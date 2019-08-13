import {capitalize} from "panda-parchment"

handler = (config) ->
  name = capitalize config.name

  config.environment.apiDocs =
    name: name
    title: "#{name} API Reference"
    description: "Reference for the #{name} API. This document contains a complete and authoritative description of available endpoints, their parameters, requirements, and request/response schema."
    url: "https://#{config.environment.hostnames[0]}"
    favicon: config.environment.favicon
    logo: config.environment.logo

  config

export default handler
