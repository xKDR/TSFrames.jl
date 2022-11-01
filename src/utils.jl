"""
# Summary statistics

```julia
describe(ts::TimeFrame; cols=:)
describe(ts::TimeFrame, stats::Union{Symbol, Pair}...; cols=:)
```

Compute summary statistics of `ts`. The output is a `DataFrame`
containing standard statistics along with number of missing values and
data types of columns. The `cols` keyword controls which subset of columns
from `ts` to be selected. The `stats` keyword is used to control which
summary statistics are to be printed. For more information about these
keywords, check out the corresponding [documentation from DataFrames.jl](https://dataframes.juliadata.org/stable/lib/functions/#DataAPI.describe).

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x...);
julia> ts = TimeFrame(random(([1, 2, 3, 4, missing], 10)))
julia> describe(ts)
2×7 DataFrame
 Row │ variable  mean     min    median   max    nmissing  eltype
     │ Symbol    Float64  Int64  Float64  Int64  Int64     Type
─────┼───────────────────────────────────────────────────────────────────────────
   1 │ Index        5.5       1      5.5     10         0  Int64
   2 │ x1           2.75      2      3.0      4         2  Union{Missing, Int64}
julia> describe(ts, cols=:Index)
1×7 DataFrame
 Row │ variable  mean     min    median   max    nmissing  eltype
     │ Symbol    Float64  Int64  Float64  Int64  Int64     DataType
─────┼──────────────────────────────────────────────────────────────
   1 │ Index         5.5      1      5.5     10         0  Int64
julia> describe(ts, :min, :max, cols=:x1)
1×3 DataFrame
 Row │ variable  min    max
     │ Symbol    Int64  Int64
─────┼────────────────────────
   1 │ x1            2      4
julia> describe(ts, :min, sum => :sum)
2×3 DataFrame
 Row │ variable  min    sum
     │ Symbol    Int64  Int64
─────┼────────────────────────
   1 │ Index         1     55
   2 │ x1            2     22
julia> describe(ts, :min, sum => :sum, cols=:x1)
1×3 DataFrame
 Row │ variable  min    sum
     │ Symbol    Int64  Int64
─────┼────────────────────────
   1 │ x1            2     22

```
"""
function describe(io::IO, ts::TimeFrame; cols=:)
    DataFrames.describe(ts.coredata; cols=cols)
end
TSx.describe(ts::TimeFrame; cols=:) = TSx.describe(stdout, ts; cols=cols)

function describe(
    io::IO,
    ts::TimeFrame,
    stats::Union{Symbol, Pair{<:Base.Callable, <:Union{Symbol, AbstractString}}}...;
    cols=:
)
    DataFrames.describe(ts.coredata, stats...; cols=cols)
end
TSx.describe(
    ts::TimeFrame,
    stats::Union{Symbol, Pair{<:Base.Callable, <:Union{Symbol, AbstractString}}}...;
    cols=:
) = TSx.describe(stdout, ts, stats...; cols=cols)

function Base.show(io::IO, ts::TimeFrame)
    title = "$(TSx.nrow(ts))×$(TSx.ncol(ts)) TimeFrame with $(eltype(index(ts))) Index"
    Base.show(io, ts.coredata; show_row_number=false, title=title)
    return nothing
end
Base.show(ts::TimeFrame) = show(stdout, ts)


function Base.summary(io::IO, ts::TimeFrame)
    println("(", nr(ts), " x ", nc(ts), ") TimeFrame")
end

"""
# Size methods

```julia
nrow(ts::TimeFrame)
nr(ts::TimeFrame)
```

Return the number of rows of `ts`. `nr` is an alias for `nrow`.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> ts = TimeFrame(collect(1:10))
julia> TSx.nrow(ts)
10
```
"""
function nrow(ts::TimeFrame)
    DataFrames.size(ts.coredata)[1]
end
# alias
nr = TSx.nrow

function Base.lastindex(ts::TimeFrame)
    lastindex(index(ts))
end

function Base.length(ts::TimeFrame)
    TSx.nrow(ts)
end

# Number of columns
"""
# Size methods

```julia
ncol(ts::TimeFrame)
```

Return the number of columns of `ts`. `nc` is an alias for `ncol`.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> TSx.ncol(TimeFrame([random(100) random(100) random(100)]))
3

julia> nc(TimeFrame([random(100) random(100) random(100)]))
3
```
"""
function ncol(ts::TimeFrame)
    DataFrames.size(ts.coredata)[2] - 1
end
# alias
nc = TSx.ncol

# Size of
"""
# Size methods
```julia
size(ts::TimeFrame)
```

Return the number of rows and columns of `ts` as a tuple.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> TSx.size(TimeFrame([collect(1:100) collect(1:100) collect(1:100)]))
(100, 3)
```
"""
function size(ts::TimeFrame)
    nr = TSx.nrow(ts)
    nc = TSx.ncol(ts)
    (nr, nc)
end

# Return index column
"""
# Index column

```julia
index(ts::TimeFrame)
```

Return the index vector from the `coredata` DataFrame.

# Examples

```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts = TimeFrame(random(10), Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(9));


julia> show(ts)
(10 x 1) TimeFrame with Dates.Date Index

 Index       x1
 Date        Float64
───────────────────────
 2022-02-01  0.768448
 2022-03-01  0.940515
 2022-04-01  0.673959
 2022-05-01  0.395453
 2022-06-01  0.313244
 2022-07-01  0.662555
 2022-08-01  0.586022
 2022-09-01  0.0521332
 2022-10-01  0.26864
 2022-11-01  0.108871

julia> index(ts)
10-element Vector{Date}:
 2022-02-01
 2022-03-01
 2022-04-01
 2022-05-01
 2022-06-01
 2022-07-01
 2022-08-01
 2022-09-01
 2022-10-01
 2022-11-01

julia>  eltype(index(ts))
Date
```
"""
function index(ts::TimeFrame)
    ts.coredata[!, :Index]
end

"""
# Column names
```julia
names(ts::TimeFrame)
```

Return a `Vector{String}` containing column names of the TimeFrame object,
excludes index.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> names(TimeFrame([1:10 11:20]))
2-element Vector{String}:
 "x1"
 "x2"
```
"""

function names(ts::TimeFrame)
    names(ts.coredata[!, Not(:Index)])
end


"""
# First Row
```julia
first(ts::TimeFrame)
```

Returns the first row of `ts` as a TimeFrame object.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random)
julia> first(TimeFrame(1:10))
(10 x 1) TimeFrame with Dates.Date Index

 Index       x1
 Date        Float64
───────────────────────
 2022-02-01  0.768448

```
"""
function Base.first(ts::TimeFrame)
    TimeFrame(Base.first(ts.coredata,1))
end


"""
# Head
```julia
head(ts::TimeFrame, n::Int = 10)
```
Returns the first `n` rows of `ts`.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random)
julia> head(TimeFrame(1:100))
(10 x 1) TimeFrame with Int64 Index

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
```
"""
function head(ts::TimeFrame, n::Int = 10)
    TimeFrame(Base.first(ts.coredata, n))
end


"""
# Tail
```julia
tail(ts::TimeFrame, n::Int = 10)
```

Returns the last `n` rows of `ts`.

```jldoctest; setup = :(using TSx, DataFrames, Dates, Random)
julia> tail(TimeFrame(1:100))
(10 x 1) TimeFrame with Int64 Index

 Index  x1
 Int64  Int64
──────────────
    91     91
    92     92
    93     93
    94     94
    95     95
    96     96
    97     97
    98     98
    99     99
   100    100
```
"""
function tail(ts::TimeFrame, n::Int = 10)
    TimeFrame(DataFrames.last(ts.coredata, n))
end


"""
# Column Rename
```julia
rename!(ts::TimeFrame, colnames::AbstractVector{String})
rename!(ts::TimeFrame, colnames::AbstractVector{Symbol})
```

Renames columns of `ts` to the values in `colnames`, in order. Input
is a vector of either Strings or Symbols. The `Index` column name is reserved,
and `rename!()` will throw an error if `colnames` contains the name `Index`.

```jldoctest; setup = :(using TSx, DataFrames, Dates, Random)
julia> ts
(100 x 2) TimeFrame with Int64 Index

 Index  x1     x2
 Int64  Int64  Int64
─────────────────────
     1      2      1
     2      3      2
     3      4      3
     4      5      4
   ⋮      ⋮      ⋮
    97     98     97
    98     99     98
    99    100     99
   100    101    100
      92 rows omitted

julia> rename!(ts, ["Col1", "Col2"])
(100 x 2) TimeFrame with Int64 Index

Index  Col1   Col2
Int64  Int64  Int64
─────────────────────
    1      2      1
    2      3      2
    3      4      3
    4      5      4
  ⋮      ⋮      ⋮
   97     98     97
   98     99     98
   99    100     99
  100    101    100
     92 rows omitted
```
"""

function rename!(ts::TimeFrame, colnames::AbstractVector{String})
    rename!(ts, Symbol.(colnames))
end

function rename!(ts::TimeFrame, colnames::AbstractVector{Symbol})
    idx = findall(i -> i == :Index, colnames)
    if length(idx) > 0
        error("Column name `Index` not allowed in TimeFrame object")
    end
    cols = copy(colnames)
    insert!(cols, 1, :Index)
    DataFrames.rename!(ts.coredata, cols)
    return ts
end

"""
Internal function to check consistency of the Index of a TimeFrame
object.
"""
function _check_consistency(ts::TimeFrame)::Bool
    issorted(index(ts))
end
