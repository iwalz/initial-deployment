#!/bin/bash

# Start SSH agent for current session and add keys from /root/.ssh/
eval `ssh-agent -s`
chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa

function usage() {
	echo "command [--parameter=value] --script=deploy.sh --repository=git@github.com:your/repo.git"
	echo "--script=(required)		- script to execute once expected ready servers are reached"
	echo "--repository=(required)	- The git repository to clone"
	echo "--servers=3			- wait for Ready servers"
	echo "--sleep=10			- sleep for seconds till the next check"
}

servers=3
sleepTime=10
scriptName=""
repository=""

while [ $# -gt 0 ]; do
  case "$1" in
    --servers=*)
      servers="${1#*=}"
      ;;
    --sleep=*)
      sleepTime="${1#*=}"
      ;;
    --script=*)
	  scriptName="${1#*=}"
	  ;;
    --repository=*)
	  repository="${1#*=}"
	  ;;
    *)
      echo "Error: Invalid argument."
      usage
      exit 1
  esac
  shift
done

if [ "${scriptName}" == "" ]; then
	echo "Scriptname missing - exit"
	usage
	exit 1
fi

if [ "${repository}" == "" ]; then
	echo "Repository missing - exit"
	usage
	exit 1
fi

rm -rf /tmp/clone                                          
git clone ${repository} /tmp/clone

while [ true ]; do                                                      
        readyServers=$(/usr/bin/kubectl get no | grep "  Ready" | wc -l)
        echo
        echo -n "Checking for ${servers} ready servers, got ${readyServers}"
        if [[ "$readyServers" -ge $servers ]]; then
                echo " - reached expected servers"
                break;
        fi                                            
        echo -n " - sleeping for ${sleepTime} seconds"
        sleep ${sleepTime}
done

echo "Executing script '${scriptName}'"
/bin/bash /tmp/clone/${scriptName}

exit $?