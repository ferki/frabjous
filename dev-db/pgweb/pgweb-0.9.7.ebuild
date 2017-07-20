# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot

EGO_PN="github.com/sosedoff/${PN}"

DESCRIPTION="Web-based PostgreSQL database browser written in Go"
HOMEPAGE="https://sosedoff.github.io/pgweb/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-go/go-bindata"

src_prepare() {
	sed -i 's/$(BINDATA_OPTS) $(BINDATA_IGNORE) //g' \
		src/${EGO_PN}/Makefile || die

	default
}

src_compile() {
	export GOPATH="${S}:$(get_golibdir_gopath)"

	cd src/${EGO_PN} || die

	emake assets && go install -v || die
}

src_install() {
	dobin bin/${PN}
	dodoc src/${EGO_PN}/{README,CHANGELOG}.md
}