# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"

inherit distutils eutils

MY_PN="${PN}2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="PostgreSQL database adapter for Python"
HOMEPAGE="http://initd.org/psycopg/ https://pypi.python.org/pypi/psycopg2"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="LGPL-3+"
SLOT="2"
KEYWORDS="*"
IUSE="debug doc examples mxdatetime"

DEPEND=">=dev-db/postgresql-8.1
	mxdatetime? ( $(python_abi_depend -e "3.* *-pypy" dev-python/egenix-mx-base) )"
RDEPEND="${DEPEND}"
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="AUTHORS NEWS README doc/HACKING doc/psycopg2.txt"
PYTHON_MODULES="${PN}2"

src_prepare() {
	epatch "${FILESDIR}/${PN}-2.4.2-setup.py.patch"

	if use debug; then
		sed -i "s/^\(define=\)/\1PSYCOPG_DEBUG,/" setup.cfg || die "sed failed"
	fi

	if use mxdatetime; then
		sed -i "s/\(use_pydatetime=\)1/\10/" setup.cfg || die "sed failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dodoc doc/psycopg2.txt
		dohtml -r doc/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
