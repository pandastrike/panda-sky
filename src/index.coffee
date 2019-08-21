# Logging.  Output everything to Console Error, but color code based on flag.
import "source-map-support/register"
import "colors"
import moment from "moment"
originalError = console.error
do ->
  __now = ->
    "[" + moment().format("HH:mm:ss").grey + "] "
  console.log = (args...) ->
    originalError __now() + "[sky]".green, args...
  console.warn = (args...) ->
    originalError __now() + "[sky]".yellow, args...
  console.error = (args...) ->
    originalError __now() + "[sky]".red, args...
