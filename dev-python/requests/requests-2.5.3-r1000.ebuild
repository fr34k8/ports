# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Python HTTP for Humans."
HOMEPAGE="http://python-requests.org/ https://github.com/kennethreitz/requests https://pypi.python.org/pypi/requests"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/certifi)
	$(python_abi_depend dev-python/chardet)
	$(python_abi_depend dev-python/urllib3)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/pytest) )"

DOCS="HISTORY.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Use system version of dev-python/chardet.
	sed -e "s/from .packages import chardet/import chardet/" -i requests/compat.py
	rm -r requests/packages/chardet

	# Use system version of dev-python/urllib3.
	sed -e "s/\(from \).packages.\(urllib3.* import\)/\1\2/" -i requests/*.py
	sed -e "s/\(from \)requests.packages.\(urllib3.* import\)/\1\2/" -i test_requests.py
	rm -r requests/packages/urllib3

	# Disable installation of deleted internal copies of dev-python/chardet and dev-python/urllib3.
	sed -e "/requests\.packages\./d" -i setup.py
}

src_test() {
	testing() {
		if [[ "$(python_get_implementation)" == "Jython" ]]; then
			# http://bugs.jython.org/issue2285
			python_execute LC_ALL="en_US.UTF-8" PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test_requests.py -v
		else
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test_requests.py -v
		fi
	}
	python_execute_function testing
}
