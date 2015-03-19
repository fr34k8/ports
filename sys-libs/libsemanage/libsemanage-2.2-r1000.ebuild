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

SEPOL_VER="2.2"
SELNX_VER="2.2.2-r1"

DESCRIPTION="SELinux kernel and policy management library"
HOMEPAGE="http://userspace.selinuxproject.org/"
SRC_URI="https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases/20131030/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="python ruby static-libs"
RESTRICT="test"

RDEPEND=">=sys-libs/libsepol-${SEPOL_VER}[${MULTILIB_USEDEP}]
	>=sys-libs/libselinux-${SELNX_VER}[${MULTILIB_USEDEP}]
	app-arch/bzip2[${MULTILIB_USEDEP}]
	dev-libs/ustr[${MULTILIB_USEDEP}]
	sys-process/audit[${MULTILIB_USEDEP}]
	ruby? ( $(ruby_implementations_depend) )"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
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
	echo "# Set this to true to save the linked policy." >> "${S}/src/semanage.conf"
	echo "# This is normally only useful for analysis" >> "${S}/src/semanage.conf"
	echo "# or debugging of policy." >> "${S}/src/semanage.conf"
	echo "save-linked=false" >> "${S}/src/semanage.conf"
	echo >> "${S}/src/semanage.conf"
	echo "# Set this to 0 to disable assertion checking." >> "${S}/src/semanage.conf"
	echo "# This should speed up building the kernel policy" >> "${S}/src/semanage.conf"
	echo "# from policy modules, but may leave you open to" >> "${S}/src/semanage.conf"
	echo "# dangerous rules which assertion checking" >> "${S}/src/semanage.conf"
	echo "# would catch." >> "${S}/src/semanage.conf"
	echo "expand-check=1" >> "${S}/src/semanage.conf"
	echo >> "${S}/src/semanage.conf"
	echo "# Modules in the module store can be compressed" >> "${S}/src/semanage.conf"
	echo "# with bzip2.  Set this to the bzip2 blocksize" >> "${S}/src/semanage.conf"
	echo "# 1-9 when compressing.  The higher the number," >> "${S}/src/semanage.conf"
	echo "# the more memory is traded off for disk space." >> "${S}/src/semanage.conf"
	echo "# Set to 0 to disable bzip2 compression." >> "${S}/src/semanage.conf"
	echo "bzip-blocksize=0" >> "${S}/src/semanage.conf"
	echo >> "${S}/src/semanage.conf"
	echo "# Reduce memory usage for bzip2 compression and" >> "${S}/src/semanage.conf"
	echo "# decompression of modules in the module store." >> "${S}/src/semanage.conf"
	echo "bzip-small=true" >> "${S}/src/semanage.conf"

	# Fix libsemanage.so symlink.
	sed -e 's:cd $(LIBDIR) && ln -sf $(LIBSO) $(TARGET):cd $(LIBDIR) \&\& ln -sf ../../`basename $(SHLIBDIR)`/$(LIBSO) $(TARGET):' -i src/Makefile

	sed -e "/^gcc/s:-aux-info:-I../include &:" -i src/exception.sh

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
	if use python; then
		python_mod_optimize semanage.py
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup semanage.py
	fi
}
