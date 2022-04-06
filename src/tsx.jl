module TSx

using DataFrames, Dates, ShiftedArrays

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
    toperiod

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
    function TS(coredata::DataFrame, index::AbstractArray{T}) where {T<:Int}
        sorted_index = sort(index)

        cd = copy(coredata)
        insertcols!(cd, 1, :Index => sorted_index, after=false, copycols=true)

        new(cd)
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


function indexcol(ts::TS)
    ts.coredata[!, :Index]
end

function names(ts::TS)
    names(ts.coredata[!, Not(:Index)])
end

function Base.show(ts::TS)
    println(first(ts.coredata, 10))
    println("Size: ", size(ts))
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
    TS(ts.coredata[[i], :])
end

function Base.getindex(ts::TS, r::UnitRange)
    TS(ts.coredata[collect(r), :])
end

function Base.getindex(ts::TS, a::AbstractArray{Int64, 1})
    TS(ts.coredata[a, :])
end

function Base.getindex(ts::TS, i::Any)
    ind = findall(x -> x == TSx.convert(eltype(ts.coredata[!, :Index]), i), ts.coredata[!, :Index]) # XXX: may return duplicate indices
    TS(ts.coredata[ind, :])     # XXX: check if data is being copied
end

# Row-column indexing
function Base.getindex(ts::TS, i::Int, j::Int)
    if j == 1
        error("j cannot be index column")
    end
    TS(ts.coredata[[i], Cols(:Index, j)])
end

##############################
# Unfixed from this point down
##############################

function Base.getindex(ts::TS, i::Symbol, j::Int)
    if j == 1
        error("j cannot be the index")
    end
    TS(ts.coredata[:, [:Index, j]], :Index)
end

function Base.getindex(ts::TS, r::UnitRange, j::Int)
    TS(ts.coredata[collect(r), j], :Index)
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
    idxConverted = Dates.value.(trunc.(ts.coredata[!, :Index], period))
    # XXX: can we do without inserting a column?
    cd = copy(ts.coredata)
    insertcols!(cd, size(cd)[2], :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    resgd = [fun(x) for x in gd]
    TS(DataFrame(resgd)[!, Not(:idxConverted)], :Index)
end

function apply(ts::TS, period, fun, cols) # fun=mean,median,maximum,minimum; cols=[:a, :b]
    idxConverted = Dates.value.(trunc.(ts.coredata[!, :Index], period))
    cd = copy(ts.coredata)
    insertcols!(cd, size(cd)[2], :idxConverted => idxConverted;
                after=true, copycols=true)
    gd = groupby(cd, :idxConverted, sort=true)
    res = combine(gd, cols .=> fun) # TODO: add the (period-based) index
    res[!, Not(:idxConverted)]
end

function lag(ts::TS, lag_value::Int = 1)
    sdf = DataFrame(ShiftedArrays.lag.(eachcol(ts.coredata[!, Not(:Index)]), lag_value), TSx.names(ts))
    insertcols!(sdf, 1, :Index => ts.coredata[!, :Index])
    TS(sdf, :Index)
end

function diff(ts::TS, periods::Int = 1, differences::Int = 1)
    if periods <= 0
        error("periods must be a postive int")
    elseif differences <= 0
        error("differences must be a positive int")
    end
    ddf = ts.coredata
    for _ in 1:differences
        ddf = ddf[:, Not(:Index)] .- TSx.lag(ts, periods).coredata[:, Not(:Index)]
    end
    insertcols!(ddf, 1, "Index" => ts.coredata[!, :Index])
    TS(ddf, :Index)
end

function pctchange(ts::TS, periods::Int = 1)
    if periods <= 0
        error("periods must be a positive int")
    end
    ddf = (ts.coredata[:, Not(:Index)] ./ TSx.lag(ts, periods).coredata[:, Not(:Index)]) .- 1
    insertcols!(ddf, 1, "Index" => ts.coredata[!, :Index])
    TS(ddf, :Index)
end

function computelogreturns(ts::TS)
    combine(ts.coredata,
            :Index => (x -> x[2:length(x)]) => :Index,
            Not(:Index) => (x -> diff(log.(x))) => :logreturns)
end

end                             # END module TSx