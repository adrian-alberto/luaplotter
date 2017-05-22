Color = {}
Color.__index = Color
Color.__tostring = function(self)
	return self.r.." "..self.g.." "..self.b.." "..self.a
end
function Color.new(R, G, B, A)
	local col = {
		r = R or 0,
		g = G or 0,
		b = B or 0,
		a = A or 255
	}
	return setmetatable(col, Color)
end

function Color.get()
	return Color.new(love.graphics.getColor())
end

function Color.set(self)
	love.graphics.setColor(self.r, self.g, self.b, self.a)
	return self.r, self.g, self.b, self.a
end

function Color.setAlpha(self, a)
	love.graphics.setColor(self.r, self.g, self.b, a)
	return self.r, self.g, self.b, self.a
end

function Color.subtractPigment(self, pigment)
	local r, g, b
	r = self.r * pigment.r / 255
	g = self.g * pigment.g / 255
	b = self.b * pigment.b / 255
	return Color.new(r, g, b, self.a)
end

function Color.unpack(self)
	return self.r, self.g, self.b, self.a
end

function Color.fromString(s)
	local r, g, b, a = string.match(s, "%((.-),(.-),(.-),(.-)%)")
	if not a then
		r, g, b = string.match(s, "%((.-),(.-),(.-)%)")
		a = 255
	end
	return Color.new(tonumber(r),tonumber(g),tonumber(b),tonumber(a))
end

function Color.fromHSV(h, s, v, a)
	--h is in radians
	local a = a or 255
	local H = (h % (math.pi*2))/(math.pi/3)
	local S = s/255
	local V = v/255
	local C = V*S
	local X = C * (1 - math.abs((H % 2) - 1))
	local m = V - C
	C = (C + m)*255
	X = (X + m)*255
	m = m * 255
	if H < 1 then
		return Color.new(C, X, m, a)
	elseif H < 2 then
		return Color.new(X, C, m, a)
	elseif H < 3 then
		return Color.new(m, C, X, a)
	elseif H < 4 then
		return Color.new(m, X, C, a)

	elseif H < 5 then
		return Color.new(X, m, C, a)
	elseif H < 6 then
		return Color.new(C, m, X, a)
	else
		return Color.new(m, m, m, a)
	end
end