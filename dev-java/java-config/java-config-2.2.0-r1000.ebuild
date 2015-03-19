# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Java environment configuration query tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="http://dev.gentoo.org/~sera/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="*"
IUSE=""

# baselayout-java is added as a dep till it can be added to eclass.
RDEPEND="
	>=dev-java/java-config-wrapper-0.15
	sys-apps/baselayout-java
	sys-apps/portage"

PYTHON_MODULES="java_config_2"
