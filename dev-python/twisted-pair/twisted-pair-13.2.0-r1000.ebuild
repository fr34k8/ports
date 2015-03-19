# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
MY_PACKAGE="Pair"

inherit twisted versionator

DESCRIPTION="Twisted Pair contains low-level networking support"

KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend "=dev-python/twisted-core-$(get_version_component_range 1-2)*")
	$(python_abi_depend dev-python/eunuchs)"
RDEPEND="${DEPEND}"

PYTHON_MODULES="twisted/pair"
