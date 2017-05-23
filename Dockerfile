# docker build . -t pandastrike/panda-sky
# docker tag pandastrike/panda-sky pandastrike/panda-sky:1.0.0-beta-19
# docker push pandastrike/panda-sky
# docker run -it --rm -v ~/.aws:/root/.aws -v "$PWD":/usr/src/app pandastrike/panda-sky sky help
FROM node:6

RUN apt-get update \
  && apt-get install -y zip

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV PATH="node_modules/.bin:$PATH"

RUN npm install -g panda-sky@1.0.0-beta-19
