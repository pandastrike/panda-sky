import {flow} from "panda-garden"
import {establishBucket, teardownBucket, scanBucket,
  syncPackage} from "./bucket"
import {syncLambdas, syncLambdaCode} from "./lambdas"
import {syncStacks, teardownStacks} from "./stacks"
import {publishDomain, teardownDomain, invalidateDomain} from "./domain"

publishStack = flow [
  establishBucket
  scanBucket
  syncPackage
  syncStacks
  syncLambdas
]

teardownStack = flow [
  teardownStacks
  teardownBucket
]

export {
  publishStack
  teardownStack
  syncLambdas
  syncLambdaCode
  publishDomain
  teardownDomain
  invalidateDomain
}
