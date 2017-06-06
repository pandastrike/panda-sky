{writeFileSync} = require "fs"
path = require "path"
{go, tee, pull, values, async, lift, shell, exists, isDirectory} = require "fairmont"
{define, write} = require "panda-9000"
rmrf = lift require "rimraf"

{safe_mkdir} = require "../utils"

# Output to stderr the command you're about to run
shellv = (command) ->
  console.error command
  shell command

chdir = (dir) ->
  console.error "cd #{dir}"
  process.chdir dir

define "build", async ->
  try
    yield rmrf "deploy"
    yield safe_mkdir "deploy"

    cwd = process.cwd()
    if !(yield isDirectory "api")
      console.error "No api directory found"
      process.exit(1)
    chdir "api"
    if !(yield exists "package.json")
      console.error "This api directory does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit(1)

    # Applications are responsible for their own coffeescript compilation.
    # You can use a 'postinstall' script in the package.json to automate this.
    yield shellv "npm install --production --silent"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    # TODO: Investigate using `npm pack` with bundledDependencies.
    yield shellv "cp -r node_modules/ lib/node_modules/" if yield exists "node_modules"
    yield shellv "zip -qr ../deploy/package.zip lib"
    chdir cwd

  catch e
    console.error e.stack
