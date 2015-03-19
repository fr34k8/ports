# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit eutils python toolchain-funcs

DESCRIPTION="Object-oriented Python bindings for Subversion"
HOMEPAGE="http://pysvn.tigris.org/ http://pysvn.barrys-emacs.org/"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI="http://people.apache.org/~Arfrever/gentoo/${P}.tar.xz"
else
	SRC_URI="http://pysvn.barrys-emacs.org/source_kits/${P}.tar.gz"
fi

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND="dev-vcs/subversion"
DEPEND="${RDEPEND}
	$(python_abi_depend ">=dev-python/pycxx-6.2.4")"

src_prepare() {
	# Delete internal copy of dev-python/pycxx.
	rm -fr Import

	epatch "${FILESDIR}/${PN}-1.7.9-respect_flags.patch"

	python_copy_sources
}

src_configure() {
	configuration() {
		cd Source
		python_execute "$(PYTHON)" setup.py configure \
			--pycxx-src-dir="${EPREFIX}/usr/share/python$(python_get_version)/CXX" \
			--apr-inc-dir="${EPREFIX}/usr/include/apr-1" \
			--apu-inc-dir="${EPREFIX}/usr/include/apr-1" \
			--svn-root-dir="${EPREFIX}/usr"
	}
	python_execute_function -s configuration
}

src_compile() {
	building() {
		cd Source
		emake CC="$(tc-getCC)" CXX="$(tc-getCXX)"
	}
	python_execute_function -s building
}

src_test() {
	testing() {
		cd Tests
		LC_ALL="en_US.UTF-8" emake
	}
	python_execute_function -s testing
}

src_install() {
	installation() {
		cd Source/pysvn
		insinto "$(python_get_sitedir)/pysvn"
		doins __init__.py
		exeinto "$(python_get_sitedir)/pysvn"
		doexe _pysvn*.so
	}
	python_execute_function -s installation

	if use doc; then
		dohtml -r Docs/
	fi

	if use examples; then
		docinto examples
		dodoc Examples/Client/*
	fi
}

pkg_postinst() {
	python_mod_optimize pysvn
}

pkg_postrm() {
	python_mod_cleanup pysvn
}
