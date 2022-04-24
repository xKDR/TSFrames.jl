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
        "API reference" => [
            "TS type" => "api/types.md",
            # "Subsetting" => "api/subsetting.md",
            # "Apply methods" => "api/apply.md",
            # "Time shifting" => "api/timeshift.md",
            # "Iterated differences and percentages" => "api/diff.md",
            # "Column and row binding (Joins)" => "api/joins.md",
            # "Logarithm" => "api/log.md",
            # "Plotting" => "api/plots.md",
            # "Displays" => "api/display.md",
            # "Utilities" => "api/utils.md",
            "All methods" => "api/api.md",
        ],
        # "Finance demo" => "demo_finance.md",
        # "Detailed guide to TSx" => "detailed_guide.md",

    ],
    doctest=false,               # TODO: switch to true in the version after v0.1.0
    strict=false,                # TODO: switch to true in the version after v0.1.0
)

deploydocs(;
    repo="github.com/xKDR/TSx.jl",
    devbranch="main",
    target = "build",
)
