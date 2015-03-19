# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/slop/slop-3.6.0.ebuild,v 1.2 2014/11/10 15:59:47 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGES.md README.md"

inherit ruby-fakegem

DESCRIPTION="A simple option parser with an easy to remember syntax and friendly API"
HOMEPAGE="https://github.com/injekt/slop"
SRC_URI="https://github.com/injekt/${PN}/archive/v${PV}.tar.gz -> ${P}.tgz"

LICENSE="MIT"
SLOT="3"
KEYWORDS="~amd64 ~ppc64 ~x86"

IUSE=""

ruby_add_bdepend "test? ( dev-ruby/minitest )"

all_ruby_prepare() {
	sed -i -e '/git ls-files/d' slop.gemspec || die
}