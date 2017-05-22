class = require("oop")

axes = class()
axes.plots = {}
axes.ymin = 0
axes.ymax = 10
axes.yinc = 2
axes.xmin = 0
axes.xmax = 10
axes.xinc = 2
axes.padding = 80
axes.x_override = nil
axes.x_num_cats = 0
axes.y_override = nil
axes.y_num_cats = 0

axes.font = love.graphics.newFont("OpenSans-Regular.ttf", 14)
axes.title_font = love.graphics.newFont("OpenSans-Regular.ttf", 24)

function axes:init()
	self:setFont(self.font, self.title_font)
end

function axes:setFont(font, title_font)
	self.font = font
	self.font_height = self.font:getHeight()
	self.title_font = title_font or font
	self.title_font_height = self.title_font:getHeight()
end

function axes:addPlot(plot)
	table.insert(axes.plots, plot)
end

function axes:setXCategories(cats)
	if not cats then
		self.x_override = nil
		self.x_num_cats = 0
		return
	end
	self.x_override = {}
	for i, v in pairs(cats) do
		self.x_override[v] = i
	end
	self.x_num_cats = #cats
end

function axes:setYCategories(cats)
	if not cats then
		self.y_override = nil
		self.y_num_cats = 0
		return
	end
	self.y_override = {}
	for i, v in pairs(cats) do
		self.y_override[v] = i
	end
	self.y_num_cats = #cats
end

function axes:draw(x, y, w, h)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", x, y, w, h)
	
	--inside coords
	local ix, iy = x + self.padding, y + self.padding
	local iw, ih = w - self.padding*2, h - self.padding*2
	local ix2, iy2 = ix + iw, iy + ih
	
	--debug draw inside
	love.graphics.setColor(0,0,0,20)
	love.graphics.rectangle("fill", ix, iy, iw, ih)

	--Title
	love.graphics.setColor(0,0,0,255)
	if self.title then
		love.graphics.setFont(self.title_font)
		love.graphics.print(self.title, ix, iy - self.title_font_height - 10)
	end

	--draw axes
	love.graphics.setFont(self.font)
	love.graphics.setColor(0,0,0)
	love.graphics.line(ix, iy, ix, iy2)
	love.graphics.line(ix, iy2, ix2, iy2)

	--increments
	if not self.x_override then
		for x = self.xmax, self.xmin, -self.xinc do
			local X = ix + iw*(x - self.xmin)/(self.xmax - self.xmin)
			love.graphics.print(x, X+5, iy2 + 10, math.pi/4)
			love.graphics.line(X, iy2, X, iy2 + 8)
		end
	else
		for label, x in pairs(self.x_override) do
			local X = ix + iw*(x-0.5)/self.x_num_cats
			love.graphics.print(label, X+5, iy2 + 10, math.pi/4)
			love.graphics.line(X, iy2, X, iy2 + 8)
		end

	end
	if not self.y_override then
		for y = self.ymax, self.ymin, -self.yinc do
			local Y = iy2 - ih*(y - self.ymin)/(self.ymax - self.ymin)
			love.graphics.printf(y, ix-self.padding*3-10, Y - self.font_height/2, self.padding*3, "right")
			love.graphics.line(ix, Y, ix - 8, Y)
		end
	else
		for label, y in pairs(self.y_override) do
			local Y = iy2 - ih*(y-0.5)/self.y_num_cats
			love.graphics.printf(label, ix-self.padding*3-10, Y - self.font_height/2, self.padding*3, "right")
		end
	end


	--draw zeros
	love.graphics.setColor(0,0,0,40)
	if not self.y_override and self.ymin < 0 and self.ymax > 0 then
		love.graphics.line(ix, iy2 - ih*(-self.ymin/(self.ymax - self.ymin)), ix2,iy2 -  ih*(-self.ymin/(self.ymax - self.ymin)))
	end

	if not self.x_override and self.xmin < 0 and self.xmax > 0 then
		love.graphics.line(ix + iw*(-self.xmin/(self.xmax - self.xmin)), iy, ix+iw*(-self.xmin/(self.xmax-self.xmin)), iy2)
	end

	--Plots
	love.graphics.setScissor(ix+1, iy+1, iw-2, ih-2)
	
	for _, plot in pairs(self.plots) do
		love.graphics.setColor(200,100,100)
		plot:draw(ix, iy, iw, ih, self)
	end
	love.graphics.setColor(0,0,0)
	love.graphics.setBlendMode("alpha")
	love.graphics.setScissor()
	
end

function axes:screenPos(x, y, ix, iy, iw, ih, jitter)
	local out_x, out_y

	if not self.x_override then
		out_x = ix + iw * ((x-self.xmin)/(self.xmax-self.xmin))
	elseif self.x_override[x] then
		out_x = ix + iw * (self.x_override[x]-0.5)/self.x_num_cats
		if jitter then
			out_x = out_x + (math.random()/2-0.25)*iw/self.x_num_cats --jitter
		end
	end
	if not self.y_override then
		out_y = iy + ih - ih * ((y - self.ymin)/(self.ymax-self.ymin))
	elseif self.y_override[y] then
		out_y = iy + ih - ih * (self.y_override[y]-0.5)/self.y_num_cats
		if jitter then
			out_y = out_y + (math.random()/2-0.25)*ih/self.y_num_cats
		end
	end
	return out_x, out_y
end

-------------------------------------------------------------------------------

baseplot = class()
function baseplot:init(data, x_selector, y_selector, color_selector)
	self.data = data
	self.x_selector = x_selector
	self.y_selector = y_selector
	--[[self.color_selector = color_selector
	if color_selector then
		self:autocolor(color_selector)
	end]]
end

function baseplot:draw()
end

--[[function baseplot:autocolor(selector)

end]]


scatterplot = class(baseplot)
scatterplot.jitter = true
scatterplot.pointScale = 1

function scatterplot:draw(ix, iy, iw, ih, ax)
	math.randomseed(math.pi*math.pi*math.pi)
	local size = math.sqrt(iw*iw+ih*ih)/80 * self.pointScale
	love.graphics.setBlendMode("multiply")
	for i = 1, #self.data[self.y_selector] do
		local x, y = ax:screenPos(self.data[self.x_selector][i], self.data[self.y_selector][i], ix, iy, iw, ih, self.jitter)
		if x and y then
			if self.colorize then
				love.graphics.setColor(self:colorize(self.data, i))
			end
			--love.graphics.circle("fill", x, y, size/3)
			--love.graphics.circle("line", x, y, size)
			love.graphics.circle("fill",x,y,size)
			love.graphics.setColor(0,0,0)
			love.graphics.circle("line",x,y,size+1)
		end
	end
end

boxplot = class(baseplot)
function boxplot:init(data, x_selector, y_selector, color_selector)
	baseplot.init(self, data, x_selector, y_selector, color_selector)
	self.boxdata = box_data(data, x_selector, y_selector)
end

function boxplot:draw(ix, iy, iw, ih, ax)
	love.graphics.setBlendMode("alpha")
	local gw = iw/ax.x_num_cats/2
	for cat, y_input in pairs(self.boxdata) do
		local y_vals = {}
		local x
		for j, v in pairs(y_input) do
			x, y = ax:screenPos(cat, v, ix, iy, iw, ih)
			y_vals[j] = y
		end
		if self.colorize then
			love.graphics.setColor(self:colorize(self.data, i))
		end

		love.graphics.setLineWidth(1)
		--Box
		love.graphics.rectangle("line", x - gw/2, y_vals[2], gw, y_vals[4]-y_vals[2])
		--Whiskers, median
		love.graphics.line(x - gw/4, y_vals[1], x + gw/4, y_vals[1])
		love.graphics.line(x - gw/2, y_vals[3], x + gw/2, y_vals[3])
		love.graphics.line(x - gw/4, y_vals[5], x + gw/4, y_vals[5])
		--Whiskerlines
		love.graphics.line(x, y_vals[1], x, y_vals[2])
		love.graphics.line(x, y_vals[4], x, y_vals[5])

		love.graphics.setLineWidth(1)
	end
end

heatmap = class(baseplot)
function heatmap:draw(ix, iy, iw, ih, ax)
	local gw = iw/ax.x_num_cats -- grid width
	local gh = ih/ax.y_num_cats -- grid height
	love.graphics.setBlendMode("alpha")
	for i = 1, #self.data[self.y_selector] do
		local x, y = ax:screenPos(self.data[self.x_selector][i], self.data[self.y_selector][i], ix, iy, iw, ih, false)
		if x and y then
			if self.colorize then
				love.graphics.setColor(self:colorize(self.data, i))
			end
			love.graphics.rectangle("fill", x-gw/2 + .5, y-gh/2 + .5, gw - 1, gh - 1)
		end
	end
end

bargraph = class(baseplot)
function bargraph:draw(ix, iy, iw, ih, ax)
	local gw = iw/ax.x_num_cats -- grid width
	--local gh = ih/ax.y_num_cats -- grid height
	if not ax.x_override then
		gw = iw / (ax.xmax - ax.xmin) * ax.xinc
	end

	local _, y_zero = ax:screenPos(self.data[self.x_selector][1], 0, ix, iy, iw, ih, false)
	love.graphics.setBlendMode("alpha")
	for i = 1, #self.data[self.y_selector] do
		local x, y = ax:screenPos(self.data[self.x_selector][i], self.data[self.y_selector][i], ix, iy, iw, ih, false)
		if x and y then
			if self.colorize then
				love.graphics.setColor(self:colorize(self.data, i))
			end
			love.graphics.rectangle("fill", x-gw/2 + 1, y_zero, gw - 2, y-y_zero)
		end
	end
end
-------------------------------------------------------------------------------
lineoverlay = class(baseplot)

function lineoverlay:init(data, label_selector)
	self.data = data
	self.label_selector = label_selector
	if not self.data.Slope then
		error("Missing 'Slope' column for line overlay dataframe.")
	elseif not self.data.Intercept then
		error("Missing 'Intercept' column for line overlay dataframe.")
	end
end

function lineoverlay:draw(ix, iy, iw, ih, ax)
	--local size = math.sqrt(iw*iw+ih*ih)/80 * self.pointScale
	love.graphics.setBlendMode("multiply")
	for i = 1, #self.data.Slope do
		local x0, y0 = ax:screenPos(ax.xmin, self.data.Slope[i]*ax.xmin + self.data.Intercept[i], ix, iy, iw, ih)
		local x1, y1 = ax:screenPos(ax.xmax, self.data.Slope[i]*ax.xmax + self.data.Intercept[i], ix, iy, iw, ih)
		if x0 and y0 and x1 and y1 then
			if self.colorize then
				love.graphics.setColor(self:colorize(self.data, i))
			end
			
			love.graphics.line(x0,y0,x1,y1)
		end
	end
end




-------------------------------------------------------------------------------
function dataframe(filename, selector)
	local splitchar = "\t"
	if string.match(filename, ".-%.csv") then
		splitchar = "," --this does not work currently
	end
	f = io.open(filename, "r")
	data = {}
	header = {}
	for x in string.gmatch(f:read(), "[^"..splitchar.."]+") do
		table.insert(header, x)
		data[x] = {}
	end

	for line in f:lines() do
		local i = 0

		for x in string.gmatch(line, "\t?([^\t\n]*)") do
			i = i + 1
			if i > #header then
				break
			end
			table.insert(data[header[i]], x)
		end
		--Undo this line if it didn't match.
		local j = #data[header[1]]
		if selector and not selector(data, j) then
			for i = 1, #header do
				table.remove(data[header[i]], #data[header[i]])
			end
		end
	end

	return data
end



function draw_legend(colors, x, y, w, h)
	local padding = 10
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill", x, y, w, h)
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	local bl = font:getBaseline()
	local asc = font:getAscent()
	for i, tup in pairs(colors) do
		local Y = y + (i-1) * font:getHeight() + padding
		local rwidth = asc

		if type(tup) == "table" then
			love.graphics.setColor(unpack(tup[1]))
			love.graphics.rectangle("fill", x + padding, Y + fh/2 - asc/2, asc, asc)
			love.graphics.setColor(0,0,0,255)
			love.graphics.print(tup[2], x + padding + asc + 10, Y)
		elseif type(tup == "string") then
			love.graphics.setColor(0,0,0,255)
			love.graphics.print(tup, x + padding, Y)
		end
	end
end

function box_data(data, x_selector, y_selector)
	local cat_lists = {}
	for i, v in pairs(data[x_selector]) do
		if not cat_lists[v] then
			cat_lists[v] = {} --Create a list of data points for this category
		end
		table.insert(cat_lists[v], tonumber(data[y_selector][i])) --Append to the list
	end


	output = {} --output[cat] = {min, q1, med, q3, max}
	for cat, list in pairs(cat_lists) do
		table.sort(list)
		local n = #list
		if n > 0 then

			local min = list[1]
			local max = list[n]
			local med = (list[math.ceil(n/2)] + list[math.floor(n/2)+1])/2
			local div_lo = math.floor(n/2) + 1
			local div_hi = math.ceil(n/2)
			local n2 = math.floor(n/2)
			local q1 = (list[math.ceil(div_lo/2)] + list[math.floor(div_lo/2)+1]) / 2
			local q3 = (list[math.ceil(n2/2) + div_hi - 1] + list[math.floor(n2/2)+1 + div_hi])/2

			output[cat] = {min, q1, med, q3, max}
		end
	end
	return output
end

function avg(data, selector)
	local total = 0
	local count = 0
	for i = 1, #data[selector] do
		if data[selector][i] and tonumber(data[selector][i]) then
			total = total + data[selector][i]
			count = count + 1
		end
	end
	return total / count
end

function correlation(data, x_selector, y_selector)
	local avg_x = avg(data, x_selector)
	local avg_y = avg(data, y_selector)
	local n = #data[x_selector]

	local n2 = 0
	local sum = 0
	local v2x = 0
	local v2y = 0
	for i = 1, n do
		local x = data[x_selector][i]
		local y = data[y_selector][i]
		if x and y and tonumber(x) and tonumber(y) then
			sum = sum + (x-avg_x)*(y-avg_y)
			n2 = n2 + 1
			v2x = v2x + (x-avg_x)^2
			v2y = v2y + (y-avg_x)^2
		end
	end
	local covariance = sum / n2
	v2x = v2x / n2
	v2y = v2y / n2
	local std_x = math.sqrt(v2x)
	local std_y = math.sqrt(v2y)
	return covariance / (std_x * std_y)
end


return {
	axes = axes,
	scatterplot = scatterplot,
	boxplot = boxplot,
	heatmap = heatmap,
	dataframe = dataframe,
	draw_legend = draw_legend,
	correlation = correlation,
	bargraph = bargraph,
	lineoverlay = lineoverlay,
}






