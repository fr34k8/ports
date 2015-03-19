# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Mako"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A Python templating language"
HOMEPAGE="http://www.makotemplates.org/ https://bitbucket.org/zzzeek/mako https://pypi.python.org/pypi/Mako"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend ">=dev-python/beaker-1.1")
	$(python_abi_depend ">=dev-python/markupsafe-0.9.2")
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend virtual/python-argparse)
	$(python_abi_depend virtual/python-mock)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=""

src_prepare() {
	distutils_src_prepare

	preparation() {
		cp -r test test-${PYTHON_ABI} || return

		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs test-${PYTHON_ABI} || return
		fi
	}
	python_execute_function preparation
}

src_test() {
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -w 'test-${PYTHON_ABI}'
}

src_install() {
	distutils_src_install

	if use doc; then
		rm -r doc/build
		dohtml -r doc/
	fi
}
