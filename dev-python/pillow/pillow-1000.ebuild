# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit python

DESCRIPTION="Wrapper package for dev-python/imaging"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE="X doc examples jpeg lcms tiff tk truetype webp zlib"

DEPEND=""
RDEPEND="$(python_abi_depend dev-python/imaging[${IUSE// /?,}?])"
