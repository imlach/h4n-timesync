#!/bin/bash
# bwfmetaedit location: /Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit
# ltcdump location: /opt/homebrew/bin/ltcdump
# usage ./timesync.sh <path-to-recording-directory> <fps(default 23.98)> <samplerate(default 48000)>


FPS=${2:-$(python3 -c "print(24*1000/1001)")}
SAMPLERATE=${3:-48000}
wavs=$(cd $1; find *M.wav)

# Iterate through all recordings
for FILE in $wavs
do
  # Pull the first LTC value out of the mic/external input (connected to TC-1)
  FILEPATH="$1/$FILE"
  TCSTR=$(ltcdump -a $FILEPATH -f $FPS  2>/dev/null | head -n1 )
  TC=($TCSTR)
  echo "Processing $FILE - ${TC[2]}"
  
  # Split out timecode into H:M:S:F
  IFS=':' read -a tcarr <<< "${TC[2]}"
  hours=${tcarr[0]}
  mins=${tcarr[1]}
  secs=${tcarr[2]}
  frames=${tcarr[3]}
  
  # Calculate the number of audio samples since midnight
  framesrounded=$(python3 -c "print(round($FPS))")
  totalframes="$((($hours*3600+$mins*60+$secs)*$framesrounded+$frames))"
  samples=$(python3 -c "print(round($totalframes/$FPS*$SAMPLERATE))")  

  extrecording=${FILE%?????}I.wav
  mkdir -p $1/SyncedTC
  cd $1; cp $extrecording $1/SyncedTC/

  # Set timecode metadata of the Input stereo file from the TC-1 track
  #TODO: Use path for BWFMetaEdit CLI tool
  /Users/imlach/wksp/BWFMetaEdit/Project/GNU/CLI/bwfmetaedit $1/SyncedTC/$extrecording --Timereference=$samples
  echo "Processed SyncedTC/$extrecording\n\n"
done
