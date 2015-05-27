#Author kyle@agronick
#Usage: Invoke this script to get the size of your subvolumes and snapshots
#Make sure to run "sudo btrfs quota enable /" first


LOCATION='/'
if [ $1 ]; then
LOCATION=$1
fi

COL1=`sudo btrfs subvolume list "$LOCATION"`
COL1=$(echo "$COL1" | cut -c 4-)

COL2=`sudo btrfs qgroup show "$LOCATION"`
COL2=$(echo "$COL2" | cut -c 2-) 
i=0;
OUTPUT="" 
for i in $COL2; do
    if [[ ! $i =~ ^[A-Za-z-]+$ ]]; then  
      if [[ "$i" == *\/* ]]; then 
        ROWID=$(echo "$i" | cut -c 2-) 
        OUTPUT+="
$ROWID  " 
      else
        MB=$(($i / 1024 / 1024))
        KB=$(($i / 1024))
        if [ $MB -eq 0 ]; then
            if [ $KB -eq 0 ]; then
                OUTPUT+=$(printf "%-9s" $i"B")  
            else
                OUTPUT+=$(printf "%-9s" $KB"KB")  
            fi
        else
            if [ $MB -gt 1024 ]; then
                GB=$(( $MB / 1024 ));
                MB=$(( ( ( $MB % 1024 ) * 100 ) / 1024 )); 
                OUTPUT+=$(printf "%-9s" "$GB.$MB""GB")
            else
                OUTPUT+=$(printf "%-9s" $MB"MB")
            fi  
        fi
           
       fi
    fi
done  

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "%-67s" "Snapshot / Subvolume"
printf "%-5s" "ID"
printf "%-9s" "Total"
printf "Exclusive Data"
printf "\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

IFS=$'\n'

for item in  $COL1; do
    ID=$(echo $item | grep -o '^[0-9.]\+' )
    for item2 in $OUTPUT; do 
        ID2=$(echo $item2 | grep -o '^[0-9.]\+' )  
            if [ "$ID" = "$ID2" ]; then
                printf "%-64s" $item
                echo  "   $item2"
                break;
            fi
    done
done
