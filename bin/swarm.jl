using Plots
using LinearAlgebra
using Lazy

const x_axis = 50
const y_axis = 50
const particle_shape = 0.05
const bag_w = 50
const bag_h = 50
const files_path = joinpath(pwd(), "assets", "swarm")

function draw_rect(width, height)
    plot!(Shape(x_axis .+ [0, width, width, 0], y_axis .+ [0, 0, height, height]))
end

function draw_particle(x, y)
    plot!(Shape(x_axis .+ [x - particle_shape, x + particle_shape, x + particle_shape, x - particle_shape],
        y_axis .+ [y - particle_shape, y - particle_shape, y + particle_shape, y + particle_shape]))
end

function draw(particles)
    plot()
    draw_rect(bag_w, bag_h)
    for p in particles
        (_, x, y) = p
        draw_particle(x, y)
    end
end

function in_bag(x, y)
    x >= 0 && x <= bag_w && y >= 0 && y <= bag_h
end

function find_knn(p, particles; knn=10)
    (pid, px, py) = p

    fst = t -> begin
        (_, dist) = t
        dist
    end

    @as acc particles begin
        filter(t -> begin
            (id, _x, _y) = t
            pid == id
        end, acc)
        map(t -> begin
            (id, nx, ny) = t
            (id, norm([px, py] - [nx, ny]))
        end, acc)
        sort(acc, by=fst)
        Iterators.take(acc, knn)
        collect(acc)
        map(t -> begin
            id = t[1]
            particles[id]
        end, acc)
    end
end

function center_point(nns)
    (x, y) = reduce(nns, init=(0.0, 0.0)) do (accx, accy), (_, x, y)
        (accx + x, accy + y)
    end
    (x / length(nns), y / length(nns))
end

function move(p, particles)
    (_, x, y) = p
    nns = find_knn(p, particles, knn=5)
    (cx, cy) = center_point(nns)
    (x + rand([1, -1]) * (rand(1:10) / 100 * cx),
    y + rand([1, -1]) * (rand(1:10) / 100 * cy))
end

function init()
    gr()
    if isdir(files_path)
        rm(files_path, recursive=true)
    end
    mkdir(files_path)
end

function main(n)
    init()

    particles = map(1:n) do id
        x = 25.0 # Float64(rand(0:bag_w))
        y = 25.0 # Float64(rand(0:bag_h))
        println("init point ($x, $y) for $id")
        (id, x, y)
    end
    i = 0
    while all(p -> in_bag(p[2], p[3]), particles)
        println("attempt $i")
        for p in particles
            (id, x, y) = p
            println("particle $id, in bag? = $(in_bag(x, y))")
            (nx, ny) = move(p, particles)
            println("id $id")
            particles[id] = (id, nx, ny)
            println("next point ($nx, $ny)")
        end
        draw(particles)
        png(joinpath(files_path, "_$i.png"))
        i += 1
    end
end

main(30)
