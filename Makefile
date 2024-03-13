# A convenience makefile with automagic rebuild.
#
# open is the macOS command, make watch relies on Skim.app (displayline) and
# https://github.com/watchexec/watchexec
.phony: open watch

PDF := _result/pdf/index.pdf

${PDF}: index.pillar
	pillar build pdf

open: ${PDF}
	open ${PDF}

watch:
	watchexec --watch index.md \
		"make && displayline -background -revert 0 ${PDF}"
