# Luma

**A small, readable programming language with a Python-like syntax, a bytecode VM, and a dedicated Windows editor.**

[English](README.md) | [Tiếng Việt](README.vi.md)

Luma is implemented in modern C++23 and designed around clear, indentation-based syntax inspired by Python 3. It can execute source files through a bytecode virtual machine or bundle them into standalone self-extracting executables — no C++ compiler needed at build time.

```luma
name = "Luma"
tasks = 3

if tasks > 0:
    print("Hello from " + name)

    for i in range(tasks):
        print("One task completed")
else:
    print("Nothing to do")
```

## Highlights

- Readable, Python-inspired syntax with indentation-based blocks
- Interpreter for fast development: `luma run`
- **Self-contained compilation**: `luma build` creates standalone .exe — no C++ compiler needed!
- **Bytecode VM** with self-extracting executables
- Python-like keywords: `if/elif/else`, `for/while`, `def`, `class`, `try/except`, `lambda`, `with/as`
- Numbers, text, booleans, lists, dicts, sets, tuples, functions, modules, and file I/O
- Ternary expressions, list comprehensions, augmented assignment (`+=`, `-=`, etc.)
- `//` floor division, `**` power, `is`, `in`, `not in`
- Legacy Luma keyword aliases (`let`, `show`, `when`, `func`, `repeat`, etc.)
- Shared standard library across interpreted and compiled programs
- Optional SDL2 graphics
- Dedicated Windows editor with syntax highlighting
- English and Vietnamese Windows installer

## Table of Contents

- [Getting Started](#getting-started)
- [Command-Line Usage](#command-line-usage)
- [Language Tour](#language-tour)
- [Loops](#loops)
- [Functions and Modules](#functions-and-modules)
- [New in v0.6](#new-in-v06)
- [Token Reference](#token-reference)
- [Standard Library](#standard-library)
- [Graphics](#graphics)
- [Luma Editor](#luma-editor)
- [Building from Source](#building-from-source)
- [Windows Installer](#windows-installer)
- [Architecture](#architecture)
- [Current Limitations](#current-limitations)

## Getting Started

Luma source files use the `.luma` extension.

### Build the project

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
```

### Run a program

```powershell
.\out\luma.exe run .\examples\welcome.luma
```

Or using CMake custom targets:

```powershell
cmake --build build --target run FILE=examples/welcome.luma
```

The explicit `run` command is optional:

```powershell
.\out\luma.exe .\examples\welcome.luma
```

### Compile to native executable

```powershell
.\out\luma.exe build .\examples\welcome.luma
.\examples\welcome.exe
```

Or using CMake custom targets:

```powershell
cmake --build build --target compile FILE=examples/welcome.luma
```

Choose a custom output file:

```powershell
.\out\luma.exe build .\examples\welcome.luma -o .\hello.exe
.\hello.exe
```

> No C++ compiler needed at build time! The VM is pre-compiled and bundled automatically.

## Command-Line Usage

```text
luma <file.luma>
luma run <file.luma>
luma build <file.luma> [-o output]
luma init [name]
luma info
luma --debug <file.luma>
luma --version
luma --help
```

| Command | Description |
| --- | --- |
| `luma file.luma` | Runs a program using the interpreter. |
| `luma run file.luma` | Explicit form of the interpreter command. |
| `luma build file.luma` | Bundles into a standalone executable. |
| `luma build file.luma -o app.exe` | Bundles with a custom output path. |
| `luma init [name]` | Creates a starter project with `main.luma`, `lib/`, and `README.md`. |
| `luma info` | Shows version, architecture, and all built-in functions. |
| `luma --debug file.luma` | Runs with timing breakdown (parse/compile/execute). |
| `luma --version` | Displays the installed version. |
| `luma --help` | Displays command-line help. |

### CMake Custom Targets

You can also use CMake custom targets for common tasks:

```powershell
cmake --build build --target run FILE=examples/welcome.luma
cmake --build build --target compile FILE=examples/welcome.luma
cmake --build build --target compile-run FILE=examples/welcome.luma
```

## Language Tour

### Values and variables

```luma
count = 10
price = 3.14
message = "Hello"
enabled = True
missing = None
values = [10, 20, 30]

count = 20
count += 5
values[0] = 100
```

The main value types are:

| Type | Examples |
| --- | --- |
| Number | `10`, `3.14`, `-5` |
| Text | `"Hello"`, `'Luma'` |
| Boolean | `True`, `False` |
| Empty value | `None` |
| List | `[1, 2, 3]` |
| Dict | `{"key": "value"}` |
| Set | `{1, 2, 3}` |
| Tuple | `(1, "a", True)` |
| Function | Native or user-defined callable |

### Output and input

```luma
print("Hello, World!")

name = input("Name: ")
age = number(input("Age: "))

print("Hello, " + name)
print("Next year: " + text(age + 1))
```

### Conditions

Luma v0.6 uses Python-style `if/elif/else`. Legacy `when/otherwise` is still accepted as an alias:

```luma
if score >= 80:
    print("Excellent")
elif score >= 50:
    print("Passed")
else:
    print("Failed")
```

Legacy form (still works):

```luma
when score >= 50:
    show "Passed"
otherwise:
    show "Failed"
```

### Ternary expressions

```luma
status = "pass" if score >= 50 else "fail"
print(status)
```

### Operators

| Category | Operators |
| --- | --- |
| Arithmetic | `+`, `-`, `*`, `/`, `//`, `%`, `**` |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=`, `//=`, `%=`, `**=` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `in` |
| Logic | `and`, `or`, `not` |
| Bitwise | `&`, `|`, `^`, `~`, `<<`, `>>` |
| Other | `@` (matrix multiply), `.` (attribute access), `:=` (walrus) |

### Lists

```luma
numbers = [5, 2, 8]

push(numbers, 1)
sort(numbers)

print(numbers)
print(numbers[0])
print(length(numbers))
print(sum(numbers))
```

### List comprehensions

```luma
items = [1, 2, 3, 4, 5]
result = [x for x in items if x > 2]
print(result)  # [3, 4, 5]

squares = [x * x for x in range(5)]
print(squares)  # [0, 1, 4, 9, 16]
```

### Dicts and sets

```luma
person = {"name": "Lan", "age": 25}
print(person["name"])

unique = {1, 2, 3, 2, 1}
print(unique)  # [1, 2, 3]
```

### Comments and blocks

Comments begin with `#`:

```luma
# Full-line comment
score = 100 # Inline comment
```

Blocks begin after `:` and use spaces for indentation. Tabs are not accepted for indentation.

```luma
if score > 0:
    print("Positive")
    print("Still inside the block")

print("Outside the block")
```

Short bodies and multiple statements may share a line:

```luma
if score > 0: print("Positive")
a = 1; b = 2; print(a + b)
```

## Loops

All loop forms support `break` and `continue`.

| Loop | Purpose |
| --- | --- |
| `for i in range(N):` | Executes a block N times (0 to N-1). |
| `for item in list:` | Iterates over a list. |
| `for i in start to stop:` | Counts inclusively from start to stop (legacy). |
| `for i in start to stop step N:` | Uses a custom step (legacy). |
| `while condition:` | Runs while a condition is true. |
| `while not condition:` | Runs until a condition becomes true. |
| `while True:` | Runs forever until `break`. |

```luma
for i in range(3):
    print("Hello")

for value in [10, 20, 30]:
    print(value)

for number in 1 to 5:
    print(number)

for number in 10 to 0 step -2:
    print(number)

count = 0
while count < 3:
    print(count)
    count += 1

while count == 5:
    count += 1

while True:
    print("Executed once")
    break
```

Loops may be nested:

```luma
for row in range(1, 4):
    for column in range(1, 4):
        print("Row " + text(row) + ", column " + text(column))
```

The counting loop includes its ending value. `range()` excludes its ending value:

```luma
for number in 1 to 5:       # 1, 2, 3, 4, 5
    print(number)

for number in range(1, 5):  # 1, 2, 3, 4
    print(number)
```

## Functions and Modules

### Functions

```luma
def square(number):
    return number ** 2

def greet(name):
    print("Hello, " + name)
    return

print(square(5))
greet("Luma")
```

Legacy `func` keyword also works:

```luma
func square(number):
    return number ** 2
```

### Lambda expressions

```luma
double = lambda x: x * 2
print(double(5))  # 10

add = lambda a, b: a + b
print(add(3, 4))  # 7
```

### Modules

Create `mathlib.luma`:

```luma
def cube(number):
    return number * number * number
```

Import it from another file:

```luma
import mathlib
print(cube(3))
```

Explicit relative paths are also supported:

```luma
import "modules/tools.luma"
```

Modules are resolved relative to the importing file and loaded once per program.

## New in v0.6

Luma v0.6 brings a major syntax upgrade toward Python compatibility while keeping backward compatibility with legacy keywords.

### Syntax changes

| Feature | v0.5 (old) | v0.6 (new) | Legacy alias |
| --- | --- | --- | --- |
| Variables | `let x = 5` | `x = 5` | `let` still works |
| Output | `show "hi"` | `print("hi")` | `show` still works |
| Conditions | `when ... otherwise` | `if ... elif ... else` | `when`/`otherwise` still work |
| Functions | `func name():` | `def name():` | `func` still works |
| Repeat | `repeat N:` | `for i in range(N):` | `repeat` still works |
| Until | `until cond:` | `while not cond:` | `until` still works |
| Forever | `forever:` | `while True:` | `forever` still works |
| True/False | `true` / `false` | `True` / `False` | lowercase still works |
| Nothing | `nothing` | `None` | `nothing` still works |

### New language features

- **Ternary expressions**: `x = 10 if True else 20`
- **List comprehensions**: `[x for x in items if x > 2]`
- **Lambda expressions**: `lambda x: x * 2`
- **Floor division**: `7 // 2` → `3`
- **Power operator**: `2 ** 10` → `1024`
- **Identity/in operators**: `x is None`, `x in list`
- **Augmented assignment**: `x += 1`, `x //= 2`, `x **= 3`
- **Class definitions**: `class Dog:` (stub — body compiles as function)
- **Try/except/finally**: parsed but not yet compiled
- **With/as**: parsed but not yet compiled
- **Decorators**: `@decorator` (parsed)
- **Increment/decrement**: `x++`, `x--`
- **Empty lists**: `[]` (fixed in parser)
- **Dict/set/tuple literals**: `{"k": v}`, `{1, 2}`, `(1, 2)`

## Token Reference

### Structural tokens

These are generated by the lexer and are not normally written directly:

| Token | Purpose |
| --- | --- |
| `end` | End of source file |
| `newline` | End of line or statement |
| `indent` | Beginning of an indented block |
| `dedent` | End of an indented block |

### Literals and names

| Token | Example |
| --- | --- |
| `identifier` | `name`, `my_value` |
| `number` | `10`, `3.14` |
| `text` | `"Hello"`, `'Hello'` |
| Boolean | `True`, `False` |
| Empty value | `None` |

### Keywords

```text
False None True and as assert async await break class
continue def del elif else except finally for from
global if import in is lambda nonlocal not or pass
raise return try while with yield
```

Legacy aliases (still accepted):

```text
let show when otherwise repeat true false nothing
func until forever to step
```

### Delimiters and operators

```text
( ) [ ] { } : ; , . @ -> ... :=
+ - * ** / // % &
| ^ ~ << >>
= += -= *= /= //= %= **= &= |= ^= <<= >>=
== != < <= > >= is in not
```

### Operator precedence

From highest to lowest:

1. Parentheses, literals, names, calls, and indexing
2. Power: `**`
3. Unary operators: `-`, `+`, `~`, `not`
4. Matrix multiply: `@`
5. Multiplication, division, floor division, remainder: `*`, `/`, `//`, `%`
6. Addition and subtraction: `+`, `-`
7. Bitwise shifts: `<<`, `>>`
8. Bitwise AND: `&`
9. Bitwise XOR: `^`
10. Bitwise OR: `|`
11. Comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `in`
12. Logical NOT: `not`
13. Logical AND: `and`
14. Logical OR: `or`
15. Conditional: `a if cond else b`
16. Lambda: `lambda args: expr`
17. Walrus: `x := expr`

## Standard Library

Built-in functions are globally available in interpreted and compiled programs; no import is required.

### Core and conversion

| Function | Description |
| --- | --- |
| `print(value)` | Prints a value followed by a newline. `show` is also accepted. |
| `length(value)` | Returns the length of text or a list. |
| `text(value)` | Converts a value to displayable text. |
| `number(value)` | Converts numeric text to a number. |
| `type_of(value)` | Returns the runtime type name. |
| `is_number(value)` | Returns `True` if the value is a number. |
| `is_text(value)` | Returns `True` if the value is text. |
| `is_list(value)` | Returns `True` if the value is a list. |
| `is_nothing(value)` | Returns `True` if the value is `None`. |
| `assert(condition)` | Raises an error if condition is false. |
| `assert(condition, message)` | Raises an error with a custom message. |

### Mathematics

| Function | Description |
| --- | --- |
| `abs(x)` | Absolute value |
| `sqrt(x)` | Square root |
| `floor(x)` | Rounds downward |
| `ceil(x)` | Rounds upward |
| `round(x)` | Rounds to the nearest integer |
| `pow(base, exponent)` | Raises a value to a power |
| `min(a, b)`, `max(a, b)` | Selects the smaller or larger value |
| `random()` | Random decimal from `0.0` to `1.0` |
| `clamp(value, low, high)` | Restricts a value to a range |
| `sum(list)` | Adds all numbers in a list |
| `product(list)` | Multiplies all numbers in a list |
| `average(list)` | Computes the arithmetic mean |
| `min_of(list)` | Returns the minimum value in a list |
| `max_of(list)` | Returns the maximum value in a list |

### Lists and ranges

| Function | Description |
| --- | --- |
| `push(list, value)` | Appends a value in place. |
| `pop(list)` | Removes and returns the last value. |
| `sort(list)` | Sorts a list in place. |
| `sorted(list)` | Returns a new sorted list (non-mutating). |
| `reverse(list)` | Reverses a list in place. |
| `reversed(list)` | Returns a new reversed list (non-mutating). |
| `unique(list)` | Returns a list with duplicates removed. |
| `flatten(list)` | Flattens a nested list one level. |
| `count(list, value)` | Counts occurrences of a value in a list. |
| `range(stop)` | Builds `[0, stop)` with a step of 1. |
| `range(start, stop)` | Builds `[start, stop)` with a step of 1. |
| `range(start, stop, step)` | Builds an exclusive range with a custom step. |
| `contains(value, item)` | Checks text or list membership. |
| `find(value, item)` | Returns a zero-based index, or `-1`. |
| `slice(value, start, stop)` | Returns an exclusive slice of text or a list. |
| `enumerate(list)` | Returns `[[0, a], [1, b], ...]` pairs. |
| `zip(list1, list2)` | Combines two lists into `[[a, x], [b, y], ...]`. |
| `any(list)` | Returns `True` if any element is truthy. |
| `all(list)` | Returns `True` if all elements are truthy. |

### Text

| Function | Description |
| --- | --- |
| `join(list, separator)` | Joins list values into text. |
| `split(text, separator)` | Splits text into a list. |
| `upper(text)`, `lower(text)` | Changes letter case. |
| `trim(text)` | Removes surrounding whitespace. |
| `replace(text, old, new)` | Replaces all matching text. |
| `starts_with(text, prefix)` | Tests a prefix. |
| `ends_with(text, suffix)` | Tests a suffix. |
| `char_at(text, index)` | Returns the character at a given index. |
| `to_char(code)` | Converts an ASCII code point to a character. |
| `ord(text)` | Returns the ASCII code of the first character. |

### Console, files, and time

| Function | Description |
| --- | --- |
| `input()` / `input(prompt)` | Reads a line from standard input. |
| `read_file(path)` | Reads an entire file as text. |
| `write_file(path, value)` | Replaces a file with the displayed value. |
| `sleep_ms(milliseconds)` | Pauses the current thread. |
| `now_ms()` | Returns the current system time in milliseconds. |

## Graphics

Graphics require SDL2 support when Luma is built.

| Function | Description |
| --- | --- |
| `window_open(title, width, height)` | Opens a window and returns its ID. |
| `window_should_close(id)` | Processes events and reports a close request. |
| `window_clear(id, r, g, b)` | Clears the drawing buffer. |
| `window_set_pixel(id, x, y, r, g, b)` | Draws one pixel. |
| `window_fill_rect(id, x, y, w, h, r, g, b)` | Draws a filled rectangle. |
| `window_draw_line(id, x1, y1, x2, y2, r, g, b)` | Draws a line. |
| `window_present(id)` | Presents the drawing buffer. |
| `window_close(id)` | Destroys the window. |

```luma
window = window_open("Luma", 640, 480)

if window != -1:
    while not window_should_close(window):
        window_clear(window, 20, 20, 30)
        window_fill_rect(window, 100, 100, 120, 80, 0, 150, 255)
        window_present(window)
        sleep_ms(16)

    window_close(window)
```

Without SDL2, window functions degrade safely and print a one-time warning.

## Luma Editor

Windows builds include `luma-edit.exe`, a lightweight editor with a **dark theme** dedicated to Luma.

Features:

- Dark theme with syntax highlighting (keywords, strings, numbers, comments, built-in functions)
- New, Open, Save, and Save As
- UTF-8 file support
- Unsaved-change protection
- Four-space Tab insertion
- Automatic indentation after lines ending in `:`
- Status bar with file, encoding, line/column, and version
- **Find** (Ctrl+F) and **Replace** (Ctrl+H) with wrap-around search
- **Go to Line** (Ctrl+G)
- Word wrap toggle
- **F5** to run on VM, **F6** to build standalone .exe, **F7** to run last built
- `.luma` file association through the installer

```powershell
.\out\luma-edit.exe
.\out\luma-edit.exe .\examples\welcome.luma
```

| Shortcut | Action |
| --- | --- |
| `Ctrl+N` | New file |
| `Ctrl+O` | Open file |
| `Ctrl+S` | Save file |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Ctrl+G` | Go to line |
| `F5` | Run on VM |
| `F6` | Build standalone EXE |
| `F7` | Run last built |

## Building from Source

### Requirements

- Windows
- CMake 3.25 or newer
- A C++23 compiler: MinGW-w64 or MSVC
- Optional: SDL2 development files for graphics
- Optional: Inno Setup 6 for creating the installer

### MinGW-w64

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
```

Executables are written to `out/`:

```text
out/luma.exe
out/luma_vm.exe
out/luma-edit.exe
out/luma_tests.exe
```

If SDL2 is installed through MSYS2:

```powershell
pacman -S mingw-w64-x86_64-SDL2
```

Configure the project again after installing SDL2.

### CMake Custom Targets

For convenience, the project defines these custom targets:

```powershell
# Run a program on the VM
cmake --build build --target run FILE=examples/welcome.luma

# Compile to native .exe
cmake --build build --target compile FILE=examples/welcome.luma

# Compile then run (requires two steps)
cmake --build build --target compile FILE=examples/welcome.luma
.\out\welcome.exe
```

The raw commands the targets run:

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --target luma luma_vm luma_edit
ctest --test-dir build --output-on-failure -C Release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" .\install.iss
.\out\luma.exe run .\examples\welcome.luma
.\out\luma.exe build .\examples\welcome.luma -o .\out\welcome.exe
.\out\welcome.exe
```

## Windows Installer

The repository includes `install.iss` for Inno Setup 6.

Build and test the project first, then compile the installer:

```powershell
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" ".\install.iss"
```

Output:

```text
installer/luma-setup.exe
```

Installer features:

- English and Vietnamese setup interfaces
- Installs luma.exe (CLI), luma_vm.exe (VM stub), and luma-edit.exe (editor)
- No C++ compiler needed to build .luma files into .exe
- Optional system or user PATH registration
- Optional desktop shortcut
- Optional `.luma` file association
- Examples and documentation (English + Vietnamese)
- PATH cleanup during uninstall

## Architecture

Luma v0.6 uses a **Bytecode VM with Self-Extracting Executables**:

```text
Source (.luma) -> Lexer -> Parser -> AST -> Bytecode Compiler -> Bytecode
                                                                    |
                       +--------------------------------------------+
                       |                                            |
                Interpreter Mode                            Build Mode
                       |                                            |
                       v                                            v
              Virtual Machine (VM)                    Bundle VM + Bytecode -> .exe
              (executes directly)                     (self-contained executable)
                                                        No C++ compiler needed!
```

### How `luma build` Works

1. **Compile source to bytecode** (same as interpreter mode)
2. **Serialize bytecode** to compact binary format
3. **Append bytecode** to pre-compiled VM stub (`luma_vm.exe`)
4. **Output .exe** is fully self-contained — runs on any Windows machine!

```
┌─────────────────────────┐
│   Pre-compiled VM Stub  │  (luma_vm.exe)
│   - Reads bytecode      │
│   - Runs on VM          │
├─────────────────────────┤
│   Magic: "LUMA"         │  (4 bytes)
│   Bytecode size         │  (4 bytes)
│   Bytecode data         │  (N bytes)
└─────────────────────────┘
```

| Directory | Responsibility |
| --- | --- |
| `include/luma/` | Public C++ interfaces |
| `src/lex/` | Indentation-aware tokenization with Python-like keywords |
| `src/parse/` | Recursive-descent parsing (Python-like syntax + legacy aliases) |
| `src/ast/` | Abstract syntax tree (20+ expression and statement types) |
| `src/bytecode/` | Bytecode generation and serialization |
| `src/runtime/` | Runtime values, operations, and VM |
| `src/stdlib/` | Shared built-in functions |
| `src/app/` | CLI, bundler, and editor |
| `examples/` | Example Luma programs |
| `tests/` | C++ regression tests |

## Current Limitations

- SDL2 is required for visible graphics windows.
- Tabs cannot be used for source indentation.
- Built .exe files contain the VM runtime (slightly larger than pure native code).
- Self-extracting .exe approach requires the VM stub to be present during build.
- `class`, `try/except`, `with/as` are parsed but not yet fully compiled.
- Dict/Set/Tuple types compile as lists internally.
- Editor autocomplete is planned for a future release.

## Examples

- [`examples/welcome.luma`](examples/welcome.luma) — basic syntax
- [`examples/functions.luma`](examples/functions.luma) — functions, lists, and loops
- [`examples/guess_number.luma`](examples/guess_number.luma) — input and control flow
- [`examples/import_demo.luma`](examples/import_demo.luma) — modules
- [`examples/demo.luma`](examples/demo.luma) — full feature demonstration
- [`examples/window_demo.luma`](examples/window_demo.luma) — SDL2 graphics

---

Created in Vietnam with a focus on readable syntax, practical native compilation, and an approachable learning experience.
