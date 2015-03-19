# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Python module for DNS (Domain Name Service)"
HOMEPAGE="http://pydns.sourceforge.net/ https://pypi.python.org/pypi/pydns"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="CNRI"
SLOT="2"
KEYWORDS="*"
IUSE="examples"

RDEPEND="!dev-python/pydns:0
	!dev-python/pydns:python-2"
DEPEND="${RDEPEND}
	virtual/libiconv"

PYTHON_MODULES="DNS"

src_prepare() {
	distutils_src_prepare

	# Fix encoding of comments.
	local file
	for file in DNS/{Lib,Type}.py; do
		iconv -f ISO-8859-1 -t UTF-8 < "${file}" > "${file}~" && mv -f "${file}~" "${file}" > /dev/null
	done

	# Fix Python shebangs in examples.
	python_convert_shebangs -r 2 {tests,tools}

	# Clean documentation.
	mv CREDITS.txt CREDITS
	mv README.txt README
	rm README-guido.txt
}

src_install(){
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins {tests,tools}/*.py
	fi
}
