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
