FROM ghcr.io/kl-engineering/kl-krakend-builder:0.0.2 AS builder

WORKDIR /tmp/builder
COPY plugins plugins

WORKDIR /tmp/builder/plugins
RUN make all

FROM ghcr.io/kl-engineering/kl-krakend:0.0.2 as krakend

USER root

COPY config/ /etc/krakend/config/
COPY krakend.json /etc/krakend/krakend.json
COPY scripts/copy-common-files.sh /tmp/ccf.sh
RUN /tmp/ccf.sh
RUN rm /tmp/ccf.sh

COPY --from=builder /tmp/builder/plugins/**/*.so /opt/krakend/plugins/
RUN if [ ! x$(find /opt/krakend/plugins -prune -empty) = x/opt/krakend/plugins ]; then chmod +x /opt/krakend/plugins/*.so; fi

USER krakend
