# MinGW-w64 Setup Tutorial

### 🪟 | Windows
1. Go to https://winlibs.com/#download-release and download the MinGW-w7 7zip Archive in the c disk (**C:**)
![screenshot1](https://github.com/Assorion/FNF-Assorion-Engine/assets/105545224/5c5dae5d-306a-4a8f-8b7f-6e2a9938ee92)

2. After the Archive is downloaded in the `C:`, Extract the file and a new folder `c:\mingw64` should exist.
3. In settings or search menu type `Edit environment variables for your account`.
4. Choose the `Path` Variable and press `edit`
![screenshot2](https://github.com/Assorion/FNF-Assorion-Engine/assets/105545224/8d1954e6-1031-446b-a50e-ba7711389acf)

5. Select **New** and add the **Mingw-w64 folder path(bin folder)** `C:\mingw64\bin`
6. Select OK to save updated path. to make sure type both the `gcc` and `g++` commands work in CMD and if they work MinGW-64 is installed

### 🐧 | Linux
gcc and g++ commands should already exists in current distro. to make sure type both `gcc` and `g++`
