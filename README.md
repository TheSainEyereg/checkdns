# DNS Resolver Checker

A lightweight shell script to test plain DNS, DNS over HTTPS (DoH) and DNS over TLS (DoT) resolvers.

## Usage
## Quick run:
```bash
wget -qO- https://raw.githubusercontent.com/TheSainEyereg/checkdns/refs/heads/main/checkdns.sh | sh
```

### Test custom domain:
```bash
wget -qO- https://raw.githubusercontent.com/TheSainEyereg/checkdns/refs/heads/main/checkdns.sh | sh -s example.com
```

### Download and run locally:
```bash
wget https://raw.githubusercontent.com/TheSainEyereg/checkdns/refs/heads/main/checkdns.sh
chmod +x checkdns.sh
./checkdns.sh
```

## Features

- Tests popular DNS resolvers (Cloudflare, Google, Quad9, AdGuard, NextDNS)
- Supports plain DNS, DoH and DoT protocols
- Clean output with status indicators (✅/❌)
- POSIX-compliant (works with sh, bash, ash)
- Custom domain testing support

## Requirements

- `dig` utility (version 9.18+)

### Installation commands for dig:
- **Debian/Ubuntu**: `sudo apt install dnsutils`
- **OpenWrt**: `opkg install bind-dig`
- **MacOS**: `brew install bind`
- **Termux**" `apt upgrade dnsutils`

## Output Example

```
🔓 Plain DNS (UDP)
  ✅ Cloudflare (5 ms)
  ✅ Google (29 ms)
  ✅ Quad9 (22 ms)
  ✅ AdGuardDNS (39 ms)
  ✅ NextDNS (14 ms)

🔒 DNS over HTTPS (DoH)
  ✅ Cloudflare (9 ms)
  ✅ Google (31 ms)
  ✅ Quad9 (57 ms)
  ✅ AdGuardDNS (40 ms)
  ✅ NextDNS (6 ms)

🔒 DNS over TLS (DoT)
  ✅ Cloudflare (49 ms)
  ✅ Google (46 ms)
  ✅ Quad9 (45 ms)
  ✅ AdGuardDNS (119 ms)
  ✅ NextDNS (113 ms)
```