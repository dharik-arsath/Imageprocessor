using FileIO
using Images
using Statistics

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



function resize(img, height, width)
    padded_img = pad(img, height, width)
    
end


function euclidean_threshold(img, thresh_val, ref_color)
    distances = @. sqrt(( img - ref_color ) ^ 2)
    colorview( Gray, map(x -> x > thresh_val ? 1.0 : 0.0, distances) )

    # return colorview( Gray, map(x -> x > thresh_val ? 1.0 : 0.0, img) )
end 


# # img = load("C:\\Users\\dhari\\projects\\DLProjects\\green_heart.png")
# img = load("C:\\Users\\dhari\\Downloads\\green_man.png")

# gray = Gray.(img)
# # blurred = box_blur(gray, 3)
# standardized = standardize(gray)

# out = euclidean_threshold(gray,0.3, 0.9)
# out = euclidean_adaptive_threshold(standardized, 3, 0.1)
