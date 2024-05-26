using Statistics
"""
((y - ŷ)□ / n)
"""

function mse(reference_img, referal_img)
    return mean( (reference_img .- referal_img) .^ 2 )
end 

"""
abs((y - ŷ)^2 )
"""
function mae(reference_img, referal_img)
    return mean( abs2.((reference_img .- referal_img)) )
end 

"""
log((y - ŷ)^2 )
"""
function mle(reference_img, referal_img)
    return mean( log1p.((reference_img .- referal_img)) )
end 