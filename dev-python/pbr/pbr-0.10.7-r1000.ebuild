# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Python Build Reasonableness"
HOMEPAGE="https://github.com/openstack-dev/pbr https://pypi.python.org/pypi/pbr"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"
PDEPEND="$(python_abi_depend -e "3.1" dev-python/pip)"

src_prepare() {
	distutils_src_prepare

	# Allow installation without dev-python/pip installed.
	sed -e "/^pip$/d" -i requirements.txt pbr.egg-info/requires.txt
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/pbr/tests"
	}
	python_execute_function -q delete_tests
}
