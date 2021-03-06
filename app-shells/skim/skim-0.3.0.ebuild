# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Generate with:
# curl -s 'https://raw.githubusercontent.com/lotabout/skim/v0.3.0/Cargo.lock' | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.1
ansi_term-0.9.0
atty-0.2.2
bitflags-0.9.1
cargo_metadata-0.2.3
clap-2.26.2
clippy-0.0.162
clippy_lints-0.0.162
dtoa-0.4.2
either-1.1.0
env_logger-0.4.3
getopts-0.2.15
itertools-0.6.2
itoa-0.3.4
kernel32-sys-0.2.2
lazy_static-0.2.8
libc-0.2.20
log-0.3.8
matches-0.1.4
memchr-1.0.1
num-traits-0.1.40
pulldown-cmark-0.0.15
quine-mc_cluskey-0.2.4
quote-0.3.15
redox_syscall-0.1.31
redox_termios-0.1.1
regex-0.2.1
regex-syntax-0.4.0
semver-0.6.0
semver-parser-0.7.0
serde-1.0.15
serde_derive-1.0.15
serde_derive_internals-0.16.0
serde_json-1.0.3
shlex-0.1.1
strsim-0.6.0
syn-0.11.11
synom-0.11.3
term_size-0.3.0
termion-1.5.1
textwrap-0.8.0
thread-id-3.0.0
thread_local-0.3.2
time-0.1.38
toml-0.4.5
unicode-normalization-0.1.3
unicode-width-0.1.4
unicode-xid-0.0.4
unreachable-0.1.1
utf8-ranges-1.0.0
utf8parse-0.1.0
vec_map-0.8.0
void-1.0.2
winapi-0.2.8
winapi-build-0.1.1
"

inherit cargo

DESCRIPTION="Fuzzy finder in Rust"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="tmux vim"

RDEPEND="tmux? ( app-misc/tmux )
	vim? ( app-editors/vim )"
RESTRICT="mirror"

DOCS=( {CHANGELOG,README}.md )

src_install() {
	dobin target/release/sk
	einstalldocs

	use tmux && dobin bin/sk-tmux

	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin
		doins plugin/skim.vim
	fi
}
