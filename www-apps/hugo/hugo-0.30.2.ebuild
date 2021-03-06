# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep EGO_VENDOR in sync with vendor/vendor.json
# Generate partially with:
# curl 'https://raw.githubusercontent.com/gohugoio/hugo/v0.30.2/vendor/vendor.json' | jq '.package[] | "\(.path) \(.revision[0:7])"'
EGO_VENDOR=(
	"github.com/BurntSushi/toml a368813"
	"github.com/PuerkitoBio/purell fd18e05"
	"github.com/PuerkitoBio/urlesc de5bf2a"
	"github.com/alecthomas/chroma 02c4adc"
	"github.com/bep/gitmap de8030e"
	"github.com/chaseadamsio/goorgeous 7daffad"
	"github.com/cpuguy83/go-md2man 1d903dc"
	"github.com/danwakefield/fnmatch cbb64ac"
	"github.com/dchest/cssmin fb8d9b4"
	"github.com/dlclark/regexp2 7632a26"
	"github.com/eknkc/amber 4ed0bf7"
	"github.com/fsnotify/fsnotify 4da3e2c"
	"github.com/gorilla/websocket 4201258"
	"github.com/hashicorp/go-immutable-radix 8aac270"
	"github.com/hashicorp/golang-lru 0a025b7"
	"github.com/hashicorp/hcl 68e816d"
	"github.com/jdkato/prose 2f88f08"
	"github.com/kardianos/osext ae77be6"
	"github.com/kyokomi/emoji ddd4753"
	"github.com/magiconair/properties 8d7837e"
	"github.com/markbates/inflect ea17041"
	"github.com/miekg/mmark 057eb9e"
	"github.com/mitchellh/mapstructure d0303fe"
	"github.com/nicksnyder/go-i18n ca33e78"
	"github.com/pelletier/go-toml 2009e44"
	"github.com/russross/blackfriday 6d1ef89"
	"github.com/shurcooL/sanitized_anchor_name 86672fc"
	"github.com/spf13/afero 8a6ade7"
	"github.com/spf13/cast acbeb36"
	"github.com/spf13/cobra 0dacccf"
	"github.com/spf13/fsync 12a01e6"
	"github.com/spf13/jwalterweatherman 12bd96e"
	"github.com/spf13/nitro 24d7ef3"
	"github.com/spf13/pflag be7121d"
	"github.com/spf13/viper d9cca5e"
	"github.com/yosssi/ace ea038f4"
	"golang.org/x/image 334384d github.com/golang/image"
	"golang.org/x/net 0a93976 github.com/golang/net"
	"golang.org/x/sys 314a259 github.com/golang/sys"
	"golang.org/x/text 1cbadb4 github.com/golang/text"
	"gopkg.in/yaml.v2 eb3733d github.com/go-yaml/yaml"
)
# Deps that are not needed:
# github.com/davecgh/go-spew
# github.com/fortytw2/leaktest
# github.com/inconshreveable/mousetrap
# github.com/stretchr/testify
# github.com/pmezard/go-difflib

inherit golang-vcs-snapshot

COMMIT_HASH="142ebba"
EGO_PN="github.com/gohugoio/hugo"
DESCRIPTION="A static HTML and CSS website generator written in Go"
HOMEPAGE="https://gohugo.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pygments"

RDEPEND="pygments? ( >=dev-python/pygments-2.1.3 )"
RESTRICT="mirror strip test"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w \
		-X ${EGO_PN}/hugolib.CommitHash=${COMMIT_HASH} \
		-X ${EGO_PN}/hugolib.BuildDate=$(date +%FT%T%z)"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die

	./hugo gen man --dir="${T}"/man || die
}

src_install() {
	dobin hugo
	doman "${T}"/man/*
}
