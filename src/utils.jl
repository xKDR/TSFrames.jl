"""
# Summary statistics

```julia
describe(ts::TSFrame; cols=:)
describe(ts::TSFrame, stats::Union{Symbol, Pair}...; cols=:)
```

Compute summary statistics of `ts`. The output is a `DataFrame`
containing standard statistics along with number of missing values and
data types of columns. The `cols` keyword controls which subset of columns
from `ts` to be selected. The `stats` keyword is used to control which
summary statistics are to be printed. For more information about these
keywords, check out the corresponding [documentation from DataFrames.jl](https://dataframes.juliadata.org/stable/lib/functions/#DataAPI.describe).

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x...);
julia> ts = TSFrame(random(([1, 2, 3, 4, missing], 10)))
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
function describe(io::IO, ts::TSFrame; cols=:)
    DataFrames.describe(ts.coredata; cols=cols)
end
TSFrames.describe(ts::TSFrame; cols=:) = TSFrames.describe(stdout, ts; cols=cols)

function describe(
    io::IO,
    ts::TSFrame,
    stats::Union{Symbol, Pair{<:Base.Callable, <:Union{Symbol, AbstractString}}}...;
    cols=:
)
    DataFrames.describe(ts.coredata, stats...; cols=cols)
end
TSFrames.describe(
    ts::TSFrame,
    stats::Union{Symbol, Pair{<:Base.Callable, <:Union{Symbol, AbstractString}}}...;
    cols=:
) = TSFrames.describe(stdout, ts, stats...; cols=cols)

function Base.show(io::IO, ts::TSFrame)
    title = "$(TSFrames.nrow(ts))×$(TSFrames.ncol(ts)) TSFrame with $(eltype(index(ts))) Index"
    Base.show(io, ts.coredata; show_row_number=false, title=title)
    return nothing
end
Base.show(ts::TSFrame) = show(stdout, ts)


function Base.summary(io::IO, ts::TSFrame)
    println("(", nr(ts), " x ", nc(ts), ") TSFrame")
end

"""
# Size methods

```julia
nrow(ts::TSFrame)
nr(ts::TSFrame)
```

Return the number of rows of `ts`. `nr` is an alias for `nrow`.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> ts = TSFrame(collect(1:10))
julia> TSFrames.nrow(ts)
10
```
"""
function nrow(ts::TSFrame)
    DataFrames.size(ts.coredata)[1]
end
# alias
nr = TSFrames.nrow

function Base.lastindex(ts::TSFrame)
    lastindex(index(ts))
end

function Base.length(ts::TSFrame)
    TSFrames.nrow(ts)
end

# Number of columns
"""
# Size methods

```julia
ncol(ts::TSFrame)
```

Return the number of columns of `ts`. `nc` is an alias for `ncol`.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> TSFrames.ncol(TSFrame([random(100) random(100) random(100)]))
3

julia> nc(TSFrame([random(100) random(100) random(100)]))
3
```
"""
function ncol(ts::TSFrame)
    DataFrames.size(ts.coredata)[2] - 1
end
# alias
nc = TSFrames.ncol

# Size of
"""
# Size methods
```julia
size(ts::TSFrame)
```

Return the number of rows and columns of `ts` as a tuple.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> TSFrames.size(TSFrame([collect(1:100) collect(1:100) collect(1:100)]))
(100, 3)
```
"""
function size(ts::TSFrame)
    nr = TSFrames.nrow(ts)
    nc = TSFrames.ncol(ts)
    (nr, nc)
end

# Return index column
"""
# Index column

```julia
index(ts::TSFrame)
```

Return the index vector from the `coredata` DataFrame.

# Examples

```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts = TSFrame(random(10), Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(9));


julia> show(ts)
(10 x 1) TSFrame with Dates.Date Index

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
function index(ts::TSFrame)
    ts.coredata[!, :Index]
end

"""
# Column names
```julia
names(ts::TSFrame)
```

Return a `Vector{String}` containing column names of the TSFrame object,
excludes index.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> names(TSFrame([1:10 11:20]))
2-element Vector{String}:
 "x1"
 "x2"
```
"""

function names(ts::TSFrame)
    names(ts.coredata[!, Not(:Index)])
end


"""
# First Row
```julia
first(ts::TSFrame)
```

Returns the first row of `ts` as a TSFrame object.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random)
julia> first(TSFrame(1:10))
(10 x 1) TSFrame with Dates.Date Index

 Index       x1
 Date        Float64
───────────────────────
 2022-02-01  0.768448

```
"""
function Base.first(ts::TSFrame)
    TSFrame(Base.first(ts.coredata,1))
end


"""
# Head
```julia
head(ts::TSFrame, n::Int = 10)
```
Returns the first `n` rows of `ts`.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random)
julia> head(TSFrame(1:100))
(10 x 1) TSFrame with Int64 Index

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
function head(ts::TSFrame, n::Int = 10)
    TSFrame(Base.first(ts.coredata, n))
end


"""
# Tail
```julia
tail(ts::TSFrame, n::Int = 10)
```

Returns the last `n` rows of `ts`.

```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random)
julia> tail(TSFrame(1:100))
(10 x 1) TSFrame with Int64 Index

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
function tail(ts::TSFrame, n::Int = 10)
    TSFrame(DataFrames.last(ts.coredata, n))
end


"""
# Column Rename
```julia
rename!(ts::TSFrame, colnames::AbstractVector{String})
rename!(ts::TSFrame, colnames::AbstractVector{Symbol})
```

Renames columns of `ts` to the values in `colnames`, in order. Input
is a vector of either Strings or Symbols. The `Index` column name is reserved,
and `rename!()` will throw an error if `colnames` contains the name `Index`.

```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random)
julia> ts
(100 x 2) TSFrame with Int64 Index

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
(100 x 2) TSFrame with Int64 Index

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

function rename!(ts::TSFrame, colnames::AbstractVector{String})
    rename!(ts, Symbol.(colnames))
end

function rename!(ts::TSFrame, colnames::AbstractVector{Symbol})
    idx = findall(i -> i == :Index, colnames)
    if length(idx) > 0
        error("Column name `Index` not allowed in TSFrame object")
    end
    cols = copy(colnames)
    insert!(cols, 1, :Index)
    DataFrames.rename!(ts.coredata, cols)
    return ts
end

"""
Internal function to check consistency of the Index of a TSFrame
object.
"""
function _check_consistency(ts::TSFrame)::Bool
    issorted(index(ts))
end

"""

```julia
isregular(timestamps::V, unit::T) where {V<:AbstractVector{TimeType}, T<:Dates.Period}
isregular(timestamps::T) where {T<:AbstractVector{TimeType}}
isregular(timestamps::AbstractVector{V}, unit::Symbol = :firstdiff) where {V<:TimeType}
isregular(ts::TSFrame, unit::Symbol = :firstdiff)
isregular(ts::TSFrame, unit::T) where {T<:Dates.Period}
```

# Examples
```jldoctest; setup = :(using TSFrame, Dates, Random)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x);

julia> dates=collect(Date(2017,1,1):Day(1):Date(2017,1,10))
10-element Vector{Date}:
 2017-01-01
 2017-01-02
 2017-01-03
 2017-01-04
 2017-01-05
 2017-01-06
 2017-01-07
 2017-01-08
 2017-01-09
 2017-01-10

julia> isregular(dates) # check if regular
true

julia> isregular(dates, Day(1)) # check if regular with a time difference of 1 day
true

julia> isregular(dates, Day(2)) # check if regular with a time difference of 2 days
false

julia> ts = TSFrame(random(10), dates)
10×1 TSFrame with Date Index
 Index       x1        
 Date        Float64   
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871

julia> isregular(ts)
true

julia> isregular(ts, Day(1))
true

julia> isregular(ts, Day(2))
false

```
"""
function isregular(timestamps::AbstractVector{V}, unit::Symbol = :firstdiff) where {V<:TimeType}
    s = size(timestamps, 1)

    if s == 1
        return false
    end

    if unit==:firstdiff
        time = timestamps[2]-timestamps[1]
    else
        unit = Symbol(uppercasefirst(String(unit))) # make first letter of symbol uppercase
        unitfunc = getfield(Dates,unit)
        time = gettimeperiod(timestamps[1], timestamps[2], unitfunc)
    end

    isregular(timestamps, time)
end

function isregular(timestamps::AbstractVector{V}, unit::T) where {V<:TimeType, T<:Dates.Period}
    s = size(timestamps, 1)

    if s == 1
        return false
    end
    if unit.value == 0
        return false
    end

    #todo add check for boundary case
    return (timestamps[1]:unit:timestamps[s])==timestamps
end

#find number of units between start and end date
function gettimeperiod(startdate, enddate, unit)
    try
        return unit(length(startdate:unit(1):enddate)-1)
    catch e
        #TODO find better way to write this
        if isa(e, MethodError)
            return 0
        else
            println(e)
        end
    end

end

function isregular(ts::TSFrame, unit::Symbol = :firstdiff)
    return isregular(ts.Index, unit)
end

function isregular(ts::TSFrame, unit::T) where {T<:Dates.Period}
    return isregular(ts.Index, unit)
end
