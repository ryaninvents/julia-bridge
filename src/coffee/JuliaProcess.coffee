Bacon = require 'baconjs'
_ = require 'lodash'

{spawn} = require 'child_process'
{EventEmitter} = require 'events'
path = require 'path'

getArgs = ()-> arguments

# Separator for different chunks of code.
# Unicode \\u0017 &#x2417; "End of Transmission Block"
#
# TODO: switch back to ETB; only using newline for testing
BLOCK_SEPARATOR = "\n"

module.exports =
# # JuliaProcess
# Best of both worlds: Bacon.js and EventEmitter.
# Use whatever you're most comfortable with.
class JuliaProcess extends Bacon.Bus
  constructor: (opt) ->
    super()
    @counter = 0
    startImmediately = opt?.startImmediately ? yes
    @juliaPath = opt?.juliaPath ? '/usr/bin/julia'
    @emitter = new EventEmitter()
    ['ready','killed'].forEach (method) =>
      @[method] = Bacon.fromEventTarget @emitter, method
        .map => @
    if startImmediately
      process.nextTick => @createProcess()
    @onValue (value) => @evaluate value
  createProcess: ->

    # The Julia process that will actually run our code.
    @process = spawn @juliaPath, [
      '--no-startup'
      path.resolve __dirname, '../julia/JavaScriptBridge.jl'
    ],
      cwd: process.cwd()

    # `@_detach` is the unsubscribe method for this
    # process's stdout stream
    @_detach = @plug (
      Bacon.fromEventTarget @process.stdout, 'data'
        .map (chunk) -> chunk.toString()
        .filter (x) -> x?
        .scan {code:[],wip:''}, (last, chunk) ->
          newCode = last.wip + chunk
          if newCode.indexOf(BLOCK_SEPARATOR) is -1
            return {
              code: []
              wip: newCode
            }
          split = newCode.split BLOCK_SEPARATOR
          {
            code: _.first split, split.length - 1
            wip: _.last split
          }
        .flatMap (codes) -> Bacon.fromArray codes.code
        .map (json) ->
          try
            JSON.parse(json)
          catch err
            new Bacon.Error json
    )
  kill: (signal) ->
    if @process?
      @detachProcess()
      @process.kill signal
      delete @process
      delete @_detach
      @emit 'killed'
  start: ->
    @createProcess()
  stop: ->
    @kill()
  restart: ->
    @stop()
    @start()
  stream: (eventName) ->
    Bacon.fromEventTarget @emitter, eventName, getArgs
  detachProcess: ->
    @_detach()
  evaluate: (code) ->
    if code?.data?.length
      @emitter.emit.apply @emitter, _.flatten [code.event, code.data]
    else
      @emitter.emit code?.event ? 'noop'
  compute: (code, callback) ->
    callbackId = "computed-value-#{@counter++}"
    code = ("\n#{code}").replace /\n/g, "\n  "
    code = "@emit \"#{callbackId}\" eval(quote\n#{code}\nend)"
    @send code
    if _.isFunction callback
      @emitter.once callbackId, =>
        callback.apply @, arguments
    else
      @stream callbackId
  send: (code) ->
    @process.stdin.write(JSON.stringify(code)+BLOCK_SEPARATOR)
