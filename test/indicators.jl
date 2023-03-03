using MarketData

@testset "indicators_integration" begin
    sp500 = TSFrame(MarketData.yahoo("^GSPC"))
    date_from = Date(2021, 03, 1)
    date_to = Date(2023, 03, 1)
    sp500_2y = TSFrames.subset(sp500, date_from, date_to)
    @test sma(sp500_2y, :AdjClose) |> typeof == TSFrame
    @test runmean(sp500_2y, :Close) |> typeof == TSFrame 
end