{join} = require "path"
program = require "commander"
{call, read, write, collect, project, empty} = require "fairmont"

require "./index"
{run} = require "panda-9000"

{bellChar} = require "./utils"
help = require "./commands/help"
render = require "./commands/render"
build = require "./commands/build"
publish = require "./commands/publish"
domain = require "./commands/domain"

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
    .command('build')
    .description('compile the API, Lambdas, and resources to prepare for publishing.')
    .action (options) -> build()

  program
    .command('init')
    .description('Initialize a Panda Sky project.')
    .action(-> run "init")

  program
    .command('publish [env]')
    .description('Deploy API, Lambdas to AWS infrastructure')
    .option '-o, --output [output]', 'Path to write API config file'
    .action (env, options) ->
      return if noEnv env
      publish env, options

  program
    .command('delete [env]')
    .description('Delete API, Lambdas from AWS infrastructure')
    .action (env) ->
      return if noEnv env
      run "delete", [env]

  program
    .command('render [env]')
    .description('Render the CloudFormation template to STDERR')
    .action (env) ->
      return if noEnv env
      render(env)

  program
  .command('update [env]')
  .description('Update *only* the Lambda code for an environment')
  .action (env) ->
    return if noEnv env
    run "update", [env]

  program
  .command('domain [subcommand] [env]')
  .option '--hard', 'In domain publish, use hard rollover for replacements.'
  .option '--yes', "Always answer warning prompts with yes. Use with caution."
  .action (subcommand, env, options) ->
    if domain[subcommand]
      return if noEnv env
      domain[subcommand] env, options
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
