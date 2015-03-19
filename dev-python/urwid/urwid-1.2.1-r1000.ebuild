# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[ncurses]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Urwid is a curses-based user interface library for Python"
HOMEPAGE="http://urwid.org/ https://github.com/wardi/urwid https://pypi.python.org/pypi/urwid"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples glib test twisted"
REQUIRED_USE="test? ( glib twisted )"

RDEPEND="glib? ( $(python_abi_depend -i "2.*" dev-python/pygobject:2) )
	twisted? ( $(python_abi_depend -i "2.*" dev-python/twisted-core) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="docs/changelog.rst"

src_prepare() {
	distutils_src_prepare

	# urwid.str_util extension module is incompatible with PyPy.
	sed \
		-e "/import os/a import platform" \
		-e "/'ext_modules':/s:\[Extension('urwid.str_util', sources=\['source/str_util.c'\])\]:& if platform.python_implementation() != \"PyPy\" else []:" \
		-i setup.py

	# Fix AttributeError during generation of documentation with Python 3.
	sed -e "/^FILE_PATH =/s/\.decode('utf-8')//" -i docs/conf.py

	if [[ "$(python_get_version -f -l --major)" == "3" ]]; then
		2to3-$(PYTHON -f --ABI) -nw --no-diffs docs/conf.py
	fi

	# Fix tests with Python 2.6.
	# https://github.com/wardi/urwid/commit/d68a468d86b4f7ec0385fe7cdf4c0aaf69e1e574
	sed -e "s/assertIn(\(.*\), \(.*\))/assertTrue(\1 in \2)/" -i urwid/tests/test_event_loops.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute PYTHONPATH="$(ls -d build-$(PYTHON -f --ABI)/lib*)" sphinx-build docs html || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/urwid/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r html/
	fi

	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
