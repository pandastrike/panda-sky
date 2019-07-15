# This sets up an existing directory to hold a Panda Sky project. There are
# different flavors to showcase different mixins.
# TODO: Where are randomWords in the decendants of Fairmont?
import Interview from "panda-interview"
import {values, merge} from "panda-parchment"
import MIXINS from "./mixins"
import render from "./render"

init = (name="core") ->
  throw new Error "this command is not currently available"
  # try
  #   {questions, actions, config} = MIXINS[name]
  #   if !questions
  #     console.error "ERROR: Unknown mixin, #{name}, specified.  Unable to continue."
  #     console.log "Done."
  #     process.exit()
  #
  #   console.log "Press ^C at any time to quit."
  #   try
  #     {ask} = new Interview()
  #     answers = await ask questions
  #   catch e
  #     console.warn "Process aborted."
  #     console.log "Done."
  #     process.exit()
  #
  #   if true in values answers
  #     console.log "Adding module(s). One moment..."
  #     for key, answer of answers when answers[key]
  #       await shell actions[key]
  #
  #   config = config await randomWords 6
  #   await render name, config
  #   console.log "Panda Sky project initialized."
  # catch e
  #   console.error e.stack
  # console.log "Done."

export default init
