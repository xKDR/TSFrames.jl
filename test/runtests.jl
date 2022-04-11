using TSx
using Test

@testset "TSx.jl" begin
    @testset "TS()" begin
        include("TS.jl")
    end
end
