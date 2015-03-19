# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
# DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Fabric"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Fabric is a simple, Pythonic tool for remote execution and deployment."
HOMEPAGE="http://fabfile.org/ https://github.com/fabric/fabric https://pypi.python.org/pypi/Fabric"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
# IUSE="doc"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-python/paramiko-1.10.0")
	$(python_abi_depend dev-python/pycrypto)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}"
#	doc? ( $(python_abi_depend dev-python/sphinx) )
#	test? ( $(python_abi_depend dev-python/fudge) )

# Tests broken.
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="fabfile fabric"

src_compile() {
	distutils_src_compile

#	if use doc; then
#		einfo "Generation of documentation"
#		pushd docs > /dev/null
#		emake html
#		popd > /dev/null
#	fi
}

src_test() {
	distutils_src_test --with-doctest
}

src_install() {
	distutils_src_install

#	if use doc; then
#		dohtml -r docs/_build/html/
#	fi
}
