#!/bin/bash
#Quality checks to review the data.json file for cdc.gov
#depends on jq1.5+

#There's one proper file https://data.cdc.gov/data.json, but then there's another file, https://www.cdc.gov/wcms/opendata/data.json that no one knows who makes it, but HHS harvests it anyway
#curl https://data.cdc.gov/data.json --output data/cdc.gov.data.json
#curl https://www.cdc.gov/wcms/opendata/data.json --output data/wcms.opendata.data.json
#curl https://www.healthdata.gov/data.json --output data/hhs.data.json

#HHS escapes all their slashes and this is bad for comparing identifiers since CDC uses URIs with https:// addresses, so I need to replace \/ with /
#running it through echo -n because sed on OSX is adding a trailing newline
echo -n `cat data/hhs.data.json | sed "s/\\\//\//g"` > data/hhs.data-clean.json

echo "https://data.cdc.gov/data.json aka \"Main\" has this many datasets"
jq ".dataset | length" data/cdc.gov.data.json
jq ".dataset[].title" data/cdc.gov.data.json |wc


echo "https://www.cdc.gov/wcms/opendata/data.json aka \"WCMS\" has this many datasets"
jq ".dataset | length" data/wcms.opendata.data.json
jq ".dataset[].title" data/wcms.opendata.data.json |wc

echo "https://www.healthdata.gov/data.json aka \"HHS\" has this many datasets from CDC"
jq ".dataset[] | select((.publisher.name==\"Centers for Disease Control and Prevention\") or (.publisher.name==\"Centers for Disease Control and Prevention, Department of Health &amp; Human Services\")).title" data/hhs.data.json|wc

echo -e "\nMain has these unique bureauCodes"
jq ".dataset[].bureauCode" data/cdc.gov.data.json -c|sort|uniq

echo -e "\n WCMS has these unique bureauCodes"
jq ".dataset[].bureauCode" data/wcms.opendata.data.json -c|sort|uniq

TITLES=`jq ".dataset[].title" data/wcms.opendata.data.json -r`

echo -e "\nLoop through all the titles in WCMS them and see if any of them are also in Main, printing out landing pages that don't match. This is weird and should be investigated."
jq ".dataset[].landingPage" data/wcms.opendata.data.json -r | { 
while read -r landingPage
do
    
    #echo $title
    MATCH=`jq ".dataset[] | select(.landingPage==\"$landingPage\").landingPage" data/cdc.gov.data.json`
    if [ -n "$MATCH" ]
    then
        (( COUNTER_MATCH++ ))
        #echo "MATCH"
        #echo $MATCH
    else
        (( COUNTER_NOMATCH++ ))
        echo "NO MATCH"
        echo $landingPage
        echo "Also, here's the identifier, so you can check to see if it's in HHS"
        jq ".dataset[] | select(.landingPage==\"$landingPage\").identifier" data/wcms.opendata.data.json
    fi
done
echo $COUNTER_MATCH "matches"
echo $COUNTER_NOMATCH "no matches"
}



#as of 5/6 healthdata.gov shows 506 datasets for CDC, this jsonpath
#$.dataset[?(@.publisher.name=="Centers for Disease Control and Prevention")] returns 458
#$.dataset[?(@.publisher.name=="Centers for Disease Control and Prevention, Department of Health &amp; Human Services")].title returns 46

#All CDC sets should have a bureauCode of 009:20 and programCode of 009:020
#But $.dataset[?(@.bureauCode=="009:20")].title returns 204
