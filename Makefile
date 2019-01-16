.phony: open watch

PDF := _result/pdf/index.pdf

${PDF}: index.pillar
	pillar build pdf

open: ${PDF}
	open ${PDF}

watch:
	watchexec --watch index.pillar \
		"make && displayline -background -revert 0 ${PDF}"
