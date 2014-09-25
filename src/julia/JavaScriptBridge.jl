import JSON
include("./lib/codeBlockProducer.jl")

blocks = Task(codeBlockProducer)

macro emit(event, data...)
  :(
    write(STDOUT, string(
      JSON.json(["event"=>$event,"data"=>[$(data...)]]),
      BLOCK_SEPARATOR
    ))
  )
end

@emit "ready"

while true
  code = ""
  json = ""
  index = 0
  try
    json = consume(blocks)
    code = JSON.parse(json)
    index = 0
    while index < length(code)
      (expr, index) = parse(code, index)
      eval(expr)
    end
    @emit "evaluated"
  catch err
    @emit "error" string(err) code JSON.json(err)
  end
end
