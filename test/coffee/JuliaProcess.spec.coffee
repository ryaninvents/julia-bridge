{expect, assert} = require 'chai'
sinon = require 'sinon'

JuliaProcess = require '../../index'

describe 'JuliaProcess', ->
  @timeout(30000)
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
    it 'should observe juliaPath', ->
      @process = new JuliaProcess(juliaPath: '/usr/bin/julia')
      @process.on 'ready', -> done()
    afterEach ->
      if @process
        @process.kill()
  describe 'createProcess', ->
  describe 'kill', ->
  describe 'evaluate', ->
  describe 'send', ->
    it 'should evaluate code sent to it', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit "myevent" 5*6+4'
      @process.on 'myevent', (value) =>
        assert.equal value, 5*6+4
        done()
    it 'should be able to respond with a Boolean', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit "boolTest" 1==1'
      @process.on 'boolTest', (value) =>
        assert value is true, "value should === true"
        done()
    it 'should be able to respond with a hashmap', (done) ->
      @process = new JuliaProcess()
      @process.ready.onValue =>
        @process.send '@emit "mapTest" ["foo"=>"bar", "baz"=>7]'
      @process.on 'mapTest', (value) =>
        assert.equal value.foo, "bar"
        assert.equal value.baz, 7
        done()
