#!/bin/bash
# bwfmetaedit location: /Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit
# ltcdump location: /opt/homebrew/bin/ltcdump
# usage ./timesync.sh <path-to-recording-directory> <fps(default 23.98)> <samplerate(default 48000)>


ABSDIR="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
FPS=${2:-$(python3 -c "print(24*1000/1001)")}
SAMPLERATE=${3:-48000}
wavs=$(cd $ABSDIR; find *M.wav)

# Iterate through all recordings
for FILE in $wavs
do
  # Pull the first LTC value out of the mic/external input (connected to TC-1)
  # This will try the first two LTC frames on either channel to try and get a sync lock.
  FILEPATH="$ABSDIR/$FILE"
  TCSTR=$(ltcdump -c 1 -a $FILEPATH -f $FPS  2>/dev/null | head -n1 | grep -v "No LTC" || 
          ltcdump -c 1 -a $FILEPATH -f $FPS  2>/dev/null | head -n2 | tail -n1 | grep -v "No LTC" ||
          ltcdump -c 2 -a $FILEPATH -f $FPS  2>/dev/null | head -n1 | grep -v "No LTC" ||
          ltcdump -c 2 -a $FILEPATH -f $FPS  2>/dev/null | head -n2 | tail -n1 
        )
  TC=($TCSTR)
  echo "Processing $FILE - ${TC[2]}"
  
  # Split out timecode into H:M:S:F
  IFS=':' read -a tcarr <<< "${TC[2]}"
  hours=$((10#${tcarr[0]}))
  mins=$((10#${tcarr[1]}))
  secs=$((10#${tcarr[2]}))
  frames=$((10#${tcarr[3]}))
  if [[ $frames -eq "" ]]; then
      frames=0
  fi
  
  # Calculate the number of audio samples since midnight
  framesrounded=$(python3 -c "print(round($FPS))")
  totalframes="$((($hours*3600+$mins*60+$secs)*$framesrounded+$frames))"
  samples=$(python3 -c "print(round($totalframes/$FPS*$SAMPLERATE))")  

  extrecording=${FILE%?????}I.wav
  mkdir -p $ABSDIR/SyncedTC
  cd $ABSDIR; cp $extrecording $ABSDIR/SyncedTC/

  # Set timecode metadata of the Input stereo file from the TC-1 track
  #TODO: Use path for BWFMetaEdit CLI tool
  /Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit $ABSDIR/SyncedTC/$extrecording --Timereference=$samples
  echo "Processed SyncedTC/$extrecording"
  echo ""
  echo ""
done
