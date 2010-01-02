
ERL=erl
ERLC=erlc
ERLS=$(wildcard src/*.erl)
BEAMS=$(ERLS:.erl=.beam)

all: force
force: compile shell
compile: $(BEAMS)

%.beam: %.erl
	@echo [$(ERLC)] $<
	@$(ERLC) -o ebin/ $<

clean:
	rm -f ebin/*.beam

shell:
	$(ERL) -pa ebin/
