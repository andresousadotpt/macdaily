# Homebrew cask template for macdaily.
# CI updates version + sha256 in ~/repos/personal/homebrew-tap on each release.
cask "macdaily" do
  version "0.1.0"
  sha256 :no_check

  url "https://github.com/andresousadotpt/macdaily/releases/download/v#{version}/macdaily-#{version}.zip"
  name "macdaily"
  desc "Daily markdown notes for macOS"
  homepage "https://github.com/andresousadotpt/macdaily"

  depends_on macos: ">= :sonoma"

  app "macdaily.app"

  zap trash: [
    "~/Library/Application Support/MacDaily",
  ]
end
