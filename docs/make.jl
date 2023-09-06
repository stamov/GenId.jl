using GenId
using Documenter

DocMeta.setdocmeta!(GenId, :DocTestSetup, :(using GenId); recursive=true)

makedocs(;
    modules=[GenId],
    authors="Plamen Stamov",
    repo="https://github.com/plamen.stamov@gmail.com/GenId.jl/blob/{commit}{path}#{line}",
    sitename="GenId.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://plamen.stamov@gmail.com.github.io/GenId.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/plamen.stamov@gmail.com/GenId.jl",
    devbranch="main",
)
