using Pipe
import Distributions: Uniform

Generation = Vector{Tuple{Float64,Float64}}

function hit_coordinate(theta, v, width)
    x = width * 0.5
    x_hit = width
    if theta > pi / 2
        x = -x
        x_hit = 0
    end
    t = x / (v * cos(theta))
    y = v * t * sin(theta) - 0.5 * 9.81 * t^2
    if y < 0
        y = 0.0
    end
    (x_hit, y)
end

function escaped(theta, v, width, height)
    (x_hit, y_hit) = hit_coordinate(theta, v, width)
    (x_hit == 0 || x_hit == width) && y_hit > height
end

function cumulative_probabilities(results)
    acc = []
    total = 0
    for res in results
        total += res
        push!(acc, total)
    end
    acc
end

function choose(choices)
    p = rand(1:choices[end])
    for i in 1:length(choices)
        if choices[i] >= p
            return i
        end
    end
end

function selection(generation::Generation, width)
    results = [hit_coordinate(theta, v, width)[2] for (theta, v) in generation]
    cumulative_probabilities(results)
end

function breed(mum, dad)
    (mum[1], dad[2])
end

function crossover(generation::Generation, width)::Generation
    choices = selection(generation, width)
    next = []
    for _ in 1:length(generation)
        mum = generation[choose(choices)]
        dad = generation[choose(choices)]
        push!(next, breed(mum, dad))
    end
    next
end

function mutate(generation::Generation)::Generation
    map(generation) do (theta, v)
        new_theta = if rand() < 0.1
            new_theta = theta + rand(-10:10) * pi / 180
            if 0 < new_theta < 2 * pi
                new_theta
            else
                theta
            end
        else
            theta
        end
        new_v = if rand() < 0.1
            v * rand(Uniform(0.9, 1.1))
        else
            v
        end
        (new_theta, new_v)
    end
end

function random_tries(items)::Generation
    map(1:items) do _
        (rand(Uniform(0.1, pi)), Float64(rand(2:20)))
    end
end

function main()
    epochs = 100
    items = 12
    height = 5
    width = 10
    generation = random_tries(items)
    generation0 = copy(generation) # save to contrast with last epoch
    res = reduce(1:epochs; init = generation) do generation, _
        @pipe generation |>
            crossover(_, width) |>
            mutate(_)
    end
    println("Origin $generation0")
    println("Res $res")
end

main()