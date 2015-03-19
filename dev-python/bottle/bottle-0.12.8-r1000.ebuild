# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Fast and simple WSGI-framework for small web-applications."
HOMEPAGE="http://bottlepy.org/ https://github.com/defnull/bottle https://pypi.python.org/pypi/bottle"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_MODULES="bottle.py"

src_prepare() {
	distutils_src_prepare
	sed -e "/^sys.path.insert/d" -i test/{servertest.py,testall.py}
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/testall.py fast
	}
	python_execute_function testing
}
