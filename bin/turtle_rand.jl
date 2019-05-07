using Luxor

function main()
    Drawing(1000, 800, "assets/turtle_rand.png")
    origin()
    background("midnightblue")
    tt = Turtle()
    Pencolor(tt, "cyan")
    Penwidth(tt, 1.5)
    n = 5
    switch = true
    for i in 1:300
        Forward(tt, n)
        HueShift(tt)
        if switch
            Turn(tt, 45)
        else
            Turn(tt, -45)
        end
        switch = !switch
        n += 0.5
    end
    finish()
end

main()
