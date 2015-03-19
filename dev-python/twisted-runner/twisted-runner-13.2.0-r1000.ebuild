# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
MY_PACKAGE="Runner"

inherit twisted versionator

DESCRIPTION="Twisted Runner is a process management library and inetd replacement"

KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend "=dev-python/twisted-core-$(get_version_component_range 1-2)*")"
RDEPEND="${DEPEND}"

PYTHON_MODULES="twisted/runner"

src_install() {
	twisted_src_install
	python_clean_installation_image
}
