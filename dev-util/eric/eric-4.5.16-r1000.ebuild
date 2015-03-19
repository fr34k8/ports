# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit eutils python

MY_PN="${PN}${PV%%.*}"
MY_PV="${PV/_pre/-snapshot-}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A full featured Python IDE using PyQt4 and QScintilla"
HOMEPAGE="http://eric-ide.python-projects.org/"
BASE_URI="mirror://sourceforge/eric-ide/${MY_PN}/stable/${PV}"
SRC_URI="${BASE_URI}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="*"
IUSE="kde spell"

DEPEND="$(python_abi_depend ">=dev-python/sip-4.12.4")
	$(python_abi_depend ">=dev-python/PyQt4-4.6[X,help,sql,svg,webkit]")
	$(python_abi_depend ">=dev-python/qscintilla-python-2.3")
	kde? ( $(python_abi_depend kde-base/pykde4) )"
RDEPEND="${DEPEND}
	$(python_abi_depend ">=dev-python/chardet-2.0.1")
	$(python_abi_depend dev-python/coverage)
	$(python_abi_depend ">=dev-python/pygments-1.1")"
PDEPEND="spell? ( $(python_abi_depend dev-python/pyenchant) )"

LANGS="cs de en es fr it ru tr zh_CN"
for L in ${LANGS}; do
	SRC_URI+=" linguas_${L}? ( ${BASE_URI}/${MY_PN}-i18n-${L/zh_CN/zh_CN.GB2312}-${MY_PV}.tar.gz )"
	IUSE+=" linguas_${L}"
done
unset L

S="${WORKDIR}/${MY_P}"

PYTHON_VERSIONED_EXECUTABLES=("/usr/bin/.*")

src_prepare() {
	epatch "${FILESDIR}/eric-4.5.9-delete_pyxml_check.patch"
	epatch "${FILESDIR}/eric-4.5.0-remove_coverage.patch"
	use kde || epatch "${FILESDIR}/eric-4.4-no-pykde.patch"

	# Delete internal copies of dev-python/chardet, dev-python/coverage, dev-python/pygments and dev-python/simplejson.
	rm -fr eric/ThirdParty
	rm -fr eric/DebugClients/Python{,3}/coverage
}

src_install() {
	installation() {
		python_execute "$(PYTHON)" install.py \
			-z \
			-b "${EPREFIX}/usr/bin" \
			-i "${T}/images/${PYTHON_ABI}" \
			-d "${EPREFIX}$(python_get_sitedir)" \
			-c
	}
	python_execute_function installation
	python_merge_intermediate_installation_images "${T}/images"

	doicon eric/icons/default/eric.png
	make_desktop_entry "${MY_PN} --nosplash" ${MY_PN} eric "Development;IDE;Qt"
}

pkg_postinst() {
	python_mod_optimize ${MY_PN}{,config.py,plugins}

	elog
	elog "The following packages will give Eric extended functionality:"
	elog "  dev-python/pylint"
	elog "  dev-python/pysvn"
	elog
	elog "This version has a plugin interface with plugin-autofetch from"
	elog "the application itself. You may want to check those as well."
	elog
}

pkg_postrm() {
	python_mod_cleanup ${MY_PN}{,config.py,plugins}
}
