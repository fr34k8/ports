# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils fdo-mime gnome2-utils

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=">=dev-java/java-config-wrapper-0.15
	!sys-apps/baselayout-java
	!app-admin/eselect-java"
# https://bugs.gentoo.org/show_bug.cgi?id=315229
PDEPEND=">=virtual/jre-1.5"
# Tests fail when java-config isn't already installed.
RESTRICT="test"

PYTHON_MODULES="java_config_2"

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" src/run-test-suite.py
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" src/run-test-suite2.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${ARCH}.conf jdk-defaults.conf
}

pkg_postrm() {
	distutils_pkg_postrm
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
