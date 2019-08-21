import {spawn} from "child_process"
import {parse as _parse, relative, join, resolve as resolvePath} from "path"
import zlib from "zlib"

import moment from "moment"
import "moment-duration-format"

import {curry, binary} from "panda-garden"
import {include, isMatch, w} from "panda-parchment"
import {exists, mkdirp, isDirectory, write as _write, read} from "panda-quill"

print = (_process) ->
  new Promise (resolve, reject) ->
    _process.stdout.on "data", (data) -> process.stdout.write data.toString()
    _process.stderr.on "data", (data) -> process.stderr.write data.toString()
    _process.on "error", (error) ->
      console.error error
      reject()
    _process.on "close", (exitCode) ->
      if exitCode == 0
        resolve()
      else
        console.error "Exited with non-zero code, #{exitCode}"
        reject()


shell = (str, path="") ->
  [command, args...] = w str
  await print await spawn command, args,
    cwd: resolvePath process.cwd(), path

pathWithUnderscore = (path) -> isMatch /(^|\/)_/, path

# Make a directory at the specified path if it doesn't already exist.
safe_mkdir = (path, mode) ->
  if await exists path
    console.warn "#{path} exists. Skipping."
    return

  mode ||= "0777"
  await mkdirp mode, path

# Copy a file to the target, but only if it doesn't already exist.
safe_cp = (original, target) ->
  if await exists target
    console.warn "#{target} exists. Skipping."
    return

  if await isDirectory original
    await shell "cp -R #{original} #{target}"
  else
    await shell "cp #{original} #{target}"

bellChar = '\u0007'

getVersion = ->
  try
    (JSON.parse await read join __dirname, "..", "..", "..", "package.json").version
  catch e
    console.error "Unable to find package.json to determine version."
    throw e

stopwatch = ->
  start = Date.now()
  ->
    d = moment.duration Date.now() - start
    if 0 < d.asSeconds() <= 60
      d.format("s[ s]", 1)
    else if 60 < d.asSeconds() < 3600
      d.format("m:ss[ min]", 0)
    else
      d.format("h:mm[ hr]", 0)

parse = (path) ->
  {dir, name, ext} = _parse path
  path: path
  directory: dir
  name: name
  extension: ext

context = curry (_directory, _path) ->
  {path, directory, name, extension} = parse _path
  path: relative _directory, (join directory, name)
  name: name
  source: {path, directory, name, extension}
  target: {}
  data: {}

write = curry binary (directory, {path, target, source}) ->
  if target.content?
    if !target.path?
      extension = if target.extension?
        target.extension
      else if source.extension?
        source.extension
      else ""
      include target,
        parse (join directory, "#{path}#{extension}")
    await mkdirp "0777", (target.directory)
    await _write target.path, target.content

isCompressible = (buffer) -> buffer.length > 1000

gzip = (buffer, level=9) ->
  new Promise (resolve, reject) ->
    zlib.gzip buffer, {level}, (error, result) ->
      if error
        reject error
      else
        resolve result.toString "base64"

brotli = (buffer, level=10) ->
  new Promise (resolve, reject) ->
    zlib.brotliCompress buffer, {level}, (error, result) ->
      if error
        reject error
      else
        resolve result.toString "base64"

export {pathWithUnderscore, safe_mkdir, safe_cp, bellChar, getVersion, context, write, stopwatch, shell, isCompressible, gzip, brotli}
