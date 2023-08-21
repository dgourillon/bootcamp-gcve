echo "--- Install powershell section ---"
# Add MS repos for powershell (govc can't get the VM IDs apparently)

if grep packages.microsoft.com /etc/apt/sources.list /etc/apt/sources.list.d/*
then
	echo "MS repository already declared" 
else
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update 
sudo apt-get install -y powershell
fi
