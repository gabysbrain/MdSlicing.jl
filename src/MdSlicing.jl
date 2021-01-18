module MdSlicing
export ProblemSpec, fillfps, hyperslice, sliceplorer, plot

include("types.jl")
include("meshes.jl")
include("hyperslicesets.jl")
include("hyperslice.jl")
include("sliceplorer.jl")
include("plots.jl")

# FIXME: put types back in
#function fillfps(ps::ProblemSpec, fp::Array{Union{Missing,Float64},1}, n::Int = 50)
function fillfps(ps, fp, n = 50)
  if !any(map(ismissing, fp)) # special case
    return [fp]
  end
  fpvals =
    [ismissing(x[1]) ? (x[2][1] .+ (x[2][2]-x[2][1]) .* rand(n)) : fill(x[1], n) for x in zip(fp, ps.vals)]
  # transpose everything
  [[fpvals[c][r] for c=1:length(fp)] for r = 1:n]
end

end # module
