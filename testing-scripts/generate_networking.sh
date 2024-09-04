# Check if an IP address was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <IP_ADDRESS>"
  exit 1
fi

# Assign the IP address to a variable
IP_ADDRESS=$1

# Run the networking script over SSH using the provided IP address
ssh "root@$IP_ADDRESS" bash -s < networking_nixos.sh

echo "Networking setup executed on $IP_ADDRESS"
