# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit autotools eutils java-pkg-opt-2 python

DESCRIPTION="SELinux policy tools"
HOMEPAGE="http://www.tresys.com/selinux/selinux_policy_tools.shtml"
SRC_URI="http://oss.tresys.com/projects/setools/chrome/site/dists/${P}/${P}.tar.bz2
	http://dev.gentoo.org/~swift/patches/setools/${P}-01-fedora-patches.tar.gz
	http://dev.gentoo.org/~swift/patches/setools/${P}-02-gentoo-patches.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="X debug java python"

DEPEND=">=sys-libs/libsepol-2.1.4
	sys-libs/libselinux
	sys-devel/bison
	sys-devel/flex
	>=dev-db/sqlite-3.2:3
	dev-libs/libxml2:2
	virtual/pkgconfig
	java? (
		dev-lang/swig:1
		>=virtual/jdk-1.4
	)
	python? ( dev-lang/swig:1 )
	X? (
		>=dev-lang/tk-8.4.9
		>=gnome-base/libglade-2.0
		>=x11-libs/gtk+-2.8:2
	)"

RDEPEND=">=sys-libs/libsepol-2.1.4
	sys-libs/libselinux
	>=dev-db/sqlite-3.2:3
	dev-libs/libxml2:2
	java? ( >=virtual/jre-1.4 )
	X? (
		>=dev-lang/tk-8.4.9
		>=dev-tcltk/bwidget-1.8
		>=gnome-base/libglade-2.0
		>=x11-libs/gtk+-2.8:2
	)"

RESTRICT="test"

pkg_setup() {
	if use java; then
		java-pkg-opt-2_pkg_setup
	fi

	if use python; then
		python_pkg_setup
		PYTHON_DIRS="libapol/swig/python libpoldiff/swig/python libqpol/swig/python libseaudit/swig/python libsefs/swig/python python"
	fi
}

src_prepare() {
	EPATCH_MULTI_MSG="Applying various (Fedora-provided) setools fixes... " \
	EPATCH_SUFFIX="patch" \
	EPATCH_SOURCE="${WORKDIR}" \
	EPATCH_FORCE="yes" \
	epatch

	EPATCH_MULTI_MSG="Applying various (Gentoo) setool fixes... " \
	EPATCH_SUFFIX="patch" \
	EPATCH_SOURCE="${WORKDIR}/gentoo-patches" \
	EPATCH_FORCE="yes" \
	epatch

	# Disable broken check for SWIG version.
	sed -e "s/AC_PROG_SWIG(2.0.0)/AC_PROG_SWIG/" -i configure.ac || die "sed failed"
	# Use SWIG 1.3.
	sed -e 's/AC_PATH_PROG(\[SWIG\],\[swig\])/AC_PATH_PROG([SWIG],[swig1.3])/' -i m4/ac_pkg_swig.m4 || die "sed failed"
	# Fix build failure due to double __init__.py installation.
	sed -e "s/^wrappedpy_DATA = qpol.py \$(pkgpython_PYTHON)/wrappedpy_DATA = qpol.py/" -i libqpol/swig/python/Makefile.am || die "sed failed"

	# Support Python 2.6.
	sed -e "/AM_PATH_PYTHON(2.7)/s/2.7/2.6/" -i configure.ac
	# Fix calculation of PYTHON_LDFLAGS and PYTHON_EXTRA_LIBS.
	sed \
		-e "/print('-L' + get_python_lib(1,1), \\\\/s/, / + ' ' + /" \
		-e "/if test \"\$py_version\" == \"2.7\"; then/,/fi/d" \
		-e "/print(conf('LOCALMODLIBS'), conf('LIBS'))/s/, / + ' ' + /" \
		-i m4/ac_python_devel.m4

	local dir
	for dir in ${PYTHON_DIRS}; do
		# Python bindings are built/installed manually.
		sed -e "s/MAYBE_PYSWIG = python/MAYBE_PYSWIG =/" -i ${dir%python}Makefile.am || die "sed failed"
		# Make PYTHON_LDFLAGS replaceable during running `make`.
		sed -e "/^AM_LDFLAGS =/s/@PYTHON_LDFLAGS@/\$(PYTHON_LDFLAGS)/" -i ${dir}/Makefile.am || die "sed failed"
	done

	sed -e "s/mkdir_p/MKDIR_P/" -i **/Makefile.am || die "sed failed"

	eautoreconf

	python_clean_py-compile_files

	epatch_user
}

src_configure() {
	econf \
		--with-java-prefix=${JAVA_HOME} \
		--disable-selinux-check \
		--disable-bwidget-check \
		$(use_enable python swig-python) \
		$(use_enable java swig-java) \
		$(use_enable X swig-tcl) \
		$(use_enable X gui) \
		$(use_enable debug)
}

src_compile() {
	emake LD="$(tc-getLD).bfd"

	if use python; then
		local dir
		for dir in ${PYTHON_DIRS}; do
			python_copy_sources ${dir}
			building() {
				emake \
					LD="$(tc-getLD).bfd" \
					SWIG_PYTHON_CPPFLAGS="-I$(python_get_includedir)" \
					PYTHON_LDFLAGS="$(python_get_library -l)" \
					pyexecdir="$(python_get_sitedir)" \
					pythondir="$(python_get_sitedir)"
			}
			python_execute_function \
				--action-message "Building of Python bindings from ${dir} directory with \$(python_get_implementation_and_version)" \
				--failure-message "Building of Python bindings from ${dir} directory with \$(python_get_implementation_and_version) failed" \
				-s --source-dir ${dir} \
				building
		done
	fi
}

src_install() {
	emake DESTDIR="${D}" install

	if use python; then
		local dir
		for dir in ${PYTHON_DIRS}; do
			installation() {
				emake \
					DESTDIR="${D}" \
					pyexecdir="$(python_get_sitedir)" \
					pythondir="$(python_get_sitedir)" \
					install
			}
			python_execute_function \
				--action-message "Installation of Python bindings from ${dir} directory with \$(python_get_implementation_and_version)" \
				--failure-message "Installation of Python bindings from ${dir} directory with \$(python_get_implementation_and_version) failed" \
				-s --source-dir ${dir} \
				installation
		done
	fi
}

pkg_postinst() {
	if use python; then
		python_mod_optimize setools
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup setools
	fi
}
