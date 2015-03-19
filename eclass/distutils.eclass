# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: distutils.eclass
# @MAINTAINER:
# Arfrever Frehtes Taifersar Arahesis <Arfrever@Apache.Org>
# @BLURB: Eclass for packages with build systems using Distutils
# @DESCRIPTION:
# The distutils eclass defines phase functions for packages with build systems using Distutils.

if [[ -z "${_PYTHON_ECLASS_INHERITED}" ]]; then
	inherit python
fi

if has "${EAPI:-0}" 0 1 && _python_abi_type multiple; then
	die "EAPI=\"${EAPI}\" not supported by distutils.eclass in ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable"
elif has "${EAPI:-0}" 0 1 2 && ! _python_abi_type multiple; then
	die "EAPI=\"${EAPI}\" not supported by distutils.eclass in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
fi

EXPORT_FUNCTIONS src_prepare src_compile src_install pkg_postinst pkg_postrm

if [[ -z "$(declare -p PYTHON_DEPEND 2> /dev/null)" ]]; then
	DEPEND="dev-lang/python"
	RDEPEND="${DEPEND}"
fi

# @ECLASS-VARIABLE: DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES
# @DESCRIPTION:
# Set this to use separate source directories for each enabled version of Python.

# @ECLASS-VARIABLE: DISTUTILS_SETUP_FILES
# @DESCRIPTION:
# Array of paths to setup files.
# Syntax:
#   [current_working_directory|]path_to_setup_file

# @ECLASS-VARIABLE: DISTUTILS_GLOBAL_OPTIONS
# @DESCRIPTION:
# Array of global options passed to setup files.
# Syntax in EAPI <4:
#   global_option
# Syntax in EAPI >=4:
#   Python_ABI_pattern global_option

# @ECLASS-VARIABLE: DISTUTILS_SRC_TEST
# @DESCRIPTION:
# Type of test command used by distutils_src_test().
# IUSE and DEPEND are automatically adjusted, unless DISTUTILS_DISABLE_TEST_DEPENDENCY is set.
# Valid values:
#   setup.py
#   nosetests
#   py.test
#   trial [arguments]

# @ECLASS-VARIABLE: DISTUTILS_DISABLE_TEST_DEPENDENCY
# @DESCRIPTION:
# Disable modification of IUSE and DEPEND caused by setting of DISTUTILS_SRC_TEST.

if [[ -n "${DISTUTILS_SRC_TEST}" && ! "${DISTUTILS_SRC_TEST}" =~ ^(setup\.py|nosetests|py\.test|trial(\ .*)?)$ ]]; then
	die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
fi

if [[ -z "${DISTUTILS_DISABLE_TEST_DEPENDENCY}" ]]; then
	if [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		IUSE="test"
		if _python_abi_type single || { ! has "${EAPI:-0}" 2 3 4 5 && _python_abi_type multiple; }; then
			if [[ -n "${PYTHON_TESTS_RESTRICTED_ABIS}" ]]; then
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" dev-python/nose) )"
			else
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend dev-python/nose) )"
			fi
		else
			DEPEND+="${DEPEND:+ }test? ( dev-python/nose )"
		fi
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		IUSE="test"
		if _python_abi_type single || { ! has "${EAPI:-0}" 2 3 4 5 && _python_abi_type multiple; }; then
			if [[ -n "${PYTHON_TESTS_RESTRICTED_ABIS}" ]]; then
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" dev-python/pytest) )"
			else
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend dev-python/pytest) )"
			fi
		else
			DEPEND+="${DEPEND:+ }test? ( dev-python/pytest )"
		fi
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		IUSE="test"
		if _python_abi_type single || { ! has "${EAPI:-0}" 2 3 4 5 && _python_abi_type multiple; }; then
			if [[ -n "${PYTHON_TESTS_RESTRICTED_ABIS}" ]]; then
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" dev-python/twisted-core) )"
			else
				DEPEND+="${DEPEND:+ }test? ( $(python_abi_depend dev-python/twisted-core) )"
			fi
		else
			DEPEND+="${DEPEND:+ }test? ( dev-python/twisted-core )"
		fi
	fi
fi

if [[ -n "${DISTUTILS_SRC_TEST}" ]]; then
	EXPORT_FUNCTIONS src_test
fi

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Documentation files installed by distutils_src_install().

_distutils_execute() {
	if [[ "$(python_get_implementation)" == "PyPy" ]]; then
		local -x CFLAGS="${CFLAGS}${CFLAGS:+ }-Werror=implicit-function-declaration"
	fi

	_python_execute_with_build_environment python_execute "$@"
}

_distutils_get_build_dir() {
	if _python_abi_type multiple && [[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		echo "build-${PYTHON_ABI}"
	else
		echo "build"
	fi
}

_distutils_get_PYTHONPATH() {
	if _python_abi_type multiple && [[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		ls -d "$(pwd)/build-${PYTHON_ABI}/lib"* 2> /dev/null
	else
		ls -d "$(pwd)/build/lib"* 2> /dev/null
	fi
}

_distutils_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if [[ "$(type -t "distutils_src_${EBUILD_PHASE}_$1_hook")" == "function" ]]; then
		"distutils_src_${EBUILD_PHASE}_$1_hook"
	fi
}

_distutils_prepare_global_options() {
	local element option pattern

	if [[ -n "$(declare -p DISTUTILS_GLOBAL_OPTIONS 2> /dev/null)" && "$(declare -p DISTUTILS_GLOBAL_OPTIONS)" != "declare -a DISTUTILS_GLOBAL_OPTIONS="* ]]; then
		die "DISTUTILS_GLOBAL_OPTIONS should be indexed array"
	fi

	if has "${EAPI:-0}" 2 3; then
		_DISTUTILS_GLOBAL_OPTIONS=("${DISTUTILS_GLOBAL_OPTIONS[@]}")
	else
		_DISTUTILS_GLOBAL_OPTIONS=()

		for element in "${DISTUTILS_GLOBAL_OPTIONS[@]}"; do
			if [[ ! "${element}" =~ ^${_PYTHON_ABI_PATTERN_REGEX}\ . ]]; then
				die "Element '${element}' of DISTUTILS_GLOBAL_OPTIONS array has invalid syntax"
			fi
			pattern="${element%% *}"
			option="${element#* }"
			if _python_check_python_abi_matching "${PYTHON_ABI}" "${pattern}"; then
				_DISTUTILS_GLOBAL_OPTIONS+=("${option}")
			fi
		done
	fi
}

_distutils_prepare_current_working_directory() {
	if [[ "$1" == *"|"*"|"* ]]; then
		die "Element '$1' of DISTUTILS_SETUP_FILES array has invalid syntax"
	fi

	if [[ "$1" == *"|"* ]]; then
		echo "${_BOLD}[${1%|*}]${_NORMAL}"
		pushd "${1%|*}" > /dev/null || die "Entering directory '${1%|*}' failed"
	fi
}

_distutils_restore_current_working_directory() {
	if [[ "$1" == *"|"* ]]; then
		popd > /dev/null || die "Leaving directory '${1%|*}' failed"
	fi
}

# @FUNCTION: distutils_src_prepare
# @DESCRIPTION:
# The distutils src_prepare function. This function is exported.
distutils_src_prepare() {
	if [[ "${EBUILD_PHASE}" != "prepare" ]]; then
		die "${FUNCNAME}() can be used only in src_prepare() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	local distribute_setup_existence ez_setup_existence setup_file

	echo " ${_GREEN}*${_NORMAL} ${_BLUE}Preparing Distutils build system...${_NORMAL}"

	for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
		_distutils_prepare_current_working_directory "${setup_file}"

		distribute_setup_existence="0" ez_setup_existence="0"

		# Delete ez_setup files to prevent packages from installing Setuptools on their own.
		[[ -d ez_setup || -f ez_setup.py ]] && ez_setup_existence="1"
		rm -fr ez_setup*
		if [[ "${ez_setup_existence}" == "1" ]]; then
			echo "def use_setuptools(*args, **kwargs): pass" > ez_setup.py
		fi

		# Delete distribute_setup files to prevent packages from installing Distribute on their own.
		[[ -d distribute_setup || -f distribute_setup.py ]] && distribute_setup_existence="1"
		rm -fr distribute_setup*
		if [[ "${distribute_setup_existence}" == "1" ]]; then
			echo "def use_setuptools(*args, **kwargs): pass" > distribute_setup.py
		fi

		_distutils_restore_current_working_directory "${setup_file}"
	done

	if _python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		python_copy_sources
	fi
}

# @FUNCTION: distutils_src_compile
# @DESCRIPTION:
# The distutils src_compile function. This function is exported.
# In ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable, this function calls distutils_src_compile_pre_hook()
# and distutils_src_compile_post_hook(), if they are defined.
distutils_src_compile() {
	if [[ "${EBUILD_PHASE}" != "compile" ]]; then
		die "${FUNCNAME}() can be used only in src_compile() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local _DISTUTILS_GLOBAL_OPTIONS=() setup_file

	if _python_abi_type single || _python_abi_type multiple; then
		distutils_building() {
			_distutils_hook pre

			_distutils_prepare_global_options

			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				_distutils_prepare_current_working_directory "${setup_file}"

				if _python_abi_type multiple; then
					_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "$(_distutils_get_build_dir)" "$@" || return "$?"
				else
					_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@" || return "$?"
				fi

				_distutils_restore_current_working_directory "${setup_file}"
			done

			_distutils_hook post
		}
		python_execute_function $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) distutils_building "$@"
		unset -f distutils_building
	else
		_distutils_prepare_global_options

		for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
			_distutils_prepare_current_working_directory "${setup_file}"

			_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@" || die "Building failed"

			_distutils_restore_current_working_directory "${setup_file}"
		done
	fi
}

_distutils_src_test_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if ! _python_abi_type single && ! _python_abi_type multiple; then
		return
	fi

	if [[ "$(type -t "distutils_src_test_pre_hook")" == "function" ]]; then
		eval "python_execute_$1_pre_hook() {
			distutils_src_test_pre_hook
		}"
	fi

	if [[ "$(type -t "distutils_src_test_post_hook")" == "function" ]]; then
		eval "python_execute_$1_post_hook() {
			distutils_src_test_post_hook
		}"
	fi
}

# @FUNCTION: distutils_src_test
# @DESCRIPTION:
# The distutils src_test function. This function is exported, when DISTUTILS_SRC_TEST variable is set.
# In ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable, this function calls distutils_src_test_pre_hook()
# and distutils_src_test_post_hook(), if they are defined.
distutils_src_test() {
	if [[ "${EBUILD_PHASE}" != "test" ]]; then
		die "${FUNCNAME}() can be used only in src_test() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local _DISTUTILS_GLOBAL_OPTIONS=() arguments setup_file

	if [[ "${DISTUTILS_SRC_TEST}" == "setup.py" ]]; then
		if _python_abi_type single || _python_abi_type multiple; then
			distutils_testing() {
				_distutils_hook pre

				_distutils_prepare_global_options

				for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
					_distutils_prepare_current_working_directory "${setup_file}"

					if _python_abi_type multiple; then
						_distutils_execute PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") test "$@" || return "$?"
					else
						_distutils_execute PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@" || return "$?"
					fi

					_distutils_restore_current_working_directory "${setup_file}"
				done

				_distutils_hook post
			}
			python_execute_function $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) distutils_testing "$@"
			unset -f distutils_testing
		else
			_distutils_prepare_global_options

			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				_distutils_prepare_current_working_directory "${setup_file}"

				_distutils_execute PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@" || die "Testing failed"

				_distutils_restore_current_working_directory "${setup_file}"
			done
		fi
	elif [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		_distutils_src_test_hook nosetests

		python_execute_nosetests -P '$(_distutils_get_PYTHONPATH)' $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) -- "$@"
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		_distutils_src_test_hook py.test

		python_execute_py.test -P '$(_distutils_get_PYTHONPATH)' $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) -- "$@"
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		if [[ "${DISTUTILS_SRC_TEST}" == "trial "* ]]; then
			arguments="${DISTUTILS_SRC_TEST#trial }"
		else
			arguments="${PN}"
		fi

		_distutils_src_test_hook trial

		python_execute_trial -P '$(_distutils_get_PYTHONPATH)' $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) -- ${arguments} "$@"
	else
		die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
	fi
}

# @FUNCTION: distutils_src_install
# @DESCRIPTION:
# The distutils src_install function. This function is exported.
# In ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable, this function calls distutils_src_install_pre_hook()
# and distutils_src_install_post_hook(), if they are defined.
# This function installs some standard documentation files (AUTHORS, BUGS, Change*, CHANGELOG, CHANGES,
# CONTRIBUTORS, CREDITS, KNOWN_BUGS, MAINTAINERS, NEWS, README*, THANKS, TODO).
distutils_src_install() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables
	_python_set_color_variables

	local _DISTUTILS_GLOBAL_OPTIONS=() doc line nspkg_pth_file nspkg_pth_files=() setup_file

	if _python_abi_type single || _python_abi_type multiple; then
		distutils_installation() {
			_distutils_hook pre

			_distutils_prepare_global_options

			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				_distutils_prepare_current_working_directory "${setup_file}"

				if _python_abi_type multiple; then
					_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") install --no-compile --root="${T}/images/${PYTHON_ABI}" "$@" || return "$?"
				else
					_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || return "$?"
				fi

				_distutils_restore_current_working_directory "${setup_file}"
			done

			_distutils_hook post
		}
		python_execute_function $(_python_abi_type multiple && [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo -s) distutils_installation "$@"
		unset -f distutils_installation

		if _python_abi_type multiple; then
			python_merge_intermediate_installation_images "${T}/images"
		fi
	else
		_distutils_prepare_global_options

		for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
			_distutils_prepare_current_working_directory "${setup_file}"

			_distutils_execute "$(PYTHON)" "${setup_file#*|}" "${_DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || die "Installation failed"

			_distutils_restore_current_working_directory "${setup_file}"
		done
	fi

	if ! has "${EAPI:-0}" 2 3; then
		python_generate_cffi_modules
	fi

	while read -d $'\0' -r nspkg_pth_file; do
		nspkg_pth_files+=("${nspkg_pth_file}")
	done < <(find "${ED}" -name "*-nspkg.pth" -type f -print0)

	if [[ "${#nspkg_pth_files[@]}" -gt 0 ]]; then
		einfo
		einfo "Python namespaces:"
		for nspkg_pth_file in "${nspkg_pth_files[@]}"; do
			einfo "    '${nspkg_pth_file#${ED%/}}':"
			while read -r line; do
				einfo "        $(echo "${line}" | sed -e "s/.*types\.ModuleType('\([^']\+\)').*/\1/")"
			done < "${nspkg_pth_file}"
			if ! has "${EAPI:-0}" 2 3; then
				rm "${nspkg_pth_file}" || die "Deletion of '${nspkg_pth_file}' failed"
			fi
		done
		einfo
	fi

	if [[ -e "${ED}usr/local" ]]; then
		die "Illegal installation into /usr/local"
	fi


	if [[ -z "$(declare -p DOCS 2> /dev/null)" ]]; then
		for doc in AUTHORS BUGS Change* CHANGELOG CHANGES CONTRIBUTORS CREDITS KNOWN_BUGS MAINTAINERS NEWS README* THANKS TODO; do
			[[ -s "${doc}" ]] && dodoc "${doc}"
		done
	elif [[ -n "${DOCS}" ]]; then
		if has "${EAPI:-0}" 2 3; then
			dodoc ${DOCS} || die "dodoc failed"
		else
			dodoc -r ${DOCS}
		fi
	fi

	DISTUTILS_SRC_INSTALL_EXECUTED="1"
}

# @FUNCTION: distutils_pkg_postinst
# @DESCRIPTION:
# The distutils pkg_postinst function. This function is exported.
# When PYTHON_MODULES variable is set, then this function calls python_byte-compile_modules() with modules
# specified in PYTHON_MODULES variable. Otherwise it calls python_byte-compile_modules() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postinst() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	if [[ -z "${DISTUTILS_SRC_INSTALL_EXECUTED}" ]]; then
		die "${FUNCNAME}() called illegally"
	fi

	local pylibdir

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	if [[ -z "${PYTHON_MODULES}" && -n "${PYTHON_MODNAME}" ]]; then
		PYTHON_MODULES="${PYTHON_MODNAME}"
	fi

	if [[ -z "$(declare -p PYTHON_MODULES 2> /dev/null)" ]]; then
		for pylibdir in "${EROOT}"usr/${_PYTHON_MULTILIB_LIBDIR}/python* "${EROOT}"usr/share/jython-*/Lib "${EROOT}"usr/${_PYTHON_MULTILIB_LIBDIR}/pypy*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODULES="${PN}"
			fi
		done
	fi

	if [[ -n "${PYTHON_MODULES}" ]]; then
		python_byte-compile_modules ${PYTHON_MODULES}
	fi
}

# @FUNCTION: distutils_pkg_postrm
# @DESCRIPTION:
# The distutils pkg_postrm function. This function is exported.
# When PYTHON_MODULES variable is set, then this function calls python_clean_byte-compiled_modules() with modules
# specified in PYTHON_MODULES variable. Otherwise it calls python_clean_byte-compiled_modules() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postrm() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	if [[ -z "${DISTUTILS_SRC_INSTALL_EXECUTED}" ]]; then
		die "${FUNCNAME}() called illegally"
	fi

	local pylibdir

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	if [[ -z "${PYTHON_MODULES}" && -n "${PYTHON_MODNAME}" ]]; then
		PYTHON_MODULES="${PYTHON_MODNAME}"
	fi

	if [[ -z "$(declare -p PYTHON_MODULES 2> /dev/null)" ]]; then
		for pylibdir in "${EROOT}"usr/${_PYTHON_MULTILIB_LIBDIR}/python* "${EROOT}"usr/share/jython-*/Lib "${EROOT}"usr/${_PYTHON_MULTILIB_LIBDIR}/pypy*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODULES="${PN}"
			fi
		done
	fi

	if [[ -n "${PYTHON_MODULES}" ]]; then
		python_clean_byte-compiled_modules ${PYTHON_MODULES}
	fi
}

# @FUNCTION: distutils_get_intermediate_installation_image
# @DESCRIPTION:
# Print path to intermediate installation image.
#
# This function can be used only in distutils_src_install_pre_hook() and distutils_src_install_post_hook().
distutils_get_intermediate_installation_image() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution

	if [[ ! " ${FUNCNAME[@]:1} " =~ " "(distutils_src_install_pre_hook|distutils_src_install_post_hook)" " ]]; then
		die "${FUNCNAME}() can be used only in distutils_src_install_pre_hook() and distutils_src_install_post_hook()"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	echo "${T}/images/${PYTHON_ABI}"
}
