##script to delete some intermediarry files in colon cancer project
#!/bin/bash

## install gsutil or module load gsutil google cloud utilities softwares from your server
module load python/2.7.16 google_cloud_sdk

echo "caution!!! script delete files in google bucket"

input="/path/to/txt.file/contating/list/of/files/to/be/deleted"
while IFS= read -r line
do
  echo " deleting $line"
  gsutil rm $line
  echo "done deleting $line"
done < "$input"

