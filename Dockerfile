# Build Stage
FROM lacion/alpine-golang-buildimage:1.11 AS build-stage

LABEL app="build-recog"
LABEL REPO="https://github.com/lacion/recog"

ENV PROJPATH=/go/src/github.com/lacion/recog

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/recog
WORKDIR /go/src/github.com/lacion/recog

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/recog"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/recog/bin

WORKDIR /opt/recog/bin

COPY --from=build-stage /go/src/github.com/lacion/recog/bin/recog /opt/recog/bin/
RUN chmod +x /opt/recog/bin/recog

# Create appuser
RUN adduser -D -g '' recog
USER recog

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/recog/bin/recog"]
