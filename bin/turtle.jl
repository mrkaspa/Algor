using Luxor

function main()
    Drawing(1000, 800, "assets/turtles.png")
    origin()
    background("midnightblue")
    quantity = 9
    turtles = [Turtle(O, true, 2pi * rand(), (rand(), rand(), 0.5)...) for i in 1:quantity]
    Reposition.(turtles, first.(collect(Tiler(800, 800, 3, 3))))
    n = 10
    Penwidth.(turtles, 0.5)
    for i in 1:300
        Forward.(turtles, n)
        HueShift.(turtles)
        Turn.(turtles, [60.1, 89.5, 110, 119.9, 120.1, 135.1, 145.1, 176, 190])
        n += 0.5
    end
    finish()
end

main()
