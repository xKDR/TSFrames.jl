function test_toperiod()
    DATA_SIZE = 360
    data_vector = randn(DATA_SIZE)
    index_timetype = Date(2007, 1,1) + Day.(0:(DATA_SIZE - 1))
    df_timetype_index = DataFrame(Index = index_timetype, data = data_vector)
    ts_daily = TS(df_timetype_index, 1)
    ts_daily_matrix = TS(DataFrames.innerjoin(df_timetype_index, df_timetype_index, on=:Index, makeunique=true))

    # function toperiod(ts::TS, period::T, fun::Function) where {T<:Dates.Period}
    # Multiple periods and functions.

    # test_toperiod_first
    ts_monthly = toperiod(ts_daily, Dates.Month, first)
    @test typeof(ts_monthly) == TSx.TS
    @test DataFrames.nrow(ts_monthly.coredata) == 12 # 360 days
    @test ts_monthly.coredata[1, :Index] == df_timetype_index[1, :Index]

    # yearly
    @test_broken ts_yearly = toperiod(ts_daily_matrix, Dates.Year, Statistics.mean)
    @test typeof(ts_yearly) == TSx.TS
    @test typeof(ts_yearly.coredata) == DataFrame
    @test DataFrames.nrow(ts_yearly.coredata) == 1
    @test ts_yearly.coredata[1, 2] == [Statistics.mean(x) for x in eachcol(Matrix(ts_daily_matrix.coredata[!, Not(:Index)]))]
end

test_toperiod()
