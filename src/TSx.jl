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
    convert,
    cbind,
    diff,
    getindex,
    index,
    join,
    lag,
    names,
    nrow,
    ncol,
    pctchange,
    log_values,
    print,
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
as an index and has the name `Index`. The DataFrame is sorted using
index values during construction.

# Constructors
```julia
TS(coredata::DataFrame, index::Union{String, Symbol, Int}=1)
TS(coredata::DataFrame, index::AbstractVector{T}) where {T<:Int}
TS(coredata::DataFrame, index::UnitRange{Int})
TS(coredata::AbstractVector{T}, index::AbstractVector{V}) where {T, V}
TS(coredata::AbstractVector{T}) where {T}
TS(coredata::AbstractArray{T,2}, meta::Dict=Dict{String, Any}()) where {T}
```

# Examples
```jldoctest
julia> df = DataFrame(x1 = randn(10))
julia> TS(df)

julia> df = DataFrame(Index = [1, 2, 3], x1 = randn(3))
julia> TS(df, 1)

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
julia> df = DataFrame(dates = dates, x1 = randn(10))
julia> TS(df, :dates)
julia> TS(DataFrame(x1=randn(10), dates))

julia> TS(randn(10))
julia> TS(randn(10), dates)
```
"""
struct TS

    coredata :: DataFrame

    function isRegular(vals)
        d = Base.diff(vals)
        if all([i == d[1] for i in d])
            result = true
        else
            result = false
        end
        result
    end

    # From DataFrame, index number/name/symbol
    function TS(coredata::DataFrame, index::Union{String, Symbol, Int}=1)
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
function TS(coredata::AbstractArray{T,2}, meta::Dict=Dict{String, Any}()) where {T}
    index_vals = collect(Base.OneTo(size(coredata)[1]))
    df = DataFrame(coredata, :auto, copycols=true)
    TS(df, index_vals)
end



####################################
# Displays
####################################

# Show
function Base.show(io::IO, ts::TS)
    if (nrow(ts) > 20)
        println("    = First 10 rows =")
        println(first(ts.coredata, 10))
        println("    ...")
        println("    ...")
        println("    = Last 10 rows =")
        println(last(ts.coredata, 10))
        println("")
    else
        println(ts.coredata)
    end
    println("Index: {", eltype(index(ts)), "} [", length(index(ts)), "]")
    println("Size: ", size(ts))
end

# Print
function Base.print(io::IO, ts::TS)
    println(ts.coredata)
    println("")
    println("Index: {", eltype(index(ts)), "} [", length(index(ts)), "]")
    print("Size: ", size(ts))
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
julia> ts = TS([randn(10) randn(10) randn(10)])
julia> ts[1]
julia> ts[1:5]
julia> ts[1:5, 2]
julia> ts[1:5, 2:3]
julia> ts[[1, 9]]               # individual rows

julia> dates = collect(Date(2007):Day(1):Date(2008, 2, 22))
julia> ts = TS(randn(length(dates)), dates)
julia> ts[Date(2007, 01, 01)]
julia> ts[Date(2007)]
julia> ts[Year(2007)]
julia> ts[Year(2007), Month(11)]
julia> ts[Year(2007), Quarter(2)]
julia> ts["2007-01-01"]

julia> ts[1, :x1]
julia> ts[1, "x1"]
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
function nrow(ts::TS)
    size(ts.coredata)[1]
end

# Number of columns
function ncol(ts::TS)
    size(ts.coredata)[2] - 1
end

# Size of
function size(ts::TS)
    nr = nrow(ts)
    nc = ncol(ts)
    (nr, nc)
end

# Return index column
"""
# Index column
Return the index vector from the TS DataFrame.

# Examples

```jldoctest
julia> ts = TS(randn(10), today():Month(1):today()+Month(9))
julia> index(ts)
julia> typeof(index(ts))
```
"""
function index(ts::TS)
    ts.coredata[!, :Index]
end

# Return row names
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
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10))
julia> ts = TS(DataFrame(Index = dates, x1 = randn(length(dates))))

# take the first observation in each month
julia> ts_monthly = apply(tsd, Month, first)
# alternate months
julia> ts_two_monthly = apply(tsd, Month(2), first)

# weekly standard deviation
julia> ts_monthly = apply(tsd, Week, Statistics.std)
# indexed by last date of the week
julia> ts_monthly = apply(tsd, Week, Statistics.std, last)
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
                 names(gd)[Not(n, r)] => fun,
                 keepkeys=false)
    TS(df, :Index)
end

# Lag
function lag(ts::TS, lag_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lag.(eachcol(ts.coredata[!, Not(:Index)]), lag_value), TSx.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TS(sdf, :Index)
end

# Diff
function diff(ts::TS, periods::Int = 1) # differences::Int = 1
    if periods <= 0
        error("periods must be a postive int")
    end
    ddf = ts.coredata[:, Not(:Index)] .- TSx.lag(ts, periods).coredata[:, Not(:Index)]
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TS(ddf, :Index)
end

# Pctchange
function pctchange(ts::TS, periods::Int = 1)
    if periods <= 0
        error("periods must be a positive int")
    end
    ddf = (ts.coredata[:, Not(:Index)] ./ TSx.lag(ts, periods).coredata[:, Not(:Index)]) .- 1
    insertcols!(ddf, 1, "Index" => ts.coredata[:, :Index])
    TS(ddf, :Index)
end

# Log Function
function log_values(ts::TS, complex::Bool = false)
    if complex == true
        for col in names(ts.coredata)
            if eltype(ts.coredata[!,col]) <: Union{Missing, Number}
                ts.coredata[!,col] = log.(Complex.((ts.coredata[!,col])))
            end
        end
    else
        for col in names(ts.coredata)
            if eltype(ts.coredata[!,col]) <: Union{Missing, Number}
                ts.coredata[!,col] = log.((ts.coredata[!,col]))
            end
        end
    end      
    return TSx.TS(ts.coredata)
end

######################
# Rolling Function
######################

function rollapply(fun::Function, ts::TS, column::Any, windowsize:: Int)
    if windowsize < 1
        error("windowsize must be positive")
    end
    res = RollingFunctions.rolling(fun, ts.coredata[!, column], windowsize)
    idx = TSx.index(ts)[windowsize:end]
    res_df = DataFrame(Index = idx,roll_fun = res)
    return TS(res_df)
end

######################
# Plot
######################


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

Left join, takes the index values which are present in the left
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
julia> ts1 = TS(randn(10), 1:10)
julia> ts2 = TS(randn(10), 1:10)

julia> join(ts1, ts2, JoinAll()) # with `missing` inserted
julia> join(ts1, ts2)            # same as JoinAll()
julia> join(ts1, ts2, JoinBoth())
julia> join(ts1, ts2, JoinLeft())
julia> join(ts1, ts2, JoinRight())

# Using TimeType objects
julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
julia> ts1 = TS(randn(length(dates)), dates)
julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,30))
julia> ts2 = TS(randn(length(dates)), dates)

julia> join(ts1, ts2)
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

function Base.vcat(ts::TS...; cols::Symbol=:setequal, source::Symbol=nothing)
    result_df = DataFrames.vcat(ts1.coredata...; cols, source)
    return TS(result_df)
end
# alias
rbind = vcat

end                             # END module TSx
