# Tutorial

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

```julia
julia> using CSV, DataFrames

julia> filename = joinpath(dirname(pathof(TSx)),
           "..", "docs", "src", "assets", "sample_daily.csv")

julia> df = CSV.read(filename, DataFrame)
431×2 DataFrame
 Row │ date        value
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  10.1248
   2 │ 2007-01-02  10.3424
   3 │ 2007-01-03   7.83777
   4 │ 2007-01-04   9.87616
   5 │ 2007-01-05  12.4548
   6 │ 2007-01-06   8.63084
   7 │ 2007-01-07   8.67409
   8 │ 2007-01-08   9.75221
   9 │ 2007-01-09   8.76406
  10 │ 2007-01-10  10.8087
  11 │ 2007-01-11   9.74481
  12 │ 2007-01-12  11.0995
  13 │ 2007-01-13   9.54143
  14 │ 2007-01-14  11.167
  15 │ 2007-01-15  10.144
  16 │ 2007-01-16  11.1019
  17 │ 2007-01-17  10.5315
  18 │ 2007-01-18  10.0811
  19 │ 2007-01-19  12.5888
  20 │ 2007-01-20  10.2757
  ⋮  │     ⋮          ⋮
 413 │ 2008-02-17  10.8087
 414 │ 2008-02-18   9.74481
 415 │ 2008-02-19  11.0995
 416 │ 2008-02-20   9.54143
 417 │ 2008-02-21  11.167
 418 │ 2008-02-22  10.144
 419 │ 2008-02-23  11.1019
 420 │ 2008-02-24  10.5315
 421 │ 2008-02-25  10.0811
 422 │ 2008-02-26  12.5888
 423 │ 2008-02-27  10.2757
 424 │ 2008-02-28  10.6202
 425 │ 2008-02-29  10.6328
 426 │ 2008-03-01  10.5008
 427 │ 2008-03-02   7.88032
 428 │ 2008-03-03   9.95546
 429 │ 2008-03-04   8.26072
 430 │ 2008-03-05   9.04647
 431 │ 2008-03-06   8.85252
            392 rows omitted

julia> ts = TS(df)
(431 x 1) TS with Dates.Date Index

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
     ⋮          ⋮
 2008-02-16   8.76406
 2008-02-17  10.8087
 2008-02-18   9.74481
 2008-02-19  11.0995
 2008-02-20   9.54143
 2008-02-21  11.167
 2008-02-22  10.144
 2008-02-23  11.1019
 2008-02-24  10.5315
 2008-02-25  10.0811
 2008-02-26  12.5888
 2008-02-27  10.2757
 2008-02-28  10.6202
 2008-02-29  10.6328
 2008-03-01  10.5008
 2008-03-02   7.88032
 2008-03-03   9.95546
 2008-03-04   8.26072
 2008-03-05   9.04647
 2008-03-06   8.85252
      391 rows omitted
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

Names of data columns can be fetched using the `names(ts)` method
which returns a `Vector{String}` object. The `Index` column can be
fetched as an object of `Vector` type by using the `index(ts)` method,
it can also be fetched directly using the underlying `coredata`
property of TS: `ts.coredata[!, :Index]`.

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


# third, fifth row and first column
julia> ts[[3, 5], 1]
(1 x 1) TS with Date Index

 Index       value
 Date        Float64
─────────────────────
 2007-01-03  7.83777


# first 10 rows and the first column
julia> ts[1:10, 1]
(10 x 1) TS with Dates.Date Index

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


# using the column name
julia> ts[1, :value]
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

## Timeseries data mainpulation

### Applying a function over a period

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

```

### Row and column binding with other objects

TSx provides methods to join two TS objects by columns: `join` (alias:
`cbind`) or by rows: `vcat` (alias: `rbind`). Both the methods provide
some basic intelligence while doing the merge. `join` merges two
datasets based on the `Index` values of both objects. Depending on the
join strategy employed the final object may only contain index values
only from the left object (using `JoinLeft`), the right object (using
`JoinRight`), intersection of both objects (using `JoinBoth`), or a
union of both objects (`JoinAll`) while inserting `missing` values
where index values are missing from any of the other object.

```julia
julia> dates = collect(Date(2007,1,1):Day(1):Date(2007,1,30));
julia> ts2 = TS(rand(length(dates)), dates)
(30 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2007-01-01  0.441924
 2007-01-02  0.140323
 2007-01-03  0.71753
 2007-01-04  0.762919
 2007-01-05  0.210845
 2007-01-06  0.3652
 2007-01-07  0.924636
 2007-01-08  0.864424
 2007-01-09  0.730909
 2007-01-10  0.985619
 2007-01-11  0.556146
 2007-01-12  0.482831
 2007-01-13  0.365106
 2007-01-14  0.732164
 2007-01-15  0.264424
 2007-01-16  0.291362
 2007-01-17  0.983965
 2007-01-18  0.566147
 2007-01-19  0.521702
 2007-01-20  0.711861
 2007-01-21  0.682508
 2007-01-22  0.74898
 2007-01-23  0.705237
 2007-01-24  0.516239
 2007-01-25  0.0973474
 2007-01-26  0.344292
 2007-01-27  0.434619
 2007-01-28  0.622751
 2007-01-29  0.0986784
 2007-01-30  0.15385


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
method also uses certain strategies to check for certain conditions
before doing the merge, throwing an error if the conditions are not
satisfied. `setequal` merges only if both objects have same column
names, `orderequal` merges only if both objects have same column names
and columns are in the same order, `intersect` merges only the columns
which are common to both objects, and `union` which merges even if the
columns differ between the two objects, the resulting object has the
columns filled with `missing`, if necessary.

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


### Rolling apply

### Rolling differences and percent change

### Creating lagged/leading series

## Converting to Matrix and DataFrame

## Writing output

## API reference
