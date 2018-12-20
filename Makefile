.phony: open watch

PDF := _result/pdf/index.pdf

$PDF: index.pillar
	pillar build pdf

open:
	open $PDF

watch:
	watchexec --watch index.pillar \
		"pillar build pdf && displayline -r 0 ${PDF}"
