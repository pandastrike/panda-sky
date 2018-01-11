{join} = require "path"
program = require "commander"
{call, read, write, collect, project, empty} = require "fairmont"

require "./index"
{run} = require "panda-9000"

{bellChar} = require "./utils"
COMMANDS = require "./commands"
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
    .action (options) -> COMMANDS.build START

  program
    .command "init [name]"
    .option "-d, --demo", "Add a reference implementaiton to demo a feature"
    .action (name, options) -> COMMANDS.init name, options

  program
    .command "publish [env]"
    .option '-o, --output [output]', 'Path to write API config file'
    .action (env, options) ->
      return if noEnv env
      COMMANDS.publish START, env, options

  program
    .command "delete [env]"
    .action (env) ->
      return if noEnv env
      COMMANDS.destroy START, env

  program
    .command "render [env]"
    .action (env) ->
      return if noEnv env
      COMMANDS.render env

  program
  .command "update [env]"
  .action (env) ->
    return if noEnv env
    COMMANDS.update START, env

  program
  .command "domain [subcommand] [env]"
  .option '--hard', 'In domain publish, use hard rollover for replacements.'
  .option '--yes', "Always answer warning prompts with yes. Use with caution."
  .action (subcommand, env, options) ->
    if domain[subcommand]
      return if noEnv env
      COMMANDS.domain[subcommand] START, env, options
    else
      console.error "ERROR: unrecognized subcommand of sky domain."
      program.help()

  program
    .command "mixin [name] [env] [others...]"
    .allowUnknownOption()
    .action (name, env, others) ->
      return if noEnv env
      COMMANDS.mixin name, env, process.argv

  program
    .command('*')
    .action -> program.help()

  # TODO: This should be more detailed, customized for each subcommand, and
  # automatically extended with new commands and flags.  For now, this will
  # need to do.
  program.help = -> console.error COMMANDS.help

  # Begin execution.
  program.parse process.argv
