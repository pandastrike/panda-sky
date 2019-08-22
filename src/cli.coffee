import program from "commander"
import "./index"
import {bellChar, getVersion, stopwatch} from "./utils"
import COMMANDS from "./commands"

do ->
  version = await getVersion()

  noEnv = (env) ->
    if !env
      console.error "ERROR: You must supply an environment name for this subcommand."
      program.help()
      true
    else
      false

  program
    .version(version)

  program
    .command "build [env]"
    .action (env, options) ->
      return if noEnv env
      timer = stopwatch()
      await COMMANDS.build env, options
      console.log "Done. (#{timer()})"

  program
    .command "init [name]"
    .action (name) -> COMMANDS.init name

  program
    .command "publish [env]"
    .option '-o, --output [output]', 'Path to write API config file'
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .option '-f, --force', 'republish environment without state checks'
    .action (env, options) ->
      return if noEnv env
      COMMANDS.publish stopwatch(), env, options

  program
    .command "delete [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      COMMANDS.destroy stopwatch(), env, options

  program
    .command "render [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      COMMANDS.render env, options

  program
  .command "update [env]"
  .option '-p, --profile [profile]', 'Name of AWS profile to use'
  .option '-h, --hard', "Issues a full update that includes configuration"
  .action (env, options) ->
    return if noEnv env
    COMMANDS.update stopwatch(), env, options

  program
    .command "tail [env]"
    .option '-v, --verbose', 'output debug level logs'
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      COMMANDS.tail env, options

  program
    .command "list"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (options) -> COMMANDS.list options

  program
    .command "test [env] [others...]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .allowUnknownOption()
    .action (env, others, options) ->
      return if noEnv env
      COMMANDS.test env, options, process.argv

  program
  .command "domain [subcommand] [env]"
  .option '--hard', 'In domain publish, use hard rollover for replacements.'
  .option '--yes', "Always answer warning prompts with yes. Use with caution."
  .option '-p, --profile [profile]', 'Name of AWS profile to use'
  .action (subcommand, env, options) ->
    if COMMANDS.domain[subcommand]
      return if noEnv env
      COMMANDS.domain[subcommand] stopwatch(), env, options
    else
      console.error "ERROR: unrecognized subcommand of sky domain."
      program.help()

  program
    .command "mixin [name] [env] [others...]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .allowUnknownOption()
    .action (name, env, others, options) ->
      return if noEnv env
      COMMANDS.mixin name, env, options, process.argv

  program
    .command "secret [env]"
    .action (env) ->
      return if noEnv env
      COMMANDS.secret env

  program
    .command('*')
    .action -> program.help()

  # TODO: This should be more detailed, customized for each subcommand, and
  # automatically extended with new commands and flags.  For now, this will
  # need to do.
  program.help = -> console.log COMMANDS.help

  # Begin execution.
  program.parse process.argv
