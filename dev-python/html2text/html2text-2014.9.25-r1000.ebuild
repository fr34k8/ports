# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="Turn HTML into equivalent Markdown-structured text."
HOMEPAGE="https://github.com/html2text/html2text https://pypi.python.org/pypi/html2text"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/chardet)
	$(python_abi_depend dev-python/feedparser)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"

DOCS="AUTHORS.rst ChangeLog.rst"

src_prepare() {
	distutils_src_prepare

	# Avoid file collision with app-text/html2text.
	sed -e "s/html2text=html2text:main/pyhtml2text=html2text:main/" -i setup.py

	# https://github.com/html2text/html2text/issues/18
	sed -e "s/find_packages()/find_packages(exclude=['test'])/" -i setup.py
}

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/test_html2text.py -v
	}
	python_execute_function testing
}
