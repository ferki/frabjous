# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools git-r3

DESCRIPTION="Fork of libstrophe for use with Profanity XMPP Client"
HOMEPAGE="https://github.com/boothj5/libmesode"
EGIT_REPO_URI="https://github.com/boothj5/libmesode.git"
RESTRICT="mirror"

LICENSE="|| ( MIT GPL-3 )"
SLOT="0"
KEYWORDS=""
IUSE="doc examples libressl +ssl static-libs test"

RDEPEND="dev-libs/expat
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
DEPEND="${RDEPEND}
	test? ( dev-libs/check )
	doc? ( app-doc/doxygen )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable ssl tls) \
		$(use_enable test static) \
		$(use_enable static-libs static) \
		|| die "econf failed"
}
src_compile() {
	default
	if use doc; then
		doxygen || die
		HTML_DOCS=( docs/html/* )
	fi
}

src_install() {
	default
	use examples && dodoc -r examples
}
