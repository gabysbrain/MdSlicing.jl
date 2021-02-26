# using Compose
# using ColorTypes
using VegaLite
using DataFrames

# include("types.jl")

# Converts sliceplorer data to the DataFrame needed for vegalite
function vl_data(data::Sliceplorer)
  output = nothing
  for (dimname, vals) in data.samples
    dfs = [ DataFrame(dim=dimname, 
            fpid=i, 
            x=[vv[1] for vv in v],
            y=[vv[2] for vv in v])
       for (i, v) in enumerate(vals) ]
    df = reduce(vcat, dfs)
    if output === nothing
      output = df
    else
      output = vcat(output, df)
    end
  end
  output
end

function vl_data(data::HypersliceSet)
  # FIXME: need case for empty set
  fpid = 1;
  curfp = data.slices[1].fp;
  output = nothing;
  for slice in data.slices
  # maybe update fpid
    if slice.fp != curfp
      fpid = fpid + 1;
      curfp = slice.fp;
    end
    df = DataFrame(d1=slice.d1, d2=slice.d2, fpid=fpid, 
           x1=slice.p1d1, x2=slice.p2d1, 
           y1=slice.p1d2, y2=slice.p2d2);
    if output === nothing
      output = df;
    else
      output = vcat(output, df);
    end
  end
  output
end

function plot(data::Sliceplorer)
  # Vegalite needs something like a dataframe
  df = vl_data(data);
  df |>
  @vlplot(
    mark = {:line, opacity = 0.4, stroke = "black"},
    row = :dim, # facet by dimension
    y = :y,
    x = :x,
    detail = :fpid
  )
end

function plot(data::HypersliceSet)
  df = vl_data(data);
    # row = :d2,
    # col = :d1,
  df |>
  @vlplot(
    mark = {:rule, opacity = 0.4, stroke = "black"},
    x = :x1,
    y = :y1,
    x2 = :x2,
    y2 = :y2,
    row = :d1,
    column = :d2,
    detail = :fpid
  )
end

