#!/usr/bin/env bash
pandoc *.md -o output.pdf -V geometry:landscape -V geometry:letterpaper -V geometry:margin=0.5in