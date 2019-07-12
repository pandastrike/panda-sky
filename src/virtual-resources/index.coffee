import {flow} from "panda-garden"
import {establishBucket, uploadTemplates, deleteBucket} from "../bucket"
import {updateLambdas} from "../lambdas"
import {publishStacks, deleteStacks} from "../stacks"

publish = flow [
  establishBucket
  syncTemplates
  publishStacks
  updateLambdas
]

_delete = flow [
  deleteStacks
  deleteBucket
]

export {publish, delete:_delete, updateLambdas}
