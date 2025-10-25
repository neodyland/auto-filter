#!/bin/bash
IP_FILTER=""

IFS=$'\n'; for item in $(cat config.json | jq -c '.[]'); do
    ASN=$(echo $item | jq .asn)
    IPV4=$(echo $item | jq .ipv4)
    IPV6=$(echo $item | jq .ipv6)
    if [ $IPV4 = "true" ]; then
        IP_FILTER+=$(bgpq4 -b AS${ASN} -l "define as${ASN}_ips")
        IP_FILTER+=$'\n'
        IP_FILTER+=$'\n'
    fi
    if [ $IPV6 = "true" ]; then
        IP_FILTER+=$(bgpq4 -6 -b AS${ASN} -l "define as${ASN}_ipv6s")
        IP_FILTER+=$'\n'
    fi
done

if [ -f ip-filters/AS${ASN}_ip.conf ]; then
    if [ "$(cat ip-filters/AS${ASN}_ip.conf)" != "$IP_FILTER" ]; then
        echo "Apply to BIRD3..."
        birdc configure
    fi
fi
echo "$IP_FILTER" > ip-filter.conf
