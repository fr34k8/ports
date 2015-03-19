# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 3.2 *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="Flask-SQLAlchemy"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SQLAlchemy support for Flask applications"
HOMEPAGE="https://pypi.python.org/pypi/Flask-SQLAlchemy"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-python/flask-0.10")
	$(python_abi_depend dev-python/sqlalchemy)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="flask_sqlalchemy"

src_prepare() {
	distutils_src_prepare

	# https://github.com/mitsuhiko/flask-sqlalchemy/issues/160
	sed -e "s/self.assertTrue(isinstance(changes, list))/self.assertTrue(isinstance(changes, type({}.values())))/" -i test_sqlalchemy.py
}
