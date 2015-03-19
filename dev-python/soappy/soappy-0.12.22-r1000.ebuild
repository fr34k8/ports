# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}ssl?,{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

MY_PN="SOAPpy"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SOAP Services for Python"
HOMEPAGE="http://pywebsvcs.sourceforge.net/ https://github.com/kiorky/SOAPpy https://pypi.python.org/pypi/SOAPpy"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="examples ssl"

DEPEND="$(python_abi_depend dev-python/defusedxml)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/wstools)
	ssl? ( $(python_abi_depend -e "*-jython *-pypy-*" dev-python/m2crypto) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt docs/*"
PYTHON_MODULES="${MY_PN}"

src_prepare() {
	distutils_src_prepare
	find -name .cvsignore -delete
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r bid contrib tools validate
	fi
}
