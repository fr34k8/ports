# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit python

DESCRIPTION="Virtual for enum Python module"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="$(python_abi_depend -i "2.* 3.1 3.2 3.3" dev-python/enum34)"
