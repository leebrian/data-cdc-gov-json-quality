# get data.json from hhs and cdc, hhs redirects so -L, added it to cdc fetch for consistency
curl -L https://www.hhs.gov/data.json > data/hhs.gov.data.json
python -m json.tool data/hhs.gov.data.json > data/pretty.hhs.gov.data.json
curl -L https://data.cdc.gov/data.json > data/cdc.gov.data.json
python -m json.tool data/cdc.gov.data.json > data/pretty.cdc.gov.data.json

