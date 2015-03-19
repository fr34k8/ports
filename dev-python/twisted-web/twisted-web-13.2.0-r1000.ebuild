# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
MY_PACKAGE="Web"

inherit twisted versionator

DESCRIPTION="Twisted web server, programmable in Python"

KEYWORDS="*"
IUSE="soap"

DEPEND="$(python_abi_depend "=dev-python/twisted-core-$(get_version_component_range 1-2)*")
	soap? ( $(python_abi_depend dev-python/soappy) )"
RDEPEND="${DEPEND}"

PYTHON_MODULES="twisted/plugins twisted/web"

src_prepare() {
	distutils_src_prepare

	if [[ "${EUID}" -eq 0 ]]; then
		# Disable tests failing with root permissions.
		sed -e "s/test_forbiddenResource/_&/" -i twisted/web/test/test_static.py
		sed -e "s/testDownloadPageError3/_&/" -i twisted/web/test/test_webclient.py
	fi
}
