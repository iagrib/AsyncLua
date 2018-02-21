local awaitable = {
	__index = {
		get = function(self, cb)
			assert(type(cb) == "function", "Awaitable:get(fn) - 'fn' must be a function")

			if self.val then cb(unpack(self.val))
			else self.callbacks[#self.callbacks + 1] = cb end
		end,
		resolve = function(self, ...)
			assert(not self.val, "Awaitable objects can only be resolved once")

			self.val = {...}
			for i = 1, #self.callbacks do
				self.callbacks[i](...)
			end
		end
	}
}

function Awaitable(fn)
	assert(not fn or type(fn) == "function", "Awaitable(fn) - 'fn' must be a function or nil")

	local new = setmetatable({callbacks = {}}, awaitable)
	if fn then fn(function(...) new:resolve(...) end) end
	return new
end

function await(av)
	if getmetatable(av) == awaitable then return coroutine.yield(av)
	else return av end
end

function async(fn)
	return function(...)
		local arg = {...}

		local thread = coroutine.create(function()
			return fn(unpack(arg))
		end)

		local aw = Awaitable()

		local function handleThread(...)
			local returned = {coroutine.resume(thread, ...)}
			assert(table.remove(returned, 1), "Error in async function: "..tostring(returned[1]))
			if coroutine.status(thread) == "dead" then aw:resolve(unpack(returned))
			else returned[1]:get(handleThread) end
		end

		handleThread()

		return aw
	end
end