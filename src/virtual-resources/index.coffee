import {flow} from "panda-garden"
import {establishBucket, teardownBucket, scanBucket} from "../bucket"
import {syncLambdas} from "../lambdas"
import {syncStacks, teardownStacks} from "../stacks"

publish = flow [
  establishBucket
  scanBucket
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
}
