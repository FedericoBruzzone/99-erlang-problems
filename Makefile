# Compiler options
ERLC = erlc
ERL = erl
ERLFLAGS =

# List of program names (without the .erl extension)
PROGRAMS = p01

# Targets
all: clean $(PROGRAMS)

# Compile and execute each program
$(PROGRAMS): %: %.erl
	@echo "Compiling and executing $<"
	$(ERLC) $(ERLFLAGS) $<
	$(ERL) -noshell -run $@ start -run init stop

clean:
	rm -f *.crashdump *.dump *.beam *.o $(PROGRAMS)

# PHONY targets (these targets don't represent files)
.PHONY: all clean

