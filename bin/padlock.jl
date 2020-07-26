const moves = [
    (2, 1),
    (-2, 1),
    (2, -1),
    (-2, -1),
    (1, 2),
    (1, -2),
    (-1, 2),
    (-1, -2),
]

function traverse_matrix(f::Function, matrix::Array{Int32,2})
    dims = size(matrix)
    for i in 1:dims[1]
        for j in 1:dims[2]
            f(i, j)
        end
    end
end

function create_matrix(dims)::Array{Int32,2}
    matrix = zeros(Int32, dims)
    n = 1
    traverse_matrix(matrix) do i, j
        matrix[i, j] = n
        n += 1
    end
    matrix
end

function get_pos_sol(matrix, pos)
    dims = size(matrix)
    reduce(moves; init=[]) do acc, move
        inw = pos[1] + move[1]
        jnw = pos[2] + move[2]
        if inw >= 1  && inw <= dims[1] && jnw >= 1  && jnw <= dims[2]
            vcat(acc, (inw, jnw))
        else
            acc
        end
    end
end

function search_for_pos(matrix, pos, depth, max_depth)
    if depth > max_depth
        return (pos, [])
    end
    solutions = get_pos_sol(matrix, pos)
    children = reduce(solutions; init=[]) do acc, solution
        inner_children = search_for_pos(matrix, solution, depth + 1, max_depth)
        vcat(acc, inner_children)
    end
    (pos, children)
end

function show_solutions(matrix, pos, solutions, steps)
    println("solutions for $(matrix[pos[1], pos[2]])")
    sols::Vector{Vector{Int32}} = []
    rec = (elem, acc) -> begin
        ((i, j), children) = elem
        acc = vcat(acc, matrix[i, j])
        for celem in children
            rec(celem, acc)
        end
        push!(sols, acc)
        acc
    end
    rec(solutions, [])
    sols = filter(sols) do elem
        length(elem) == steps
    end
    for sol in sols
        println("-> $sol")
    end
    println("")
end

function solve(dims, steps)
    matrix = create_matrix(dims)
    traverse_matrix(matrix) do i, j
        if i == 1 && j == 1
            solutions = search_for_pos(matrix, (i, j), 1, steps)
            show_solutions(matrix, (i, j), solutions, steps)
        end
    end
end

solve((5, 6), 9)
