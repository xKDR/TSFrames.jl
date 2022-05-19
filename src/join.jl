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

`join(ts1::TS, ts2::TS, ::Type{JoinBoth})`

a.k.a. inner join, takes the intersection of the indexes of `ts1` and
`ts2`, and then merges the columns of both the objects. The resulting
object will only contain rows which are present in both the objects'
indexes. The function will rename columns in the final object if
they had same names in the TS objects.

`join(ts1::TS, ts2::TS, ::Type{JoinAll})`:

a.k.a. outer join, takes the union of the indexes of `ts1` and `ts2`
before merging the other columns of input objects. The output will
contain rows which are present in all the input objects while
inserting `missing` values where a row was not present in any of the
objects. This is the default behaviour if no `JoinType` object is
provided.

`join(ts1::TS, ts2::TS, ::Type{JoinLeft})`:

Left join takes the index values which are present in the left
object `ts1` and finds matching index values in the right object
`ts2`. The resulting object includes all the rows from the left
object, the column values from the left object, and the values
associated with matching index rows on the right. The operation
inserts `missing` values where in the unmatched rows of the right
object.

`join(ts1::TS, ts2::TS, ::Type{JoinRight})`

Right join, similar to left join but works in the opposite
direction. The final object contains all the rows from the right
object while inserting `missing` values in rows missing from the left
object.

The default behaviour is to assume `JoinAll` if no `JoinType` object
is provided to the `join` method.

`cbind` is an alias for `join` method.

# Examples
```jldoctest; setup = :(using TSx, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> ts1 = TS(random(length(dates)), dates)
julia> show(ts1)
(10 x 1) TS with Dates.Date Index

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

julia> ts2 = TS(random(length(dates)), dates);
julia> show(ts2)
(30 x 1) TS with Dates.Date Index

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
     ⋮           ⋮
 2017-01-23  0.281066
 2017-01-24  0.792931
 2017-01-25  0.20923
 2017-01-26  0.918165
 2017-01-27  0.614255
 2017-01-28  0.802665
 2017-01-29  0.555668
 2017-01-30  0.940782
        14 rows omitted


# join on all index values
# equivalent to `join(ts1, ts2, JoinAll)` call
julia> join(ts1, ts2)
(30 x 2) TS with Date Index

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
julia> join(ts1, ts2, JoinBoth)
(10 x 2) TS with Date Index

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
julia> join(ts1, ts2, JoinLeft)
(10 x 2) TS with Date Index

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
julia> join(ts1, ts2, JoinRight)
(30 x 2) TS with Date Index

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

```
"""
function Base.join(ts1::TS, ts2::TS)
    join(ts1, ts2, JoinAll)
end

function Base.join(ts1::TS, ts2::TS, ::Type{JoinBoth})
    result = DataFrames.innerjoin(ts1.coredata, ts2.coredata, on=:Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::Type{JoinAll})
    result = DataFrames.outerjoin(ts1.coredata, ts2.coredata, on=:Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::Type{JoinLeft})
    result = DataFrames.leftjoin(ts1.coredata, ts2.coredata, on=:Index, makeunique=true)
    return TS(result)
end

function Base.join(ts1::TS, ts2::TS, ::Type{JoinRight})
    result = DataFrames.rightjoin(ts1.coredata, ts2.coredata, on=:Index, makeunique=true)
    return TS(result)
end
# alias
cbind = join
