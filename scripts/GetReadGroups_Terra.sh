#date: june 18th  2020
## Purpose; code to extract read groups from fastq files for sample preprocessing in terra, https://app.terra.bio/#workspaces/help-gatk/Sequence-Format-Conversion
## this script has been tested on fastq of illumina Casava 1.8 or above formats; see wiki for interpretation https://en.wikipedia.org/wiki/FASTQ_format
#general format for fastq
#@EAS139:136:FC706VJ:2:2104:15343:197393 1:Y:18:ATCACG


#create a file of all fastq files in google bucket
gsutil ls gs://fc-0e64c8b9-ba29-44f3-8b04-91a3c1a5df18/*/*.fastq.gz > test.list.paths.BcancerRay.txt

##create tmp variables;
Read_groups_all="Read_group_info_Bcancer_Columbia"
#create file to be updated with each samples read group in, PU names
echo -e " Sample_name" ' \t ' "Platform_Unit" ' \t ' "Read_Group_ID">> ${Read_groups_all}.txt


#####script  to pick up read group inform
while IFS= read -r line
do
tmp_header="tmp_header"
echo "Processing $line"
gsutil cat $line| zcat | grep -m1 "^@" > "${tmp_header}.txt" #save header into temp vriable ($tmp_header); should look something like this
# @A00740:56:HL5CHDSXX:2:1101:2049:1000 1:N:0:CAAGGAGC+ATTACTCG
Sample_name=$(basename -s .fastq.gz $line) ##please remember to trim away any "R1/R2" to match sample name on terra tables
lane_Info=$(cat "${tmp_header}.txt" | head -n 1 | cut -d ":" -f 4)
Sample_barcode=$(cat "${tmp_header}.txt" | head -n 1 | cut -d " " -f 2 | cut -d ":" -f 4)
flowcell_barcode=$(cat "${tmp_header}.txt" | head -n 1 | cut -f 3 -d ":")
PU=$(echo $flowcell_barcode.$lane_Info.$Sample_barcode)
RGID=$(cat "${tmp_header}.txt" | head -n 1 | cut -f 1-4 -d":"| sed 's/@//' | sed 's/:/_/g')
send_Rg_to_file=$(echo -e $Sample_name ' \t ' $PU ' \t ' $RGID)
echo $send_Rg_to_file >> ${Read_groups_all}.txt
done < "test.list.paths.BcancerRay.txt"

