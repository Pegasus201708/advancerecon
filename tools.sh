#!/bin/bash
   
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install figlet -y
sudo apt-get install sublist3r -y
sudo apt-get install subfinder -y

sudo apt-get install assetfinder -y
sudo apt-get install dnsgen -y
sudo apt-get install massdns -y
sudo apt-get install httprobe -y
sudo apt-get install amass -y
sudo apt-get install -y ffuf
sudo apt-get install -y chromium 
sudo apt-get install dirsearch -y
sudo apt-get install wpscan -y
sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-get install -y python-setuptools
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y python-pip
sudo apt-get install -y python-dnspython
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs

mkdir ~/tools
cd ~/tools/



#installing golang
sudo apt-get install golang -y
if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, installing go lang"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)

					echo "Installing Golang"
					wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
					sudo tar -xvf go1.13.4.linux-amd64.tar.gz
					sudo mv go /usr/local
					export GOROOT=/usr/local/go
					export GOPATH=$HOME/go
					export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
					echo 'export GOROOT=/usr/local/go' >> ~/.bash_profile
					echo 'export GOPATH=$HOME/go'	>> ~/.bash_profile			
					echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_profile	
					source ~/.bash_profile
					sleep 1
					break
					;;
				no)
					echo "Please install go and rerun this script"
					echo "Aborting installation..."
					exit 1
					;;
	esac	
done
fi


#install aquatone
echo "Installing Aquatone"
sudo go get github.com/michenriksen/aquatone
echo "done"


#install JSParser
echo "installing JSParser"
git clone https://github.com/nahamsec/JSParser.git
cd ~/tools/JSParser*
sudo python setup.py install
cd ~/tools/
echo "done"

#install awscli
echo "installing teh_s3_bucketeers"
sudo apt-get install awscli
git clone https://github.com/tomdev/teh_s3_bucketeers.git
cd ~/tools/
echo "done"


#installing lazys3
echo "installing lazys3"
git clone https://github.com/nahamsec/lazys3.git
cd ~/tools/
echo "done"

#installing virtual host discovery
echo "installing virtual host discovery"
git clone https://github.com/jobertabma/virtual-host-discovery.git
cd ~/tools/
echo "done"


#installing sqlmap
echo "installing sqlmap"
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
cd ~/tools/
echo "done"

#installing knock.py
echo "installing knock.py"
git clone https://github.com/guelfoweb/knock.git
cd ~/tools/knock
pip3 install -r requirements.txt
sudo python3 setup.py install
cd ~/tools/
echo "done"

#installing crtndstry
echo "installing crtndstry"
git clone https://github.com/nahamsec/crtndstry.git
echo "done"

#downloading Seclists
echo "downloading Seclists"
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
cd ~/tools/
echo "done"

#installing unfurl
echo "installing unfurl"
sudo go get -u github.com/tomnomnom/unfurl 
echo "done"

#installing waybackurls
echo "installing waybackurls"
sudo go get github.com/tomnomnom/waybackurls
echo "done"


#installing asnlookup
echo "installing asnlookup"
git clone https://github.com/yassineaboukir/asnlookup.git
cd ~/tools/asnlookup
pip install -r requirements.txt
cd ~/tools/
echo "done"


#installing massdns scriptlist
echo "downloading massdns "
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/
echo "done"


#importing scripts
https://github.com/Pegasus201708/scriptlists.git
cd ~/tools/scriptlists
chmod 777 chmod.sh
bash chmod.sh
cd ~/tools/
echo "done"
