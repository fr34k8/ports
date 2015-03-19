# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"
DISTUTILS_DISABLE_TEST_DEPENDENCY="1"

inherit distutils libtool multilib-minimal toolchain-funcs

MY_P="${P/_}"

DESCRIPTION="Password Checking Library"
HOMEPAGE="http://sourceforge.net/projects/cracklib/"
SRC_URI="mirror://sourceforge/cracklib/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="nls python static-libs test zlib"

RDEPEND="zlib? ( sys-libs/zlib:0=[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	python? (
		$(python_abi_depend dev-python/setuptools)
		test? ( $(python_abi_depend dev-python/nose) )
	)"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="cracklib.py"

do_python() {
	multilib_is_native_abi || return 0
	use python || return 0
	pushd python > /dev/null || die
	distutils_src_${EBUILD_PHASE}
	popd > /dev/null || die
}

pkg_setup() {
	# workaround #195017
	if has unmerge-orphans ${FEATURES} && has_version "<${CATEGORY}/${PN}-2.8.10" ; then
		eerror "Upgrade path is broken with FEATURES=unmerge-orphans"
		eerror "Please run: FEATURES=-unmerge-orphans emerge cracklib"
		die "Please run: FEATURES=-unmerge-orphans emerge cracklib"
	fi

	if use python; then
		python_pkg_setup
	fi
}

src_prepare() {
	elibtoolize #269003
	do_python
	multilib_copy_sources
}

multilib_src_configure() {
	# use /usr/lib so that the dictionary is shared between ABIs
	econf \
		--with-default-dict='/usr/lib/cracklib_dict' \
		--without-python \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		$(use_with zlib)
}

multilib_src_compile() {
	default
	do_python
}

multilib_src_test() {
	do_python
}

multilib_src_install() {
	default
	# move shared libs to /
	multilib_is_native_abi && gen_usr_ldscript -a crack

	do_python
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
	rm -r "${ED}"/usr/share/cracklib

	insinto /usr/share/dict
	doins dicts/cracklib-small

	if use python; then
		delete_tests() {
			rm "${ED}$(python_get_sitedir)/test_cracklib.py"
		}
		python_execute_function -q delete_tests
	fi
}

pkg_postinst() {
	if [[ ${ROOT} == "/" ]] ; then
		ebegin "Regenerating cracklib dictionary"
		create-cracklib-dict "${EPREFIX}"/usr/share/dict/* > /dev/null
		eend $?
	fi

	if use python; then
		distutils_pkg_postinst
	fi
}

pkg_postrm() {
	if use python; then
		distutils_pkg_postrm
	fi
}
