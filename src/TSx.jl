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
    log,
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

Permitted data inputs to constructor are DataFrame, Vector, and
2-dimensional Array. If an index is already not present in the
constructor then it is generated.

# Constructors
```julia
TS(coredata::DataFrame, index::Union{String, Symbol, Int}=1)
TS(coredata::DataFrame, index::AbstractVector{T}) where {T<:Int}
TS(coredata::DataFrame, index::UnitRange{Int})
TS(coredata::AbstractVector{T}, index::AbstractVector{V}) where {T, V}
TS(coredata::AbstractVector{T}) where {T}
TS(coredata::AbstractArray{T,2}) where {T}
```

# Examples
```jldoctest
julia> df = DataFrame(x1 = randn(10))
julia> TS(df)                   # generates index

julia> df = DataFrame(ind = [1, 2, 3], x1 = randn(3))
julia> TS(df, 1)                # first column is index

julia> df = DataFrame(x1 = randn(3), x2 = randn(3), Index = [1, 2, 3])
julia> TS(df)                   # looks up `Index` column

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
julia> df = DataFrame(dates = dates, x1 = randn(10))
julia> TS(df, :dates)
julia> TS(DataFrame(x1=randn(10), dates))

julia> TS(randn(10))
julia> TS(randn(10), dates)

# matrix object
julia> TS([randn(10) randn(10)], dates)
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
        return TS(coredata, collect(1:nrow(coredata)))
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
"""
# Size methods
`nrow(ts::TS)`
Return the number of rows of `ts`.

# Examples
```jldoctest
julia> ts = TS(randn(100))
julia> nrow(ts)
```
"""
function nrow(ts::TS)
    size(ts.coredata)[1]
end

# Number of columns
"""
# Size methods
`ncol(ts::TS)`
Return the number of columns of `ts`.

# Examples
```jldoctest
julia> ts = TS([randn(100) randn(100) randn(100)])
julia> ncol(ts)
```
"""
function ncol(ts::TS)
    size(ts.coredata)[2] - 1
end

# Size of
"""
# Size methods
`size(ts::TS)`
Return the number of rows and columns of `ts` as a tuple.

# Examples
```jldoctest
julia> ts = TS([randn(100) randn(100) randn(100)])
julia> size(ts)
```
"""
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

# Return column names
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
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10))
julia> ts = TS(DataFrame(Index = dates, x1 = randn(length(dates))))

# Lags once
julia> lag(ts)
# Lags by 2 values
julia> lag(ts, 2)
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
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10))
julia> ts = TS(DataFrame(Index = dates, x1 = randn(length(dates))))

# Leads once
julia> lead(ts)
# Leads by 2 values
julia> lead(ts, 2)
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
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10))
julia> ts = TS(DataFrame(Index = dates, x1 = randn(length(dates))))

# Difference over successive rows
julia> diff(ts)
# Difference over the third row
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
julia> dates = collect(Date(2017,1,1):Day(1):Date(2018,3,10))
julia> ts = TS(DataFrame(Index = dates, x1 = randn(length(dates))))

# Pctchange over successive rows
julia> pctchange(ts)
# Pctchange over the third row
julia> pctchange(ts, 3)
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

```jdoctest
julia> ts = TS(1:12, today():Month(1):today()+Month(11))
julia> rollpply(sum, ts, :x1, 10)
julia> rollapply(Statistics.mean, ts, :x1, 5)
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
    end
    res = RollingFunctions.rolling(fun, ts.coredata[!, col], windowsize)
    idx = TSx.index(ts)[windowsize:end]
    colname = names(ts.coredata[!, [column]])
    res_df = DataFrame([idx, res], ["Index", "$(colname)_roll_$(fun)"])
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
```jdoctest
julia> df = DataFrame(Ind = today():Month(1):today()+Month(11), val1 = abs.(rand(Int16, 12)), val2 = abs.(rand(Int16, 12)))
julia> ts = TS(df)
julia> plot(ts)
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
