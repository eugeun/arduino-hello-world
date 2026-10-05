# Arduino CLI Makefile
SKETCH  := Blink
FQBN    ?= arduino:avr:uno
# Auto-detect the first USB serial port on macOS/Linux; override with `make upload PORT=...`
PORT    ?= $(firstword $(wildcard /dev/cu.usbmodem* /dev/cu.usbserial* /dev/ttyACM* /dev/ttyUSB*))
BUILD   := build
BAUD    ?= 9600
CLI     ?= arduino-cli
CORE    ?= arduino:avr@1.8.8

.PHONY: all core compile upload deploy monitor clean boards

all: compile

# One-time setup: install the AVR core
core:
	$(CLI) core update-index
	$(CLI) core install $(CORE)

compile:
	$(CLI) compile --fqbn $(FQBN) --build-path $(BUILD) $(SKETCH)

# Compile + flash
upload deploy: compile
	@test -n "$(PORT)" || (echo "No board found. Plug it in or run: make upload PORT=/dev/cu.usbmodemXXXX"; exit 1)
	$(CLI) upload --fqbn $(FQBN) --port $(PORT) --input-dir $(BUILD) $(SKETCH)

monitor:
	@test -n "$(PORT)" || (echo "No board found."; exit 1)
	$(CLI) monitor --port $(PORT) --config baudrate=$(BAUD)

boards:
	$(CLI) board list

clean:
	rm -rf $(BUILD)
