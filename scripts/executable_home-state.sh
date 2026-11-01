#!/bin/bash
# Copy browser bookmarks (and any other home-only state listed in the
# manifest) to a folder, and copy them back on another Mac.
# macOS /bin/bash is 3.2 — keep this script compatible with that.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: home-state.sh <backup|restore> <folder>

  backup   Copy the paths in home-state.manifest into <folder>.
  restore  Copy that snapshot back into the current home directory.

<folder> is used only for this snapshot (a directory on a disk or USB
drive, for example /Volumes/Backup/home-state). Running backup again
replaces the snapshot in that folder. Pass a different folder to keep
an older copy.

Firefox bookmarks are stored in places.sqlite, which also contains
browsing history, so that file is included. Quit the apps before
restore. Backup can run while they are open; quit them first if you
want the latest Safari or Chromium bookmarks flushed to disk.

Reading ~/Library/Safari needs Full Disk Access for the app that runs
this script.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
manifest=$script_dir/home-state.manifest
entries=""
stage=""
archive=""
dest=""
saved_count=0
restored_count=0
failed=0
blocked=0

cleanup() {
  if [[ -n "$entries" ]]; then
    rm -f "$entries"
  fi
  if [[ -n "$stage" ]]; then
    rm -rf "$stage"
  fi
}
trap cleanup EXIT

trim() {
  local s="$1"
  s=${s#"${s%%[![:space:]]*}"}
  s=${s%"${s##*[![:space:]]}"}
  printf '%s\n' "$s"
}

validate_rel() {
  local path="$1"
  case "$path" in
    "" | /* | .. | ../* | */.. | */../*)
      die "invalid path in manifest: $path"
      ;;
  esac
}

normalize_manifest() {
  local line kind path
  : >"$entries"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%$'\r'}
    line=$(trim "$line")
    case "$line" in
      "" | \#*) continue ;;
    esac
    kind=${line%%[[:space:]]*}
    path=${line#"$kind"}
    path=$(trim "$path")
    case "$kind" in
      chromium | firefox | safari | file | dir) ;;
      *) die "unknown kind in $manifest: $kind" ;;
    esac
    [[ -n "$path" ]] || die "missing path for $kind in $manifest"
    validate_rel "$path"
    printf '%s\t%s\n' "$kind" "$path" >>"$entries"
  done <"$manifest"
}

for_each_entry() {
  local action="$1" kind path
  while IFS=$'\t' read -r kind path; do
    [[ -n "$kind" ]] || continue
    "$action" "$kind" "$path"
  done <"$entries"
}

# name|executable-path-fragment, matched with pgrep -f.
# Longer prefixes must be listed before shorter ones (Chrome Dev before Chrome).
process_specs_for() {
  case "$1" in
    "Library/Application Support/BraveSoftware/Brave-Browser"*)
      printf '%s\n' "Brave Browser|/Brave Browser.app/Contents/MacOS/Brave Browser"
      ;;
    "Library/Application Support/Google/Chrome Dev"*)
      printf '%s\n' "Google Chrome Dev|/Google Chrome Dev.app/Contents/MacOS/Google Chrome Dev"
      ;;
    "Library/Application Support/Google/Chrome Beta"*)
      printf '%s\n' "Google Chrome Beta|/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta"
      ;;
    "Library/Application Support/Google/Chrome Canary"*)
      printf '%s\n' "Google Chrome Canary|/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
      ;;
    "Library/Application Support/Google/Chrome"*)
      printf '%s\n' "Google Chrome|/Google Chrome.app/Contents/MacOS/Google Chrome"
      ;;
    "Library/Application Support/com.operasoftware.OperaDeveloper"*)
      printf '%s\n' "Opera Developer|/Opera Developer.app/Contents/MacOS/Opera"
      ;;
    "Library/Application Support/com.operasoftware.Opera GX"*)
      printf '%s\n' "Opera GX|/Opera GX.app/Contents/MacOS/Opera"
      ;;
    "Library/Application Support/com.operasoftware.Opera"*)
      printf '%s\n' "Opera|/Opera.app/Contents/MacOS/Opera"
      ;;
    "Library/Application Support/Firefox"*)
      printf '%s\n' "Firefox Developer Edition|/Firefox Developer Edition.app/Contents/MacOS/firefox"
      printf '%s\n' "Firefox|/Firefox.app/Contents/MacOS/firefox"
      ;;
    "Library/Application Support/TorBrowser-Data"*)
      printf '%s\n' "Tor Browser|/Tor Browser.app/Contents/MacOS/firefox"
      ;;
    "Library/Application Support/Microsoft Edge Beta"*)
      printf '%s\n' "Microsoft Edge Beta|/Microsoft Edge Beta.app/Contents/MacOS/Microsoft Edge Beta"
      ;;
    "Library/Application Support/Microsoft Edge Dev"*)
      printf '%s\n' "Microsoft Edge Dev|/Microsoft Edge Dev.app/Contents/MacOS/Microsoft Edge Dev"
      ;;
    "Library/Application Support/Microsoft Edge Canary"*)
      printf '%s\n' "Microsoft Edge Canary|/Microsoft Edge Canary.app/Contents/MacOS/Microsoft Edge Canary"
      ;;
    "Library/Application Support/Microsoft Edge"*)
      printf '%s\n' "Microsoft Edge|/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
      ;;
    "Library/Application Support/Vivaldi Snapshot"*)
      printf '%s\n' "Vivaldi Snapshot|/Vivaldi Snapshot.app/Contents/MacOS/Vivaldi Snapshot"
      ;;
    "Library/Application Support/Vivaldi"*)
      printf '%s\n' "Vivaldi|/Vivaldi.app/Contents/MacOS/Vivaldi"
      ;;
    "Library/Application Support/Arc"*)
      printf '%s\n' "Arc|/Arc.app/Contents/MacOS/Arc"
      ;;
    "Library/Application Support/Chromium"*)
      printf '%s\n' "Chromium|/Chromium.app/Contents/MacOS/Chromium"
      ;;
    "Library/Application Support/Code/"*)
      printf '%s\n' "Visual Studio Code|/Visual Studio Code.app/Contents/MacOS/Code"
      ;;
    "Library/Application Support/Claude/"*)
      printf '%s\n' "Claude|/Claude.app/Contents/MacOS/Claude"
      ;;
    .cursor*)
      printf '%s\n' "Cursor|/Cursor.app/Contents/MacOS/Cursor"
      ;;
    .claude*)
      printf '%s\n' "Claude|/Claude.app/Contents/MacOS/Claude"
      ;;
    Library/Safari*)
      printf '%s\n' "Safari|/Safari.app/Contents/MacOS/Safari"
      ;;
  esac
}

each_running_app() {
  local rel="$1" spec name needle
  while IFS= read -r spec; do
    [[ -n "$spec" ]] || continue
    name=${spec%%|*}
    needle=${spec#*|}
    needle=${needle//./\\.}
    if pgrep -f "$needle" >/dev/null 2>&1; then
      printf '%s\n' "$name"
    fi
  done < <(process_specs_for "$rel")
}

warn_if_running() {
  local rel="$1" name
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    echo "note: $name is running. Saving the files currently on disk."
  done < <(each_running_app "$rel")
}

snapshot_present() {
  local kind="$1" path="$2"
  case "$kind" in
    safari | file) [[ -f "$archive/files/$path" ]] ;;
    *) [[ -e "$archive/files/$path" ]] ;;
  esac
}

preflight_entry() {
  local kind="$1" path="$2" name
  snapshot_present "$kind" "$path" || return 0
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    echo "error: quit $name before restoring ($path)." >&2
    blocked=1
  done < <(each_running_app "$path")
}

copy_file() {
  local src="$1" target="$2"
  mkdir -p "$(dirname "$target")"
  if ! cp -p "$src" "$target"; then
    if [[ "$src" == */Library/Safari/* || "$target" == */Library/Safari/* ]]; then
      echo "error: cannot copy Safari bookmarks." >&2
      echo "error: grant Full Disk Access to the app running this script, then retry." >&2
      echo "error: System Settings → Privacy & Security → Full Disk Access." >&2
    else
      echo "error: failed to copy $src" >&2
    fi
    return 1
  fi
}

sqlite_ok() {
  local db="$1" result
  [[ -s "$db" ]] || return 1
  result=$(sqlite3 "$db" "PRAGMA integrity_check;" 2>/dev/null || true)
  # integrity_check can leave a WAL beside the snapshot. The backup is one file.
  sqlite3 "$db" "PRAGMA journal_mode=DELETE;" >/dev/null 2>&1 || true
  rm -f "${db}-wal" "${db}-shm"
  [[ "$result" == "ok" ]]
}

# A running Firefox holds places.sqlite open. .backup works when the file is
# free. When it is locked, copy the database plus its WAL and back up the copy
# so the snapshot is a single consistent file.
sqlite_backup() {
  local src="$1" target="$2" escaped tmp attempt
  command -v sqlite3 >/dev/null 2>&1 || die "sqlite3 is required to back up Firefox bookmarks"
  mkdir -p "$(dirname "$target")"
  escaped=${target//\'/\'\'}
  rm -f "$target"
  if sqlite3 "$src" ".timeout 1000" ".backup '${escaped}'" 2>/dev/null && sqlite_ok "$target"; then
    return 0
  fi
  rm -f "$target"
  attempt=0
  while [[ "$attempt" -lt 2 ]]; do
    attempt=$((attempt + 1))
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/home-state-places.XXXXXX")
    if cp -p "$src" "$tmp/places.sqlite" \
      && { [[ ! -f "${src}-wal" ]] || cp -p "${src}-wal" "$tmp/places.sqlite-wal"; } \
      && { [[ ! -f "${src}-shm" ]] || cp -p "${src}-shm" "$tmp/places.sqlite-shm"; } \
      && sqlite3 "$tmp/places.sqlite" ".backup '${escaped}'" \
      && sqlite_ok "$target"; then
      rm -rf "$tmp"
      return 0
    fi
    rm -f "$target"
    rm -rf "$tmp"
  done
  return 1
}

abs_dir() {
  (cd "$1" && pwd -P)
}

guard_entry() {
  local kind="$1" path="$2" source real
  source="$HOME/$path"
  [[ -e "$source" ]] || return 0
  case "$kind" in
    file | safari)
      if [[ -d "$source" ]]; then
        real=$(abs_dir "$source")
      else
        real="$(abs_dir "$(dirname "$source")")/$(basename "$source")"
      fi
      [[ "$dest" != "$real" ]] || die "destination is the file being backed up ($path)"
      ;;
    *)
      [[ -d "$source" ]] || return 0
      real=$(abs_dir "$source")
      case "$dest/" in
        "$real/"*) die "destination is inside $path" ;;
      esac
      ;;
  esac
}

profile_key() {
  local base="$1"
  case "$base" in
    *.*) printf '%s\n' "${base#*.}" ;;
    *) printf '%s\n' "$base" ;;
  esac
}

# Prints "name<path" lines for [Profile*] sections. Paths are relative.
list_profiles() {
  local file="$1" line section="" name="" path=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%$'\r'}
    case "$line" in
      \[Profile*\])
        if [[ -n "$path" ]]; then
          printf '%s\t%s\n' "$name" "$path"
        fi
        section=${line#[}
        section=${section%]}
        name=""
        path=""
        ;;
      \[*)
        if [[ -n "$path" ]]; then
          printf '%s\t%s\n' "$name" "$path"
        fi
        section=""
        name=""
        path=""
        ;;
      Name=*)
        [[ -n "$section" ]] || continue
        name=${line#Name=}
        ;;
      Path=*)
        [[ -n "$section" ]] || continue
        path=${line#Path=}
        ;;
    esac
  done <"$file"
  if [[ -n "$path" ]]; then
    printf '%s\t%s\n' "$name" "$path"
  fi
}

profile_has_bookmarks() {
  local dir="$1" f
  if [[ -f "$dir/places.sqlite" ]]; then
    return 0
  fi
  if [[ -d "$dir/bookmarkbackups" ]]; then
    for f in "$dir/bookmarkbackups"/*; do
      if [[ -f "$f" ]]; then
        return 0
      fi
    done
  fi
  return 1
}

# Echoes the live profile path (relative to the Firefox root) or returns 1.
match_profile() {
  local live_ini="$1" want_path="$2" want_name="$3"
  local want_base want_key name path base key
  local key_path="" key_count=0 name_path="" name_count=0
  want_base=$(basename "$want_path")
  want_key=$(profile_key "$want_base")
  while IFS=$'\t' read -r name path; do
    [[ -n "$path" ]] || continue
    if [[ "$path" == "$want_path" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
    base=$(basename "$path")
    if [[ "$base" == "$want_base" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
    key=$(profile_key "$base")
    if [[ "$key" == "$want_key" ]]; then
      key_path=$path
      key_count=$((key_count + 1))
    fi
    if [[ -n "$want_name" && "$name" == "$want_name" ]]; then
      name_path=$path
      name_count=$((name_count + 1))
    fi
  done < <(list_profiles "$live_ini")
  if [[ "$key_count" -eq 1 ]]; then
    printf '%s\n' "$key_path"
    return 0
  fi
  if [[ "$name_count" -eq 1 ]]; then
    printf '%s\n' "$name_path"
    return 0
  fi
  return 1
}

save_file() {
  local src="$1" rel="$2"
  if copy_file "$src" "$archive/files/$rel"; then
    echo "saved $rel"
    saved_count=$((saved_count + 1))
  else
    failed=1
  fi
}

backup_chromium() {
  local rel="$1" root bookmarks relpath found=0
  root="$HOME/$rel"
  if [[ ! -d "$root" ]]; then
    echo "skip (not installed): $rel"
    return 0
  fi
  warn_if_running "$rel"
  while IFS= read -r -d '' bookmarks; do
    found=1
    relpath=${bookmarks#"$HOME/"}
    save_file "$bookmarks" "$relpath"
    if [[ -f "${bookmarks}.bak" ]]; then
      save_file "${bookmarks}.bak" "${relpath}.bak"
    fi
  done < <(find "$root" -maxdepth 4 -type f -name Bookmarks \
    ! -path '*/System Profile/*' ! -path '*/Guest Profile/*' -print0)
  if [[ "$found" -eq 0 ]]; then
    echo "skip (no bookmarks): $rel"
  fi
}

backup_firefox_profile() {
  local rel="$1" profile_rel="$2" profile_dir="$3" f base
  if [[ -f "$profile_dir/places.sqlite" ]]; then
    local target="$archive/files/$rel/$profile_rel/places.sqlite"
    echo "saving $rel/$profile_rel/places.sqlite"
    if sqlite_backup "$profile_dir/places.sqlite" "$target"; then
      echo "saved $rel/$profile_rel/places.sqlite"
      saved_count=$((saved_count + 1))
    else
      echo "error: failed to back up $rel/$profile_rel/places.sqlite. Quit the browser and retry." >&2
      failed=1
    fi
  fi
  if [[ -d "$profile_dir/bookmarkbackups" ]]; then
    for f in "$profile_dir/bookmarkbackups"/*; do
      [[ -f "$f" ]] || continue
      base=$(basename "$f")
      save_file "$f" "$rel/$profile_rel/bookmarkbackups/$base"
    done
  fi
}

backup_firefox() {
  local rel="$1" root path profile_dir
  root="$HOME/$rel"
  if [[ ! -f "$root/profiles.ini" ]]; then
    echo "skip (not installed): $rel"
    return 0
  fi
  warn_if_running "$rel"
  save_file "$root/profiles.ini" "$rel/profiles.ini"
  while IFS=$'\t' read -r _name path; do
    [[ -n "$path" ]] || continue
    case "$path" in
      /*)
        echo "skip (absolute profile path): $rel/$path"
        continue
        ;;
    esac
    profile_dir="$root/$path"
    if ! profile_has_bookmarks "$profile_dir"; then
      echo "skip (no bookmarks): $rel/$path"
      continue
    fi
    backup_firefox_profile "$rel" "$path" "$profile_dir"
  done < <(list_profiles "$root/profiles.ini")
}

backup_file() {
  local rel="$1" src
  src="$HOME/$rel"
  if [[ ! -f "$src" ]]; then
    echo "skip (absent): $rel"
    return 0
  fi
  warn_if_running "$rel"
  save_file "$src" "$rel"
}

backup_dir() {
  local rel="$1" src target
  src="$HOME/$rel"
  if [[ ! -d "$src" ]]; then
    echo "skip (absent): $rel"
    return 0
  fi
  warn_if_running "$rel"
  target="$archive/files/$rel"
  mkdir -p "$target"
  if ! cp -pR "$src/." "$target/"; then
    echo "error: failed to copy $rel" >&2
    failed=1
    return 0
  fi
  echo "saved $rel/"
  saved_count=$((saved_count + 1))
}

backup_entry() {
  local kind="$1" path="$2"
  case "$kind" in
    chromium) backup_chromium "$path" ;;
    firefox) backup_firefox "$path" ;;
    safari) backup_file "$path" ;;
    file) backup_file "$path" ;;
    dir) backup_dir "$path" ;;
  esac
}

restore_profile_payload() {
  local archived_profile="$1" live_profile="$2" label="$3" f base
  mkdir -p "$live_profile"
  if [[ -f "$archived_profile/places.sqlite" ]]; then
    rm -f "$live_profile/places.sqlite-wal" "$live_profile/places.sqlite-shm"
    if copy_file "$archived_profile/places.sqlite" "$live_profile/places.sqlite"; then
      echo "restored $label/places.sqlite"
      restored_count=$((restored_count + 1))
    else
      failed=1
    fi
  fi
  if [[ -d "$archived_profile/bookmarkbackups" ]]; then
    mkdir -p "$live_profile/bookmarkbackups"
    for f in "$archived_profile/bookmarkbackups"/*; do
      [[ -f "$f" ]] || continue
      base=$(basename "$f")
      if copy_file "$f" "$live_profile/bookmarkbackups/$base"; then
        echo "restored $label/bookmarkbackups/$base"
        restored_count=$((restored_count + 1))
      else
        failed=1
      fi
    done
  fi
}

restore_firefox() {
  local rel="$1" archived live name path live_path
  archived="$archive/files/$rel"
  if [[ ! -f "$archived/profiles.ini" ]]; then
    echo "skip (not in snapshot): $rel"
    return 0
  fi
  live="$HOME/$rel"
  if [[ ! -f "$live/profiles.ini" ]]; then
    mkdir -p "$live"
    if ! copy_file "$archived/profiles.ini" "$live/profiles.ini"; then
      failed=1
      return 0
    fi
    echo "restored $rel/profiles.ini"
    restored_count=$((restored_count + 1))
    while IFS=$'\t' read -r name path; do
      [[ -n "$path" ]] || continue
      profile_has_bookmarks "$archived/$path" || continue
      restore_profile_payload "$archived/$path" "$live/$path" "$rel/$path"
    done < <(list_profiles "$archived/profiles.ini")
    return 0
  fi

  while IFS=$'\t' read -r name path; do
    [[ -n "$path" ]] || continue
    profile_has_bookmarks "$archived/$path" || continue
    if live_path=$(match_profile "$live/profiles.ini" "$path" "$name"); then
      if [[ "$live_path" != "$path" ]]; then
        echo "matched $rel/$path -> $rel/$live_path"
      fi
      restore_profile_payload "$archived/$path" "$live/$live_path" "$rel/$live_path"
    else
      echo "error: no Firefox profile on this Mac matches $rel/$path (name: ${name:-unknown})." >&2
      echo "error: restore before launching Firefox the first time, or launch it once so a $(profile_key "$(basename "$path")") profile exists, then retry." >&2
      failed=1
    fi
  done < <(list_profiles "$archived/profiles.ini")
}

restore_chromium() {
  local rel="$1" root bookmarks relpath
  root="$archive/files/$rel"
  if [[ ! -d "$root" ]]; then
    echo "skip (not in snapshot): $rel"
    return 0
  fi
  while IFS= read -r -d '' bookmarks; do
    relpath=${bookmarks#"$archive/files/"}
    if copy_file "$bookmarks" "$HOME/$relpath"; then
      echo "restored $relpath"
      restored_count=$((restored_count + 1))
    else
      failed=1
    fi
    if [[ -f "${bookmarks}.bak" ]]; then
      if copy_file "${bookmarks}.bak" "$HOME/${relpath}.bak"; then
        echo "restored ${relpath}.bak"
        restored_count=$((restored_count + 1))
      else
        failed=1
      fi
    fi
  done < <(find "$root" -type f -name Bookmarks -print0)
}

restore_file() {
  local rel="$1" src
  src="$archive/files/$rel"
  if [[ ! -f "$src" ]]; then
    echo "skip (not in snapshot): $rel"
    return 0
  fi
  if copy_file "$src" "$HOME/$rel"; then
    echo "restored $rel"
    restored_count=$((restored_count + 1))
  else
    failed=1
  fi
}

restore_dir() {
  local rel="$1" src target
  src="$archive/files/$rel"
  if [[ ! -d "$src" ]]; then
    echo "skip (not in snapshot): $rel"
    return 0
  fi
  target="$HOME/$rel"
  mkdir -p "$target"
  if ! cp -pR "$src/." "$target/"; then
    echo "error: failed to restore $rel" >&2
    failed=1
    return 0
  fi
  echo "restored $rel/"
  restored_count=$((restored_count + 1))
}

restore_entry() {
  local kind="$1" path="$2"
  case "$kind" in
    chromium) restore_chromium "$path" ;;
    firefox) restore_firefox "$path" ;;
    safari) restore_file "$path" ;;
    file) restore_file "$path" ;;
    dir) restore_dir "$path" ;;
  esac
}

computer_name() {
  local name=""
  if command -v scutil >/dev/null 2>&1; then
    name=$(scutil --get ComputerName 2>/dev/null || true)
  fi
  if [[ -n "$name" ]]; then
    printf '%s\n' "$name"
    return 0
  fi
  hostname
}

dest_reusable() {
  local entry base
  for entry in "$dest"/* "$dest"/.[!.]* "$dest"/..?*; do
    [[ -e "$entry" ]] || continue
    base=$(basename "$entry")
    case "$base" in
      files | files.new | files.previous | source.txt | source.txt.new | HOME_STATE_FORMAT | HOME_STATE_FORMAT.new | .DS_Store) ;;
      .incoming.*) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

# A previous backup can die mid-swap. Put a finished new tree back, and drop
# a new tree that never replaced the previous one.
finish_interrupted_swap() {
  if [[ ! -d "$dest/files" && -d "$dest/files.new" ]]; then
    mv "$dest/files.new" "$dest/files"
  fi
  if [[ ! -f "$dest/source.txt" && -f "$dest/source.txt.new" ]]; then
    mv "$dest/source.txt.new" "$dest/source.txt"
  fi
  if [[ ! -f "$dest/HOME_STATE_FORMAT" && -f "$dest/HOME_STATE_FORMAT.new" ]]; then
    mv "$dest/HOME_STATE_FORMAT.new" "$dest/HOME_STATE_FORMAT"
  fi
  rm -f "$dest/source.txt.new" "$dest/HOME_STATE_FORMAT.new"
  rm -rf "$dest/files.new" "$dest/files.previous"
}

remove_incoming() {
  local entry
  for entry in "$dest"/.incoming.*; do
    [[ -e "$entry" ]] || continue
    rm -rf "$entry"
  done
}

commit_stage() {
  local leftover
  rm -rf "$dest/files.new" "$dest/files.previous"
  mv "$stage/files" "$dest/files.new"
  mv "$stage/source.txt" "$dest/source.txt.new"
  mv "$stage/HOME_STATE_FORMAT" "$dest/HOME_STATE_FORMAT.new"
  if [[ -d "$dest/files" ]]; then
    mv "$dest/files" "$dest/files.previous"
  fi
  mv "$dest/files.new" "$dest/files"
  mv "$dest/source.txt.new" "$dest/source.txt"
  mv "$dest/HOME_STATE_FORMAT.new" "$dest/HOME_STATE_FORMAT"
  rm -rf "$dest/files.previous"
  leftover=$stage
  stage=""
  rm -rf "$leftover"
}

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "this script only supports macOS home paths"
}

do_backup() {
  local home_real
  require_macos
  if [[ -e "$dest" && ! -d "$dest" ]]; then
    die "destination exists and is not a directory: $dest"
  fi
  mkdir -p "$dest"
  dest=$(abs_dir "$dest")
  home_real=$(abs_dir "$HOME")
  [[ "$dest" != "$home_real" ]] || die "destination cannot be your home directory"
  finish_interrupted_swap
  dest_reusable || die "destination is not empty and is not an existing home-state snapshot: $dest"
  for_each_entry guard_entry
  remove_incoming
  stage=$(mktemp -d "$dest/.incoming.XXXXXX")
  archive=$stage
  mkdir -p "$archive/files"
  for_each_entry backup_entry
  if [[ "$saved_count" -eq 0 ]]; then
    die "nothing was backed up"
  fi
  {
    printf 'created: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'host: %s\n' "$(computer_name)"
    printf 'user: %s\n' "$USER"
  } >"$stage/source.txt"
  printf '1\n' >"$stage/HOME_STATE_FORMAT"
  commit_stage
  echo "Backed up $saved_count files to $dest"
  if [[ "$failed" -ne 0 ]]; then
    echo "error: backup finished with errors. The snapshot still contains what could be copied." >&2
    exit 1
  fi
}

do_restore() {
  local version
  require_macos
  [[ -d "$dest" ]] || die "no such folder: $dest"
  dest=$(abs_dir "$dest")
  [[ -f "$dest/HOME_STATE_FORMAT" ]] || die "not a home-state snapshot (missing HOME_STATE_FORMAT): $dest"
  version=$(tr -d '[:space:]' <"$dest/HOME_STATE_FORMAT")
  [[ "$version" == "1" ]] || die "unsupported snapshot version: $version"
  archive=$dest
  if [[ -f "$dest/source.txt" ]]; then
    echo "Snapshot:"
    sed 's/^/  /' "$dest/source.txt"
  fi
  for_each_entry preflight_entry
  if [[ "$blocked" -ne 0 ]]; then
    exit 1
  fi
  for_each_entry restore_entry
  if [[ "$restored_count" -eq 0 ]]; then
    die "nothing was restored"
  fi
  echo "Restored $restored_count files from $dest"
  if [[ "$failed" -ne 0 ]]; then
    echo "error: restore finished with errors." >&2
    exit 1
  fi
}

main() {
  local mode
  [[ -f "$manifest" ]] || die "manifest not found: $manifest"
  if [[ $# -eq 1 && ($1 == "-h" || $1 == "--help" || $1 == "help") ]]; then
    usage
    exit 0
  fi
  if [[ $# -ne 2 ]]; then
    usage >&2
    exit 2
  fi
  mode=$1
  dest=$2
  case "$mode" in
    backup | restore) ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  entries=$(mktemp "${TMPDIR:-/tmp}/home-state.XXXXXX")
  normalize_manifest
  case "$mode" in
    backup) do_backup ;;
    restore) do_restore ;;
  esac
}

main "$@"
