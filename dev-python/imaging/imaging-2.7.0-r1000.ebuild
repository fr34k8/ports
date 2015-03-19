# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<[{*-cpython}tk?]>>"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils eutils

MY_PN="Pillow"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python Imaging Library - Pillow (fork of PIL)"
HOMEPAGE="https://github.com/python-pillow/Pillow https://pypi.python.org/pypi/Pillow"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="HPND"
SLOT="0"
KEYWORDS="*"
IUSE="X doc examples jpeg jpeg2k lcms test tiff tk truetype webp zlib"
REQUIRED_USE="test? ( jpeg )"

RDEPEND="X? ( x11-misc/xdg-utils )
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( media-libs/openjpeg:2= )
	lcms? ( media-libs/lcms:2= )
	tiff? ( media-libs/tiff:0= )
	truetype? ( media-libs/freetype:2= )
	webp? ( >=media-libs/libwebp-0.3:0= )
	zlib? ( sys-libs/zlib:0= )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? (
		$(python_abi_depend dev-python/sphinx)
		$(python_abi_depend dev-python/sphinx-better-theme)
	)
	test? ( $(python_abi_depend -i "2.6 3.1" dev-python/unittest2) )"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.rst README.rst"
PYTHON_MODULES="PIL"

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-2.6.0-delete_hardcoded_paths.patch"
	epatch "${FILESDIR}/${PN}-2.6.0-libm_linking.patch"
	epatch "${FILESDIR}/${PN}-2.6.0-use_xdg-open.patch"

	# Fix compatibility with Python 3.1.
	sed -e "s/callable(\([^)]\+\))/(hasattr(\1, '__call__') if __import__('sys').version_info\[:2\] == (3, 1) else &)/" -i PIL/Image.py
	sed -e "s/if sys.version_info\[:2\] <= (2, 6):/if sys.version_info[:2] <= (2, 6) or sys.version_info[:2] == (3, 1):/" -i Tests/helper.py

	# https://github.com/python-pillow/Pillow/issues/940
	sed -e "s/test_monochrome/_&/" -i Tests/test_file_palm.py

	local feature
	for feature in jpeg jpeg2k:jpeg2000 lcms tiff truetype:freetype webp webp:webpmux zlib; do
		if ! use ${feature%:*}; then
			sed -e "s/if feature\.want('${feature#*:}'):/if False:/" -i setup.py
		fi
	done

	if ! use tk; then
		sed -e "s/import _tkinter/raise ImportError/" -i setup.py
	fi
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
		popd > /dev/null
	fi
}

src_test() {
	tests() {
		local exit_status="0" test

		if ! python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" selftest.py --installed; then
			eerror "selftest.py failed with $(python_get_implementation_and_version)"
			exit_status="1"
		fi

		for test in Tests/test_*.py; do
			if ! python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function tests
}

src_install() {
	distutils_src_install

	install_headers() {
		insinto "$(python_get_includedir)"
		doins libImaging/Imaging.h
		doins libImaging/ImPlatform.h
	}
	python_execute_function install_headers

	local module
	for module in PIL/*.py; do
		module="${module#PIL/}"
		module="${module%.py}"
		[[ "${module}" =~ ^(__init__|_binary|_util|ImageMorph|Jpeg2KImagePlugin|JpegPresets|MpoImagePlugin|PyAccess|WebPImagePlugin)$ ]] && continue
		PYTHON_MODULES+=" ${module}.py"
	done

	generate_compatibility_modules() {
		local module
		for module in PIL/*.py; do
			module="${module#PIL/}"
			module="${module%.py}"
			[[ "${module}" =~ ^(__init__|_binary|_util|ImageMorph|Jpeg2KImagePlugin|JpegPresets|MpoImagePlugin|PyAccess|WebPImagePlugin)$ ]] && continue
			dodir "$(python_get_sitedir)"
			cat << EOF > "${ED}$(python_get_sitedir)/${module}.py"
def _warning():
	import warnings
	message = "'%s' module is deprecated. Use 'PIL.%s' module instead." % (__name__, __name__)
	warnings.filterwarnings("default", message, DeprecationWarning)
	warnings.warn(message, DeprecationWarning)
_warning()
del _warning

from PIL.${module} import *
EOF
		done
	}
	python_execute_function -q generate_compatibility_modules

	if use doc; then
		dohtml -r docs/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins Scripts/*
	fi
}
