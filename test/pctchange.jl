ts = TimeFrame(integer_data_vector, index_timetype)

@test_throws ArgumentError pctchange(ts, 0)
@test_throws ArgumentError pctchange(ts, -1)

# when period is something less than DATA_SIZE
for periods in [1, Int(floor(DATA_SIZE/2))]
    pctchange_ts = pctchange(ts, periods)

    # test that Index remains the same
    @test isequal(pctchange_ts[:, :Index], ts[:, :Index])

    # first periods values are missing
    @test isequal(Vector{Missing}(pctchange_ts[1:periods, :x1]), fill(missing, periods))

    # other elements are pct changes
    pctchange_output = pctchange_ts[(periods + 1):TimeFrames.nrow(ts), :x1]
    correct_output = (ts[periods + 1:TimeFrames.nrow(ts), :x1] - ts[1:TimeFrames.nrow(ts) - periods, :x1]) ./ abs.(ts[1:TimeFrames.nrow(ts) - periods, :x1])

    @test floor.(pctchange_output .* 100) == floor.(correct_output .* 100)
end

# when period is atleast DATA_SIZE
for periods in [DATA_SIZE, DATA_SIZE + 1]
    pctchange_ts = lag(ts, periods)
    @test isequal(pctchange_ts[:, :Index], ts[:, :Index])
    @test isequal(Vector{Missing}(pctchange_ts[1:DATA_SIZE, :x1]), fill(missing, DATA_SIZE))
end


