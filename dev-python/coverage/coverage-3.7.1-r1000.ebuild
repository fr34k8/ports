# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Code coverage measurement for Python"
HOMEPAGE="http://nedbatchelder.com/code/coverage/ https://bitbucket.org/ned/coveragepy https://pypi.python.org/pypi/coverage"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="AUTHORS.txt CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare

	# Disable versioning of coverage script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed \
		-e "/'coverage%d = coverage:main'/d" \
		-e "/'coverage-%d.%d = coverage:main'/d" \
		-i setup.py
}
