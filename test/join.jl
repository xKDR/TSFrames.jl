ts1 = TS(rand(DATA_SIZE), index_timetype)
ts2 = TS(rand(Int(floor(DATA_SIZE/2))), index_timetype[1:Int(floor(DATA_SIZE/2))])

# testing JoinInner/JoinBoth
ts_innerjoin = join(ts1, ts2, JoinInner)
@test propertynames(ts_innerjoin.coredata) == [:Index, :x1, :x1_1]
@test ts_innerjoin[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_innerjoin[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_innerjoin[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]

ts_joinboth = join(ts1, ts2, JoinBoth)
@test propertynames(ts_joinboth.coredata) == [:Index, :x1, :x1_1]
@test ts_joinboth[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_joinboth[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_joinboth[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]

# testing JoinOuter/JoinAll
ts_outerjoin = join(ts1, ts2, JoinOuter)
@test propertynames(ts_outerjoin.coredata) == [:Index, :x1, :x1_1]
@test ts_outerjoin[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_outerjoin[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_outerjoin[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_outerjoin[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_joinboth = join(ts1, ts2, JoinAll)
@test propertynames(ts_joinboth.coredata) == [:Index, :x1, :x1_1]
@test ts_joinboth[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_joinboth[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_joinboth[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_joinboth[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

# testing JoinLeft
ts_joinleft = join(ts1, ts2, JoinLeft)
@test propertynames(ts_joinleft.coredata) == [:Index, :x1, :x1_1]
@test ts_joinleft[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_joinleft[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_joinleft[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_joinleft[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

# testing JoinRight
ts_joinright = join(ts1, ts2, JoinRight)
@test propertynames(ts_joinright.coredata) == [:Index, :x1, :x1_1]
@test ts_joinright[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_joinright[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_joinright[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]