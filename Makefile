
.PHONY: test doc

test:
	julia --project -e 'using Pkg; Pkg.test(coverage=true);'

doc:
	julia --project --color=yes docs/make.jl

