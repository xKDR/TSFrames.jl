ts1 = TSFrame(rand(DATA_SIZE), index_timetype)
ts2 = TSFrame(rand(Int(floor(DATA_SIZE/2))), index_timetype[1:Int(floor(DATA_SIZE/2))])
ts3 = TSFrame(rand(DATA_SIZE), index_timetype)
ts4 = TSFrame(rand(DATA_SIZE), index_timetype)
ts5 = TSFrame(rand(DATA_SIZE), index_timetype)

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

ts_multipleinnerjoin = join(ts1, ts2, ts3; jointype=JoinInner)
@test propertynames(ts_multipleinnerjoin.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multipleinnerjoin[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_multipleinnerjoin[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multipleinnerjoin[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multipleinnerjoin[:, :x1_2] == ts3[1:Int(floor(DATA_SIZE/2)), :x1]

ts_multiplejoinboth = join(ts1, ts2, ts3; jointype=JoinBoth)
@test propertynames(ts_multiplejoinboth.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multiplejoinboth[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_multiplejoinboth[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multiplejoinboth[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multiplejoinboth[:, :x1_2] == ts3[1:Int(floor(DATA_SIZE/2)), :x1]

ts_fiveinnerjoins = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinInner)
@test propertynames(ts_fiveinnerjoins.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fiveinnerjoins[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_fiveinnerjoins[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fiveinnerjoins[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fiveinnerjoins[:, :x1_2] == ts3[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fiveinnerjoins[:, :x1_3] == ts4[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fiveinnerjoins[:, :x1_4] == ts5[1:Int(floor(DATA_SIZE/2)), :x1]

ts_fivejoinboth = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinBoth)
@test propertynames(ts_fivejoinboth.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fivejoinboth[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_fivejoinboth[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinboth[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinboth[:, :x1_2] == ts3[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinboth[:, :x1_3] == ts4[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinboth[:, :x1_4] == ts5[1:Int(floor(DATA_SIZE/2)), :x1]

# testing JoinOuter/JoinAll
ts_outerjoin = join(ts1, ts2, JoinOuter)
@test propertynames(ts_outerjoin.coredata) == [:Index, :x1, :x1_1]
@test ts_outerjoin[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_outerjoin[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_outerjoin[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_outerjoin[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_joinall = join(ts1, ts2, JoinAll)
@test propertynames(ts_joinall.coredata) == [:Index, :x1, :x1_1]
@test ts_joinall[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_joinall[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_joinall[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_joinall[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_multipleouterjoin = join(ts1, ts2, ts3; jointype=JoinOuter)
@test propertynames(ts_multipleouterjoin.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multipleouterjoin[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_multipleouterjoin[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_multipleouterjoin[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multipleouterjoin[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_multipleouterjoin[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_multiplejoinall = join(ts1, ts2, ts3; jointype=JoinAll)
@test propertynames(ts_multiplejoinall.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multiplejoinall[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_multiplejoinall[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_multiplejoinall[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multiplejoinall[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_multiplejoinall[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_fiveouterjoins = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinOuter)
@test propertynames(ts_fiveouterjoins.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fiveouterjoins[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_fiveouterjoins[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fiveouterjoins[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test ts_fiveouterjoins[:, :x1_3] == ts4[1:DATA_SIZE, :x1]
@test ts_fiveouterjoins[:, :x1_4] == ts5[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_fiveouterjoins[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_fivejoinalls = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinAll)
@test propertynames(ts_fivejoinalls.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fivejoinalls[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_fivejoinalls[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinalls[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test ts_fivejoinalls[:, :x1_3] == ts4[1:DATA_SIZE, :x1]
@test ts_fivejoinalls[:, :x1_4] == ts5[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_fivejoinalls[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

# testing JoinLeft
ts_joinleft = join(ts1, ts2, JoinLeft)
@test propertynames(ts_joinleft.coredata) == [:Index, :x1, :x1_1]
@test ts_joinleft[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_joinleft[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_joinleft[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_joinleft[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_multiplejoinleft = join(ts1, ts2, ts3; jointype=JoinLeft)
@test propertynames(ts_multiplejoinleft.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multiplejoinleft[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_multiplejoinleft[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_multiplejoinleft[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_multiplejoinleft[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_multiplejoinleft[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

ts_fivejoinlefts = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinLeft)
@test propertynames(ts_fivejoinlefts.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fivejoinlefts[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_fivejoinlefts[:, :x1] == ts1[1:DATA_SIZE, :x1]
@test ts_fivejoinlefts[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_fivejoinlefts[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test ts_fivejoinlefts[:, :x1_3] == ts4[1:DATA_SIZE, :x1]
@test ts_fivejoinlefts[:, :x1_4] == ts5[1:DATA_SIZE, :x1]
@test isequal(Vector{Missing}(ts_fivejoinlefts[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))

# testing JoinRight
ts_joinright = join(ts1, ts2, JoinRight)
@test propertynames(ts_joinright.coredata) == [:Index, :x1, :x1_1]
@test ts_joinright[:, :Index] == ts1[1:Int(floor(DATA_SIZE/2)), :Index]
@test ts_joinright[:, :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test ts_joinright[:, :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]

ts_multiplejoinright = join(ts1, ts2, ts3; jointype=JoinRight)
@test propertynames(ts_multiplejoinright.coredata) == [:Index, :x1, :x1_1, :x1_2]
@test ts_multiplejoinright[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_multiplejoinright[1:Int(floor(DATA_SIZE/2)), :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_multiplejoinright[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))
@test ts_multiplejoinright[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_multiplejoinright[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))
@test ts_multiplejoinright[:, :x1_2] == ts3[1:DATA_SIZE, :x1]

ts_fivejoinrights = join(ts1, ts2, ts3, ts4, ts5; jointype=JoinRight)
@test propertynames(ts_fivejoinrights.coredata) == [:Index, :x1, :x1_1, :x1_2, :x1_3, :x1_4]
@test ts_fivejoinrights[:, :Index] == ts1[1:DATA_SIZE, :Index]
@test ts_fivejoinrights[1:Int(floor(DATA_SIZE/2)), :x1] == ts1[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_fivejoinrights[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))
@test ts_fivejoinrights[1:Int(floor(DATA_SIZE/2)), :x1_1] == ts2[1:Int(floor(DATA_SIZE/2)), :x1]
@test isequal(Vector{Missing}(ts_fivejoinrights[Int(floor(DATA_SIZE/2)) + 1:DATA_SIZE, :x1_1]), fill(missing, DATA_SIZE - Int(floor(DATA_SIZE/2))))
@test ts_fivejoinrights[:, :x1_2] == ts3[1:DATA_SIZE, :x1]
@test ts_fivejoinrights[:, :x1_3] == ts4[1:DATA_SIZE, :x1]
@test ts_fivejoinrights[:, :x1_4] == ts5[1:DATA_SIZE, :x1]