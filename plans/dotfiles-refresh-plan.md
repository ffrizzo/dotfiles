# Dotfiles Refresh Plan — Close the Fresh-Install Gap

## Context

The dotfiles repo hasn't been touched since it was written and the machine has drifted a lot since then — new tools, a new secondary "confidential" repo, changed preferences, and a few outright bugs that would bite on a real fresh install. The goal isn't a redesign; it's making the next fresh install actually reproduce today's machine with one command per repo, without surprises. Two live audits (repo read-through + machine inspection: `brew bundle check`, `brew leaves`/`cask` diffs, `mdls` usage stats, live-vs-repo file diffs) turned up three categories of problems:

1. **Outright bugs** — things that would error or silently do the wrong thing on a fresh run, independent of any preference.
2. **Drift** — the live machine changed and the repo never caught up (tracked files, dock, macOS defaults).
3. **Gaps** — real tools/apps in daily use that the repo never captured at all, including a whole second repo (`dotfiles-confidential`) that isn't referenced anywhere in this one.

Decisions already confirmed with you: keep VS Code + Cursor (drop Zed), keep `cp -a` (no symlinks, but add a way to pull live edits back into the repo), 1Password/Tailscale/NordVPN/YubiKey/Ledger Live belong to `dotfiles-confidential` (not duplicated here), drop LastPass and OrcaSlicer, and Ledger Live is being replaced by Ledger Wallet (usage data confirms: Ledger Wallet used yesterday, Ledger Live/LastPass/OrcaSlicer show zero Spotlight usage).

## 1. Fix outright bugs

- **`setup.sh`** calls `sh install-tools.sh` (line 7) — this file doesn't exist (renamed to `install-cli-tools.sh` at some point per git history, which is already called on line 4). Delete the dead line.
- **`Brewfile`**: `brew bundle check` fails hard on `tap "goreleaser/tap"` / `brew "goreleaser/tap/goreleaser"` — the formula no longer exists under that name. The machine actually has `goreleaser` installed as a **cask**, not the tap formula. Replace with `cask "goreleaser"` and drop the tap line.
- **`Brewfile`**: renamed cask tokens: `logi-options-plus` → `logi-options+`, `autodesk-fusion360` → `autodesk-fusion`, `opera-developer` → `opera@developer` (all three warn), and `firefox-developer-edition` → `firefox@developer-edition` (fully invalid now — `brew bundle check` errors outright on the old name, this one was missed in the initial audit and caught during implementation verification).
- **`Brewfile`**: `rustup-init` → `rustup` (the machine has the `rustup` formula installed directly; `rustup-init` is the old bootstrapper name).
- **`home/.zshrc`**: sources `$(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme` unconditionally, but the Brewfile has both the tap and formula for p10k **commented out** — so this line errors on every shell start on a fresh install. You've already worked around this locally by commenting the line out (confirmed via live diff) but never committed that fix. Plan: remove the p10k source line and the dead commented-out Brewfile entries for it, matching what you're actually running today.
- **`Brewfile`**: `mas "Grammarly for Safari"` — `mas list` shows nothing installed via the Mac App Store at all, and Grammarly is already covered by `cask "grammarly"`. Drop the stale `mas` line.
- **`home/.zshenv`** sources `$HOME/.cargo/env` unconditionally, which doesn't exist until `rustup` has actually initialized a toolchain — on a truly fresh machine this errors until that's done manually. Document as a one-line manual step in the README right after `brew bundle` ("run `rustup default stable` once") rather than scripting it, consistent with keeping things simple.

## 2. Sync tracked dotfiles to what's actually live

Live-vs-repo diffs turned up real drift beyond the p10k line above:

- **`home/.zprofile`**: set `EDITOR='code'` (confirmed default), and add the `export PATH="/opt/homebrew/opt/node@22/bin:$PATH"` line that's live but untracked.
- **`home/.zshrc`**: remove the `vault` oh-my-zsh plugin (present in repo, absent live — matches you no longer using Vault), and add the Rancher-Desktop-managed PATH block (`### MANAGED BY RANCHER DESKTOP ... ###`) that's live but untracked — harmless to track even though Rancher Desktop would re-add it on first launch anyway. (The live `asdf` shims PATH line is superseded by the `mise` migration in section 7 below, not carried forward as-is.)
- **`home/.gitconfig-confidential`** is tracked in this repo **as an empty file**, while the real live file has 27 lines (work email override, etc.) and isn't backed up in *either* repo. Since `setup.sh` does `cp -a ./home/ ~/`, re-running setup would silently wipe the real file back to empty. Fix: stop tracking this file in the main repo entirely (delete it from `home/`), and move the real content into `dotfiles-confidential/home/` instead — that repo already exists specifically for private/work config and already ships `home/.ssh/config` the same way. This closes the only spot where a real secret-adjacent file was one `cp -a` away from being destroyed.
- **`osx-user-defaults.sh`** sets `com.apple.dock tilesize -int 29`; live is `71`. Everything else spot-checked (autohide, `AppleShowAllExtensions`, Finder view style) already matches. Update the script's tilesize to `71` to reflect your actual preference.
- **`setup-dock.py`** hardcodes a stale app list (includes Discord, which isn't even installed anymore; uses Chrome Canary instead of the Chrome Dev you actually use now). Update `thirdPartyApps` to match the live dock: Warp, Cursor, Visual Studio Code, Claude, Slack, Spotify, Microsoft Outlook, Brave Browser, Google Chrome Dev, Firefox Developer Edition.

## 3. Add the real gaps to `Brewfile`

Filtered using `brew bundle check`/`leaves`/`cask` diffs plus Spotlight `kMDItemLastUsedDate`/`kMDItemUseCount` (today is 2026-07-30) so this isn't a guess:

**CLI tools** (all present as `brew leaves`, i.e. deliberately installed standalone — zsh history was inconclusive as a usage signal since it showed zero hits even for tools you obviously use, so "is a leaf" is the more trustworthy signal here): `gh`, `dive`, `pandoc`, `protobuf`, `jfrog-cli`, `stripe-cli`, `mole`, `svu`, `ngrok`, `docker-credential-helper`.

**Toolchain versions actually installed** (not in Brewfile at all today): `node@22`, `go@1.21`, `gradle@7`, `openjdk@11`, `openjdk@21`, `zulu@8`.

**Casks — confirmed active by usage data:**
- `freecad` (24 opens, last used 2026-07-27)
- `claude` (25 opens, last used 2026-07-29)
- `cursor` (confirmed by you directly, keep alongside VS Code)
- `ledger-wallet` (21 opens, last used 2026-07-28 — replacing `ledger-live`)
- `microsoft-outlook` (70 opens, last used today), `microsoft-word`, `microsoft-auto-update` (bundled MS 365 apps)

**Casks confirmed unused, excluded per your answer and/or zero Spotlight usage:** `lastpass`, `orcaslicer` (your call), `ledger-live` (replaced), `anydesk` and `trae` (some Spotlight opens logged, but you confirmed you don't actually use either), plus two more the data flagged the same way: `ghostty` and `imhex` (both show `(null)` last-used/use-count — never actually opened).

**Not added — already owned by `dotfiles-confidential`:** `1password`, `1password-cli`, `tailscale`, `nordvpn`, `yubico-yubikey-manager`. You confirmed both NordVPN and Tailscale stay as-is (NordVPN's `(null)` Spotlight usage stat doesn't mean it's unwanted), and that the stray `mullvadvpn` cask receipt (pointing at a `Caskroom/mullvad-vpn` folder that no longer exists) isn't required — that cleanup, like the rest of this list, belongs in `dotfiles-confidential`, not this repo.

**Remove from Brewfile as rot (not installed / superseded):** `google-chrome-canary` (replaced by `google-chrome@dev`), `istat-menus` (replaced by `istat-menus@6`), `shiftit` (fully superseded by `rectangle`, which is already listed), `vmware-fusion` (not installed). `discord` stays in the Brewfile — you confirmed you still use it; it's just not installed on this particular machine right now.

## 4. VS Code / Cursor extension parity

- Delete `install-vscode-plugins.sh` — it's already commented out of `setup.sh`, and it's drifted from the Brewfile's `vscode` entries (e.g. it references `bungcip.better-toml` while the Brewfile has since moved to `tamasfe.even-better-toml`). The Brewfile's `vscode "..."` lines are the single source of truth via `brew bundle`.
- Update the Brewfile's `vscode` entries to match `code --list-extensions`: drop `VisualStudioExptTeam.intellicode-api-usage-examples`, `VisualStudioExptTeam.vscodeintellicode` (uninstalled), and `zxh404.vscode-proto3` (replaced by `drblury.protobuf-vsc`); add `anthropic.claude-code`, `docker.docker`, `drblury.protobuf-vsc`, `esbenp.prettier-vscode`, `ms-azuretools.vscode-containers`, `ms-python.debugpy`, `ms-python.vscode-python-envs`, `oracle.oracle-java`, `vscjava.vscode-gradle`.
- `brew bundle`'s `vscode` entries only target the `code` CLI, not Cursor. Add a short loop in `install-cli-tools.sh` (or a new small script) that also runs `cursor --install-extension <id>` for each entry, since Cursor accepts the same extension IDs. Keeps one extension list for both editors instead of maintaining two.
- Optional/nice-to-have: track Cursor's `~/Library/Application Support/Cursor/User/settings.json` and `keybindings.json` in `home/Library/...` alongside the existing VS Code ones, so Cursor's config round-trips through `cp -a` too.

## 5. Document the two-repo install flow

Right now `setup.sh` and `README.md` never mention `dotfiles-confidential` exists — a true fresh install today requires remembering, from memory, to separately clone and run a second private repo for 1Password/SSH/work tools. Fix: update `README.md`'s Installation section to spell out both steps explicitly (this repo first, then clone+run `dotfiles-confidential`), and add a final `echo` reminder at the end of `setup.sh` pointing at it. No new automation/cloning logic — just make the two-step reality visible instead of tribal knowledge.

## 6. Reverse-sync helper (keeps `cp -a`, closes the drift problem)

Per your call to keep `cp -a` rather than symlinks: add a small `sync-from-home.sh` that copies the tracked files **back** from `~` into `./home/` (mirror direction of what `setup.sh` does today). Run it before committing whenever you've tweaked `.zshrc`/`.zprofile`/VS Code settings/etc. locally — this is exactly how `.zshrc`, `.zprofile`, and the p10k line ended up silently out of sync in the first place, and a one-command pull-back fixes that without symlinks.

## 7. Replace `asdf` with `mise`

You said you don't like `asdf` and want something more modern — that's a reasonable call, and the ecosystem has mostly moved on. The current standard replacement is [**mise**](https://mise.jdx.dev) (formerly `rtx`): same core idea (polyglot runtime version manager, still reads `.tool-versions`), but it's a single fast Rust binary, has quicker shell activation than asdf's shim model, and is the tool most asdf users migrate to today. (The other modern contender is `proto` from the Moonrepo team, but `mise` has wider plugin coverage and is the more common default recommendation.)

What this actually touches, since `asdf` here only has one thing in real use — a `terraform` plugin with two installed versions (1.6.6, 1.9.5); the `nodejs` plugin has zero versions installed and is dead weight, since Node already comes from `brew node@22`:

- **`Brewfile`**: drop `brew "asdf"`, add `brew "mise"`.
- **`home/.zshrc`**: instead of carrying forward the live `asdf` shims PATH line, add `eval "$(mise activate zsh)"`.
- Migrate just the `terraform` versions: `mise use -g terraform@1.6.6` and `mise use -g terraform@1.9.5` (mise's `terraform` plugin is asdf-plugin-compatible, so this is a like-for-like swap). Drop the `nodejs` plugin rather than migrating it.
- Document one manual post-install step in the README (`mise install` to pick up the pinned versions) — same category as the `rustup default stable` step, since actual runtime installs aren't something `brew bundle` can do for you.
- Uninstall `asdf` from the machine once `mise` is confirmed working — a one-time manual cleanup for you, not scripted.

## 8. Other modern CLI swaps you confirmed

- **`Brewfile`**: `brew "hey"` → `brew "oha"`. `hey` (rakyll/hey) is unmaintained upstream; `oha` is an actively-maintained Rust rewrite with the same CLI shape plus a live TUI and HTTP/2/3 support.
- **`Brewfile`**: `brew "httpie"` → `brew "xh"`. `xh` is a Rust rewrite of httpie, near drop-in (has an HTTPie-compat mode), and starts noticeably faster than the Python-based original.
- **`Brewfile`**: remove `cask "keybase"` — effectively unmaintained since the Zoom acquisition (dependency bumps only, `keybase.pub` shut down in 2023), and not something you use enough to keep around.
- **`Brewfile`**: remove `cask "rapidapi"` — in maintenance mode since Nokia's 2024 acquisition of Rapid's tech, no longer actively developed.

## Explicitly deferred / out of scope

- No symlink/Stow migration (your call — `cp -a` stays, improved by #6 instead).
- No automation of secrets/SSH/GPG (already correctly handled by `dotfiles-confidential`).
- The stray `mullvadvpn` cask receipt cleanup and any other `dotfiles-confidential` Brewfile changes — flagged above but left to you since it's a different repo. NordVPN and Tailscale stay as-is, no change needed there.
- Stale leftover `iStat Menus.app` (old, non-`@6` copy still on disk) — cosmetic disk cruft, not a dotfiles concern.
- **OpenTofu**: considered as a Terraform alternative, but you're staying on Terraform — no change.
- **Granted**: considered for AWS SSO role-switching, but doesn't apply to how you actually use AWS SSO — not adopted.

## Verification

- `brew bundle check --verbose --file=Brewfile` should report all dependencies satisfied with no errors (currently hard-fails on the `goreleaser` tap formula).
- Open a new terminal tab/window after the `.zshrc`/`.zprofile`/`.zshenv` edits — no `command not found` / `no such file or directory` errors at shell start.
- `code --list-extensions` and `cursor --list-extensions` both match the Brewfile's `vscode` list.
- `git config --global --list` still resolves `user.email` correctly for both personal and work contexts after moving `.gitconfig-confidential` to `dotfiles-confidential`.
- Diff `setup-dock.py`'s app list against a live `defaults read com.apple.dock persistent-apps` dump.
