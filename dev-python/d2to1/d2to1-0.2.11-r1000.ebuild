# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Allows using distutils2-like setup.cfg files for a package's metadata with a distribute/setuptools setup.py"
HOMEPAGE="https://pypi.python.org/pypi/d2to1"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)"
RDEPEND="${DEPEND}"

DOCS="CHANGES.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Use system version of dev-python/six.
	sed \
		-e "s/from .* import six/import six/" \
		-e "s/from .*\.six import/from six import/" \
		-i d2to1/*.py d2to1/tests/*.py
	rm -f d2to1/extern/six.py
}
