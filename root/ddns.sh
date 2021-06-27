#!/bin/bash

### Google Domains provides an API to update a DNS "Synthetic record". This script
### updates a record with the script-runner's public IP, as resolved using a DNS
### lookup.
###
### Original Gist: https://gist.github.com/cyrusboadway/5a7b715665f33c237996
### Google Dynamic DNS: https://support.google.com/domains/answer/6147083
### Synthetic Records: https://support.google.com/domains/answer/6069273

echo "Starting script..."

# READ IN VALUES
DEFAULTIFS="${IFS}"
IFS=';'
read -r -a cfhost <<< "${HOSTS}"
read -r -a cftype <<< "${RECORDTYPES}"
read -r -a cfuser <<< "${USERNAMES}"
read -r -a cfpass <<< "${PASSWORDS}"
IFS="${DEFAULTIFS}"

while true; do
    newip4=$(curl -fsL -4 ip.seeip.org)
    echo "Got IPv4: $newip4"
    newip6=$(curl -fsL -6 ip.seeip.org || echo "error")
    echo "Got IPv6: $newip6"

    for index in ${!cfhost[*]}; do
        host=${cfhost[$index]}
        type=${cftype[$index]}
        user=${cfuser[$index]}
        pass=${cfpass[$index]}

        case "${type}" in
            A)
                [ "$newip4" = "error" ] && {
                    echo "Bad IPv4, moving on..."
                    continue
                }
                newip=$newip4
                ;;
            AAAA)
                [ "$newip6" = "error" ] && {
                    echo "Bad IPv6, moving on..."
                    continue
                }
                newip=$newip6
                ;;
        esac

        echo "Updating $host ($type) to $newip"

        # Update Google DNS Record
        curl -fsL --user "${user}:${pass}" "https://domains.google.com/nic/update?hostname=${host}&myip=${newip}"
        echo ""
    done

    echo "Waiting $INTERVAL"
    sleep "${INTERVAL}"
done
