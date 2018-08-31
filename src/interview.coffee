import prompt from "prompt"

Interview

  # Initialize the interviewer.  Remove the default settings, start `prompt`
  setup: ->
    prompt.message = ""
    prompt.delimiter = ""
    prompt.start()

  # Execute the interview.  Wrap the menthod in a promise to use ES6 style.
  ask: (questions) ->
    new Promise (resolve, reject) ->
      prompt.get questions, (error, answers) ->
        if error?
          reject error
        else
          # Map boolean-esque answers onto "true" and "false" values.
          for k of answers
            if answers[k] in ["yes", "Yes", "YES", "y", "Y", "true", "True"]
              answers[k] = true
            if answers[k] in ["no", "No", "NO", "n", "N", "false", "False"]
              answers[k] = false

          resolve answers

export default Interview
