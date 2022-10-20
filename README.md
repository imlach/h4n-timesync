# H4n TimeSync

## Sumamry

Syncs a Deity TC-1 synced h4n in the mic/external input to timecode

This assumes timecode on 4ch...M.wav, and audio on 4ch...I.wav
Defaults to 23.976 FPS, and 48000hz sample rate


## Usage

 `./timesync.sh <path to h4 directory> <FPS> <SampleRate>`


This creates SyncedTC/... subdirectory of all the metadata-modified 4CH...I.wav files for easy sync-ing in Davinci Resolve


## Dependencies

* ltctools (ltcdump) 
* BWFMetaEdit CLI tool - https://github.com/MediaArea/BWFMetaEdit


## Known issues

* Doesn't take into account "Drop" framerates, I would probably only use it with 23.98 (default), 24, 25 and 30fps.
* It's a bit messy, probably not very robust, and is very opinionated.
* BWFMetaEdit is called from a hard coded path on my machine (something something works on my machine...)
