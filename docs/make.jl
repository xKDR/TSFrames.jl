using TimeFrames
using Documenter

DocMeta.setdocmeta!(TimeFrames, :DocTestSetup, :(using TimeFrames, DataFrames, Dates, Statistics); recursive=true)

makedocs(;
    modules=[TimeFrames],
    authors="xKDR Forum",
    repo="https://github.com/xKDR/TimeFrames.jl/blob/{commit}{path}#{line}",
    sitename="TimeFrames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://xKDR.github.io/TimeFrames.jl",
        assets=String[],
    ),
    pages=[
        "Introduction" => "index.md",
        "Basic demo of TimeFrames" => "demo_finance.md",
        "User guide" => "user_guide.md",
        "API reference" => "api.md",
    ],
    doctest=false,               # TODO: switch to true in the version after v0.1.0
    strict=false,                # TODO: switch to true in the version after v0.1.0
)

deploydocs(;
    repo="github.com/xKDR/TimeFrames.jl",
    devbranch="main",
    target = "build",
)
