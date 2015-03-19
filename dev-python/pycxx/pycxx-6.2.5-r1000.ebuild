# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils eutils

DESCRIPTION="Set of facilities to extend Python with C++"
HOMEPAGE="http://cxx.sourceforge.net/ http://sourceforge.net/projects/cxx/"
SRC_URI="mirror://sourceforge/cxx/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

PYTHON_MODULES="CXX"

src_prepare() {
	epatch "${FILESDIR}/${PN}-6.2.3-installation.patch"

	# Fix compatibility with Python 3.
	: > Lib/__init__.py

	# Fix version number.
	sed -e "/^ *version *=/s/6.2.4/${PV}/" -i setup.py

	sed -e "/^#include/s:/Python[23]/:/:" -i CXX/*/*.hxx || die "sed failed"
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r Doc/
	fi

	if use examples; then
		docinto examples/python-2
		dodoc Demo/Python2/*
		docinto examples/python-3
		dodoc Demo/Python3/*
	fi
}
