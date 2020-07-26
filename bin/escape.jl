using Luxor
import JSON

escaped = (ypos, xpos) -> begin
    (xpos < -35 || xpos > 35) && (ypos < -35 || ypos > 35)
end

function draw_bag()
    bag = Turtle()
    rect(-35, -35, 70, 70)
end

function main()
    Drawing(70, 70, "assets/escape.png")
    origin()
    background("midnightblue")
    draw_bag()
    tt = Turtle(O)
    Pencolor(tt, "cyan")
    Penwidth(tt, 1.5)

    moves = []
    n = 5
    while !escaped(tt.xpos, tt.ypos)
        Forward(tt, n)
        HueShift(tt)
        Turn(tt, 45)
        n += 1
        push!(moves, (trunc(tt.xpos; digits=4), trunc(tt.ypos; digits=4), escaped(tt.xpos, tt.ypos)))
    end
    finish()
    moves
end

moves = main()
data = JSON.json(moves)
file = joinpath(pwd(), "assets", "data.json")
open(file, "w") do f
    write(f, data)
end
