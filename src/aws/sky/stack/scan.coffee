{async} = require "fairmont"
interview = require "../../../interview"

module.exports = (s) ->
  # Determine whether an update is required or if the deployment is up-to-date.
  scan = async ->
    app = yield s.meta.current.fetch()
    if !app
      console.error "-- No deployment metadata detected."
      yield override() if yield s.cfo.get()
      console.error "-- Setting up for new deployment."
      return yield s.meta.create()

    console.error "-- Existing deployment metadata detected."
    yield s.meta.update() # Updates to desired config, not "current" hashes.
    yield s.meta.current.check app

  # Ask politely if an override is neccessary.
  override = async ->
    interview.setup()
    questions = [
      name: "override"
      description: """
        WARNING: A stack with the name #{s.stackName} already exists, but it
        does not seem to be managed by Sky.  Would you like Sky to override?
        This is a destructive operation. [Y/n]
      """
      default: "n"
    ]

    answers = yield interview.ask questions
    if answers.override
      console.error "Attempting to remove non-Sky stack..."
      yield s.cfo.delete()
      yield s.cfo.deleteWait()
      console.error "Removal complete.  Continuing with publish."
    else
      console.error "Discontinuing publish."
      console.error "Done."
      process.exit()

  {scan}
