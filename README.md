# julia-bridge

Call Julia code directly from Node.

`npm install julia-bridge`

[![NPM package](http://img.shields.io/npm/v/julia-bridge.svg?style=flat)](https://www.npmjs.org/package/julia-bridge)
[![Build Status](http://img.shields.io/travis/baconscript/julia-bridge.svg?branch=master&style=flat)](https://travis-ci.org/baconscript/julia-bridge)

## Intended API

This isn't how the code works currently, but it's where it's headed.

```coffee
JuliaProcess = require 'julia-bridge'
julia = new JuliaProcess

PROGRAM = """
  fib = (n) ->
    if n <= 1
      1
    else
      fib(n-1) + fib(n-2)
  fib(10)
"""

julia.on 'ready', ->
  julia.compute PROGRAM, (result) ->
    console.log("Fibonacci value #10 = #{result}")
```

Or, if you prefer the FRP style:

```coffee
julia.ready.flatMap ->
    julia.compute PROGRAM
  .map (result) ->
    console.log("Fibonacci value #10 = #{result}")
```

Julia-Bridge will return full JavaScript values, not just a text
representation of the Julia output.

You can also use a message-passing style if your Julia code might
send back multiple values, or if you just want the benefits of
decoupling:

```coffee
julia.on 'message:foo', (message) ->
  console.log "Result reported: #{message}"

julia.send """
  @send 'foo' longRunningComputation()
"""
```

or as streams:

```coffee
julia.stream('foo').onValue (message) ->
  console.log "Result reported: #{message}"
```
