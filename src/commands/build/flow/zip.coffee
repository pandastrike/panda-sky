import {resolve, basename} from "path"
import {mkdirp, read, write} from "panda-quill"
import JSZip from "jszip"


zip = (source, target) ->
  Zip = new JSZip()

  name = basename source
  data = await read source, "buffer"
  Zip.file name, data,
    date: new Date "2019-08-12T19:17:56.050Z" # Lie to get consistent hash
    createFolders: false

  archive = await Zip.generateAsync
    type: "nodebuffer"
    compression: "DEFLATE"
    compressionOptions: level: 9

  await write target, archive

# Compress the webpacked code for delivery to S3. We use JSZip to avoid system
# calls on platofroms that lack `zip` and to ensure we get a
# timestamp-independent hash when publishing lambdas.
handler = (config) ->
  await mkdirp "0777", "deploy"
  await zip (resolve "build", "main", "sky.js"),
    (resolve "deploy", "package.zip")

  await mkdirp "0777", resolve "deploy", "workers"
  for name of config.environment.workers
    await zip (resolve "build", "workers", name, "index.js"),
      (resolve "deploy", "workers", "#{name}.zip")

  for name of config.environment.cache.edges
    await zip (resolve "build", "edges", name, "index.js"),
      (resolve "deploy", "edges", "#{name}.zip")

  config


export default handler
