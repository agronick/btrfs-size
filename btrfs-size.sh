#Author Kyle Agronick <agronick@gmail.com>
#Usage: Invoke this script to get the size of your subvolumes and snapshots
#Make sure to run "sudo btrfs quota enable /" first


LOCATION='/'
if [ $1 ]; then
LOCATION=$1
fi

OUTPUT=""

COL1=`sudo btrfs subvolume list "$LOCATION"`
COL1=$(echo "$COL1" | cut -c 4-)


COL2=`sudo btrfs qgroup show "$LOCATION" --raw 2>&1`
CONTINUE=false
if [[ $COL2 == *"unrecognized option"* ]]; then
    COL2=`sudo btrfs qgroup show "$LOCATION" `
fi

COL2=$(echo "$COL2" | cut -c 2-)



function convert()
{
        OUT=`echo "$i" | awk '{ sum=$1 ; hum[1024^3]="GB";hum[1024^2]="MB";hum[1024]="KB"; for (x=1024^3; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f%s\n",sum/x,hum[x];break } }}'`
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

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "%-85s" "Snapshot / Subvolume"
printf "%-5s" "ID"
printf "%-10s" "Total"
printf "Exclusive Data"
printf "\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =


IFS=$'\n'

for item in  $COL1; do
    ID=$(echo $item | grep -o '^[0-9.]\+' )
    for item2 in $OUTPUT; do
        ID2=$(echo $item2 | grep -o '^[0-9.]\+' )
            if [ "$ID" = "$ID2" ]; then
                IFS=" " read -a dat <<< "$item"
                printf "%4s " "${dat[0]}"
                printf "%3s " "${dat[1]}"
                printf "%6s " "${dat[2]}"
                printf "%3s " "${dat[3]}"
                printf "%5s " "${dat[4]}"
                printf "%1s " "${dat[5]}"
                printf "%-6s " "${dat[6]}"
                printf "%-40s " "${dat[7]}"
                printf "%-4s " "${dat[8]}"
                IFS=" " read -a dat <<< "$item2"
                printf "%6s " "${dat[0]}"
                printf "%9s " "${dat[1]}"
                printf "%10s " "${dat[2]}"
                echo
                break;
            fi
    done
done

if [ $ECL_TOTAL -gt "1" ]; then
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
    i=$ECL_TOTAL
    printf "%-85s" " "
    printf "Exclusive Total: $(convert $i) \n"
fi
