Bacon = require 'baconjs'
_ = require 'lodash'

{spawn} = require 'child_process'
{EventEmitter} = require 'events'
path = require 'path'

getArgs = ()-> arguments

# Separator for different chunks of code.
# Unicode 0x17 &#x2417; "End of Transmission Block"
BLOCK_SEPARATOR = "\u0017"

module.exports =
# # JuliaProcess
# Best of both worlds: Bacon.js and EventEmitter.
# Use whatever you're most comfortable with.
class JuliaProcess extends Bacon.Bus
  constructor: (opt) ->
    super()
    startImmediately = opt?.startImmediately ? yes
    @juliaPath = opt?.juliaPath ? '/usr/bin/julia'
    @emitter = new EventEmitter()
    _.keys(EventEmitter::)
      .filter (method) -> method isnt 'emit'
      .forEach (method) =>
        @[method] = @emitter[method].bind @emitter
    @ready = Bacon.fromEventTarget @emitter, 'ready'
      .map -> @
    if startImmediately
      process.nextTick => @createProcess()
  createProcess: ->
    @process = spawn @juliaPath, ['--no-startup'], cwd: process.cwd()
    @_detach = @plug (
      Bacon.fromEventTarget @process.stdout, 'data'
        .skipUntil Bacon.fromEventTarget @process.stdout, 'readable'
        .scan '', (last, chunk) ->
          split = chunk.split BLOCK_SEPARATOR
          if split.length > 1
            _.first split
        .scan {code:[],wip:''}, (last, chunk) ->
          split = last.wip + chunk.split BLOCK_SEPARATOR
          if split.length > 1
            code: _.first split, split.length - 1
            wip: _.last split
          else
            code: []
            wip: split[0]
        .flatMap (codes) -> Bacon.fromArray codes.code
        .map (x) -> console.log x; x
        .onValue (code) => @evaluate code
    )
    @emitter.emit('ready')
  kill: (signal) -> @process.kill signal
  restart: ->
  detachProcess: ->
    @process
  evaluate: (code) ->
