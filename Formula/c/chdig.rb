class Chdig < Formula
  desc "Dig into ClickHouse with TUI interface"
  homepage "https://github.com/azat/chdig"
  url "https://github.com/azat/chdig/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "f1455281aad6b3fba56680631b4b5eade8d50b277c33619eaaa937143a981587"
  license "MIT"
  head "https://github.com/azat/chdig.git", branch: "main"

  livecheck do
    url :stable
    regex(%r{^chdig/v?(\d+(?:\.\d+)+)$}i)
  end

  depends_on "pyoxidizer" => [:build]
  depends_on "python@3.11" => [:build]
  depends_on "rust" => [:build]

  def install
    # workaround for [1], copy pyoxidizer binary to temporary directory (since
    # sometimes pyoxidizer uses directory where binary lies for temporary data,
    # but you cannot write to under brew, you will got EPERM)
    #
    #   [1]: https://github.com/indygreg/PyOxidizer/issues/730
    mkdir_p ".build"
    pyoxidizer_cmd = which("pyoxidizer")
    ln_sf pyoxidizer_cmd, ".build/pyoxidizer"
    ENV.prepend_path "PATH", "#{buildpath}/.build"

    system "make", "chdig", "build_completion", "deploy-binary"
    bin.install "target/chdig"
    bash_completion.install "target/chdig.bash-completion" => "chdig"
  end

  test do
    # Sometimes even if the compilation is OK, binary may not work, let's try.
    system bin/"chdig", "--help"
  end
end
