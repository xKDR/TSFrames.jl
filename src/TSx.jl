module TSx

using DataFrames, Dates, ShiftedArrays, RecipesBase, RollingFunctions

import Base.convert
import Base.diff
import Base.filter
import Base.first
import Base.getindex
import Base.join
import Base.lastindex
import Base.length
import Base.log
import Base.Matrix
import Base.names
import Base.print
import Base.==
import Base.show
import Base.summary
import Base.size
import Base.vcat

import Dates.Period

export TS,
    JoinBoth,
    JoinAll,
    JoinInner,
    JoinOuter,
    JoinLeft,
    JoinRight,
    Matrix,
    apply,
    convert,
    cbind,
    describe,
    diff,
    first,
    getindex,
    head,
    index,
    join,
    lag,
    lastindex,
    lead,
    length,
    names,
    first,
    head,
    tail,
    nr,
    nrow,
    nc,
    ncol,
    pctchange,
    plot,
    log,
    rbind,
    show,
    size,
    subset,
    summary,
    tail,
    rollapply,
    vcat

include("TS.jl")
include("utils.jl")

include("apply.jl")
include("diff.jl")
include("getindex.jl")
include("join.jl")
include("lag.jl")
include("lead.jl")
include("log.jl")
include("matrix.jl")
include("pctchange.jl")
include("plot.jl")
include("rollapply.jl")
include("subset.jl")
include("vcat.jl")

end                             # END module TSx
