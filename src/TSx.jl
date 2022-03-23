module TSx

using DataFrames, Dates

import Base.convert 
import Base.filter
import Base.getindex
import Base.print
import Base.==
import Base.size

import Dates.Period

export TS, convert, getindex, nrow, ncol, size, toperiod, apply

struct TS
    coredata :: DataFrame
    index :: Int              # column index
    meta :: Dict
    function isRegular(vals)
        d = diff(vals)
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

function Base.show(ts::TS)
    print("Index:", ts.index, "\n")
    print(ts.coredata, "\n")
    print("Metadata:", ts.meta)
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
    TS(ts.coredata[[i], [j-1]], ts.index, ts.meta) # j-1: index is always 1
end

function Base.getindex(ts::TS, i::Colon, j::Int)
    if j == ts.index
        error("j cannot be the index")
    end
    TS(ts.coredata[:, [ts.index, j]], ts.index, ts.meta)
end
##

function nrow(ts::TS)
    nrow(ts.coredata)
end

function ncol(ts::TS)
    ncol(ts.coredata) - 1
end

function size(ts::TS)
    nr = nrow(ts.coredata)
    nc = ncol(ts.coredata) - 1  # minus the index
    (nr, nc)
end

# convert to period
function toperiod(ts::TS, period, fun)
    idxConverted = Dates.value.(trunc.(ts.coredata[!, ts.index], period))
    # XXX: can we do without inserting a column?
    cd = copy(ts.coredata)
    insertcols!(cd, ncol(cd), :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    idxname = Symbol(names(cd)[ts.index])
    resgd = [fun(x) for x in gd]
    TS(DataFrame(resgd)[!, Not(:idxConverted)], ts.index, ts.meta)
end

function apply(ts::TS, period, fun, cols) # fun=mean,median,maximum,minimum; cols=[:a, :b]
    idxConverted = Dates.value.(trunc.(ts.coredata[!, ts.index], period))
    cd = copy(ts.coredata)
    insertcols!(cd, ncol(cd), :idxConverted => idxConverted;
                after=true, copycols=true)
    idxname = Symbol(names(cd)[ts.index])
    gd = groupby(cd, :idxConverted, sort=true)
    res = combine(gd, cols .=> fun) # TODO: add the (period-based) index
    res[!, Not(:idxConverted)]
end

end                             # END module TSx
