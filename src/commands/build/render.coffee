import pug from "pug"
import MarkdownIt from "markdown-it"
import emoji from "markdown-it-emoji"

markdown = do (p = undefined) ->
  p = MarkdownIt
    linkify: true
    typographer: true
    quotes: '“”‘’'
  .use emoji
  (string) -> p.render string

render = (config) ->
  pug.render config.environment.templates.apiDocs,
    filters: {markdown}

export default render
