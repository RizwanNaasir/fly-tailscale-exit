FROM alpine:latest as builder
WORKDIR /app
COPY . ./

FROM alpine:latest
RUN apk update && apk add ca-certificates iptables ip6tables \
  && rm -rf /var/cache/apk/*

COPY --from=builder /app/start.sh /app/start.sh

# Pull Tailscale binaries from official Docker image (always latest stable)
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

CMD ["/app/start.sh"]
