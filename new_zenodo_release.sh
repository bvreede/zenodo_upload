# create deposition
RECORD_ID=$(zenodraft deposition create in-existing-collection 5645153)

# prepare zip archive
zip preprocessed_data.zip

# populate the deposition with files
for file in $(find ./preprocessed_data -type f -maxdepth 2)
do
    if [[ $file == *".nc" ]]; then
        zenodraft file add $RECORD_ID $file
        zip -rv preprocessed_data.zip $file
    fi
done
zenodraft file add $RECORD_ID preprocessed_data.zip

# derive zenodo metadata from CITATION.cff using 'cffconvert'
cffconvert -f zenodo > .zenodo.base.json

# upsert with additional data using 'jq', store the result in .zenodo.json
cat .zenodo.base.json .zenodo.extras.json | jq -sS add > .zenodo.json

# attach the metadata to the zenodo record
zenodraft metadata update $RECORD_ID .zenodo.json

# publish the record
# zenodraft deposition publish $RECORD_ID
