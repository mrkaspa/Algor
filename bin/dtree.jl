import JSON
using Pipe

module MapUtils

export most_common, count_map

function most_common(data)
    dict = count_map(data)
    println(dict)
    max_v = 0
    max_k = 0
    for (k, v) in dict
        if v > max_v
            max_k = k
            max_v = v
        end
    end
    (max_k, max_v)
end

function count_map(data)
    uniq = unique(data)
    Dict([(i, count(x->x == i, data)) for i in uniq])
end

end

using .MapUtils

function entropy(data)
    freq = count_map([item[end] for item in data])
    ientropy = (category)->begin
        ratio = float(category) / length(data)
        -1 * ratio * log2(ratio)
    end
    sum([ientropy(c) for c in values(freq)])
end

function best_feat(data)
    baseline = entropy(data)
    feat_entropy = f->begin
        e = v->begin
            partitioned_data = [d for d in data if d[f] == v]
            proportion = float(length(partitioned_data)) / float(length(data))
            proportion * entropy(partitioned_data)
        end
        iter_data = unique([d[f] for d in data])
        sum([e(v) for v in iter_data])
    end
    features = length(data[1]) - 1
    best_feat = @pipe [baseline - feat_entropy(f) for f in 1:features] |>
        maximum |>
        abs |>
        trunc(Int, _)
    println("best_feat = $(best_feat)")
    best_feat + 1
end

function create_tree(data, label)
    println("entro")
    (category, count) = most_common([item[end] for item in data])
    println("count $count")
    println("length $(length(data))")
    if count == length(data)
        return Bool(category)
    end
    node = Dict{String,Any}()
    feature = best_feat(data)
    feature_label = label[feature]
    node[feature_label] = Dict()
    classes = unique([d[feature] for d in data])
    println("feature $feature_label - classes $classes")
    for c in classes
        partitioned_data::Array{Array{Float64}} = [(println("forin $(d[feature]) == $c"); d) for d in data if d[feature] == c]
        println("part = $partitioned_data")
        node[feature_label][c] = create_tree(partitioned_data, label)
    end
    node
end

function classify(tree, label, data)
    root = collect(keys(tree))[1]
    node = tree[root]
    index = findfirst(x->x == root, label)
    for k in keys(node)
        if data[index] == k
            println("isa(node[k], Dict) = $(isa(node[k], Dict))")
            if isa(node[k], Dict)
                println("rec call")
                return classify(node[k], label, data)
            else
                return node[k]
            end
        end
    end
end

file = joinpath(pwd(), "assets", "data.json")
labels = ["x", "y", "escape"]
open(file, "r") do f
    data = JSON.parse(read(file, String))
    tree = create_tree(data, labels)
    println("Tree = \n$tree")
    res = classify(tree, labels, [67.1837, 35.2426])
    println("Res = \n$res")
end
