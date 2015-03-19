# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Module for manipulating ID3 (v1 + v2) tags in Python"
HOMEPAGE="http://eyed3.nicfit.net/"
SRC_URI="http://eyed3.nicfit.net/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_configure() {
	python_execute_function -d -f -q
}

src_install() {
	dohtml *.html
	rm -f *.html

	distutils_src_install

	install_script() {
		mkdir -p "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/bin"
		cp bin/eyeD3 "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/bin/eyeD3-0.6"
	}
	python_execute_function -q install_script
	python_merge_intermediate_installation_images "${T}/images"

	doman doc/*.1
}
