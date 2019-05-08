module MapUtils

export most_common, count_map

function most_common(data)
    dict = count_map(data)
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
