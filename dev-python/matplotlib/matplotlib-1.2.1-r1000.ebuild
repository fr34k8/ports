# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[tk?]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils eutils

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
IUSE="cairo doc examples excel fltk gtk gtk3 latex qt4 test tk wxwidgets"

RDEPEND="$(python_abi_depend dev-python/numpy)
	$(python_abi_depend dev-python/pyparsing)
	$(python_abi_depend dev-python/python-dateutil)
	$(python_abi_depend dev-python/pytz)
	$(python_abi_depend -i "3.*" dev-python/six)
	media-libs/freetype:2=
	media-libs/libpng:0=
	cairo? ( $(python_abi_depend dev-python/pycairo) )
	excel? ( $(python_abi_depend -i "2.*" dev-python/xlwt) )
	fltk? ( $(python_abi_depend -i "2.*" dev-python/pyfltk) )
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
	wxwidgets? ( $(python_abi_depend -i "2.*" dev-python/wxpython:2.8) )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		app-text/dvipng
		dev-python/imaging[python_abis_2.7]
		dev-python/ipython[python_abis_2.7]
		dev-python/sphinx[python_abis_2.7]
		dev-python/xlwt[python_abis_2.7]
		dev-texlive/texlive-fontsrecommended
		dev-texlive/texlive-latexextra
		dev-texlive/texlive-latexrecommended
		media-gfx/graphviz[cairo]
	)
	test? ( $(python_abi_depend dev-python/nose) )"

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
		[provide_packages]
		pytz = False
		dateutil = False
		six = False
		[gui_support]
		$(use_setup gtk)
		$(use_setup gtk gtkagg)
		$(use_setup tk tkagg)
	EOF

	# Avoid checks needing a X display.
	sed \
		-e "s/check_for_gtk()/$(use gtk && echo True || echo False)/" \
		-e "s/check_for_tk()/$(use tk && echo True || echo False)/" \
		-i setup.py || die "sed failed"

	# Disable building of extension modules incompatible with Python 3.
	sed \
		-e "s/config.getboolean(\"gui_support\", \"gtk\")/& and sys.version_info[0] < 3/" \
		-e "s/config.getboolean(\"gui_support\", \"gtkagg\")/& and sys.version_info[0] < 3/" \
		-i setupext.py

	# Use system pyparsing.
	rm -f lib/matplotlib/pyparsing_py{2,3}.py || die "Deletion of internal copy of pyparsing failed"
	sed -e "s/matplotlib.pyparsing_py[23]/pyparsing/g" -i lib/matplotlib/{mathtext,fontconfig_pattern}.py || die "sed failed"
}

src_compile() {
	unset DISPLAY

	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		# python_execute PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" VARTEXFONTS="${T}/fonts" "$(PYTHON -f)" make.py --small all || die "Generation of documentation failed"
		python_execute EPYTHON="$(PYTHON 2.7)" PYTHONPATH="$(ls -d ../build-2.7/lib*)" VARTEXFONTS="${T}/fonts" "$(PYTHON 2.7)" make.py --small all || die "Generation of documentation failed"
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
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/matplotlib/tests"
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
