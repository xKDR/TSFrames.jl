###
# Test _check_consistency()
###
ts = TS(data_vector, 1:length(data_vector));
@test TSx._check_consistency(ts) == true

ts.coredata.Index = sample(index_integer, length(data_vector), replace=true);
@test TSx._check_consistency(ts) == false
####

function test_isregular()
    random(x) = rand(MersenneTwister(123), x)

    dates_day = collect(Date(2017,1,1):Day(1):Date(2017,1,10))
    dates_month = collect(Date(2017,1,1):Month(1):Date(2017,10,1))
    dates_rep = fill(Date(2017,1,1), 10)
    dates_rand = copy(dates_day)
    dates_rand[2] = Date(2017,10,9)
    dates_rand[4] = Date(2017, 7,27)
    dates_rand[7] = Date(2018,11,11)
    dates_eq = copy(dates_day)
    dates_eq[10] = Date(2017,1,9)

    ts_day = TS(random(10), dates_day)
    ts_month = TS(random(10), dates_month)
    ts_rep = TS(random(10), dates_rep)
    ts_rand = TS(random(10), dates_rand)
    ts_eq = TS(random(10), dates_eq)

    @test isregular(dates_rand) == false
    @test isregular(dates_eq) == false
    @test isregular(dates_month) == false
    @test isregular(dates_rep) == true
    @test isregular(dates_day) == true

    @test isregular(dates_day, Day(2)) == false
    @test isregular(dates_day, Month(1)) == false
    @test isregular(dates_month, Day(1)) == false
    @test isregular(dates_month, Month(1)) == false
    @test isregular(dates_rand, Day(1)) == false
    @test isregular(dates_rand, Month(1)) == false
    @test isregular(dates_eq, Day(1)) == false
    @test isregular(dates_rep, Month(1)) == false
    @test isregular(dates_day, Day(1)) == true
    @test isregular(dates_rep, Day(0)) == true

    @test isregular(ts_month) == false
    @test isregular(ts_rand) == false
    @test isregular(ts_eq) == false
    @test isregular(ts_day) == true
    @test isregular(ts_rep) == true

    @test isregular(ts_day, Day(2)) == false
    @test isregular(ts_day, Month(1)) == false
    @test isregular(ts_month, Day(1)) == false
    @test isregular(ts_month, Month(1)) == false
    @test isregular(ts_rand, Day(1)) == false
    @test isregular(ts_rand, Month(1)) == false
    @test isregular(ts_eq, Day(1)) == false
    @test isregular(ts_rep, Month(1)) == false
    @test isregular(ts_day, Day(1)) == true
    @test isregular(ts_rep, Day(0)) == true
end

# Run each test
# NOTE: Do not forget to add any new test-function created above
# otherwise that test won't run.
test_isregular()
