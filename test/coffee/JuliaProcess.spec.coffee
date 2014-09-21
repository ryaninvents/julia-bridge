{expect, assert} = require 'chai'
sinon = require 'sinon'

JuliaProcess = require '../../index'

describe 'JuliaProcess', ->
  describe 'constructor', ->
    it 'should create a new Julia process', ->
      process = new JuliaProcess()
    it 'should fire a "ready" event', (done) ->
      process = new JuliaProcess()
      process.on 'ready', ->
        done()
    it 'should obey startImmediately: no', ->
      process = new JuliaProcess(startImmediately: no)
      process.on 'ready', ->
        throw new Error "Julia process should not have started"
  describe 'createProcess', ->
  describe 'kill', ->
  describe 'evaluate', ->
  describe 'send', ->
