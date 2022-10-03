#!/usr/bin/env bash
# Tell emacs to update mu4e
emacsclient --eval "(mu4e-update-index)" || true
