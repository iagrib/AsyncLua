# AsyncLua

AsyncLua is a wrapper around coroutines that allows you to use 'async' functions with 'await' statement in form of a function:

```lua
async(function(arg)
	local foo = await( doSomething(arg) )
	if foo then
		foo = await( doSomethingElse(foo) )
	else
		foo = await( doOtherThing(foo) )
		foo = foo * 2
	end
	return foo
end)
```

It was designed to get rid of callbacks that make code less readable.

# Reference

## async(fn)

`async` is a global function. It accepts a function as the only argument and returns an 'asynchronous' variant of that function. `await` can be used inside this function. When asynchronous function is called, instead of normally returning a value, it returns *[Awaitable](#awaitable)* object (see below).

Example:

```lua
local asyncFn = async(function()
	-- code to be executed
end)
```

## await(awaitable)

`await` is also a global function, however it should **only** be called inside asynchronous functions, else unexpected things might happen.

It accepts one value. If it's *[Awaitable](#awaitable)* object, it waits for it to resolve and then returns its value. Otherwise, it returns passed value itself.

Example:

```lua
async(function()
	local foo = await(bar())
	return foo
end)
```

## Awaitable

*Awaitable* objects are created using global function `Awaitable`. They represent a value that might be or not be available at given moment, and that value can be `await`ed in async function or be retrieved outside of it using normal callbacks.

### Awaitable([fn])

`Awaitable` function is used to create *Awaitable* object. It accepts an optional callback function that will be called as soon as the object is created and is passed one argument - the function to resolve created object (this isn't different from resolving it with `awaitable:resolve(...)`, just makes your code cleaner).

### awaitable:get(fn)

Attaches a callback to `awaitable` that will be called as soon as it's resolved (or instantly, if it's already resolved). This can be used to work with given Awaitable object outside of async functions.

### awaitable:resolve(...)

Resolves `awaitable` with given values.

## License

```
   Copyright 2018 Ia_grib

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```