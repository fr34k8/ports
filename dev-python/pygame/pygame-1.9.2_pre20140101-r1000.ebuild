# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_TESTS_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils virtualx
if [[ "${PV}" == *_pre* ]]; then
	inherit vcs-snapshot
fi

DESCRIPTION="Python bindings for SDL multimedia library"
HOMEPAGE="http://www.pygame.org/ https://bitbucket.org/pygame/pygame"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI="https://bitbucket.org/pygame/pygame/get/90f8019b31d294fc9264c0f3da66ceeb0e0fd154.tar.bz2 -> ${P}.tar.bz2"
else
	SRC_URI="http://www.pygame.org/ftp/pygame-${PV}release.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples X"

RDEPEND="$(python_abi_depend dev-python/numpy)
	media-libs/freetype:2=
	media-libs/libpng:0=
	media-libs/sdl-image:0=[png,jpeg]
	media-libs/sdl-mixer:0=
	media-libs/sdl-ttf:0=
	media-libs/smpeg:0=
	virtual/jpeg
	X? ( media-libs/libsdl:0=[X,video] )
	!X? ( media-libs/libsdl:0= )"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

if [[ "${PV}" != *_pre* ]]; then
	S="${WORKDIR}/${P}release"
fi

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="WHATSNEW"

src_configure() {
	python_execute "$(PYTHON -f)" config.py -auto

	if ! use X; then
		sed -e "s:^scrap :#&:" -i Setup || die "sed failed"
	fi

	# Disable automagic dependency on PortMidi.
	sed -e "s:^pypm :#&:" -i Setup || die "sed failed"

	# Restore pygame.movie module.
	sed -e "s:^#movie :movie :" -i Setup || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		sphinx-build docs/reST html || die "Generation of documentation failed"
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" run_tests.py
	}
	VIRTUALX_COMMAND="python_execute_function" virtualmake testing
}

src_install() {
	distutils_src_install

	delete_examples_and_tests() {
		rm -r "${ED}$(python_get_sitedir)/pygame/examples"
		rm -r "${ED}$(python_get_sitedir)/pygame/tests"
	}
	python_execute_function -q delete_examples_and_tests

	if use doc; then
		dohtml -r html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
