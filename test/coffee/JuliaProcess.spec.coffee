{expect, assert} = require 'chai'
sinon = require 'sinon'

JuliaProcess = require '../../index'

describe 'JuliaProcess', ->
  it 'should probably do something', (done) ->
    @timeout(30000)
    @process = new JuliaProcess()
    @process.ready.onValue =>
      @process.send '@emit "myevent" 5*6+4'
    @process.log('value!').onValue (value) =>
      console.log 'got stuff',value
      done()
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
    afterEach ->
      if @process
        @process.kill()
  describe 'createProcess', ->
  describe 'kill', ->
  describe 'evaluate', ->
  describe 'send', ->
