# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6 *-jython"

inherit distutils

DESCRIPTION="Python library for serializing any arbitrary object graph into JSON"
HOMEPAGE="https://jsonpickle.github.io/ https://github.com/jsonpickle/jsonpickle https://pypi.python.org/pypi/jsonpickle"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/feedparser) )"
RDEPEND=""

src_prepare() {
	distutils_src_prepare

	# Work around bug in libxml2 or feedparser.
	sed -e "s/^\([[:space:]]*\)self.doc = feedparser.parse(RSS_DOC)$/\1if 'drv_libxml2' in feedparser.PREFERRED_XML_PARSERS: feedparser.PREFERRED_XML_PARSERS.remove('drv_libxml2')\n&/" -i tests/thirdparty_tests.py
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests/runtests.py
	}
	python_execute_function testing
}
