# get data.json from hhs and cdc, hhs redirects so -L, added it to cdc fetch for consistency
curl -L https://www.hhs.gov/data.json > data/hhs.gov.data.json
python -m json.tool data/hhs.gov.data.json > data/pretty.hhs.gov.data.json
curl -L https://data.cdc.gov/data.json > data/cdc.gov.data.json
python -m json.tool data/cdc.gov.data.json > data/pretty.cdc.gov.data.json

# I suppose I want code.json files to see how those change over time with hhs and cdc
curl -L https://www.hhs.gov/code.json > data/hhs.gov.code.json
python -m json.tool data/hhs.gov.code.json > data/pretty.hhs.gov.code.json
curl -L https://www.cdc.gov/code.json > data/cdc.gov.code.json
python -m json.tool data/cdc.gov.code.json > data/pretty.cdc.gov.code.json

