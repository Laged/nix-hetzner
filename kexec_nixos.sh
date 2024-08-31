# Check if an IP address was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <IP_ADDRESS>"
  exit 1
fi

# Assign the IP address to a variable
IP_ADDRESS=$1

# Run the setup commands over SSH
ssh "root@$IP_ADDRESS" 'curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root && /root/kexec/run'

echo "NixOS installation started on $IP_ADDRESS"

