# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit multilib toolchain-funcs versionator

MY_PV=$(replace_version_separator 3 '')
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua"
HOMEPAGE="http://prosody.im/"
SRC_URI="http://prosody.im/tmp/${MY_PV}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="ipv6 jit +libevent libressl mysql postgres sqlite +ssl +zlib"

DEPEND="net-im/jabber-base
		!jit? ( >=dev-lang/lua-5.1:0 )
		jit? ( dev-lang/luajit:2 )
		>=net-dns/libidn-1.1
		!libressl? ( dev-libs/openssl:0 )
		libressl? ( dev-libs/libressl:= )"
RDEPEND="${DEPEND}
		>=dev-lua/luaexpat-1.3.0
		dev-lua/luafilesystem
		ipv6? ( >=dev-lua/luasocket-3 )
		!ipv6? ( dev-lua/luasocket )
		libevent? ( >=dev-lua/luaevent-0.4.3 )
		mysql? ( dev-lua/luadbi[mysql] )
		postgres? ( dev-lua/luadbi[postgres] )
		sqlite? ( dev-lua/luadbi[sqlite] )
		ssl? ( <dev-lua/luasec-0.6 )
		zlib? ( dev-lua/lua-zlib )"

S=${WORKDIR}/${MY_P}

JABBER_ETC="/etc/jabber"
JABBER_SPOOL="/var/spool/jabber"

src_prepare() {
	default
	epatch "${FILESDIR}/${PN}-0.9.2-cfg.lua.patch"
	sed -i -e "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!"\
		 Makefile || die
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	luajit=""
	if use jit; then
		luajit="--runwith=luajit"
	fi
	./configure \
		--ostype=linux $luajit \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-include=/usr/include \
		--with-lua-lib=/usr/$(get_libdir)/lua \
		--cflags="${CFLAGS} -Wall -fPIC -D_GNU_SOURCE" \
		--ldflags="${LDFLAGS} -shared" \
		--c-compiler="$(tc-getCC)" \
		--linker="$(tc-getCC)" \
		--require-config || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install
	newinitd "${FILESDIR}/${PN}".initd ${PN}
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}".logrotate "${PN}"
}

src_test() {
	cd tests || die
	./run_tests.sh || die
}
