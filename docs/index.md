# Calculator Project Library Generation and Testing Template

## Overview

This project provides a suite of modules aimed to show how Cmake used with Ctest. Also combines doxygen documentation and test coverage reports

## Requirements

- CMake >= 3.12
- C++ Standard >= 11
- GoogleTest (for testing modules)
- Visual Studio Communit Edition for Windows Generator
- Ninja for WSL/Linux

## Setup Development Environment

### Step-1 (Run on Windows, Can Effect on WSL)

Run 1-configure-pre-commit.bat file to copy 1-pre-commit script to .git/hooks that checkes. README.md, gitignore and doxygenfiles. Also format code with astyle tool

### Step-2 (Run on Windows, Can Effect on WSL)

If gitignore missing then you can create gitignore with 2-create-git-ignore.bat file run this file.

### Step-3 (Only Windows)

Install package managers that we will use to install applications. Run 3-install-package-manager.bat to install choco and scoop package managers

### Step-4 (Only Windows)

Run 4-install-windows-enviroment.bat to install required applications. 

### Step-5 (Only WSL)

Open powershell as admin and enter WSL then goto project folder and run 4-install-wsl-environment.sh to setup WSL environment



## Generate Development Environment

You can run 9-clean-configure-app-windows.bat to generate Visual Studio Communit Edition Project of this file. Or You can use Cmake project development with Visual Studio Community Edition



## Build, Test and Package Application on Windows

Run 7-build-app-windows.bat to build, test and generate packed binaries for your application on windows.



Also you can run 7-build-doc-windows.bat to only generate documentation and 8-build-test-windows.bat to only test application. 

## Build, Test and Package Application on WSL

Run 7-build-app-linux.sh to build, test and generate packed binaries for your application on WSL environment.



## Clean Project

You can run 9-clean-project.bat to clean project outputs. 



## Supported Platforms

![Ubuntu badge](assets/badge-ubuntu.svg)

![macOS badge](assets/badge-macos.svg)

![Windows badge](assets/badge-windows.svg)

### Test Coverage Ratios

> **Note** : There is a known bug on doxygen following badges are in different folder but has same name for this reason in doxygen html report use same image for all content [Images with same name overwrite each other in output directory · Issue #8362 · doxygen/doxygen · GitHub](https://github.com/doxygen/doxygen/issues/8362). README.md and WebPage show correct badges.

| Coverage Type | Windows OS                                                             | Linux OS (WSL-Ubuntu 20.04)                                              |
| ------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Line Based    | ![Line Coverage](assets/codecoveragelibwin/badge_linecoverage.svg)     | ![Line Coverage](assets/codecoverageliblinux/badge_linecoverage.svg)     |
| Branch Based  | ![Branch Coverage](assets/codecoveragelibwin/badge_branchcoverage.svg) | ![Branch Coverage](assets/codecoverageliblinux/badge_branchcoverage.svg) |
| Method Based  | ![Method Coverage](assets/codecoveragelibwin/badge_methodcoverage.svg) | ![Method Coverage](assets/codecoverageliblinux/badge_methodcoverage.svg) |

### Documentation Coverage Ratios

|                    | Windows OS                                                        | Linux OS (WSL-Ubuntu 20.04)                                         |
| ------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Coverage Ratio** | ![Line Coverage](assets/doccoveragelibwin/badge_linecoverage.svg) | ![Line Coverage](assets/doccoverageliblinux/badge_linecoverage.svg) |



#### Install Test Results to HTML Converter

We are using [GitHub - inorton/junit2html: Turn Junit XML reports into self contained HTML reports](https://github.com/inorton/junit2html) to convert junit xml formatted test results to HTML page for reporting also we store logs during test. Use following commands to install this module with pip

```bash
pip install junit2html
```

### Github Actions

This project also compiled and tested with Github Actions. If there is a missing setup or problem follow github action script for both Windows and WSL under

`.github/workflows/cpp.yml`

Github actions take too much time more than 1 hour take to complete build for Windows, MacOS and Linux. Also its paid operation for this reason we use offline batch scripts easy to use. 

### Build App on Windows

We have already configured script for build operations. `7-build-app-windows.bat` have complete all required tasks and copy outputs to release folder.  

**Operation Completed in 11-15 minutes.**

- Clean project outputs

- Create required folders

- Run doxygen for documentation

- Run coverxygen for document coverage report

- Run Report Generator for Documentation Coverage Report

- Configure project for Visual Studio Community Edition

- Build Project Debug and Release

- Install/Copy Required Library and Headers

- Run Tests 

- Run OpeCppCoverage for Coverage Data Collection

- Run Reportgenerator for Test Coverage Report

- Copy output report to webpage folder

- Run mkdocs to build webpage

- Compress outputs to release folder, everything is ready for deployment. 

### Build App on WSL/Linux

We are running WSL on Windows 10 and solve our virtual machine problem. We make cross-platform development. After development before commit we run and test app on Windows and WSL with this scripts. To run on WSL you need to install WSL first. 

you can use our public notes

- https://github.com/coruhtech/vs-docker-wsl-cpp-development

- [GitHub - ucoruh/ns3-wsl-win10-setup: ns3 windows 10 WSL2 setup and usage](https://github.com/ucoruh/ns3-wsl-win10-setup)

After WSL installation, right click and open WSL bash and run `7-build-app-linux.sh` this will provide similart task with windows and will generate report and libraries on release folder. 



----

$End-Of-File$
