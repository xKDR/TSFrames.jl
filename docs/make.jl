using TSFrames
using Documenter

DocMeta.setdocmeta!(TSFrames, :DocTestSetup, :(using TSFrames, DataFrames, Dates, Statistics); recursive=true)

makedocs(;
    modules=[TSFrames],
    authors="xKDR Forum",
    repo="https://github.com/xKDR/TSFrames.jl/blob/{commit}{path}#{line}",
    sitename="TSFrames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://xKDR.github.io/TSFrames.jl",
        assets=String[],
    ),
    pages=[
        "Introduction" => "index.md",
        "Basic demo of TSFrames" => "demo_finance.md",
        "User guide" => "user_guide.md",
        "API reference" => "api.md",
    ],
    doctest=false,               # TODO: switch to true in the version after v0.1.0
    strict=false,                # TODO: switch to true in the version after v0.1.0
)

deploydocs(;
    repo="github.com/xKDR/TSFrames.jl",
    devbranch="main",
    target = "build",
)
