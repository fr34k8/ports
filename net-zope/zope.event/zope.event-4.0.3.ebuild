# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Very basic event publishing system"
HOMEPAGE="https://pypi.python.org/pypi/zope.event"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

DOCS="CHANGES.rst README.rst"
PYTHON_MODULES="${PN/.//}"

src_prepare() {
	distutils_src_prepare
	rm -r docs/_build

	# Fix generation of documentation with zope.event not installed.
	sed \
		-e "/^rqmt = pkg_resources.require('zope.event')\[0\]$/d" \
		-e "s/^version = '%s.%s' % tuple(map(int, rqmt.version.split('.')\[:2\]))$/version = '%s.%s' % tuple('${PV}'.split('.')[:2])/" \
		-e "s/^release = rqmt.version$/release = '${PV}'/" \
		-i docs/conf.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
