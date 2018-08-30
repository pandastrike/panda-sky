module.exports = (config) ->
  # Pull config data for the requested environment.
  {env} = config
  desired = config.aws.environments[env]
  {domain} = config.aws

  # Construct an array of full subdomains to feed the process.
  hostnames = []
  if desired.hostnames
    hostnames.push "#{name}.#{domain}" for name in desired.hostnames
  config.aws.hostnames = hostnames

  # Pull CloudFront (cdn / caching) info into the config
  config.aws.cache = buildCustomDomain desired.cache

  # Internal names for the custom domain stack.
  config.aws.cache.logBucket = "#{config.environmentVariables.fullName}-#{config.projectID}-cflogs"
  config.aws.cache.originID = "customDomain#{config.name}#{config.env}"


  config


defaultHeaders = [
  "Accept",
  "Accept-Charset",
  "Accept-Datetime",
  "Accept-Language",
  "Access-Control-Request-Headers",
  "Access-Control-Request-Method",
  "Authorization",
  "Origin",
  "Referer"
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
      Done.
    """
    process.exit()
  else
    headers

# Accept the cache configuraiton and fill in any default values.
applyDefaults = (config={}) ->
  config.httpVersion ||= "http2"
  config.protocol ||= "TLSv1.2_2018"
  config.expires ||= 0
  config.priceClass ||= 100
  config.headers = setHeaders config.headers
  config.originID =

  config

applyFirewall = (config) ->
  if !config.waf
    config.waf = false
  else
    config.waf =
      floodThreshold: config.waf.floodThreshold || 2000
      errorThreshold: config.waf.errorThreshold || 50
      blockTTL: config.waf.blockTTL || 240
  config

buildCustomDomain = (config={}) ->
  config = applyDefaults config
  config = applyFirewall config
