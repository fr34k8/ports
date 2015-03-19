# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils versionator

DESCRIPTION="Python based policy daemon for Postfix SPF checking"
HOMEPAGE="https://launchpad.net/pypolicyd-spf"
SRC_URI="http://launchpad.net/pypolicyd-spf/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/authres)
	$(python_abi_depend ">=dev-python/pyspf-2.0.9")
	$(python_abi_depend virtual/python-ipaddress)"
RDEPEND="${DEPEND}"

DOCS="CHANGES policyd-spf.conf.commented README README.per_user_whitelisting"
PYTHON_MODULES="policydspfsupp.py policydspfuser.py"
