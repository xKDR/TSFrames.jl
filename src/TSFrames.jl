module TSFrames

using DataFrames, Dates, ShiftedArrays, RecipesBase, RollingFunctions, Tables # , Indicators

import Base.convert
import Base.diff
import Base.filter
import Base.first
import Base.getindex
import Base.join
import Base.lastindex
import Base.length
import Base.Matrix
import Base.names
import Base.print
import Base.==
import Base.show
import Base.summary
import Base.size
import Base.vcat

import Dates.Period

export TSFrame,
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
    endpoints,
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
    rbind,
    rollapply,
    show,
    size,
    subset,
    summary,
    tail,
    to_period,
    to_yearly,
    to_quarterly,
    to_monthly,
    to_weekly,
    to_daily,
    to_hourly,
    to_minutes,
    to_seconds,
    to_milliseconds,
    to_microseconds,
    to_nanoseconds,
    vcat,
    DataFrame,
    Date
# sma,
# runmean

include("TSFrame.jl")
include("utils.jl")

include("apply.jl")
include("diff.jl")
include("endpoints.jl")
include("getindex.jl")
include("getproperty.jl")
include("join.jl")
include("lag.jl")
include("lead.jl")
include("matrix.jl")
include("pctchange.jl")
include("plot.jl")
include("rollapply.jl")
include("subset.jl")
include("to_period.jl")
include("vcat.jl")
include("broadcasting.jl")
include("tables.jl")
# include("indicators.jl")

end                             # END module TSFrames
