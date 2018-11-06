import {isArray} from "panda-parchment"

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
  names = config.aws.environments[config.env].hostnames || []
  {domain} = config.aws
  hostnames = []
  hostnames.push "#{name}.#{domain}" for name in names
  hostnames

# Accept the cache configuraiton and fill in any default values.
applyDefaults = (config) ->
  cache = config.aws.environments[config.env].cache || {}
  cache.httpVersion ||= "http2"
  cache.protocol ||= "TLSv1.2_2018"
  cache.priceClass ||= 100
  cache.headers = setHeaders cache.headers
  cache.originID = "Sky-" + config.aws.stack.name

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

  cache

applyFirewall = (config) ->
  {waf} = config.aws.cache
  if !waf
    false
  else
    floodThreshold: waf.floodThreshold || 2000
    errorThreshold: waf.errorThreshold || 50
    blockTTL: waf.blockTTL || 240

Domains = (config) ->
  # Construct an array of full subdomains to feed the process.
  config.aws.hostnames = applyHostnames config

  # Apply smart defaults for CloudFront.
  config.aws.cache = applyDefaults config

  # Expand the firewall configuation
  config.aws.cache.waf = applyFirewall config

  # Internal names for the custom domain stack.
  config.aws.cache.logBucket = "#{config.environmentVariables.fullName}-#{config.projectID}-cflogs"
  config.aws.cache.originID = "customDomain#{config.name}#{config.env}"
  config

export default Domains
