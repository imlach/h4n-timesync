#!/bin/bash
#/Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit
#/opt/homebrew/bin/ltcdump


#python3 -c "print(24*1000/1001)"
FPS=${2:-$(python3 -c "print(24*1000/1001)")}
SAMPLERATE=${3:-48000}

wavs=$(cd $1; find *M.wav)
for FILE in $wavs
do
  FILEPATH="$1/$FILE"
  TCSTR=$(ltcdump -c 1 -a $FILEPATH -f $FPS  2>/dev/null | head -n1 | grep -v "No LTC" || ltcdump -c 2 -a $FILEPATH -f $FPS  2>/dev/null | head -n1 )
  TC=($TCSTR)
  echo "Processing $FILE - ${TC[2]}"

  IFS=':' read -a tcarr <<< "${TC[2]}"

  hours=${tcarr[0]}
  mins=${tcarr[1]}
  secs=${tcarr[2]}
  frames=$((10#${tcarr[3]}))
  if [[ $frames -eq "" ]]; then
      frames=0
  fi
  
  framesrounded=$(python3 -c "print(round($FPS))")
  totalframes="$((($hours*3600+$mins*60+$secs)*$framesrounded+$frames))"
  
  samples=$(python3 -c "print(round($totalframes/$FPS*$SAMPLERATE))")  

  extrecording=${FILE%?????}I.wav

  echo "Processed SyncedTC/$extrecording"

  mkdir -p $1/SyncedTC
  cd $1; cp $extrecording $1/SyncedTC/

  
  /Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit $1/SyncedTC/$extrecording --Timereference=$samples
  

done


