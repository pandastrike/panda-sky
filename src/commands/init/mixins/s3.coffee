export default {
  questions: [
    name: "s3"
    description: "Add sky-mixin-s3 as a dev-dependency to package.json? [Y/n]"
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
    s3: "npm install sky-mixin-s3 --save-dev"
    ps: "npm install panda-sky-helpers --save"
    yaml: "npm install js-yaml --save"
  config: (projectID) ->
    projectID: projectID
    buckets: ["sky-#{projectID}-alpha", "sky-#{projectID}-beta"]
}
