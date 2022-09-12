using Dates
using DataFrames
using Random
using StatsBase
using Statistics
using Test
using TSx

include("dataobjects.jl")

@testset "TS()" begin
    include("TS.jl")
end

@testset "getindex()" begin
    include("getindex.jl")
end

@testset "index()" begin
    include("index.jl")
end

@testset "utils" begin
    include("utils.jl")
end

@testset "endpoints()" begin
    include("endpoints.jl")
end
