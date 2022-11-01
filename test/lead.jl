ts = TimeFrame(integer_data_vector, index_timetype)

# when leading by somethng non-negative and atmost DATA_SIZE
for leadby in [0, 1, Int(floor(DATA_SIZE/2)), DATA_SIZE]
    ts_lead = lead(ts, leadby)

    # Index should be the same
    @test isequal(ts_lead[:, :Index], ts[:, :Index])
    
    # The last lead values must be missing
    @test isequal(Vector{Missing}(ts_lead[TSx.nrow(ts) - (leadby - 1):TSx.nrow(ts), :x1]), fill(missing, leadby))

    # The rest of the values must be shifted
    @test isequal(ts_lead[1:TSx.nrow(ts) - leadby, :x1], ts[leadby + 1:TSx.nrow(ts), :x1])
end

# when leading by something greater than DATA_SIZE
ts_lead = lead(ts, DATA_SIZE + 1)
@test isequal(ts_lead[:, :Index], ts[:, :Index])
@test isequal(Vector{Missing}(ts_lead[1:TSx.nrow(ts), :x1]), fill(missing, DATA_SIZE))

# when leading by something negative
ts_lead = lead(ts, -1)
@test isequal(ts_lead[:, :Index], ts[:, :Index])
@test isequal(ts_lead[1, :x1], missing)
@test isequal(ts_lead[2:TSx.nrow(ts), :x1], ts[1:TSx.nrow(ts) - 1, :x1])