require "./commands/build"
require "./commands/delete"
require "./commands/init"
require "./commands/publish"
require "./commands/update"

module.exports = (AWS) -> require("./sky-helpers")(AWS)
