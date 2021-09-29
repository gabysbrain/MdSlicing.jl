# Multi-dimensional Slicing

A library for computing 1D and 2D slices through multi-dimensional datasets.

## Installation

```julia
Pkg.add("https://github.com/gabysbrain/MdSlicing.jl")
```

## 1D slice example

This will plot the function $f(x) = \sum x^2$.

```julia
using MdSlicing

f = x -> sum(x .* x)
spec = ProblemSpec("x1" => (-1.,1.), "x2" => (-1.,1.), "x3" => (-1.,1.))
d = slice1d(f, spec)
plot(d)
```

1. If your data is a set of samples in a table, rather than a function then
   build a regression model on your dataset so you have a function to
   visualize. Divide your data into `X` which is a table of all independent
   variables and `Y` which is a vector of a single dependent variable.

2. You will also need to create a `ProblemSpec` instance to keep track of
   the names and limits of each dimension.
   ```julia
   using MdSlicing
   lims = ProblemSpec("x1" => (-1, 1), "x2" => (-1, 1), "x3" => (-1, 1))
   ```
3. Create a set of slices from the function you have. Here, we create 50
   slices of the function for each dimension.
   ```julia
   slices = sliceplorer(f, lims)
   ```
4. Now plot the slices
   ```julia
   plot(slices)
   ```

## 2D slice example

Plot 2D cross sections of a cube:

```julia
using MdSlicing

cube = ConvexMesh(
  ProblemSpec("x1" => (0., 1.), "x2" => (0., 1.), "x3" => (0., 1.)),
  [ 0. 0. 0. ;
    0. 0. 1. ;
    0. 1. 0. ;
    0. 1. 1. ;
    1. 0. 0. ;
    1. 0. 1. ;
    1. 1. 0. ;
    1. 1. 1.
  ],
  [ 4  3  1 ;
    4  2  1 ;
    6  2  1 ;
    6  5  1 ;
    6  4  2 ;
    6  4  8 ;
    7  3  1 ;
    7  5  1 ;
    7  4  3 ;
    7  4  8 ;
    7  6  5 ;
    7  6  8 ]
)
slices = hyperslice(cube, UInt32(50));
plot(slices)
```

1. The multi-dimensional shape should be defined as a simplical mesh. You can
   create this as a vector of points in n-space and then a vector of simplices,
   specified as indices into the point vector. You'll also need a `ProblemSpec`
   instance to define the bounds of the figure.
   ```julia
   lims = ProblemSpec("x1" => (0., 1.), "x2" => (0., 1.), "x3" => (0., 1.));
   points = [ 0. 0. 0. ;
              0. 0. 1. ;
              0. 1. 0. ;
              0. 1. 1. ;
              1. 0. 0. ;
              1. 0. 1. ;
              1. 1. 0. ;
              1. 1. 1.
            ];
   simplices = [ 4  3  1 ;
                4  2  1 ;
                6  2  1 ;
                6  5  1 ;
                6  4  2 ;
                6  4  8 ;
                7  3  1 ;
                7  5  1 ;
                7  4  3 ;
                7  4  8 ;
                7  6  5 ;
                7  6  8 ];
   cube = ConvexMesh(lims, points, simplices)
   ```
2. Create a set of slices using `hyperslice`
   ```julia
   slices = slice2d(cube; n=UInt32(50));
   ```
3. View the results
   ```julia
   plot(slices)
   ```

## License

This project is licensed under a BSD License --- see the
[LICENSE.md](LICENSE.md) file for details.

