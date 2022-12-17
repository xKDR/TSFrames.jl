"""
# Rolling Functions

```julia
rollapply(fun::Function, ts::TSFrame, column::Any, windowsize::Int)
```

Apply a function to a column of `ts` for each continuous set of rows
of size `windowsize`. `column` could be any of the `DataFrame` column
selectors.

The output is a TSFrame object with `(nrow(ts) - windowsize + 1)` rows
indexed with the last index value of each window.

This method uses `RollingFunctions` package to implement this
functionality.

# Examples

```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> ts = TSFrame(1:12, Date("2022-02-01"):Month(1):Date("2022-02-01")+Month(11))

julia> show(ts)
(12 x 1) TSFrame with Dates.Date Index

 Index       x1
 Date        Int64
───────────────────
 2022-02-01      1
 2022-03-01      2
 2022-04-01      3
 2022-05-01      4
 2022-06-01      5
 2022-07-01      6
 2022-08-01      7
 2022-09-01      8
 2022-10-01      9
 2022-11-01     10
 2022-12-01     11
 2023-01-01     12

julia> rollapply(sum, ts, :x1, 10)
(3 x 1) TSFrame with Dates.Date Index

 Index       x1_rolling_sum
 Date        Float64
────────────────────────────
 2022-11-01            55.0
 2022-12-01            65.0
 2023-01-01            75.0

julia> rollapply(Statistics.mean, ts, 1, 5)
(8 x 1) TSFrame with Dates.Date Index

 Index       x1_rolling_mean
 Date        Float64
─────────────────────────────
 2022-06-01              3.0
 2022-07-01              4.0
 2022-08-01              5.0
 2022-09-01              6.0
 2022-10-01              7.0
 2022-11-01              8.0
 2022-12-01              9.0
 2023-01-01             10.0

```
"""
function rollapply(fun::Function, ts::TSFrame, column::Any, windowsize::Int) # TODO: multiple columns
    if windowsize < 1
        throw(ArgumentError("windowsize must be greater than or equal to 1"))
    end
    col = Int(1)
    if typeof(column) <: Int
        col = copy(column)
        col = col+1             # index is always 1
    else
        col = column
    end
    res = RollingFunctions.rolling(fun, ts.coredata[!, col], windowsize)
    idx = TSFrames.index(ts)[windowsize:end]
    colname = names(ts.coredata[!, [col]])[1]
    res_df = DataFrame([idx, res], ["Index", "$(colname)_rolling_$(fun)"])
    return TSFrame(res_df)
end

"""
```julia
rollapply(fun::Function, ts::TSFrame, windowsize::Int; bycolumn=true)
```
"""
function rollapply(fun::Function, ts::TSFrame, windowsize::Int; bycolumn=true)
    # apply function to each column
    if bycolumn
        res = nothing
        df = DataFrame(ts)[:, Not(:Index)]
        for endindex in windowsize:TSFrames.nrow(ts)
            # get the window
            df_window = df[endindex - windowsize + 1:endindex, :]

            # transform columns
            mapcols!(col -> fun(col), df_window)

            # concat vertically
            if isequal(res, nothing)
                res = df_window
            else
                res = vcat(res, df_window)
            end
        end

        # rename cols and add index to resulting DataFrame
        DataFrames.rename!(res, [col => string("rolling_", col, "_", Symbol(fun)) for col in propertynames(res)])
        res[:, :Index] = TSFrames.index(ts)[windowsize:end]
        return TSFrame(res)

    # apply function to table as a whole
    else
        # outputs will be a vector of outputs
        outputs = nothing
        for endindex in windowsize:TSFrames.nrow(ts)
            ts_window = ts[endindex - windowsize + 1:endindex]
            output = fun(ts_window)

            if (isequal(outputs, nothing))
                outputs = [output]
            else
                push!(outputs, output)
            end
        end
        res = DataFrame(Index=TSFrames.index(ts)[windowsize:end], outputs=outputs)
        DataFrames.rename!(res, Dict(:outputs => string("rolling_", Symbol(fun))))
        return TSFrame(res)
    end
end
