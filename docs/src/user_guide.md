# User guide

This page describes how to use the TSx package for timeseries data
handling.

## Installation

```julia
julia> using Pkg
julia> Pkg.add(url="https://github.com/xKDR/TSx.jl")
```

## Constructing TS objects

After installing TSx you need to load the package in Julia
environment. Then, create a basic `TS` object.

```julia
julia> using TSx

julia> ts = TS(1:10)
(10 x 1) TS with Int64 Index

 Index  x1
 Int64  Int64
──────────────
     1      1
     2      2
     3      3
     4      4
     5      5
     6      6
     7      7
     8      8
     9      9
    10     10

julia> show(ts.coredata)
10×2 DataFrame
 Row │ Index  x1
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     2      2
   3 │     3      3
   4 │     4      4
   5 │     5      5
   6 │     6      6
   7 │     7      7
   8 │     8      8
   9 │     9      9
  10 │    10     10

```

The basic TS constructor takes in a `Vector` of any type and
automatically generates an index out of it (the `Index` column).

There are many ways to construct a `TS` object. For real world
applications you would want to read in a CSV file or download a dataset
as a `DataFrame` and then operate on it. You can easily convert a
`DataFrame` to a `TS` object.

```@repl e1
using CSV, DataFrames, TSx

filename = joinpath(dirname(pathof(TSx)),
    "..", "docs", "src", "assets", "sample_daily.csv");

df = CSV.read(filename, DataFrame);
show(df)

ts = TS(df);
show(ts)
```

In the above example you load a CSV file bundled with TSx package,
store it into a DataFrame `df` and then convert `df` into a `TS`
object `ts`. The top line of the `ts` object tells you the number of
rows (`431` here) and the number of columns (`1`) along with the
`Type` of `Index` (`Dates.Date` in the above example).

You can also fetch the number of rows and columns by using `nr(ts)`,
`nc(ts)`, and `size(ts)` methods. Respectively, they fetch the number
of rows, columns, and a `Tuple` of row and column numbers. A
`length(::TS)` method is also provided for convenience which returns
the number of rows of it's argument.

```julia
julia> nr(ts)
431

julia> nc(ts)
1

julia> size(ts)
(431, 1)

julia> length(ts)
431

```

Names of data columns can be fetched using the `names(ts)` method
which returns a `Vector{String}` object. The `Index` column can be
fetched as an object of `Vector` type by using the `index(ts)` method,
it can also be fetched directly using the underlying `coredata`
property of TS: `ts.coredata[!, :Index]`.

```julia
julia> names(ts)
1-element Vector{String}:
 "value"

julia> index(ts)
431-element Vector{Date}:
 2007-01-01
 2007-01-02
 2007-01-03
 2007-01-04
 2007-01-05
 2007-01-06
 2007-01-07
 2007-01-08
 2007-01-09
 2007-01-10
 2007-01-11
 ⋮
 2008-02-25
 2008-02-26
 2008-02-27
 2008-02-28
 2008-02-29
 2008-03-01
 2008-03-02
 2008-03-03
 2008-03-04
 2008-03-05
 2008-03-06

```

Another simpler way to read a CSV directly into a TS object is by
using pipes.

```julia
julia> ts = CSV.File(filename) |> DataFrame |> TS
```

## Indexing and subsetting

One of the primary features of a timeseries package is to provide ways
to index or subset a dataset using convenient interfaces. TSx makes it
easier to index a `TS` object by providing multiple intuitive
`getindex` methods which work by just using the regular square
parenthese (`[ ]`).

```julia
# first row
julia> ts[1]
(1 x 1) TS with Dates.Date Index

 Index       value
 Date        Float64
─────────────────────
 2007-01-01  10.1248


# third & fifth row, and first column
julia> ts[[3, 5], [1]]
(2 x 1) TS with Date Index

 Index       value
 Date        Float64
──────────────────────
 2007-01-03   7.83777
 2007-01-05  12.4548


# first 10 rows and the first column as a vector
julia> ts[1:10, 1]
10-element Vector{Float64}:
 10.1248338098958
 10.3424091138411
  7.83777413591419
  9.87615632977506
 12.4548084674329
  8.63083527336206
  8.67408599632254
  9.75221297863206
  8.76405813698277
 10.8086548113129


# using the column name
julia> ts[1, [:value]]
(1 x 1) TS with Dates.Date Index

 Index       value
 Date        Float64
─────────────────────
 2007-01-01  10.1248

```

Apart from integer-based row indexing and integer, name based column
indexing, TSx provides special subsetting methods for date and time
types defined inside the `Dates` module.

```julia
julia> using Dates

# on January 10, 2007
julia> ts[Date(2007, 1, 10)]
(1 x 1) TS with Date Index

 Index       value
 Date        Float64
─────────────────────
 2007-01-10  10.8087

# January 10, 11
julia> ts[[Date(2007, 1, 10), Date(2007, 1, 11)]]
(2 x 1) TS with Date Index

 Index       value
 Date        Float64
──────────────────────
 2007-01-10  10.8087
 2007-01-11   9.74481


# entire January 2007
julia> ts[Year(2007), Month(1)]
(31 x 1) TS with Date Index

 Index       value
 Date        Float64
──────────────────────
 2007-01-01  10.1248
 2007-01-02  10.3424
 2007-01-03   7.83777
 2007-01-04   9.87616
 2007-01-05  12.4548
 2007-01-06   8.63084
 2007-01-07   8.67409
 2007-01-08   9.75221
 2007-01-09   8.76406
 2007-01-10  10.8087
 2007-01-11   9.74481
 2007-01-12  11.0995
 2007-01-13   9.54143
 2007-01-14  11.167
 2007-01-15  10.144
 2007-01-16  11.1019
 2007-01-17  10.5315
 2007-01-18  10.0811
 2007-01-19  12.5888
 2007-01-20  10.2757
 2007-01-21  10.6202
 2007-01-22  10.6328
 2007-01-23  10.5008
 2007-01-24   7.88032
 2007-01-25   9.95546
 2007-01-26   8.26072
 2007-01-27   9.04647
 2007-01-28   8.85252
 2007-01-29   8.47322
 2007-01-30  11.0956
 2007-01-31  10.5902

julia> ts[Year(2007), Quarter(2)];

```

Finally, one can also use the dot notation to get a column as a vector.

```julia
# get the value column as a vector
julia> ts.value;

```

## Summary statistics

The `describe()` method prints summary statistics of the TS
object. The output is a `DataFrame` which includes the number of
missing values, data types of columns along with computed statistical
values.

```julia
julia> TSx.describe(ts)
2×7 DataFrame
 Row │ variable  mean     min         median      max         nmissing  eltype
     │ Symbol    Union…   Any         Any         Any         Int64     DataType
─────┼───────────────────────────────────────────────────────────────────────────
   1 │ Index              2007-01-01  2007-08-04  2008-03-06         0  Date
   2 │ value     9.98177  7.83777     10.1248     12.5888            0  Float64

```


## Plotting

A TS object can be plotted using the `plot()` function of the `Plots`
package. The plotting functionality is provided by `RecipesBase`
package so all the flexibility and functionality of the `Plots`
package is available for users.

```@example e1
using Plots
plot(ts, size=(600,400); legend=false)
```

## Applying a function over a period

The `apply` method allows you to aggregate the TS object over a period
type (`Dates.Period`(@ref)) and return the output of applying the
function on each period. For example, to convert frequency of daily
timeseries to monthly you may use `first()`, `last()`, or
`Statistics.mean()` functions and the period as `Dates.Month`.

```julia
julia> using Statistics

# convert to monthly series using the last value for each month
julia> ts_monthly = apply(ts, Month, last)
(15 x 1) TS with Date Index

 Index       value_last
 Date        Float64
────────────────────────
 2007-01-01    10.5902
 2007-02-01     8.85252
 2007-03-01     8.85252
 2007-04-01     9.04647
 2007-05-01     9.04647
 2007-06-01     8.26072
 2007-07-01     8.26072
 2007-08-01     8.26072
 2007-09-01     9.95546
 2007-10-01     9.95546
 2007-11-01     7.88032
 2007-12-01     7.88032
 2008-01-01     7.88032
 2008-02-01    10.6328
 2008-03-01     8.85252


# compute weekly standard deviation
julia> ts_weekly = apply(ts, Week, Statistics.std)
(62 x 1) TS with Date Index

 Index       value_std
 Date        Float64
───────────────────────
 2007-01-01   1.52077
 2007-01-08   0.910942
 2007-01-15   0.876362
 2007-01-22   1.08075
 2007-01-29   1.17684
 2007-02-05   1.40065
 2007-02-12   0.630415
 2007-02-19   1.38134
 2007-02-26   1.10601
 2007-03-05   1.51014
     ⋮           ⋮
 2008-01-07   1.47589
 2008-01-14   0.923073
 2008-01-21   0.885798
 2008-01-28   1.16116
 2008-02-04   1.22311
 2008-02-11   1.40016
 2008-02-18   0.680589
 2008-02-25   1.37616
 2008-03-03   0.702384
        43 rows omitted

# same as above but index contains the last date of the week
julia> apply(ts, Week, Statistics.std, last)
(62 x 1) TS with Date Index

 Index       value_std
 Date        Float64
───────────────────────
 2007-01-07   1.52077
 2007-01-14   0.910942
 2007-01-21   0.876362
 2007-01-28   1.08075
 2007-02-04   1.17684
 2007-02-11   1.40065
 2007-02-18   0.630415
 2007-02-25   1.38134
 2007-03-04   1.10601
 2007-03-11   1.51014
     ⋮           ⋮
 2008-01-13   1.47589
 2008-01-20   0.923073
 2008-01-27   0.885798
 2008-02-03   1.16116
 2008-02-10   1.22311
 2008-02-17   1.40016
 2008-02-24   0.680589
 2008-03-02   1.37616
 2008-03-06   0.702384
        43 rows omitted

# do not rename column
julia> apply(ts, Week, Statistics.std, last, renamecols=false)
(62 x 1) TS with Date Index

 Index       value
 Date        Float64
──────────────────────
 2007-01-07  1.52077
 2007-01-14  0.910942
 2007-01-21  0.876362
 2007-01-28  1.08075
 2007-02-04  1.17684
 2007-02-11  1.40065
 2007-02-18  0.630415
 2007-02-25  1.38134
 2007-03-04  1.10601
 2007-03-11  1.51014
     ⋮          ⋮
 2008-01-13  1.47589
 2008-01-20  0.923073
 2008-01-27  0.885798
 2008-02-03  1.16116
 2008-02-10  1.22311
 2008-02-17  1.40016
 2008-02-24  0.680589
 2008-03-02  1.37616
 2008-03-06  0.702384
       43 rows omitted

```

## Joins: Row and column binding with other objects

TSx provides methods to join two TS objects by columns: `join` (alias:
`cbind`) or by rows: `vcat` (alias: `rbind`). Both the methods provide
some basic intelligence while doing the merge.

`join` merges two datasets based on the `Index` values of both
objects. Depending on the join strategy employed the final object may
only contain index values only from the left object (using
`JoinLeft`), the right object (using `JoinRight`), intersection of
both objects (using `JoinBoth`), or a union of both objects
(`JoinAll`) while inserting `missing` values where index values are
missing from any of the other object.

```julia
julia> dates = collect(Date(2007,1,1):Day(1):Date(2007,1,30));
julia> ts2 = TS(rand(length(dates)), dates)
(30 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2007-01-01  0.125811
 2007-01-02  0.06005
 2007-01-03  0.324745
 2007-01-04  0.873089
 2007-01-05  0.781964
 2007-01-06  0.570593
 2007-01-07  0.770224
 2007-01-08  0.295923
 2007-01-09  0.363075
 2007-01-10  0.985884
     ⋮           ⋮
 2007-01-22  0.222852
 2007-01-23  0.818168
 2007-01-24  0.718452
 2007-01-25  0.863064
 2007-01-26  0.0572773
 2007-01-27  0.282689
 2007-01-28  0.547679
 2007-01-29  0.380771
 2007-01-30  0.945756
        11 rows omitted


# cbind/join on Index column
julia> join(ts, ts2, JoinAll)
(431 x 2) TS with Date Index

 Index       value     x1
 Date        Float64?  Float64?
──────────────────────────────────────
 2007-01-01  10.1248         0.441924
 2007-01-02  10.3424         0.140323
 2007-01-03   7.83777        0.71753
 2007-01-04   9.87616        0.762919
 2007-01-05  12.4548         0.210845
 2007-01-06   8.63084        0.3652
 2007-01-07   8.67409        0.924636
 2007-01-08   9.75221        0.864424
 2007-01-09   8.76406        0.730909
 2007-01-10  10.8087         0.985619
     ⋮          ⋮            ⋮
 2008-02-27  10.2757   missing
 2008-02-28  10.6202   missing
 2008-02-29  10.6328   missing
 2008-03-01  10.5008   missing
 2008-03-02   7.88032  missing
 2008-03-03   9.95546  missing
 2008-03-04   8.26072  missing
 2008-03-05   9.04647  missing
 2008-03-06   8.85252  missing
                      412 rows omitted

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

```julia
julia> dates = collect(Date(2008,4,1):Day(1):Date(2008,4,30));
julia> ts3 = TS(DataFrame(values=rand(length(dates)), Index=dates))
(30 x 1) TS with Date Index

 Index       values
 Date        Float64
───────────────────────
 2008-04-01  0.738621
 2008-04-02  0.142737
 2008-04-03  0.760334
 2008-04-04  0.742455
 2008-04-05  0.689045
 2008-04-06  0.310307
 2008-04-07  0.839686
 2008-04-08  0.736732
 2008-04-09  0.24704
 2008-04-10  0.850607
     ⋮           ⋮
 2008-04-22  0.780828
 2008-04-23  0.179
 2008-04-24  0.226587
 2008-04-25  0.710613
 2008-04-26  0.507179
 2008-04-27  0.761281
 2008-04-28  0.0944633
 2008-04-29  0.253298
 2008-04-30  0.995585
        11 rows omitted


# do the merge
julia> vcat(ts, ts3)
(461 x 2) TS with Date Index

 Index       value          values
 Date        Float64?       Float64?
────────────────────────────────────────────
 2007-01-01       10.1248   missing
 2007-01-02       10.3424   missing
 2007-01-03        7.83777  missing
 2007-01-04        9.87616  missing
 2007-01-05       12.4548   missing
 2007-01-06        8.63084  missing
 2007-01-07        8.67409  missing
 2007-01-08        9.75221  missing
 2007-01-09        8.76406  missing
 2007-01-10       10.8087   missing
     ⋮             ⋮               ⋮
 2008-04-22  missing              0.780828
 2008-04-23  missing              0.179
 2008-04-24  missing              0.226587
 2008-04-25  missing              0.710613
 2008-04-26  missing              0.507179
 2008-04-27  missing              0.761281
 2008-04-28  missing              0.0944633
 2008-04-29  missing              0.253298
 2008-04-30  missing              0.995585
                            442 rows omitted

```


## Rolling window operations

The `rollapply` applies a function over a fixed-size rolling window on
the dataset. In the example below, we compute the 10-day average of
dataset values on a rolling basis.

```julia
julia> rollapply(Statistics.mean, ts, :value, 10)
(422 x 1) TS with Date Index

 Index       value_rolling_mean
 Date        Float64
────────────────────────────────
 2007-01-10             9.72658
 2007-01-11             9.68858
 2007-01-12             9.76428
 2007-01-13             9.93465
 2007-01-14            10.0637
 2007-01-15             9.83266
 2007-01-16            10.0798
 2007-01-17            10.2655
 2007-01-18            10.2984
 2007-01-19            10.6809
     ⋮               ⋮
 2008-02-27            10.6276
 2008-02-28            10.7151
 2008-02-29            10.6685
 2008-03-01            10.7644
 2008-03-02            10.4357
 2008-03-03            10.4169
 2008-03-04            10.1327
 2008-03-05             9.98425
 2008-03-06             9.86139
                403 rows omitted

```


## Computing rolling difference and percent change

Similar to `apply` and `rollapply` there are specific methods to
compute rolling differences and percent changes of a `TS` object. The
`diff` method computes mathematical difference of values in adjacent
rows, inserting `missing` in the first row. `pctchange` computes the
percentage change between adjacent rows.

```julia
julia> diff(ts)
^P(431 x 1) TS with Date Index

 Index       value
 Date        Float64?
─────────────────────────────
 2007-01-01  missing
 2007-01-02        0.217575
 2007-01-03       -2.50463
 2007-01-04        2.03838
 2007-01-05        2.57865
 2007-01-06       -3.82397
 2007-01-07        0.0432507
 2007-01-08        1.07813
 2007-01-09       -0.988155
 2007-01-10        2.0446
     ⋮              ⋮
 2008-02-27       -2.31316
 2008-02-28        0.344553
 2008-02-29        0.0126078
 2008-03-01       -0.131995
 2008-03-02       -2.62052
 2008-03-03        2.07514
 2008-03-04       -1.69474
 2008-03-05        0.785754
 2008-03-06       -0.193954
             412 rows omitted


julia> pctchange(ts)
(431 x 1) TS with Date Index

 Index       value
 Date        Float64?
──────────────────────────────
 2007-01-01  missing
 2007-01-02        0.0214893
 2007-01-03       -0.242171
 2007-01-04        0.260072
 2007-01-05        0.261099
 2007-01-06       -0.307028
 2007-01-07        0.00501119
 2007-01-08        0.124293
 2007-01-09       -0.101326
 2007-01-10        0.233293
     ⋮              ⋮
 2008-02-27       -0.183747
 2008-02-28        0.0335309
 2008-02-29        0.00118715
 2008-03-01       -0.0124139
 2008-03-02       -0.249554
 2008-03-03        0.263332
 2008-03-04       -0.170232
 2008-03-05        0.0951193
 2008-03-06       -0.0214398
              412 rows omitted

```

## Computing log of data values

```julia
julia> log.(ts)
(431 x 1) TS with Date Index

 Index       value_log
 Date        Float64
───────────────────────
 2007-01-01    2.31499
 2007-01-02    2.33625
 2007-01-03    2.05895
 2007-01-04    2.29012
 2007-01-05    2.52211
 2007-01-06    2.15534
 2007-01-07    2.16034
 2007-01-08    2.27749
 2007-01-09    2.17066
 2007-01-10    2.38035
     ⋮           ⋮
 2008-02-27    2.32978
 2008-02-28    2.36276
 2008-02-29    2.36395
 2008-03-01    2.35146
 2008-03-02    2.06437
 2008-03-03    2.29812
 2008-03-04    2.11151
 2008-03-05    2.20238
 2008-03-06    2.1807
       412 rows omitted

```

## Creating lagged/leading series

`lag()` and `lead()` provide ways to lag or lead a series respectively
by a fixed value, inserting `missing` where required.

```julia
julia> lag(ts, 2)
(431 x 1) TS with Date Index

 Index       value
 Date        Float64?
───────────────────────────
 2007-01-01  missing
 2007-01-02  missing
 2007-01-03       10.1248
 2007-01-04       10.3424
 2007-01-05        7.83777
 2007-01-06        9.87616
 2007-01-07       12.4548
 2007-01-08        8.63084
 2007-01-09        8.67409
 2007-01-10        9.75221
     ⋮             ⋮
 2008-02-27       10.0811
 2008-02-28       12.5888
 2008-02-29       10.2757
 2008-03-01       10.6202
 2008-03-02       10.6328
 2008-03-03       10.5008
 2008-03-04        7.88032
 2008-03-05        9.95546
 2008-03-06        8.26072
           412 rows omitted


julia> lead(ts, 2)
(431 x 1) TS with Date Index

 Index       value
 Date        Float64?
───────────────────────────
 2007-01-01        7.83777
 2007-01-02        9.87616
 2007-01-03       12.4548
 2007-01-04        8.63084
 2007-01-05        8.67409
 2007-01-06        9.75221
 2007-01-07        8.76406
 2007-01-08       10.8087
 2007-01-09        9.74481
 2007-01-10       11.0995
     ⋮             ⋮
 2008-02-27       10.6328
 2008-02-28       10.5008
 2008-02-29        7.88032
 2008-03-01        9.95546
 2008-03-02        8.26072
 2008-03-03        9.04647
 2008-03-04        8.85252
 2008-03-05  missing
 2008-03-06  missing
           412 rows omitted

```

## Converting to Matrix and DataFrame

You can easily convert a TS object into a `Matrix` or fetch the
`DataFrame` for doing operations which are outside of the TSx scope.

```julia
# convert column 1 to a vector of floats
julia> ts[:, 1]
431-element Vector{Float64}:
 10.1248338098958
 10.3424091138411
  7.83777413591419
  9.87615632977506
 12.4548084674329
  8.63083527336206
  8.67408599632254
  9.75221297863206
  8.76405813698277
 10.8086548113129
  9.74480982888519
  ⋮
 10.0811113869023
 12.5888345885963
 10.2756782417694
 10.6202311288555
 10.6328389451372
 10.5008434702989
  7.88032001621439
  9.95545794087256
  8.2607203222573
  9.04647411362002
  8.85251977208324


# convert entire TS into a Matrix
julia> Matrix(ts)
431×1 Matrix{Float64}:
 10.1248338098958
 10.3424091138411
  7.83777413591419
  9.87615632977506
 12.4548084674329
  8.63083527336206
  8.67408599632254
  9.75221297863206
  8.76405813698277
 10.8086548113129
  9.74480982888519
  ⋮
 10.0811113869023
 12.5888345885963
 10.2756782417694
 10.6202311288555
 10.6328389451372
 10.5008434702989
  7.88032001621439
  9.95545794087256
  8.2607203222573
  9.04647411362002
  8.85251977208324


# use the underlying DataFrame for other operations
julia> select(ts.coredata, :Index, :value, DataFrames.nrow)
431×3 DataFrame
 Row │ Index       value     nrow
     │ Date        Float64   Int64
─────┼─────────────────────────────
   1 │ 2007-01-01  10.1248     431
   2 │ 2007-01-02  10.3424     431
   3 │ 2007-01-03   7.83777    431
   4 │ 2007-01-04   9.87616    431
   5 │ 2007-01-05  12.4548     431
   6 │ 2007-01-06   8.63084    431
   7 │ 2007-01-07   8.67409    431
   8 │ 2007-01-08   9.75221    431
   9 │ 2007-01-09   8.76406    431
  10 │ 2007-01-10  10.8087     431
  11 │ 2007-01-11   9.74481    431
  12 │ 2007-01-12  11.0995     431
  13 │ 2007-01-13   9.54143    431
  14 │ 2007-01-14  11.167      431
  ⋮  │     ⋮          ⋮        ⋮
 418 │ 2008-02-22  10.144      431
 419 │ 2008-02-23  11.1019     431
 420 │ 2008-02-24  10.5315     431
 421 │ 2008-02-25  10.0811     431
 422 │ 2008-02-26  12.5888     431
 423 │ 2008-02-27  10.2757     431
 424 │ 2008-02-28  10.6202     431
 425 │ 2008-02-29  10.6328     431
 426 │ 2008-03-01  10.5008     431
 427 │ 2008-03-02   7.88032    431
 428 │ 2008-03-03   9.95546    431
 429 │ 2008-03-04   8.26072    431
 430 │ 2008-03-05   9.04647    431
 431 │ 2008-03-06   8.85252    431
                   403 rows omitted

```
## Writing TS into a CSV file

Writing a TS object into a CSV file can be done easily by using the
underlying `coredata` property. This `DataFrame` can be passed to
the `CSV.write` method for writing into a file.

```julia
julia> ts.coredata |> CSV.write("/tmp/demo_ts.csv");
```

## Broadcasting

Broadcasting can be used on a `TS` object to apply a function to a subset of it's columns.

```jldoctest
julia> using TSx, DataFrames;

julia> ts = TS(DataFrame(Index = [1, 2, 3, 4, 5], A = [10.1, 12.4, 42.4, 24.1, 242.5], B = [2, 4, 6, 8, 10]))
(5 x 2) TS with Int64 Index

 Index  A        B     
 Int64  Float64  Int64 
───────────────────────
     1     10.1      2
     2     12.4      4
     3     42.4      6
     4     24.1      8
     5    242.5     10

julia> sin_A = sin.(ts[:, [:A]])    # get sin of column A
(5 x 1) TS with Int64 Index

 Index  A_sin
 Int64  Float64
──────────────────
     1  -0.625071
     2  -0.165604
     3  -0.999934
     4  -0.858707
     5  -0.562466

julia> log_ts = log.(ts)    # take log of all columns
(5 x 2) TS with Int64 Index

 Index  A_log    B_log
 Int64  Float64  Float64
──────────────────────────
     1  2.31254  0.693147
     2  2.5177   1.38629
     3  3.74715  1.79176
     4  3.18221  2.07944
     5  5.491    2.30259

julia> log_ts = log.(ts[:, [:A, :B]])   # can specify multiple columns
(5 x 2) TS with Int64 Index

 Index  A_log    B_log
 Int64  Float64  Float64
──────────────────────────
     1  2.31254  0.693147
     2  2.5177   1.38629
     3  3.74715  1.79176
     4  3.18221  2.07944
     5  5.491    2.30259

```
