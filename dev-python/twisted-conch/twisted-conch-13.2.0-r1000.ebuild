# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
MY_PACKAGE="Conch"

inherit twisted versionator

DESCRIPTION="Twisted SSHv2 implementation"

KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend "=dev-python/twisted-core-$(get_version_component_range 1-2)*")
	$(python_abi_depend dev-python/pyasn1)
	$(python_abi_depend dev-python/pycrypto)"
RDEPEND="${DEPEND}"

PYTHON_MODULES="twisted/conch twisted/plugins"

src_prepare() {
	distutils_src_prepare

	if [[ "${EUID}" -eq 0 ]]; then
		# Disable tests failing with root permissions.
		sed -e "s/test_checkKeyAsRoot/_&/" -i twisted/conch/test/test_checkers.py
		sed -e "s/test_getPrivateKeysAsRoot/_&/" -i twisted/conch/test/test_openssh_compat.py
	fi
}
