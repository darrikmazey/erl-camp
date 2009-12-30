
ERLC=erlc
ERLS=$(wildcard *.erl)
BEAMS=$(ERLS:.erl=.beam)

all: force
force: $(BEAMS)

%.beam: %.erl
	@echo [$(ERLC)] $<
	@$(ERLC) $<
