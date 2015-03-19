# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GNOME_ORG_MODULE="glib"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"

inherit distutils eutils gnome.org

DESCRIPTION="GDBus code and documentation generator"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

# To prevent circular dependencies with glib[test]
PDEPEND=">=dev-libs/glib-${PV}:2"

S="${WORKDIR}/glib-${PV}/gio/gdbus-2.0/codegen"

PYTHON_MODULES="gdbus_codegen"

src_prepare() {
	epatch "${FILESDIR}/${PN}-2.40.0-sitedir.patch"
	sed -e "s:\"/usr/local\":\"${EPREFIX}/usr\":" \
		-i config.py || die "sed config.py failed"

	sed -e "s:^#!@PYTHON@:#!${EPREFIX}/usr/bin/python:" gdbus-codegen.in > gdbus-codegen || die "sed gdbus-codegen failed"
	cp "${FILESDIR}/setup.py-2.32.4" setup.py || die "cp failed"
	sed -e "s/@PV@/${PV}/" -i setup.py || die "sed setup.py failed"
}

src_test() {
	einfo "Skipping tests. This package is tested by dev-libs/glib"
	einfo "when merged with FEATURES=test"
}

src_install() {
	distutils_src_install
	doman "${WORKDIR}/glib-${PV}/docs/reference/gio/gdbus-codegen.1"
}
