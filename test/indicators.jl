using MarketData

@testset "indicators_integration" begin
    sp500 = TSFrame(MarketData.yahoo("^GSPC"))
    date_from = Date(2021, 03, 1)
    date_to = Date(2023, 03, 1)
    sp500_2y = TSFrames.subset(sp500, date_from, date_to)
    @test sma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test runmean(sp500_2y, :Close) |> typeof == TSFrame
    @test trima(sp500_2y, :Close) |> typeof == TSFrame
    @test wma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test ema(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test mma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test dema(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test tema(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test mama(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test hma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test swma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test kama(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test alma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test zlema(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test hama(sp500_2y, :AdjClose) |> typeof == TSFrame
end