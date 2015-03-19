# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit eutils python waf-utils

PYCAIRO_PYTHON2_VERSION="${PV}"
PYCAIRO_PYTHON3_VERSION="${PV}"
WAF_VERSION="1.7.15"

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="http://cairographics.org/pycairo/ https://pypi.python.org/pypi/pycairo"
SRC_URI="http://cairographics.org/releases/py2cairo-${PYCAIRO_PYTHON2_VERSION}.tar.bz2
	http://cairographics.org/releases/pycairo-${PYCAIRO_PYTHON3_VERSION}.tar.bz2
	http://waf.googlecode.com/files/waf-${WAF_VERSION}.tar.bz2"

# Pycairo 1.10.0 for Python 2: || ( LGPL-2.1 MPL-1.1 )
# Pycairo 1.10.0 for Python 3: LGPL-3
LICENSE="|| ( LGPL-2.1 MPL-1.1 ) LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples +svg test xcb"

RDEPEND=">=x11-libs/cairo-1.10.0[svg?,xcb?]
	xcb? ( $(python_abi_depend -i "2.*" x11-libs/xpyb) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( $(python_abi_depend dev-python/pytest) )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

src_prepare() {
	pushd "${WORKDIR}/py2cairo-${PYCAIRO_PYTHON2_VERSION}" > /dev/null

	epatch "${FILESDIR}/py2cairo-1.10.0-xpyb_detection.patch"
	epatch "${FILESDIR}/py2cairo-1.10.0-svg_check.patch"
	epatch "${FILESDIR}/py2cairo-1.10.0-xpyb_check.patch"

	rm -f src/config.h

	# Use newer Waf.
	cp "${WORKDIR}/waf-${WAF_VERSION}/waf" .

	# Fix compatibility with newer Waf.
	# http://cgit.freedesktop.org/pycairo/commit/?id=c57cd129407c904f8c2f752a59d0183df7b01a5e
	sed -e "s/ctx.\(tool_options\|check_tool\)(/ctx.load(/" -i wscript

	popd > /dev/null

	pushd "${WORKDIR}/pycairo-${PYCAIRO_PYTHON3_VERSION}" > /dev/null

	epatch "${FILESDIR}/${PN}-1.10.0-xpyb_detection.patch"
	epatch "${FILESDIR}/${PN}-1.10.0-svg_check.patch"
	epatch "${FILESDIR}/${PN}-1.10.0-xpyb_check.patch"

	# Use newer Waf.
	cp "${WORKDIR}/waf-${WAF_VERSION}/waf" .

	# Fix compatibility with newer Waf.
	# http://cgit.freedesktop.org/pycairo/commit/?id=c57cd129407c904f8c2f752a59d0183df7b01a5e
	sed -e "s/ctx.\(tool_options\|check_tool\)(/ctx.load(/" -i wscript

	popd > /dev/null

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			cp -r "${WORKDIR}/pycairo-${PYCAIRO_PYTHON3_VERSION}" "${S}-${PYTHON_ABI}"
		else
			cp -r "${WORKDIR}/py2cairo-${PYCAIRO_PYTHON2_VERSION}" "${S}-${PYTHON_ABI}"
		fi
	}
	python_execute_function preparation
}

src_configure() {
	if ! use svg; then
		export PYCAIRO_DISABLE_SVG="1"
	fi

	if ! use xcb; then
		export PYCAIRO_DISABLE_XPYB="1"
	fi

	WAF_BINARY="./waf" python_execute_function -s waf-utils_src_configure --nopyc --nopyo
}

src_compile() {
	WAF_BINARY="./waf" python_execute_function -s waf-utils_src_compile
}

src_test() {
	test_installation() {
		python_execute ./waf install --destdir="${T}/tests/${PYTHON_ABI}"
	}
	python_execute_function -q -s test_installation

	python_execute_py.test -P '${T}/tests/${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)' -s
}

src_install() {
	WAF_BINARY="./waf" python_execute_function -s waf-utils_src_install

	dodoc AUTHORS NEWS README

	if use doc; then
		dohtml -r doc/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}

pkg_postinst() {
	python_mod_optimize cairo
}

pkg_postrm() {
	python_mod_cleanup cairo
}
