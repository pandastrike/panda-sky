update = require "./update"
tail = require "./tail"
Delete = require "./delete"

module.exports = (s) ->
  {
    tail: tail s
    update: update s
    delete: Delete s
  }
