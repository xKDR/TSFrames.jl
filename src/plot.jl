"""
# Plotting

```julia
plot(ts::TimeFrame, cols::Vector{Int} = collect(1:TimeFrames.ncol(ts)))
plot(ts::TimeFrame, cols::Vector{T}) where {T<:Union{String, Symbol}}
plot(ts::TimeFrame, cols::T) where {T<:Union{Int, String, Symbol}}
```

Plots a TimeFrame object with the index on the x-axis and selected `cols` on
the y-axis. By default, plot all the columns. Columns can be selected
using Int indexes, String(s), or Symbol(s).

# Example
```jldoctest; setup = :(using TimeFrames, DataFrames, Dates, Plots, Random, Statistics)
julia> using Random;
julia> random(x) = rand(MersenneTwister(123), x);
julia> dates = Date("2022-01-01"):Month(1):Date("2022-01-01")+Month(11);

julia> df = DataFrame(Index = dates,
        val1 = random(12),
        val2 = random(12),
        val3 = random(12));

julia> ts = TimeFrame(df)
julia> show(ts)
(12 x 3) TimeFrame with Dates.Date Index

 Index       val1        val2        val3
 Date        Float64     Float64     Float64
────────────────────────────────────────────────
 2022-01-01  -0.319954    0.974594   -0.552977
 2022-02-01  -0.0386735  -0.171675    0.779539
 2022-03-01   1.67678    -1.75251     0.820462
 2022-04-01   1.69702    -0.0130037   1.0507
 2022-05-01   0.992128    0.76957    -1.28008
 2022-06-01  -0.315461   -0.543976   -0.117256
 2022-07-01  -1.18952    -1.12867    -0.0829082
 2022-08-01   0.159595    0.450044   -0.231828
 2022-09-01   0.501436    0.265327   -0.948532
 2022-10-01  -2.10516    -1.11489     0.285194
 2022-11-01  -0.781082   -1.20202    -0.639953
 2022-12-01  -0.169184    1.34879     1.33361


julia> using Plots

julia> # plot(ts)

# plot first 6 rows with selected columns
julia> # plot(ts[1:6], [:val1, :val3]);

# plot columns 1 and 2 on a specified window size
julia> # plot(ts, [1, 2], size=(600, 400));
```
"""
@recipe function f(ts::TimeFrame, cols::Vector{Int} = collect(1:TimeFrames.ncol(ts)))
    seriestype := :line
    size --> (1200, 1200)
    xlabel --> :Index
    ylabel --> join(TimeFrames.names(ts)[cols], ", ")
    legend := true
    label := permutedims(TimeFrames.names(ts)[cols])
    (TimeFrames.index(ts), Matrix(ts.coredata[!, cols.+1])) # increment to account for Index
end

@recipe function f(ts::TimeFrame, cols::Vector{T}) where {T<:Union{String, Symbol}}
    colindices = [DataFrames.columnindex(ts.coredata, i) for i in cols]
    colindices .-= 1            # decrement to account for Index
    (ts, colindices)
end

@recipe function f(ts::TimeFrame, cols::T) where {T<:Union{Int, String, Symbol}}
    (ts, [cols])
end
