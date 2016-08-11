# Panda Sky

_Quicky publish severless APIs to AWS._

## Install

    npm install -g panda-sky

## Quick Start

### Initialize your app.

    mkdir greeting-api && cd greeting-api
    sky init
    
### Define your API.

Edit your `api.yaml`:

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
```

### Define a handler.

Add a JavaScript file under `lib/sky.js`:

```javascript
module.exports = (data, context, callback) => callback `Hello ${data.name}!`
```

### Set Up Your Domain

In order to publish your API, you need a domain to publish it to.
[You need to tell AWS about it and acquire an SSL (TLS) cert][domain-setup].

[domain-setup]:https://www.pandastrike.com/open-source/haiku9/publish/aws-setup

### Add The Domain To Your Configuration

Add the name of your API and the domain to your `sky.yaml` file:

```yaml
name: greeting
description: Greeting API
aws:
  domain: greeting.com
  region: us-west-2
  environments:
  
    staging:
      hostnames:
        - staging-api
      cache:
        expires: 0
        ssl: true
        priceClass: 100

    production:
      hostnames:
        - api
      cache:
        expires: 1800
        ssl: true
        priceClass: 100
```

### Publish Your API

This will take awhile the first time around,
(Panda Sky is doing a lot of set up for you)
but after that, it's relatively quick.

    sky publish production

### Test It Out

    curl https://greeting.com/greeting/Ace
    Hello, Ace

## Status

Panda Sky is in beta.
