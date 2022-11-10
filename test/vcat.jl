# constants
DATA_SIZE_1 = 200
DATA_SIZE_2 = 200

index_timetype1 = Date(2007, 1,1) + Day.(0:(DATA_SIZE_1 - 1))
index_timetype2 = Date(2007, 1, 1) + Day(DATA_SIZE_1) + Day.(0:(DATA_SIZE_2 - 1))

# testing setequal and orderequal
df1 = DataFrame(x1 = random(200), x2 = random(200))
df2 = DataFrame(x2 = random(200), x1 = random(200))
ts1 = TSFrame(df1, index_timetype1)
ts2 = TSFrame(df2, index_timetype2)
ts_setequal = TSFrames.vcat(ts1, ts2, colmerge=:setequal)

@test propertynames(ts_setequal.coredata) == [:Index, :x1, :x2]
@test ts_setequal[1:DATA_SIZE_1, :Index] == ts1[:, :Index]
@test ts_setequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :Index] == ts2[:, :Index]
@test ts_setequal[1:DATA_SIZE_1, :x1] == ts1[:, :x1]
@test ts_setequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x1] == ts2[:, :x1]
@test ts_setequal[1:DATA_SIZE_1, :x2] == ts1[:, :x2]
@test ts_setequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x2] == ts2[:, :x2]

df2 = DataFrame(x1 = random(200), x2 = random(200))
ts2 = TSFrame(df2, index_timetype2)
ts_orderequal = TSFrames.vcat(ts1, ts2, colmerge=:orderequal)

@test propertynames(ts_orderequal.coredata) == [:Index, :x1, :x2]
@test ts_orderequal[1:DATA_SIZE_1, :Index] == ts1[:, :Index]
@test ts_orderequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :Index] == ts2[:, :Index]
@test ts_orderequal[1:DATA_SIZE_1, :x1] == ts1[:, :x1]
@test ts_orderequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x1] == ts2[:, :x1]
@test ts_orderequal[1:DATA_SIZE_1, :x2] == ts1[:, :x2]
@test ts_orderequal[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x2] == ts2[:, :x2]

# testing union and intersection
df1 = DataFrame(x1 = random(200), x2 = random(200))
df2 = DataFrame(x2 = random(200), x3 = random(200))
ts1 = TSFrame(df1, index_timetype1)
ts2 = TSFrame(df2, index_timetype2)

ts_intersect = TSFrames.vcat(ts1, ts2, colmerge=:intersect)

@test propertynames(ts_intersect.coredata) == [:Index, :x2]
@test ts_intersect[1:DATA_SIZE_1, :Index] == ts1[:, :Index]
@test ts_intersect[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :Index] == ts2[:, :Index]
@test ts_intersect[1:DATA_SIZE_1, :x2] == ts1[:, :x2]
@test ts_intersect[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x2] == ts2[:, :x2]

ts_union = TSFrames.vcat(ts1, ts2, colmerge=:union)

@test propertynames(ts_union.coredata) == [:Index, :x1, :x2, :x3]
@test ts_union[1:DATA_SIZE_1, :Index] == ts1[:, :Index]
@test ts_union[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :Index] == ts2[:, :Index]
@test ts_union[1:DATA_SIZE_1, :x1] == ts1[:, :x1]
@test isequal(Vector{Missing}(ts_union[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x1]), fill(missing, DATA_SIZE_2))
@test ts_union[1:DATA_SIZE_1, :x2] == ts1[:, :x2]
@test ts_union[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x2] == ts2[:, :x2]
@test isequal(Vector{Missing}(ts_union[1:DATA_SIZE_1, :x3]), fill(missing, DATA_SIZE_1))
@test ts_union[DATA_SIZE_1 + 1:DATA_SIZE_1 + DATA_SIZE_2, :x3] == ts2[:, :x3]
