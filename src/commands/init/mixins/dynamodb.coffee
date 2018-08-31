export default {
  questions: [
    name: "dynamodb"
    description: "Add sky-mixin-dynamodb as a dev-dependency to package.json? [Y/n]"
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
    dynamodb: "npm install sky-mixin-dynamodb --save-dev"
    ps: "npm install panda-sky-helpers --save"
    yaml: "npm install js-yaml --save"
  config: (projectID) ->
    projectID: projectID
    tableName: "sky-staging-alpha"
}
