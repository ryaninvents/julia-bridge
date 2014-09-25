{expect, assert} = require 'chai'
sinon = require 'sinon'
path = require 'path'

JuliaProcess = require '../../index'

describe 'JuliaProcess', ->
  @timeout(60000)

  afterEach ->
    if @process
      @process.kill()
  describe 'constructor', ->
    it 'should create a new Julia process', ->
      @process = new JuliaProcess()
    it 'should fire a "ready" event', (done) ->
      @process = new JuliaProcess()
      @process.on 'ready', ->
        done()
    it 'should have a useful "ready" stream', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue -> done()
    it 'should obey startImmediately: no', ->
      @process = new JuliaProcess(startImmediately: no)
      @process.on 'ready', ->
        assert false, "Julia process should not have started"
    it 'should observe juliaPath', (done)->
      @process = new JuliaProcess(juliaPath: '/usr/bin/julia')
      @process.on 'ready', -> done()
  describe 'createProcess', ->
  describe 'kill', ->
  describe 'evaluate', ->
  describe 'stream', ->
    it 'should form streams correctly', (done)->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send "@emit(\"foo\", 2, true, \"blue\")"
      @process.stream('foo').onValues (num, bool, str) =>
        assert.equal num, 2
        assert.equal bool, true
        assert.equal str, 'blue'
        done()
  describe 'send', ->
    it 'should evaluate code sent to it', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit("myevent", 5*6+4)'
      @process.on 'myevent', (value) =>
        assert.equal value, 5*6+4
        done()
    it 'should be able to respond with a Boolean', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit("boolTest", 1==1)'
      @process.on 'boolTest', (value) =>
        assert value is true, "value should === true"
        done()
    it 'should be able to respond with a hashmap', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit("mapTest",["foo"=>"bar", "baz"=>7])'
      @process.on 'mapTest', (value) =>
        assert.equal value.foo, "bar"
        assert.equal value.baz, 7
        done()
    it 'should be able to include .jl files', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send "include(\"#{path.resolve __dirname, 'testFunctions.jl'}\")"
        @process.send '@emit("includeTest",f(7),g(6,5))'
      @process.stream('includeTest').onValues (f, g) =>
        assert.equal f, 19
        assert.equal g, 61
        done()
    it 'should be able to handle multiple code blocks', (done) ->
      first = no
      second = no
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit("first")'
        @process.send '@emit("second")'
      @process.on 'first', =>
        first = yes
        if first and second
          done()
      @process.on 'second', =>
        second = yes
        if first and second
          done()
    it 'should be able to evaluate multi-line code blocks', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send """
          x = [1,2,3]
          y = map((x) -> x^2, x)
          @emit("yValue", y)
        """
      @process.stream('yValue').onValues (a, b, c) =>
        assert.equal a, 1
        assert.equal b, 4
        assert.equal c, 9
        done()
  describe 'compute', ->
    it 'should call the callback once it has a value', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.compute "5*5", (result) =>
          assert.equal result, 25
          done()
    it 'should return a stream if there\'s no callback', (done) ->
      @process = new JuliaProcess()
      @process.ready.flatMap =>
        @process.compute "5*6"
      .onValues (result) =>
        assert.equal result, 30
        done()
    it 'should compute the Fibonacci sequence displayed in README', (done) ->
      @process = julia = new JuliaProcess()
      @process.on 'error', console.log.bind console, '<error>'
      PROGRAM = """
        function fib(n)
          if n <= 2
            1
          else
            fib(n-1) + fib(n-2)
          end
        end
        return fib(10)
      """
      @process.on 'ready', ->
        julia.compute PROGRAM, (result) ->
          assert.equal result, 55
          done()
