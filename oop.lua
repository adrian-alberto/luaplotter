function class(inheritsFrom)
	local c = {}
	local c_mt = {__index = c, __tostring = function(obj) if obj.tostring then return obj:tostring() end end}
	function c.new(...)
		local obj = setmetatable({}, c_mt)
		if obj.init then obj:init(...) end
		return obj
	end
	function c.super()
		return inheritsFrom
	end
	function c.instanceOf(class)
		return c == class or inheritsFrom and inheritsFrom.instanceOf(class)
	end
	if inheritsFrom then
		if not inheritsFrom.instanceOf then error("Bad superclass.") end
		setmetatable(c, {__index = inheritsFrom})
	end
	return c
end

return class