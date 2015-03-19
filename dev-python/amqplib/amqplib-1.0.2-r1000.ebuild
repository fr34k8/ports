# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils eutils

DESCRIPTION="Python client for the Advanced Message Queuing Procotol (AMQP)"
HOMEPAGE="http://code.google.com/p/py-amqplib/ https://pypi.python.org/pypi/amqplib"
SRC_URI="http://py-amqplib.googlecode.com/files/${P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="examples extras"

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="CHANGES README TODO"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.6.1_disable_socket_tests.patch"

	distutils_src_prepare

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs tests
		fi
	}
	python_execute_function -s preparation
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build/lib" "$(PYTHON)" tests/client_0_8/run_all.py
	}
	python_execute_function -s testing
}

src_install() {
	distutils_src_install

	dodoc docs/*
	if use examples; then
		docinto examples
		dodoc demo/*
	fi
	if use extras; then
		insinto /usr/share/doc/${PF}
		doins -r extras
	fi
}
