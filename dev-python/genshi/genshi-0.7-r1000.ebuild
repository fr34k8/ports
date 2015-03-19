# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_P="Genshi-${PV}"

DESCRIPTION="A toolkit for generation of output for the web"
HOMEPAGE="http://genshi.edgewall.org/ https://pypi.python.org/pypi/Genshi"
SRC_URI="http://ftp.edgewall.com/pub/genshi/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DISTUTILS_GLOBAL_OPTIONS=(
	"2.*-cpython --with-speedups"
	"3.[12]-cpython --with-speedups"
	# http://genshi.edgewall.org/ticket/555
	"3.[3-9]-cpython --without-speedups"
)

src_install() {
	distutils_src_install
	python_clean_installation_image

	if use doc; then
		dodoc doc/*.txt
		dohtml -r doc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
