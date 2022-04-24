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
        "Tutorial" => "tutorial.md",
        "Functionality" => [
            "TS type" => "types.md",
            "Subsetting" => "subsetting.md",
            "Apply methods and period conversion" => "apply.md",
            "Time shifting" => "timeshift.md",
            "Iterated differences and percentages" => "diff.md",
            "Column and row binding (Joins)" => "join.md",
            "Logarithm" => "log.md",
            "Plotting" => "plots.md",
            "Displays" => "display.md",
            "Utilities" => "utils.md"
        ],
        "Finance demo" => "demo_finance.md",
        "Detailed guide to TSx" => "detailed_guide.md",
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
