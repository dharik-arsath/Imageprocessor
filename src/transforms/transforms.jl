using FileIO
using Images
using Statistics
using ImageProcessor
import ImageDistances as img_dist

"""
(X - X_Min) / (X_MAX / X_MIN )
"""
function min_max(img)
    x_min = minimum(img)
    x_max = maximum(img)

    return @. (img - x_min) / (x_max - x_min)
end 

"""
(X - μ) / σ

where μ = mean 
      σ = standard deviation
"""
function standardize(img)
    μ = mean(img)
    σ = std(img)

    return @. (img - μ) / σ 
end

"""
Simple Threshold
"""
function threshold(img, thresh_val)
    return colorview( Gray, map(x -> x > thresh_val ? 1.0 : 0.0, img) )
end 

"""
Adaptive Threshold
"""
function adaptive_threshold(img, block_size)
    out = similar(img)
    height, width = size(img)
    half_block = block_size ÷ 2 

    for row in 1:height
        for col in 1:width 
            row_start = max(1, row - half_block)
            row_end = min(height, row + half_block)
            col_start = max(1, col - half_block)
            col_end = min(width, col + half_block)
            
            img_view = @view img[row_start: row_end, col_start: col_end]
            local_mean = mean(img_view)

            out[row, col] = img[row, col] > local_mean ? 1.0 : 0.0
        end 
    end
    return out 
end


"""
Box Blur
"""
function box_blur(img, block_size)
    out = similar(img)
    height, width = size(img)
    half_block = block_size ÷ 2 

    for row in 1:height
        for col in 1:width 
            row_start = max(1, row - half_block)
            row_end = min(height, row + half_block)
            col_start = max(1, col - half_block)
            col_end = min(width, col + half_block)
            
            img_view = @view img[row_start: row_end, col_start: col_end]
            local_mean = mean(img_view)

            out[row, col] = local_mean 
        end 
    end
    return out 
end

function pad(img, pad_height, pad_width, pad_value=0)
    height, width = size(img)
    padded_height = height + 2 * pad_height
    padded_width = width + 2 * pad_width

    # Create a padded image initialized to 0
    # out = Matrix{eltype(img)}(0, padded_height, padded_width)
    out = fill(N0f8(pad_value), padded_height, padded_width)
    # Copy the original image into the center of the padded image
    for row in 1:height
        for col in 1:width
            out[row + pad_height, col + pad_width] = img[row, col]
        end
    end

    return colorview(Gray, out )
end


function euclidean_threshold(img, thresh_val, ref_color)
    distances = @. sqrt(( img - ref_color ) ^ 2)
    return colorview( Gray, map(x -> x > thresh_val ? 1.0 : 0.0, distances) )
end 


# Function to match template (unchanged)
function match_template(original_image, patch_image)
    patch_height, patch_width = size(patch_image)
    original_height, original_width = size(original_image)

    result = fill(Inf, (original_height - patch_height), (original_width - patch_width))

    for ind in CartesianIndices(result)
        i, j = ind.I
        img_view = @view original_image[i:i+patch_height-1, j:j+patch_width-1]
        error = img_dist.rmse(img_view, patch_image)
        result[i, j] = error
    end

    min_val = minimum(result)
    top_left = findfirst(x -> x == min_val, result)
    bottom_right = (top_left[1] + patch_height - 1, top_left[2] + patch_width - 1)

    matched_patch = original_image[top_left[1]:bottom_right[1], top_left[2]:bottom_right[2]]
    return matched_patch
end

function wcss(cluster, centroid)
    total = 0
    for i in 1:length(cluster)
        total = total + ((cluster[i] - centroid) ^ 2)
    end 
    return total 
end 


function kmeans(img, k, iterate_for=30, threshold=1e-4)
    centroids = [convert(Float32, img[rand(1:size(img, 1)), rand(1:size(img, 2))] ) for _ in 1:k]
    println("Centroid Being Initialized is : ",centroids)
    cluster_idx_mat = Matrix{Int32}(undef, size(img, 1), size(img, 2))

    # Initialize clusters as arrays to store pixel values
    clusters = [Array{Float32}(undef, 0) for _ in 1:k]
    iterate = 1
    prev_wcss = Inf
    while iterate <= iterate_for
        clusters=  [Array{Float32}(undef, 0) for _ in 1:k]
        for i in 1:size(img, 1)
            for j in 1:size(img, 2)
                dists = []
                for cluster in 1: k
                    dist = euclidean( convert(Float32, img[i, j] ),  centroids[cluster])
                    push!(dists, dist)
                end 
                cluster_idx = argmin(dists)
                cluster_idx_mat[i, j] = cluster_idx
                push!(clusters[cluster_idx], convert(Float32, img[i, j]))
            end
        end
        wcss_scores = Float32[]
        for i in 1:k
            if length(clusters[i]) > 0
                push!( wcss_scores, wcss(clusters[i], centroids[i]) )
                centroids[i] = mean(clusters[i])
            else 
                centroids[i] = img[rand(1:size(img, 1)), rand(1:size(img, 2))]
                push!(wcss_scores, 0.0)
            end 
        end
        change_in_wcss = abs(prev_wcss - sum(wcss_scores))
        if change_in_wcss < threshold
            println("Convergence reached at iteration $iterate")
            break
        end

        prev_wcss = sum(wcss_scores)
        iterate += 1
    end 
    return cluster_idx_mat, clusters 
end


# implement KNN and KMeans
# Example usage

# function main()
#     large_img = load("test//settings_large.png")
#     # patch_img = load("test//image.png") 

#     large_img_gray = Gray.(large_img)
#     # patch_gray     = Gray.(patch_img)

#     # @time matched_patch = match_template(large_img_gray, patch_gray)
    

# large_img = load("c:\\Users\\dhari\\projects\\DLProjects\\full_img.png")
# # patch_img = load("test//image.png") 

# large_img_gray = Gray.(large_img)
# # patch_gray     = Gray.(patch_img)

# # @time matched_patch = match_template(large_img_gray, patch_gray)
# coords, out = kmeans(large_img_gray, 2, 10, 1e-4)





# Gray.( min_max(coords) )


# sub_img = Matrix{Float32}(undef, size(large_img_gray, 1), size(large_img_gray, 2))

# for i in 1:size(coords, 1)
#     for j in 1:size(coords, 2)
#         if coords[i, j] == 1.0
#             sub_img[i, j] = convert(Float32, large_img_gray[i, j])
#         else
#             sub_img[i, j] = 0
#         end 
#     end 
# end

# end 