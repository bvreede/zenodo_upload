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

# create and update metadata
cffconvert -f zenodo > .zenodo.json
cat add_to_zenodojson.txt >> .zenodo.json
perl -i -pe 'BEGIN{undef $/;} s/\n\}\nADDITIONAL_TEXT/,/smg' .zenodo.json
zenodraft metadata update $RECORD_ID .zenodo.json

# publish the record
# zenodraft deposition publish $RECORD_ID