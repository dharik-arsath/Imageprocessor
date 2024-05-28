using ImageProcessor
using Test
using FileIO
using Statistics
import Images:Gray

@testset "ImageProcessor.jl" begin
    img = load("C:\\Users\\dhari\\Downloads\\green_man.png")
    gray = Gray.(img)

    std_img = standardize(gray)
    # @test mean(std_img) ≈ 0
    @test std(std_img)  ≈ 1

    @test convert(Float32, mae(gray, gray) ) ≈ 0
    @test convert(Float32, mse(gray, gray) ) ≈ 0
    @test convert(Float32, mle(gray, gray) ) ≈ 0
    # Write your tests here.

    large_img = load("test//settings.jpg")
    patch_img = load("test//patch_img.png") 

    large_img_gray = Gray.(large_img)
    patch_gray     = Gray.(patch_img)
    res = match_template(large_img_gray, patch_gray)
    @test length(res) == 2

end

