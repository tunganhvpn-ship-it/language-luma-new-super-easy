# Luma

**A small, readable programming language with an interpreter, a native compiler, and a dedicated Windows editor.**

[English](README.md) | [Tiếng Việt](README.vi.md)

Luma is implemented in modern C++23 and designed around clear, indentation-based syntax. It can execute source files through a bytecode virtual machine or translate them to C++ and produce standalone native executables.

```luma
let name = "Luma"
let tasks = 3

when tasks > 0:
    show "Hello from " + name

    repeat tasks:
        show "One task completed"
otherwise:
    show "Nothing to do"
```

## Highlights

- Readable, Python-inspired indentation
- Interpreter for fast development: `luma run`
- Native compilation to standalone executables: `luma build`
- Numbers, text, booleans, lists, functions, modules, and file I/O
- Conditions and several loop styles
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

Run an example:

```powershell
.\out\luma.exe run .\examples\welcome.luma
```

The explicit `run` command is optional:

```powershell
.\out\luma.exe .\examples\welcome.luma
```

Compile a Luma program to a native executable:

```powershell
.\out\luma.exe build .\examples\welcome.luma
.\examples\welcome.exe
```

Choose a custom output file:

```powershell
.\out\luma.exe build .\examples\welcome.luma -o .\hello.exe
.\hello.exe
```

> Native compilation requires a compatible C++ compiler such as MinGW-w64 `g++`.

## Command-Line Usage

```text
luma <file.luma>
luma run <file.luma>
luma build <file.luma> [-o output]
luma --version
luma --help
```

| Command | Description |
| --- | --- |
| `luma file.luma` | Runs a program using the interpreter. |
| `luma run file.luma` | Explicit form of the interpreter command. |
| `luma build file.luma` | Compiles a program to a native executable. |
| `luma build file.luma -o app.exe` | Compiles with a custom output path. |
| `luma --version` | Displays the installed version. |
| `luma --help` | Displays command-line help. |

`luma build` also writes `<file>.luma.generated.cpp` next to the source file so the generated C++ can be inspected.

## Language Tour

### Values and variables

```luma
let count = 10
let price = 3.14
let message = "Hello"
let enabled = true
let missing = nothing
let values = [10, 20, 30]

count = 20
count += 5
values[0] = 100
```

The main value types are:

| Type | Examples |
| --- | --- |
| Number | `10`, `3.14`, `-5` |
| Text | `"Hello"`, `'Luma'` |
| Boolean | `true`, `false` |
| Empty value | `nothing` |
| List | `[1, 2, 3]` |
| Function | Native or user-defined callable |

### Output and input

```luma
show "Hello, World!"

let name = input("Name: ")
let age = number(input("Age: "))

show "Hello, " + name
show "Next year: " + text(age + 1)
```

### Conditions

Luma supports its own `when` syntax and Python-style alternatives:

```luma
when score >= 50:
    show "Passed"
otherwise:
    show "Failed"
```

```luma
if score >= 80:
    show "Excellent"
elif score >= 50:
    show "Passed"
else:
    show "Failed"
```

### Operators

| Category | Operators |
| --- | --- |
| Arithmetic | `+`, `-`, `*`, `/`, `%`, `**` |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=`, `%=` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| Logic | `and`, `or`, `not` |

### Lists

```luma
let numbers = [5, 2, 8]

push(numbers, 1)
sort(numbers)

show numbers
show numbers[0]
show length(numbers)
show sum(numbers)
```

### Comments and blocks

Comments begin with `#`:

```luma
# Full-line comment
let score = 100 # Inline comment
```

Blocks begin after `:` and use spaces for indentation. Tabs are not accepted for indentation.

```luma
if score > 0:
    show "Positive"
    show "Still inside the block"

show "Outside the block"
```

Short bodies and multiple statements may share a line:

```luma
if score > 0: show "Positive"
let a = 1; let b = 2; show a + b
```

## Loops

All loop forms support `break` and `continue`.

| Loop | Purpose |
| --- | --- |
| `repeat N:` | Executes a block a known number of times. |
| `for item in list:` | Iterates over a list. |
| `for i in start to stop:` | Counts inclusively from start to stop. |
| `for i in start to stop step amount:` | Uses a custom positive or negative step. |
| `while condition:` | Runs while a condition is true. |
| `until condition:` | Runs until a condition becomes true. |
| `forever:` | Runs until explicitly stopped with `break`. |

```luma
repeat 3:
    show "Hello"

for value in [10, 20, 30]:
    show value

for number in 1 to 5:
    show number

for number in 10 to 0 step -2:
    show number

let count = 0
while count < 3:
    show count
    count += 1

until count == 5:
    count += 1

forever:
    show "Executed once"
    break
```

Loops may be nested:

```luma
for row in 1 to 3:
    for column in 1 to 3:
        show "Row " + text(row) + ", column " + text(column)
```

The counting loop includes its ending value. `range()` excludes its ending value:

```luma
for number in 1 to 5:       # 1, 2, 3, 4, 5
    show number

for number in range(1, 5):  # 1, 2, 3, 4
    show number
```

## Functions and Modules

### Functions

```luma
func square(number):
    return number ** 2

func greet(name):
    show "Hello, " + name
    return

show square(5)
greet("Luma")
```

### Modules

Create `mathlib.luma`:

```luma
func cube(number):
    return number * number * number
```

Import it from another file:

```luma
import mathlib
show cube(3)
```

Explicit relative paths are also supported:

```luma
import "modules/tools.luma"
```

Modules are resolved relative to the importing file and loaded once per program.

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
| Boolean | `true`, `false` |
| Empty value | `nothing` |

### Keywords

```text
let show when otherwise repeat true false nothing
and or not if elif else func return for in to step
while until forever break continue import pass
```

### Delimiters and operators

```text
( ) [ ] : ; ,
+ - * ** / %
= += -= *= /= %=
== != < <= > >=
```

A standalone `!` is not supported. Use `not` for logical negation and `!=` for inequality.

### Operator precedence

From highest to lowest:

1. Parentheses, literals, names, calls, and indexing
2. Power: `**`
3. Unary operators: `-`, `not`
4. Multiplication, division, remainder: `*`, `/`, `%`
5. Addition and subtraction: `+`, `-`
6. Comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`
7. Logical AND: `and`
8. Logical OR: `or`

## Standard Library

Built-in functions are globally available in interpreted and compiled programs; no import is required.

### Core and conversion

| Function | Description |
| --- | --- |
| `length(value)` | Returns the length of text or a list. |
| `text(value)` | Converts a value to displayable text. |
| `number(value)` | Converts numeric text to a number. |
| `type_of(value)` | Returns the runtime type name. |

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

### Lists and ranges

| Function | Description |
| --- | --- |
| `push(list, value)` | Appends a value in place. |
| `pop(list)` | Removes and returns the last value. |
| `sort(list)` | Sorts a list in place. |
| `reverse(list)` | Reverses a list in place. |
| `range(stop)` | Builds `[0, stop)` with a step of 1. |
| `range(start, stop)` | Builds `[start, stop)` with a step of 1. |
| `range(start, stop, step)` | Builds an exclusive range with a custom step. |
| `contains(value, item)` | Checks text or list membership. |
| `find(value, item)` | Returns a zero-based index, or `-1`. |
| `slice(value, start, stop)` | Returns an exclusive slice of text or a list. |

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
let window = window_open("Luma", 640, 480)

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

Windows builds include `luma-edit.exe`, a lightweight editor dedicated to Luma.

Features:

- Syntax highlighting for keywords, strings, numbers, and comments
- New, Open, Save, and Save As
- UTF-8 file support
- Unsaved-change protection
- Four-space Tab insertion
- Automatic indentation after lines ending in `:`
- Status bar with file state, line, and column
- `F5` to save and run
- `F6` to save and compile
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
| `F5` | Run program |
| `F6` | Compile program |

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
out/luma-edit.exe
out/luma_tests.exe
```

If SDL2 is installed through MSYS2:

```powershell
pacman -S mingw-w64-x86_64-SDL2
```

Configure the project again after installing SDL2.

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
- Compiler and editor installation
- Optional system or user PATH registration
- Optional desktop shortcut
- Optional `.luma` file association
- Examples, headers, runtime sources, and generated build configuration
- PATH cleanup during uninstall

## Architecture

Luma source code flows through:

```text
Source -> Lexer -> Parser -> AST
                         |-> Bytecode compiler -> Virtual machine
                         `-> C++ backend -> Native C++ compiler -> Executable
```

| Directory | Responsibility |
| --- | --- |
| `include/luma/` | Public C++ interfaces |
| `src/lex/` | Indentation-aware tokenization |
| `src/parse/` | Recursive-descent parsing |
| `src/ast/` | Abstract syntax tree |
| `src/bytecode/` | Bytecode generation |
| `src/runtime/` | Runtime values, operations, and VM |
| `src/stdlib/` | Shared built-in functions |
| `src/app/` | CLI, native backend, and editor |
| `examples/` | Example Luma programs |
| `tests/` | C++ regression tests |

## Current Limitations

- Native compilation requires a compatible C++ compiler.
- SDL2 is required for visible graphics windows.
- In native mode, functions must currently be declared at the top level.
- Indirect function calls through variables currently work only in interpreted mode.
- Tabs cannot be used for source indentation.

## Examples

- [`examples/welcome.luma`](examples/welcome.luma) — basic syntax
- [`examples/functions.luma`](examples/functions.luma) — functions, lists, and loops
- [`examples/guess_number.luma`](examples/guess_number.luma) — input and control flow
- [`examples/import_demo.luma`](examples/import_demo.luma) — modules
- [`examples/window_demo.luma`](examples/window_demo.luma) — SDL2 graphics

---

Created in Vietnam with a focus on readable syntax, practical native compilation, and an approachable learning experience.


# Luma

**Ngôn ngữ lập trình nhỏ gọn, dễ đọc, có trình thông dịch, trình biên dịch native và code editor riêng cho Windows.**

[English](README.md) | [Tiếng Việt](README.vi.md)

Luma được xây dựng bằng C++23 hiện đại và hướng tới cú pháp rõ ràng, dùng thụt dòng để tạo khối lệnh. Luma có thể chạy mã nguồn bằng máy ảo bytecode hoặc chuyển mã sang C++ để tạo file thực thi native độc lập.

```luma
let name = "Luma"
let tasks = 3

when tasks > 0:
    show "Xin chào từ " + name

    repeat tasks:
        show "Đã hoàn thành một công việc"
otherwise:
    show "Không có công việc"
```

## Điểm nổi bật

- Cú pháp dễ đọc, lấy cảm hứng từ Python
- Trình thông dịch để phát triển nhanh: `luma run`
- Biên dịch native thành file thực thi độc lập: `luma build`
- Hỗ trợ số, văn bản, boolean, danh sách, hàm, module và file
- Nhiều kiểu điều kiện và vòng lặp
- Thư viện chuẩn dùng chung giữa chế độ thông dịch và biên dịch
- Đồ họa SDL2 tùy chọn
- Code editor riêng cho Windows có tô màu cú pháp
- Trình cài đặt Windows hỗ trợ tiếng Anh và tiếng Việt

## Mục lục

- [Bắt đầu](#bắt-đầu)
- [Lệnh dòng lệnh](#lệnh-dòng-lệnh)
- [Tổng quan ngôn ngữ](#tổng-quan-ngôn-ngữ)
- [Vòng lặp](#vòng-lặp)
- [Hàm và module](#hàm-và-module)
- [Danh sách token](#danh-sách-token)
- [Thư viện chuẩn](#thư-viện-chuẩn)
- [Đồ họa](#đồ-họa)
- [Luma Editor](#luma-editor)
- [Build từ mã nguồn](#build-từ-mã-nguồn)
- [Trình cài đặt Windows](#trình-cài-đặt-windows)
- [Kiến trúc](#kiến-trúc)
- [Giới hạn hiện tại](#giới-hạn-hiện-tại)

## Bắt đầu

File mã nguồn Luma sử dụng phần mở rộng `.luma`.

Chạy một ví dụ:

```powershell
.\out\luma.exe run .\examples\welcome.luma
```

Có thể bỏ từ khóa `run`:

```powershell
.\out\luma.exe .\examples\welcome.luma
```

Biên dịch chương trình Luma thành file native:

```powershell
.\out\luma.exe build .\examples\welcome.luma
.\examples\welcome.exe
```

Chọn file đầu ra:

```powershell
.\out\luma.exe build .\examples\welcome.luma -o .\hello.exe
.\hello.exe
```

> Biên dịch native yêu cầu trình biên dịch C++ tương thích, ví dụ MinGW-w64 `g++`.

## Lệnh dòng lệnh

```text
luma <file.luma>
luma run <file.luma>
luma build <file.luma> [-o output]
luma --version
luma --help
```

| Lệnh | Công dụng |
| --- | --- |
| `luma file.luma` | Chạy chương trình bằng trình thông dịch. |
| `luma run file.luma` | Dạng đầy đủ của lệnh thông dịch. |
| `luma build file.luma` | Biên dịch chương trình thành file native. |
| `luma build file.luma -o app.exe` | Biên dịch với đường dẫn đầu ra tùy chọn. |
| `luma --version` | Hiển thị phiên bản đã cài. |
| `luma --help` | Hiển thị trợ giúp dòng lệnh. |

`luma build` cũng tạo file `<file>.luma.generated.cpp` bên cạnh mã nguồn để bạn có thể xem mã C++ được sinh ra.

## Tổng quan ngôn ngữ

### Giá trị và biến

```luma
let count = 10
let price = 3.14
let message = "Xin chào"
let enabled = true
let missing = nothing
let values = [10, 20, 30]

count = 20
count += 5
values[0] = 100
```

Các kiểu giá trị chính:

| Kiểu | Ví dụ |
| --- | --- |
| Số | `10`, `3.14`, `-5` |
| Văn bản | `"Xin chào"`, `'Luma'` |
| Boolean | `true`, `false` |
| Giá trị rỗng | `nothing` |
| Danh sách | `[1, 2, 3]` |
| Hàm | Hàm native hoặc hàm do người dùng định nghĩa |

### Xuất và nhập dữ liệu

```luma
show "Xin chào!"

let name = input("Tên: ")
let age = number(input("Tuổi: "))

show "Xin chào, " + name
show "Năm sau: " + text(age + 1)
```

### Điều kiện

Luma hỗ trợ cú pháp `when` riêng và cú pháp kiểu Python:

```luma
when score >= 50:
    show "Đạt"
otherwise:
    show "Chưa đạt"
```

```luma
if score >= 80:
    show "Xuất sắc"
elif score >= 50:
    show "Đạt"
else:
    show "Chưa đạt"
```

### Toán tử

| Nhóm | Toán tử |
| --- | --- |
| Số học | `+`, `-`, `*`, `/`, `%`, `**` |
| Gán | `=`, `+=`, `-=`, `*=`, `/=`, `%=` |
| So sánh | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| Logic | `and`, `or`, `not` |

### Danh sách

```luma
let numbers = [5, 2, 8]

push(numbers, 1)
sort(numbers)

show numbers
show numbers[0]
show length(numbers)
show sum(numbers)
```

### Chú thích và khối lệnh

Chú thích bắt đầu bằng `#`:

```luma
# Chú thích cả dòng
let score = 100 # Chú thích cuối dòng
```

Khối lệnh bắt đầu sau dấu `:` và dùng dấu cách để thụt dòng. Không dùng tab để thụt dòng.

```luma
if score > 0:
    show "Số dương"
    show "Vẫn ở trong khối"

show "Ngoài khối"
```

Câu lệnh ngắn và nhiều câu lệnh có thể viết cùng dòng:

```luma
if score > 0: show "Số dương"
let a = 1; let b = 2; show a + b
```

## Vòng lặp

Mọi kiểu vòng lặp đều hỗ trợ `break` và `continue`.

| Vòng lặp | Công dụng |
| --- | --- |
| `repeat N:` | Chạy khối lệnh một số lần xác định. |
| `for item in list:` | Duyệt qua danh sách. |
| `for i in start to stop:` | Đếm từ đầu đến cuối, bao gồm cả hai đầu. |
| `for i in start to stop step amount:` | Dùng bước nhảy dương hoặc âm tùy chọn. |
| `while condition:` | Chạy khi điều kiện còn đúng. |
| `until condition:` | Chạy cho đến khi điều kiện đúng. |
| `forever:` | Chạy đến khi được dừng bằng `break`. |

```luma
repeat 3:
    show "Xin chào"

for value in [10, 20, 30]:
    show value

for number in 1 to 5:
    show number

for number in 10 to 0 step -2:
    show number

let count = 0
while count < 3:
    show count
    count += 1

until count == 5:
    count += 1

forever:
    show "Chạy một lần"
    break
```

Có thể lồng nhiều vòng lặp:

```luma
for row in 1 to 3:
    for column in 1 to 3:
        show "Hàng " + text(row) + ", cột " + text(column)
```

Vòng lặp đếm bao gồm giá trị kết thúc, còn `range()` loại trừ giá trị kết thúc:

```luma
for number in 1 to 5:       # 1, 2, 3, 4, 5
    show number

for number in range(1, 5):  # 1, 2, 3, 4
    show number
```

## Hàm và module

### Hàm

```luma
func square(number):
    return number ** 2

func greet(name):
    show "Xin chào, " + name
    return

show square(5)
greet("Luma")
```

### Module

Tạo file `mathlib.luma`:

```luma
func cube(number):
    return number * number * number
```

Import từ file khác:

```luma
import mathlib
show cube(3)
```

Cũng có thể dùng đường dẫn tương đối:

```luma
import "modules/tools.luma"
```

Module được tìm tương đối từ file đang import và chỉ được tải một lần trong mỗi chương trình.

## Danh sách token

### Token cấu trúc

Các token này do lexer sinh ra và thường không được viết trực tiếp:

| Token | Công dụng |
| --- | --- |
| `end` | Kết thúc file mã nguồn |
| `newline` | Kết thúc dòng hoặc câu lệnh |
| `indent` | Bắt đầu khối được thụt vào |
| `dedent` | Kết thúc khối được thụt vào |

### Giá trị và tên

| Token | Ví dụ |
| --- | --- |
| `identifier` | `name`, `my_value` |
| `number` | `10`, `3.14` |
| `text` | `"Xin chào"`, `'Luma'` |
| Boolean | `true`, `false` |
| Giá trị rỗng | `nothing` |

### Từ khóa

```text
let show when otherwise repeat true false nothing
and or not if elif else func return for in to step
while until forever break continue import pass
```

### Dấu phân cách và toán tử

```text
( ) [ ] : ; ,
+ - * ** / %
= += -= *= /= %=
== != < <= > >=
```

Không hỗ trợ dấu `!` độc lập. Dùng `not` để phủ định logic và `!=` để kiểm tra khác nhau.

### Độ ưu tiên toán tử

Từ cao xuống thấp:

1. Ngoặc, giá trị, tên, gọi hàm và truy cập index
2. Lũy thừa: `**`
3. Toán tử một ngôi: `-`, `not`
4. Nhân, chia và chia dư: `*`, `/`, `%`
5. Cộng và trừ: `+`, `-`
6. So sánh: `==`, `!=`, `<`, `<=`, `>`, `>=`
7. Logic AND: `and`
8. Logic OR: `or`

## Thư viện chuẩn

Các hàm tích hợp sẵn có ở cả chế độ thông dịch và biên dịch; không cần import.

### Cơ bản và chuyển đổi

| Hàm | Công dụng |
| --- | --- |
| `length(value)` | Trả về độ dài văn bản hoặc danh sách. |
| `text(value)` | Chuyển giá trị thành văn bản hiển thị. |
| `number(value)` | Chuyển văn bản dạng số thành số. |
| `type_of(value)` | Trả về tên kiểu dữ liệu khi chạy. |

### Toán học

| Hàm | Công dụng |
| --- | --- |
| `abs(x)` | Giá trị tuyệt đối |
| `sqrt(x)` | Căn bậc hai |
| `floor(x)` | Làm tròn xuống |
| `ceil(x)` | Làm tròn lên |
| `round(x)` | Làm tròn đến số nguyên gần nhất |
| `pow(base, exponent)` | Tính lũy thừa |
| `min(a, b)`, `max(a, b)` | Chọn số nhỏ hơn hoặc lớn hơn |
| `random()` | Số ngẫu nhiên từ `0.0` đến `1.0` |
| `clamp(value, low, high)` | Giới hạn giá trị trong một khoảng |
| `sum(list)` | Tính tổng các số trong danh sách |

### Danh sách và khoảng số

| Hàm | Công dụng |
| --- | --- |
| `push(list, value)` | Thêm giá trị vào cuối danh sách. |
| `pop(list)` | Xóa và trả về giá trị cuối. |
| `sort(list)` | Sắp xếp trực tiếp danh sách. |
| `reverse(list)` | Đảo ngược trực tiếp danh sách. |
| `range(stop)` | Tạo khoảng `[0, stop)` với bước 1. |
| `range(start, stop)` | Tạo khoảng `[start, stop)` với bước 1. |
| `range(start, stop, step)` | Tạo khoảng loại trừ điểm cuối với bước tùy chọn. |
| `contains(value, item)` | Kiểm tra phần tử trong văn bản hoặc danh sách. |
| `find(value, item)` | Trả về index từ 0 hoặc `-1`. |
| `slice(value, start, stop)` | Cắt văn bản hoặc danh sách, loại trừ điểm cuối. |

### Văn bản

| Hàm | Công dụng |
| --- | --- |
| `join(list, separator)` | Ghép danh sách thành văn bản. |
| `split(text, separator)` | Tách văn bản thành danh sách. |
| `upper(text)`, `lower(text)` | Đổi chữ hoa hoặc chữ thường. |
| `trim(text)` | Xóa khoảng trắng ở hai đầu. |
| `replace(text, old, new)` | Thay thế toàn bộ văn bản khớp. |
| `starts_with(text, prefix)` | Kiểm tra tiền tố. |
| `ends_with(text, suffix)` | Kiểm tra hậu tố. |

### Console, file và thời gian

| Hàm | Công dụng |
| --- | --- |
| `input()` / `input(prompt)` | Đọc một dòng từ đầu vào chuẩn. |
| `read_file(path)` | Đọc toàn bộ file thành văn bản. |
| `write_file(path, value)` | Ghi đè file bằng giá trị hiển thị. |
| `sleep_ms(milliseconds)` | Tạm dừng luồng hiện tại. |
| `now_ms()` | Trả về thời gian hệ thống hiện tại theo mili giây. |

## Đồ họa

Đồ họa yêu cầu Luma được build với SDL2.

| Hàm | Công dụng |
| --- | --- |
| `window_open(title, width, height)` | Mở cửa sổ và trả về ID. |
| `window_should_close(id)` | Xử lý sự kiện và kiểm tra yêu cầu đóng. |
| `window_clear(id, r, g, b)` | Xóa vùng vẽ bằng một màu. |
| `window_set_pixel(id, x, y, r, g, b)` | Vẽ một pixel. |
| `window_fill_rect(id, x, y, w, h, r, g, b)` | Vẽ hình chữ nhật đặc. |
| `window_draw_line(id, x1, y1, x2, y2, r, g, b)` | Vẽ đường thẳng. |
| `window_present(id)` | Hiển thị vùng vẽ lên màn hình. |
| `window_close(id)` | Hủy cửa sổ. |

```luma
let window = window_open("Luma", 640, 480)

if window != -1:
    while not window_should_close(window):
        window_clear(window, 20, 20, 30)
        window_fill_rect(window, 100, 100, 120, 80, 0, 150, 255)
        window_present(window)
        sleep_ms(16)

    window_close(window)
```

Nếu không có SDL2, các hàm cửa sổ sẽ chuyển sang chế độ an toàn và in cảnh báo một lần.

## Luma Editor

Bản build Windows có `luma-edit.exe`, một editor nhẹ dành riêng cho Luma.

Tính năng:

- Tô màu từ khóa, chuỗi, số và chú thích
- New, Open, Save và Save As
- Hỗ trợ file UTF-8
- Cảnh báo thay đổi chưa lưu
- Phím Tab chèn bốn dấu cách
- Tự động thụt dòng sau dòng kết thúc bằng `:`
- Thanh trạng thái hiển thị file, trạng thái lưu, dòng và cột
- `F5` để lưu và chạy
- `F6` để lưu và biên dịch
- Liên kết file `.luma` thông qua installer

```powershell
.\out\luma-edit.exe
.\out\luma-edit.exe .\examples\welcome.luma
```

| Phím tắt | Thao tác |
| --- | --- |
| `Ctrl+N` | Tạo file mới |
| `Ctrl+O` | Mở file |
| `Ctrl+S` | Lưu file |
| `F5` | Chạy chương trình |
| `F6` | Biên dịch chương trình |

## Build từ mã nguồn

### Yêu cầu

- Windows
- CMake 3.25 trở lên
- Trình biên dịch C++23: MinGW-w64 hoặc MSVC
- Tùy chọn: SDL2 development files cho đồ họa
- Tùy chọn: Inno Setup 6 để tạo installer

### MinGW-w64

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
```

Các file thực thi được tạo trong `out/`:

```text
out/luma.exe
out/luma-edit.exe
out/luma_tests.exe
```

Nếu cài SDL2 qua MSYS2:

```powershell
pacman -S mingw-w64-x86_64-SDL2
```

Hãy cấu hình lại project sau khi cài SDL2.

## Trình cài đặt Windows

Repository có file `install.iss` dành cho Inno Setup 6.

Build và test project trước, sau đó biên dịch installer:

```powershell
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" ".\install.iss"
```

Đầu ra:

```text
installer/luma-setup.exe
```

Tính năng installer:

- Giao diện cài đặt tiếng Anh và tiếng Việt
- Cài compiler và editor
- Tùy chọn thêm vào PATH hệ thống hoặc PATH người dùng
- Tùy chọn tạo shortcut Desktop
- Tùy chọn liên kết file `.luma`
- Cài ví dụ, header, mã nguồn runtime và cấu hình build đã sinh
- Tự xóa mục PATH khi gỡ cài đặt

## Kiến trúc

Luồng xử lý mã nguồn Luma:

```text
Mã nguồn -> Lexer -> Parser -> AST
                              |-> Bytecode compiler -> Máy ảo
                              `-> C++ backend -> Trình biên dịch C++ -> File thực thi
```

| Thư mục | Trách nhiệm |
| --- | --- |
| `include/luma/` | Giao diện C++ công khai |
| `src/lex/` | Phân tách token có nhận biết thụt dòng |
| `src/parse/` | Parser recursive-descent |
| `src/ast/` | Cây cú pháp trừu tượng |
| `src/bytecode/` | Sinh bytecode |
| `src/runtime/` | Giá trị runtime, phép toán và máy ảo |
| `src/stdlib/` | Hàm tích hợp dùng chung |
| `src/app/` | CLI, native backend và editor |
| `examples/` | Chương trình Luma mẫu |
| `tests/` | Bộ kiểm thử hồi quy C++ |

## Giới hạn hiện tại

- Biên dịch native yêu cầu trình biên dịch C++ tương thích.
- Cần SDL2 để hiển thị cửa sổ đồ họa.
- Trong chế độ native, hàm hiện phải được khai báo ở cấp cao nhất.
- Gọi hàm gián tiếp qua biến hiện chỉ hoạt động ở chế độ thông dịch.
- Không thể dùng tab để thụt dòng mã nguồn.

## Ví dụ

- [`examples/welcome.luma`](examples/welcome.luma) — cú pháp cơ bản
- [`examples/functions.luma`](examples/functions.luma) — hàm, danh sách và vòng lặp
- [`examples/guess_number.luma`](examples/guess_number.luma) — nhập liệu và điều khiển luồng
- [`examples/import_demo.luma`](examples/import_demo.luma) — module
- [`examples/window_demo.luma`](examples/window_demo.luma) — đồ họa SDL2

---

Được tạo tại Việt Nam với mục tiêu xây dựng cú pháp dễ đọc, khả năng biên dịch native thực tế và trải nghiệm học tập thân thiện.
