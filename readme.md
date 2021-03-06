# Nata
**Nata** is an entity management library for LÖVE. It can be used in a traditional OOP style or a minimal ECS style.

Nata lets you create **entity pools**, which hold all of the objects in your game world, such as platforms, enemies, and collectables.

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to your `main.lua`:
```lua
nata = require 'nata' -- if your nata.lua is in the root directory
nata = require 'path.to.nata' -- if it's in subfolders
```

## Usage - OOP style
In the traditional OOP (object oriented programming) style, an entity is a table that contains both **data** and **functions**. For example, a player entity may have `x` and `y` variables for position, as well as functions such as `jump`. Generally, all entities will have some of the same functions, such as `update` or `draw`, which contain behavior unique to that entity.

### Creating an entity pool
```lua
pool = nata.new()
```
Creates a pool which holds entities.

### Queueing entities to be added to the pool
```lua
entity = pool:queue(entity, ...)
```
Adds an entity to the queue and returns it. Additional arguments are stored to be passed to `entity.add` when the queue is flushed.

### Adding queued entities
```lua
pool:flush()
```
Adds all of the entities in the queue to the pool. For each entity, `entity:add(...)` will be called (if it exists), where `...` is the arguments passed to `pool.queue`.

### Calling an event for all entities
```lua
pool:call(event, ...)
```
For each entity, this will run `entity:[event](...)` if the entity has a function called `event`. Any additional arguments passed to `pool.call` will be passed to each entity's function.

### Calling an event for a single entity
```lua
pool:callOn(entity, event, ...)
```

### Getting entities
```lua
entities = pool:get(f)
```
Returns a table containing all the entities for which `f(entity)` returns true. For example, this code will return a table with all the entities that are marked as "solid":
```lua
solidEntities = pool:get(function(entity)
  return entity.solid
end)
```
If no function is provided, `pool:get()` will return every entity.

### Sorting entities
```lua
pool:sort(f)
```
Sorts the entities according to the function `f`. This works just like Lua's `table.sort`.

### Removing entities
```lua
pool:remove(f)
```
Removes all the entities for which `f(entity)` returns true and calls the "remove" event on each entity that is removed.

## Usage - ECS style
While object oriented programming is a powerful metaphor, the **Entity Component System** pattern can offer greater flexibility and avoid some of the problems with inheritance. With ECS, entities primarily contain **data** rather than functions, and systems act on entities depending on what components they have.

Using Nata in the ECS style is almost exactly the same as using it in the OOP style, except you pass a list of systems to `nata.new`.
```lua
pool = nata.new(systems)
```
Each system is a table with an optional filter function and a function for each event it should respond to. Each event function will receive an entity as the first argument, followed by any additional arguments passed to `pool.call`, `pool.callOn`, `pool.add`, or `pool.remove`. For example, a gravity system might look like this:
```lua
GravitySystem = {
  filter = function(entity)
    return entity.vy and entity.gravity
  end,
  update = function(entity, dt)
    entity.vy = entity.vy + entity.gravity * dt
  end,
}
```
Nata's OOP functionality is implemented as a single system that passes every event (except for "filter") to the entity. If you want to use this system in combination with other systems, add `nata.oop()` to the `systems` table.

Nata also has functions that are only applicable when using multiple systems:

### Calling a single system on all entities
```lua
pool:callSystem(system, event, ...)
```

### Calling a single system on an entity
```lua
pool:callSystemOn(system, entity, event, ...)
```

## Contributing
This library is in very early development. Feel free to make suggestions about the design. Issues and pull requests are always welcome.

## License
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
