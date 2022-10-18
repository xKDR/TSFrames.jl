# constants
DATA_SIZE = 360
dates = Date(2000, 1,1) + Day.(0:(DATA_SIZE - 1))

ts = TS(rand(1:100, DATA_SIZE), dates)

# lagging by something atmost DATA_SIZE
for lagby in [0, floor(Int(DATA_SIZE/2)), DATA_SIZE]
    lagged_ts = lag(ts, lagby)

    # test that Index remains the same
    @test isequal(lagged_ts[:, :Index], ts[:, :Index])

    # first lagby values are missing
    @test isequal(Vector{Missing}(lagged_ts[1:lagby, :x1]), fill(missing, lagby))

    # other elements are shifted
    isequal(lagged_ts[(lagby + 1):length(ts), :x1], ts[1:(length(ts) - lagby), :x1])
end

# lagging by something greater than DATA_SIZE
lagged_ts = lag(ts, DATA_SIZE + 5)
@test isequal(lagged_ts[:, :Index], ts[:, :Index])
@test isequal(Vector{Missing}(lagged_ts[1:DATA_SIZE, :x1]), fill(missing, DATA_SIZE))