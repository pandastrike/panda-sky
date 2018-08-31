{regexp, many, any, all, rule, grammar} = require "panda-grammar"
{merge} = require "fairmont"
require "colors"

validTypes = ["ERROR", "WARN", "INFO", "DEBUG", "START", "END", "REPORT"]

# Temp fix for bug in Bartlett.  TODO: Make this change in Bartlett.
regexp = (re) ->
  (s) ->
    if (match = s.match(re))?
      [value] = match
      rest = s[value.length..]
      {value, rest}

validate = (p, f) ->
  (s) ->
    result = p(s)
    if result && f result then result else null

finish = (f) ->
  (s) ->
    result = f(s)
    result.rest = '' if result
    result

# General helpers parsers to identify message type and when everything ends.
_type = rule (regexp /^[A-Z]+/), ({value}) -> Type: value
type = validate _type, ({value: {Type}}) -> Type in validTypes
eol = regexp /^\n$/

# Parsers for system messages from Lambdas: START, END, REPORT
name = regexp /^[\w\s]+/
delimiter = regexp /^\:/
value  = rule (regexp /^\s?[^\s]*\s/), ({value}) -> value.trim()
tabbedValue = rule (regexp /^\s?[^\t]*(\t|\n$)/), ({value}) -> value.trim()

field = (valueRule) ->
  rule (all name, delimiter, valueRule),
    ({value: [name, , value]}) -> [name.trim()]: value.trim()
fields = (fieldRule) ->
  rule (many fieldRule), ({value}) -> merge value...

report = rule (all type, (fields (field tabbedValue)), eol),
  ({value: [type, fields]}) -> merge type, fields

simple = rule (all type, (fields (field value))),
  ({value: [type, fields]}) -> merge type, fields

# Parsers for the explicit console messages, written manually by developers.
namedLevel = finish rule type,
  ({value: {Type}, rest}) -> {Type, Message: rest.trim()}
noLevel = (s) -> value: { Type: "CONSOLE", Message: s.trim()}, rest: ''
message = any namedLevel, noLevel
manual = rule (all tabbedValue, tabbedValue, message),
  ({value: [Timestamp, RequestId, {Type, Message}]}) ->
    {Timestamp, RequestId, Type, Message}

fallback = (s) -> value: { Type: "UKNOWN", Message: s}, rest: ''

parse = grammar any report, simple, manual, fallback

module.exports = ({timestamp, message}) ->
  output = parse(message) || {}
  merge output, Timestamp: timestamp
