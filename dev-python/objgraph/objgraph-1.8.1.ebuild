# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/objgraph/objgraph-1.8.1.ebuild,v 1.1 2014/12/04 09:23:08 heroxbd Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Draws Python object reference graphs with graphviz"
HOMEPAGE="http://mg.pov.lt/objgraph/"
SRC_URI="mirror://pypi/o/${PN}/${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0"
IUSE="doc"

DEPEND=""
RDEPEND="media-gfx/graphviz"

python_install_all() {
	use doc && local HTML_DOCS=(  docs/* )

	distutils-r1_python_install_all
}