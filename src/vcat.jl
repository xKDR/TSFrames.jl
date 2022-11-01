"""
# Row-merging (vcat/rbind)

```julia
vcat(ts1::TimeFrame, ts2::TimeFrame; colmerge::Symbol=:union)
```

Concatenate rows of two TimeFrame objects, append `ts2` to `ts1`.

The `colmerge` keyword argument specifies the column merge
strategy. The value of `colmerge` is directly passed to `cols`
argument of `DataFrames.vcat`.

Currently, `DataFrames.vcat` supports four types of column-merge strategies:

1. `:setequal`: only merge if both objects have same column names, use the order of columns in `ts1`.
2. `:orderequal`: only merge if both objects have same column names and columns are in the same order.
3. `:intersect`: only merge the columns which are common to both objects, ignore the rest.
4. `:union`: merge even if columns differ, the resulting object has all the columns filled with `missing`, if necessary.

# Examples
```jldoctest; setup = :(using TimeFrames, DataFrames, Dates, Random, Statistics)
julia> using Random;

julia> random(x) = rand(MersenneTwister(123), x);

julia> dates1 = collect(Date(2017,1,1):Day(1):Date(2017,1,10));

julia> dates2 = collect(Date(2017,1,11):Day(1):Date(2017,1,30));

julia> ts1 = TimeFrame([randn(length(dates1)) randn(length(dates1))], dates1)
julia> show(ts1)
(10 x 1) TimeFrame with Dates.Date Index

 Index       x1
 Date        Float64
────────────────────────
 2017-01-01  -0.420348
 2017-01-02   0.109363
 2017-01-03  -0.0702014
 2017-01-04   0.165618
 2017-01-05  -0.0556799
 2017-01-06  -0.147801
 2017-01-07  -2.50723
 2017-01-08  -0.099783
 2017-01-09   0.177526
 2017-01-10  -1.08461

julia> df = DataFrame(x1 = randn(length(dates2)), y1 = randn(length(dates2)))
julia> ts2 = TimeFrame(df, dates2)
julia> show(ts2)
(20 x 1) TimeFrame with Dates.Date Index

 Index       x1
 Date        Float64
────────────────────────
 2017-01-11   2.15087
 2017-01-12   0.9203
 2017-01-13  -0.0879142
 2017-01-14  -0.930109
 2017-01-15   0.061117
 2017-01-16   0.0434627
 2017-01-17   0.0834733
 2017-01-18  -1.52281
     ⋮           ⋮
 2017-01-23  -0.756143
 2017-01-24   0.491623
 2017-01-25   0.549672
 2017-01-26   0.570689
 2017-01-27  -0.380011
 2017-01-28  -2.09965
 2017-01-29   1.37289
 2017-01-30  -0.462384
          4 rows omitted


julia> vcat(ts1, ts2)
(30 x 3) TimeFrame with Date Index

 Index       x1          x2              y1
 Date        Float64     Float64?        Float64?
─────────────────────────────────────────────────────────
 2017-01-01  -0.524798        -1.4949    missing
 2017-01-02  -0.719611        -1.1278    missing
 2017-01-03   0.0926092        1.19778   missing
 2017-01-04   0.236237         1.39115   missing
 2017-01-05   0.369588         1.21792   missing
 2017-01-06   1.65287         -0.930058  missing
 2017-01-07   0.761301         0.23794   missing
 2017-01-08  -0.571046        -0.480486  missing
 2017-01-09  -2.01905         -0.46391   missing
 2017-01-10   0.193942        -1.01471   missing
 2017-01-11   0.239041   missing              -0.473429
 2017-01-12   0.286036   missing              -0.90377
 2017-01-13   0.683429   missing              -0.128489
 2017-01-14  -1.51442    missing              -2.39843
 2017-01-15  -0.581341   missing              -0.12265
 2017-01-16   1.07059    missing              -0.916064
 2017-01-17   0.859396   missing               0.0162969
 2017-01-18  -1.93127    missing               2.11127
 2017-01-19   0.529477   missing               0.636964
 2017-01-20   0.817429   missing              -0.34038
 2017-01-21  -0.682296   missing              -0.971262
 2017-01-22   1.36232    missing              -0.236323
 2017-01-23   0.143188   missing              -0.501722
 2017-01-24   0.621845   missing              -1.20016
 2017-01-25   0.076199   missing              -1.36616
 2017-01-26   0.379672   missing              -0.555395
 2017-01-27   0.494473   missing               1.05389
 2017-01-28   0.278259   missing              -0.358983
 2017-01-29   0.0231765  missing               0.712526
 2017-01-30   0.516704   missing               0.216855

julia> vcat(ts1, ts2; colmerge=:intersect)
(30 x 1) TimeFrame with Date Index

 Index       x1
 Date        Float64
────────────────────────
 2017-01-01  -0.524798
 2017-01-02  -0.719611
 2017-01-03   0.0926092
 2017-01-04   0.236237
 2017-01-05   0.369588
 2017-01-06   1.65287
 2017-01-07   0.761301
 2017-01-08  -0.571046
 2017-01-09  -2.01905
 2017-01-10   0.193942
 2017-01-11   0.239041
 2017-01-12   0.286036
 2017-01-13   0.683429
 2017-01-14  -1.51442
 2017-01-15  -0.581341
 2017-01-16   1.07059
 2017-01-17   0.859396
 2017-01-18  -1.93127
 2017-01-19   0.529477
 2017-01-20   0.817429
 2017-01-21  -0.682296
 2017-01-22   1.36232
 2017-01-23   0.143188
 2017-01-24   0.621845
 2017-01-25   0.076199
 2017-01-26   0.379672
 2017-01-27   0.494473
 2017-01-28   0.278259
 2017-01-29   0.0231765
 2017-01-30   0.516704

```
"""
function Base.vcat(ts1::TimeFrame, ts2::TimeFrame; colmerge=:union)
    result_df = DataFrames.vcat(ts1.coredata, ts2.coredata; cols=colmerge)
    return TimeFrame(result_df)
end
# alias
rbind = vcat
