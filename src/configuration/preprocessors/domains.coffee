import {isArray, camelCase} from "panda-parchment"
import {flow} from "panda-garden"

defaultHeaders = [
  "Accept",
  "Access-Control-Request-Headers",
  "Access-Control-Request-Method",
  "Authorization",
  "Origin"
]

setHeaders = (headers) ->
  if !headers
    defaultHeaders
  else if "*" in headers && headers.length > 1
    console.error """
      ERROR: Incorrect header cache specificaton.  Wildcard cannot be used with
      other named headers.  Please adjust the cache configuration for this
      environment within sky.yaml and try again.

      This process will discontinue.
    """
    console.log "Done."
    process.exit()
  else
    headers

applyHostnames = (config) ->
  config.environment.hostnames = do ->
    "#{name}.#{config.domain}" for name in config.environment.hostnames
  config

# Accept the cache configuraiton and fill in any default values.
applyDefaults = (config) ->
  cache = config.environment.cache || {}
  cache.httpVersion ?= "http2"
  cache.protocol ?= "TLSv1.2_2018"
  cache.priceClass ?= 100
  cache.headers = setHeaders cache.headers
  cache.originID = "Sky-" + config.stack.name
  cache.origin = "alb-#{config.environment.hostnames[0]}"
  cache.hostedzone = config.environment.hostedzone
  cache.certificate =  config.environment.certificate
  cache.stack = config.environment.stack.name + "-custom-domain"

  if !cache.ttl
    cache.ttl = {min: 0, max: 0, default: 0}
  else if !isArray cache.ttl
    cache.ttl = {min: 0, max: cache.ttl, default: cache.ttl}
  else
    cache.ttl = {min: cache.ttl[0], max: cache.ttl[1], default: cache.ttl[2]}

  if cache.paths
    for item in cache.paths
      if !isArray item.ttl
        item.ttl = {min: 0, max: item.ttl, default: item.ttl}
      else
        item.ttl = {min: item.ttl[0], max: item.ttl[1], default: item.ttl[2]}

  config.environment.cache = cache
  config

applyFirewall = (config) ->
  {waf} = config.environment.cache
  if !waf
    config.environment.cache.waf = false
  else
    {name} = config.environment.variables
    config.environment.cache.waf =
      logBucket: "#{name}-#{config.projectID}-cflogs"
      floodThreshold: waf.floodThreshold ? 2000
      errorThreshold: waf.errorThreshold ? 50
      blockTTL: waf.blockTTL ? 240

  config

Domains = flow [
  applyHostnames
  applyDefaults
  applyFirewall
]

export default Domains
