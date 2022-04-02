module TSx

using DataFrames, Dates, ShiftedArrays

import Base.convert 
import Base.diff
import Base.filter
import Base.getindex
import Base.print
import Base.==
import Base.show
import Base.size

import Dates.Period

export TS, convert, getindex, nrow, ncol, size, toperiod, apply

struct TS
    coredata :: DataFrame
    index :: Int              # column index
    meta :: Dict
    function isRegular(vals)
        d = Base.diff(vals)
        if all([i == d[1] for i in d])
            result = true
        else
            result = false
        end
        result
    end
    function TS(coredata::DataFrame, index::Int=1, meta::Dict=Dict{String, Any}())
        index_vals = coredata[!, index]
        ind = sort(index_vals)
        if isRegular(ind)
            meta["regular"] = true
        end
        meta["index_type"] = eltype(coredata[!, index])
        cd = copy(coredata)
        new(sort(cd, index), index, meta)
    end
    function TS(coredata::DataFrame, index::AbstractArray{T}, meta::Dict=Dict{String, Any}()) where {T<:Int}
        ind = sort(index)
        if isRegular(ind)
            meta["regular"] = true
        end
        meta["index_type"] = eltype(coredata[!, index])
        cd = copy(coredata)
        insertcols!(cd, 1, :index => index; after=false, copycols=true)
        new(sort(cd, index), 1, meta)
    end
end

function TS(coredata::DataFrame, index::UnitRange{Int}, meta::Dict=Dict{String, Any}())
    index_vals = collect(index)
    TS(coredata, index_vals, meta)
end

# FIXME:
# julia> TS(rand(10), index_vals)
# ERROR: MethodError: no method matching TS(::Vector{Float64}, ::Vector{Int64})
function TS(coredata::AbstractVector{T}, meta::Dict=Dict{String, Any}()) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    df = DataFrame([coredata], :auto, copycols=true)
    TS(df, index_vals, meta)
end

function TS(coredata::AbstractArray{T,2}, meta::Dict=Dict{String, Any}()) where {T}
    index_vals = collect(Base.OneTo(length(coredata)))
    df = DataFrame(coredata, :auto, copycols=true)
    TS(df, index_vals, meta)
end

function indexcol(ts::TS)
    ts.coredata[!, ts.index]
end

function Base.show(ts::TS)
    print(first(ts.coredata, 10), "\n")
    print("Index col: ", ts.index, "\n")
    print("Metadata: ", ts.meta)
    print("Size: ", size(ts))
end

function Base.print(ts::TS)
    show(ts)
end

## Date-time type conversions for indexing
function convert(::Type{Date}, str::String)
    Date(Dates.parse_components(str, Dates.dateformat"yyyy-mm-dd")...)
end

function convert(::Type{String}, date::Date)
    Dates.format(date, "yyyy-mm-dd")
end
    
###

# ts[1]
# ts[1:10]
# ts[[1,3,5]]
# ts["2012-02-02", 2]

# Row indexing
function Base.getindex(ts::TS, i::Int)
    TS(ts.coredata[[i], :], ts.index, ts.meta)
end

function Base.getindex(ts::TS, r::UnitRange)
    TS(ts.coredata[collect(r), :], ts.index, ts.meta)
end

function Base.getindex(ts::TS, a::AbstractArray{Int64, 1})
    TS(ts.coredata[a, :], ts.index, ts.meta)
end

function Base.getindex(ts::TS, i::Any)
    ind = findall(x -> x == convert(ts.meta["index_type"], i), ts.coredata[!, ts.index]) # XXX: may return duplicate indices
    TS(ts.coredata[ind, :], ts.index, ts.meta)     # XXX: check if data is being copied
end
##

## Row-column indexing
function Base.getindex(ts::TS, i::Int, j::Int)
    if j == ts.index
        error("j cannot be index column")
    end
    TS(ts.coredata[[i], Cols(ts.index, j)], ts.index, ts.meta)
end

function Base.getindex(ts::TS, i::Colon, j::Int)
    if j == ts.index
        error("j cannot be the index")
    end
    TS(ts.coredata[:, [ts.index, j]], ts.index, ts.meta)
end

function Base.getindex(ts::TS, r::UnitRange, j::Int)
    TS(ts.coredata[collect(r), j], ts.index, ts.meta)
end
##

function nrow(ts::TS)
    size(ts.coredata)[1]
end

function ncol(ts::TS)
    size(ts.coredata)[2] - 1
end

function size(ts::TS)
    nr = nrow(ts)
    nc = ncol(ts)
    (nr, nc)
end

# convert to period
function toperiod(ts::TS, period, fun)
    idxConverted = Dates.value.(trunc.(ts.coredata[!, ts.index], period))
    # XXX: can we do without inserting a column?
    cd = copy(ts.coredata)
    insertcols!(cd, size(cd)[2], :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    resgd = [fun(x) for x in gd]
    TS(DataFrame(resgd)[!, Not(:idxConverted)], ts.index, ts.meta)
end

function apply(ts::TS, period, fun, cols) # fun=mean,median,maximum,minimum; cols=[:a, :b]
    idxConverted = Dates.value.(trunc.(ts.coredata[!, ts.index], period))
    cd = copy(ts.coredata)
    insertcols!(cd, size(cd)[2], :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    res = combine(gd, cols .=> fun) # TODO: add the (period-based) index
    res[!, Not(:idxConverted)]
end
    
function lag(ts::TS, lag_value::Int = 1)
    sdf = DataFrame(Base.lag(Matrix(ts.coredata[:, Not(ts.index)]), 
                    lag_value))
    rename!(sdf, names(ts.coredata[:, Not(ts.index)]))
    insertcols!(sdf, ts.index, "Index", col = ts.coredata[ts.index])
    TS(sdf, ts.index, ts.meta)
end

function diff(ts::TS, periods::Int = 1, differences::Int = 1)
    if periods <= 0
        error("periods must be a postive int")
    elseif differences <= 0
        error("differences must be a positive int")
    end
    ddf = ts.coredata
    for _ in 1:differences
        ddf = ddf[:, Not(ts.index)] .- TSx.lag(ts, periods).coredata[:, Not(ts.index)]
    end
    insertcols!(ddf, ts.index, "Index", col = ts.coredata[ts.index])
    TS(ddf, ts.index, ts.meta)
end

function pctchange(ts::TS, periods::Int = 1)
    if periods <= 0
        error("periods must be a positive int")
    end
    ddf = (ts.coredata[:, Not(ts.index)] ./ TSx.lag(ts, periods).coredata[:, Not(ts.index)]) .- 1
    insertcols!(ddf, ts.index, "Index", col = ts.coredata[ts.index])
    TS(ddf, ts.index, ts.meta)
end


end                             # END module TSx
