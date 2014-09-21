function stdinProducer()
  while true
    produce(read(STDIN, Char))
  end
end

function codeBlockProducer()
  input = @task stdinProducer
  code = ""
  while true
    newChar = consume(input)
    if newChar == BLOCK_SEPARATOR
      produce(code)
      code = ""
    else
      code = string(code, newChar)
  end
end
