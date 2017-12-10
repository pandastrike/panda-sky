module.exports = '''
{
  "url": {
    "path": {
      #foreach($param in $input.params().path.keySet())
      "$param": "$util.escapeJavaScript($input.params().path.get($param))"
      #if($foreach.hasNext),#end
      #end
    },
    "query": {
      #foreach($param in $input.params().querystring.keySet())
      "$param": "$util.escapeJavaScript($input.params().querystring.get($param))"
      #if($foreach.hasNext),#end
      #end
    }
  },
  "method": "$context.httpMethod",
  "headers": {
    #foreach($param in $input.params().header.keySet())
    "$param": "$util.escapeJavaScript($input.params().header.get($param))"
    #if($foreach.hasNext),#end
    #end
  },
  "content" : $input.json('$')
}
'''

