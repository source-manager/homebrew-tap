cask "source-manager" do
  # Both of these are written by the `Homebrew cask` workflow in
  # source-manager/app, through tools/bump-cask.sh, after a release has been
  # published — never by hand, so that the digest always describes the bytes a
  # reader will actually receive.
  version "0.0.1"
  sha256 "c7eb9c860f273e62dd7df5839aaf97a1b6e836727c053109f74068198c417d03"

  url "https://github.com/source-manager/dist/releases/download/v#{version}/SourceManager-#{version}-macOS.dmg"
  name "Source Manager"
  desc "Desktop GUI for viewing and managing Git repositories"
  homepage "https://github.com/source-manager/dist"

  livecheck do
    url :url
    strategy :github_latest
  end

  # No Sparkle, no self-updater: a new version arrives through `brew upgrade`.
  auto_updates false

  # The release is built on an Apple Silicon runner against Homebrew's Qt, which
  # is not universal, so there is no Intel build to offer. Declared rather than
  # left out: `brew` then refuses on an Intel Mac, which is a sentence, where
  # installing would be an app that cannot start.
  depends_on arch: :arm64

  # Measured from the artifact, not chosen: the app binary's LC_BUILD_VERSION says
  # `minos 26.0`, because it was built against the macOS 26 SDK with no deployment
  # target set, and everything Homebrew contributed — libgit2 and what it loads —
  # is built for the running macOS too. `brew audit --online` reads that same load
  # command and errors if this line disagrees.
  #
  # Lowering it means building the release against an older SDK with a deployment
  # target set, and against frameworks built for that release — not editing this
  # line. `tools/make-dmg.sh --min-macos` turns a mismatch into a refusal.
  #
  # The symbol form *is* the minimum ("or newer"); the `">= :symbol"` spelling this
  # used to carry is deprecated and warns on every `brew` invocation.
  depends_on macos: :tahoe

  app "SourceManager.app"

  # What the app writes outside its own bundle. The keychain entry a forge token
  # lives in is deliberately not here: `zap` empties an application's files, and
  # taking somebody's credentials out of their keychain is a different promise.
  zap trash: [
    "~/Library/Application Support/pasdam/SourceManager",
    "~/Library/Application Support/SourceManager",
    "~/Library/Preferences/*pasdam*SourceManager*.plist",
    "~/Library/Saved Application State/io.github.pasdam.SourceManager.savedState",
  ]

  caveats <<~EOS
    This build is signed ad-hoc rather than with a Developer ID, so macOS refuses
    to open it unless Homebrew is told not to mark it as downloaded:

      brew install --cask --no-quarantine source-manager

    If you have just installed it without that flag, reinstall with it — or open
    the app once, let macOS refuse, and press Open Anyway in
    System Settings > Privacy & Security.
  EOS
end
