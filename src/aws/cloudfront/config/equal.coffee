{deepEqual} = require "assert"

module.exports = do ->
  # Within a CloudFront distribution configuration, arrays need not be
  # congruent, but merely a permutation of a given set. This recursive helper
  # normalizes arrays within nested objects so that we can safely apply a
  # deepEqual to compare current and new configurations.
  deepSort = (o) ->
    if Array.isArray o
      o.sort()
    else if typeof o == "object"
      n = {}
      n[k] = deepSort v for k,v of o
      n
    else
      o

  # Compare two normalized CloudFront distribution configurations.
  (currentConfig, newConfig) ->
    deepEqual deepSort(currentConfig), deepSort(newconfig)
