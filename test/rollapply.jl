DATA_SIZE = 10
index_timetype = Date(2000, 1,1) + Day.(0:(DATA_SIZE - 1))
vec1 = collect(1:DATA_SIZE)
vec2 = collect(1:DATA_SIZE)
vec3 = collect(1:DATA_SIZE)
ts = TSFrame([vec1 vec2 vec3], index_timetype, colnames=[:A, :B, :C])

windowsize = 0
@test_throws ArgumentError rollapply(first, ts, :A, windowsize)

windowsize = 1
rp = rollapply(first, ts, :A, windowsize)
@test typeof(rp) == TSFrames.TSFrame      # test type
@test occursin("A", names(rp)[1]) # test colname

@test TSFrames.nrow(rp) == TSFrames.nrow(ts) - windowsize + 1 # nrow
@test rp[1, 1] == ts[1, :A]                         # shift
@test rp[2, 1] == ts[2, :A]                         # value

windowsize = 5
rp = rollapply(sum, ts, :A, windowsize)
@test typeof(rp) == TSFrames.TSFrame
@test first(index(rp)) == index(ts)[windowsize]
@test TSFrames.nrow(rp) == TSFrames.nrow(ts) - windowsize + 1
@test rp[1, 1] == sum(ts[1:windowsize, :A])
@test occursin("A", names(rp)[1])

windowsize = DATA_SIZE
@test typeof(rp) == TSFrames.TSFrame
rp = rollapply(sum, ts, :A, windowsize)
@test first(index(rp)) == index(ts)[windowsize]
@test TSFrames.nrow(rp) == 1
@test rp[1, 1] == sum(ts[1:windowsize, :A])
@test occursin("A", names(rp)[1])

windowsize = DATA_SIZE + 1
@test_throws ErrorException rollapply(first, ts, :A, windowsize)

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
