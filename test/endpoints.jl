##
# Sample data sets
##

## ::Date
dates = collect(Date(2007, 1, 2):Day(1):Date(2007, 7, 1));
tsdaily = TS(random(length(dates)), dates);

dates5 = collect(Date(2007, 1, 2):Day(5):Date(2007, 7, 1));

## ::DateTime
datetimes = collect(DateTime(2007, 1, 2):Day(1):DateTime(2007, 7, 1));
tsdatetimes = TS(random(length(datetimes)), datetimes);

## ::Integer
indexinteger = [-3, -2, -1, 0, 1, 2, 3];
tsinteger = TS(collect(1:7), indexinteger);

## ::DateTime (Hour)
datetimehours = collect(range(DateTime(today()),
                              DateTime(today()) + Day(2),
                              step = Hour(1)));
tshours = TS(random(length(datetimehours)), datetimehours);

## ::DateTime (Minute)
datetimeminutes = collect(range(DateTime(today()) + Hour(9),
                                DateTime(today()) + Hour(15) + Minute(29),
                                step=Minute(1)));
tsminutes = TS(random(length(datetimeminutes)), datetimeminutes);

## ::DateTime (Second)
datetimeseconds = collect(range(DateTime(today()) + Hour(9),
                                DateTime(today()) + Hour(15) + Minute(29),
                                step=Second(1)));
tsseconds = TS(random(length(datetimeseconds)), datetimeseconds);

## ::DateTime (Second(10))
datetime10seconds = collect(range(DateTime(today()) + Hour(9),
                                  DateTime(today()) + Hour(9) + Minute(2),
                                  step=Second(10)));

## ::DateTime (Millisecond)
datetimemilliseconds = collect(range(DateTime(today()) + Hour(9),
                                     DateTime(today()) + Hour(9) + Minute(59),
                                     step=Millisecond(500)));
tsmilliseconds = TS(random(length(datetimemilliseconds)), datetimemilliseconds);

## ::Time (Hour)
timestampshours = collect(Time(9, 0, 0):Hour(1):Time(15, 0, 0))

## ::Time (Minute)
timestampsminutes = collect(Time(9, 1, 2):Minute(1):Time(11, 2, 3))

## ::Time (Second)
timestampsseconds = collect(Time(9, 0, 0):Second(1):Time(10, 0, 0))

## ::Time (Millisecond)
timestampsmilliseconds = collect(Time(9, 0, 0):Millisecond(1):Time(9, 0, 2))

## ::Time (Microsecond)
timestampsmicroseconds = collect(Time(9, 0, 0):Microsecond(1):Time(9, 0, 0, 2))

## ::Time (Nanosecond)
timestampsnanoseconds = collect(Time(9, 0, 0):Nanosecond(1):Time(9, 0, 0, 0, 2))

##
# endpoints(values::AbstractVector, on::Function, k::Int=1)
##
@test_throws DomainError endpoints(collect(1:10), i -> i .^ 2, 0)
@test_throws DomainError endpoints(collect(1:10), i -> i .^ 2, -1)
# value of last monday, last, tuesday, etc.
@test endpoints(dates, i -> dayofweek.(i), 1) == [175, 176, 177, 178, 179, 180, 181]
@test endpoints(indexinteger, i -> i .^ 2, 1) == [4, 5, 6, 7]
@test endpoints(indexinteger, i -> i .^ 2, 2) == [5, 7]

##
# endpoints(ts::TS, on::Function, k::Int=1)
##
@test_throws DomainError endpoints(tsdaily, i -> dayofweek.(i), -1)
@test_throws DomainError endpoints(tsdaily, i -> dayofweek.(i), 0)
@test endpoints(tsdaily, i -> dayofweek.(i), 1) == endpoints(index(tsdaily), i -> dayofweek.(i), 1)
@test endpoints(tsdaily, i -> dayofweek.(i), 1) == [175, 176, 177, 178, 179, 180, 181]
@test endpoints(tsinteger, i -> i .^  2, 1) == [4, 5, 6, 7]
@test endpoints(tsinteger, i -> i .^ 2, 2) == [5, 7]

## Error cases
# ::Date, <:TimePeriod
@test_throws ArgumentError endpoints(tsdaily, Hour(1))
@test_throws ArgumentError endpoints(tsdaily, Minute(1))
# ::DateTime, ::Union{Microsecond, Nanosecond}
@test_throws ArgumentError endpoints(datetimehours, Microsecond(1))
@test_throws ArgumentError endpoints(datetimehours, Nanosecond(1))
# ::Time, <: DatePeriod
@test_throws ArgumentError endpoints(timestampshours, Day(1))
@test_throws ArgumentError endpoints(timestampshours, Year(1))


##
# endpoints(dates::AbstractVector{T}, on::Year) where {T<:Union{Date, DateTime}}
##
@test endpoints(dates, Year(1)) == [181]
@test endpoints(dates, Year(2)) == [181]
@test endpoints(datetimes, Year(1)) == [181]
@test endpoints(datetimes, Year(2)) == [181]

@test endpoints(dates5, Year(1)) == [lastindex(dates5)]

##
# endpoints(dates::AbstractVector{T}, on::Quarter) where {T<:Union{Date, DateTime}}
##
@test endpoints(dates, Quarter(1)) == [89, 180, 181]
@test endpoints(dates, Quarter(2)) == [180, 181]
@test endpoints(dates, Quarter(3)) == [181]
@test endpoints(dates, Quarter(4)) == [181]
@test endpoints(datetimes, Quarter(1)) == [89, 180, 181]
@test endpoints(datetimes, Quarter(2)) == [180, 181]
@test endpoints(datetimes, Quarter(3)) == [181]
@test endpoints(datetimes, Quarter(4)) == [181]

@test endpoints(dates5, Quarter(1)) == [18, 36, 37]
@test endpoints(dates5, Quarter(2)) == [36, 37]
@test endpoints(dates5, Quarter(3)) == [37]

##
# endpoints(dates::AbstractVector{T}, on::Month) where {T<:Union{Date, DateTime}}
##
@test endpoints(dates, Month(1)) == [30, 58, 89, 119, 150, 180, 181]
@test endpoints(dates, Month(2)) == [58, 119, 180, 181]
@test endpoints(dates, Month(7)) == [181]
@test endpoints(dates, Month(8)) == [181]
@test endpoints(datetimes, Month(1)) == [30, 58, 89, 119, 150, 180, 181]
@test endpoints(datetimes, Month(2)) == [58, 119, 180, 181]
@test endpoints(datetimes, Month(7)) == [181]
@test endpoints(datetimes, Month(8)) == [181]

@test endpoints(dates5, Month(1)) == [6, 12, 18, 24, 30, 36, 37]
@test endpoints(dates5, Month(2)) == [12, 24, 36, 37]
@test endpoints(dates5, Month(8)) == [37]

##
# endpoints(dates::AbstractVector{T}, on::Week) where {T<:Union{Date, DateTime}}
##
@test endpoints(dates, Week(1)) == [6, 13, 20, 27, 34, 41, 48, 55, 62,
                                    69, 76, 83, 90, 97, 104, 111, 118,
                                    125, 132, 139, 146, 153, 160, 167,
                                    174, 181]
@test endpoints(dates, Week(2)) == [13, 27, 41, 55, 69, 83, 97, 111,
                                    125, 139, 153, 167, 181]
ep1 = endpoints(dates, Week(2))[1];
@test dayofweek(dates[ep1]) == 7
@test endpoints(dates, Week(2))[end] == length(dates) # last endpoint is the last element of dates
@test endpoints(datetimes, Week(1)) == [6, 13, 20, 27, 34, 41, 48, 55, 62,
                                    69, 76, 83, 90, 97, 104, 111, 118,
                                    125, 132, 139, 146, 153, 160, 167,
                                    174, 181]
@test endpoints(datetimes, Week(2)) == [13, 27, 41, 55, 69, 83, 97, 111,
                                    125, 139, 153, 167, 181]
ep1 = endpoints(datetimes, Week(2))[1];
@test dayofweek(datetimes[ep1]) == 7
@test endpoints(datetimes, Week(2))[end] == length(datetimes) # last endpoint is the last element of datetimes

##
# endpoints(dates::AbstractVector{T}, on::Day) where {T<:Union{Date, DateTime}}
##
@test endpoints(dates, Day(1)) == collect(1:TSx.nrow(tsdaily))
@test endpoints(dates, Day(2)) == [collect(2:2:TSx.nrow(tsdaily))..., 181]
@test endpoints(datetimes, Day(1)) == collect(1:TSx.nrow(tsdaily))
@test endpoints(datetimes, Day(2)) == [collect(2:2:TSx.nrow(tsdaily))..., 181]
@test endpoints(datetimehours, Day(1)) == [24, 48, 49]

##
# endpoints(datetimes::AbstractVector{DateTime}, on::Hour)
##
# Hour to Hour
@test endpoints(datetimehours, Hour(1)) == collect(1:length(datetimehours))
@test endpoints(datetimehours, Hour(2)) == collect([2:2:length(datetimehours)..., lastindex(datetimehours)])
@test endpoints(datetimehours, Hour(24)) == [24, 48, 49]
@test endpoints(datetimehours, Hour(length(datetimehours)+1)) == [lastindex(datetimehours)]
# Minute to Hour
@test endpoints(datetimeminutes, Hour(1)) == [60, 120, 180, 240, 300, 360, 390]
@test endpoints(datetimeminutes, Hour(2)) == [120, 240, 360, 390]
@test endpoints(datetimeminutes, Hour(7)) == [390]
@test endpoints(datetimeminutes, Hour(8)) == [390]
# Hour to Minute
@test endpoints(datetimehours, Minute(1)) == collect(1:length(datetimehours))
@test endpoints(datetimehours, Minute(2)) == collect(1:length(datetimehours))

##
# endpoints(datetimes::AbstractVector{DateTime}, on::Minute)
##

# Minute to Minute
@test endpoints(datetimeminutes, Minute(1)) == collect(1:length(datetimeminutes))
@test endpoints(datetimeminutes, Minute(2)) == collect(2:2:length(datetimeminutes))
@test endpoints(datetimeminutes, Minute(59)) == [59, 118, 177, 236, 295, 354, 390]
@test endpoints(datetimeminutes, Minute(60)) == endpoints(datetimeminutes, Hour(1))
@test endpoints(datetimeminutes, Minute(600)) == [390]

# Second to Minute
@test endpoints(datetimeseconds, Minute(1)) == [collect(range(60, 6*60*60 + 29*60, step=60))..., length(datetimeseconds)]
@test endpoints(datetimeseconds, Minute(2)) == [collect(range(120, 6*60*60 + 29*60, step=120))..., length(datetimeseconds)]
@test endpoints(datetimeseconds, Minute(60)) == endpoints(datetimeseconds, Hour(1))
@test endpoints(datetimeseconds, Minute(length(datetimeseconds) + 1)) == [length(datetimeseconds)]

##
# endpoints(datetimes::AbstractVector{T}, on::Second) where {T<:Union{Date, DateTime}}
##

# Second to Second
@test endpoints(datetimeseconds, Second(1)) == collect(1:length(datetimeseconds))
@test endpoints(datetimeseconds, Second(2)) == collect([2:2:length(datetimeseconds)..., lastindex(datetimeseconds)])
@test endpoints(datetimeseconds, Second(59)) == collect([59:59:length(datetimeseconds)..., lastindex(datetimeseconds)])
@test endpoints(datetimeseconds, Second(60)) == endpoints(datetimeseconds, Minute(1))
@test endpoints(datetimeseconds, Second(length(datetimeseconds) + 1)) == [length(datetimeseconds)]

# Millisecond to Second
@test endpoints(datetimemilliseconds, Second(1)) == [collect(range(2, 59*60*2, step=2))..., length(datetimemilliseconds)]
@test endpoints(datetimemilliseconds, Second(2)) == [collect(range(4, 59*60*2, step=4))..., length(datetimemilliseconds)]
@test endpoints(datetimemilliseconds, Second(60)) == endpoints(datetimemilliseconds, Minute(1))
@test endpoints(datetimemilliseconds, Second(3600 - 60)) == [7080, 7081]

# Periodicity > 1
@test endpoints(datetime10seconds, Second(1)) == collect(1:length(datetime10seconds))
@test endpoints(datetime10seconds, Second(2)) == collect(1:length(datetime10seconds))
@test endpoints(datetime10seconds, Second(10)) == collect(1:length(datetime10seconds))
@test endpoints(datetime10seconds, Second(20)) == collect([2:2:length(datetime10seconds)..., lastindex(datetime10seconds)])
@test endpoints(datetime10seconds, Minute(1)) == [collect(6:6:length(datetime10seconds))..., lastindex(datetime10seconds)]
@test endpoints(datetime10seconds, Second(60)) == endpoints(datetime10seconds, Minute(1))

##
# endpoints(timestamps::AbstractVector{Time}, on::Hour)
##
@test endpoints(timestampshours, Hour(1)) == collect(1:length(timestampshours))
@test endpoints(timestampshours, Hour(2)) == [2, 4, 6, 7]
@test endpoints(timestampshours, Hour(length(timestampshours) + 1)) == [lastindex(timestampshours)]

##
# endpoints(timestamps::AbstractVector{Time}, on::Minute)
##
# Minute to Hour
@test endpoints(timestampsminutes, Hour(1)) == [59, 119, lastindex(timestampsminutes)]
@test endpoints(timestampsminutes, Hour(2)) == [119, lastindex(timestampsminutes)]

# Minute to Minute
@test endpoints(timestampsminutes, Minute(1)) == collect(1:length(timestampsminutes))
@test endpoints(timestampsminutes, Minute(2)) == collect(2:2:length(timestampsminutes))
@test endpoints(timestampsminutes, Minute(59)) == collect([59:59:length(timestampsminutes)..., lastindex(timestampsminutes)])
@test endpoints(timestampsminutes, Minute(60)) == [60, 120, 122] # Note: every 60 minutes != every 1 hour
@test endpoints(timestampsminutes, Minute(length(timestampsminutes) + 1)) == [lastindex(timestampsminutes)]

##
# endpoints(timestamps::AbstractVector{Time}, on::Second)
##
# Second to Minute
@test endpoints(timestampsseconds, Minute(1)) == collect([60:60:length(timestampsseconds)..., lastindex(timestampsseconds)])
@test endpoints(timestampsseconds, Minute(2)) == collect([120:120:length(timestampsseconds)..., lastindex(timestampsseconds)])
@test endpoints(timestampsseconds, Minute(60)) == [lastindex(timestampsseconds) - 1, lastindex(timestampsseconds)]

# Second to Second
@test endpoints(timestampsseconds, Second(1)) == collect(1:length(timestampsseconds))
@test endpoints(timestampsseconds, Second(2)) == collect([2:2:length(timestampsseconds)..., lastindex(timestampsseconds)])
@test endpoints(timestampsseconds, Second(59)) == collect([59:59:length(timestampsseconds)..., lastindex(timestampsseconds)])
@test endpoints(timestampsseconds, Second(60)) == endpoints(timestampsseconds, Minute(1))
@test endpoints(timestampsseconds, Second(length(timestampsseconds) + 1)) == [lastindex(timestampsseconds)]

##
# endpoints(timestamps::AbstractVector{Time}, on::Millisecond)
##
# Millisecond to Second
@test endpoints(timestampsmilliseconds, Second(1)) == collect([1000:1000:length(timestampsmilliseconds)..., lastindex(timestampsmilliseconds)])
@test endpoints(timestampsmilliseconds, Second(2)) == [lastindex(timestampsmilliseconds) - 1, lastindex(timestampsmilliseconds)]

# Millisecond to Millisecond
@test endpoints(timestampsmilliseconds, Millisecond(1)) == collect(1:length(timestampsmilliseconds))
@test endpoints(timestampsmilliseconds, Millisecond(2)) == collect([2:2:length(timestampsmilliseconds)..., lastindex(timestampsmilliseconds)])
@test endpoints(timestampsmilliseconds, Millisecond(999)) == collect([999:999:length(timestampsmilliseconds)..., lastindex(timestampsmilliseconds)])
@test endpoints(timestampsmilliseconds, Millisecond(1000)) == endpoints(timestampsmilliseconds, Second(1))
@test endpoints(timestampsmilliseconds, Millisecond(length(timestampsmilliseconds) + 1)) == [lastindex(timestampsmilliseconds)]

##
# endpoints(timestamps::AbstractVector{Time}, on::Microsecond)
##
# Microsecond to Second
@test endpoints(timestampsmicroseconds, Millisecond(1)) == collect([1000:1000:length(timestampsmicroseconds)..., lastindex(timestampsmicroseconds)])
@test endpoints(timestampsmicroseconds, Millisecond(2)) == [lastindex(timestampsmicroseconds) - 1, lastindex(timestampsmicroseconds)]

# Microsecond to Microsecond
@test endpoints(timestampsmicroseconds, Microsecond(1)) == collect(1:length(timestampsmicroseconds))
@test endpoints(timestampsmicroseconds, Microsecond(2)) == collect([2:2:length(timestampsmicroseconds)..., lastindex(timestampsmicroseconds)])
@test endpoints(timestampsmicroseconds, Microsecond(999)) == collect([999:999:length(timestampsmicroseconds)..., lastindex(timestampsmicroseconds)])
@test endpoints(timestampsmicroseconds, Microsecond(1000)) == endpoints(timestampsmicroseconds, Millisecond(1))
@test endpoints(timestampsmicroseconds, Microsecond(length(timestampsmicroseconds) + 1)) == [lastindex(timestampsmicroseconds)]

##
# endpoints(timestamps::AbstractVector{Time}, on::Nanosecond)
##
# Nanosecond to Microsecond
@test endpoints(timestampsnanoseconds, Microsecond(1)) == collect([1000:1000:length(timestampsnanoseconds)..., lastindex(timestampsnanoseconds)])
@test endpoints(timestampsnanoseconds, Microsecond(2)) == [lastindex(timestampsnanoseconds) - 1, lastindex(timestampsnanoseconds)]

# Nanosecond to Nanosecond
@test endpoints(timestampsnanoseconds, Nanosecond(1)) == collect(1:length(timestampsnanoseconds))
@test endpoints(timestampsnanoseconds, Nanosecond(2)) == collect([2:2:length(timestampsnanoseconds)..., lastindex(timestampsnanoseconds)])
@test endpoints(timestampsnanoseconds, Nanosecond(999)) == collect([999:999:length(timestampsnanoseconds)..., lastindex(timestampsnanoseconds)])
@test endpoints(timestampsnanoseconds, Nanosecond(1000)) == endpoints(timestampsnanoseconds, Microsecond(1))
@test endpoints(timestampsnanoseconds, Nanosecond(length(timestampsnanoseconds) + 1)) == [lastindex(timestampsnanoseconds)]

# Irregular series
datetimesecondsrandom = sample(MersenneTwister(123), datetimeseconds, 20, replace=false, ordered=true)
@test endpoints(datetimesecondsrandom, Minute(1)) == [1, 2, 3, 4, 5, 6, 7, 8, 10, 11,
                                                      12, 13, 14, 15, 16, 17, 18, 19,
                                                      20]
@test endpoints(datetimesecondsrandom, Minute(20)) == [2, 3, 5, 6, 8, 11, 12, 13, 15, 18, 19, 20]
@test endpoints(datetimesecondsrandom, Hour(1)) == [3, 6, 11, 13, 18, 20]


##
# endpoints(ts::TS, on::T) where {T<:Period}
##
@test endpoints(tsdaily, Day(1)) == endpoints(dates, Day(1))
@test endpoints(tsdaily, Month(1)) == endpoints(dates, Month(1))

##
# endpoints(ts::TS, on::Symbol, k::Int=1)
##
@test_throws MethodError endpoints(tsinteger, :years, 1) # non TimeType index should throw an error
@test_throws ArgumentError endpoints(tsdaily, :abc, 1)
@test_throws DomainError endpoints(tsdaily, :days, 0)
@test_throws DomainError endpoints(tsdaily, :days, -1)
@test endpoints(tsdaily, :days, 1) == endpoints(tsdaily, Day(1))

##
# endpoints(ts::TS, on::String, k::Int=1)
##
@test endpoints(tsdaily, "days", 1) == endpoints(tsdaily, :days, 1)
