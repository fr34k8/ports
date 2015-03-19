# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<[threads]>>"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy"
# Random time-outs in some tests.
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit bash-completion-r1 distutils elisp-common eutils

DESCRIPTION="Scalable distributed SCM"
HOMEPAGE="http://mercurial.selenic.com/ https://pypi.python.org/pypi/Mercurial"
SRC_URI="http://mercurial.selenic.com/release/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="bugzilla emacs gpg test tk"

RDEPEND="app-misc/ca-certificates
	bugzilla? ( $(python_abi_depend dev-python/mysql-python) )
	gpg? ( app-crypt/gnupg )
	tk? ( dev-lang/tk )"
DEPEND="emacs? ( virtual/emacs )
	$([[ ${PV} == 9999 ]] && python_abi_depend dev-python/docutils)
	test? (
		app-arch/unzip
		$(python_abi_depend dev-python/pygments)
	)"

PYTHON_CFLAGS=(
	"2.* + -fno-strict-aliasing"
	"* - -ftracer -ftree-vectorize"
)

PYTHON_MODULES="${PN} hgext"
SITEFILE="70${PN}-gentoo.el"

src_prepare() {
	distutils_src_prepare
	sed -e "s|^if sys.platform == 'darwin' and os.path.exists('/usr/bin/xcodebuild'):$|if False:|" -i setup.py

	# https://bz.selenic.com/show_bug.cgi?id=4083
	rm tests/test-subrepo-svn.t
	# https://bz.selenic.com/show_bug.cgi?id=4084
	rm tests/test-clone-cgi.t
	rm tests/test-hgweb-commands.t
	rm tests/test-push-cgi.t
	# Disable test failing due to DeprecationWarning in internal code in dev-vcs/bzr 2.6.0.
	rm tests/test-convert-bzr-directories.t

	epatch "${FILESDIR}/${PN}-3.0.1-po_fixes.patch"
}

src_compile() {
	distutils_src_compile

	if [[ ${PV} == 9999 ]]; then
		emake doc
	fi

	if use emacs; then
		pushd contrib > /dev/null || die
		elisp-compile mercurial.el
		popd > /dev/null || die
	fi

	rm -r contrib/{macosx,win32} || die
}

src_test() {
	testing() {
		local testdir="${T}/tests-${PYTHON_ABI}"
		python_execute "$(PYTHON)" setup.py build -b build-${PYTHON_ABI} install --root="${testdir}"
		cd tests || die
		rm -fr "${testdir}/tests"
		python_execute PYTHONPATH="${testdir}$(python_get_sitedir)" "$(PYTHON)" run-tests.py \
			--tmpdir="${testdir}/temp" \
			--verbose \
			--with-hg="${testdir}/usr/bin/hg"
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	newbashcomp contrib/bash_completion hg
	insinto /usr/share/zsh/site-functions
	newins contrib/zsh_completion _hg

	if use emacs; then
		elisp-install ${PN} contrib/mercurial.el*
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
	fi

	dodoc CONTRIBUTORS
	cp hgweb*.cgi "${ED}"/usr/share/doc/${PF}/ || die

	dobin hgeditor
	dobin contrib/hgk
	python_install_executables contrib/hg-ssh

	rm -r contrib/{*.el,bash_completion,buildrpm,hg-ssh,hgk,mercurial.spec,plan9,wix,zsh_completion} || die

	dodoc -r contrib
	docompress -x /usr/share/doc/${PF}/contrib
	doman doc/*.?

	cat > "${T}/80mercurial" <<-EOF
HG="${EPREFIX}/usr/bin/hg"
EOF
	doenvd "${T}/80mercurial"

	insinto /etc/mercurial/hgrc.d
	doins "${FILESDIR}/cacerts.rc"
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen

	elog "If you want to convert repositories from other tools using convert"
	elog "extension please install correct tool:"
	elog "  dev-vcs/cvs"
	elog "  dev-vcs/darcs"
	elog "  dev-vcs/git"
	elog "  dev-vcs/monotone"
	elog "  dev-vcs/subversion"
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
