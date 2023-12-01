.SILENT:

# Compiler options
ERLC = erlc
ERL = erl
ERLFLAGS =

# List of program names (without the .erl extension)
PROGRAMS = p01 p02 p03 p04 p05 p06 p07 p08 p09 p10 p11
LAST = $(shell echo $(PROGRAMS) | awk '{print $$NF}')

# Targets
all: clean $(PROGRAMS)

# Compile and execure a program by name (given as an argument)
run:
	@echo "\033[32mCompiling and executing:\033[0m \033[1m$(P)\033[0m"
	$(ERLC) $(ERLFLAGS) $(P).erl
	$(ERL) -noshell -run $(P) start -run init stop

# Compile and execute last program
last: $(LAST)

# Compile and execute each program
$(PROGRAMS): %: %.erl
	@echo "\033[32mCompiling and executing:\033[0m \033[1m$<\033[0m"
	$(ERLC) $(ERLFLAGS) $<
	$(ERL) -noshell -run $@ start -run init stop

clean:
	rm -f *.crashdump *.dump *.beam *.o $(PROGRAMS)

# PHONY targets (these targets don't represent files)
.PHONY: all clean run last $(PROGRAMS)

