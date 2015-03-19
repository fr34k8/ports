# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="SPF (Sender Policy Framework) implemented in Python."
HOMEPAGE="https://pypi.python.org/pypi/pyspf"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/authres)
	$(python_abi_depend -i "2.*" dev-python/pydns:2)
	$(python_abi_depend -i "3.*" dev-python/pydns:3)
	$(python_abi_depend virtual/python-ipaddress)"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend dev-python/pyyaml) )"

PYTHON_MODULES="spf.py"

src_test() {
	cd test

	testing() {
		python_execute PYTHONPATH="../build-${PYTHON_ABI}/lib" "$(PYTHON)" testspf.py
	}
	python_execute_function testing
}
