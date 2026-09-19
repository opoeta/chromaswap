#!/bin/sh
# Builds dist/chromaswap.tar.gz (top folder "chromaswap/") from the committed files.
mkdir -p dist && git archive --prefix=chromaswap/ -o dist/chromaswap.tar.gz HEAD && ls -l dist/chromaswap.tar.gz
