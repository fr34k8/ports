# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="apipkg: namespace control and lazy-import mechanism"
HOMEPAGE="https://bitbucket.org/hpk42/apipkg https://pypi.python.org/pypi/apipkg"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="CHANGELOG README.txt"
PYTHON_MODULES="apipkg.py"

src_prepare() {
	distutils_src_prepare

	# Require not hgdistver.
	sed \
		-e "s/get_version_from_scm=True/version='${PV}'/" \
		-e "/setup_requires=\[/,/\]/d" \
		-i setup.py
}
