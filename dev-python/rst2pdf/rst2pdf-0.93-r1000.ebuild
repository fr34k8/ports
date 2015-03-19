# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython"

inherit distutils

DESCRIPTION="Tool for transforming reStructuredText to PDF using ReportLab"
HOMEPAGE="http://rst2pdf.ralsina.com.ar/ http://code.google.com/p/rst2pdf/ https://pypi.python.org/pypi/rst2pdf"
SRC_URI="http://rst2pdf.googlecode.com/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="matplotlib pythonmagick sphinx xhtml2pdf"

DEPEND="$(python_abi_depend dev-python/docutils)
	$(python_abi_depend dev-python/imaging)
	$(python_abi_depend dev-python/pdfrw)
	$(python_abi_depend dev-python/pygments)
	$(python_abi_depend ">=dev-python/reportlab-2.4")
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/simplejson)
	$(python_abi_depend dev-python/roman)
	matplotlib? ( $(python_abi_depend -e "*-pypy-*" dev-python/matplotlib) )
	pythonmagick? ( $(python_abi_depend -e "*-pypy-*" dev-python/pythonmagick) )
	sphinx? ( $(python_abi_depend dev-python/sphinx) )
	xhtml2pdf? ( $(python_abi_depend dev-python/xhtml2pdf) )"
RDEPEND="${DEPEND}"

DOCS="Contributors.txt CHANGES.txt README.txt doc/*.pdf"

src_install() {
	distutils_src_install
	doman doc/rst2pdf.1
}
