#!/usr/bin/env bash
# Claude Code statusline
# Two-line layout for narrower split-pane widths:
#   Line 1: cwd | git branch (if repo)
#   Line 2: model | context used% | rate limits
# Reads statusline JSON payload from stdin.

input=$(cat)

# Colors (ANSI). Terminal renders these dimmed, so plain codes read fine.
COLOR_DIR='\033[34m'      # blue
COLOR_BRANCH='\033[35m'   # magenta
COLOR_MODEL='\033[36m'    # cyan
COLOR_RATE='\033[32m'     # green
RESET='\033[0m'
DIM='\033[2m'

# --- Line 1, field 1: current directory (basename) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir_name=$(basename "$cwd")
line1_segments=("$(printf "${DIM}directory:${RESET} ${COLOR_DIR}%s${RESET}" "$dir_name")")

# --- Line 1, field 2: git branch (omit if not a repo) ---
if [ -n "$cwd" ] && GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" branch --show-current 2>/dev/null)
	if [ -n "$branch" ]; then
		line1_segments+=("$(printf "${DIM}branch:${RESET} ${COLOR_BRANCH}%s${RESET}" "$branch")")
	fi
fi

# --- Line 2, field 1: model display name ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
line2_segments=()
if [ -n "$model" ]; then
	line2_segments+=("$(printf "${DIM}model:${RESET} ${COLOR_MODEL}%s${RESET}" "$model")")
fi

# --- Line 2, field 2: context window used percentage (color-scaled) ---
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
	used_int=$(printf '%.0f' "$used")
	if [ "$used_int" -ge 80 ]; then
		color='\033[31m' # red
	elif [ "$used_int" -ge 50 ]; then
		color='\033[33m' # yellow
	else
		color='\033[32m' # green
	fi
	line2_segments+=("$(printf "${DIM}context:${RESET} ${color}%s%% used${RESET}" "$used_int")")
fi

# --- Line 2, field 3: rate limits (5h / 7d), omit entirely if neither present ---
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$five" ] || [ -n "$week" ]; then
	rate_str=""
	[ -n "$five" ] && rate_str="5h:$(printf '%.0f' "$five")%"
	if [ -n "$week" ]; then
		[ -n "$rate_str" ] && rate_str="$rate_str "
		rate_str="${rate_str}7d:$(printf '%.0f' "$week")%"
	fi
	line2_segments+=("$(printf "${DIM}limits:${RESET} ${COLOR_RATE}%s${RESET}" "$rate_str")")
fi

# Join a segment array with a dim " | " delimiter
join_segments() {
	local out=""
	for seg in "$@"; do
		if [ -z "$out" ]; then
			out="$seg"
		else
			out="$out \033[2m|${RESET} $seg"
		fi
	done
	printf "%s" "$out"
}

line1=$(join_segments "${line1_segments[@]}")
line2=$(join_segments "${line2_segments[@]}")

printf "%b\n%b\n" "$line1" "$line2"
