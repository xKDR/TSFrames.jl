joinmap = Dict(
    :JoinInner=>DataFrames.innerjoin,
    :JoinBoth=>DataFrames.innerjoin,
    :JoinOuter=>DataFrames.outerjoin,
    :JoinAll=>DataFrames.outerjoin,
    :JoinLeft=>DataFrames.leftjoin,
    :JoinRight=>DataFrames.rightjoin
)

"""
# Joins/Column-binding

```julia
join(ts1::TSFrame, ts2::TSFrame, ts...; jointype::Symbol=:JoinAll)
```

`TSFrame` objects can be combined together column-wise using `Index` as the
column key. There are four kinds of column-binding operations possible
as of now. Each join operation works by performing a Set operation on
the `Index` column and then merging the datasets based on the output
from the Set operation. Each operation changes column names in the
final object automatically if the operation encounters duplicate
column names amongst the TSFrame objects.

The following join types are supported:

`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinInner)` and
`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinBoth)`

a.k.a. inner join, takes the intersection of the indexes of `ts1` and
`ts2`, and then merges the columns of both the objects. The resulting
object will only contain rows which are present in both the objects'
indexes. The function will rename columns in the final object if
they had same names in the TSFrame objects.

`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinOuter)` and
`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinAll)`:

a.k.a. outer join, takes the union of the indexes of `ts1` and `ts2`
before merging the other columns of input objects. The output will
contain rows which are present in all the input objects while
inserting `missing` values where a row was not present in any of the
objects. This is the default behaviour if no `jointype` is
provided.

`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinLeft)`:

Left join takes the index values which are present in the left
object `ts1` and finds matching index values in the right object
`ts2`. The resulting object includes all the rows from the left
object, the column values from the left object, and the values
associated with matching index rows on the right. The operation
inserts `missing` values where in the unmatched rows of the right
object.

`join(ts1::TSFrame, ts2::TSFrame; jointype=:JoinRight)`

Right join, similar to left join but works in the opposite
direction. The final object contains all the rows from the right
object while inserting `missing` values in rows missing from the left
object.

The default behaviour is to assume `jointype=:JoinAll` if no `jointype` is provided to the `join` method.

Joining multiple `TSFrame`s is also supported. The syntax is

`join(ts1::TSFrame, ts2::TSFrame, ts...; jointype::Symbol)`

where `jointype` must be one of `:JoinInner`, `:JoinBoth`, `:JoinOuter`, `:JoinAll`,
`:JoinLeft` or `:JoinRight`. Note that `join` on multiple `TSFrame`s is left associative.

`cbind` is an alias for `join` method.

# Examples
```jldoctest; setup = :(using TSFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts1 = TSFrame(random(length(dates)), dates);
julia> show(ts1)
(10 x 1) TSFrame with Dates.Date Index

 Index       x1
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,30));

julia> ts2 = TSFrame(random(length(dates)), dates);
julia> show(ts2)
30×1 TSFrame with Date Index
 Index       x1
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871
 2017-01-11  0.163666
 2017-01-12  0.473017
 2017-01-13  0.865412
 2017-01-14  0.617492
 2017-01-15  0.285698
 2017-01-16  0.463847
 2017-01-17  0.275819
 2017-01-18  0.446568
 2017-01-19  0.582318
 2017-01-20  0.255981
 2017-01-21  0.70586
 2017-01-22  0.291978
 2017-01-23  0.281066
 2017-01-24  0.792931
 2017-01-25  0.20923
 2017-01-26  0.918165
 2017-01-27  0.614255
 2017-01-28  0.802665
 2017-01-29  0.555668
 2017-01-30  0.940782

# join on all index values
# equivalent to `join(ts1, ts2; jointype=:JoinAll)` call
julia> join(ts1, ts2)
(30 x 2) TSFrame with Date Index
 Index       x1               x1_1
 Date        Float64?         Float64?
────────────────────────────────────────
 2017-01-01        0.768448   0.768448
 2017-01-02        0.940515   0.940515
 2017-01-03        0.673959   0.673959
 2017-01-04        0.395453   0.395453
 2017-01-05        0.313244   0.313244
 2017-01-06        0.662555   0.662555
 2017-01-07        0.586022   0.586022
 2017-01-08        0.0521332  0.0521332
 2017-01-09        0.26864    0.26864
 2017-01-10        0.108871   0.108871
     ⋮              ⋮             ⋮
 2017-01-22  missing          0.291978
 2017-01-23  missing          0.281066
 2017-01-24  missing          0.792931
 2017-01-25  missing          0.20923
 2017-01-26  missing          0.918165
 2017-01-27  missing          0.614255
 2017-01-28  missing          0.802665
 2017-01-29  missing          0.555668
 2017-01-30  missing          0.940782
                         11 rows omitted

# alias to `join()`
julia> cbind(ts1, ts2);

# join only the common index values
julia> join(ts1, ts2; jointype=:JoinBoth)
(10 x 2) TSFrame with Date Index
 Index       x1         x1_1
 Date        Float64    Float64
──────────────────────────────────
 2017-01-01  0.768448   0.768448
 2017-01-02  0.940515   0.940515
 2017-01-03  0.673959   0.673959
 2017-01-04  0.395453   0.395453
 2017-01-05  0.313244   0.313244
 2017-01-06  0.662555   0.662555
 2017-01-07  0.586022   0.586022
 2017-01-08  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864
 2017-01-10  0.108871   0.108871

# keep index values of `ts1`
julia> join(ts1, ts2; jointype=:JoinLeft)
(10 x 2) TSFrame with Date Index
 Index       x1         x1_1
 Date        Float64    Float64?
──────────────────────────────────
 2017-01-01  0.768448   0.768448
 2017-01-02  0.940515   0.940515
 2017-01-03  0.673959   0.673959
 2017-01-04  0.395453   0.395453
 2017-01-05  0.313244   0.313244
 2017-01-06  0.662555   0.662555
 2017-01-07  0.586022   0.586022
 2017-01-08  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864
 2017-01-10  0.108871   0.108871

# keep index values of `ts2`
julia> join(ts1, ts2; jointype=:JoinRight)
(30 x 2) TSFrame with Date Index
 Index       x1               x1_1
 Date        Float64?         Float64
────────────────────────────────────────
 2017-01-01        0.768448   0.768448
 2017-01-02        0.940515   0.940515
 2017-01-03        0.673959   0.673959
 2017-01-04        0.395453   0.395453
 2017-01-05        0.313244   0.313244
 2017-01-06        0.662555   0.662555
 2017-01-07        0.586022   0.586022
 2017-01-08        0.0521332  0.0521332
 2017-01-09        0.26864    0.26864
 2017-01-10        0.108871   0.108871
     ⋮              ⋮             ⋮
 2017-01-22  missing          0.291978
 2017-01-23  missing          0.281066
 2017-01-24  missing          0.792931
 2017-01-25  missing          0.20923
 2017-01-26  missing          0.918165
 2017-01-27  missing          0.614255
 2017-01-28  missing          0.802665
 2017-01-29  missing          0.555668
 2017-01-30  missing          0.940782
                         11 rows omitted

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,30));

julia> ts3 = TSFrame(random(length(dates)), dates);
julia> show(ts3)
30×1 TSFrame with Date Index
 Index       x1
 Date        Float64
───────────────────────
 2017-01-01  0.768448
 2017-01-02  0.940515
 2017-01-03  0.673959
 2017-01-04  0.395453
 2017-01-05  0.313244
 2017-01-06  0.662555
 2017-01-07  0.586022
 2017-01-08  0.0521332
 2017-01-09  0.26864
 2017-01-10  0.108871
 2017-01-11  0.163666
 2017-01-12  0.473017
 2017-01-13  0.865412
 2017-01-14  0.617492
 2017-01-15  0.285698
 2017-01-16  0.463847
 2017-01-17  0.275819
 2017-01-18  0.446568
 2017-01-19  0.582318
 2017-01-20  0.255981
 2017-01-21  0.70586
 2017-01-22  0.291978
 2017-01-23  0.281066
 2017-01-24  0.792931
 2017-01-25  0.20923
 2017-01-26  0.918165
 2017-01-27  0.614255
 2017-01-28  0.802665
 2017-01-29  0.555668
 2017-01-30  0.940782

# joining multiple TSFrame objects
julia> join(ts1, ts2, ts3; jointype=:JoinLeft)
10×3 TSFrame with Date Index
 Index       x1         x1_1       x1_2
 Date        Float64    Float64?   Float64?
─────────────────────────────────────────────
 2017-01-01  0.768448   0.768448   0.768448
 2017-01-02  0.940515   0.940515   0.940515
 2017-01-03  0.673959   0.673959   0.673959
 2017-01-04  0.395453   0.395453   0.395453
 2017-01-05  0.313244   0.313244   0.313244
 2017-01-06  0.662555   0.662555   0.662555
 2017-01-07  0.586022   0.586022   0.586022
 2017-01-08  0.0521332  0.0521332  0.0521332
 2017-01-09  0.26864    0.26864    0.26864
 2017-01-10  0.108871   0.108871   0.108871

```
"""
function Base.join(
    ts1::TSFrame,
    ts2::TSFrame,
    ts...;
    jointype::Symbol=:JoinAll
)
    result = joinmap[jointype](ts1.coredata, ts2.coredata, on=:Index, makeunique=true)
    for tsf in ts
        result = joinmap[jointype](result, tsf.coredata, on=:Index, makeunique=true)
    end
    return TSFrame(result)
end

# alias
cbind = join

# EXPERIMENTAL: basic merge-join algorithm

# requirements:
# `allunique(left) & allunique(right)` # TODO: look at this issue.
# `issorted(left) & issorted(right)`
function sort_merge_idx(left::AbstractVector, right::AbstractVector)
    # iteration variables
    i = 1
    j = 1
    k = 1

    length_left, length_right = length(left), length(right)

    result = DataFrames.similar_outer(left, right, length(left) + length(right))
    idx_left  = Vector{Int32}(undef, length(left))
    idx_right = Vector{Int32}(undef, length(right))

    @inbounds begin
        while (i <= length_left) && (j <= length_right)
            if left[i] < right[j]
                result[k] = left[i]
                idx_left[i] = k
                i += 1
            elseif left[i] > right[j]
                result[k] = right[j]
                idx_right[j] = k
                j += 1
            else
                result[k] = left[i]
                idx_left[i] = k
                idx_right[j] = k
                i += 1
                j += 1
            end
            k += 1
        end
        while i <= length_left
            result[k] = left[i]
            idx_left[i] = k
            i += 1
            k += 1
        end
        while j <= length_right
            result[k] = right[j]
            idx_right[j] = k
            j += 1
            k += 1
        end
    end
    resize!(result, k - 1)
    return result, idx_left, idx_right
end

function fast_outerjoin(left::TSFrame, right::TSFrame)

    to = Main.to

    merged_idx, merged_idx_left, merged_idx_right = @timeit to "sort_merge_idx" sort_merge_idx(index(left), index(right))

    merged_length = length(merged_idx)

    # TODO: add this feature,
    # if all three arrays have the same length, then the indices are the same
    # and we can go down a faster path of simple concatenation.
    # add_missings = !(length(merged_idx) == length(left) == length(right)) 

    @timeit to "column disambiguation" begin

        left_colnames = setdiff(Tables.columnnames(left.coredata), (:Index,))
        right_colnames = setdiff(Tables.columnnames(right.coredata), (:Index,))
        left_colidxs = Tables.columnindex.((left.coredata,), left_colnames)
        right_colidxs = Tables.columnindex.((right.coredata,), right_colnames)
        disambiguated_right_colnames = deepcopy(right_colnames)

        # disambiguate col names
        for (ind, colname) in enumerate(right_colnames)
            leftind = findfirst(==(colname), left_colnames)
            isnothing(leftind) || (disambiguated_right_colnames[ind] = Symbol(string(colname)*"_1"))
        end

    end

    @timeit to "DataFrame construction" begin
        result = DataFrame(:Index => merged_idx; makeunique = false, copycols = false)
        left_coredata = left.coredata
        right_coredata = right.coredata
    end

    @timeit to "column building" for idx in 1:length(left_colnames)
        col_idx = left_colidxs[idx]
        contents = @timeit to "column allocation" DataFrames.similar_missing(left.coredata[!, col_idx], merged_length)
        @timeit to "column population" (@inbounds contents[merged_idx_left] = left_coredata[!, col_idx])
        @timeit to "column transfer" (result[!, left_colnames[idx]] = contents)
    end

    @timeit to "column building" for idx in 1:length(right_colnames)
        col_idx = right_colidxs[idx]
        contents = @timeit to "column allocation" DataFrames.similar_missing(right.coredata[!, col_idx], merged_length)
        @timeit to "column population" (@inbounds contents[merged_idx_right] = right_coredata[!, col_idx])
        @timeit to "column transfer" result[!, disambiguated_right_colnames[idx]] = contents
    end

    return @timeit to "TSFrame construction" TSFrame(result, :Index; issorted = true, copycols = false)

end

function fast_outerjoin(ts1::TSFrame, ts2::TSFrame, others:::TSFrame...)

    result = fast_outerjoin(ts1, ts2)
    
    for other in others
        result = fast_outerjoin(ts1, ts2)
    end

    return result

end

# # as of 22-Jan-22, the timer outputs are as follows:
# BenchmarkTools.Trial: 100 samples with 1 evaluation.
#  Range (min … max):  61.627 ms … 287.822 ms  ┊ GC (min … max):  0.00% … 71.47%
#  Time  (median):     76.965 ms               ┊ GC (median):     0.00%
#  Time  (mean ± σ):   94.324 ms ±  47.940 ms  ┊ GC (mean ± σ):  22.42% ± 21.94%

#    ▄█▆▇▄                                                        
#   ▄█████▆▁▁▆▅▃▄▃▁▁▃▁▁▁▁▁▃▃▁▁▃▃▁▁▁▃▁▁▁▁▃▁▁▃▃▁▁▁▁▁▁▁▁▁▁▁▁▃▃▁▁▁▃▃ ▃
#   61.6 ms         Histogram: frequency by time          270 ms <

#  Memory estimate: 584.75 MiB, allocs estimate: 127.

#  ──────────────────────────────────────────────────────────────────────────────────
#                                           Time                    Allocations      
#                                  ───────────────────────   ────────────────────────
#         Tot / % measured:             43.8s /  93.7%            244GiB /  99.8%    

#  Section                 ncalls     time    %tot     avg     alloc    %tot      avg
#  ──────────────────────────────────────────────────────────────────────────────────
#  column building            854    23.0s   56.1%  26.9ms   74.2GiB   30.4%  89.0MiB
#    column population        854    13.5s   32.9%  15.8ms   4.82MiB    0.0%  5.78KiB
#    column allocation        854    9.49s   23.1%  11.1ms   74.2GiB   30.4%  89.0MiB
#    column transfer          854   16.9ms    0.0%  19.8μs   1.02MiB    0.0%  1.23KiB
#  sort_merge_idx             427    12.4s   30.1%  29.0ms   95.4GiB   39.1%   229MiB
#  TSFrame construction       427    5.64s   13.8%  13.2ms   74.2GiB   30.4%   178MiB
#  column disambiguation      427   6.44ms    0.0%  15.1μs    709KiB    0.0%  1.66KiB
#  ──────────────────────────────────────────────────────────────────────────────────


