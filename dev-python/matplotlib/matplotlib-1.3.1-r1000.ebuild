# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[tk?]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
# https://github.com/matplotlib/matplotlib/issues/2343
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"
PYTHON_NAMESPACES="mpl_toolkits"

inherit distutils python-namespaces virtualx

DESCRIPTION="Python plotting package"
HOMEPAGE="http://matplotlib.org/ https://github.com/matplotlib/matplotlib https://pypi.python.org/pypi/matplotlib"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

# Main license: matplotlib
# Some modules: BSD
# matplotlib/backends/qt4_editor: MIT
# Fonts: BitstreamVera, OFL-1.1
LICENSE="BitstreamVera BSD matplotlib MIT OFL-1.1"
SLOT="0"
KEYWORDS="*"
IUSE="cairo doc examples excel gtk gtk3 latex qt4 test tk webagg wxwidgets"

RDEPEND="$(python_abi_depend dev-python/imaging)
	$(python_abi_depend dev-python/numpy)
	$(python_abi_depend dev-python/pyparsing)
	$(python_abi_depend dev-python/python-dateutil)
	$(python_abi_depend dev-python/pytz)
	$(python_abi_depend -i "3.*" dev-python/six)
	media-libs/freetype:2=
	media-libs/libpng:0=
	cairo? ( $(python_abi_depend dev-python/pycairo) )
	excel? ( $(python_abi_depend -i "2.*" dev-python/xlwt) )
	gtk? ( $(python_abi_depend -i "2.*" dev-python/pygtk) )
	gtk3? (
		dev-libs/gobject-introspection
		$(python_abi_depend dev-python/pygobject:3)
		x11-libs/gtk+:3[introspection]
	)
	latex? (
		app-text/dvipng
		app-text/ghostscript-gpl
		app-text/poppler[utils]
		dev-texlive/texlive-fontsrecommended
		virtual/latex-base
	)
	qt4? ( $(python_abi_depend virtual/python-qt[X] ) )
	webagg? ( $(python_abi_depend -e "3.1" www-servers/tornado) )
	wxwidgets? ( $(python_abi_depend -i "2.*" dev-python/wxpython) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/pycxx)
	$(python_abi_depend dev-python/setuptools)
	virtual/pkgconfig
	doc? (
		app-text/dvipng
		$(python_abi_depend -e "3.1" dev-python/ipython)
		$(python_abi_depend -e "3.1" dev-python/numpydoc)
		$(python_abi_depend -e "3.1" dev-python/sphinx)
		dev-texlive/texlive-fontsrecommended
		dev-texlive/texlive-latexextra
		dev-texlive/texlive-latexrecommended
		media-gfx/graphviz[cairo]
	)
	test? ( $(python_abi_depend dev-python/nose) )"

S="${WORKDIR}/${P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")
PYTHON_CXXFLAGS=("2.* + -fno-strict-aliasing")

PYTHON_MODULES="matplotlib mpl_toolkits pylab.py"

use_setup() {
	local option="${2:-${1}}"
	if use ${1}; then
		echo "${option} = True"
	else
		echo "${option} = False"
	fi
}

src_prepare() {
	distutils_src_prepare

	# Create setup.cfg. (See setup.cfg.template and setupext.py for any changes.)
	cat > setup.cfg <<-EOF
		[directories]
		basedirlist = ${EPREFIX}/usr
		[gui_support]
		$(use_setup gtk)
		$(use_setup gtk gtkagg)
		$(use_setup tk tkagg)
	EOF

	# Use system PyCXX.
	sed -e "771s/if sys.version_info\[0\] >= 3:/if False:/" -i setupext.py
	rm -r CXX

	# Disable building of extension modules incompatible with Python 3.
	sed -e "/raise CheckFailed(\"Requires pygtk\")/i\\\\            if sys.version_info[0] >= 3: self.optional = True" -i setupext.py

	# Fix generation of documentation.
	sed -e "s/if sphinx.__version__ >= 1.1:/if sphinx.__version__ >= '1.1':/" -i doc/conf.py
	if [[ "$(python_get_version -f -l --major)" == "3" ]]; then
		2to3-$(PYTHON -f --ABI) -f unicode -nw --no-diffs doc/sphinxext/gen_rst.py
	fi
}

src_compile() {
	unset DISPLAY

	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		if [[ "$(python_get_version -f -l)" == "3.1" ]]; then
			die "Generation of documentation not supported with Python 3.1"
		fi
		pushd doc > /dev/null
		python_execute PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" VARTEXFONTS="${T}/fonts" "$(PYTHON -f)" make.py --small all || die "Generation of documentation failed"
		[[ -e build/latex/Matplotlib.pdf ]] || die "Generation of documentation failed"
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --root="${T}/tests-${PYTHON_ABI}" --no-compile || die "Installation for tests failed with $(python_get_implementation_and_version)"
		pushd "${T}/tests-${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)" > /dev/null || die
		python_execute "$(PYTHON)" -c "import matplotlib, sys; sys.exit(not matplotlib.test(verbosity=${PYTHON_TEST_VERBOSITY}))" || return
		popd > /dev/null || die
	}
	VIRTUALX_COMMAND="python_execute_function" virtualmake testing
}

src_install() {
	distutils_src_install
	python-namespaces_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/matplotlib/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r doc/build/html/
		dodoc doc/build/latex/Matplotlib.pdf
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	python-namespaces_pkg_postinst
}

pkg_postrm() {
	distutils_pkg_postrm
	python-namespaces_pkg_postrm
}
