# A scan of the current domain configuration and available AWS resources is
# needed to confirm that Sky can accomplish the requested operation.
{async} = require "fairmont"

module.exports = (s) ->
  isViable: async ->
    yield "hello"
    # Check to make sure a hostname is specified
    # Check to make sure a public hosted zone exists to support that hostname
    # Check to make sure we have the ACM cert for that domain

    # Check to make sure we have deployment for this hostname



fail = (msg) ->
  console.error msg
  console.error "This process will now discontinue.\nDone.\n"
  process.exit()

hostnameMSG = """

"""

domainMSG = """

"""

ACMMSG = """

"""

deploymentMSG = """

"""
