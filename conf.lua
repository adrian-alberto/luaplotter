function love.conf(t)
    t.identity = "plotter"
    t.window.title = "Lua Plotter"
    t.window.resizable = true
    t.window.minwidth = 100
    t.window.minheight = 100
    t.window.msaa = 0
    t.window.vsync = true
end