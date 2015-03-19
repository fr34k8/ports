# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.* *-jython *-pypy-*"

inherit eutils python

MY_PN="${PN}${PV%%.*}"
MY_PV="${PV/_pre/-snapshot-}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A full featured Python IDE using PyQt4 and QScintilla"
HOMEPAGE="http://eric-ide.python-projects.org/"
BASE_URI="mirror://sourceforge/eric-ide/${MY_PN}/stable/${PV}"
SRC_URI="${BASE_URI}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="5"
KEYWORDS="*"
IUSE="spell"

DEPEND="$(python_abi_depend ">=dev-python/sip-4.12.4")
	$(python_abi_depend ">=dev-python/PyQt4-4.8[X,help,sql,svg,webkit]")
	$(python_abi_depend ">=dev-python/qscintilla-python-2.6")"
RDEPEND="${DEPEND}
	$(python_abi_depend ">=dev-python/chardet-2.0.1")
	$(python_abi_depend ">=dev-python/coverage-3.2")
	$(python_abi_depend ">=dev-python/pygments-1.4")"
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
	epatch "${FILESDIR}/${PN}-5.3.6-remove_coverage.patch"

	# Avoid file collisions between different slots of Eric.
	sed -e "s/^Icon=eric$/&${SLOT}/" -i eric/${MY_PN}.desktop || die "sed failed"
	sed -e "s/\([^[:alnum:]]\)eric\.png\([^[:alnum:]]\)/\1eric5.png\2/" -i $(grep -lr eric.png .) || die "sed failed"
	mv eric/icons/default/eric{,5}.png || die "mv failed"
	mv eric/pixmaps/eric{,5}.png || die "mv failed"
	rm -f eric/APIs/Python/zope-*.api
	rm -f eric/APIs/Ruby/Ruby-*.api

	# Delete internal copies of dev-python/chardet, dev-python/coverage and dev-python/pygments.
	rm -fr eric/ThirdParty
	rm -fr eric/DebugClients/Python{,3}/coverage

	# Fix desktop files.
	sed -e "/^Categories=/s:Python:X-&:" -i eric/eric5{,_webbrowser}.desktop || die
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

	doicon eric/icons/default/${MY_PN}.png
}

pkg_postinst() {
	python_mod_optimize -x "/eric5/(DebugClients/Python|UtilitiesPython2)/" ${MY_PN}{,config.py,plugins}

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
