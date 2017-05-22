g = require("graphlib2")



function love.load()
    love.window.setMode(1000,600, {msaa=8, resizable=true})


    local data = g.dataframe("data/TEDA_subfamily_fishers.tsv")

    local ctypes = {}
    local subfamilies = {}--[[{"L1HS","L1PA2","L1PA3","L1PA4","L1PA5", "L1PA6","L1PA7","L1PA8","L1PA8A",
                        "L1PA10","L1PA11","L1PA12","L1PA13A","L1PA14","L1PA15","L1PA16","L1PA17",
                        "L1PB1","L1PB2","L1PB3","L1PB4"}]]

    for line in io.open("repbase_AluY.txt"):lines() do
        line = string.gsub(line, "%W" , "")
        --subfamilies[#subfamilies+1] = line
        table.insert(subfamilies, 1, line)
        print(line)
    end
    
    local temp = {}
    for i, v in pairs(data["CancerType"]) do
        if not temp[v] then
            temp[v] = true
            table.insert(ctypes, v)
        end
    end
    table.sort(ctypes)
    temp = {}
    --[[for i, v in pairs(data["Subfamily"]) do
        if not temp[v] then
            temp[v] = true
            table.insert(subfamilies, v)
        end
    end]]
    --[[temp = {}
    for i, v in pairs(subfamilies) do
        temp[v] = true
    end
    for i = 1, #subfamilies/2 do
        swap = subfamilies[i]
        subfamilies[i] = subfamilies[#subfamilies + 1 - i]
        subfamilies[#subfamilies + 1 - i] = swap
    end
    temp = nil]]

    test_ax = g.axes.new()
    test_ax.title = "SINE Insertion Rates by Cancer Type"
    test_ax:setXCategories(ctypes)
    test_ax:setYCategories(subfamilies, true)

    local testplot = g.heatmap.new(data, "CancerType", "Subfamily")

    --[[function testplot:colorize(data, i)
        local a = tonumber(data["Samples_normal"][i])
        return 255, 0, 0, a*3
    end]]
    function testplot:colorize(data, i)
        if not tonumber(data["Rate"][i]) then
            return 255,255,255,0
        end
        local r, g, b, a
        local pval = tonumber(data["P_value"][i])
        if pval < 0.05 and data["Family"][i] == "SINE" then
            if pval < 0.005 then
                a = 255
            else
                a = 100
            end
            --a = (1 - (pval-0.05)/0.05) * 100
        else
            a = 0
        end

        local rate = tonumber(data["Rate"][i])
        if math.abs(rate-1) <= 0.2 then
            r = 100
            g = 200
            b = 0
        elseif rate > 1 then
            r = 255
            g = 100
            b = 0
        else
            r = 0
            g = 180
            b = 200
        end

        return r, g, b, a
    end
    test_ax:addPlot(testplot)
end

local DRAWN = false
function love.draw()
    love.graphics.setBackgroundColor(255,255,255)
    local x, y = love.window.getMode()
    if not DRAWN then
        DRAWN = love.graphics.newCanvas(x, y)
        love.graphics.setCanvas(DRAWN)
        love.graphics.setColor(255,255,255,255)
        love.graphics.rectangle("fill",0,0,x,y)
    	test_ax:draw(120,0,x-240, y)
        draw_legend({
                "Insertions increase",
                "with cancer:",
                {{255,100,0,255}, "r > 1.2, p < 0.005"},
                {{255,100,0,100}, "r > 1.2, p < 0.05"},
--[[                "",
                "Insertions decrease",
                "with cancer:",
                {{0,180,200,255}, "r < 0.8, p < 0.005"},
                {{0,180,200,100}, "r < 0.8, p < 0.05"},
                "",
                "Insertions unaffected:",
                {{100,200,0,255}, "r in [0.8, 1.2], p < 0.005"},
                {{100,200,0,100}, "r in [0.8, 1.2], p < 0.05"},
--]]                "",
                "r is the odds ratio",
                "(unconditional maximum",
                "likelihood estimate) ",
                "as determined by Fisher's",
                "Exact Test"
            }, x-200, 80, 200, y-160)
        love.graphics.setCanvas()
        test_ax = nil

    end
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(DRAWN,0,0)

end
