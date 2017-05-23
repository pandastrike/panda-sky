# Panda Sky

_Quicky publish severless APIs to AWS._

## Install
Install `panda-sky` as a global package, granting you access to the `sky`
executable.

    npm install -g panda-sky

Make sure you have an AWS account, and that you store your credentials at
`~/.aws/credentials`.
> If you don't have an Amazon Web Services (AWS) account currently, stop here,
go [signup and get CLI access credentials](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html)
 and then come back here.

## Quick Start
These commands will take you from start to functioning deployment that you can
iterate on.

    mkdir hello-sky && cd hello-sky
    npm init
    sky init
    sky build
    sky publish staging

In about 60 seconds, you will see a message like this:
> Your API is online and ready at the following endpoint:
>   https://<API-ID>.execute-api.us-west-2.amazonaws.com/staging

If you direct your browser to
https://<API-ID>.execute-api.us-west-2.amazonaws.com/staging/greeting/World, you will
see the test message from the API you just deployed.  Adding your name to the
URL path will change the page, a simple demonstration dynamic behavior.  

You can also view a description of the API by directing a request against the API
 root, https://<API-ID>.execute-api.us-west-2.amazonaws.com/staging

## What Panda Sky Does
This is a slightly more detailed walkthrough that includes how to give your application a custom domain and have Panda Sky setup the Route53 routing on your behalf.

### Initialize your app.

    mkdir greeting-api && cd greeting-api
    npm init
    sky init

Panda Sky needs a `package.json` to anchor your project's dependencies when it gathers them and sends them to AWS to be used within a Lambda.  `sky init` gives you the starter files for a project.

### Define your API.

Edit your `api.yaml`.  This file is the authoritative description of your API.  Panda Sky uses it to build an API within the API Gateway platform.  Each method is mapped to a corresponding Lambda that gets invoked when the method's handler recieves an HTTP request.

```yaml
resources:

  greeting:

    path: "/greeting/{name}"
    description: Returns a greeting for {name}.

  methods:

    get:
      method: GET
      signature:
        status: 200
        accept: text/html
```

### Define a handler.

Add a JavaScript file under `src/sky.js`:

Lambdas execute Javascript code compatible with Node 6.10.  Lambdas accept context
from the corresponding Gateway method's HTTP request.  After executing arbitrary
code, the result is returned in the callback and sent as the response in the
Gateway method.  

The code snippet below shows a section of the template code `sky init` drops
into your repo.  This method is invoked when the `GET` method is used in a
request against the `greeting` resource.  Edits here affect the API's response.

```javascript
API[`${fullName}-greeting-get`] = async( function*(data, context, callback) {
  var message, name;
  name = data.name || "World";
  message = `<h1>Hello, ${name}!</h1>`;
  message += "<p>Seeing this page indicates a successful deployment of your test API with Panda Sky!</p>";
  return callback(null, message);
});
```

### Environmental Variables
Panda Sky supports the injection of environmental variables into your Lambda's context.  These can be accessed from the `process` Node variable.

> Currently within api.yaml, however this may be moved into sky.yaml so they can be set on a per-environment basis.
```yaml
variables:
  foobar: This optional value is injected into the Lambda context
```
> sky.js
```javascript
var {foobar} = process.env;
```  

## Built-in Helpers
Panda Sky comes with helpers to ease development within a Lambda environment:
```coffeescript
# Import Panda Sky Helpers
{async, response, s3} = require "panda-sky"
```
### async
`async` is the function from `fairmont`, but it allows end users to pull it in without the whole library.

### s3
- `s3` is a wrapper around the AWS SDK library for S3.

```coffeescript
{get, put, del} = s3 BucketName
data = yield get "foobar.yaml"
```

The `get`, `put`, and `del` methods do what they say.  They are promises you can either chain `.then` or use ES6's yield / generator construct with.  They are very thin wrappers, either succeeding or returning an error directly from the AWS library.

### response
To invoke a given response within a Lambda, use the response class from Panda Sky
```coffeescript
# Import Panda Sky Helpers
{response} = require "panda-sky"
new response.NotFound("Unable to locate the blog post in the database")
new response.Unauthorized("You must login to access this resource")
new response.ServiceUnavailable("Try again in 30 minutes")
```

It takes the form:
```
new response.<Response Type>(<Optional message>)
```

> Note that responses must be explicitly definied within the API description.



## Custom Domains

In order to publish your API to production, you need a domain to publish it to.
[You need to tell AWS about it and acquire an SSL (TLS) cert][domain-setup].

[domain-setup]:https://www.pandastrike.com/open-source/haiku9/publish/aws-setup

### Add The Domain To Your Configuration

Add the name of your API and the domain to your `sky.yaml` file:

This file tracks the overall configuration for your app.  Panda Sky divides
configuration between "environments" to group related config within one cli
target.  It allows you to switch your environment target without repeatedly
editing this file.

The `cache` stanza holds configuration for CloudFront distributions, which
provides both edge caching for your API responses and custom domain assignment.
Please note that setting up a distribution is time-intensive.  It can take 15-30
minutes to setup and sync your allocation across AWS's global constellation of
edge servers.

```yaml
name: greeting
description: Greeting API
aws:
  runtime: nodejs6.10
  domain: greeting.com
  region: us-west-2
  environments:

    staging: {}

    production:
      hostnames:
        - api
      cache:
        expires: 1800
        ssl: true
        priceClass: 100
```

### Publish Your API

This will take a while the first time around,
(Panda Sky is doing a lot of set up for you)
but after that, it's relatively quick.

    sky publish production

### Test It Out

    curl https://greeting.com/greeting/Ace
    Hello, Ace!

## Status

Panda Sky is in beta.

