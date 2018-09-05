import {resolve} from "path"
import JSCK from "jsck"
import {read, merge, keys} from "fairmont"
import {yaml} from "panda-serialize"
import SDK from "aws-sdk"
import Sundog from "sundog"

import API from "./api"
import SKY from "./sky"

import preprocess from "./preprocessors"
import render from "./cloudformation"

compile = (appRoot, env, profile="default") ->
  sky = await readSky appRoot, env  # sky.yaml
  api = await readAPI appRoot       # api.yaml
  config = merge api, sky, {env, profile}

  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: sky.aws.region
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS

  if env
    # Run everything through preprocessors to get final config.
    config = await preprocess config
    config.aws.templates = await render config

  config

readAPI = (root) ->
  try
    await API.read resolve root, "api.yaml"
  catch e
    console.error "Unable to read API description."
    console.error e
    process.exit()


readSky = (root, env) ->
  try
    await SKY.read root, env
  catch e
    console.error "Unable to read Sky description."
    console.error e
    process.exit()

export default {compile}
