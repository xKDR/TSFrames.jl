using TSx
using Documenter

DocMeta.setdocmeta!(TSx, :DocTestSetup, :(using TSx); recursive=true)

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
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/xKDR/TSx.jl",
    devbranch="main",
    target = "build",
)
