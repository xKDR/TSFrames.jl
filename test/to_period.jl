dates = collect(Date(2007, 1, 2):Day(1):Date(2007, 7, 1));
tsdaily = TSFrame(random(length(dates)), dates);

datetimes = collect(DateTime(2007, 1, 2, 0):Millisecond(500):DateTime(2007, 1, 2, 1));
tsdatetimes = TSFrame(random(length(datetimes)), datetimes);

timestamps = collect(Time(0, 0, 0):Nanosecond(500):Time(0, 0, 0, 1));
tstimestamps = TSFrame(random(length(timestamps)), timestamps);

@test to_period(tsdaily, Month(1)) == tsdaily[endpoints(tsdaily, Month(1))]
@test to_period(tsdaily, Month(2)) == tsdaily[endpoints(tsdaily, Month(2))]

@test to_yearly(tsdaily, 1) == tsdaily[endpoints(tsdaily, Year(1))]
@test to_yearly(tsdaily, 2) == tsdaily[endpoints(tsdaily, Year(2))]

@test to_quarterly(tsdaily, 1) == tsdaily[endpoints(tsdaily, Quarter(1))]
@test to_quarterly(tsdaily, 2) == tsdaily[endpoints(tsdaily, Quarter(2))]

@test to_monthly(tsdaily, 1) == tsdaily[endpoints(tsdaily, Month(1))]
@test to_monthly(tsdaily, 2) == tsdaily[endpoints(tsdaily, Month(2))]

@test to_weekly(tsdaily, 1) == tsdaily[endpoints(tsdaily, Week(1))]
@test to_weekly(tsdaily, 2) == tsdaily[endpoints(tsdaily, Week(2))]

@test to_daily(tsdaily, 1) == tsdaily
@test to_daily(tsdaily, 2) == tsdaily[endpoints(tsdaily, Day(2))]

@test to_hourly(tsdatetimes, 1) == tsdatetimes[endpoints(tsdatetimes, Hour(1))]
@test to_hourly(tsdatetimes, 2) == tsdatetimes[endpoints(tsdatetimes, Hour(2))]

@test to_minutes(tsdatetimes, 1) == tsdatetimes[endpoints(tsdatetimes, Minute(1))]
@test to_minutes(tsdatetimes, 2) == tsdatetimes[endpoints(tsdatetimes, Minute(2))]

@test to_seconds(tsdatetimes, 1) == tsdatetimes[endpoints(tsdatetimes, Second(1))]
@test to_seconds(tsdatetimes, 2) == tsdatetimes[endpoints(tsdatetimes, Second(2))]

@test to_milliseconds(tsdatetimes, 1) == tsdatetimes
@test to_milliseconds(tsdatetimes, 2) == tsdatetimes[endpoints(tsdatetimes, Millisecond(2))]

@test to_microseconds(tstimestamps, 1) == tstimestamps[endpoints(tstimestamps, Microsecond(1))]
@test to_microseconds(tstimestamps, 2) == tstimestamps[endpoints(tstimestamps, Microsecond(2))]

@test to_nanoseconds(tstimestamps, 1) == tstimestamps
@test to_nanoseconds(tstimestamps, 2) == tstimestamps[endpoints(tstimestamps, Nanosecond(2))]
