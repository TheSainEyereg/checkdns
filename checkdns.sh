#!/bin/sh

#set -x

DOMAIN="${1:-itdog.info}"
RESOLVERS_UDP="Cloudflare:1.1.1.1,1.1 Google:8.8.8.8,8.4.4.8 Quad9:9.9.9.9,149.112.112.112 AdGuardDNS:94.140.14.140,94.140.14.141 NextDNS:45.90.28.43,45.90.30.43 DNS4EU:86.54.11.100,86.54.11.200 ControlD:76.76.2.0,76.76.10.0 Wikimedia:185.71.138.138"
RESOLVERS_DOT="Cloudflare:cloudflare-dns.com Google:dns.google Quad9:dns.quad9.net AdGuardDNS:dns.adguard-dns.com NextDNS:dns.nextdns.io DNS4EU:unfiltered.joindns4.eu ControlD:p0.freedns.controld.com Wikimedia:wikimedia-dns.org"
RESOLVERS_DOH="Cloudflare:cloudflare-dns.com Google:dns.google Quad9:dns.quad9.net AdGuardDNS:dns.adguard-dns.com NextDNS:dns.nextdns.io DNS4EU:unfiltered.joindns4.eu ControlD:freedns.controld.com/p0 Wikimedia:wikimedia-dns.org"

if ! command -v dig >/dev/null 2>&1; then
    echo "dig is not installed. Commands to install:"
    echo "Debian/Ubuntu: sudo apt install dnsutils"
    echo "OpenWrt: opkg install bind-dig"
    echo "MacOS: brew install bind"
    echo "Termux: apt upgrade dnsutils"
    exit 1
fi

dns_query() {
    protocol="$1"
    resolver_name="$2"
    resolver_host="$3"
    protocol_endpoint="${4:-}"

    dig_cmd="+tries=1 +time=3 +${protocol}"
    if [ -n "$protocol_endpoint" ]; then
        dig_cmd="${dig_cmd}=${protocol_endpoint}"
    fi

    result=$(dig ${dig_cmd} @"$resolver_host" "$DOMAIN" A 2>&1)

    if echo "$result" | grep -q "failed:\|timed out\|no servers could be reached\|connection refused\|host unreachable"; then
        echo "  ❌ $resolver_name ($resolver_host)"
        echo "$result" | grep -E "(failed:|timed out|no servers|connection|unreachable)" | sed 's/^/    /'
        return
    fi

    query_time=$(echo "$result" | grep "Query time:" | sed 's/.*Query time: \([0-9]*\) msec.*/\1/')

    ip_lines=$(echo "$result" | grep -A 10 "ANSWER SECTION:" | grep -E "IN[[:space:]]+A[[:space:]]+([0-9]{1,3}\.){3}[0-9]{1,3}")

    if [ -n "$ip_lines" ]; then
        if [ -n "$query_time" ]; then
            echo "  ✅ $resolver_name ($resolver_host) ($query_time ms)"
        else
            echo "  ✅ $resolver_name ($resolver_host)"
        fi
    else
        if [ -n "$query_time" ]; then
            echo "  ❌ $resolver_name ($resolver_host) ($query_time ms)"
        else
            echo "  ❌ $resolver_name ($resolver_host)"
        fi
        echo "$result" | grep -v '^$' | grep -v '^;' | sed 's/^/    /'
    fi
}

query_wrapper() {
    protocol="$1"
    resolver_name="$2"
    resolver_spec="$3"

    if echo "$resolver_spec" | grep -q '/'; then
        host_part=${resolver_spec%%/*}
        endpoint_part="/${resolver_spec#*/}"
    else
        host_part="$resolver_spec"
        endpoint_part=""
    fi

    IFS=',' read -r -a hosts <<< "$host_part"

    for host in "${hosts[@]}"; do
        host=$(echo "$host" | xargs)
        if [ -n "$host" ]; then
            dns_query "$protocol" "$resolver_name" "$host" "$endpoint_part"
        fi
    done
}

echo "🔓 Plain DNS (UDP)"

for resolver in $RESOLVERS_UDP; do
    name=${resolver%%:*}
    spec=${resolver#*:}
    query_wrapper "notcp" "$name" "$spec"
done

echo ""
echo "🔒 DNS over HTTPS (DoH)"

for resolver in $RESOLVERS_DOH; do
    name=${resolver%%:*}
    spec=${resolver#*:}
    query_wrapper "https" "$name" "$spec"
done

echo ""
echo "🔒 DNS over TLS (DoT)"

for resolver in $RESOLVERS_DOT; do
    name=${resolver%%:*}
    spec=${resolver#*:}
    query_wrapper "tls" "$name" "$spec"
done
