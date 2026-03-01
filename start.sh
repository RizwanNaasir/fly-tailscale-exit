#!/usr/bin/env sh

echo 'Starting up...'

echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

/app/tailscaled \
    --verbose=1 \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock &

sleep 2

/app/tailscale up \
    --auth-key=${TAILSCALE_AUTHKEY} \
    --hostname=fly-${FLY_REGION} \
    --advertise-exit-node \
    --advertise-tags=tag:fly-exit

echo "Tailscale started. Let's go!"
sleep infinity
