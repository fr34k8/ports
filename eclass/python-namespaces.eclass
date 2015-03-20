# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: python-namespaces.eclass
# @MAINTAINER:
# Arfrever Frehtes Taifersar Arahesis <Arfrever@Apache.Org>
# @BLURB: Eclass for packages installing Python namespaces
# @DESCRIPTION:
# The python-namespaces eclass defines phase functions for packages installing Python namespaces.

if [[ -z "${_PYTHON_ECLASS_INHERITED}" ]]; then
	inherit python
fi

if ! has "${EAPI:-0}" 4 4-python 5 5-progress; then
	die "EAPI=\"${EAPI}\" not supported by python-namespaces.eclass"
fi

if ! _python_abi_type multiple; then
	die "python-namespaces.eclass can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
fi

# ========================================================================================================================
# ================================================= HANDLING OF METADATA =================================================
# ========================================================================================================================

# @ECLASS-VARIABLE: PYTHON_NAMESPACES
# @REQUIRED
# @DESCRIPTION:
# Python namespaces.
# If given namespace is prepended with "+" or "-", then "+" or "-" is prepended to corresponding
# USE flag in generated IUSE.

if [[ -z "${PYTHON_NAMESPACES}" ]]; then
	die "PYTHON_NAMESPACES variable not set"
fi

_python-namespaces_set_metadata() {
	local namespace parent_namespace

	_PYTHON_NAMESPACES=""
	_PYTHON_NAMESPACES_COUNT="0"
	for namespace in ${PYTHON_NAMESPACES}; do
		_PYTHON_NAMESPACES+="${_PYTHON_NAMESPACES:+ }${namespace#[+-]}"
		((_PYTHON_NAMESPACES_COUNT++))
	done

	DESCRIPTION="Python namespaces: ${_PYTHON_NAMESPACES// /, }"
	HOMEPAGE=""
	SRC_URI=""

	LICENSE="public-domain"
	SLOT="0"

	if [[ "${_PYTHON_NAMESPACES_COUNT}" -ge 2 ]]; then
		if has "${EAPI:-0}" 4 5; then
			IUSE="${PYTHON_NAMESPACES//./-}"
			REQUIRED_USE="|| ( ${_PYTHON_NAMESPACES//./-} )"

			for namespace in ${_PYTHON_NAMESPACES}; do
				if [[ "${namespace}" == *.* ]]; then
					parent_namespace="${namespace%.*}"
					REQUIRED_USE+=" ${namespace//./-}? ( ${parent_namespace//./-} )"
				fi
			done
		else
			IUSE="${PYTHON_NAMESPACES}"
			REQUIRED_USE="|| ( ${_PYTHON_NAMESPACES} )"

			for namespace in ${_PYTHON_NAMESPACES}; do
				if [[ "${namespace}" == *.* ]]; then
					parent_namespace="${namespace%.*}"
					REQUIRED_USE+=" ${namespace}? ( ${parent_namespace} )"
				fi
			done
		fi
	else
		IUSE=""
		REQUIRED_USE=""
	fi

	S="${WORKDIR}"
}
_python-namespaces_set_metadata
unset -f _python-namespaces_set_metadata

# ========================================================================================================================
# =================================================== PHASE FUNCTIONS ====================================================
# ========================================================================================================================

EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

_python-namespaces_get_enabled_namespaces() {
	local namespace

	if [[ "${_PYTHON_NAMESPACES_COUNT}" -ge 2 ]]; then
		for namespace in ${_PYTHON_NAMESPACES}; do
			if has "${EAPI:-0}" 4 5; then
				if use ${namespace//./-}; then
					echo ${namespace}
				fi
			else
				if use ${namespace}; then
					echo ${namespace}
				fi
			fi
		done
	else
		echo ${_PYTHON_NAMESPACES}
	fi
}

# @FUNCTION: python-namespaces_src_install
# @DESCRIPTION:
# Implementation of src_install() phase. This function is exported.
# This function installs __init__.py modules corresponding to Python namespaces.
python-namespaces_src_install() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	python-namespaces_installation() {
		local namespace
		for namespace in $(_python-namespaces_get_enabled_namespaces); do
			dodir $(python_get_sitedir)/${namespace//.//} || return 1
			echo \
"try:
	import pkg_resources
	pkg_resources.declare_namespace(__name__)
	try:
		del pkg_resources
	except NameError:
		pass
except ImportError:
	import pkgutil
	__path__ = pkgutil.extend_path(__path__, __name__)
	del pkgutil" > "${ED}$(python_get_sitedir)/${namespace//.//}/__init__.py" || return 1
		done
	}
	python_execute_function \
		--action-message 'Installation of Python namespaces with $(python_get_implementation_and_version)' \
		--failure-message 'Installation of Python namespaces with $(python_get_implementation_and_version) failed' \
		python-namespaces_installation
	unset -f python-namespaces_installation
}

# @FUNCTION: python-namespaces_pkg_postinst
# @DESCRIPTION:
# Implementation of pkg_postinst() phase. This function is exported.
# This function calls python_byte-compile_modules() with __init__.py modules corresponding to Python namespaces.
python-namespaces_pkg_postinst() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	python_byte-compile_modules $(for namespace in $(_python-namespaces_get_enabled_namespaces); do echo ${namespace//.//}/__init__.py; done)
}

# @FUNCTION: python-namespaces_pkg_postrm
# @DESCRIPTION:
# Implementation of pkg_postrm() phase. This function is exported.
# This function calls python_clean_byte-compiled_modules() with __init__.py modules corresponding to Python namespaces.
python-namespaces_pkg_postrm() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	python_clean_byte-compiled_modules $(for namespace in $(_python-namespaces_get_enabled_namespaces); do echo ${namespace//.//}/__init__.py; done)
}
