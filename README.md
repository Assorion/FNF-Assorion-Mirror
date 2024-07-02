# Friday Night Funkin' Assorion Engine!

![LOGO](assorion.png)

-------------------------------------------------------------
 <div align="center">
 <a href="#"><img src="https://img.shields.io/github/repo-size/Assorion/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/></a>
 <a href="https://github.com/Assorion/FNF-Assorion-Engine/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/Assorion/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/</a> 
 <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/github/v/release/Assorion/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/></a>
 </div>
 <div align="center">
 <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/badge/Windows_Build-Released-blue?style=for-the-badge&color=e1b100"/></a>
 <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/badge/Linux_Build-Released-blue?style=for-the-badge&color=e1b100"/></a>
 <a href="https://github.com/Assorion/FNF-Assorion-Engine/actions/workflows/HTML5.yml"><img src="https://img.shields.io/badge/Web_Build-Testing-blue?style=for-the-badge&color=e1b100"/></a>  
 </div>

-------------------------------------------------------------
<div align="center">
 
**Table of Contents**
</div>
<div align="center">
 
┃ [**`• What is Assorion?`**](#--what-is-assorion-engine) ┃ [**`• Important Notes`**](#%EF%B8%8F--important-notesroadmap) ┃ [**`• Compiling`**](#--compiling) ┃ [**`• Min Reqs`**](#--minimum-requirements) ┃ <a href="https://assorion.github.io/wiki/">**`• Wiki (WIP)`**</a> ┃ <a href="https://discord.gg/nbhWWxKxTe">**`• Discord`**</a> ┃

</div>

-------------------------------------------------------------
 
# ⚝ | What is Assorion Engine?

Assorion Engine is a minimalist engine, focusing on modding primarily the source code, as opposed to external scripting languages. 
Most original <a href="https://ninja-muffin24.itch.io/funkin">Friday Night Funkin'</a> code has been replaced / revised with more efficient, optimized code & modular code.

Assorion Engine doesn't have mods folder capabilities planned nor will it be implemented. 
In addition, things such as cutscenes, events, discordRPC, etc, will have to be added yourself. 
Though, Assorion Engine does have several <a href="https://github.com/Assorion/FNF-Assorion-Engine#branches">branches</a> planned with more features soon.

Assorion is a very simple engine and thus, it may not receive many feature updates; Assorion will continue to have bug fixes and optimizations.

## ⚡ | Why choose Assorion Engine?

1. Assorion Engine is incredibly fast and stable
2. Assorion's Code is much better streamlined, and much easier to mod
3. Assorion has an emphasis on simplicity, over bloat
4. Assorion is actively maintained, adding many fixes

# 🗒️ | Important Notes/RoadMap

-	There has been a complete overhaul of Chartingstate. Therefore, it will probably have new bugs and will be partially confusing at first glance
-	The characters in the song are entirely un-hardcoded. Thus you can define 2 or 4 characters instead of 3. Notes have a `player` value that makes this work
-	Charts are handled differently to the base game. Absolute positions are used instead of millisecond values. In addition, notes have player values in the chart
-	Assorion Engine based off <a href="https://github.com/FunkinCrew/Funkin/releases/tag/v0.2.6">`0.2.6`</a> version of the base game, though has been radically altered
-	The Songs and Data folder have been merged into the `songs-data` folder
- Pressing the F12 key juring gameplay uses an experimental screenshot feature. When pressed, a folder and file will be created
- The rating system, health loss, health gain, and menus are inaccurate to the base game or other engines
- Ratings, input, and chart speed change depending on BPM
  
 **RoadMap**
* [x]	Offset wizard
* [X]	Web build
* [X]	Improvements to the chart editor
* [X]	Fixes for newer Flixel
* [ ]	Events System
 
#### **Branches**

> <details>
> <summary>Deprecated List</summary>
> <table>
> <tr>
> <td>
>
>   | `Assorion Branch's`                                | `Windows` | `Linux` | `HTML5 (WEB)`     |
>   |--------------------------------------------------|---------|-------|-----------------|
>   | <a href="#">Assorion-Main</a>                                    | ✓       | ✓     | ⍻              |
>   | <a href="#">Assorion-Plus</a>                                    | ☓       | ☓     | ☓              |
>   | <a href="#">Assorion-Minimun</a>                                 | ☓       | ☓     | ☓              |
>   | <a href="#">Assorion-Base</a>                                    | ☓       | ☓     | ☓              |
>   | <a href="#">Assorion-3D</a>                                      | ☓       | ☓     | ☓              |
></td>
></tr>
></table>
></details>
Until the **primary Assorion Engine repository** is finalized, the following branches listed above will be **deprecated**.

## 🖼️ | Screenshots

Take a look at <a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/art/screenshots.md">`art/screenshots.md`</a>. 

# 🛠 | Compiling

> [!NOTE]
> Please do **not** clone, or download the source from the top download button. The **NEWEST** source code is often broken due to testing.
> Use the <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases">latest release's</a> source code as it is stable, and less-likely to be broken.

#### **For Windows:**
- Install <a href="https://haxe.org/">`Haxe`</a>
- Run `haxelib setup` in CMD. Using the defaults is fine
- Install [libraries](#libraries) below
- Run `haxelib run lime setup` in CMD
- Download and extract the <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases">latest release's</a> source code
- Setup <a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/.github/MinGW-Setup.md">MinGW-w64</a> and make sure the PATH is set correctly
- Test to make sure both the `gcc` and `g++` commands work in CMD
- Run `lime test windows -D HXCPP_MINGW` in CMD. Make sure it's in the project root folder, not the source folder

#### **For Linux:**
- Install Haxe using your package manager
- Run `haxelib setup` in your terminal
- Install [libraries](#libraries) below
- Run `haxelib run lime setup`
- Download and extract the <a href="https://github.com/Assorion/FNF-Assorion-Engine/releases">latest release's</a> source code
- Make sure both `gcc` and `g++` commands work. If not, install GCC using your package manager
- Run `lime test linux` in your terminal. Make sure it's in the project root folder, not the source folder

#### **Libraries:**  
Run `haxelib install <library name>` replacing `<library name>` with these libraries below:
- `hxcpp`
- `lime`
- `openfl`
- `flixel`
- `flixel-addons`
- `flixel-ui`

#### **If you're confused:**  
Follow a YouTube guide, or the <a href="https://github.com/FunkinCrew/Funkin#build-instructions">base game instructions</a> on compiling. Do **NOT** use **`Visual Studio's Clang-Compiler`**, please use <a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/.github/MinGW-Setup.md">**`MinGW-w64`**</a> unless the compiler errors out.  
Remember to install the [library versions](#libraries) listed above.

## 💻 | Minimum Requirements

The engine *should* be able to run smoothly (max framerate) on at least an **`Intel Core2 Duo E6850`** with an **`AMD Radeon R5 240`**. 
The engine runs *perfectly* on an **`Intel i7-2600`**, and an **`Nvidia GT 1030`**.

> [!tip]
> Any games performance will decrease with higher resolutions.  
> Un-fullscreen and resize the game if encountering performance issues.

These should be the lowest minimum requirements to run the engine:

- **Windows**: Windows 7 64-Bit or Higher
  
- **Linux**: Any 64-Bit Distro With GLibC 2.36 or Equivilant
  
- **Processor**: Intel Celeron (SSE to SSE4 with MMX) or Higher
  
- **Memory**: 512MB - 1GB of Ram. 256mb VRam or Higher
  
- **Storage**: ~70MB Available Space


# ⚠️ | License
**<a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/LICENSE">GPL-3.0 Public License</a>, Version 3, 29 June 2007**

Under the terms of the <a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/LICENSE">GPL-3.0 Public License</a>, Assorion Engine will be free and open source and anyone using this project thereafter acknowledges being bound under the <a href="https://github.com/Assorion/FNF-Assorion-Engine/blob/main/LICENSE">GPL-3.0 Public License's</a> conditions, and making their variant of the project open source.

Project authored and maintained by <a href="https://github.com/Legendary-Candice-Joe">***Legendary Candice Joe***</a>.
