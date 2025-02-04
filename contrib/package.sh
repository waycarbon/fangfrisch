#!/usr/bin/env bash
# vim:tabstop=4:noexpandtab
#
# Script to package fangfrisch for distribution and to handle PyPI uploads.
# You need Python modules 'wheel' and 'twine' to publish to PyPI, and
# Ruby Gems 'asciidoctor' and 'asciidoctor-pdf' to generate HTML/PDF
# documentation.

set -euo pipefail

function usage() {
	local bn
	bn="$(basename $0)"
	echo "Usage: ${bn} {clean | dist}" >&2
	echo "       ${bn} upload [repository]" >&2
	echo "       ${bn} setver {version}" >&2
	exit 1
}

function do_clean() {
	/bin/rm -r build/* dist/* || true
}

function do_dist() {
	python setup.py sdist bdist_wheel
}

function do_upload() {
	if [ $# -gt 0 ]; then
		repo="$1"
	fi
	local opt=(
		'-sign'
		'-i'
		'D3DCBBA4EFA680A1C5C85708593AAE2E98E2219D'
		'-r'
		"${repo:-testpypi}"
	)
	twine upload "${opt[@]}" dist/*
}

function do_setver() {
	[ $# -gt 0 ] || usage
	/usr/bin/sed -i '' -E -e "s/^v[^,]+, {docdate.+/v${1}, {docdate}/" docs/fangfrisch.adoc
	/usr/bin/sed -i '' -E -e "s/^__version.+/__version__ = '${1}'/" fangfrisch/__init__.py
}

[ $# -gt 0 ] || usage
arg="$1"
shift
case "$arg" in
	clean)
		do_${arg}
		;;
	dist | setver | upload)
		source .venv/bin/activate
		do_${arg} "$@"
		;;
	*)
		usage
		;;
esac
