# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep EGO_VENDOR in sync with Godeps
EGO_VENDOR=(
	"collectd.org 2ce1445 github.com/collectd/go-collectd"
	"github.com/Shopify/sarama 574d314"
	"github.com/Sirupsen/logrus 61e43dc"
	"github.com/aerospike/aerospike-client-go 95e1ad7"
	"github.com/amir/raidman c74861f"
	"github.com/aws/aws-sdk-go 7524cb9"
	"github.com/beorn7/perks 4c0e845"
	"github.com/cenkalti/backoff b02f2bb"
	"github.com/couchbase/go-couchbase bfe555a"
	"github.com/couchbase/gomemcached 4a25d2f"
	"github.com/couchbase/goutils 5823a0c"
	"github.com/davecgh/go-spew 346938d"
	"github.com/docker/docker b89aff1"
	"github.com/eapache/go-resiliency b86b1ec"
	"github.com/eapache/go-xerial-snappy bb955e0"
	"github.com/eapache/queue 44cc805"
	"github.com/eclipse/paho.mqtt.golang d4f545e"
	"github.com/go-sql-driver/mysql 2e00b5c"
	"github.com/gobwas/glob bea32b9"
	"github.com/golang/protobuf 8ee7999"
	"github.com/golang/snappy 7db9049"
	"github.com/gorilla/mux 392c28f"
	"github.com/hailocab/go-hostpool e80d13c"
	"github.com/hashicorp/consul 63d2fc6"
	"github.com/influxdata/tail a395bf9"
	"github.com/influxdata/toml 5d1d907"
	"github.com/influxdata/wlog 7c63b0a"
	"github.com/jackc/pgx b84338d"
	"github.com/kardianos/osext c2c54e5"
	"github.com/kardianos/service 6d3a0ee"
	"github.com/kballard/go-shellquote d8ec1a6"
	"github.com/klauspost/crc32 cb6bfca"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/miekg/dns 99f84ae"
	"github.com/naoina/go-stringutil 6b638e9"
	"github.com/nats-io/go-nats ea95856"
	"github.com/nats-io/nats ea95856"
	"github.com/nats-io/nuid 289cccf"
	"github.com/nsqio/go-nsq a53d495"
	"github.com/pierrec/lz4 5c9560b"
	"github.com/pierrec/xxHash 5a00444"
	"github.com/prometheus/client_golang c317fb7"
	"github.com/prometheus/client_model fa8ad6f"
	"github.com/prometheus/common dd2f054"
	"github.com/prometheus/procfs 1878d9f"
	"github.com/rcrowley/go-metrics 1f30fe9"
	"github.com/samuel/go-zookeeper 1d7be4e"
	"github.com/satori/go.uuid 5bf94b6"
	"github.com/shirou/gopsutil 9a4a916"
	"github.com/soniah/gosnmp 5ad50dc"
	"github.com/streadway/amqp 63795da"
	"github.com/stretchr/testify 4d4bfba"
	"github.com/vjeantet/grok d73e972"
	"github.com/wvanbergen/kafka bc265fe"
	"github.com/wvanbergen/kazoo-go 9689573"
	"github.com/yuin/gopher-lua 66c871e"
	"github.com/zensqlmonitor/go-mssqldb ffe5510"
	"golang.org/x/crypto dc137be github.com/golang/crypto"
	"golang.org/x/net f249948 github.com/golang/net"
	"golang.org/x/text 506f9d5 github.com/golang/text"
	"gopkg.in/dancannon/gorethink.v1 edc7a6a github.com/GoRethink/gorethink"
	"gopkg.in/fatih/pool.v2 6e328e6 github.com/fatih/pool"
	"gopkg.in/mgo.v2 3f83fa5 github.com/go-mgo/mgo"
	"gopkg.in/olivere/elastic.v5 ee3ebce github.com/olivere/elastic"
	"gopkg.in/yaml.v2 4c78c97 github.com/go-yaml/yaml"
)

PKG_COMMIT="7192e68"
EGO_PN="github.com/influxdata/telegraf"
EGO_LDFLAGS="-s -w -X main.version=${PV} -X main.branch=${PV} -X main.commit=${PKG_COMMIT}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="An agent for collecting, processing, aggregating, and writing metrics"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 -1 ${PN}
}

src_compile() {
	GOPATH="${S}" go install -v \
		-ldflags "${EGO_LDFLAGS}" ${EGO_PN}/cmd/${PN} || die
}

src_install() {
	dobin bin/${PN}

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd ${PN}.conf

	pushd src/${EGO_PN} > /dev/null || die
	systemd_dounit scripts/${PN}.service

	insinto /etc/${PN}
	doins etc/${PN}.conf

	insinto /etc/logrotate.d
	doins etc/logrotate.d/${PN}
	popd > /dev/null || die

	keepdir /etc/${PN}/${PN}.d /var/log/${PN}
	fowners ${PN}:${PN} /var/log/${PN}
}
