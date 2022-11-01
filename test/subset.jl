# constants
MIDPOINT = Int(floor(DATA_SIZE/2))
FIRSTDATE = Date(2007, 1, 1)
MIDDATE = Date(2008, 1, 1)
LASTDATE = Date(2008, 2, 4)

# testing for integer index
ts_integer = TimeFrame(rand(DATA_SIZE), index_integer)

## subsetting from -1 to 0
ts_subset = TSx.subset(ts_integer, -1, 0)
@test TSx.nrow(TSx.subset(ts_integer, -1, 0)) == 0
@test TSx.nrow(TSx.subset(ts_integer, :, 0)) == 0

## subsetting from -1 to MIDPOINT
ts_subset = TSx.subset(ts_integer, -1, MIDPOINT)
@test TSx.nrow(ts_subset) == MIDPOINT
@test ts_subset[:, :Index] == 1:MIDPOINT
@test ts_subset[:, :x1] == ts_integer[1:MIDPOINT, :x1]
@test TSx.subset(ts_integer, :, MIDPOINT)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_integer, :, MIDPOINT)[:, :x1] == ts_subset[:, :x1]

## subsetting from MIDPOINT to DATA_SIZE
ts_subset = TSx.subset(ts_integer, MIDPOINT, DATA_SIZE)
@test TSx.nrow(ts_subset) == DATA_SIZE - MIDPOINT + 1
@test ts_subset[:, :Index] == MIDPOINT:DATA_SIZE
@test ts_subset[:, :x1] == ts_integer[MIDPOINT:DATA_SIZE, :x1]
@test TSx.subset(ts_integer, MIDPOINT, :)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_integer, MIDPOINT, :)[:, :x1] == ts_subset[:, :x1]

## subsetting from MIDPOINT to DATA_SIZE + 1
ts_subset = TSx.subset(ts_integer, MIDPOINT, DATA_SIZE + 1)
@test TSx.nrow(ts_subset) == DATA_SIZE - MIDPOINT + 1
@test ts_subset[:, :Index] == MIDPOINT:DATA_SIZE
@test ts_subset[:, :x1] == ts_integer[MIDPOINT:DATA_SIZE, :x1]
@test TSx.subset(ts_integer, MIDPOINT, :)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_integer, MIDPOINT, :)[:, :x1] == ts_subset[:, :x1]

## subsetting from DATA_SIZE + 1 to DATA_SIZE + 5
ts_subset = TSx.subset(ts_integer, DATA_SIZE + 1, DATA_SIZE + 5)
@test TSx.nrow(ts_subset) == 0
@test TSx.nrow(TSx.subset(ts_integer, DATA_SIZE + 1, :)) == 0

# testing for time index
ts_timetype = TimeFrame(rand(DATA_SIZE), index_timetype)

## subsetting from 2006-12-30 to 2006-12-31
@test TSx.nrow(TSx.subset(ts_timetype, Date(2006, 12, 30), Date(2006, 12, 31))) == 0
@test TSx.nrow(TSx.subset(ts_timetype, :, Date(2006, 12, 31))) == 0

## subsetting from 2006-12-31 to MIDDATE
ts_subset = TSx.subset(ts_timetype, Date(2006, 12, 31), MIDDATE)
@test TSx.nrow(ts_subset) == length(FIRSTDATE:Day(1):MIDDATE)
@test ts_subset[:, :Index] == FIRSTDATE:Day(1):MIDDATE
@test ts_subset[:, :x1] == ts_timetype[FIRSTDATE:Day(1):MIDDATE, :x1]
@test TSx.subset(ts_timetype, :, MIDDATE)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_timetype, :, MIDDATE)[:, :x1] == ts_subset[:, :x1]

## subsetting from MIDDATE to LASTDATE
ts_subset = TSx.subset(ts_timetype, MIDDATE, LASTDATE)
@test TSx.nrow(ts_subset) == length(MIDDATE:Day(1):LASTDATE)
@test ts_subset[:, :Index] == ts_timetype[MIDDATE:Day(1):LASTDATE, :Index]
@test ts_subset[:, :x1] == ts_timetype[MIDDATE:Day(1):LASTDATE, :x1]
@test TSx.subset(ts_timetype, MIDDATE, :)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_timetype, MIDDATE, :)[:, :x1] == ts_subset[:, :x1]

## subsetting from MIDDATE to LASTDATE + 5
ts_subset = TSx.subset(ts_timetype, MIDDATE, LASTDATE + Day(5))
@test TSx.nrow(ts_subset) == length(MIDDATE:Day(1):LASTDATE)
@test ts_subset[:, :Index] == ts_timetype[MIDDATE:Day(1):LASTDATE, :Index]
@test ts_subset[:, :x1] == ts_timetype[MIDDATE:Day(1):LASTDATE, :x1]
@test TSx.subset(ts_timetype, MIDDATE, :)[:, :Index] == ts_subset[:, :Index]
@test TSx.subset(ts_timetype, MIDDATE, :)[:, :x1] == ts_subset[:, :x1]


## subsetting from LASTDATE + 1 to LASTDATE + 5
ts_subset = TSx.subset(ts_timetype, LASTDATE + Day(1), LASTDATE + Day(5))
@test TSx.nrow(ts_subset) == 0
@test TSx.nrow(TSx.subset(ts_timetype, LASTDATE + Day(1), :)) == 0