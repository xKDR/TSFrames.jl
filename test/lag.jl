# constants
date_from = Date(2022, 1, 1)
date_to = Date(2022, 5, 31)
dates = date_from:Day(1):date_to

ts = TS(rand(length(dates)), dates)

for lagby in 1:length(ts)
    lagged_ts = lag(ts, lagby)

    # test that Index remains the same
    @test isequal(lagged_ts[:, :Index], ts[:, :Index])
    
    # first lagby values are missing
    @test isequal(Vector{Missing}(lagged_ts[1:lagby, :x1]), fill(missing, lagby))

    # other elements are shifted
    isequal(lagged_ts[(lagby + 1):length(ts), :x1], ts[1:(length(ts) - lagby), :x1])
end

