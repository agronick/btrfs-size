#!/bin/bash
#Author Kyle Agronick <agronick@gmail.com>
#Usage: Invoke this script to get the size of your subvolumes and snapshots
#Make sure to run "sudo btrfs quota enable /" first


LOCATION='/'
if [ $1 ]; then
LOCATION=$1
fi

OUTPUT="" 

COL1=`sudo btrfs subvolume list "$LOCATION"`

if [ $? -ne 0 ]; then
	echo "Failed to the volume data! BTRFS volume is required on the target location!"
	exit 1
fi

COL1=$(echo "$COL1" | cut -d ' ' -f 2,9) # Only taking the ID and the Snapshot name

COL2=`sudo btrfs qgroup show "$LOCATION" --raw 2>&1`

if [ $? -ne 0 ]; then 
    echo "Failed to get size on the target location! Is quota enabled?"
    exit 1
fi

CONTINUE=false
if [[ $COL2 == *"unrecognized option"* ]]; then
    COL2=`sudo btrfs qgroup show "$LOCATION" `
fi    

COL2=$(echo "$COL2" | cut -c 2-)


function convert()
{ 
        OUT=`echo "$i" | awk '{ sum=$1 ; hum[1024^4]="TB";hum[1024^3]="GB";hum[1024^2]="MB";hum[1024]="KB"; for (x=1024^4; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f%s\n",sum/x,hum[x];break } }}'`
        OUTPUT=$(printf "%-9s" $OUT) 
        echo "$OUTPUT"
}

i=0
ECL_TOTAL=0
INDEX=0
LC_ALL=C
for i in $COL2; do  
    if [[ $i == *"groupid"* ]] || [[ $i == *"----"* ]]; then
        continue;
    fi 
    if [[ ! $i =~ ^[A-Za-z-]+$ ]]; then  
      if [[ "$i" == *\/* ]]; then 
        INDEX=0
        ROWID=$(echo "$i" | cut -c 2-)   
        OUTPUT+="
$ROWID  " 
      else
        ((INDEX++))   
        if [ -z `echo $i | tr -d "[:alpha:]"` ]; then
            echo $i" letters\n"
            OUTPUT="$OUTPUT"$(printf "%-9s" $i)
        else
            if [ $INDEX -eq 2 ]; then
                ECL_TOTAL=$(($i + $ECL_TOTAL)) 
            fi
            OUTPUT="$OUTPUT$(convert $i)"
        fi
       fi
    fi
done


# Determine terminal width
if hash tput 2>/dev/null; then
	COLCOUNT=`tput cols`
elif hash stty 2>/dev/null; then
	COLCOUNT=`stty size | cut -d' ' -f2`
else
	COLCOUNT=80 # Default
fi

declare -a COLUMNWIDHTS=(-$(($COLCOUNT-30)) 20 6)

function printRow
{
	DATA=("$@")
	
	# The offset is calculated to help aligning the next column properly,
	# if the preveious one was too long
	local offset=0
	for ((i=0;i < $#;i++))
	{
		local modifier=""
		local width=${COLUMNWIDHTS[$i]}
		if [ $width -lt 0 ]; then
			width=$((0-$width)) # Gettings abs value
			modifier="-." # Left-padded and truncating if too long
		fi
		local pattern="%$modifier*s"
		local column # The current column with padding
		printf -v column $pattern $(($width + $offset)) "${DATA[$i]}"
		printf "$column"
		offset=$(($offset + $width - ${#column}))
	}
	printf "\n"
}

function printHorizontalLine
{
	printf '%*s\n' $COLCOUNT '' | tr ' ' '='
}

# Header start
printHorizontalLine
printRow "Snapshot / Subvolume" "Total Exclusive Data" "ID"
printHorizontalLine
# Header end

IFS=$'\n'

# Table body start
for item in  $COL1; do
    ID=$(echo $item | cut -d' ' -f1)
    name=$(echo $item | cut -d' ' -f2)
    for item2 in $OUTPUT; do
        ID2=$(echo $item2 | grep -o '^[0-9.]\+' )
        if [ "$ID" = "$ID2" ]; then
			eval ROWDATA=($(echo $name ${item2[@]} | awk -F' ' '{print $1, $3, $2}'))
			printRow "${ROWDATA[@]}"
			break;
        fi
    done
done
# Table body end

if [ $ECL_TOTAL -gt "1" ]; then
    printHorizontalLine
    i=$ECL_TOTAL
    printf "%-64s" " "  
    printf "Exclusive Total: $(convert $i) \n"
fi
