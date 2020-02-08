struct DivZeroError <: Exception end

Base.showerror(io::IO, e::DivZeroError) = print(io, "DIV BY ZERO")

function may_div(a, b)
    if b == 0
        throw(DivZeroError())
    else
        a / b, nothing
    end
end

try
    res = may_div(10, 0)
    println("res $res")
catch err
    if isa(err, DivZeroError)
        println("Err ", err)
    end
end
