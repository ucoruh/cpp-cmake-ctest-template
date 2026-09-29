# From a project topic to your own project

This walks through turning the sample "Calculator" (`utility` + `calculator` + `calculatorapp` +
googletest) into your own course project, using one concrete example topic so every step is
copy-pasteable rather than abstract.

## Worked example topic: "Simple Inventory Tracker"

Say your course project guide gives you the topic **"Simple Inventory Tracker"** (track items, add
stock, remove stock, report low-stock items). Here is the whole process for that topic; substitute
your own topic's nouns/verbs where this uses "inventory"/"item"/"stock".

## 1. Rename the sample folders and CMake targets

Keep the same three-layer shape (a small `utility` library, your real `inventory` library, and an
`inventoryapp` command-line demo, plus `tests/`) - it is what lets you get both a tested library *and*
a runnable demo, with coverage on the library.

```text
src/utility        -> keep as-is (generic helpers) or rename if you truly do not need it
src/calculator     -> rename to src/inventory
src/calculatorapp  -> rename to src/inventoryapp
src/tests/calculator -> rename to src/tests/inventory
```

In each renamed `CMakeLists.txt`, change `set(LIBNAME calculator)` / `set(APPNAME calculatorapp)` /
`set(TESTNAME calculator)` to `inventory` / `inventoryapp` / `inventory`, and fix the
`target_include_directories`/`target_link_libraries` paths that reference `../calculator/...`.

## 2. Rename the C++ namespace

`Coruh::Calculator` -> pick your own, e.g. `Coruh::Inventory` (keep your own name/nickname instead of
`Coruh` if you prefer - it is just a namespace, not a requirement). Update:

- `src/inventory/header/*.h` (was `calculator.h`): class name, namespace, header guard.
- `src/inventory/src/*.cpp`: `using namespace ...`, `#include` paths.
- `src/inventoryapp/src/inventoryapp.cpp`: `using namespace ...`, `#include` path.
- `src/tests/inventory/*_test.cpp`: `using namespace ...`, `#include` path, `TEST_F` fixture class
  name.

## 3. Write your tests FIRST, then the library code

This template moved its own sample logic (infix/postfix expression parsing) out of the app and into
the library specifically so it is unit-testable - do the same for your logic. For "Simple Inventory
Tracker":

1. Design the library's public API first (e.g. `Inventory::addStock`, `Inventory::removeStock`,
   `Inventory::lowStockItems`) in the header, with Doxygen comments (they feed the doc-coverage
   report - see `docs/reports.md`).
2. Write the googletest cases against that API *before* implementing it - normal cases, boundary
   cases (e.g. removing exactly all remaining stock), and every error case (e.g. removing more stock
   than exists, adding a negative quantity, an unknown item id) - see
   `src/tests/calculator/expressionParser_test.cpp` for the pattern (28 cases covering normal,
   precedence, parentheses, decimals, and every error path of one small module - aim for the same
   thoroughness on your own module).
3. Implement the library code until the tests pass (`ctest -C Debug --output-on-failure`).
4. Keep the app (`inventoryapp`) as a thin driver: read input, call the library, print output, no
   real logic in `main()` - exactly like `calculatorapp.cpp` now only reads a line and calls
   `ExpressionParser::evaluateInfix`.

## 4. Add your own modules

Need a second library (e.g. a `storage` module that persists inventory to a file)? Copy the pattern
of `src/utility/`: its own folder, its own `CMakeLists.txt` (`set(LIBNAME storage)`), its own
`target_include_directories`, added to the top-level `CMakeLists.txt` with an `option(ENABLE_STORAGE
"..." ON)` and `add_subdirectory(${ROOT}/storage)` guarded by it, and its own
`src/tests/storage/CMakeLists.txt` + test file, added to `src/tests/CMakeLists.txt`.

## 5. Keep coverage

Every time you add a `.cpp` file under a library's `src/` folder, its test coverage will
automatically show up in `docs/coveragereportlibwin` / `coveragenativelibwin` (and the Linux
equivalents) the next time you run the full build script - the `file(GLOB ...)` in each
`CMakeLists.txt` picks up new files automatically, and OpenCppCoverage / lcov instrument whatever got
built. There is nothing extra to configure; just make sure each new function has at least one test
exercising it (check the coverage report's line-by-line view for anything still red/uncovered).

## 6. Checklist before you consider a module "done"

- [ ] Renamed namespace/class/target names consistently (grep for the old name to be sure nothing
      was missed: `grep -rn "Calculator" src/`).
- [ ] Doxygen comment on every public class/function (`\brief`, `@param`, `@return`, `@throws`).
- [ ] Tests for: normal input, boundary input, every error/exception path.
- [ ] `ctest -C Debug --output-on-failure` passes with 0 failures.
- [ ] No compiler warnings (`-Wall -Wextra` on GCC/Clang is already on by default in this template's
      `CMakeLists.txt`; watch the build output).
- [ ] Full build script (`7-build-app-windows.bat` / `.sh`) runs end to end; coverage report shows
      the new module with no red (untested) lines you did not mean to leave untested.
- [ ] README.md updated to describe your actual project, not "Calculator".

## Next step

Continue with [daily-workflow.en.md](daily-workflow.en.md).
