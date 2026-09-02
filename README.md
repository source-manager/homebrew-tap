# source-manager/homebrew-tap

The Homebrew tap for **[Source Manager](https://github.com/source-manager/dist)**, a
desktop GUI for viewing and managing Git repositories.

```bash
brew tap source-manager/tap
brew install --cask --no-quarantine source-manager
```

## Why `--no-quarantine`

macOS runs its first-launch check on the `com.apple.quarantine` attribute, which is
set by whatever *downloaded* a file. Homebrew sets it by default; this asks it not
to.

The builds are signed **ad-hoc** rather than with an Apple Developer ID, so with
the attribute set macOS refuses to open the app at all. Without it, there is
nothing to check and the app opens normally. Nothing is disabled and no setting is
changed: the flag says you are vouching for this download rather than asking Apple
to.

If you install without it, the app lands in `/Applications` and will not start.
Either reinstall with the flag, or open it once, let macOS refuse, and press
**Open Anyway** in System Settings → Privacy & Security. (On macOS 15 and later
the old Control-click → Open trick no longer works.)

When the app is notarised this line loses the flag and nothing else changes.

## What it will not install

**Intel Macs.** The release is built on an Apple Silicon runner against a
non-universal Qt, so the cask declares `depends_on arch: :arm64` and `brew` refuses
rather than installing something that cannot run. **macOS older than 15**, for the
same class of reason: the Qt frameworks inside the bundle are built for the
runner's own macOS.

## Everything else

```bash
brew upgrade --cask source-manager      # a new release
brew uninstall --cask source-manager    # remove it
brew uninstall --zap --cask source-manager   # and its preferences and fleet
```

`--zap` deliberately leaves the keychain alone: emptying an application's files is
one promise and taking your forge tokens out of your keychain is another.

## How this repository is kept

`Casks/source-manager.rb` is the only file that matters, and its `version` and
`sha256` are written by a workflow in `source-manager/app` after a release is
published — never by hand. That workflow downloads the disk image anonymously,
over the same public URL your `brew` will use, and digests what arrived; if the
release is still a draft the download fails and the cask is left where it was.

Everything else in the cask — the url, the app stanza, the architecture and macOS
constraints, the zap list — is edited here.
