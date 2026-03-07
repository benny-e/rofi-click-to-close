#!/usr/bin/env bash
set -euo pipefail

#Script for adding click to close functionality to rofi in hypyland
#Detects pointer clicks outside of the rofi layer and kills rofi
#author: benny-e

#if rofi isn't running, exit
pgrep -x rofi >/dev/null || exit 0



get_cursor_xy() {
  if hyprctl cursorpos -j >/dev/null 2>&1; then
    hyprctl cursorpos -j | jq -r '[.x,.y] | @tsv'
  else
    hyprctl cursorpos | tr -d ' ' | awk -F',' '{print $1 "\t" $2}'
  fi
}

get_rofi_rects() {
  hyprctl layers -j 2>/dev/null | jq -r '
    .. | objects
    | select(.namespace? == "rofi")
    | select(.x? and .y? and (.w? or .width?) and (.h? or .height?) and .pid?)
    | [
        (.pid|tostring),
        (.x|tostring),
        (.y|tostring),
        ((.w // .width)|tostring),
        ((.h // .height)|tostring)
      ] | @tsv
  '
}

rects="$(get_rofi_rects || true)"
[[ -z "${rects}" ]] && exit 0  

read -r cx cy <<<"$(get_cursor_xy)"

inside_any=0
pids=()

while IFS=$'\t' read -r pid rx ry rw rh; do
  [[ -z "${pid:-}" ]] && continue
  pids+=("$pid")

  if (( cx >= rx && cx < rx + rw && cy >= ry && cy < ry + rh )); then
    inside_any=1
    break
  fi
done <<< "$rects"

(( inside_any == 1 )) && exit 0


#Prevent rofi open click closing the recently opened window
GRACE_MS=150

hz="$(getconf CLK_TCK)"

for pid in "${pids[@]}"; do
  [[ -r "/proc/$pid/stat" ]] || continue

  start_ticks="$(awk '{print $22}' "/proc/$pid/stat")"
  now_ticks="$(awk -v hz="$hz" '{print int($1*hz)}' /proc/uptime)"

  age_ms=$(( (now_ticks - start_ticks) * 1000 / hz ))

  if (( age_ms < GRACE_MS )); then
    exit 0
  fi
done


#Kill the rofi window
for pid in "${pids[@]}"; do
  kill -TERM "$pid" 2>/dev/null || true
done

exit 0
