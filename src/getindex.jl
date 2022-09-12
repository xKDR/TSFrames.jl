## Date-time type conversions for indexing
function _convert(::Type{Date}, str::String)
    Date(Dates.parse_components(str, Dates.dateformat"yyyy-mm-dd")...)
end

function _convert(::Type{String}, date::Date)
    Dates.format(date, "yyyy-mm-dd")
end

"""
# Indexing

`TS` can be indexed using row and column indices. The row selector
could be an integer, a range, an array or it could also be a `Date`
object or an ISO-formatted date string ("2007-04-10"). There are
methods to subset on year, year-month, and year-quarter. The latter
two subset `coredata` by matching on the index column.

Column selector could be an integer or any other selector which
`DataFrame` indexing supports. You can use a Symbols to fetch specific
columns (ex: `ts[[:x1, :x2]]`). For fetching column values
as `Vector`, use `Colon` with column name: `ts[:, :x1]`. For Matrix
output, use the constructor: `Matrix(ts)`.

For fetching the index column vector use the `index()` method.

# Examples

```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> ts = TS([random(10) random(10) random(10)])
julia> show(ts)

# first row
julia> ts[1]
(1 x 3) TS with Int64 Index

 Index  x1        x2        x3
 Int64  Float64   Float64   Float64
─────────────────────────────────────
     1  0.768448  0.768448  0.768448

# first five rows
julia> ts[1:5]
(5 x 3) TS with Int64 Index

 Index  x1        x2        x3
 Int64  Float64   Float64   Float64
─────────────────────────────────────
     1  0.768448  0.768448  0.768448
     2  0.940515  0.940515  0.940515
     3  0.673959  0.673959  0.673959
     4  0.395453  0.395453  0.395453
     5  0.313244  0.313244  0.313244

# first five rows, x2 column; returns a vector
julia> ts[1:5, :x2]
5-element Vector{Float64}:
 0.7684476751965699
 0.940515000715187
 0.6739586945680673
 0.3954531123351086
 0.3132439558075186

julia> ts[1:5, 2:3]
(5 x 2) TS with Int64 Index

 Index  x2        x3
 Int64  Float64   Float64
───────────────────────────
     1  0.768448  0.768448
     2  0.940515  0.940515
     3  0.673959  0.673959
     4  0.395453  0.395453
     5  0.313244  0.313244

# individual rows
julia> ts[[1, 9]]
(2 x 3) TS with Int64 Index

 Index  x1        x2        x3
 Int64  Float64   Float64   Float64
─────────────────────────────────────
     1  0.768448  0.768448  0.768448
     9  0.26864   0.26864   0.26864

julia> ts[:, :x1]            # returns a Vector
10-element Vector{Float64}:
 0.7684476751965699
 0.940515000715187
 0.6739586945680673
 0.3954531123351086
 0.3132439558075186
 0.6625548164736534
 0.5860221243068029
 0.05213316316865657
 0.26863956854495097
 0.10887074134844155


julia> ts[:, [:x1, :x2]]
(10 x 2) TS with Int64 Index

 Index  x1         x2
 Int64  Float64    Float64
─────────────────────────────
     1  0.768448   0.768448
     2  0.940515   0.940515
     3  0.673959   0.673959
     4  0.395453   0.395453
     5  0.313244   0.313244
     6  0.662555   0.662555
     7  0.586022   0.586022
     8  0.0521332  0.0521332
     9  0.26864    0.26864
    10  0.108871   0.108871


julia> dates = collect(Date(2007):Day(1):Date(2008, 2, 22));
julia> ts = TS(random(length(dates)), dates)
julia> show(ts[1:10])
(10 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2007-01-01  0.768448
 2007-01-02  0.940515
 2007-01-03  0.673959
 2007-01-04  0.395453
 2007-01-05  0.313244
 2007-01-06  0.662555
 2007-01-07  0.586022
 2007-01-08  0.0521332
 2007-01-09  0.26864
 2007-01-10  0.108871

julia> ts[Date(2007, 01, 01)]
(1 x 1) TS with Dates.Date Index

 Index       x1
 Date        Float64
──────────────────────
 2007-01-01  0.768448


julia> ts[[Date(2007, 1, 1), Date(2007, 1, 2)]]
(2 x 1) TS with Date Index

 Index       x1       
 Date        Float64  
──────────────────────
 2007-01-01  0.768448
 2007-01-02  0.940515


julia> ts[[Date(2007, 1, 1), Date(2007, 1, 2)], :x1]
2-element Vector{Float64}:
 0.7684476751965699
 0.940515000715187


julia> ts[Date(2007)]
(1 x 1) TS with Dates.Date Index

 Index       x1
 Date        Float64
──────────────────────
 2007-01-01  0.768448


julia> ts[Year(2007)]
(365 x 1) TS with Dates.Date Index

 Index       x1
 Date        Float64
───────────────────────
 2007-01-01  0.768448
 2007-01-02  0.940515
 2007-01-03  0.673959
 2007-01-04  0.395453
 2007-01-05  0.313244
 2007-01-06  0.662555
 2007-01-07  0.586022
 2007-01-08  0.0521332
     ⋮           ⋮
 2007-12-24  0.468421
 2007-12-25  0.0246652
 2007-12-26  0.171042
 2007-12-27  0.227369
 2007-12-28  0.695758
 2007-12-29  0.417124
 2007-12-30  0.603757
 2007-12-31  0.346659
       349 rows omitted


julia> ts[Year(2007), Month(11)]
(30 x 1) TS with Date Index

 Index       x1
 Date        Float64
───────────────────────
 2007-11-01  0.214132
 2007-11-02  0.672281
 2007-11-03  0.373938
 2007-11-04  0.317985
 2007-11-05  0.110226
 2007-11-06  0.797408
 2007-11-07  0.095699
 2007-11-08  0.186565
 2007-11-09  0.586859
 2007-11-10  0.623613
 2007-11-11  0.62035
 2007-11-12  0.830895
 2007-11-13  0.72423
 2007-11-14  0.493046
 2007-11-15  0.767975
 2007-11-16  0.462157
 2007-11-17  0.779754
 2007-11-18  0.398596
 2007-11-19  0.941196
 2007-11-20  0.578657
 2007-11-21  0.702451
 2007-11-22  0.746427
 2007-11-23  0.301046
 2007-11-24  0.619772
 2007-11-25  0.425161
 2007-11-26  0.410939
 2007-11-27  0.0883656
 2007-11-28  0.135477
 2007-11-29  0.693611
 2007-11-30  0.557009


julia> ts[Year(2007), Quarter(2)];


julia> ts["2007-01-01"]
(1 x 1) TS with Date Index

 Index       x1
 Date        Float64
──────────────────────
 2007-01-01  0.768448


julia> ts[1, :x1]  # returns a scalar
0.7684476751965699


julia> ts[1, "x1"]; # same as above

```
"""
###
## Row-Column interfaces
###

### Inputs: row scalar, column scalar; Output: scalar
function Base.getindex(ts::TS, i::Int, j::Int)
    ts.coredata[i, j+1]
end

function Base.getindex(ts::TS, i::Int, j::Union{Symbol, String})
    return ts.coredata[i, j]
end

function Base.getindex(ts::TS, dt::T, j::Int) where {T<:TimeType}
    idx = findfirst(x -> x == dt, index(ts))
    ts.coredata[idx, j+1]
end

function Base.getindex(ts::TS, dt::T, j::Union{String, Symbol}) where {T<:TimeType}
    idx = findfirst(x -> x == dt, index(ts))
    ts.coredata[idx, j]
end
###

### Inputs: row scalar, column vector; Output: TS
function Base.getindex(ts::TS, i::Int, j::AbstractVector{Int})
    TS(ts.coredata[[i], Cols(:Index, j.+1)]) # increment: account for Index
end

function Base.getindex(ts::TS, i::Int, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
    TS(ts.coredata[[i], Cols(:Index, j)])
end

function Base.getindex(ts::TS, dt::T, j::AbstractVector{Int}) where {T<:TimeType}
    idx = findfirst(x -> x == dt, index(ts))
    ts[idx, j]
end

function Base.getindex(ts::TS, dt::D, j::AbstractVector{T}) where {D<:TimeType, T<:Union{String, Symbol}}
    idx = findfirst(x -> x == dt, index(ts))
    ts[idx, j]
end
###

### Inputs: row scalar, column range; Output: TS
function Base.getindex(ts::TS, i::Int, j::UnitRange)
    return TS(ts.coredata[[i], Cols(:Index, 1 .+(j))])
end
###

### Inputs: row vector, column scalar; Output: vector
function Base.getindex(ts::TS, i::AbstractVector{Int}, j::Int)
    ts.coredata[i, j+1] # increment: account for Index
end

function Base.getindex(ts::TS, i::AbstractVector{Int}, j::Union{String, Symbol})
    ts.coredata[i, j]
end

function Base.getindex(ts::TS, dt::AbstractVector{T}, j::Int) where {T<:TimeType}
    idx = map(d -> findfirst(x -> x == d, index(ts)), dt)
    if length(idx) == 0
        return nothing
    end
    ts[idx, j]
end

function Base.getindex(ts::TS, dt::AbstractVector{T}, j::Union{String, Symbol}) where {T<:TimeType}
    idx = map(d -> findfirst(x -> x == d, index(ts)), dt)
    if length(idx) == 0
        return nothing
    end
    ts[idx, j]
end
###

### Inputs: row vector, column vector; Output: TS
function Base.getindex(ts::TS, i::AbstractVector{Int}, j::AbstractVector{Int})
    TS(ts.coredata[i, Cols(:Index, j.+1)]) # increment: account for Index
end

function Base.getindex(ts::TS, i::AbstractVector{Int}, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
    TS(ts.coredata[i, Cols(:Index, j)])
end

function Base.getindex(ts::TS, dt::AbstractVector{T}, j::AbstractVector{Int}) where {T<:TimeType}
    idx = map(d -> findfirst(x -> x == d, index(ts)), dt)
    if length(idx) == 0
        return nothing
    end
    ts[idx, j]
end

function Base.getindex(ts::TS, dt::AbstractVector{D}, j::AbstractVector{T}) where {D<:TimeType, T<:Union{String, Symbol}}
    idx = map(d -> findfirst(x -> x == d, index(ts)), dt)
    ts[idx, j]
end
###

### Inputs: row vector, column range; Output: TS
function Base.getindex(ts::TS, i::AbstractVector{Int}, j::UnitRange)
    ts[i, collect(j)]
end

function Base.getindex(ts::TS, dt::AbstractVector{T}, j::UnitRange) where {T<:TimeType}
    ts[dt, collect(j)]
end
###


### Inputs: row range, column scalar: return a vector
function Base.getindex(ts::TS, i::UnitRange, j::Int)
    ts[collect(i), j]
end

function Base.getindex(ts::TS, i::UnitRange, j::Union{String, Symbol})
    ts[collect(i), j]
end
###

### Inputs: row range, column vector: return TS
function Base.getindex(ts::TS, i::UnitRange, j::AbstractVector{Int})
    ts[collect(i), j]
end

function Base.getindex(ts::TS, i::UnitRange, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
    ts[collect(i), j]
end
###

### Inputs: row range, column range: return TS
function Base.getindex(ts::TS, i::UnitRange, j::UnitRange)
    ts[collect(i), collect(j)]
end


###
## Row indexing interfaces
###

function Base.getindex(ts::TS, i::Int)
    ts[i, 1:TSx.ncol(ts)]
end

function Base.getindex(ts::TS, i::UnitRange)
    ts[i, 1:TSx.ncol(ts)]
end

function Base.getindex(ts::TS, i::AbstractVector{Int64})
    ts[i, 1:TSx.ncol(ts)]
end

function Base.getindex(ts::TS, dt::AbstractVector{T}) where {T<:TimeType}
    ts[dt, 1:TSx.ncol(ts)]
end

function Base.getindex(ts::TS, d::T) where {T<:TimeType}
    ts[[d], 1:TSx.ncol(ts)]
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
    sdf = filter(:Index => x -> yearmonth(x) == (y.value, m.value), ts.coredata)
    TS(sdf)
end

function Base.getindex(ts::TS, y::Year, m::Month, d::Day)
    sdf = filter(:Index => x -> (Year(x), Month(x), Day(x)) == (y, m, d), ts.coredata)
    TS(sdf)
end

function Base.getindex(ts::TS, y::Year, m::Month, w::Week)
    sdf = filter(:Index => x -> (Year(x), Month(x), Week(x)) == (y, m, w), ts.coredata)
    TS(sdf)
end

# By string timestamp
function Base.getindex(ts::TS, i::String)
    ind = findall(x -> x == TSx._convert(eltype(ts.coredata[!, :Index]), i), ts.coredata[!, :Index]) # XXX: may return duplicate indices
    TS(ts.coredata[ind, :])     # XXX: check if data is being copied
end

# By {TimeType, Period} range
# function Base.getindex(ts::TS, r::StepRange{T, V}) where {T<:TimeType, V<:Period}
# end

###
## Column indexing with Colon
###

### Inputs: row colon, column scalar: return vector
function Base.getindex(ts::TS, ::Colon, j::Int)
    ts[1:TSx.nrow(ts), j]
end

function Base.getindex(ts::TS, ::Colon, j::Union{String, Symbol})
    ts[1:TSx.nrow(ts), j]
end
###

### Inputs: row colon, column vector: return TS
function Base.getindex(ts::TS, ::Colon, j::AbstractVector{Int})
    ts[1:TSx.nrow(ts), j]
end

function Base.getindex(ts::TS, ::Colon, j::AbstractVector{T}) where {T<:Union{String, Symbol}}
    ts[1:TSx.nrow(ts), j]
end
###

### Inputs: row colon, column range: return TS
function Base.getindex(ts::TS, i::Colon, j::UnitRange)
    ts[1:TSx.nrow(ts), collect(j)]
end
###
