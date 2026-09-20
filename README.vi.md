# Luma

**Ngôn ngữ lập trình nhỏ gọn, dễ đọc, cú pháp giống Python, có máy ảo bytecode và code editor riêng cho Windows.**

[English](README.md) | [Tiếng Việt](README.vi.md)

Luma được xây dựng bằng C++23 hiện đại và hướng tới cú pháp rõ ràng, lấy cảm hứng từ Python 3, dùng thụt dòng để tạo khối lệnh. Luma có thể chạy mã nguồn bằng máy ảo bytecode hoặc đóng gói thành file thực thi độc lập — không cần trình biên dịch C++ tại thời điểm build.

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

## Điểm nổi bật

- Cú pháp dễ đọc, lấy cảm hứng từ Python với thụt dòng
- Trình thông dịch để phát triển nhanh: `luma run`
- **Biên dịch độc lập**: `luma build` tạo file .exe — không cần trình biên dịch C++!
- **Máy ảo bytecode** với file thực thi tự giải nén
- Từ khóa kiểu Python: `if/elif/else`, `for/while`, `def`, `class`, `try/except`, `lambda`, `with/as`
- Số, văn bản, boolean, danh sách, dict, set, tuple, hàm, module và file I/O
- Biểu thức ba ngôi, list comprehension, phép gán kết hợp (`+=`, `-=`, ...)
- `//` chia lấy floor, `**` lũy thừa, `is`, `in`, `not in`
- Từ khóa cũ Luma vẫn được hỗ trợ (`let`, `show`, `when`, `func`, `repeat`, ...)
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
- [Mới trong v0.6](#mới-trong-v06)
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

### Build project

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
```

### Chạy chương trình

```powershell
.\out\luma.exe run .\examples\welcome.luma
```

Hoặc dùng CMake custom targets:

```powershell
cmake --build build --target run FILE=examples/welcome.luma
```

Có thể bỏ từ khóa `run`:

```powershell
.\out\luma.exe .\examples\welcome.luma
```

### Biên dịch thành file native

```powershell
.\out\luma.exe build .\examples\welcome.luma
.\examples\welcome.exe
```

Hoặc dùng CMake custom targets:

```powershell
cmake --build build --target compile FILE=examples/welcome.luma
```

Chọn file đầu ra:

```powershell
.\out\luma.exe build .\examples\welcome.luma -o .\hello.exe
.\hello.exe
```

> Không cần trình biên dịch C++ tại thời điểm build! VM được biên dịch sẵn và đóng gói tự động.

## Lệnh dòng lệnh

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

| Lệnh | Mô tả |
| --- | --- |
| `luma file.luma` | Chạy chương trình bằng trình thông dịch. |
| `luma run file.luma` | Dạng đầy đủ của lệnh thông dịch. |
| `luma build file.luma` | Đóng gói thành file .exe độc lập. |
| `luma build file.luma -o app.exe` | Đóng gói với đường dẫn đầu ra tùy chọn. |
| `luma init [name]` | Tạo project mẫu với `main.luma`, `lib/` và `README.md`. |
| `luma info` | Hiển thị phiên bản, kiến trúc và tất cả hàm built-in. |
| `luma --debug file.luma` | Chạy với thông tin timing (parse/compile/execute). |
| `luma --version` | Hiển thị phiên bản đã cài. |
| `luma --help` | Hiển thị trợ giúp dòng lệnh. |

## Tổng quan ngôn ngữ

### Giá trị và biến

```luma
count = 10
price = 3.14
message = "Xin chào"
enabled = True
missing = None
values = [10, 20, 30]

count = 20
count += 5
values[0] = 100
```

Các kiểu giá trị chính:

| Kiểu | Ví dụ |
| --- | --- |
| Số | `10`, `3.14`, `-5` |
| Văn bản | `"Xin chào"`, `'Luma'` |
| Boolean | `True`, `False` |
| Giá trị rỗng | `None` |
| Danh sách | `[1, 2, 3]` |
| Dict | `{"key": "value"}` |
| Set | `{1, 2, 3}` |
| Tuple | `(1, "a", True)` |
| Hàm | Hàm native hoặc hàm do người dùng định nghĩa |

### Xuất và nhập dữ liệu

```luma
print("Xin chào!")

name = input("Tên: ")
age = number(input("Tuổi: "))

print("Xin chào, " + name)
print("Năm sau: " + text(age + 1))
```

### Điều kiện

Luma v0.6 dùng cú pháp `if/elif/else` kiểu Python. Từ khóa cũ `when/otherwise` vẫn được chấp nhận:

```luma
if score >= 80:
    print("Xuất sắc")
elif score >= 50:
    print("Đạt")
else:
    print("Chưa đạt")
```

Dạng cũ (vẫn hoạt động):

```luma
when score >= 50:
    show "Đạt"
otherwise:
    show "Chưa đạt"
```

### Biểu thức ba ngôi

```luma
status = "đạt" if score >= 50 else "trượt"
print(status)
```

### Toán tử

| Nhóm | Toán tử |
| --- | --- |
| Số học | `+`, `-`, `*`, `/`, `//`, `%`, `**` |
| Gán | `=`, `+=`, `-=`, `*=`, `/=`, `//=`, `%=`, `**=` |
| So sánh | `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `in` |
| Logic | `and`, `or`, `not` |
| Bitwise | `&`, `|`, `^`, `~`, `<<`, `>>` |
| Khác | `@` (nhân ma trận), `.` (truy cập thuộc tính), `:=` (walrus) |

### Danh sách

```luma
numbers = [5, 2, 8]

push(numbers, 1)
sort(numbers)

print(numbers)
print(numbers[0])
print(length(numbers))
print(sum(numbers))
```

### List comprehension

```luma
items = [1, 2, 3, 4, 5]
result = [x for x in items if x > 2]
print(result)  # [3, 4, 5]

squares = [x * x for x in range(5)]
print(squares)  # [0, 1, 4, 9, 16]
```

### Dict và set

```luma
person = {"name": "Lan", "age": 25}
print(person["name"])

unique = {1, 2, 3, 2, 1}
print(unique)  # [1, 2, 3]
```

### Chú thích và khối lệnh

Chú thích bắt đầu bằng `#`:

```luma
# Chú thích cả dòng
score = 100 # Chú thích cuối dòng
```

Khối lệnh bắt đầu sau dấu `:` và dùng dấu cách để thụt dòng. Không dùng tab để thụt dòng.

```luma
if score > 0:
    print("Số dương")
    print("Vẫn ở trong khối")

print("Ngoài khối")
```

Câu lệnh ngắn và nhiều câu lệnh có thể viết cùng dòng:

```luma
if score > 0: print("Số dương")
a = 1; b = 2; print(a + b)
```

## Vòng lặp

Mọi kiểu vòng lặp đều hỗ trợ `break` và `continue`.

| Vòng lặp | Công dụng |
| --- | --- |
| `for i in range(N):` | Chạy khối lệnh N lần (0 đến N-1). |
| `for item in list:` | Duyệt qua danh sách. |
| `for i in start to stop:` | Đếm từ đầu đến cuối, bao gồm cả hai đầu (cũ). |
| `for i in start to stop step N:` | Dùng bước nhảy tùy chọn (cũ). |
| `while condition:` | Chạy khi điều kiện còn đúng. |
| `while not condition:` | Chạy cho đến khi điều kiện đúng. |
| `while True:` | Chạy mãi cho đến khi `break`. |

```luma
for i in range(3):
    print("Xin chào")

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
    print("Chạy một lần")
    break
```

Có thể lồng nhiều vòng lặp:

```luma
for row in range(1, 4):
    for column in range(1, 4):
        print("Hàng " + text(row) + ", cột " + text(column))
```

Vòng lặp đếm bao gồm giá trị kết thúc, còn `range()` loại trừ giá trị kết thúc:

```luma
for number in 1 to 5:       # 1, 2, 3, 4, 5
    print(number)

for number in range(1, 5):  # 1, 2, 3, 4
    print(number)
```

## Hàm và module

### Hàm

```luma
def square(number):
    return number ** 2

def greet(name):
    print("Hello, " + name)
    return

print(square(5))
greet("Luma")
```

Từ khóa cũ `func` cũng hoạt động:

```luma
func square(number):
    return number ** 2
```

### Biểu thức lambda

```luma
double = lambda x: x * 2
print(double(5))  # 10

add = lambda a, b: a + b
print(add(3, 4))  # 7
```

### Module

Tạo file `mathlib.luma`:

```luma
def cube(number):
    return number * number * number
```

Import từ file khác:

```luma
import mathlib
print(cube(3))
```

Cũng có thể dùng đường dẫn tương đối:

```luma
import "modules/tools.luma"
```

Module được tìm tương đối từ file đang import và chỉ được tải một lần trong mỗi chương trình.

## Mới trong v0.6

Luma v0.6 nâng cấp cú pháp lớn hướng tới tương thích Python trong khi vẫn giữ được backward compatibility với từ khóa cũ.

### Thay đổi cú pháp

| Tính năng | v0.5 (cũ) | v0.6 (mới) | Alias cũ |
| --- | --- | --- | --- |
| Biến | `let x = 5` | `x = 5` | `let` vẫn hoạt động |
| Xuất | `show "hi"` | `print("hi")` | `show` vẫn hoạt động |
| Điều kiện | `when ... otherwise` | `if ... elif ... else` | `when`/`otherwise` vẫn hoạt động |
| Hàm | `func name():` | `def name():` | `func` vẫn hoạt động |
| Lặp lại | `repeat N:` | `for i in range(N):` | `repeat` vẫn hoạt động |
| Until | `until cond:` | `while not cond:` | `until` vẫn hoạt động |
| Forever | `forever:` | `while True:` | `forever` vẫn hoạt động |
| True/False | `true` / `false` | `True` / `False` | Chữ thường vẫn hoạt động |
| Nothing | `nothing` | `None` | `nothing` vẫn hoạt động |

### Tính năng ngôn ngữ mới

- **Biểu thức ba ngôi**: `x = 10 if True else 20`
- **List comprehension**: `[x for x in items if x > 2]`
- **Biểu thức lambda**: `lambda x: x * 2`
- **Chia lấy floor**: `7 // 2` → `3`
- **Toán tử lũy thừa**: `2 ** 10` → `1024`
- **Toán tử is/in**: `x is None`, `x in list`
- **Gán kết hợp**: `x += 1`, `x //= 2`, `x **= 3`
- **Định nghĩa class**: `class Dog:` (đang chờ — body biên dịch thành hàm)
- **Try/except/finally**: đã parse nhưng chưa biên dịch
- **With/as**: đã parse nhưng chưa biên dịch
- **Decorator**: `@decorator` (đã parse)
- **Tăng/giảm**: `x++`, `x--`
- **Danh sách rỗng**: `[]` (đã sửa parser)
- **Dict/set/tuple literal**: `{"k": v}`, `{1, 2}`, `(1, 2)`

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
| Boolean | `True`, `False` |
| Giá trị rỗng | `None` |

### Từ khóa

```text
False None True and as assert async await break class
continue def del elif else except finally for from
global if import in is lambda nonlocal not or pass
raise return try while with yield
```

Từ khóa cũ (vẫn chấp nhận):

```text
let show when otherwise repeat true false nothing
func until forever to step
```

### Dấu phân cách và toán tử

```text
( ) [ ] { } : ; , . @ -> ... :=
+ - * ** / // % &
| ^ ~ << >>
= += -= *= /= //= %= **= &= |= ^= <<= >>=
== != < <= > >= is in not
```

### Độ ưu tiên toán tử

Từ cao xuống thấp:

1. Ngoặc, giá trị, tên, gọi hàm và truy cập index
2. Lũy thừa: `**`
3. Toán tử một ngôi: `-`, `+`, `~`, `not`
4. Nhân ma trận: `@`
5. Nhân, chia, chia floor và chia dư: `*`, `/`, `//`, `%`
6. Cộng và trừ: `+`, `-`
7. Shift bit: `<<`, `>>`
8. AND bit: `&`
9. XOR bit: `^`
10. OR bit: `|`
11. So sánh: `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `in`
12. Logic NOT: `not`
13. Logic AND: `and`
14. Logic OR: `or`
15. Ba ngôi: `a if cond else b`
16. Lambda: `lambda args: expr`
17. Walrus: `x := expr`

## Thư viện chuẩn

Các hàm tích hợp sẵn có ở cả chế độ thông dịch và biên dịch; không cần import.

### Cơ bản và chuyển đổi

| Hàm | Công dụng |
| --- | --- |
| `print(value)` | In giá trị theo sau là newline. `show` cũng được chấp nhận. |
| `length(value)` | Trả về độ dài văn bản hoặc danh sách. |
| `text(value)` | Chuyển giá trị thành văn bản hiển thị. |
| `number(value)` | Chuyển văn bản dạng số thành số. |
| `type_of(value)` | Trả về tên kiểu dữ liệu khi chạy. |
| `is_number(value)` | Trả về `True` nếu giá trị là số. |
| `is_text(value)` | Trả về `True` nếu giá trị là văn bản. |
| `is_list(value)` | Trả về `True` nếu giá trị là danh sách. |
| `is_nothing(value)` | Trả về `True` nếu giá trị là `None`. |
| `assert(condition)` | Ném lỗi nếu điều kiện sai. |
| `assert(condition, message)` | Ném lỗi với thông báo tùy chọn. |

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
| `product(list)` | Tích các số trong danh sách |
| `average(list)` | Trung bình cộng |
| `min_of(list)` | Trả về giá trị nhỏ nhất trong danh sách |
| `max_of(list)` | Trả về giá trị lớn nhất trong danh sách |

### Danh sách và khoảng số

| Hàm | Công dụng |
| --- | --- |
| `push(list, value)` | Thêm giá trị vào cuối danh sách. |
| `pop(list)` | Xóa và trả về giá trị cuối. |
| `sort(list)` | Sắp xếp trực tiếp danh sách. |
| `sorted(list)` | Trả về danh sách mới đã sắp xếp (không thay đổi gốc). |
| `reverse(list)` | Đảo ngược trực tiếp danh sách. |
| `reversed(list)` | Trả về danh sách mới đã đảo ngược (không thay đổi gốc). |
| `unique(list)` | Trả về danh sách đã loại bỏ phần tử trùng. |
| `flatten(list)` | Phẳng hóa danh sách lồng nhau một cấp. |
| `count(list, value)` | Đếm số lần xuất hiện của giá trị trong danh sách. |
| `range(stop)` | Tạo khoảng `[0, stop)` với bước 1. |
| `range(start, stop)` | Tạo khoảng `[start, stop)` với bước 1. |
| `range(start, stop, step)` | Tạo khoảng loại trừ điểm cuối với bước tùy chọn. |
| `contains(value, item)` | Kiểm tra phần tử trong văn bản hoặc danh sách. |
| `find(value, item)` | Trả về index từ 0 hoặc `-1`. |
| `slice(value, start, stop)` | Cắt văn bản hoặc danh sách, loại trừ điểm cuối. |
| `enumerate(list)` | Trả về `[[0, a], [1, b], ...]` các cặp index-giá trị. |
| `zip(list1, list2)` | Kết hợp hai danh sách thành `[[a, x], [b, y], ...]`. |
| `any(list)` | Trả về `True` nếu bất kỳ phần tử nào đúng. |
| `all(list)` | Trả về `True` nếu tất cả phần tử đều đúng. |

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
| `char_at(text, index)` | Lấy ký tự tại vị trí chỉ định. |
| `to_char(code)` | Chuyển mã ASCII thành ký tự. |
| `ord(text)` | Trả về mã ASCII của ký tự đầu tiên. |

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
window = window_open("Luma", 640, 480)

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

Bản build Windows có `luma-edit.exe`, editor nhẹ với **dark theme** dành riêng cho Luma.

Tính năng:

- Dark theme với syntax highlighting (từ khóa, chuỗi, số, chú thích, hàm built-in)
- New, Open, Save và Save As
- Hỗ trợ file UTF-8
- Bảo vệ file chưa lưu
- Tab chen 4 dấu cách
- Tự động thụt dòng sau dòng kết thúc bằng `:`
- Thanh trạng thái hiển thị file, encoding, dòng/cột và phiên bản
- **Find** (Ctrl+F) và **Replace** (Ctrl+H) với tìm kiếm wrap-around
- **Go to Line** (Ctrl+G)
- Toggle word wrap
- **F5** để chạy trên VM, **F6** để build .exe độc lập, **F7** để chạy lại kết quả cũ
- Liên kết file `.luma` qua installer

```powershell
.\out\luma-edit.exe
.\out\luma-edit.exe .\examples\welcome.luma
```

| Phim tắt | Thao tác |
| --- | --- |
| `Ctrl+N` | Tạo file mới |
| `Ctrl+O` | Mở file |
| `Ctrl+S` | Lưu file |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Ctrl+G` | Go to line |
| `F5` | Chạy trên VM |
| `F6` | Build .exe độc lập |
| `F7` | Chạy lại kết quả cũ |

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
out/luma_vm.exe
out/luma-edit.exe
out/luma_tests.exe
```

Nếu cài SDL2 qua MSYS2:

```powershell
pacman -S mingw-w64-x86_64-SDL2
```

Hãy cấu hình lại project sau khi cài SDL2.

### CMake Custom Targets

Để thuận tiện, project định nghĩa các custom targets:

```powershell
# Chạy chương trình trên VM
cmake --build build --target run FILE=examples/welcome.luma

# Biên dịch thành file native .exe
cmake --build build --target compile FILE=examples/welcome.luma

# Biên dịch rồi chạy (cần hai bước)
cmake --build build --target compile FILE=examples/welcome.luma
.\out\welcome.exe
```

Các lệnh gốc mà target gọi:

```powershell
cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --target luma luma_edit luma_tests
ctest --test-dir build --output-on-failure -C Release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" .\install.iss
.\out\luma.exe run .\examples\welcome.luma
.\out\luma.exe build .\examples\welcome.luma -o .\out\welcome.exe
.\out\welcome.exe
```

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
- Cài luma.exe (CLI), luma_vm.exe (VM stub) và luma-edit.exe (editor)
- Không cần trình biên dịch C++ để build file .luma thành .exe
- Tùy chọn thêm vào PATH hệ thống hoặc PATH người dùng
- Tùy chọn tạo shortcut Desktop
- Tùy chọn liên kết file `.luma`
- Cài ví dụ và tài liệu (English + Vietnamese)
- Tự xóa mục PATH khi gỡ cài đặt

## Kiến trúc

Luma v0.6 sử dụng kiến trúc **Máy ảo Bytecode với File thực thi tự giải nén**:

```text
Mã nguồn (.luma) -> Lexer -> Parser -> AST -> Bytecode Compiler -> Bytecode
                                                                       |
                      +-----------------------------------------------+
                      |                                               |
               Interpreter Mode                                Build Mode
                      |                                               |
                      v                                               v
             Máy ảo (VM)                                  Đóng gói VM + bytecode -> .exe
             (thực thi trực tiếp)                          (không cần trình biên dịch C++)
```

| Thư mục | Trách nhiệm |
| --- | --- |
| `include/luma/` | Giao diện C++ công khai |
| `src/lex/` | Phân tách token có nhận biết thụt dòng với từ khóa kiểu Python |
| `src/parse/` | Parser recursive-descent (cú pháp Python + alias cũ) |
| `src/ast/` | Cây cú pháp trừu tượng (20+ kiểu biểu thức và câu lệnh) |
| `src/bytecode/` | Sinh bytecode và tuần tự hóa |
| `src/runtime/` | Giá trị runtime, phép toán và máy ảo |
| `src/stdlib/` | Hàm tích hợp dùng chung |
| `src/app/` | CLI, bundler và editor |
| `examples/` | Chương trình Luma mẫu |
| `tests/` | Bộ kiểm thử hồi quy C++ |

## Giới hạn hiện tại

- Cần SDL2 để hiển thị cửa sổ đồ họa.
- Không thể dùng tab để thụt dòng mã nguồn.
- File .exe build chứa VM runtime (lớn hơn một chút so với native code thuần).
- Phương pháp self-extracting yêu cầu VM stub có sẵn khi build.
- `class`, `try/except`, `with/as` đã parse nhưng chưa biên dịch đầy đủ.
- Dict/Set/Tuple biên dịch dưới dạng list bên trong.
- Tự động gợi ý trong editor sẽ được thêm trong phiên bản tương lai.

## Ví dụ

- [`examples/welcome.luma`](examples/welcome.luma) — cú pháp cơ bản
- [`examples/functions.luma`](examples/functions.luma) — hàm, danh sách và vòng lặp
- [`examples/guess_number.luma`](examples/guess_number.luma) — nhập liệu và điều khiển luồng
- [`examples/import_demo.luma`](examples/import_demo.luma) — module
- [`examples/demo.luma`](examples/demo.luma) — giới thiệu đầy đủ tính năng
- [`examples/window_demo.luma`](examples/window_demo.luma) — đồ họa SDL2

---

Được tạo tại Việt Nam với mục tiêu xây dựng cú pháp dễ đọc, khả năng biên dịch native thực tế và trải nghiệm học tập thân thiện.
