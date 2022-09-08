#!/usr/bin/env bash
# Turn on the guard rails
set -exou pipefail
# Tell emacs to update mu4e
emacsclient --eval "(mu4e-update-index)"
