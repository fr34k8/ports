# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 2.6 3.* *-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit eutils gnome2-utils python systemd

DESCRIPTION="A firewall daemon with D-BUS interface providing a dynamic firewall"
HOMEPAGE="https://fedorahosted.org/firewalld/"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="gui"

RDEPEND="$(python_abi_depend dev-python/dbus-python)
	$(python_abi_depend dev-python/decorator)
	$(python_abi_depend dev-python/python-slip[dbus])
	$(python_abi_depend dev-python/pygobject:3)
	net-firewall/ebtables
	net-firewall/iptables[ipv6]
	|| ( sys-apps/openrc sys-apps/systemd )
	gui? (
		$(python_abi_depend dev-python/pygtk:2)
		>=x11-libs/gtk+-2.6:2
		x11-libs/gtk+:3
	)"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	>=dev-util/intltool-0.35
	sys-devel/gettext"

src_prepare() {
	epatch_user
	python_src_prepare
}

src_configure() {
	python_src_configure \
		--enable-systemd \
		"$(systemd_with_unitdir systemd-unitdir)"
}

src_install() {
	python_src_install

	# Delete useless files.
	rm -fr "${ED}etc/rc.d"
	rm -fr "${ED}etc/sysconfig"

	if ! use gui; then
		# Delete GUI-related files.
		rm -f "${ED}usr/bin/firewall-applet"*
		rm -f "${ED}usr/bin/firewall-config"*
		rm -fr "${ED}usr/share/applications"
		rm -fr "${ED}usr/share/icons"
	fi

	newinitd "${FILESDIR}/firewalld.init" firewalld
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update
	python_mod_optimize firewall
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
	python_mod_cleanup firewall
}
