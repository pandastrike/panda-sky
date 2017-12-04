# TODO - This is the code that was previously used to pull in mixins.  But we
# only had basic support for S3.  We'll come back here when we hammer out the
# mixin model.

mixinNames = yield listMixins appRoot
for name in mixinNames
  resources.push yield renderMixin appRoot, name, globals
# Each mixin template may define a number of CloudFormation Resources. We
# merge them in a blind manner, so it is possible for one mixin to clobber a
# Resource key supplied by a predecessor. Predictability depends on the order
# of results returned by `fairmont.readdir`.
merge resources...

renderMixin = async (dir, name, globals) ->

  # TODO: template = getMixinTemplate(name)
  template = yield read resolve skyMixinsPath, "#{name}.yaml"

  # FIXME: This is a good indication that the Sky API description
  # isn't the same kind of mixin as the other mixins.
  dataPath = if name == "api" then "api" else "mixins/#{name}"

  # acquire the parameters for this particular mixin from the app files
  mixinConfig = yaml yield read resolve dir, "#{dataPath}.yaml"

  # FIXME: should globals be winning over mixin-specific params?
  mungedConfig = merge mixinConfig, globals

  preprocessor = preprocessors[name]
  mungedConfig = yield preprocessor mungedConfig
  yaml _render template, mungedConfig


listMixins = async (appRoot) ->
  mixinPath = resolve appRoot, "mixins"
  mixins = []

  if yield exists mixinPath
    files = yield readdir mixinPath
    for file in files when isFile file
      mixins.push basename file, ".yaml"
  mixins

renderMixins = (appRoot, globals) ->


module.exports = {renderMixins}
