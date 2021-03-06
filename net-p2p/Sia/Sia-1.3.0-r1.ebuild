# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/NebulousLabs/demotemutex 235395f"
	"github.com/NebulousLabs/fastrand 60b6156"
	"github.com/NebulousLabs/merkletree 9aa7ce5"
	"github.com/NebulousLabs/bolt 20be698"

	"golang.org/x/crypto 2faea14 github.com/golang/crypto"
	"golang.org/x/net f5079bd github.com/golang/net"
	"golang.org/x/text 836efe4 github.com/golang/text"

	"github.com/NebulousLabs/entropy-mnemonics 7b01a64"
	"github.com/NebulousLabs/errors 98e1f05"
	"github.com/NebulousLabs/go-upnp 11ba854"
	"github.com/NebulousLabs/muxado b4de4d8"

	"github.com/cpuguy83/go-md2man 23709d0"
	"github.com/klauspost/cpuid 09cded8"
	"github.com/klauspost/reedsolomon 48a4fd0"
	"github.com/julienschmidt/httprouter 975b5c4"
	"github.com/inconshreveable/go-update 8152e7e"
	"github.com/kardianos/osext ae77be6"

	"github.com/bgentry/speakeasy 4aabc24"
	"github.com/spf13/cobra 34594c7"
	"github.com/spf13/pflag e57e3ee"
	"gopkg.in/yaml.v2 25c4ec8 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/NebulousLabs/Sia"
DESCRIPTION="Blockchain-based marketplace for file storage"
HOMEPAGE="https://sia.tech"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup sia
	enewuser sia -1 -1 -1 sia
}

src_compile() {
	export GOPATH="${G}"
	emake release-std
}

src_test() {
	default
}

src_install() {
	dobin "${G}"/bin/sia{c,d}
	dodoc doc/*.md

	newinitd "${FILESDIR}"/sia.initd-r2 sia
	systemd_dounit "${FILESDIR}"/sia.service

	diropts -o sia -g sia -m 0750
	dodir /var/lib/sia
}
