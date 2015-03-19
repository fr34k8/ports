# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Database schema migration for SQLAlchemy"
HOMEPAGE="https://github.com/stackforge/sqlalchemy-migrate https://pypi.python.org/pypi/sqlalchemy-migrate"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend dev-python/decorator)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend ">=dev-python/sqlalchemy-0.7.8")
	$(python_abi_depend dev-python/tempita)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/pbr)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

DOCS="AUTHORS ChangeLog README.rst"
PYTHON_MODULES="migrate"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc/source > /dev/null
		PYTHONPATH="../../build-$(PYTHON -f --ABI)/lib" emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/source/_build/html/
	fi
}
