require "./build"
require "./delete"
require "./init"
require "./publish"
require "./render"
require "./survey"
require "./update"
require "./watch"

module.exports = (AWS) -> require("./sky-helpers")(AWS)
