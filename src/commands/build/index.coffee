import {go, tee, pull} from "panda-river"
import {values, toJSON} from "panda-parchment"
import {exists, write} from "panda-quill"
import pug from "pug"
import MarkdownIt from "markdown-it"
import emoji from "markdown-it-emoji"

markdown = do (p = undefined) ->
  p = MarkdownIt
    linkify: true
    typographer: true
    quotes: '“”‘’'
  .use emoji
  (string) -> p.render string

import transpile from "./transpile"
import {safe_mkdir, bellChar, outputDuration, shell, isCompressible, gzip, brotli} from "../../utils"
import compile from "../../configuration"


START = 0
Build = (stopwatch, env, {profile}) ->
  try
    source = "src"
    target = "lib"
    manifest = "package.json"

    if !(await exists manifest)
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit -1

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.log "  -- Wiping out build directories"
    await shell "rm -rf deploy #{target} node_modules package-lock.json"

    console.log "  -- Pipelining project code"
    await safe_mkdir target
    await transpile source, target

    # Run npm install for the developer.  Only the stuff going into Lambda
    console.log "  -- Building deploy package"
    console.log "    -- Pulling production dependencies..."
    await shell "npm install --only=production --silent"
    await shell "cp -r node_modules/ #{target}/node_modules/" if await exists "node_modules"

    # Now install everything, including dev-dependencies
    console.log "    -- Pulling local dependencies..."
    await shell "npm install --silent"

    console.log "    -- Applying environment configuration..."
    console.log "        - Compiling environment configuration..."
    config = await compile process.cwd(), env, profile

    console.log "        - Packaging API definition..."
    file = Buffer.from toJSON resources: config.resources
    await safe_mkdir "#{target}/api/json"
    await write "#{target}/api/json/identity", file
    await write "#{target}/api/json/gzip", await gzip file
    await write "#{target}/api/json/brotli", await brotli file

    console.log "        - Packaging API documentation..."
    file = pug.render config.environment.templates.apiDocs,
      filters: {markdown}

    await safe_mkdir "#{target}/api/html"
    await write "#{target}/api/html/identity", file
    await write "#{target}/api/html/gzip", await gzip file
    await write "#{target}/api/html/brotli", await brotli file



    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    console.log "    -- Compressing final deploy package..."
    await safe_mkdir "deploy"
    await shell "zip -qr -9 deploy/package.zip lib"

    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

export default Build
