import JSON
include("./lib/codeBlockProducer.jl")

blocks = Task(codeBlockProducer)

macro emit(event, data...)
  :(
    println(JSON.json(["event"=>$event,"data"=>[$(data...)]]))
  )
end

@emit "ready"

while true
  code = ""
  try
    code = consume(blocks)
    eval(parse(code))
  catch err
    @emit "error" string(err) code JSON.json(err)
  end
end
