#!/usr/bin/env bash
# Claude Code statusline, styled after the starship prompt.
#   - ANSI-16 colours only: Ghostty follows the system Github Light/Dark theme,
#     so any hardcoded hex would be unreadable in one of the two.
#   - No emoji except ⛅︎, which the starship aws module already proves renders
#     at one cell in MD IO. Wide glyphs push the line past the edge.
#   - Ordered by importance: notifications truncate this row from the right.
set -u

# \x1f, not tab: bash strips empty fields when IFS is whitespace, and effort,
# git_worktree and used_percentage are all absent early in a session.
IFS=$'\x1f' read -r model effort pct big cwd proj wt added removed < <(
  jq -r '[
    .model.display_name,
    (.effort.level // ""),
    ((.context_window.used_percentage // 0) | floor),
    (if .exceeds_200k_tokens then "1" else "0" end),
    .workspace.current_dir,
    .workspace.project_dir,
    (.workspace.git_worktree // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0)
  ] | map(tostring) | join("\u001f")'
)

dim=$'\e[2;3m' reset=$'\e[0m' blue=$'\e[34m' grey=$'\e[90;3m'
green=$'\e[32m' yellow=$'\e[33;3m' red=$'\e[31m' sep="${dim} · ${reset}"

# Machine-local extras live outside this repo. The file may switch a built-in
# segment off (STATUSLINE_NO_AWS, STATUSLINE_NO_K8S) or define statusline_local,
# whose stdout is appended as one more segment and may use the colours above.
# A machine without the file gets the generic line.
LOCAL_SEGMENTS="$HOME/.claude/statusline.local.sh"
# shellcheck source=/dev/null
[[ -r $LOCAL_SEGMENTS ]] && . "$LOCAL_SEGMENTS"

# context bar: 10 cells. Amber past the 200k long-context price step, red at 80%.
filled=$(( pct / 10 )); (( filled > 10 )) && filled=10
bar=""
for ((i = 0; i < 10; i++)); do (( i < filled )) && bar+="▓" || bar+="░"; done
if   (( pct >= 80 )); then ctx="$red"
elif [[ $big == 1 ]];  then ctx="$yellow"
else                       ctx="$green"; fi
out="${ctx}${bar}${reset}${dim} ${pct}%${reset}"

# model, and reasoning effort when the model reports one
out+="${sep}${grey}${model}${effort:+ $effort}${reset}"

# Blast radius. The aws profile shows only when one is in the environment; the
# kube context follows the [kubernetes] detect_files rule from starship.toml, so
# it appears in a directory that deploys charts and nowhere else. That also
# keeps kubectl off the hot path in every other repo.
if [[ -z ${STATUSLINE_NO_AWS:-} ]]; then
  aws="${AWS_PROFILE:-${AWSUME_PROFILE:-}}"
  [[ -n $aws ]] && out+="${sep}${yellow}⛅︎ ${aws}${reset}"
fi
if [[ -z ${STATUSLINE_NO_K8S:-} ]] &&
   [[ -e "$cwd/helmfile.yaml" || -e "$cwd/Chart.yaml" || -e "$cwd/kustomization.yaml" ]]; then
  kube=$(kubectl config current-context 2>/dev/null)
  [[ -n $kube ]] && out+="${sep}${yellow}k8s ${kube}${reset}"
fi

if declare -F statusline_local >/dev/null; then
  extra=$(statusline_local) || extra=""
  [[ -n $extra ]] && out+="${sep}${extra}${reset}"
fi

# directory: basename, with the worktree name or an arrow when cwd left home
dir="${cwd##*/}"
[[ -n $wt ]] && dir+="${dim}@${wt}${reset}${blue}"
[[ $cwd != "$proj" ]] && dir="${proj##*/}${dim}→${reset}${blue}${dir}"
out+="${sep}${blue}${dir}${reset}"

branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ ${#branch} -gt 24 ]] && branch="${branch:0:23}…"
[[ -n $branch ]] && out+="${grey} on ${branch}${reset}"

(( added || removed )) && out+="${sep}${green}+${added}${reset}${dim}/${reset}${red}-${removed}${reset}"

printf '%s\n' "$out"
