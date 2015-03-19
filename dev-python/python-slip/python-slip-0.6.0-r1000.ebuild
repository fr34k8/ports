# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils eutils

DESCRIPTION="Miscellaneous convenience, extension and workaround code for Python"
HOMEPAGE="https://fedorahosted.org/python-slip/"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="dbus gtk selinux"

DEPEND="dbus? (
		$(python_abi_depend dev-python/dbus-python)
		$(python_abi_depend dev-python/decorator)
		|| (
			$(python_abi_depend dev-python/pygobject:3)
			$(python_abi_depend dev-python/pygobject:2)
		)
		$(python_abi_depend dev-python/six)
		sys-auth/polkit
	)
	gtk? ( $(python_abi_depend -i "2.*" dev-python/pygtk:2) )
	selinux? ( $(python_abi_depend sys-libs/libselinux[python]) )"
RDEPEND="${DEPEND}"

PYTHON_MODULES="slip"

src_prepare() {
	use selinux || epatch "${FILESDIR}/${PN}-0.2.24-disable_selinux.patch"
	sed -e "s:@VERSION@:${PV}:" setup.py.in > setup.py || die "sed failed"

	# Fix compatibility with Python 2.6.
	sed -e "s/sys.version_info.major/sys.version_info[0]/" -i setup.py

	if ! use dbus; then
		sed -e '/^setup(name="slip.dbus"/,/)$/d' -i setup.py || die "sed failed"
	fi
	if ! use gtk; then
		sed -e '/^if sys.version_info\[0\] == 2:/,/)$/d' -i setup.py || die "sed failed"
	fi

	distutils_src_prepare
}
