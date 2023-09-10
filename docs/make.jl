using GenId
using Documenter

DocMeta.setdocmeta!(GenId, :DocTestSetup, :(using GenId); recursive=true)

makedocs(;
    modules=[GenId],
    authors="Plamen Stamov",
    repo="https://github.com/stamov/GenId.jl/blob/{commit}{path}#{line}",
    sitename="GenId.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://stamov.github.io/GenId.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/stamov/GenId.jl",
    devbranch="main",
)
