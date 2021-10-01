#!/bin/bash

 echo "Usage: ./lazyrecon.sh -d domain.com [-e] [excluded.domain.com,other.domain.com]\nOptions:\n  -e\t-\tspecify excluded subdomains\n " 
while getopts ":d:e:r:" o; do
    case "${o}" in
        d)
            domain=${OPTARG}
            ;;

            #### working on subdomain exclusion
        e)
            set -f
	    IFS=","
	    excluded+=($OPTARG)
	    unset IFS
            ;;

		r)
            subreport+=("$OPTARG")
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "${domain}" ] && [[ -z ${subreport[@]} ]]; then
   usage; exit 1;
fi



todate=$(date +"%Y-%m-%d")
path=$(pwd)
foldername=recon-$todate
main $domain



red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

 if [ -d "./$domain" ]
  then
    echo "This is a known target."
  else
    mkdir ./$domain
  fi

  mkdir ./$domain/$foldername
  mkdir ./$domain/$foldername/aqua_out
  mkdir ./$domain/$foldername/aqua_out/parsedjson
  mkdir ./$domain/$foldername/reports/
  mkdir ./$domain/$foldername/wayback-data/
  mkdir ./$domain/$foldername/screenshots/
  touch ./$domain/$foldername/crtsh.txt
  touch ./$domain/$foldername/mass.txt
  touch ./$domain/$foldername/cnames.txt
  touch ./$domain/$foldername/pos.txt
  touch ./$domain/$foldername/alldomains.txt
  touch ./$domain/$foldername/temp.txt
  touch ./$domain/$foldername/tmp.txt
  touch ./$domain/$foldername/domaintemp.txt
  touch ./$domain/$foldername/ipaddress.txt
  touch ./$domain/$foldername/cleantemp.txt
 # touch ./$domain/$foldername/master_report.html

mkdir ./$domain/$foldername/thirdlevel/
mkdir ./$domain/$foldername/scan/
mkdir ./$domain/$foldername/eyewitness/




auquatoneThreads=5
subdomainThreads=10
dirsearchThreads=50
dirsearchWordlist=~/tools/dirsearch/db/dicc.txt
massdnsWordlist=~/tools/SecLists/Discovery/DNS/clean-jhaddix-dns.txt
chromiumPath=/snap/bin/chromium

-



  
  echo "${red}

██████╗░░█████╗░░█████╗░████████╗░░░░░░██████╗░███████╗░█████╗░  
██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝░░░░░░██╔══██╗██╔════╝██╔══██╗  
██████╔╝██║░░██║██║░░██║░░░██║░░░█████╗██████╔╝█████╗░░██║░░╚═╝  
██╔══██╗██║░░██║██║░░██║░░░██║░░░╚════╝██╔══██╗██╔══╝░░██║░░██╗  
██║░░██║╚█████╔╝╚█████╔╝░░░██║░░░░░░░░░██║░░██║███████╗╚█████╔╝  
╚═╝░░╚═╝░╚════╝░░╚════╝░░░░╚═╝░░░░░░░░░╚═╝░░╚═╝╚══════╝░╚════╝░  

░██████╗░█████╗░██████╗░██╗██████╗░████████╗
██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝
╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░
░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░
██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░
╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░
${reset}                                                      "






  echo "${green}Recon started on $domain ${reset}"
  echo "${red}SUBFINDER$domain ${reset}"
  echo "Listing subdomains using sublister..."
  subfinder -d $domain -t 10 -v -o ./$domain/$foldername/$domain.txt 
  
  echo "Checking certspotter..."
  curl -s https://certspotter.com/api/v0/certs\?domain\=$domain | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $domain >> ./$domain/$foldername/$domain.txt
  
  
  
  
  
  
echo "{yellow}3rd level subdomain enumuration start"

cat ./$domain/$foldername/$domain.txt | grep -Po "(\w+\.\w+\.\w+)$" | sort -u >> ./$domain/$foldername/$domain.txt

for dom in $(cat ./$domain/$foldername/$domain.txt)
                       do
                          subfinder -d $dom | tee -a ./$domain/$foldername/thirdlevel/$dom.txt
                          chmod 777 ./$domain/$foldername/thirdlevel/$dom.txt
                          cat ./$domain/$foldername/thirdlevel/$dom.txt | sort -u  >> ./$domain/$foldername/subdomains.txt
                    done
echo "{yellow}3rd level subdomain enumuration end"








#massdns
echo "{green}DIRECTORY SEARCH START...(MASSDNS) ..."

echo "Starting dirsearch..."
cat ./$domain/$foldername/subdomains.txt | xargs -P$subdomainThreads -I % sh -c "python3 ~/tools/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar -w $dirsearchWordlist -t $dirsearchThreads -u % | grep Target && tput sgr0 && ./lazyrecon.sh -r $domain -r $foldername -r %"


echo "Starting aquatone scan..."
cat ./$domain/$foldername/subdomains.txt  | aquatone -chrome-path $chromiumPath -out ./$domain/$foldername/aqua_out -threads $auquatoneThreads -silent


echo "Checking http://crt.sh"
 python3 ~/tools/massdns/scripts/ct.py $domain 2>/dev/null > ./$domain/$foldername/tmp.txt
 [ -s ./$domain/$foldername/tmp.txt ] && cat ./$domain/$foldername/tmp.txt | ~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -q -o S -w  ./$domain/$foldername/crtsh.txt
 cat ./$domain/$foldername/$domain.txt | ~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -q -o S -w  ./$domain/$foldername/domaintemp.txt


 echo "Starting Massdns Subdomain discovery this may take a while"

 python3 ~/tools/massdns/scripts/subbrute.py $massdnsWordlist $domain | ~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -q -o S | grep -v 142.54.173.92 > ./$domain/$foldername/mass.txt >/dev/null
   
   echo "Massdns finished..."
   
   echo "{green}DIRECTORY SEARCH END...(MASSDNS) ..."
                
                echo "${green}Started dns records check...${reset}"
                echo "Looking into CNAME Records..."


                cat ./$domain/$foldername/mass.txt >> ./$domain/$foldername/temp.txt
                cat ./$domain/$foldername/domaintemp.txt >> ./$domain/$foldername/temp.txt
                cat ./$domain/$foldername/crtsh.txt >> ./$domain/$foldername/temp.txt


                cat ./$domain/$foldername/temp.txt | awk '{print $3}' | sort -u | while read line; do
                wildcard=$(cat ./$domain/$foldername/temp.txt | grep -m 1 $line)
                echo "$wildcard" >> ./$domain/$foldername/cleantemp.txt
                done


                cat ./$domain/$foldername/cleantemp.txt | grep CNAME >> ./$domain/$foldername/cnames.txt
                cat ./$domain/$foldername/cnames.txt | sort -u | while read line; do
                hostrec=$(echo "$line" | awk '{print $1}')
                if [[ $(host $hostrec | grep NXDOMAIN) != "" ]]
                then
                echo "${red}Check the following domain for NS takeover:  $line ${reset}"
                echo "$line" >> ./$domain/$foldername/pos.txt
                else
                echo -ne "working on it...\r"
                fi
                done
                sleep 1
                cat ./$domain/$foldername/$domain.txt > ./$domain/$foldername/alldomains.txt
                cat ./$domain/$foldername/cleantemp.txt | awk  '{print $1}' | while read line; do
                x="$line"
                echo "${x%?}" >> ./$domain/$foldername/alldomains.txt
		cat ./$domain/$foldername/alldomains.txt >>./$domain/$foldername/subdomains.txt
                done
                sleep 1

echo "${green}END dns records check...${reset}"




                  cat ./$domain/$foldername/subdomains.txt | sort -u  >> ./$domain/$foldername/subdomains.txt





echo "${red} START FINDING LIVE HOST${reset}"

echo "Probing for live hosts..."
cat ./$domain/$foldername/subdomains.txt -u | httprobe -c 50 -t 3000 >> ./$domain/$foldername/responsive.txt
cat ./$domain/$foldername/responsive.txt | sed 's/\http\:\/\///g' |  sed 's/\https\:\/\///g' | sort -u | while read line; do
probeurl=$(cat ./$domain/$foldername/responsive.txt | sort -u | grep -m 1 $line)
echo "$probeurl" >> ./$domain/$foldername/urllist.txt
done
echo "$(cat ./$domain/$foldername/urllist.txt | sort -u)" > ./$domain/$foldername/urllist.txt
echo  "${yellow}Total of $(wc -l ./$domain/$foldername/urllist.txt | awk '{print $1}') live subdomains were found${reset}"

echo "${red}  FINDING LIVE HOST END ...${reset}"






echo "${yellow} EXCLUDING DOMAIN START${reset}"
  # from @incredincomp with love <3
  echo "Excluding domains (if you set them with -e)..."
  IFS=$'\n'
  # prints the $excluded array to excluded.txt with newlines 
  printf "%s\n" "${excluded[*]}" > ./$domain/$foldername/excluded.txt
  # this form of grep takes two files, reads the input from the first file, finds in the second file and removes
  grep -vFf ./$domain/$foldername/excluded.txt ./$domain/$foldername/urllist.txt > ./$domain/$foldername/urllist2.txt
  mv ./$domain/$foldername/urllist2.txt ./$domain/$foldername/urllist.txt
  #rm ./$domain/$foldername/excluded.txt # uncomment to remove excluded.txt, I left for testing purposes
  echo "Subdomains that have been excluded from discovery:"
  printf "%s\n" "${excluded[@]}"
  unset IFS

echo "${yellow} EXCLUDING DOMAIN END${reset}"






echo "${red} DOMAIN SCRAPING START...${reset}"
echo "Scraping wayback for data..."
cat ./$domain/$foldername/urllist.txt| waybackurls > ./$domain/$foldername/wayback-data/waybackurls.txt


cat ./$domain/$foldername/wayback-data/waybackurls.txt  | sort -u | unfurl --unique keys > ./$domain/$foldername/wayback-data/paramlist.txt


cat ./$domain/$foldername/wayback-data/waybackurls.txt  | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > ./$domain/$foldername/wayback-data/jsurls.txt


cat ./$domain/$foldername/wayback-data/waybackurls.txt  | sort -u | grep -P "\w+\.php(\?|$) | sort -u " > ./$domain/$foldername/wayback-data/phpurls.txt


cat ./$domain/$foldername/wayback-data/waybackurls.txt  | sort -u | grep -P "\w+\.aspx(\?|$) | sort -u " > ./$domain/$foldername/wayback-data/aspxurls.txt


cat ./$domain/$foldername/wayback-data/waybackurls.txt  | sort -u | grep -P "\w+\.jsp(\?|$) | sort -u " > ./$domain/$foldername/wayback-data/jspurls.txt

echo "${red} DOMAIN SCRAPING END...${reset}"







echo "{RED}TAKING SNAP:---~~-~-~-~-~-~-~-~-"
echo "[::-*-::] Running Eyewitness...[::-*-::]"
eyewitness -f ./$domain/$foldername/urllist.txtt -d ./$domain/$foldername/$domain
chmod 777 ./$domain/$foldername/$domain
mv ./$domain/$foldername/$domain ./$domain/$foldername/eyewitness/$domain



