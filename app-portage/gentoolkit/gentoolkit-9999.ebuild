# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"
PYTHON_NONVERSIONED_EXECUTABLES=(".*")

inherit distutils git-r3

EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/gentoolkit.git"
EGIT_BRANCH="gentoolkit"

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS=""

# DEPEND="$(python_abi_depend sys-apps/portage)"
DEPEND="sys-apps/portage"
RDEPEND="${DEPEND}
	!<=app-portage/gentoolkit-dev-0.2.7
	|| ( >=sys-apps/coreutils-8.15 sys-freebsd/freebsd-bin )
	sys-apps/gawk
	!prefix? ( sys-apps/gentoo-functions )
	sys-apps/grep
	$(python_abi_depend virtual/python-argparse)"

distutils_src_compile_pre_hook() {
	python_execute VERSION="9999-${EGIT_VERSION}" "$(PYTHON)" setup.py set_version || die "setup.py set_version failed"
}

src_install() {
	python_convert_shebangs -r "" build-*/scripts-*
	distutils_src_install

	# Create cache directory for revdep-rebuild
	keepdir /var/cache/revdep-rebuild
	use prefix || fowners root:0 /var/cache/revdep-rebuild
	fperms 0700 /var/cache/revdep-rebuild

	# remove on Gentoo Prefix platforms where it's broken anyway
	if use prefix; then
		elog "The revdep-rebuild command is removed, the preserve-libs"
		elog "feature of portage will handle issues."
		rm "${ED}"/usr/bin/revdep-rebuild*
		rm "${ED}"/usr/share/man/man1/revdep-rebuild.1
		rm -rf "${ED}"/etc/revdep-rebuild
		rm -rf "${ED}"/var
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	# Only show the elog information on a new install
	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog
		elog "For further information on gentoolkit, please read the gentoolkit"
		elog "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
		elog
		elog "Another alternative to equery is app-portage/portage-utils"
		elog
		elog "Additional tools that may be of interest:"
		elog
		elog "    app-admin/eclean-kernel"
		elog "    app-portage/diffmask"
		elog "    app-portage/flaggie"
		elog "    app-portage/install-mask"
		elog "    app-portage/portpeek"
		elog "    app-portage/smart-live-rebuild"
	fi
}
