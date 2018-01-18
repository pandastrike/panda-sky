debugEquivalents = ["DEBUG", "START", "END", "REPORT"]

parseTime = (d) ->
  pad = (s) -> if s.toString().length == 1 then "0#{s}" else s
  i = (n) -> n + 1
  date = "#{d.getUTCFullYear()}-#{pad i d.getUTCMonth()}-#{pad d.getUTCDate()}"
  time = "#{pad d.getUTCHours()}:#{pad d.getUTCMinutes()}:#{pad d.getUTCSeconds()}.#{d.getUTCMilliseconds()} UTC"
  "#{date} #{time}"

justify = (final, s) -> s + " ".repeat(final - s.length)

space = (one, two, three, four) ->
  one = justify 9, one
  if four
    [one, two, three, four].join "  "
  else
    [one, two, three].join "  "

# Convert the parse object into a normalized string for output or show problem.
normalize = (parsedOutput) ->
  {Type="UNKNOWN", RequestId, Message="", Timestamp} = parsedOutput
  Timestamp = parseTime new Date Timestamp

  switch Type
    when "REPORT"
      output = space "[REPORT]", "#{Timestamp}", "#{RequestId}"
      output +="\n    Duration: #{parsedOutput.Duration}"
      output +="\n    Max Memory Used: #{parsedOutput["Max Memory Used"]}"
      output +="\n    Billed Duration: #{parsedOutput["Billed Duration"]}"
      output +="\n    Memory Size: #{parsedOutput["Memory Size"]}"
    when "UNKNOWN"
      console.error "### Sky is unable to parse this log. Displaying raw data.".yellow
      output = Message
    when "START", "END"
      output = space "[#{Type}]", "#{Timestamp}", "#{RequestId}"
    else
      output = space "[#{Type}]", "#{Timestamp}", "#{RequestId}", "#{Message}"

  # Return the formmatted strings with their appropriate colors.
  switch Type
    when "INFO"
      output.green
    when "START", "END", "REPORT", "DEBUG"
      output.cyan
    when "WARN"
      output.yellow
    when "ERROR"
      output.red
    when "CONSOLE"
      output
    else
      output

module.exports = (isVerbose, e) ->
  if isVerbose
    console.error normalize e
  else if e.Type not in debugEquivalents
    console.error normalize e
