
## Sliceplorer definition stuff
using Sobol

function func1d(f, pt, d)
  function(x)
    xx = copy(pt)
    xx[d] = x
    f(xx)
  end
end

function func_samples(f, rng, pt, d)
  f1d = func1d(f, pt, d)
  samples = range(rng[1], stop=rng[2], length=51) # 50 samples for now
  [(x, f1d(x)) for x = samples]
end

function sample_dim(f, rng, fps, d)
  [func_samples(f, rng, fp, d) for fp = fps]
end

@doc raw"""
    sliceplorer(f, spec)

Compute the slices for a given function `f` given the ProblemSpec 
range `spec`.

See also: [`plot`](@ref)

# Examples

This will plot the function $f(x) = \sum x^2$.
```julia-repl
julia> f = x -> sum(x .* x)
julia> spec = ProblemSpec("x1" => (-1.,1.), "x2" => (-1.,1.), "x3" => (-1.,1.))
julia> d = sliceplorer(f, spec)
julia> plot(d)
```
"""
# TODO: add type signature
function sliceplorer(f, spec, n=50)
  focuspoints = gen_fps(spec, n)
  samps = sample_fps(f, focuspoints, spec, n)
  Sliceplorer(focuspoints, samps)
end

function gen_fps(spec, n)
  # Create focus points for slicing
  dmins = [x[1] for (_,x) in spec]
  dmaxs = [x[2] for (_,x) in spec]
  seq = SobolSeq(dmins, dmaxs)
  hcat([next!(seq) for i = 1:n])
end

function sample_fps(f, focuspoints, spec, n)
  samps = SliceplorerSamples()
  for (i,d) in enumerate(keys(spec))
    samps[d] = sample_dim(f, spec[d], focuspoints, i)
  end
  samps
end


