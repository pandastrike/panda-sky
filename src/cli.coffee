{join} = require "path"
program = require "commander"
{call, read, write, collect, project, empty} = require "fairmont"

require "./index"
{run} = require "panda-9000"

{bellChar} = require "./utils"
help = require "./commands/help"
init = require "./commands/init"
render = require "./commands/render"
build = require "./commands/build"
publish = require "./commands/publish"
destroy = require "./commands/delete"
update = require "./commands/update"
domain = require "./commands/domain"

START = new Date().getTime()
call ->

  noEnv = (env) ->
    if !env
      console.error "ERROR: You must supply an environment name for this subcommand."
      program.help()
      true
    else
      false

  {version} = JSON.parse yield read join __dirname, "..", "package.json"

  program
    .version(version)

  program
    .command "build"
    .action (options) -> build START

  program
    .command "init"
    .action -> init START

  program
    .command "publish [env]"
    .option '-o, --output [output]', 'Path to write API config file'
    .action (env, options) ->
      return if noEnv env
      publish START, env, options

  program
    .command "delete [env]"
    .action (env) ->
      return if noEnv env
      destroy START, env

  program
    .command "render [env]"
    .action (env) ->
      return if noEnv env
      render env

  program
  .command "update [env]"
  .action (env) ->
    return if noEnv env
    update START, env

  program
  .command "domain [subcommand] [env]"
  .option '--hard', 'In domain publish, use hard rollover for replacements.'
  .option '--yes', "Always answer warning prompts with yes. Use with caution."
  .action (subcommand, env, options) ->
    if domain[subcommand]
      return if noEnv env
      domain[subcommand] START, env, options
    else
      console.error "ERROR: unrecognized subcommand of sky domain."
      program.help()

  program
    .command('*')
    .action -> program.help()

  # TODO: This should be more detailed, customized for each subcommand, and
  # automatially extended with new commands and flags.  For now, this will
  # need to do.
  program.help = -> console.error help

  # Begin execution.
  program.parse process.argv
