module TSx

using DataFrames, Dates, ShiftedArrays, RollingFunctions, Plots

import Base.convert
import Base.diff
import Base.filter
import Base.getindex
import Base.names
import Base.print
import Base.==
import Base.show
import Base.size

import Dates.Period

export TS,
    apply,
    convert,
    diff,
    getindex,
    lag,
    names,
    nrow,
    ncol,
    pctchange,
    print,
    show,
    size,
    toperiod,
    rollapply,
    leftjoin,
    rightjoin,
    innerjoin,
    outerjoin,
    vcat


####################################
# The TS structure
####################################
"""
    TS

A type to hold ordered data with an index.

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
        sorted_cd = sort(coredata, index)
        index_vals = sorted_cd[!, index]

        cd = sorted_cd[:, Not(index)]
        insertcols!(cd, 1, :Index => index_vals, after=false, copycols=true)

        new(cd)
    end

    # From DataFrame, external index
    function TS(coredata::DataFrame, index::AbstractVector{T}) where {T<:Int}
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
# FIXME:
# julia> TS(rand(10), index_vals)
# ERROR: MethodError: no method matching TS(::Vector{Float64}, ::Vector{Int64})
function TS(coredata::AbstractVector{T}) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    df = DataFrame()
    df.:Auto = coredata
    insertcols!(df, 1, :Index => index_vals, after=false, copycols=true)
    TS(df, :Index)
end


# From Matrix and meta
function TS(coredata::AbstractArray{T,2}, meta::Dict=Dict{String, Any}()) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    df = DataFrame(coredata, :auto, copycols=true)
    TS(df, index_vals)
end



####################################
# Displays
####################################

# Show
function Base.show(io::IO, ts::TS)
    println(first(ts.coredata, 10))
    println("Size: ", size(ts))
end

# Print
function Base.print(io::IO, ts::TS)
    println(ts.coredata)
    print("Size: ", size(ts))
end



#######################
# Indexing
#######################
"""
# Subsetting/Indexing

`TS` can be subset using row and column indices. The row selector
could be an integer, a range, an array or it could also be a `Date`
object or an ISO-formatted date string. The latter two subset
`coredata` by matching on the index column.

Column selector could be an integer or any other selector which
`DataFrame` indexing supports. To fetch the index column one can use
the `index()` method on the `TS` object.
"""
## Date-time type conversions for indexing
function convert(::Type{Date}, str::String)
    Date(Dates.parse_components(str, Dates.dateformat"yyyy-mm-dd")...)
end

function convert(::Type{String}, date::Date)
    Dates.format(date, "yyyy-mm-dd")
end


# By row
function Base.getindex(ts::TS, i::Int)
    TS(ts.coredata[[i], :])
end

# By row-range
function Base.getindex(ts::TS, r::UnitRange)
    TS(ts.coredata[collect(r), :])
end

# By row-array
function Base.getindex(ts::TS, a::AbstractArray{Int64, 1})
    TS(ts.coredata[a, :])
end

function Base.getindex(ts::TS, a::Date)
    sdf = filter(x -> x.Index == d, ts.coredata)
    TS(sdf)
end

function Base.getindex(ts::TS, y::Year)
    sdf = filter(x -> Dates.Year.(x.Index) == y, ts.coredata)
    TS(sdf)
end

# XXX: ideally, Dates.YearMonth class should exist
function Base.getindex(ts::TS, y::Year, m::Month)
    sdf = filter(x -> Dates.yearmonth.(x.Index) == (y, m), ts.coredata)
    TS(sdf)
end

# By timestamp
function Base.getindex(ts::TS, i::Any)
    ind = findall(x -> x == TSx.convert(eltype(ts.coredata[!, :Index]), i), ts.coredata[!, :Index]) # XXX: may return duplicate indices
    TS(ts.coredata[ind, :])     # XXX: check if data is being copied
end

# By row-column
function Base.getindex(ts::TS, i::Int, j::Int)
    if j == 1
        error("j cannot be index column")
    end
    TS(ts.coredata[[i], Cols(:Index, j)])
end

# By row-range, column
function Base.getindex(ts::TS, i::UnitRange, j::Int)
    if j == 1
        error("j cannot be index column")
    end
    return TS(ts.coredata[i, Cols(:Index,j)])
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
function index(ts::TS)
    ts.coredata[!, :Index]
end

# Return row names
function names(ts::TS)
    names(ts.coredata[!, Not(:Index)])
end

# convert to period
function toperiod(ts::TS, period, fun)
    sdf = transform(df, :Index => i -> period.(i))
    gd = groupby(sdf, :Index_function)
    df = select(gd, :Index => fun,
                names(df[!, Not(:Index)]),
                keepkeys=false, renamecols=false, sort=true)
    TS(df, :Index)
end

# Apply
function apply(ts::TS, period, fun, cols) # fun=mean,median,maximum,minimum; cols=[:a, :b]
    idxConverted = Dates.value.(trunc.(ts.coredata[!, :Index], period))
    cd = copy(ts.coredata)
    insertcols!(cd, size(cd)[2], :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    res = combine(gd, cols .=> fun) # TODO: add the (period-based) index
    res[!, Not(:idxConverted)]
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

# Log Returns
function computelogreturns(ts::TS)
    combine(ts.coredata,
            :Index => (x -> x[2:length(x)]) => :Index,
            Not(:Index) => (x -> diff(log.(x))) => :logreturns)
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


function tsplot(ts::TS, colnames::Vector{String} = TSx.names(ts))
    Plots.plot(ts.coredata[!, :Index], Matrix(ts.coredata[!, colnames]))
end

######################
# joins
######################

function innerjoin(ts1, ts2)
    result = DataFrames.innerjoin(ts1.coredata, ts2.coredata, on = :Index)
    return TS(result)
end

function outerjoin(ts1, ts2)
    result = DataFrames.outerjoin(ts1.coredata, ts2.coredata, on = :Index)
    return TS(result)
end

function leftjoin(ts1, ts2)
    result = DataFrames.leftjoin(ts1.coredata, ts2.coredata, on = :Index)
    return TS(result)
end

function rightjoin(ts1, ts2)
    result = DataFrames.rightjoin(ts1.coredata, ts2.coredata, on = :Index)
    return TS(result)
end

function vcat(ts1::TS, ts2::TS)
    result_df = DataFrames.vcat(ts1.coredata, ts2.coredata)
    return TS(result_df)
end

end                             # END module TSx
