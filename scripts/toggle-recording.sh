#!/usr/bin/env bash
# Toggle screen recording with wf-recorder. First press starts recording
# with audio; second press stops and saves to ~/Videos/Recordings/.
set -euo pipefail

PIDFILE=/tmp/wf-recorder.pid
OUTDIR="$HOME/Videos/Recordings"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    rm "$PIDFILE"
    notify-send "Recording" "Stopped — saved to ~/Videos/Recordings/" -t 3000
else
    mkdir -p "$OUTDIR"
    OUTFILE="$OUTDIR/$(date +%Y%m%d-%H%M%S).mp4"
    wf-recorder --audio -f "$OUTFILE" &
    echo $! > "$PIDFILE"
    notify-send "Recording" "Started (Super+Shift+R to stop)" -t 2000
fi
