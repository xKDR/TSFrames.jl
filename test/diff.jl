ts = TSFrame(integer_data_vector, index_timetype)

# when period is atmost DATA_SIZE
for period in [1, Int(floor(DATA_SIZE/2)), DATA_SIZE]
    ts_diff = diff(ts, period)

    # Index should be the same
    @test isequal(ts_diff[:, :Index], ts[:, :Index])

    # the first period values must be missing
    @test isequal(Vector{Missing}(ts_diff[1:period, :x1]), fill(missing, period))

    # the rest of the values must be the differences
    @test isequal(ts_diff[(period + 1):TimeFrames.nrow(ts), :x1], ts[(period + 1):TimeFrames.nrow(ts), :x1] - ts[1:TimeFrames.nrow(ts) - period, :x1])
end

# when period is greater than DATA_SIZE
ts_diff = diff(ts, DATA_SIZE + 1)
@test isequal(ts_diff[:, :Index], ts[:, :Index])
@test isequal(Vector{Missing}(ts_diff[1:DATA_SIZE, :x1]), fill(missing, DATA_SIZE))
