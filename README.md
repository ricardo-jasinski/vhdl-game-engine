VAGE - VHDL "Advanced" Game Engine
==================================
A game engine implemented purely in hardware using the VHDL language

(C) Ricardo Jasinski, 2013

![Adventure Demo Screenshot](https://raw.githubusercontent.com/ricardo-jasinski/vhdl-game-engine/master/doc/screenshots/screenshot_01_adventure.png "Adventure Demo Screenshot") ![Space Shooter Demo Screenshot](https://raw.githubusercontent.com/ricardo-jasinski/vhdl-game-engine/master/doc/screenshots/screenshot_02_space_shooter.png "Space Shooter Demo Screenshot") 

Summary
=======
1. Overview
2. Technical Details
3. Creating a Game with VAGE
4. Q&A

1. Overview
===========

What is it?
-----------
VAGE (VHDL "Advanced" Game Engine) is a series of hardware modules that help
creating simple games in the VHDL language.

Features
--------
* VGA output with 640x480 resolution
* Supports an unlimited number of hardware sprites (8x8 pixels)
* Supported hardware platforms:
   - Altera DE2 (35)

Planned features
----------------
There are no planned future releases for this project. However, there are still
some things I'd like to add and maybe they will see the light of day. Please
drop me a line if you see use for some of these features and maybe we can work
on something together.
* Animated sprites
* Support for world maps
* Scrolling background
* Text output

I'd like to add three game demos to be used as templates for new games:
* A space shooter demo
* A bouncing ball ("Arkanoid") demo
* An adventure game demo (this one is currently completed)

License
-------
This code comes with absolutely no guarantees. This code is public domain and
you can do with it whatever you like.


2. Technical Details
====================

2.1 Sprites
-----------
VAGE provides a sprite engine that takes care of drawing sprites on the screen
and checking for collisions. All sprites have a fixed 8x8 size and are defined
in terms of paletted colors using the system fixed palette.

Bitmaps for the sprites can be generated using the sprite-gen tool in the
scripts folder. This script takes in PNG pictures and selects the best color
for each pixel considering the system fixed palette. The output is printed on
screen as a VHDL code snippet.

2.2 Video Output
----------------
VAGE provides a video engine that generates VGA signals (640x480 @60FPS). It
uses a fixed palette with 64 colors (color 0 is transparent), out of 2^24
possible colors. To save resources, a scaling factor may be used. By default,
a default value of 2 is used, meaning that the game screen has 320x240 pixels.

2.3 Source Code Organization
----------------------------
The VHDL source code is split into two folders: "engine" and "game/game_name".
Code in the "engine" folder should not be changed. Code in the "game" folder
must be changed to create the intended game behavior.

3. Creating a Game with VAGE
============================

The /hdl/implementation/game folder contains two game demos that can be adapted
to created your own game. The best course of action is to choose the demo that
is most similar to your original game, and delete the other directories in the
game folder. Remember, in theory you shouldn't have to touch anything in the
/hdl/implementation/engine folder.

4. Q&A
======

1. If it is so simple, why call it "Advanced"?

Honestly, I just needed a vowel to form an acronym. And maybe someday the
project will grow beyond the basic level.



