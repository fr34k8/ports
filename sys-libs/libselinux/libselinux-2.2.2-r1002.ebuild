# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
RUBY_OPTIONAL="yes"
USE_RUBY="ruby19 ruby20 ruby21"

inherit eutils multilib multilib-minimal python ruby-ng toolchain-funcs

MY_P="${P//_/-}"

PATCHBUNDLE="r5"
SEPOL_VER="2.2"

DESCRIPTION="SELinux userland library"
HOMEPAGE="http://userspace.selinuxproject.org/"
SRC_URI="https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases/20131030/${MY_P}.tar.gz
	http://dev.gentoo.org/~swift/patches/${PN}/patchbundle-${P}-${PATCHBUNDLE}.tar.gz"

LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="*"
IUSE="python ruby static-libs"
RESTRICT="test"

RDEPEND=">=sys-libs/libsepol-${SEPOL_VER}[${MULTILIB_USEDEP}]
	>=dev-libs/libpcre-8.33[${MULTILIB_USEDEP},static-libs?]
	ruby? ( $(ruby_implementations_depend) )"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9 )
	ruby? (
		>=dev-lang/swig-2.0.9
		virtual/pkgconfig
	)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi

	if use ruby; then
		ruby-ng_pkg_setup
	fi
}

src_unpack() {
	default
}

src_prepare() {
	EPATCH_MULTI_MSG="Applying libselinux patches ... " \
	EPATCH_SUFFIX="patch" \
	EPATCH_SOURCE="${WORKDIR}/gentoo-patches" \
	EPATCH_FORCE="yes" \
	epatch

	# Respect RUBYPREFIX.
	sed -e 's/SWIGRUBYLOBJ:= $(patsubst %.c,%.lo,$(SWIGRUBYCOUT))/SWIGRUBYLOBJ:= $(patsubst %.c,$(RUBYPREFIX)%.lo,$(SWIGRUBYCOUT))/' -i src/Makefile

	# Link libselinux.so against libpthread.so.
	sed -e "s/-ldl/& -lpthread/" -i src/Makefile

	epatch_user

	multilib_copy_sources
}

src_configure() {
	default
}

multilib_src_compile() {
	emake \
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		LIBDIR="/usr/$(get_libdir)" \
		PCRE_CFLAGS="$("$(tc-getPKG_CONFIG)" libpcre --cflags)" \
		PCRE_LIBS="$("$(tc-getPKG_CONFIG)" libpcre --libs)" \
		RANLIB="$(tc-getRANLIB)" \
		all

	if multilib_is_native_abi && use python; then
		building() {
			emake \
				CC="$(tc-getCC)" \
				LIBDIR="/usr/$(get_libdir)" \
				PYINC="-I$(python_get_includedir)" \
				PYPREFIX="python-${PYTHON_ABI}-" \
				pywrap
		}
		python_execute_function building
	fi

	if multilib_is_native_abi && use ruby; then
		each_ruby_compile() {
			cd "${BUILD_DIR}"
			emake \
				CC="$(tc-getCC)" \
				LIBDIR="/usr/$(get_libdir)" \
				RUBY="${RUBY}" \
				RUBYPREFIX="ruby-$("${RUBY}" -e 'print RUBY_VERSION.split(".")[0..1].join(".")')-" \
				rubywrap
		}
		ruby-ng_src_compile
	fi
}

src_compile() {
	multilib-minimal_src_compile
}

src_test() {
	default
}

multilib_src_install() {
	emake \
		DESTDIR="${D}" \
		LIBDIR="\$(PREFIX)/$(get_libdir)" \
		SHLIBDIR="\$(DESTDIR)/$(get_libdir)" \
		install

	if multilib_is_native_abi && use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				LIBDIR="\$(PREFIX)/$(get_libdir)" \
				PYPREFIX="python-${PYTHON_ABI}-" \
				install-pywrap
		}
		python_execute_function installation
	fi

	if multilib_is_native_abi && use ruby; then
		each_ruby_install() {
			cd "${BUILD_DIR}"
			emake \
				DESTDIR="${D}" \
				LIBDIR="\$(PREFIX)/$(get_libdir)" \
				RUBY="${RUBY}" \
				RUBYINSTALL="${D}$(ruby_rbconfig_value sitearchdir)" \
				RUBYPREFIX="ruby-$("${RUBY}" -e 'print RUBY_VERSION.split(".")[0..1].join(".")')-" \
				install-rubywrap
		}
		ruby-ng_src_install
	fi
}

multilib_src_install_all() {
	use static-libs || rm "${D}"usr/lib*/*.a
}

src_install() {
	multilib-minimal_src_install
}

pkg_postinst() {
	local expression_file policy_type
	for policy_type in ${POLICY_TYPES}; do
		mkdir -p "${EROOT}etc/selinux/${policy_type}/contexts/files"
		touch "${EROOT}etc/selinux/${policy_type}/contexts/files/file_contexts.local"

		for expression_file in file_contexts file_contexts.homedirs file_contexts.local; do
			sefcontext_compile /etc/selinux/${policy_type}/contexts/files/${expression_file}
		done
	done

	if use python; then
		python_mod_optimize selinux
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup selinux
	fi
}
