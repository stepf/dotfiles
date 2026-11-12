#!/usr/bin/env bash
# Claude Code statusline, styled after the starship prompt.
# Use ANSI-16 colours only, because the terminal switches between light and dark themes.
# Every glyph must be one cell wide; wide emoji push the line past the edge.
# Segments are ordered by importance, since truncation eats the row from the right.
set -u

# \x1f, not tab, because bash merges empty fields when IFS is whitespace.
# _proj and _wt are unused, but must stay so the later fields land in the right variables.
IFS=$'\x1f' read -r model effort pct five five_at cwd _proj _wt added removed \
                 pr_num pr_state pr_kind wt_name wt_branch repo_name week < <(
  jq -r '[
    .model.display_name,
    (.effort.level // ""),
    ((.context_window.used_percentage // 0) | floor),
    (if .rate_limits.five_hour.used_percentage == null then ""
     else (.rate_limits.five_hour.used_percentage | floor) end),
    (if .rate_limits.five_hour.resets_at == null then ""
     else (.rate_limits.five_hour.resets_at | floor) end),
    .workspace.current_dir,
    .workspace.project_dir,
    (.workspace.git_worktree // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0),
    (.pr.number // ""),
    (.pr.review_state // ""),
    (.pr.kind // ""),
    (.worktree.name // ""),
    (.worktree.branch // ""),
    (.workspace.repo.name // ""),
    (if .rate_limits.seven_day.used_percentage == null then ""
     else (.rate_limits.seven_day.used_percentage | floor) end)
  ] | map(tostring) | join("\u001f")'
)

# Colour only what needs attention: red is a limit coming up, yellow is worth a glance,
# green is good news, dim is punctuation.
dim=$'\e[2;3m' reset=$'\e[0m'
green=$'\e[32m' yellow=$'\e[33;3m' red=$'\e[31m' sep="${dim} · ${reset}"
# shellcheck disable=SC2034  # unused here on purpose; statusline_local may use them
grey=$'\e[90;3m' blue=$'\e[34m'

# Machine-local extras: the file may set STATUSLINE_NO_AWS or STATUSLINE_NO_K8S, or
# define statusline_local, whose output becomes one more segment.
LOCAL_SEGMENTS="$HOME/.claude/statusline.local.sh"
# shellcheck source=/dev/null
[[ -r $LOCAL_SEGMENTS ]] && . "$LOCAL_SEGMENTS"

# Context: yellow from 50%, red at the auto-compact point. 80% is the default, but it is
# server config, so set STATUSLINE_COMPACT_PCT in statusline.local.sh if it differs.
: "${STATUSLINE_COMPACT_PCT:=80}"
if   (( pct >= STATUSLINE_COMPACT_PCT )); then ctx="$red"
elif (( pct >= 50 ));                     then ctx="$yellow"
else                                           ctx="";      fi
out="${ctx}◱ ${pct}%${reset}"

# 5-hour rate limit, red from 80%. Only subscriptions report it, and only after the first
# response, so an empty field hides the segment instead of showing 0%.
if [[ -n $five ]]; then
  (( five >= 80 )) && fc="$red" || fc=""
  out+="${sep}${fc}◷ ${five}%${reset}"

  # From 75%, show the reset as a clock time. A countdown would go stale, because the
  # line only redraws on each message. printf %(fmt)T formats the time without a fork.
  if [[ -n $five_at ]] && (( five >= 75 )); then
    printf -v now '%(%s)T' -1
    (( five_at > now )) && printf -v at '%(%H:%M)T' "$five_at" \
      && out+=" ↻${at}"
  fi
fi

# Weekly limit, shown only from 80% and always red, as its own "wk 91%" segment after the 5-hour one.
[[ -n $week ]] && (( week >= 80 )) && out+="${sep}${red}wk ${week}%${reset}"

# Model and effort as short handles: "Opus 5 (1M context)" with high effort becomes "o5 h".
name="${model%% (*}"
handle="${name:0:1}"; handle="${handle,,}"
ver="${name#* }"; [[ $ver != "$name" ]] && handle+="$ver"
case $effort in
  low) e=l;; medium) e=m;; high) e=h;; xhigh) e=x;; max) e=mx;; *) e="$effort";;
esac

# » marks a model chosen by opusplan. The input JSON doesn't say so, only settings.json
# does, and that holds the default, so only Opus or Sonnet handles can carry the mark.
cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
plan=""
if [[ $handle == [os]* ]] && [[ $(jq -r '.model // ""' "$cfg" 2>/dev/null) == opusplan ]]; then
  plan="»"
fi
out+="${sep}${plan}${handle}${e:+ $e}"

# Profile number (p1, p2), shown only when a claude2 profile (<name>-2) exists.
prof="${CLAUDE_CONFIG_DIR:-}"; prof="${prof%/}"
[[ $prof =~ ^(.+)-([0-9]+)$ ]] && base="${BASH_REMATCH[1]}" num="${BASH_REMATCH[2]}" || base=""
if [[ -n $base && -d $base ]]; then
  out+="${sep}p${num}"
elif [[ $prof == "$HOME/.claude-profiles/"* ]]; then
  for alt in "$prof"-[0-9]*; do [[ -d $alt ]] && out+="${sep}p1"; break; done
fi

# The AWS profile and kube context show where a command would land. The kube context
# only appears in chart directories, like starship's detect_files, which keeps kubectl
# out of every other repo. ⛅︎ needs its variation selector to stay one cell wide.
if [[ -z ${STATUSLINE_NO_AWS:-} ]]; then
  aws="${AWS_PROFILE:-${AWSUME_PROFILE:-}}"
  [[ -n $aws ]] && out+="${sep}${yellow}⛅︎ ${aws}${reset}"
fi
if [[ -z ${STATUSLINE_NO_K8S:-} ]] &&
   [[ -e "$cwd/helmfile.yaml" || -e "$cwd/Chart.yaml" || -e "$cwd/kustomization.yaml" ]]; then
  kube=$(kubectl config current-context 2>/dev/null)
  [[ -n $kube ]] && out+="${sep}${yellow}⎈ ${kube}${reset}"
fi

if declare -F statusline_local >/dev/null; then
  extra=$(statusline_local) || extra=""
  [[ -n $extra ]] && out+="${sep}${extra}${reset}"
fi

# Prefer .workspace.repo.name, because a worktree's git toplevel is the worktree directory.
# Don't use project_dir: in a multi-repo workspace it is the folder above all repos.
git_top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
repo="${repo_name:-${git_top##*/}}"
[[ -z $repo ]] && repo="${cwd##*/}"
# A long repo name gets cut, the branch never does.
[[ ${#repo} -gt 24 ]] && repo="${repo:0:23}…"

if [[ -n $wt_branch ]]; then
  branch="$wt_branch"
else
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi

# One segment: repo@branch, repo→subdir@branch in a subdirectory, and (wt) for a worktree.
anchor="$git_top"; [[ -n $wt_name ]] && anchor="$cwd"
dir_proj=""
if [[ -n $anchor && $cwd != "$anchor" ]]; then
  dir_proj="${repo}${dim}→${reset}"
  dir_base="${cwd##*/}"
else
  dir_base="$repo"
fi
seg_branch=""; [[ -n $branch ]] && seg_branch="@${branch}"
dir_wt=""; [[ -n $wt_name ]] && dir_wt="${dim}(wt)${reset}"

seg_diff=""
(( added || removed )) && seg_diff="${sep}+${added}${dim}/${reset}-${removed}"

# Open PR (#) or GitLab MR (!) for this branch. The dot shows the review: filled is
# decided (green approved, yellow changes), hollow is waiting, dotted is a draft.
seg_pr=""
if [[ -n $pr_num ]]; then
  [[ $pr_kind == mr ]] && seg_pr="${sep}!${pr_num}" || seg_pr="${sep}#${pr_num}"
  case $pr_state in
    approved)          seg_pr+="${green} ●${reset}" ;;
    changes_requested) seg_pr+="${yellow} ●${reset}" ;;
    pending)           seg_pr+=" ○" ;;
    draft)             seg_pr+="${dim} ◌${reset}" ;;
  esac
fi

# Drop whole segments from the right until the row fits: PR, diff, (wt), then repo→.
# COLUMNS is the only width source, because tput sees no terminal here; without it
# nothing is dropped. Raise STATUSLINE_WIDTH_MARGIN in statusline.local.sh if a segment still clips.
shopt -s extglob
probe="◱"

# Visible width of $1 into $_w. Under a C locale ${#s} counts bytes, so subtract
# UTF-8 continuation bytes; never skip the check, or the terminal cuts a segment in half.
vis_width() {
  local s=${1//$'\e'[\[]*([0-9;])m/} cont
  if (( ${#probe} == 1 )); then
    _w=${#s}
  else
    cont=${s//[!$'\x80'-$'\xbf']/}
    _w=$(( ${#s} - ${#cont} ))
  fi
}

assemble() {
  line="${out}${sep}${dir_proj}${dir_base}${seg_branch}${dir_wt}${seg_diff}${seg_pr}"
}

assemble
dropped=""
if [[ ${COLUMNS:-} =~ ^[0-9]+$ ]]; then
  budget=$(( COLUMNS - ${STATUSLINE_WIDTH_MARGIN:-1} ))
  for drop in pr diff wt proj; do
    vis_width "$line"
    (( _w <= budget )) && break
    case $drop in
      pr)   seg_pr=""   ;;
      diff) seg_diff="" ;;
      wt)   dir_wt=""   ;;
      proj) dir_proj="" ;;
    esac
    dropped+="$drop "
    assemble
  done
fi

# Set STATUSLINE_DEBUG to a file path to log the width and what was dropped.
if [[ -n ${STATUSLINE_DEBUG:-} ]]; then
  vis_width "$line"
  printf '%(%F %T)T COLUMNS=%s margin=%s probe=%s width=%s dropped=[%s]\n' \
    -1 "${COLUMNS:-unset}" "${STATUSLINE_WIDTH_MARGIN:-1}" "${#probe}" \
    "$_w" "${dropped% }" >> "$STATUSLINE_DEBUG"
fi

printf '%s\n' "$line"
