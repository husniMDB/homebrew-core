class Apko < Formula
  desc "Build OCI images from APK packages directly without Dockerfile"
  homepage "https://github.com/chainguard-dev/apko"
  url "https://github.com/chainguard-dev/apko/archive/refs/tags/v0.22.5.tar.gz"
  sha256 "2d89201850e1b1d7fb63edb0bc6645211fb290dadcade31f4bc032c107bb8b1d"
  license "Apache-2.0"
  head "https://github.com/chainguard-dev/apko.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b2e989602dc890ef27eec947e741e94f130020abaa8f2fd15657e78562a659d5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b2e989602dc890ef27eec947e741e94f130020abaa8f2fd15657e78562a659d5"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "b2e989602dc890ef27eec947e741e94f130020abaa8f2fd15657e78562a659d5"
    sha256 cellar: :any_skip_relocation, sonoma:        "9665317dfc0afacd6c17e343584af2e91007dd66281ad4bc14f6c8a73e6d3eaa"
    sha256 cellar: :any_skip_relocation, ventura:       "9665317dfc0afacd6c17e343584af2e91007dd66281ad4bc14f6c8a73e6d3eaa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6332a774b0a108d506f56e8df017bbb3c7e405a15909d3f5cae4c49ef1b04d1b"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X sigs.k8s.io/release-utils/version.gitVersion=#{version}
      -X sigs.k8s.io/release-utils/version.gitCommit=brew
      -X sigs.k8s.io/release-utils/version.gitTreeState=clean
      -X sigs.k8s.io/release-utils/version.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"apko", "completion")
  end

  test do
    (testpath/"test.yml").write <<~YAML
      contents:
        repositories:
          - https://dl-cdn.alpinelinux.org/alpine/edge/main
        packages:
          - alpine-base

      entrypoint:
        command: /bin/sh -l

      # optional environment configuration
      environment:
        PATH: /usr/sbin:/sbin:/usr/bin:/bin

      # only key found for arch riscv64 [edge],
      archs:
        - riscv64
    YAML
    system bin/"apko", "build", testpath/"test.yml", "apko-alpine:test", "apko-alpine.tar"
    assert_predicate testpath/"apko-alpine.tar", :exist?

    assert_match version.to_s, shell_output(bin/"apko version 2>&1")
  end
end
