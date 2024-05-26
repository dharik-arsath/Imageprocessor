module ImageProcessor

    # Write your package code here.

    include("transforms/Transformations.jl")
    using .Transformations
    export min_max, standardize, threshold, adaptive_threshold, box_blur, pad,euclidean_threshold

    include("measures/Measures.jl")
    using .Measures 
    export mse, mae, mle
end
