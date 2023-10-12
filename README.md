# Friday Night Funkin' Assorion Engine!

![LOGO](art/assorione.png)

-------------------------------------------------------------
 <div align="center">
 <a href="#"><img src="https://img.shields.io/github/repo-size/Legendary-Candice-Joe/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/></a>
 <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/Legendary-Candice-Joe/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/</a> 
 <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/github/v/release/Legendary-Candice-Joe/FNF-Assorion-Engine?style=for-the-badge&color=06b59c"/></a>
 </div>
 <div align="center">
 <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/badge/Windows_Build-Released-blue?style=for-the-badge&color=e1b100"/></a>
 <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/releases"><img src="https://img.shields.io/badge/Linux_Build-Released-blue?style=for-the-badge&color=e1b100"/></a>
 <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/actions/workflows/HTML5.yml"><img src="https://img.shields.io/badge/Web_Build-Testing-blue?style=for-the-badge&color=e1b100"/></a>  
 </div>

-------------------------------------------------------------
<div align="center">
 
**Table of Contents**
</div>
<div align="center">
 
┃ [**`• What is Assorion?`**](#--what-is-assorion-engine) ┃ [**`• Important Notes`**](#%EF%B8%8F--important-notesroadmap) ┃ [**`• Compiling`**](#--compiling) ┃ [**`• Minimun Requirements`**](#--compiling) ┃
</div>

-------------------------------------------------------------

# ⚝ | What is Assorion Engine?

Assorion Engine is effectively the Linux of <a href="https://ninja-muffin24.itch.io/funkin">Friday Night Funkin'</a> Engines. 
All original base Friday Night Funkin' code has been replaced with more efficient, optimized code. 

Assorion Engine doesn't have mods folder capabilities planned and it won't be implemented. 
In addition to cutscenes, events, discordRPC, etc, most other features will have to be added yourself, 
although Assorion Engine may have several <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine#branches">branches</a> with more features soon.

## ⚡ | Why choose Assorion Engine?

1. Assorion Engine is increadibly speedy and stable
2. Assorion's Code is much better streamlined
3. Assorion takes up less than ~70mb
4. Assorion frequently has many bug fixes and consistently gets improvements compared to the original game and many other engines

# 🗒️ | Important Notes/RoadMap

### **Note for Developers**
> [!NOTE] 
> Please use the <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/releases"><ins>**latest release**</ins></a> source code, not the cloned or downloaded source code at the top. Mainly because of working on a lot of things throughout the source code during the weeks. Which will necessitate numerous commits.
>
> Thus inevitably exists the potential that something might be wrong if you use the most recent **source** code, as opposed to the most recent <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/releases"><ins>**release**</ins></a> code.

#
  **Notes**   
-	There has been a complete overhaul of Chartingstate. Therefore, it will probably have new bugs and will be partially confusing at first glance
-	It should be simpler to integrate more characters into a single song. Notes have special player values that make this possible
-	Charts are handled differently to the base game. Absolute positions are used instead of millisecond values. In addition, notes have player values in the chart
-	Assorion Engine based off <a href="https://github.com/FunkinCrew/Funkin/releases/tag/v0.2.6">`0.2.6`</a> version of the base game
-	Songs and Data folder have been merged into the songs-data folder
- Pressing the F12 key in gameplay uses an experimental screenshot feature. When pressed, a folder and file will be created
  
 **RoadMap**
* [x]	Offset wizard
* [X]	Web build
* [ ]	Improvements to the chart editor
* [ ]	Events System
* [ ]	Portuguese translation
* [ ]	Fixes for newer Flixel

#### **Branches**
| `Assorion Branch's`                                | `Windows` | `Linux` | `HTML5 (WEB)`     |
|--------------------------------------------------|---------|-------|-----------------|
| <a href="#">Assorion-Main</a>                                    | ✓       | ✓     | ⍻              |
| <a href="#">Assorion-Plus</a>                                    | ☓       | ☓     | ☓              |
| <a href="#">Assorion-Minimun</a>                                 | ☓       | ☓     | ☓              |
| <a href="#">Assorion-Base</a>                                    | ☓       | ☓     | ☓              |
| <a href="#">Assorion-3D</a>                                      | ☓       | ☓     | ☓              |

## 🖼️ | Screenshots

look at <a href="https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/blob/main/art/screenshots.md">`art/screenshots.md`</a>. 

# 🛠 | Compiling

Follow the <a href="https://github.com/FunkinCrew/Funkin#build-instructions">base game instructions</a> for compiling. (Flixel version <a href="https://lib.haxe.org/p/flixel/5.0.0/">`5.0.0`</a> or <a href="https://lib.haxe.org/p/flixel/4.11.0/">`4.11.0`</a> for compiling)

> [!WARNING] 
> Assorion engine has been tested with the most recent versions of Haxe & Flixel, Using these new version's will cause camera problems with Assorion engine, Please <ins>**downgrade**</ins> to Flixel <a href="https://lib.haxe.org/p/flixel/5.2.2/">`5.2.2`</a> or any version lower that the one specified. Fixes will be implemented eventually.


> [!IMPORTANT]
>This will need <a href="https://lib.haxe.org/p/flixel-ui/">`flixel-ui 2.5.0`</a> & <a href="https://lib.haxe.org/p/flixel-addons/3.0.2/releasenotes">`flixel-addons 3.0.2`</a> otherwise game will not compile, fixes may be implemented.

## 💻 | Minimum Requirements

1. 512mb - 1gb of RAM
2. Core 2 Duo CPU or higher
3. 256mb of VRAM or more
4. Windows 7 64-bit or higher
