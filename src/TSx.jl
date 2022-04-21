module TSx

using DataFrames, Dates, ShiftedArrays, RollingFunctions, Plots

import Base.convert
import Base.diff
import Base.filter
import Base.getindex
import Base.join
import Base.names
import Base.print
import Base.==
import Base.show
import Base.size
import Base.vcat

import Dates.Period

export TS,
    apply,
    cbind,
    diff,
    getindex,
    index,
    join,
    lag,
    lead,
    names,
    nrow,
    ncol,
    pctchange,
    plot,
    log,
    rbind,
    show,
    size,
    rollapply,
    vcat


####################################
# The TS structure
####################################
"""
    struct TS
      coredata :: DataFrame
    end

`::TS` - A type to hold ordered data with an index.

A TS object is essentially a `DataFrame` with a specific column marked
as an index. The input `DataFrame` is sorted during construction and
is stored under the property `coredata`. The index is stored in the
`Index` column of `coredata`.

Permitted data inputs to the constructors are `DataFrame`, `Vector`,
and 2-dimensional `Array`. If an index is already not present in the
constructor then a sequential integer index is created
automatically.

`TS(coredata::DataFrame)`: Here, the constructor looks for a column
named `Index` in `coredata` as the index column, if this is not found
then the first column of `coredata` is made the index by default. If
`coredata` only has a single column then a new sequential index is
generated.

Since `TS.coredata` is a DataFrame it can be operated upon
independently using methods provided by the DataFrames package
(ex. `transform`, `combine`, etc.).

# Constructors
```julia
TS(coredata::DataFrame, index::Union{String, Symbol, Int})
TS(coredata::DataFrame, index::AbstractVector{T}) where {T<:Union{Int, TimeType}}
TS(coredata::DataFrame)
TS(coredata::DataFrame, index::UnitRange{Int})
TS(coredata::AbstractVector{T}, index::AbstractVector{V}) where {T, V}
TS(coredata::AbstractVector{T}) where {T}
TS(coredata::AbstractArray{T,2}) where {T}
TS(coredata::AbstractArray{T,2}, index::AbstractVector{V}) where {T, V}
```

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x);

julia> df = DataFrame(x1 = random(10))
julia> ts = TS(df)   # generates index
(10 x 1) TS with Int64 Index

 Index  x1        
 Int64  Float64   
──────────────────
     1  0.768448
     2  0.940515
     3  0.673959
     4  0.395453
     5  0.313244
     6  0.662555
     7  0.586022
     8  0.0521332
     9  0.26864
    10  0.108871

# ts.coredata is a DataFrame
julia> combine(ts.coredata, :x1 => Statistics.mean, DataFrames.nrow)
1×2 DataFrame
 Row │ x1_mean  nrow
     │ Float64  Int64
─────┼────────────────
   1 │ 0.49898    418

julia> df = DataFrame(ind = [1, 2, 3], x1 = random(3))
3×2 DataFrame
 Row │ ind    x1       
     │ Int64  Float64  
─────┼─────────────────
   1 │     1  0.768448
   2 │     2  0.940515
   3 │     3  0.673959

julia> ts = TS(df, 1)        # the first column is index
(3 x 1) TS with Int64 Index

 Index  x1       
 Int64  Float64  
─────────────────
     1  0.768448
     2  0.940515
     3  0.673959

julia> df = DataFrame(x1 = random(3), x2 = random(3), Index = [1, 2, 3]);
3×3 DataFrame
 Row │ x1        x2        Index 
     │ Float64   Float64   Int64 
─────┼───────────────────────────
   1 │ 0.768448  0.768448      1
   2 │ 0.940515  0.940515      2
   3 │ 0.673959  0.673959      3

julia> ts = TS(df)   # uses existing `Index` column
(3 x 2) TS with Int64 Index

 Index  x1        x2       
 Int64  Float64   Float64  
───────────────────────────
     1  0.768448  0.768448
     2  0.940515  0.940515
     3  0.673959  0.673959

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
julia> df = DataFrame(dates = dates, x1 = random(10))
julia> ts = TS(df, :dates)
(10 x 1) TS with Date Index

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


julia> ts = TS(DataFrame(x1=random(10)), dates)
(10 x 1) TS with Date Index

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

julia> ts = TS(random(10))
(10 x 1) TS with Int64 Index

 Index  x1        
 Int64  Float64   
──────────────────
     1  0.768448
     2  0.940515
     3  0.673959
     4  0.395453
     5  0.313244
     6  0.662555
     7  0.586022
     8  0.0521332
     9  0.26864
    10  0.108871

julia> ts = TS(random(10), dates)
(10 x 1) TS with Date Index

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

julia> ts = TS([random(10) random(10)], dates) # matrix object
(10 x 2) TS with Date Index

 Index       x1         x2        
 Date        Float64    Float64   
──────────────────────────────────
 2017-01-01  0.768448   0.768448
 2017-01-02  0.940515   0.940515
 2017-01-03  0.673959   0.673959
 2017-01-04  0.395453   0.395453
 2017-01-05  0.313244   0.313244
 2017-01-06  0.662555   0.662555
 2017-01-07  0.586022   0.586022
 2017-01-08  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864
 2017-01-10  0.108871   0.108871

```
"""
struct TS

    coredata :: DataFrame

    # From DataFrame, index number/name/symbol
    function TS(coredata::DataFrame, index::Union{String, Symbol, Int})
        if (DataFrames.ncol(coredata) == 1)
            TS(coredata, collect(Base.OneTo(DataFrames.nrow(coredata))))
        end

        sorted_cd = sort(coredata, index)
        index_vals = sorted_cd[!, index]

        cd = sorted_cd[:, Not(index)]
        insertcols!(cd, 1, :Index => index_vals, after=false, copycols=true)

        new(cd)
    end

    # From DataFrame, external index
    function TS(coredata::DataFrame, index::AbstractVector{T}) where {T<:Union{Int, TimeType}}
        sorted_index = sort(index)

        cd = copy(coredata)
        insertcols!(cd, 1, :Index => sorted_index, after=false, copycols=true)

        new(cd)
    end

end



####################################
# Constructors
####################################

function TS(coredata::DataFrame)
    if "Index" in names(coredata)
        return TS(coredata, :Index)
    elseif DataFrames.ncol(coredata) == 1
        return TS(coredata, collect(1:DataFrames.nrow(coredata)))
    else
        return TS(coredata, 1)
    end
end

# From DataFrame, index range
function TS(coredata::DataFrame, index::UnitRange{Int})
    index_vals = collect(index)
    cd = copy(coredata)
    insertcols!(cd, 1, :Index => index_vals, after=false, copycols=true)
    TS(cd, :Index)
end

# From AbstractVector
function TS(coredata::AbstractVector{T}, index::AbstractVector{V}) where {T, V}
    df = DataFrame([coredata], :auto)
    TS(df, index)
end

function TS(coredata::AbstractVector{T}) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    TS(coredata, index_vals)
end


# From Matrix and meta
# FIXME: use Metadata.jl
function TS(coredata::AbstractArray{T,2}) where {T}
    index_vals = collect(Base.OneTo(size(coredata)[1]))
    df = DataFrame(coredata, :auto, copycols=true)
    TS(df, index_vals)
end

function TS(coredata::AbstractArray{T,2}, index::AbstractVector{V}) where {T, V}
    df = DataFrame(coredata, :auto, copycols=true)
    TS(df, index)
end


####################################
# Displays
####################################

# Show
function Base.show(io::IO, ts::TS)
    println("(", TSx.nrow(ts), " x ", TSx.ncol(ts), ") TS with ", eltype(index(ts)), " Index")
    println("")
    DataFrames.show(ts.coredata, show_row_number=false, summary=false)
end

#######################
# Indexing
#######################
## Date-time type conversions for indexing
function convert(::Type{Date}, str::String)
    Date(Dates.parse_components(str, Dates.dateformat"yyyy-mm-dd")...)
end

function convert(::Type{String}, date::Date)
    Dates.format(date, "yyyy-mm-dd")
end


"""
# Subsetting/Indexing

`TS` can be subset using row and column indices. The row selector
could be an integer, a range, an array or it could also be a `Date`
object or an ISO-formatted date string ("2007-04-10"). There are
methods to subset on year, year-month, and year-quarter.

The latter two subset
`coredata` by matching on the index column.

Column selector could be an integer or any other selector which
`DataFrame` indexing supports. To fetch the index column one can use
the `index()` method on the `TS` object.

# Examples

```jldoctest
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts = TS([random(10) random(10) random(10)]);
10×4 DataFrame
 Row │ Index  x1         x2         x3
     │ Int64  Float64    Float64    Float64
─────┼────────────────────────────────────────
   1 │     1  0.768448   0.768448   0.768448
   2 │     2  0.940515   0.940515   0.940515
   3 │     3  0.673959   0.673959   0.673959
   4 │     4  0.395453   0.395453   0.395453
   5 │     5  0.313244   0.313244   0.313244
   6 │     6  0.662555   0.662555   0.662555
   7 │     7  0.586022   0.586022   0.586022
   8 │     8  0.0521332  0.0521332  0.0521332
   9 │     9  0.26864    0.26864    0.26864
  10 │    10  0.108871   0.108871   0.108871
Index: {Int64} [10]
Size: (10, 3)

julia> ts[1]  # first row
1×4 DataFrame
 Row │ Index  x1        x2        x3
     │ Int64  Float64   Float64   Float64
─────┼─────────────────────────────────────
   1 │     1  0.768448  0.768448  0.768448

Index: {Int64} [1]
Size: (1, 3)

julia> ts[1:5]
5×4 DataFrame
 Row │ Index  x1        x2        x3
     │ Int64  Float64   Float64   Float64
─────┼─────────────────────────────────────
   1 │     1  0.768448  0.768448  0.768448
   2 │     2  0.940515  0.940515  0.940515
   3 │     3  0.673959  0.673959  0.673959
   4 │     4  0.395453  0.395453  0.395453
   5 │     5  0.313244  0.313244  0.313244

Index: {Int64} [5]
Size: (5, 3)

julia> ts[1:5, 2]               # first five rows, second column
5×2 DataFrame
 Row │ Index  x2
     │ Int64  Float64
─────┼─────────────────
   1 │     1  0.768448
   2 │     2  0.940515
   3 │     3  0.673959
   4 │     4  0.395453
   5 │     5  0.313244

Index: {Int64} [5]
Size: (5, 1)

julia> ts[1:5, 2:3]
5×3 DataFrame
 Row │ Index  x2        x3
     │ Int64  Float64   Float64
─────┼───────────────────────────
   1 │     1  0.768448  0.768448
   2 │     2  0.940515  0.940515
   3 │     3  0.673959  0.673959
   4 │     4  0.395453  0.395453
   5 │     5  0.313244  0.313244

Index: {Int64} [5]
Size: (5, 2)

julia> ts[[1, 9]]               # individual rows
2×4 DataFrame
 Row │ Index  x1        x2        x3
     │ Int64  Float64   Float64   Float64
─────┼─────────────────────────────────────
   1 │     1  0.768448  0.768448  0.768448
   2 │     9  0.26864   0.26864   0.26864

Index: {Int64} [2]
Size: (2, 3)

julia> dates = collect(Date(2007):Day(1):Date(2008, 2, 22));

julia> ts = TS(random(length(dates)), dates)
    = First 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2007-01-01  0.768448
   2 │ 2007-01-02  0.940515
   3 │ 2007-01-03  0.673959
   4 │ 2007-01-04  0.395453
   5 │ 2007-01-05  0.313244
   6 │ 2007-01-06  0.662555
   7 │ 2007-01-07  0.586022
   8 │ 2007-01-08  0.0521332
   9 │ 2007-01-09  0.26864
  10 │ 2007-01-10  0.108871
    ...
    ...
    = Last 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2008-02-13  0.230099
   2 │ 2008-02-14  0.84356
   3 │ 2008-02-15  0.197678
   4 │ 2008-02-16  0.807931
   5 │ 2008-02-17  0.429457
   6 │ 2008-02-18  0.170111
   7 │ 2008-02-19  0.787517
   8 │ 2008-02-20  0.618442
   9 │ 2008-02-21  0.823573
  10 │ 2008-02-22  0.556063

Index: {Date} [418]
Size: (418, 1)

julia> ts[Date(2007, 01, 01)]
1×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  0.768448

Index: {Dates.Date} [1]
Size: (1, 1)

julia> ts[Date(2007)]
1×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  0.768448

Index: {Dates.Date} [1]
Size: (1, 1)

julia> ts[Year(2007)]
    = First 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2007-01-01  0.768448
   2 │ 2007-01-02  0.940515
   3 │ 2007-01-03  0.673959
   4 │ 2007-01-04  0.395453
   5 │ 2007-01-05  0.313244
   6 │ 2007-01-06  0.662555
   7 │ 2007-01-07  0.586022
   8 │ 2007-01-08  0.0521332
   9 │ 2007-01-09  0.26864
  10 │ 2007-01-10  0.108871
    ...
    ...
    = Last 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2007-12-22  0.530505
   2 │ 2007-12-23  0.0923232
   3 │ 2007-12-24  0.468421
   4 │ 2007-12-25  0.0246652
   5 │ 2007-12-26  0.171042
   6 │ 2007-12-27  0.227369
   7 │ 2007-12-28  0.695758
   8 │ 2007-12-29  0.417124
   9 │ 2007-12-30  0.603757
  10 │ 2007-12-31  0.346659

Index: {Date} [365]
Size: (365, 1)

julia> ts[Year(2007), Month(11)];
    = First 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-11-01  0.214132
   2 │ 2007-11-02  0.672281
   3 │ 2007-11-03  0.373938
   4 │ 2007-11-04  0.317985
   5 │ 2007-11-05  0.110226
   6 │ 2007-11-06  0.797408
   7 │ 2007-11-07  0.095699
   8 │ 2007-11-08  0.186565
   9 │ 2007-11-09  0.586859
  10 │ 2007-11-10  0.623613
    ...
    ...
    = Last 10 rows =
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2007-11-21  0.702451
   2 │ 2007-11-22  0.746427
   3 │ 2007-11-23  0.301046
   4 │ 2007-11-24  0.619772
   5 │ 2007-11-25  0.425161
   6 │ 2007-11-26  0.410939
   7 │ 2007-11-27  0.0883656
   8 │ 2007-11-28  0.135477
   9 │ 2007-11-29  0.693611
  10 │ 2007-11-30  0.557009

Index: {Date} [30]
Size: (30, 1)

julia> ts[Year(2007), Quarter(2)];

julia> ts["2007-01-01"]
1×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  0.768448

Index: {Dates.Date} [1]
Size: (1, 1)

julia> ts[1, :x1]
1×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  0.768448

Index: {Dates.Date} [1]
Size: (1, 1)

julia> ts[1, "x1"]
1×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼──────────────────────
   1 │ 2007-01-01  0.768448

Index: {Dates.Date} [1]
Size: (1, 1)
```
"""
function Base.getindex(ts::TS, i::Int)
    TS(ts.coredata[[i], :])
end

# By row-range
function Base.getindex(ts::TS, r::UnitRange)
    TS(ts.coredata[collect(r), :])
end

# By row-array
function Base.getindex(ts::TS, a::AbstractVector{Int64})
    TS(ts.coredata[a, :])
end

# By date
function Base.getindex(ts::TS, d::Date)
    sdf = filter(x -> x.Index == d, ts.coredata)
    TS(sdf)
end

# By period
function Base.getindex(ts::TS, y::Year)
    sdf = filter(:Index => x -> Dates.Year(x) == y, ts.coredata)
    TS(sdf)
end

function Base.getindex(ts::TS, y::Year, q::Quarter)
    sdf = filter(:Index => x -> (Year(x), Quarter(x)) == (y, q), ts.coredata)
    TS(sdf)
end

# XXX: ideally, Dates.YearMonth class should exist
function Base.getindex(ts::TS, y::Year, m::Month)
    sdf = filter(:Index => x -> (Year(x), Month(x)) == (y, m), ts.coredata)
    TS(sdf)
end

# By string timestamp
function Base.getindex(ts::TS, i::String)
    ind = findall(x -> x == TSx.convert(eltype(ts.coredata[!, :Index]), i), ts.coredata[!, :Index]) # XXX: may return duplicate indices
    TS(ts.coredata[ind, :])     # XXX: check if data is being copied
end

# By row-column
function Base.getindex(ts::TS, i::Int, j::Int)
    TS(ts.coredata[[i], Cols(:Index, j+1)])
end

# By row-range, column
function Base.getindex(ts::TS, i::UnitRange, j::Int)
    return TS(ts.coredata[i, Cols(:Index, j+1)])
end

function Base.getindex(ts::TS, i::Int, j::UnitRange)
    return TS(ts.coredata[[i], Cols(:Index, 1 .+(j))])
end

function Base.getindex(ts::TS, i::UnitRange, j::UnitRange)
    return TS(ts.coredata[i, Cols(:Index, 1 .+(j))])
end

function Base.getindex(ts::TS, i::Int, j::Symbol)
    return TS(ts.coredata[[i], Cols(:Index, j)])
end

function Base.getindex(ts::TS, i::Int, j::String)
    return TS(ts.coredata[[i], Cols("Index", j)])
end

# By {TimeType, Period} range
function Base.getindex(ts::TS, r::StepRange{T, V}) where {T<:TimeType, V<:Period}
end

########################
# Parameters
########################

# Number of rows
"""
# Size methods
`nrow(ts::TS)`
Return the number of rows of `ts`.

# Examples
```jldoctest
julia> ts = TS(collect(1:10))
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


julia> TSx.nrow(ts)
10
```
"""
function nrow(ts::TS)
    DataFrames.size(ts.coredata)[1]
end

# Number of columns
"""
# Size methods

`ncol(ts::TS)`

Return the number of columns of `ts`.

# Examples
```jldoctest
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> TSx.ncol(TS([random(100) random(100) random(100)]))
3
```
"""
function ncol(ts::TS)
    DataFrames.size(ts.coredata)[2] - 1
end

# Size of
"""
# Size methods
`size(ts::TS)`
Return the number of rows and columns of `ts` as a tuple.

# Examples
```jldoctest
julia> TSx.size(TS([collect(1:100) collect(1:100) collect(1:100)]))
(100, 3)
```
"""
function size(ts::TS)
    nr = TSx.nrow(ts)
    nc = TSx.ncol(ts)
    (nr, nc)
end

# Return index column
"""
# Index column
Return the index vector from the `coredata` DataFrame.

# Examples

```jldoctest
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts = TS(random(10), Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(9));

julia> show(ts)
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2022-02-01  0.768448
   2 │ 2022-03-01  0.940515
   3 │ 2022-04-01  0.673959
   4 │ 2022-05-01  0.395453
   5 │ 2022-06-01  0.313244
   6 │ 2022-07-01  0.662555
   7 │ 2022-08-01  0.586022
   8 │ 2022-09-01  0.0521332
   9 │ 2022-10-01  0.26864
  10 │ 2022-11-01  0.108871

Index: {Dates.Date} [10]
Size: (10, 1)

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
function index(ts::TS)
    ts.coredata[!, :Index]
end

"""
# Column names
`names(ts::TS)`

Return a `Vector{String}` containing column names of the TS object,
excludes index.

# Examples
```jldoctest
julia> names(TS([1:10 11:20]))
2-element Vector{String}:
 "x1"
 "x2"
```
"""
function names(ts::TS)
    names(ts.coredata[!, Not(:Index)])
end

# convert to period
"""
# Apply/Period conversion
`apply(ts::TS, period::Union{T,Type{T}},
      fun::V,
      index_at::Function=first)
    where {T<:Union{DatePeriod,TimePeriod}, V<:Function}`

Apply `fun` to `ts` object based on `period` and return correctly
indexed rows. This method is used for doing aggregation over a time
period or to convert `ts` into an object of lower frequency (ex. from
daily series to monthly).

`period` is any of `Period` types in the `Dates` module. Conversion
from lower to a higher frequency will throw an error as interpolation
isn't currently handled by this method.

By default, the method uses the first value of the index within the
period to index the resulting aggregated object. This behaviour can be
controlled by `index_at` argument which can take `first` or `last` as
an input.

# Examples
```jldoctest
julia> using Random, Statistics;
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));
julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));
julia> show(apply(ts, Month, first))
(15 x 1) TS with Date Index

 Index       x1_first  
 Date        Float64   
───────────────────────
 2017-01-01  0.768448
 2017-02-01  0.790201
 2017-03-01  0.467219
 2017-04-01  0.783473
 2017-05-01  0.651354
 2017-06-01  0.373346
 2017-07-01  0.83296
 2017-08-01  0.132716
 2017-09-01  0.27899
 2017-10-01  0.995414
 2017-11-01  0.214132
 2017-12-01  0.832917
 2018-01-01  0.0409471
 2018-02-01  0.720163
 2018-03-01  0.87459


julia> show(apply(ts, Month(2), first)) # alternate months
(8 x 1) TS with Date Index

 Index       x1_first  
 Date        Float64   
───────────────────────
 2017-01-01  0.768448
 2017-03-01  0.467219
 2017-05-01  0.651354
 2017-07-01  0.83296
 2017-09-01  0.27899
 2017-11-01  0.214132
 2018-01-01  0.0409471
 2018-03-01  0.87459


julia> ts_monthly = apply(ts, Week, Statistics.std) # weekly standard deviation;

julia> ts_monthly = apply(ts, Week, Statistics.std, last) # indexed by last date of the week;

```
"""
function apply(ts::TS, period::Union{T,Type{T}}, fun::V, index_at::Function=first) where {T<:Union{DatePeriod,TimePeriod}, V<:Function}
    sdf = transform(ts.coredata, :Index => i -> Dates.floor.(i, period))
    gd = groupby(sdf, :Index_function)

    ## Columns to exclude from operation.
    # Note: Not() does not support more
    # than one Symbol so we have to find Int indexes.
    ##
    n = findfirst(r -> r == "Index", names(gd))
    r = findfirst(r -> r == "Index_function", names(gd))

    df = combine(gd,
                 :Index => index_at => :Index,
                 names(gd)[Not(n, r)] .=> fun,
                 keepkeys=false)
    TS(df, :Index)
end

"""
# Lagging
`lag(ts::TS, lag_value::Int = 1)`

Lag the `ts` object by the specified `lag_value`. The rows corresponding
to lagged values will be rendered as `missing`. Negative values of lag are
also accepted (see `TSx.lead`).

# Examples
```jldoctest
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

julia> lag(ts);

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

julia> lag(ts, 2) # Lags by 2 values;

```
"""
function lag(ts::TS, lag_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lag.(eachcol(ts.coredata[!, Not(:Index)]), lag_value), TSx.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TS(sdf, :Index)
end

"""
# Leading
`lead(ts::TS, lead_value::Int = 1)`

Similar to lag, this method leads the `ts` object by `lead_value`. The
lead rows are inserted with `missing`. Negative values of lead are
also accepted (see `TSx.lag`).

# Examples
```jldoctest
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

julia> lead(ts) # Leads once;

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

julia> lead(ts, 2)# Leads by 2 values;

```
"""
function lead(ts::TS, lead_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lead.(eachcol(ts.coredata[!, Not(:Index)]), lead_value), TSx.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TS(sdf, :Index)
end

"""
# Differencing
`diff(ts::TS, periods::Int = 1)`

Return the discrete difference of successive row elements.
Default is the element in the next row. `periods` defines the number
of rows to be shifted over. The skipped rows are rendered as `missing`.

`diff` returns an error if column type does not have the method `-`.

# Examples
```jldoctest
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10));

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

# Difference over successive rows
julia> diff(ts)# Difference over the third row;
julia> diff(ts, 3)
```
"""

# Diff
function diff(ts::TS, periods::Int = 1)
    if periods <= 0
        error("periods must be a postive int")
    end
    ddf = ts.coredata[:, Not(:Index)] .- TSx.lag(ts, periods).coredata[:, Not(:Index)]
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TS(ddf, :Index)
end

"""
# Percent Change
`pctchange(ts::TS, periods::Int = 1)`

Return the percentage change between successive row elements.
Default is the element in the next row. `periods` defines the number
of rows to be shifted over. The skipped rows are rendered as `missing`.

`pctchange` returns an error if column type does not have the method `/`.

# Examples
```jldoctest
julia> using Random, Statistics;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts = TS(DataFrame(Index = dates, x1 = random(length(dates))));

# Pctchange over successive rows
julia> pctchange(ts)
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64?
─────┼────────────────────────────
   1 │ 2017-01-01  missing
   2 │ 2017-01-02        0.223915
   3 │ 2017-01-03       -0.283415
   4 │ 2017-01-04       -0.413238
   5 │ 2017-01-05       -0.207886
   6 │ 2017-01-06        1.11514
   7 │ 2017-01-07       -0.115511
   8 │ 2017-01-08       -0.911039
   9 │ 2017-01-09        4.15295
  10 │ 2017-01-10       -0.594733
Index: {Dates.Date} [10]
Size: (10, 1)

# Pctchange over the third row
julia> pctchange(ts, 3)
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64?
─────┼─────────────────────────────
   1 │ 2017-01-01  missing
   2 │ 2017-01-02  missing
   3 │ 2017-01-03  missing
   4 │ 2017-01-04       -0.485387
   5 │ 2017-01-05       -0.666944
   6 │ 2017-01-06       -0.0169207
   7 │ 2017-01-07        0.4819
   8 │ 2017-01-08       -0.83357
   9 │ 2017-01-09       -0.59454
  10 │ 2017-01-10       -0.814221
Index: {Dates.Date} [10]
Size: (10, 1)
```
"""

# Pctchange
function pctchange(ts::TS, periods::Int = 1)
    if periods <= 0
        error("periods must be a positive int")
    end
    ddf = (ts.coredata[:, Not(:Index)] ./ TSx.lag(ts, periods).coredata[:, Not(:Index)]) .- 1
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TS(ddf, :Index)
end


"""
# Log Function

`log(ts::TS, complex::Bool = false)`

This method computes the log value of the non-index columns in the TS
object.

If the `complex` argument is `true` the function returns the log of
negative numbers as complex numbers.  But this also coerces the log of
positive values as complex numbers with the imaginary component equal
to 0.
"""
function log(ts::TS, complex::Bool = false)
    ts_new = ts
    if complex == true
        for col in names(ts_new.coredata)
            if eltype(ts_new.coredata[!,col]) <: Union{Missing, Number}
                ts_new.coredata[!,col] = Base.log.(Complex.((ts_new.coredata[!,col])))
            end
        end
    else
        for col in names(ts_new.coredata)
            if eltype(ts_new.coredata[!,col]) <: Union{Missing, Number}
                ts_new.coredata[!,col] = Base.log.((ts_new.coredata[!,col]))
            end
        end
    end
    return TSx.TS(ts_new.coredata)
end

######################
# Rolling Function
######################

"""
# Rolling Functions

`rollapply(fun::Function, ts::TS, column::Any, windowsize::Int)`

Apply a function to a column of `ts` for each continuous set of rows
of size `windowsize`. `column` could be any of the `DataFrame` column
selectors.

The output is a TS object with `(nrow(ts) - windowsize + 1)` rows
indexed with the last index value of each window.

This method uses `RollingFunctions` package to implement this
functionality.

# Examples

```jldoctest; setup = :(using Statistics)
julia> ts = TS(1:12, Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(11))
(12 x 1) TS with Date Index

 Index       x1    
 Date        Int64 
───────────────────
 2022-02-01      1
 2022-03-01      2
 2022-04-01      3
 2022-05-01      4
 2022-06-01      5
 2022-07-01      6
 2022-08-01      7
 2022-09-01      8
 2022-10-01      9
 2022-11-01     10
 2022-12-01     11
 2023-01-01     12


julia> rollapply(sum, ts, :x1, 10)
(8 x 1) TS with Date Index

 Index       x1_rolling_sum 
 Date        Float64        
────────────────────────────
 2022-06-01            15.0
 2022-07-01            20.0
 2022-08-01            25.0
 2022-09-01            30.0
 2022-10-01            35.0
 2022-11-01            40.0
 2022-12-01            45.0
 2023-01-01            50.0


julia> rollapply(Statistics.mean, ts, 1, 5)
(8 x 1) TS with Date Index

 Index       x1_rolling_mean 
 Date        Float64         
─────────────────────────────
 2022-06-01              3.0
 2022-07-01              4.0
 2022-08-01              5.0
 2022-09-01              6.0
 2022-10-01              7.0
 2022-11-01              8.0
 2022-12-01              9.0
 2023-01-01             10.0

```
"""
function rollapply(fun::Function, ts::TS, column::Any, windowsize::Int)
    if windowsize < 1
        error("windowsize must be greater than or equal to 1")
    end
    col = Int(1)
    if typeof(column) <: Int
        col = copy(column)
        col = col+1             # index is always 1
    else
        col = column
    end
    res = RollingFunctions.rolling(fun, ts.coredata[!, col], windowsize)
    idx = TSx.index(ts)[windowsize:end]
    colname = names(ts.coredata[!, [col]])[1]
    res_df = DataFrame([idx, res], ["Index", "$(colname)_rolling_$(fun)"])
    return TS(res_df)
end

######################
# Plot
######################

"""
# Plottting
`plot(ts::TS, colnames::Vector{String} = TSx.names(ts))`

Plots a timeseries plot of the TS object, with the X axis as the index.
`colnames` lets you select which column you wish to plot.

This method uses the Plots package to implement this funcitonality.

# Example
```jldoctest
julia> df = DataFrame(Ind = Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(11), val1 = abs.(rand(Int16, 12)), val2 = abs.(rand(Int16, 12)));

julia> TS(df);

julia> # plot(ts);

```
"""
function plot(ts::TS, colnames::Vector{String} = TSx.names(ts))
    Plots.plot(ts.coredata[!, :Index], Matrix(ts.coredata[!, colnames]))
end

######################
# Joins
######################
struct JoinBoth    # inner
end
struct JoinAll    # inner
end
struct JoinLeft     # left
end
struct JoinRight    # right
end

"""
# Joins/Column-binding

`TS` objects can be combined together column-wise using `Index` as the
column key. There are four kinds of column-binding operations possible
as of now. Each join operation works by performing a Set operation on
the `Index` column and then merging the datasets based on the output
from the Set operation. Each operation changes column names in the
final object automatically if the operation encounters duplicate
column names amongst the TS objects.

The following join types are supported:

`join(ts1::TS, ts2::TS, ::JoinBoth)`

a.k.a. inner join, takes the intersection of the indexes of `ts1` and
`ts2`, and then merges the columns of both the objects. The resulting
object will only contain rows which are present in both the objects'
indexes. The function will renamine the columns in the final object if
they had same names in the TS objects.

`join(ts1::TS, ts2::TS, ::JoinAll)`:

a.k.a. outer join, takes the union of the indexes of `ts1` and `ts2`
before merging the other columns of input objects. The output will
contain rows which are present in all the input objects while
inserting `missing` values where a row was not present in any of the
objects. This is the default behaviour if no `JoinType` object is
provided.

`join(ts1::TS, ts2::TS, ::JoinLeft)`:

Left join takes the index values which are present in the left
object `ts1` and finds matching index values in the right object
`ts2`. The resulting object includes all the rows from the left
object, the column values from the left object, and the values
associated with matching index rows on the right. The operation
inserts `missing` values where in the unmatched rows of the right
object.

`join(ts1::TS, ts2::TS, ::JoinRight)`

Right join, similar to left join but works in the opposite
direction. The final object contains all the rows from the right
object while inserting `missing` values in rows missing from the left
object.

The default behaviour is to assume `JoinAll()` if no `JoinType` object
is provided to the `join` method.

`cbind` is an alias for `join` method.

# Examples
```jldoctest
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts1 = TS(random(10), 1:10);

julia> ts2 = TS(random(10), 1:10);

julia> join(ts1, ts2, TSx.JoinAll())
10×3 DataFrame
 Row │ Index  x1         x1_1
     │ Int64  Float64?   Float64?
─────┼─────────────────────────────
   1 │     1  0.768448   0.768448
   2 │     2  0.940515   0.940515
   3 │     3  0.673959   0.673959
   4 │     4  0.395453   0.395453
   5 │     5  0.313244   0.313244
   6 │     6  0.662555   0.662555
   7 │     7  0.586022   0.586022
   8 │     8  0.0521332  0.0521332
   9 │     9  0.26864    0.26864
  10 │    10  0.108871   0.108871

Index: {Int64} [10]
Size: (10, 2)

julia> join(ts1, ts2);             # same as JoinAll()

julia> join(ts1, ts2, TSx.JoinBoth());

julia> join(ts1, ts2, TSx.JoinLeft());

julia> join(ts1, ts2, TSx.JoinRight());

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
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

julia> ts1 = TS(random(length(dates)), dates);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,30));

julia> ts2 = TS(random(length(dates)), dates);

julia> join(ts1, ts2);
```
"""
function Base.join(ts1::TS, ts2::TS)
    join(ts1, ts2, JoinAll())
end

function Base.join(ts1::TS, ts2::TS, ::JoinBoth)
    result = DataFrames.innerjoin(ts1.coredata, ts2.coredata, on = :Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::JoinAll)
    result = DataFrames.outerjoin(ts1.coredata, ts2.coredata, on = :Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::JoinLeft)
    result = DataFrames.leftjoin(ts1.coredata, ts2.coredata, on = :Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::JoinRight)
    result = DataFrames.rightjoin(ts1.coredata, ts2.coredata, on = :Index, makeunique=true)
    return TS(result)
end
# alias
cbind = join

"""
vcat(ts::TS...; cols::Symbol=:setequal, source::Symbol=nothing)

vcat concatenates two or more arrays along dimension 1. This method implements the `Base.vcat` method.

The `cols` keyword argument determines the columns of the data frame
`:setequal`: require all data frames to have the same column names disregarding order.
If they appear in different orders, the order of the first provided data frame is used.
`:orderequal`: require all data frames to have the same column names and in the same order.
`:intersect`: only the columns present in all provided data frames are kept. If the intersection is empty, an empty data frame is returned.
`:union`: columns present in at least one of the provided data frames are kept.
 Columns not present in some data frames are filled with missing where necessary.

The `source` keyword argument, if not nothing (the default), specifies the additional column
to be added in the last position in the resulting data frame that will identify the source data frame.

# Example

```jldoctest
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates1 = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
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

julia> TS(random(length(dates1)), dates1)
10×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2017-01-01  0.768448
   2 │ 2017-01-02  0.940515
   3 │ 2017-01-03  0.673959
   4 │ 2017-01-04  0.395453
   5 │ 2017-01-05  0.313244
   6 │ 2017-01-06  0.662555
   7 │ 2017-01-07  0.586022
   8 │ 2017-01-08  0.0521332
   9 │ 2017-01-09  0.26864
  10 │ 2017-01-10  0.108871

Index: {Dates.Date} [10]
Size: (10, 1)

julia> dates2 = collect(Date(2017,1,11):Day(1):Date(2017,1,30));

julia> TS(random(length(dates2)), dates2)
20×2 DataFrame
 Row │ Index       x1
     │ Date        Float64
─────┼───────────────────────
   1 │ 2017-01-11  0.768448
   2 │ 2017-01-12  0.940515
   3 │ 2017-01-13  0.673959
   4 │ 2017-01-14  0.395453
   5 │ 2017-01-15  0.313244
   6 │ 2017-01-16  0.662555
   7 │ 2017-01-17  0.586022
   8 │ 2017-01-18  0.0521332
   9 │ 2017-01-19  0.26864
  10 │ 2017-01-20  0.108871
  11 │ 2017-01-21  0.163666
  12 │ 2017-01-22  0.473017
  13 │ 2017-01-23  0.865412
  14 │ 2017-01-24  0.617492
  15 │ 2017-01-25  0.285698
  16 │ 2017-01-26  0.463847
  17 │ 2017-01-27  0.275819
  18 │ 2017-01-28  0.446568
  19 │ 2017-01-29  0.582318
  20 │ 2017-01-30  0.255981

Index: {Dates.Date} [20]
Size: (20, 1)

julia> ts1 = TS(randn(length(dates1)), dates1);

julia> ts2 = TS(randn(length(dates2)), dates2);

julia> # vcat(ts1, ts2);


```
"""
function Base.vcat(ts::TS...; cols::Symbol=:setequal, source::Symbol=nothing)
    result_df = DataFrames.vcat(ts1.coredata...; cols, source)
    return TS(result_df)
end
# alias
rbind = vcat

end                             # END module TSx
