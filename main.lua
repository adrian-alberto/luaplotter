g = require("graphlib2")
require("color")
local CYCLE = 0

function love.load()
    love.window.setMode(400,300, {msaa=8, resizable=true})


    local data = g.dataframe("data/apobec_vs_expression2.tsv",
        function(data, i)
            if not tonumber(data.Base_Mean_B[i]) then
                return false
            end
            return true
        end)

    local lines = g.dataframe("data/apobec_vs_expression_mxmd1.txt")

    ctypes, colors = unique(data, "CancerType")
    for i, ctype in pairs(ctypes) do
        local alpha = (i-1)/#ctypes
        colors[ctype] = Color.fromHSV(alpha * math.pi * 2, 200, 220, 255)
    end


    test_ax = g.axes.new()
    test_ax.title = "APOBEC Enrichment(x) versus L1HS Expression(y) Mixed Model"
    test_ax.ymax = 20000
    test_ax.yinc = 2000
    test_ax.xmax = 5
    test_ax.xinc = 1
    test_ax.padding = 60

    mainplot = g.scatterplot.new(data, "APOBEC_Enrich", "Base_Mean_B")
    mainplot.pointScale = .2

    function mainplot:colorize(data, i)
        local ctype = data["CancerType"][i]
        return colors[ctype]:unpack()
    end

    test_ax:addPlot(mainplot)

    mainoverlay = g.lineoverlay.new(lines, "CancerType")
    function mainoverlay:colorize(data, i)
        local ctype = data["CancerType"][i]
        return colors[ctype]:unpack()
    end
    test_ax:addPlot(mainoverlay)
end

R_VAL = ""
local DRAWN = false
function love.draw()
    love.graphics.setBackgroundColor(255,255,255)
    local x, y = love.window.getMode()
    --if not DRAWN then
        --DRAWN = love.graphics.newCanvas(x, y)
        --love.graphics.setCanvas(DRAWN)
        love.graphics.setColor(255,255,255,255)
        love.graphics.rectangle("fill",0,0,x,y)
    	test_ax:draw(0,0,x,y)
        --love.graphics.setCanvas()
        --test_ax = nil

    --end
	--[[love.graphics.setColor(0,0,0,255)
	love.graphics.print("r = " .. R_VAL, 10, 10)
    love.graphics.setColor(255,255,255,255)]]
    --love.graphics.draw(DRAWN,0,0)

end

function unique(data, selector)
    local set = {}
    local list = {}
    for i = 1, #data[selector] do
        if not set[data[selector][i]] then
            set[data[selector][i]] = true
            table.insert(list, data[selector][i])
        end
    end
    table.sort(list)
    return list, set
end


function love.keypressed(key)
    if key == "w" then
        CYCLE = CYCLE + 1
    elseif key == "s" then
        CYCLE = CYCLE - 1
    end

end
