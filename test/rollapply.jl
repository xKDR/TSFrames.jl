DATA_SIZE = 10
index_timetype = Date(2000, 1,1) + Day.(0:(DATA_SIZE - 1))
vec1 = collect(1:DATA_SIZE)
vec2 = collect(1:DATA_SIZE)
vec3 = collect(1:DATA_SIZE)
ts = TSFrame([vec1 vec2 vec3], index_timetype, colnames=[:A, :B, :C])

# tests for rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=true)
@test_throws ArgumentError rollapply(ts, Statistics.mean, 0)

## testing for windowsize equal to 1, 5, DATA_SIZE and DATA_SIZE + 1
for windowsize in [1, 5, DATA_SIZE, DATA_SIZE + 1]
    windowsize = min(windowsize, DATA_SIZE)
    mean_ts = rollapply(ts, Statistics.mean, windowsize)
    @test propertynames(mean_ts.coredata) == [:Index, :rolling_A_mean, :rolling_B_mean, :rolling_C_mean]
    @test index(mean_ts) == index_timetype[windowsize:DATA_SIZE]
    outputs = Vector([mean(endindex - windowsize + 1:endindex) for endindex in windowsize:DATA_SIZE])
    @test mean_ts[:, :rolling_A_mean] == outputs
    @test mean_ts[:, :rolling_B_mean] == outputs
    @test mean_ts[:, :rolling_C_mean] == outputs
end

# tests for rollapply(ts::TSFrame, fun::Function, windowsize::Int; bycolumn=false)
@test_throws ArgumentError rollapply(ts, size, 0; bycolumn=false)

## testing for windowsize equal to 1, 5, DATA_SIZE and DATA_SIZE + 1
for windowsize in [1, 5, DATA_SIZE, DATA_SIZE + 1]
    windowsize = min(windowsize, DATA_SIZE)
    size_ts = rollapply(ts, size, windowsize; bycolumn=false)
    @test propertynames(size_ts.coredata) == [:Index, :rolling_size]
    @test index(size_ts) == index_timetype[windowsize:DATA_SIZE]
    @test size_ts[:, :rolling_size] == [(windowsize, TSFrames.ncol(ts)) for i in windowsize:DATA_SIZE]
end
