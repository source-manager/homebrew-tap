cask "source-manager" do
  # Both of these are written by the `Homebrew cask` workflow in
  # source-manager/app, through tools/bump-cask.sh, after a release has been
  # published. Until the first release they are a placeholder: the url below
  # resolves to nothing and `brew install` refuses, which is the honest state for
  # a tap whose product has not shipped yet.
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

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

  # The frameworks macdeployqt copies in are Homebrew's, built for the runner's
  # own macOS. Lowering this means building the release on an older runner with a
  # deployment target set, not editing this line.
  depends_on macos: ">= :sequoia"

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
