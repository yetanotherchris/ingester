class Zolam < Formula
  desc "Semantic search file ingester for ChromaDB"
  homepage "https://github.com/yetanotherchris/zolam"
  version "VERSION"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/yetanotherchris/zolam/releases/download/vVERSION/zolam-darwin-arm64.tar.gz"
      sha256 "SHA256"
    else
      url "https://github.com/yetanotherchris/zolam/releases/download/vVERSION/zolam-darwin-amd64.tar.gz"
      sha256 "SHA256"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/yetanotherchris/zolam/releases/download/vVERSION/zolam-linux-arm64.tar.gz"
      sha256 "SHA256"
    else
      url "https://github.com/yetanotherchris/zolam/releases/download/vVERSION/zolam-linux-amd64.tar.gz"
      sha256 "SHA256"
    end
  end

  def install
    bin.install "zolam"
  end

  test do
    assert_match "zolam version", shell_output("#{bin}/zolam --version")
  end
end
