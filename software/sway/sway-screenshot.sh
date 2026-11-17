DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
SATTY_CMD=(
    satty -f - --initial-tool=arrow --copy-command="wl-copy"
    --actions-on-enter="save-to-clipboard,save-to-file,exit"
    --actions-on-escape="save-to-clipboard,save-to-file,exit"
    --brush-smooth-history-size=5 --disable-notifications
    --output-filename "$DIR/satty-$TIMESTAMP.png"
)

case "$1" in
    area)
        FILE="$DIR/screenshot-$TIMESTAMP.png"
        # Экран заморозится, slurp берет геометрию. Если нажат Esc — GEOM пустой,
        # grim не вызывается, а killall в любом случае отпускает экран.
        wayfreeze --hide-cursor --after-freeze-cmd '
            GEOM=$(slurp)
            [ -n "$GEOM" ] && grim -g "$GEOM" -t png - | tee "'"$FILE"'" | wl-copy
            killall wayfreeze
        ';;

    fullscreen)
        grim -t ppm - | "${SATTY_CMD[@]}";;

    window)
        GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        [ -n "$GEOM" ] && grim -t ppm -g "$GEOM" - | "${SATTY_CMD[@]}";;
esac
