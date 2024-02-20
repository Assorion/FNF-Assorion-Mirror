# MinGW-w64 Setup Tutorial (Windows)

### 🪟 | Windows
1. Go to https://winlibs.com/#download-release and download the MinGW-w7 7zip Archive in the c disk (**C:**). Make sure you download the **`MSVCRT`** version of MinGW-w7.
   
![Screenshot1 1](https://github.com/Assorion/FNF-Assorion-Engine/assets/105545224/73280e96-de09-49ef-b5ee-976ff8a06cf7)

3. After the Archive is downloaded in the `C:`, Extract the file and a new folder `c:\mingw64` should exist. **Rename the folder to `MinGW`**
4. In settings or search menu type `Edit environment variables for your account`.
5. Choose the **`Path`** Variable and press **`edit`**
   
![Screenshot2](https://github.com/Assorion/FNF-Assorion-Engine/assets/105545224/ea411063-cc61-4a18-b6d6-4d6e4d8929a1)

6. Select **New** and add the **Mingw-w64 folder path(bin folder)** **`C:\MinGW\bin`**
7. Select OK to save updated path. to make sure type both the `gcc` and `g++` commands work in CMD and if they work MinGW-64 is installed
