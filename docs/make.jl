using ImageProcessor
using Documenter

DocMeta.setdocmeta!(ImageProcessor, :DocTestSetup, :(using ImageProcessor); recursive=true)

makedocs(;
    modules=[ImageProcessor],
    authors="Dharik Arsath <dharikarsath12@gmail.com> and contributors",
    sitename="ImageProcessor.jl",
    format=Documenter.HTML(;
        canonical="https://dharik-arsath.github.io/ImageProcessor.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "docs" => "docs.md"
    ],
)

deploydocs(;
    repo="github.com/dharik-arsath/ImageProcessor.jl",
    devbranch="master",
)
