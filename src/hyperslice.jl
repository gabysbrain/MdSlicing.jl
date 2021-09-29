# include("types.jl")
include("util.jl")
# include("IntersectTest.jl")

using Sobol: SobolSeq, next!
using JSON

function slice2d(mesh::ConvexMesh; n::UInt32=UInt32(50)) :: SliceSet2D
  dims = size(mesh)[2]

  # Generate the focus points
  lbs = [b[1] for b = mesh.problemSpec.vals]
  ubs = [b[2] for b = mesh.problemSpec.vals]
  s = SobolSeq(lbs, ubs)
  fps = collect([next!(s) for _ = 1:n])

  hyperslice(mesh, fps)
end

function slice2d(mesh::ConvexMesh, fps::Array{PointND}) :: SliceSet2D
  slices = []
  for fp in fps
    ss = sliceDims(mesh, fp)
    append!(slices, ss)
  end
  SliceSet2D(mesh.problemSpec, slices)
end

# slices of all dimensions
function sliceDims(mesh::ConvexMesh, fp::PointND)
  slices = []
  for dd in dimComb(UInt64(size(mesh)[2]))
    ss = slice(mesh, fp, dd[1], dd[2])
    hss = [HypersliceSegment(fp, simp, dd[1], dd[2], s.p1d1, s.p1d2, s.p2d1, s.p2d2) for (simp, s) in ss]
    append!(slices, hss)
  end
  return slices
end

function slice(mesh::ConvexMesh, fp::PointND, d1::Dim, d2::Dim)::Vector{Tuple{Simplex,Intersect2D}}
  slices = Tuple{Simplex,Intersect2D}[]
  for s in mesh
    ts = [(s, t) for t in simplexPointIntersection(s, fp, d1, d2)]
    append!(slices, ts)
  end
  return slices
end

function hypersliceplorer(mesh::ConvexMesh; n::UInt32=UInt32(50))
  slices = slice2d(mesh; n=n);
  plot(slices)
end

function hypersliceplorer(mesh::ConvexMesh, fps::Array{PointND})
  slices = slice2d(mesh, fps);
  plot(slices)
end


