using Plots

const x_axis = 50
const y_axis = 50
const particle_shape = 0.05
const bag_w = 20
const bag_h = 20

function draw_rect(width, height)
    plot!(Shape(x_axis .+ [0, width, width, 0], y_axis .+ [0, 0, height, height]))
end

function draw_particle(x, y)
    plot!(Shape(x_axis .+ [x - particle_shape, x + particle_shape, x + particle_shape, x - particle_shape],
        y_axis .+ [y - particle_shape, y - particle_shape, y + particle_shape, y + particle_shape]))
end

function draw(x, y)
    plot()
    draw_rect(bag_w, bag_h)
    draw_particle(x, y)
end

function in_bag(x, y)
    x >= 0 && x <= bag_w && y >= 0 && y <= bag_h
end

function move(x, y)
    (x + randn() - 0.5, y + randn() - 0.5)
end

function main()
    gr()

    files_path = joinpath(pwd(), "assets", "swarm")
    if isdir(files_path)
        rm(files_path, recursive = true)
    end
    mkdir(files_path)

    x = rand(0:bag_w)
    y = rand(0:bag_h)
    i = 0
    println("init point ($x, $y)")
    while in_bag(x, y)
        println("attempt $i, res = $(in_bag(x, y))")
        (x, y) = move(x, y)
        println("next point ($x, $y)")
        draw(x, y)
        png(joinpath(files_path, "_$i.png"))
        i += 1
    end
end

main()
