# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

MY_PV="${PV/_/-}"
PKG_COMMIT="7018c18"
EGO_PN="github.com/mattermost/platform"
DESCRIPTION="Open source Slack-alternative in Golang and React"
HOMEPAGE="https://mattermost.com"
SRC_URI="https://github.com/mattermost/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=net-libs/nodejs-6.0.0"
DEPEND="${RDEPEND}
	sys-apps/yarn"

RESTRICT="mirror strip"

pkg_setup() {
	if has network-sandbox $FEATURES; then
		die "www-apps/mattermost-server require 'network-sandbox' to be disabled in FEATURES"
	fi

	enewgroup mattermost
	enewuser mattermost -1 -1 -1 mattermost
}

src_prepare() {
	# Disable developer settings and fix path
	sed -i \
		-e 's|"ConsoleLevel": "DEBUG"|"ConsoleLevel": "INFO"|g' \
		-e 's|"SiteURL": "http://localhost:8065"|"SiteURL": ""|g' \
		-e 's|"Directory": ".*"|"Directory": "/var/lib/mattermost/"|g' \
		-e 's|tcp(dockerhost:3306)|unix(/run/mysqld/mysqld.sock)|g' \
		src/${EGO_PN}/config/default.json || die

	# Reset email sending to original configuration
	sed -i \
		-e 's|"SendEmailNotifications": true,|"SendEmailNotifications": false,|g' \
		-e 's|"FeedbackEmail": "test@example.com",|"FeedbackEmail": "",|g' \
		-e 's|"SMTPServer": "dockerhost",|"SMTPServer": "",|g' \
		-e 's|"SMTPPort": "2500",|"SMTPPort": "",|g' \
		src/${EGO_PN}/config/default.json || die

	default
}

src_compile() {
	local GOLDFLAGS="-s -w \
	-X github.com/mattermost/platform/model.BuildNumber=${MY_PV} \
	-X 'github.com/mattermost/platform/model.BuildDate=$(date -u)' \
	-X github.com/mattermost/platform/model.BuildHash=${PKG_COMMIT} \
	-X github.com/mattermost/platform/model.BuildHashEnterprise=none \
	-X github.com/mattermost/platform/model.BuildEnterpriseReady=false"

	# Unfortunately 'network-sandbox' needs to disabled
	# because sys-apps/yarn fetch dependencies here:
	emake -C src/${EGO_PN}/webapp build

	GOPATH="${S}" go install -v -ldflags \
		"${GOLDFLAGS}" ${EGO_PN}/cmd/platform || die
}

src_install() {
	exeinto /usr/libexec/${PN}/bin
	doexe bin/platform

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	pushd src/${EGO_PN} > /dev/null || die
	insinto /etc/${PN}
	doins config/README.md
	newins config/default.json config.json
	fowners mattermost:mattermost /etc/${PN}/config.json
	fperms 600 /etc/${PN}/config.json

	insinto /usr/share/${PN}
	doins -r {fonts,i18n,templates}

	insinto /usr/share/${PN}/webapp
	doins -r webapp/dist
	popd > /dev/null || die

	dosym ../../../../etc/${PN}/config.json /usr/libexec/${PN}/config/config.json
	dosym ../../share/${PN}/fonts /usr/libexec/${PN}/fonts
	dosym ../../share/${PN}/i18n /usr/libexec/${PN}/i18n
	dosym ../../share/${PN}/templates /usr/libexec/${PN}/templates
	dosym ../../share/${PN}/webapp /usr/libexec/${PN}/webapp

	diropts -o mattermost -g mattermost -m 0750
	dodir /var/{lib,log}/${PN}
	dosym ../../../var/log/${PN} /usr/libexec/${PN}/logs
}