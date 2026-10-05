# Blinking LED (Arduino + VS Code + arduino-cli)

Blinks the LED on pin 13 once per second. It is built and flashed with `arduino-cli`, driven by a `Makefile`, and edited in VS Code.

The Makefile targets an Arduino Uno (`arduino:avr:uno`). Smraza kits are Uno-compatible.

## Project layout

```
.
├── Makefile                      build / upload / monitor / clean
├── Blink/Blink.ino               the sketch (folder name must match the .ino name)
└── .vscode/
    ├── tasks.json                Build / Upload / Serial Monitor / Clean tasks
    ├── c_cpp_properties.json     IntelliSense configuration
    └── settings.json
```

## Make targets

| Command        | What it does                                              |
| -------------- | --------------------------------------------------------- |
| `make core`    | One-time: installs the `arduino:avr` board core           |
| `make`         | Compiles the sketch into `build/`                         |
| `make upload`  | Compiles and flashes the board (alias: `make deploy`)     |
| `make monitor` | Opens the serial monitor (default 9600 baud)              |
| `make boards`  | Lists connected boards and their ports                    |
| `make clean`   | Deletes `build/`                                          |

Variables you can override on the command line:

```sh
make upload PORT=/dev/cu.usbserial-1420   # choose the serial port
make FQBN=arduino:avr:nano                # use a different board
make monitor BAUD=115200
```

---

## macOS

### One-time setup

1. Install Homebrew, then the tools:
   ```sh
   brew install arduino-cli make
   ```
   (macOS already ships a `make`, so installing it is optional.)
2. **Apple Silicon (M1/M2/M3/M4) only:** install Rosetta 2. The Arduino AVR compiler is Intel-only, and without Rosetta the build fails with `bad CPU type in executable`.
   ```sh
   softwareupdate --install-rosetta --agree-to-license
   ```
   Intel Macs can skip this step.
3. Install the AVR board core (downloads the compiler and `Arduino.h`):
   ```sh
   make core
   ```
4. In VS Code, install the **C/C++** extension (Microsoft).
5. Clone boards often use a CH340 USB chip. If `make boards` shows no port after you plug the board in, install the CH340 driver. Recent macOS versions usually don't need it.

### Build and deploy

1. Plug in the board over USB.
2. From the project folder:
   ```sh
   make            # build only
   make upload     # build and flash
   ```
   The port is detected automatically (`/dev/cu.usbmodem*` or `/dev/cu.usbserial*`). If it picks the wrong one, run `make boards` and pass `PORT=...`.

In VS Code, `Cmd+Shift+B` builds. Upload, Serial Monitor and Clean are under **Terminal → Run Task**.

### IntelliSense

`.vscode/c_cpp_properties.json` points at `~/Library/Arduino15/...`. If you update the AVR core or compiler, update the version numbers in that file (`1.8.8` for the core, `7.3.0-atmel3.6.1-arduino7` for avr-gcc). Then run **C/C++: Reload IntelliSense Window**.

---

## Microsoft Windows

> The Makefile and VS Code configuration were developed and tested on macOS. The Windows steps below are not tested. They follow standard arduino-cli and GNU Make behavior on Windows.

### One-time setup

1. Install the tools. Using PowerShell with winget:
   ```powershell
   winget install ArduinoSA.CLI
   winget install Git.Git
   winget install ezwinports.make
   ```
   Git for Windows provides **Git Bash**, which supplies the `sh`, `test` and `rm` commands the Makefile uses. Reopen your terminal afterwards so the new tools are on `PATH`.
2. Install the USB driver if Windows doesn't recognize the board. Clone boards with a CH340 chip need the CH340 driver. Check **Device Manager → Ports (COM & LPT)** for the board.
3. Install the AVR board core. Open **Git Bash** in the project folder:
   ```sh
   make core
   ```
4. In VS Code, install the **C/C++** extension (Microsoft). To make Git Bash the integrated terminal, open **Terminal → New Terminal** and pick **Git Bash** from the dropdown.

### Build and deploy

1. Plug in the board and find its COM port:
   ```sh
   make boards
   ```
2. From Git Bash in the project folder:
   ```sh
   make                       # build only
   make upload PORT=COM3      # build and flash (use your COM port)
   make monitor PORT=COM3
   ```
   Always pass `PORT=COMx` on Windows. Automatic port detection only looks for macOS/Linux device names.

The VS Code tasks in `.vscode/tasks.json` run plain `make upload`. On Windows, either add `PORT=COMx` to that command in `tasks.json`, or run the make commands from the terminal.

### IntelliSense

`.vscode/c_cpp_properties.json` contains macOS paths. On Windows, replace `${env:HOME}/Library/Arduino15` with `${env:LOCALAPPDATA}/Arduino15` in every path, and change the avr-gcc version folder if yours differs. Then run **C/C++: Reload IntelliSense Window**.

---

## Troubleshooting

| Symptom                                          | Fix                                                                                   |
| ------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `bad CPU type in executable` (Apple Silicon)     | Install Rosetta 2 (see macOS step 2)                                                  |
| `No board found`                                 | Check the cable (it must carry data), run `make boards`, pass `PORT=...`              |
| `Platform 'arduino:avr' not found`               | Run `make core`                                                                       |
| `cannot open source file "Arduino.h"` in VS Code | Run `make core`, then check the version numbers in `.vscode/c_cpp_properties.json`    |
| Upload fails with a permission or busy error     | Close the serial monitor and any other program using the port                         |
