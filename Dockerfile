ARG TF_VERSION=0.13.2
ARG GO_VERSION=1.14

FROM hashicorp/terraform:${TF_VERSION} AS terraform
FROM golang:${GO_VERSION} AS golang

ARG TERRASPEC_VERSION=0.5.0

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

RUN cd /tmp && git clone https://github.com/acquia/terraspec.git \
      && cd terraspec \
      && git checkout ${TERRASPEC_VERSION} \
      && go install -ldflags="-X 'main.Version=${TERRASPEC_VERSION}'" \
      && cd $GOPATH \
      && rm -rf /tmp/terraspec

ENTRYPOINT ["/bin/sh"]