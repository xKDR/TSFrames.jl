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
ecosystem which are supported by `DataFrames.jl` come to `TSx` at no
cost.

<!-- TSx allows you to perform timeseries specific data operations on top -->
<!-- of a `DataFrame`. This brings you the power of DataFrames.jl as well -->
<!-- in case you want to perform operations on the TS object which TSx.jl -->
<!-- doesn't provide. -->


To start using `TSx.jl` head to the [Tutorial page](tutorial.md).

## API reference

```@index
Pages = ["api.md"]
```
