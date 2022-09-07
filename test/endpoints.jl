dates = Date(2007, 1, 2):Day(1):Date(2007, 7, 1);
data_vector = random(length(dates));
ts = TS(data_vector, dates);

# errors
@test_throws ArgumentError endpoints(ts, :abc, 1)
@test_throws DomainError endpoints(ts, :days, -1)
@test_throws DomainError endpoints(ts, :days, 0)
@test_throws DomainError endpoints(ts, :Function, -1)
@test_throws DomainError endpoints(ts, :Function, 0)

@test endpoints(ts, :days, 1) == collect(1:TSx.nrow(ts))
@test endpoints(ts, :days, 2) == collect(2:2:TSx.nrow(ts))

@test endpoints(ts, :weeks, 1) == [6, 13, 20, 27, 34, 41, 48, 55, 62,
                                   69, 76, 83, 90, 97, 104, 111, 118,
                                   125, 132, 139, 146, 153, 160, 167,
                                   174, 181]

@test endpoints(ts, :weeks, 2) == [13, 27, 41, 55, 69, 83, 97, 111,
                                   125, 139, 153, 167, 181]

ep1 = endpoints(ts, :weeks, 2)[1]; @test dayofweek(index(ts)[ep1]) == 7
@test endpoints(ts, :weeks, 2)[end] == TSx.nrow(ts)

@test endpoints(ts, :months, 1) == [30, 58, 89, 119, 150, 180, 181]
@test endpoints(ts, :months, 2) == [58, 119, 180]

@test endpoints(ts, :quarters, 1) == [89, 180, 181]
@test endpoints(ts, :quarters, 2) == [180]
@test endpoints(ts, :quarters, 3) == [181]

@test endpoints(ts, :years, 1) == [181]
@test endpoints(ts, :years, 2) == Int64[]

# value of last monday, tuesday, etc.
@test endpoints(ts, i -> dayofweek.(i), 1) == [175, 176, 177, 178, 179, 180, 181]

ts = TS(1:7, [-3, -2, -1, 0, 1, 2, 3])
@test endpoints(ts, i -> i .^ 2, 1) == [4, 5, 6, 7]
@test endpoints(ts, i -> i .^ 2, 2) == [5, 7]
