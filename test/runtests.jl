using Dates
using DataFrames
using Random
using StatsBase
using Statistics
using Test
using Tables
using TSFrames

include("dataobjects.jl")

@testset "TSFrame()" begin
    include("TSFrame.jl")
end

@testset "getindex()" begin
    include("getindex.jl")
end

@testset "apply()" begin
    include("apply.jl")
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

@testset "broadcasting" begin
    include("broadcasting.jl")
end

@testset "getproperty" begin
    include("getproperty.jl")
end

@testset "diff" begin
    include("diff.jl")
end

@testset "lag" begin
    include("lag.jl")
end

@testset "lead" begin
    include("lead.jl")
end

@testset "pctchange" begin
    include("pctchange.jl")
end

@testset "subset" begin
    include("subset.jl")
end

@testset "matrix" begin
    include("matrix.jl")
end

@testset "vcat" begin
    include("vcat.jl")
end

@testset "join" begin
    include("join.jl")
end

@testset "Tables.jl" begin
    include("tables.jl")
end

@testset "rollapply()" begin
    include("rollapply.jl")
end
