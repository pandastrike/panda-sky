update = require "./update"
tail = require "./tail"

module.exports = (s) ->
  {
    tail: tail s
    update: update s
  }
