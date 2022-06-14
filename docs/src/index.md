# TSx.jl

TSx provides a convenient interface for performing standard
manipulations of timeseries data. The package uses `DataFrame` at it's
core to allow powerful data manipulation functions while being
lightweight. It is inspired by
[zoo](https://cran.r-project.org/web/packages/zoo/index.html) and
[xts](https://cran.r-project.org/web/packages/xts/index.html) packages
from the [R](https://www.r-project.org/) world.

TSx wraps a familiar syntax for timeseries operations over `DataFrame`
type, thereby, providing the user with full set of `DataFrame`
functionalities as well. Integrations with other packages in the Julia
ecosystem which are supported by
[DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) come to
`TSx` at little cost.

To start using `TSx.jl` take a look at the [basic demo](demo_finance.md)
and then head to the [User guide](user_guide.md).

## User guide

```@contents
Pages = ["user_guide.md"]
```

## API reference

```@index
Pages = ["api.md"]
```
