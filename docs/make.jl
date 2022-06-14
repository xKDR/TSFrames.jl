using TSx
using Documenter

DocMeta.setdocmeta!(TSx, :DocTestSetup, :(using TSx, DataFrames, Dates, Statistics); recursive=true)

makedocs(;
    modules=[TSx],
    authors="xKDR Forum",
    repo="https://github.com/xKDR/TSx.jl/blob/{commit}{path}#{line}",
    sitename="TSx.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://xKDR.github.io/TSx.jl",
        assets=String[],
    ),
    pages=[
        "Introduction" => "index.md",
        "Basic demo of TSx" => "demo_finance.md",
        "User guide" => "user_guide.md",
        "API reference" => "api.md",
    ],
    doctest=false,               # TODO: switch to true in the version after v0.1.0
    strict=false,                # TODO: switch to true in the version after v0.1.0
)

deploydocs(;
    repo="github.com/xKDR/TSx.jl",
    devbranch="main",
    target = "build",
)
