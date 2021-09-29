using Plots
using RecipesBase

# function primarily to create an individual sliceplorer sub-plot
#@recipe function f(::Type{Val{:sliceplorerdim}}, x, y, z)
@recipe function f(spDim::SliceplorerDim)
  #spDim = y;
  # separate out the x and y values from the data structure
  xs = [[v′.pt[1] for v′ in v.sample] for v in spDim.dim]
  ys = [[v′.pt[2] for v′ in v.sample] for v in spDim.dim]

  # plot properties
  # FIXME: set line width to something nice
  seriestype := :line # sort by x
  legend := false
  linealpha --> 0.4
  linecolor --> :black
  
  (hcat(xs...), hcat(ys...))
end

# TODO: add option to lay out everything vertically, etc
@recipe function f(sp::SliceSet1D)

  # global options for the subplots
  legend := false
  link := :both
  layout := length(sp.problemSpec) # number of dimensions
  #seriestype := :sliceplorerdim

  # FIXME: adjust positioning of title
  title := [k for j in 1:1, k in keys(sp.samples.samples)]
  titlelocation := :right
  titlefont := font(8)

  # FIXME: might need to be a map (i.e. returns something)
  for (i, spDim) in enumerate(values(sp.samples.samples))
    @series begin
      subplot := i
      spDim
    end
  end
end

# TODO: is it worth splitting this by suplot like the other dataset?
@recipe function f(hsp::Vector{HypersliceSet})

  # need to sort by dims otherwise layout and splitting doesn't work
  slices = sort(hsp.slices, by=x -> (x.d1, x.d2));
 
  # universal settings
  linecolor := :black
  linealpha --> 0.4
  seriestype := :path

  # layout is a SPLOM-style layout
  dims = length(hsp.problemSpec);
  layoutRows = map(1:(dims-1)) do d
    hcat(fill(nothing, (1, )), fill(∘, (1, dims-d)))
  end
  # FIXME: might need to search/replace the underscore...
  layout := @layout vcat(layoutRows)

  # cut up the segment list by dimension
  # and generate a subplot per segment
  # FIXME: seems like there could be a better algorithm
  subplot = 1
  iRow = 1
  while iRow <= length(slices)
    dimSet = (slices[iRow].d1, slices[iRow].d2);
    i = iRow + 1
    while dimSet == (slices[i].d1, slices[i].d2) && i <= length(slices)
      i = i + 1;
    end
    
    @series begin
      slices[iRow:i]
      subplot := subplot
    end

    iRow = i;
  end
  
end

