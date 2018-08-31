export default {
  questions: [
    name: "kms"
    description: "Add sky-mixin-kms as a dev-dependency to package.json? [Y/n]"
    default: "Y"
  ,
    name: "ps"
    description: "Add panda-sky-helpers as a dependency to package.json? [Y/n]"
    default: "Y"
  ,
    name: "yaml"
    description: "Add js-yaml as a dependency to package.json? [Y/n]"
    default: "Y"
  ]
  actions:
    kms: "npm install sky-mixin-kms --save-dev"
    ps: "npm install panda-sky-helpers --save"
    yaml: "npm install js-yaml --save"
  config: (projectID) ->
    projectID: projectID
}
