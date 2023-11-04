.SILENT:

# Compiler options
ERLC = erlc
ERL = erl
ERLFLAGS =

# List of program names (without the .erl extension)
PROGRAMS = p01 p02 p03 p04 p05 p06 p07
LAST = $(shell echo $(PROGRAMS) | awk '{print $$NF}')

# Targets
all: clean $(PROGRAMS)

# Compile and execute last program
last: $(LAST)

# Compile and execute each program
$(PROGRAMS): %: %.erl
	@echo "\e[32mCompiling and executing:\e[0m \e[1m$<\e[0m"
	$(ERLC) $(ERLFLAGS) $<
	$(ERL) -noshell -run $@ start -run init stop

clean:
	rm -f *.crashdump *.dump *.beam *.o $(PROGRAMS)

# PHONY targets (these targets don't represent files)
.PHONY: all clean

