# User guide

This page describes how to use the TSFrames package for timeseries data
handling.

## Installation

```julia
julia> using Pkg
julia> Pkg.add(url="https://github.com/xKDR/TSFrames.jl")
```

## Constructing TSFrame objects

After installing TSFrames you need to load the package in Julia
environment. Then, create a basic `TSFrame` object.

```@repl
using TSFrames;
ts = TSFrame(1:10)
ts.coredata
```

The basic TSFrame constructor takes in a `Vector` of any type and
automatically generates an index out of it (the `Index` column).

There are many ways to construct a `TSFrame` object. For real world
applications you would want to read in a CSV file or download a dataset
as a `DataFrame` and then operate on it. You can easily convert a
`DataFrame` to a `TSFrame` object.

```@repl e1
using CSV, DataFrames, TSFrames, Dates
dates = Date(2007, 1, 1):Day(1):Date(2008, 03, 06)
ts = TSFrame(DataFrame(Index=dates, value=10*rand(431)))
```

In the above example you generate a random `DataFrame` and convert it
into a `TSFrame` object `ts`. The top line of the `ts` object tells you the number of
rows (`431` here) and the number of columns (`1`) along with the
`Type` of `Index` (`Dates.Date` in the above example).

You can also fetch the number of rows and columns by using `nr(ts)`,
`nc(ts)`, and `size(ts)` methods. Respectively, they fetch the number
of rows, columns, and a `Tuple` of row and column numbers. A
`length(::TSFrame)` method is also provided for convenience which returns
the number of rows of it's argument.

```@repl e1
nr(ts)
nc(ts)
size(ts)
length(ts)
```

Names of data columns can be fetched using the `names(ts)` method
which returns a `Vector{String}` object. The `Index` column can be
fetched as an object of `Vector` type by using the `index(ts)` method,
it can also be fetched directly using the underlying `coredata`
property of TSFrame: `ts.coredata[!, :Index]`.

```@repl e1
names(ts)
index(ts)
```

Another simpler way to read a CSV is to pass `TSFrame` as a sink to the `CSV.read` function.

```julia-repl
julia> ts = CSV.File(filename, TSFrame)
```

## Indexing and subsetting

One of the primary features of a timeseries package is to provide ways
to index or subset a dataset using convenient interfaces. TSFrames makes it
easier to index a `TSFrame` object by providing multiple intuitive
`getindex` methods which work by just using the regular square
parentheses(`[ ]`).

```@repl e1
ts[1] # first row
ts[[3, 5], [1]] # third & fifth row, and first column
ts[1:10, 1] # first 10 rows and the first column as a vector
ts[1, [:value]] # using the column name
```

Apart from integer-based row indexing and integer, name based column
indexing, TSFrames provides special subsetting methods for date and time
types defined inside the `Dates` module.

```@repl e1
ts[Date(2007, 1, 10)] # on January 10, 2007
ts[[Date(2007, 1, 10), Date(2007, 1, 11)]] # January 10, 11
ts[Year(2007), Month(1)] # entire January 2007
ts[Year(2007), Quarter(2)]
```

Finally, one can also use the dot notation to get a column as a vector.

```@repl e1
ts.value # get the value column as a vector
```

## Summary statistics

The `describe()` method prints summary statistics of the TSFrame
object. The output is a `DataFrame` which includes the number of
missing values, data types of columns along with computed statistical
values.

```@repl e1
TSFrames.describe(ts)
```


## Plotting

A TSFrame object can be plotted using the `plot()` function of the `Plots`
package. The plotting functionality is provided by `RecipesBase`
package so all the flexibility and functionality of the `Plots`
package is available for users.

```@example e1
using Plots
plot(ts, size=(600,400); legend=false)
```

## Applying a function over a period

The `apply` method allows you to aggregate the TSFrame object over a period
type (`Dates.Period`(@ref)) and return the output of applying the
function on each period. For example, to convert frequency of daily
timeseries to monthly you may use `first()`, `last()`, or
`Statistics.mean()` functions and the period as `Dates.Month`.

```@repl e1
using Statistics
ts_monthly = apply(ts, Month(1), last) # convert to monthly series using the last value for each month
ts_weekly = apply(ts, Week(1), Statistics.std) # compute weekly standard deviation
apply(ts, Week(1), Statistics.std, last) # same as above but index contains the last date of the week
apply(ts, Week(1), Statistics.std, last, renamecols=false) # do not rename column
```

## Joins: Row and column binding with other objects

TSFrames provides methods to join two TSFrame objects by columns: `join` (alias:
`cbind`) or by rows: `vcat` (alias: `rbind`). Both the methods provide
some basic intelligence while doing the merge.

`join` merges two datasets based on the `Index` values of both
objects. Depending on the join strategy employed the final object may
only contain index values only from the left object (using
`jointype=:JoinLeft`), the right object (using `jointype=:JoinRight`), intersection of
both objects (using `jointype=:JoinBoth`), or a union of both objects
(`jointype=:JoinAll`) while inserting `missing` values where index values are
missing from any of the other object.

```@repl e1
dates = collect(Date(2007,1,1):Day(1):Date(2007,1,30));
ts2 = TSFrame(rand(length(dates)), dates)
join(ts, ts2; jointype=:JoinAll) # cbind/join on Index column
```

`vcat` also works similarly but merges two datasets by rows. This
method also uses certain strategies provided via `colmerge` argument
to check for certain conditions before doing the merge, throwing an
error if the conditions are not satisfied.

`colmerge` can be passed `setequal` which merges only if both objects
have same column names, `orderequal` which merges only if both objects
have same column names and columns are in the same order, `intersect`
merges only the columns which are common to both objects, and `union`
which merges even if the columns differ between the two objects, the
resulting object has the columns filled with `missing`, if necessary.

For `vcat`, if the values of `Index` are same in the two objects then
all the index values along with values in other columns are kept in
the resulting object. So, a `vcat` operation may result in duplicate
`Index` values and the results from other operations may differ or
even throw unknown errors.

```@repl e1
dates = collect(Date(2008,4,1):Day(1):Date(2008,4,30));
ts3 = TSFrame(DataFrame(values=rand(length(dates)), Index=dates))
vcat(ts, ts3) # do the merge
```


## Rolling window operations

The `rollapply` applies a function over a fixed-size rolling window on
the dataset. In the example below, we compute the 10-day average of
dataset values on a rolling basis.

```@repl e1
rollapply(ts, mean, 10)
```


## Computing rolling difference and percent change

Similar to `apply` and `rollapply` there are specific methods to
compute rolling differences and percent changes of a `TSFrame` object. The
`diff` method computes mathematical difference of values in adjacent
rows, inserting `missing` in the first row. `pctchange` computes the
percentage change between adjacent rows.

```@repl e1
diff(ts)
pctchange(ts)
```

## Computing log of data values

```@repl e1
log.(ts)
```

## Creating lagged/leading series

`lag()` and `lead()` provide ways to lag or lead a series respectively
by a fixed value, inserting `missing` where required.

```@repl e1
lag(ts, 2)
lead(ts, 2)
```

## Converting to Matrix and DataFrame

You can easily convert a TSFrame object into a `Matrix` or fetch the
`DataFrame` for doing operations which are outside of the TSFrames scope.

```@repl e1
ts[:, 1] # convert column 1 to a vector of floats
Matrix(ts) # convert entire TSFrame into a Matrix
select(ts.coredata, :Index, :value, DataFrames.nrow) # use the underlying DataFrame for other operations
```
## Writing TSFrame into a CSV file

Writing a TSFrame object into a CSV file can be done easily by using the
underlying `coredata` property. This `DataFrame` can be passed to
the `CSV.write` method for writing into a file.

```@repl e1
CSV.write("/tmp/demo_ts.csv", ts)
```

## Broadcasting

Broadcasting can be used on a `TSFrame` object to apply a function to a subset of it's columns.

```jldoctest
julia> using TSFrames, DataFrames;

julia> ts = TSFrame(DataFrame(Index = [1, 2, 3, 4, 5], A = [10.1, 12.4, 42.4, 24.1, 242.5], B = [2, 4, 6, 8, 10]))
(5 x 2) TSFrame with Int64 Index

 Index  A        B     
 Int64  Float64  Int64 
───────────────────────
     1     10.1      2
     2     12.4      4
     3     42.4      6
     4     24.1      8
     5    242.5     10

julia> sin_A = sin.(ts[:, [:A]])    # get sin of column A
(5 x 1) TSFrame with Int64 Index

 Index  A_sin
 Int64  Float64
──────────────────
     1  -0.625071
     2  -0.165604
     3  -0.999934
     4  -0.858707
     5  -0.562466

julia> log_ts = log.(ts)    # take log of all columns
(5 x 2) TSFrame with Int64 Index

 Index  A_log    B_log
 Int64  Float64  Float64
──────────────────────────
     1  2.31254  0.693147
     2  2.5177   1.38629
     3  3.74715  1.79176
     4  3.18221  2.07944
     5  5.491    2.30259

julia> log_ts = log.(ts[:, [:A, :B]])   # can specify multiple columns
(5 x 2) TSFrame with Int64 Index

 Index  A_log    B_log
 Int64  Float64  Float64
──────────────────────────
     1  2.31254  0.693147
     2  2.5177   1.38629
     3  3.74715  1.79176
     4  3.18221  2.07944
     5  5.491    2.30259

```

## [Tables.jl](https://github.com/JuliaData/Tables.jl) Integration

`TSFrame` objects are [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible. This integration enables easy conversion between the `TSFrame` format and other formats which are [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible.

As an example, first consider the following code which converts a `TSFrame` object into a `DataFrame`, a `TimeArray` and a `CSV` file respectively.

```julia
julia> using TSFrames, TimeSeries, Dates, DataFrames, CSV;

julia> dates = Date(2018, 1, 1):Day(1):Date(2018, 12, 31)
Date("2018-01-01"):Day(1):Date("2018-12-31")

julia> ts = TSFrame(DataFrame(Index = dates, x1 = 1:365));

# conversion to DataFrames
julia> df = DataFrame(ts);

# conversion to TimeArray
julia> timeArray = TimeArray(ts, timestamp = :Index);

# writing to CSV
julia> CSV.write("ts.csv", ts);

```

Next, here is some code which converts a `DataFrame`, a `TimeArray` and a `CSV` file to a `TSFrame` object.

```julia-repl
julia> using TSFrames, DataFrames, CSV, TimeSeries, Dates;

# converting DataFrame to TSFrame
julia> ts = TSFrame(DataFrame(Index=1:10, x1=1:10));

# converting from TimeArray to TSFrame
julia> dates = Date(2018, 1, 1):Day(1):Date(2018, 12, 31)
Date("2018-01-01"):Day(1):Date("2018-12-31")

julia> ta = TimeArray(dates, rand(length(dates)));

julia> ts = TSFrame(ta);

# converting from CSV to TSFrame
julia> CSV.read("ts.csv", TSFrame);
```

!!! note

    This discussion warrants a note about how we've implemented the [`Tables.jl`](https://github.com/JuliaData/Tables.jl) interfaces. Since `TSFrame` objects are nothing but a wrapper around a `DataFrame`, our implementations of these interfaces just call [`DataFrames.jl`](https://github.com/JuliaData/DataFrames.jl)'s implementations. Moreover, while constructing `TSFrame` objects out of other [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible types, our constructor first converts the input table to a `DataFrame`, and then converts the `DataFrame` to a `TSFrame` object.
