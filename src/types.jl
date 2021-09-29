
# Types for use in the rest of the package

using DataStructures: OrderedDict
using JSON

const EPS = sqrt(eps())

Dim = UInt

struct Intersect2D
    p1d1::Float64
    p1d2::Float64
    p2d1::Float64
    p2d2::Float64
end

function Base.isapprox(x::Intersect2D, y::Intersect2D; atol::Real=0, rtol::Real=rtoldefault(x, y, atol), nans::Bool=false)
  # FIXME: easy to break
    isapprox(x.p1d1, y.p1d1, atol, rtol, nans) &&
  isapprox(x.p1d2, y.p1d2, atol, rtol, nans) &&
  isapprox(x.p2d1, y.p2d1, atol, rtol, nans) &&
  isapprox(x.p2d2, y.p2d2, atol, rtol, nans)
end

PointND = Vector{Float64}
LambdaND = Vector{Float64}

Simplex = Array{Float64}

ProblemSpec = OrderedDict{String,Tuple{Float64,Float64}}

struct SliceplorerPoint 
  pt :: Tuple{Float64,Float64}
end
struct SliceplorerDimSample 
  sample :: Array{SliceplorerPoint} # a single slice
end
struct SliceplorerDim 
  dim :: Array{SliceplorerDimSample} # each element is one 'line' in the plot
end
struct SliceplorerSamples 
  samples :: OrderedDict{String,SliceplorerDim}
end

struct Sliceplorer 
  problemSpec::ProblemSpec
  focusPoints::Array{PointND}
  samples::SliceplorerSamples
end

