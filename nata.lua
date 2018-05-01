local nata = {
	_VERSION = 'Nata',
	_DESCRIPTION = 'Entity management for Lua.',
	_URL = 'https://github.com/tesselode/nata',
	_LICENSE = [[
		MIT License

		Copyright (c) 2018 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

local Pool = {}
Pool.__index = Pool

function Pool:call(event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			for entity, _ in pairs(self._entities) do
				if self._cache[system][entity] then
					system[event](entity, ...)
				end
			end
		end
	end
end

function Pool:callOn(entity, event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] and self._cache[system][entity] then
			system[event](entity, ...)
		end
	end
end

function Pool:queue(entity)
	self._queue[entity] = true
end

function Pool:flush()
	for entity, _ in pairs(self._queue) do
		self._entities[entity] = true
		self._queue[entity] = nil
		for _, system in ipairs(self._systems) do
			if (not system.filter) or system.filter(entity) then
				self._cache[system][entity] = true
			end
		end
		self:callOn(entity, 'add')
	end
end

function Pool:remove(f)
	for entity, _ in pairs(self._entities) do
		if f(entity) then
			self:callOn(entity, 'remove')
			self._entities[entity] = nil
			for _, system in ipairs(self._systems) do
				self._cache[system][entity] = nil
			end
		end
	end
end

function Pool:get(f)
	local entities = {}
	for entity, _ in pairs(self._entities) do
		if (not f) or f(entity) then
			table.insert(entities, entity)
		end
	end
	return entities
end

nata.oop = setmetatable({_f = {}}, {
	__index = function(t, k)
		if k == 'filter' then
			return rawget(t, k)
		else
			t._f[k] = t._f[k] or function(e, ...)
				if type(e[k]) == 'function' then
					e[k](e, ...)
				end
			end
			return t._f[k]
		end
	end
})

function nata.new(systems)
	local pool = setmetatable({
		_systems = systems or {nata.oop},
		_cache = {},
		_entities = {},
		_queue = {},
	}, Pool)
	for _, system in ipairs(pool._systems) do
		pool._cache[system] = {}
	end
	return pool
end