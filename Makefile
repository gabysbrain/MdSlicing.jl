
.PHONY: test testcov doc

test:
	julia --project -e 'using Pkg; Pkg.test(coverage=false);'

testcov:
	julia --project -e 'using Pkg; Pkg.test(coverage=true);'

doc:
	julia --project --color=yes docs/make.jl

