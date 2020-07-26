import JSON

include("MapUtils.jl")

using .MapUtils

function entropy(data)
    freq = count_map([item[end] for item in data])
    ientropy = (category) -> begin
        ratio = float(category) / length(data)
        -1 * ratio * log2(ratio)
    end
    sum([ientropy(c) for c in values(freq)])
end

function best_feat(data)
    baseline = entropy(data)
    feat_entropy = f -> begin
        e = v -> begin
            partitioned_data = [d for d in data if d[f] == v]
            proportion = float(length(partitioned_data)) / float(length(data))
            proportion * entropy(partitioned_data)
        end
        iter_data = unique([d[f] for d in data])
        sum([e(v) for v in iter_data])
    end
    features = length(data[1]) - 1
    baselines = [trunc(Int, baseline - feat_entropy(f)) for f in 1:features]
    max_v = 0
    max_k = 1
    for i in 1:length(baselines)
        v = baselines[i]
        if v > max_v
            max_k = i
            max_v = v
        end
    end
    best_feat = baselines[max_k]
    max_k
end

function create_tree(data, label)
    (category, count) = most_common([item[end] for item in data])
    if count == length(data)
        return Bool(category)
    end
    node = Dict{String,Any}()
    feature = best_feat(data)
    feature_label = label[feature]
    node[feature_label] = Dict()
    classes = unique([d[feature] for d in data])
    for c in classes
        partitioned_data = [d for d in data if d[feature] == c]
        node[feature_label][c] = create_tree(partitioned_data, label)
    end
    node
end

function classify(tree, label, data)
    root = collect(keys(tree))[1]
    node = tree[root]
    index = findfirst(x -> x == root, label)
    for k in keys(node)
        if data[index] == k
            if isa(node[k], Dict)
                return classify(node[k], label, data)
            else
                return node[k]
            end
        end
    end
end

function main_json()
    file = joinpath(pwd(), "assets", "data.json")
    labels = ["x", "y", "escape"]
    open(file, "r") do f
        data = JSON.parse(read(file, String))
        tree = create_tree(data, labels)
        println("Tree = \n$tree")
        res = classify(tree, labels, [67.1837, 35.2426])
        println("Res = \n$res")
    end
end

function main_data()
    data = [[0.0, 0.0, false],
        [-1.0, 0.0, true]]
    labels = ["x", "y", "out"]
    tree = create_tree(data, labels)
    println("Tree = $tree")
    category = classify(tree, labels, [-1, 0])
    println("Res = $category")
end

main_json()
# main_data()
