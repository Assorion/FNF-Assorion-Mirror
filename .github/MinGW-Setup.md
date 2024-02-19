# MinGW-w64 Setup Tutorial (Windows)

### 🪟 | Windows
1. Go to https://winlibs.com/#download-release and download the MinGW-w7 7zip Archive in the c disk (**C:**)

2. After the Archive is downloaded in the `C:`, Extract the file and a new folder `c:\mingw64` should exist. **Rename the folder to `MinGW`**
3. In settings or search menu type `Edit environment variables for your account`.
4. Choose the **`Path`** Variable and press **`edit`**

5. Select **New** and add the **Mingw-w64 folder path(bin folder)** **`C:\MinGW\bin`**
6. Select OK to save updated path. to make sure type both the `gcc` and `g++` commands work in CMD and if they work MinGW-64 is installed
