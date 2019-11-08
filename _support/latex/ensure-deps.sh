#!/bin/bash

xargs tlmgr install <<DEPS
    fira
    gentium-tug
    opensans

    varwidth
    footmisc
    tcolorbox
    environ
    trimspaces
    ctablestack
    import
    multirow
DEPS
