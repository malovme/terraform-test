ARG TF_VERSION=0.13.2

# Build terraspec

ARG GO_VERSION=1.14

FROM golang:${GO_VERSION}-alpine AS golang

ARG TERRASPEC_VERSION=0.5.0

RUN apk update && apk add --no-cache git
RUN cd /go/src && git clone https://github.com/acquia/terraspec.git \
      && cd terraspec \
      && git checkout ${TERRASPEC_VERSION} \
      && go build -ldflags="-X 'main.Version=${TERRASPEC_VERSION}'" -o /go/bin/terraspec

# Use terraform image and copy terraspec to it

FROM hashicorp/terraform:${TF_VERSION}

COPY --from=golang /go/bin/terraspec /usr/local/bin/terraspec

ENTRYPOINT ["/bin/sh"]
