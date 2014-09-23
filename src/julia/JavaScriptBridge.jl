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
  try
    code = consume(blocks)
    eval(parse(code))
    @emit "evaluated"
  catch err
    @emit "error" string(err) code JSON.json(err)
  end
end
