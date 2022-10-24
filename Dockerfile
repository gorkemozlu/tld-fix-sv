FROM docker.io/bitnami/minideb:bullseye

ARG TARGETARCH
ARG GO_VERSION
ENV GO_VERSION="1.17.3"

LABEL org.opencontainers.image.authors="https://bitnami.com/contact" \
      org.opencontainers.image.description="Application packaged by Bitnami" \
      org.opencontainers.image.ref.name="1.22.15-debian-11-r9" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/kubectl" \
      org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.vendor="VMware, Inc." \
      org.opencontainers.image.version="1.22.15"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux"

RUN mkdir -p /opt/bitnami
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl git jq procps openssh-client wget git gcc jq vim

RUN wget -P /tmp "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
RUN tar -C /usr/local -xzf "/tmp/go${GO_VERSION}.linux-amd64.tar.gz"
RUN rm "/tmp/go${GO_VERSION}.linux-amd64.tar.gz"
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN mkdir -p /tmp/bitnami/pkg/cache/ && cd /tmp/bitnami/pkg/cache/ && \
    COMPONENTS=( \
      "kubectl-1.22.15-1-linux-${OS_ARCH}-debian-11" \
    ) && \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi && \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" && \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' && \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN mkdir /.kube && chmod g+rwX /.kube

ENV APP_VERSION="1.22.15" \
    BITNAMI_APP_NAME="kubectl" \
    PATH="/opt/bitnami/kubectl/bin:$PATH" \
    GO111MODULE=off

COPY tld-local.sh /opt/bitnami
COPY tld-run.sh /opt/bitnami
COPY run-remote.go /opt/bitnami
COPY run-scp.go /opt/bitnami
RUN go get github.com/appleboy/easyssh-proxy
RUN  chmod +x /opt/bitnami/tld-run.sh
RUN  chmod +x /opt/bitnami/tld-local.sh


ENTRYPOINT [ "/opt/bitnami/tld-run.sh" ]
CMD [ "--help" ]