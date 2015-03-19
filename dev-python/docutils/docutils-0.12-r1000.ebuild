# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Docutils - Python Documentation Utilities"
HOMEPAGE="http://docutils.sourceforge.net/ https://pypi.python.org/pypi/docutils"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI="http://people.apache.org/~Arfrever/gentoo/${P}.tar.xz"
else
	SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
fi

LICENSE="BSD-2 GPL-3 public-domain"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/roman)"
RDEPEND="${DEPEND}"

DOCS="*.txt"

src_compile() {
	distutils_src_compile

	# Generate html docs from reStructured text sources.

	# Place html4css1.css in base directory to ensure that the generated reference to it is correct.
	cp docutils/writers/html4css1/html4css1.css .

	pushd tools > /dev/null

	python_execute PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" "$(PYTHON -f)" ../tools/buildhtml.py --input-encoding=utf-8 --stylesheet-path=../html4css1.css --traceback ../docs || die "buildhtml.py failed"

	popd > /dev/null

	# Clean up after building of documentation.
	rm html4css1.css
}

src_test() {
	testing() {
		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/alltests.py
		else
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test3/alltests.py
		fi
	}
	python_execute_function testing
}

install_txt_doc() {
	local doc="${1}"
	local dir="txt/$(dirname ${doc})"
	docinto "${dir}"
	dodoc "${doc}"
}

src_install() {
	distutils_src_install

	# Install tools.
	python_install_executables tools/{buildhtml.py,quicktest.py}

	# Install documentation.
	dohtml -r docs tools

	# Install stylesheet file.
	insinto /usr/share/doc/${PF}/html
	doins docutils/writers/html4css1/html4css1.css
	local doc
	for doc in {docs,tools}/**/*.txt; do
		install_txt_doc "${doc}"
	done
}
