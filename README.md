Syncs a Deity TC-1 synced h4n in the mic/external input to timecode

This assumes timecode on 4ch...M.wav, and audio on 4ch...I.wav
Defaults to 23.976 FPS, and 48000hz sample rate


usage: `./timesync.sh <path to h4 directory> <FPS> <SampleRate>`


Creates SyncedTC/ subdirectory of all the modified *I.wav files
Depends on ltctools (ltcdump) and BWFMetaEdit CLI tool (currently a hard coded path)
