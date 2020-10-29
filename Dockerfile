ARG TF_VERSION=0.13.2

# Build terraspec

ARG GO_VERSION=1.14

FROM golang:${GO_VERSION}-alpine AS golang

ARG TERRASPEC_VERSION=0.5.1
ARG TFSEC_VERSION=v0.36.0
ARG TFLINT_VERSION=v0.20.1

RUN apk update && apk add --no-cache git
RUN cd /go/src && git clone https://github.com/acquia/terraspec.git \
      && cd terraspec \
      && git checkout ${TERRASPEC_VERSION} \
      && go build -ldflags="-X 'main.Version=${TERRASPEC_VERSION}'" -o /go/bin/terraspec

ENV GO111MODULE=on
RUN go get -ldflags "-X github.com/tfsec/tfsec/version.Version=${TFSEC_VERSION}" github.com/tfsec/tfsec/cmd/tfsec@${TFSEC_VERSION}
RUN go get github.com/terraform-linters/tflint@${TFLINT_VERSION}

# Use alpine image as base and copy terraform, terraspec, tfsec, tflint to it

FROM hashicorp/terraform:${TF_VERSION} as terraform
FROM alpine:latest

COPY --from=golang /go/bin/terraspec /usr/local/bin/terraspec
COPY --from=golang /go/bin/tfsec /usr/local/bin/tfsec
COPY --from=golang /go/bin/tflint /usr/local/bin/tflint
COPY --from=terraform /bin/terraform /bin/terraform
