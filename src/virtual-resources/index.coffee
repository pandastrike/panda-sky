import {flow} from "panda-garden"
import {establishBucket, teardownBucket, scanBucket, syncPackage} from "../bucket"
import {syncLambdas, syncLambdaCode} from "../lambdas"
import {syncStacks, teardownStacks} from "../stacks"

publish = flow [
  establishBucket
  scanBucket
  syncPackage
  syncStacks
  syncLambdas
]

_delete = flow [
  teardownStacks
  teardownBucket
]

export {
  publish
  delete:_delete
  syncLambdas
  syncLambdaCode
}
