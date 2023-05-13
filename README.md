# compiler
## compile

### Compile with cmake 3.18 or more:
```bash
# In the project root directory:
mkdir -p build && cd build
cmake .. && make
```

### Compile with makefile: 
```bash
# In the src directory:
make
```

## Usage
```bash
# In the src directory:
./minigcc <input file> [output file]
```

_if compiled with cmake you can run tests_
```bash
# In the build directory:
make test
```