# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="a portable GNU which replacement implemented in Python"
HOMEPAGE="http://code.google.com/p/which/ https://pypi.python.org/pypi/which"
SRC_URI="http://${PN}.googlecode.com/files/${P}.zip -> python-${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
PYTHON_MODULES="which.py"

src_prepare() {
	distutils_src_prepare

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs which.py
		fi
	}
	python_execute_function -s preparation
}
