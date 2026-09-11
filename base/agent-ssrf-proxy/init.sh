#!/bin/bash
# Renders the agent SSRF proxy templates (squid-agent.conf.template + squid-common.conf.template).
# Designed to run as an InitContainer in Kustomize deployment.

set -e

render() {
    awk '{
        while(match($0, /\${[A-Za-z_][A-Za-z_0-9]*}/)) {
            var = substr($0, RSTART+2, RLENGTH-3)
            val = ENVIRON[var]
            $0 = substr($0, 1, RSTART-1) val substr($0, RSTART+RLENGTH)
        }
        print
    }' "$1" > "$2"
}

echo "[INIT] rendering agent ssrf squid config"
render /template/squid-agent.conf.template /etc/squid/squid.conf
render /template/squid-common.conf.template /etc/squid/dify_common.conf
echo "[INIT] config generation complete"
