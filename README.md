# compiler

## Requirements

- build-essential

```bash
sudo apt install build-essential
```

- graphviz:

```bash
sudo apt install graphviz
```

_if building with cmake:_

- cmake 3.18 or more

```bash
sudo apt install cmake
```

## Building

- Compile with cmake 3.18 or more:

```bash
# In the project root directory:
mkdir -p build && cd build
cmake .. && make
```

- Compile with makefile:

```bash
# In the src directory:
make
```

## Usage

```bash
./minigcc [options] <input file> [output file]
```

_Output file is optional and defaults to output.dot_

### Options

- `-h` or `--help`: print help

- `-v` or `--version`: print version

- `-ToPdf`: generate a pdf file from the output dot file

### Example

```bash
./minigcc -toPdf ../tests/functions.c functions.dot
```

_if compiled with cmake you can run tests_

```bash
# In the build directory:
make test
```
