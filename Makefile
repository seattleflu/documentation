# Use bash to run recipes so we can rely on fancier shell features
SHELL := /bin/bash

# Path to clone of https://github.com/auderenow/learn
AUDERE_SRC := ../audere/learn
FLU_TRACK  := $(AUDERE_SRC)/learn/ReactNativeTS/FluTrack

# These targets don't have a good upstream source to use for dependency
# timestamp resolution.
.PHONY: \
	survey-data-dictionary.json \
	survey-data-dictionary.txt

all: survey-data-dictionary.txt survey-flow.pdf

survey-data-dictionary.json: | bin/survey-data-dictionary
	./bin/survey-data-dictionary --format json $(FLU_TRACK) > $@

survey-data-dictionary.txt: | bin/survey-data-dictionary
	./bin/survey-data-dictionary --format text $(FLU_TRACK) > $@

survey-flow.dot: survey-data-dictionary.json | bin/survey-flow
	./bin/survey-flow $^ > $@

survey-flow.pdf: survey-flow.dot
	dot -T pdf $^ > $@
