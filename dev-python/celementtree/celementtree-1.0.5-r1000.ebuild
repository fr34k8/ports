# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils eutils

MY_P="cElementTree-${PV}-20051216"

DESCRIPTION="The cElementTree module is a C implementation of the ElementTree API"
HOMEPAGE="http://effbot.org/zone/celementtree.htm https://pypi.python.org/pypi/cElementTree"
SRC_URI="http://effbot.org/downloads/${MY_P}.tar.gz"

LICENSE="ElementTree"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

RDEPEND="dev-libs/expat
	$(python_abi_depend ">=dev-python/elementtree-1.2")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-use_system_expat.patch"
	epatch "${FILESDIR}/${P}-setuptools.patch"
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" selftest.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins samples/* selftest.py
	fi
}
