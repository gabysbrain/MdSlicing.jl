module App.NearestNeighbor 
  where
  --( radialNN
  --) where

import Prelude
import App.Data (DataPoint, Link, rowVal)
import Data.Bifunctor (bimap)
import Data.List (List)
import Data.List as L
import Data.Foldable (class Foldable, foldl, foldMap, maximumBy, minimumBy)
import Data.Maybe (Maybe(..), fromJust)
import Data.Tuple (Tuple(..), fst, snd, swap)
import Data.Geom.Point (Point)
import Data.Geom.Point as P
import Data.Geom.Point ((!!!))
import Data.Geom.Vector as V
import Data.Geom.Line as Line
import Partial.Unsafe (unsafePartial)

newtype HullSegment d = HullSegment (Tuple (Point d) (Point d))

instance showHullSegment :: Show (HullSegment d) where
  show (HullSegment hs) = show hs

-- equality is equal in both directions. we might need to fix this later...
instance eqHullSegment :: Eq (HullSegment d) where
  eq (HullSegment hs1) (HullSegment hs2) = (hs1 == hs2) || (swap hs1 == hs2)

mapPts :: forall d d'. (Point d -> Point d') -> HullSegment d -> HullSegment d'
mapPts f (HullSegment hs) = HullSegment $ bimap f f hs

-- TODO: move the data types around to unify them...
-- | neighborhood based on radius
radialNN :: forall f d. Foldable f 
         => Number -> f (DataPoint d) -> List (Link d)
radialNN r df = _radialNN r (L.fromFoldable df) L.Nil

_radialNN :: forall d
           . Number 
          -> List (DataPoint d)
          -> List {src::DataPoint d,tgt::DataPoint d}
          -> List (Link d)
_radialNN r df accum = case L.uncons df of
  Nothing -> L.mapWithIndex (\i ns -> {linkId:i,src:ns.src,tgt:ns.tgt}) accum
  Just {head:pt,tail:pts} -> _radialNN r pts (accum <> createNbrsR r pt pts)

-- find the set of neighbors a certain distance around a point (pt)
createNbrsR :: forall d
             . Number -> DataPoint d -> List (DataPoint d) 
            -> List {src::DataPoint d,tgt::DataPoint d}
createNbrsR r pt = foldMap (mkNbr pt)
  where
  mkNbr p1 p2 = if rowVal (P.sqDist <$> p1 <*> p2) <= r*r
                   then L.singleton {src:p1, tgt:p2}
                   else L.Nil

-- | delauny triangulation computation
delauny :: forall f d. Foldable f
        => f (Point d) -> List (HullSegment d)
--      => f (DataPoint d) -> List (HullSegment d)
delauny = projectUp >>> convexHull >>> L.filter lowerLink >>> projectDown
  where
  projectUp = foldMap (pure <<< addDistDim)
  projectDown = map (mapPts rmDistDim)

addDistDim :: forall d d'. Point d -> Point d'
addDistDim = P.projectUp (pure <<< distFun)
  where
  distFun = foldl (\s x -> s + x*x) 0.0

rmDistDim :: forall d d'. Point d -> Point d'
rmDistDim p = P.projectNot (P.dims p - 1) p

-- determine if a link is part of the "lower" hull
lowerLink :: forall d. HullSegment d -> Boolean
lowerLink (HullSegment link) = 
    (fst link !!! lastidx) - (snd link !!! lastidx) /= 0.0
  where
  lastidx = P.dims $ fst link

convexHull :: forall d. List (Point d) -> List (HullSegment d)
convexHull = quickhull

quickhull :: forall d. List (Point d) -> List (HullSegment d)
quickhull pts | L.length pts < 2 = L.Nil -- one point does not a hull make
quickhull (L.Cons p1 (L.Cons p2 L.Nil)) = pure $ HullSegment $ Tuple p1 p2
quickhull pts = (findHull left right splits.init)
             <> (findHull right left splits.rest)
  where
    left  = unsafeMinBy (\p1 p2 -> compare (p1 !!! 0) (p2 !!! 0)) pts
    right = unsafeMaxBy (\p1 p2 -> compare (p1 !!! 0) (p2 !!! 0)) pts
    splits = splitPts left right pts

-- split the set of points into left and right hand points
splitPts :: forall d
          . Point d -> Point d 
         -> List (Point d)
         -> {init :: List (Point d), rest :: List (Point d)}
splitPts lp1 lp2 = split <<< rmPts
  where
  split = L.span (rhsPts lp1 lp2)
  rmPts = L.filter (\p -> p /= lp1 && p /= lp2)

findHull :: forall d
          . Point d -> Point d 
         -> List (Point d)
         -> List (HullSegment d)
findHull lp1 lp2 L.Nil = pure $ HullSegment $ Tuple lp1 lp2 -- done!
findHull lp1 lp2 pts = findHull lp2 maxPt split.init 
                    <> findHull maxPt lp1 split.rest
  where
  l = Line.fromPoints lp1 lp2
  maxPt = unsafeMaxBy (\p1 p2 -> compare (Line.dist2pt l p1) (Line.dist2pt l p2)) pts
  split = splitPts maxPt lp2 pts

rhsPts :: forall d. Point d -> Point d -> Point d -> Boolean
rhsPts lp1 lp2 pt = V.sinTheta v1 v2 > 0.0
  where
  v1 = V.fromPoints lp1 lp2
  v2 = V.fromPoints lp1 pt

-- dangerous functions but these are only run on non-empty lists
unsafeMaxBy :: forall a f. Foldable f => (a -> a -> Ordering) -> f a -> a
unsafeMaxBy f l = unsafePartial $ fromJust $ maximumBy f l
unsafeMinBy :: forall a f. Foldable f => (a -> a -> Ordering) -> f a -> a
unsafeMinBy f l = unsafePartial $ fromJust $ minimumBy f l

