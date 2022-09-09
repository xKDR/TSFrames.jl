# errors
@test_throws ArgumentError endpoints(ts, :abc, 1)
@test_throws DomainError endpoints(ts, :days, -1)
@test_throws DomainError endpoints(ts, :days, 0)
@test_throws DomainError endpoints(ts, :Function, -1)
@test_throws DomainError endpoints(ts, :Function, 0)

dates = Date(2007, 1, 2):Day(1):Date(2007, 7, 1);
data_vector = random(length(dates));
ts = TS(data_vector, dates);

@test endpoints(ts, :days, 1) == collect(1:TSx.nrow(ts))
@test endpoints(ts, :days, 2) == [collect(2:2:TSx.nrow(ts))..., 181]

@test endpoints(ts, :weeks, 1) == [6, 13, 20, 27, 34, 41, 48, 55, 62,
                                   69, 76, 83, 90, 97, 104, 111, 118,
                                   125, 132, 139, 146, 153, 160, 167,
                                   174, 181]

@test endpoints(ts, :weeks, 2) == [13, 27, 41, 55, 69, 83, 97, 111,
                                   125, 139, 153, 167, 181]

ep1 = endpoints(ts, :weeks, 2)[1]; @test dayofweek(index(ts)[ep1]) == 7
@test endpoints(ts, :weeks, 2)[end] == TSx.nrow(ts)

@test endpoints(ts, :months, 1) == [30, 58, 89, 119, 150, 180, 181]
@test endpoints(ts, :months, 2) == [58, 119, 180, 181]
@test endpoints(ts, :months, 7) == [181]
@test endpoints(ts, :months, 8) == []

@test endpoints(ts, :quarters, 1) == [89, 180, 181]
@test endpoints(ts, :quarters, 2) == [180, 181]
@test endpoints(ts, :quarters, 3) == [181]
@test endpoints(ts, :quarters, 4) == []

@test endpoints(ts, :years, 1) == [181]
@test endpoints(ts, :years, 2) == []

# Intraday
timestamps = range(DateTime(today()) + Hour(9),
                   DateTime(today()) + Hour(15) + Minute(29),
                   step=Minute(1))
tsintra = TS(random(length(timestamps)), timestamps);

@test endpoints(tsintra, :hours, 1) == [60, 120, 180, 240, 300, 360, 390]
@test endpoints(tsintra, :hours, 2) == [120, 240, 360, 390]
@test endpoints(tsintra, :hours, 7) == [390]
@test endpoints(tsintra, :hours, 8) == []

timestamps = range(DateTime(today()) + Hour(9),
                   DateTime(today()) + Hour(15) + Minute(29),
                   step=Second(1))
tsintra = TS(random(length(timestamps)), timestamps);

@test endpoints(tsintra, :minutes, 1) == [collect(range(60, 6*60*60 + 29*60, step=60))..., length(tsintra)]
@test endpoints(tsintra, :minutes, 2) == [collect(range(120, 6*60*60 + 29*60, step=120))..., length(tsintra)]
@test endpoints(tsintra, :minutes, 60) == endpoints(tsintra, :hours, 1)
@test endpoints(tsintra, :minutes, length(tsintra) + 1) == []

timestamps = range(DateTime(today()) + Hour(9),
                   DateTime(today()) + Hour(9) + Minute(59),
                   step=Millisecond(500))
tsintra = TS(random(length(timestamps)), timestamps);

@test endpoints(tsintra, :seconds, 1) == [collect(range(2, 59*60*2, step=2))..., length(tsintra)]
@test endpoints(tsintra, :seconds, 2) == [collect(range(4, 59*60*2, step=4))..., length(tsintra)]
@test endpoints(tsintra, :seconds, 60) == endpoints(tsintra, :minutes, 1)
@test endpoints(tsintra, :seconds, 3600 - 60) == [7080, 7081]
@test endpoints(tsintra, :seconds, length(tsintra) + 1) == []

# value of last monday, last, tuesday, etc.
@test endpoints(ts, i -> dayofweek.(i), 1) == [175, 176, 177, 178, 179, 180, 181]

ts = TS(1:7, [-3, -2, -1, 0, 1, 2, 3]);
@test endpoints(ts, i -> i .^ 2, 1) == [4, 5, 6, 7]
@test endpoints(ts, i -> i .^ 2, 2) == [5, 7]
