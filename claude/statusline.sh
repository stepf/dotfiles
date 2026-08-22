#!/usr/bin/env bash
# Claude Code statusline, styled after the starship prompt.
#   - ANSI-16 colours only: Ghostty follows the system Github Light/Dark theme,
#     so any hardcoded hex would be unreadable in one of the two.
#   - No emoji except ⛅︎, which the starship aws module already proves renders
#     at one cell in MD IO. Wide glyphs push the line past the edge, which rules
#     out the 🟢🟡🔴 that most published statuslines mark their thresholds with.
#   - ◱ (context) and ◷ (5h window) are Geometric Shapes, the same width class
#     as the ▓░ this line used to draw a bar with. Square reads as a buffer
#     filling up and circle as time: the one distinction that still separates
#     the two numbers at one cell each, once both have gone red together.
#   - Ordered by importance. Notifications truncate this row from the right,
#     and past COLUMNS the guard at the foot drops whole segments in the same
#     direction, so the two agree about what goes first.
set -u

# \x1f, not tab: bash strips empty fields when IFS is whitespace, and effort,
# git_worktree and five are all absent early in a session.
# _proj and _wt are read but unused: the fields still have to be consumed in
# order for everything after them to land in the right variable.
IFS=$'\x1f' read -r model effort pct five five_at cwd _proj _wt added removed \
                 pr_num pr_state pr_kind wt_name wt_branch repo_name < <(
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
    (.workspace.repo.name // "")
  ] | map(tostring) | join("\u001f")'
)

# Everything is the terminal's neutral foreground unless it is telling me
# something. Red is a wall I am about to hit, yellow is worth a glance, green is
# the one piece of good news the line carries. dim is punctuation only. grey and
# blue stay defined for statusline_local, documented below as free to use them.
dim=$'\e[2;3m' reset=$'\e[0m'
green=$'\e[32m' yellow=$'\e[33;3m' red=$'\e[31m' sep="${dim} · ${reset}"
# shellcheck disable=SC2034  # unused here on purpose; statusline_local may use them
grey=$'\e[90;3m' blue=$'\e[34m'

# Machine-local extras live outside this repo. The file may switch a built-in
# segment off (STATUSLINE_NO_AWS, STATUSLINE_NO_K8S) or define statusline_local,
# whose stdout is appended as one more segment and may use the colours above.
# A machine without the file gets the generic line.
LOCAL_SEGMENTS="$HOME/.claude/statusline.local.sh"
# shellcheck source=/dev/null
[[ -r $LOCAL_SEGMENTS ]] && . "$LOCAL_SEGMENTS"

# context. Neutral is the resting state: below half a window there is nothing
# to decide, so the number should not compete for attention.
#
# Red is the auto-compact point. Claude Code compacts at the effective window
# minus a buffer whose default fraction is 0.2, so 80%. That number is server
# config, not a constant, and CLAUDE_AUTOCOMPACT_PCT_OVERRIDE lowers it further,
# so set STATUSLINE_COMPACT_PCT in statusline.local.sh if this client differs.
# Red is worth the attention: Anthropic's own guidance is that the model is at
# its least intelligent point when compacting, so this is the moment to /clear
# or /rewind rather than let it summarize.
#
# Amber is 50% and nothing else. Anthropic documents context rot as real and
# gradual ("as token count grows, accuracy and recall degrade") but publishes no
# per-model threshold for it, so there is no second condition to test here. If
# they ever publish one for the model in $handle, it belongs in this branch.
: "${STATUSLINE_COMPACT_PCT:=80}"
if   (( pct >= STATUSLINE_COMPACT_PCT )); then ctx="$red"
elif (( pct >= 50 ));                     then ctx="$yellow"
else                                           ctx="";      fi
out="${ctx}◱ ${pct}%${reset}"

# 5-hour rate limit window. Only Claude.ai subscriptions report it, and only
# after the first API response, so an empty field drops the segment rather than
# claiming 0%. Neutral until 80%, where running out becomes a real prospect
# within the window, then red. No amber step: there is nothing to do about this
# number gradually, so it is either background or it is a wall coming up.
if [[ -n $five ]]; then
  (( five >= 80 )) && fc="$red" || fc=""
  out+="${sep}${fc}◷ ${five}%${reset}"

  # resets_at as a wall clock, not a countdown. This line only re-renders on
  # each message, so a countdown sits visibly stale while reading; 09:35 stays
  # true however long the terminal is left alone, with no refreshInterval and
  # no timer. Stays neutral even when the percentage is red: the time is the
  # reference, the percentage is the alarm. A stamp already in the past is
  # dropped: the window has turned over and the percentage above is the fresh one.
  # printf %(fmt)T, not date(1): bash 4.2 formats epoch seconds without a fork.
  #
  # Hidden below 75%. With four fifths of the window left there is nothing to
  # plan around, and the clock appears five points before the red at 80% so it
  # arrives as a warning rather than alongside one.
  if [[ -n $five_at ]] && (( five >= 75 )); then
    printf -v now '%(%s)T' -1
    (( five_at > now )) && printf -v at '%(%H:%M)T' "$five_at" \
      && out+=" ↻${at}"
  fi
fi

# model and effort as handles: "Opus 5 (1M context)" high -> o5 h. The window
# size is dropped on purpose: settings.json pins opus[1m], so the suffix would be
# constant on every line here and say nothing. Some names carry no version
# ("Opus (1M context)", "Fable"), which leaves the bare letter.
name="${model%% (*}"
handle="${name:0:1}"; handle="${handle,,}"
ver="${name#* }"; [[ $ver != "$name" ]] && handle+="$ver"
case $effort in
  low) e=l;; medium) e=m;; high) e=h;; xhigh) e=x;; max) e=mx;; *) e="$effort";;
esac

# opusplan resolves to Opus in plan mode and Sonnet everywhere else, so "s5"
# here is exactly what's running this turn but looks identical to a session
# actually configured to run Sonnet outright. Nothing in this JSON says which
# mode is configured, only the concrete model that's live right now — the
# alias lives in settings.json alone, so read it directly. » prefixes the
# handle to flag "this model is where opusplan landed," not the only model
# the session will ever run.
#
# settings.json is the configured DEFAULT, not this turn's model — a session
# that started as opusplan but was since pointed at Fable via /model still
# reads opusplan there, so the handle itself gets the final say: only o* or
# s* (opusplan's two actual legs) can carry the marker, never f or anything
# else.
cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
plan=""
if [[ $handle == [os]* ]] && [[ $(jq -r '.model // ""' "$cfg" 2>/dev/null) == opusplan ]]; then
  plan="»"
fi
out+="${sep}${plan}${handle}${e:+ $e}"

# Blast radius. The aws profile shows only when one is in the environment; the
# kube context follows the [kubernetes] detect_files rule from starship.toml, so
# it appears in a directory that deploys charts and nowhere else. That also
# keeps kubectl off the hot path in every other repo.
#
# ⎈ is U+2388 HELM SYMBOL, East Asian Width N, so it is one cell in every locale
# and needs no variation selector — unlike the ⛅︎ above it, which is emoji-capable
# and only narrows because of the VS15. Prefer ⎈ over ☸ for exactly that reason.
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

# repo identity: .workspace.repo.name (from the origin remote) survives a
# --worktree checkout, whose own git toplevel is the worktree directory, not
# the repo. It's also the fix for a workspace that holds several repos under
# one umbrella folder: .workspace.project_dir is that umbrella, sitting one
# level ABOVE every repo, so comparing cwd to project_dir made every session
# read "‹umbrella›→...", never the repo cwd was actually in.
git_top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
repo="${repo_name:-${git_top##*/}}"
[[ -z $repo ]] && repo="${cwd##*/}"
# The repo name is the guessable half — it's the same on every line in a
# given directory, and this is the multi-repo workspace's own name for it.
# The branch is the half that actually changes and is worth reading in full,
# so it's the repo name that gives way when the segment runs long.
[[ ${#repo} -gt 24 ]] && repo="${repo:0:23}…"

# branch: .worktree.branch is authoritative for a --worktree session (no
# shell-out needed); everything else still has to ask git directly.
if [[ -n $wt_branch ]]; then
  branch="$wt_branch"
else
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi

# One segment, not three: repo@branch, plus a bare (wt) flag for a --worktree
# session. No separate branch glyph and no worktree slug: the slug used to
# repeat itself against a branch name that (by a ticket-key naming
# convention) already carries it, and repo@branch says exactly as much either
# way.
#
# The arrow survives only for the ordinary case of cd-ing into a subdirectory
# of a plain repo (no worktree in play) — dropped for a worktree session,
# whose cwd already IS the root Claude Code put you at.
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

# Open pull request for this branch, last because it is the first thing a
# notification eats from the right and the least urgent thing here. Absent until
# one is found and gone again once it merges, so it costs nothing at rest.
# GitLab remotes fill the same fields for a merge request, which numbers with !
# rather than #. review_state is independently optional, so a PR with no review
# yet shows the bare number.
#
# The state is one dot, not a word: "approved" alone was nine cells on the
# segment that truncation eats first. Shape says how far along the review is,
# colour says whether it is on me — filled is decided, hollow is waiting, dotted
# is not a real review yet. All four are Geometric Shapes, the block ◱ and ◷
# already proved renders at one cell here.
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

# Assemble, dropping from the right while the row will not fit. Segments go
# whole or not at all: half a "+12/-3" is worse than no diff count.
#
# COLUMNS is the only way to learn the width: Claude Code captures stdout, so
# tput and stty see no terminal from in here. Unset before v2.1.153 and when the
# script is run by hand, and then nothing can be guaranteed and the terminal
# clips mid-segment as it always did.
#
# Width is measured two ways because ${#s} follows the locale, and the locale
# here is whatever Claude Code happened to spawn the script with, not the one in
# the shell. Under UTF-8 ${#s} already counts characters. Under C it counts
# bytes, and every glyph on this row is three of them, so the count comes from
# bytes minus UTF-8 continuation bytes instead. An earlier version probed the
# locale and skipped the guard when it was C, which silently turned the guard
# off and let the terminal clip a segment in half. Measure, never skip.
#
# COLUMNS is the terminal width, not necessarily the width this row may use, so
# STATUSLINE_WIDTH_MARGIN holds back a cell. Raise it in statusline.local.sh if
# a segment still ends up clipped.
#
# Drop order is least useful first: the PR, the diff counts, the worktree name,
# then the project prefix. What survives to the narrowest terminal is the two
# usage numbers, the model, the directory basename and the branch.
shopt -s extglob
probe="◱"

# Visible width of $1 into $_w: no forks, no subshell, locale independent.
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

# Set STATUSLINE_DEBUG to a file path in statusline.local.sh to see what the
# script is actually handed: the width it thinks it has, and what it dropped.
if [[ -n ${STATUSLINE_DEBUG:-} ]]; then
  vis_width "$line"
  printf '%(%F %T)T COLUMNS=%s margin=%s probe=%s width=%s dropped=[%s]\n' \
    -1 "${COLUMNS:-unset}" "${STATUSLINE_WIDTH_MARGIN:-1}" "${#probe}" \
    "$_w" "${dropped% }" >> "$STATUSLINE_DEBUG"
fi

printf '%s\n' "$line"
