# Zigzag

An extremely minimal game system for zig, inspired by another project: https://github.com/beta-bytes/bbmicro and pico8.

![Screenshot](docs/zigzag.gif)

Try the [wasm demo](https://ibebrett.github.io/zigzag).

## Pico 8

The initial goal is to build an api compatible with pico8 (a proven api), by sticking as closely as is reasonable to the [pico8 api](https://iiviigames.github.io/pico8-api/). Over time we will probably evolve and diverge, but for now lets keep it simple.

## Building

You can right now either build using SDL (on windows (more platforms coming)), or WASM.

### Windows + SDL

Aside from zig (obviously), you need both SDL2 and SDL_Image development releases.

1. Download the sdl development release SDL2-devel-2.26.1-VC and unzip in the main directory of this repo.
2. Download the sdl2 image development release SDL2_image-devel-2.6.2-VC and unzip in the main directory of this repo.
3. Run `zig build -Dnative=true`

### WASM

1. `zig build -Dwasm=true`
2. Serve the conents of the root of this directory with a webserver. If you like python you can run `python -m http.server` and go to http://localhost:8000.

## Usage

The main idea is to implement the methods of `Game`. You then directly interact with the api. Details such as windowing system, graphics system are abstracted away (in this case SDL is powering zigzag, but this can be swapped out for a different system later).

The two methods you must implement are:

`update` where you should update your game state.
`draw` where you should do all of your drawing.

### Graphics

The screen is 128x128 (ala pico8).
Sprites are 8x8, but can be drawn anywhere on the screen.

### Input

There are only 6 buttons supported: A (a), S (s), Up, Down, Left, Right.

You can read the state of them with `btnp` to see if the button has been pressed this frame, or `btn` to see if the button is currently held down.

### Full API Docs

coming soon...

### API Progress (PICO 8 equivalent)

Pico8 api descriptions copied from: [iiviigames.github.io](https://iiviigames.github.io/pico8-api/)

#### Graphics

##### Implemented

```
camera([x, y]) -- set camera position
spr(n, x, y, [w, h], [flip_x], [flip_y]) -- draw sprite (without flip_x and flip_y currently)
```

##### Not Yet Implemented

```
circ(x, y, r, [col]) -- draw circle
circfill(x, y, r, [col]) -- draw filled circle
clip([x, y, w, h]) -- set screen clipping region
cls([col]) -- clear screen; col = clear color
color(col) -- set default color
cursor(x, y) -- set cursor and CR/LF margin position
fget(n, [f]) -- get values of sprite flags
fillp(mask) -- set fill pattern for circ, circfill, rect, rectfill, pset, and line
flip() -- flip screen back buffer (30fps)
fset(n, [f], v) -- set values of sprite flags
line(x0, y0, x1, y1, [col]) -- draw line
oval(x0, y0, x1, y1, [col]) -- draws an ellipse inside of a bounding rectangle
ovalfill(x0, y0, x1, y1, [col]) -- draws a colored ellipse
pal(c0, c1, [p]) -- swaps col 0 to col 1; p = 0 = draw palette; p = 1 = screen palette
palt(col, t) -- set transparency for colour to t (bool)
pget(x, y) -- get pixel colour
print(str, [x, y, [col]]) -- print string
pset(x, y, [col]) -- set pixel colour
rect(x0, y0, x1, y1, [col]) -- draw rectangle
rectfill(x0, y0, x1, y1, [col]) -- draw filled rectangle
sget(x, y) -- get spritesheet pixel colour
sset(x, y, [col]) -- set spritesheet pixel colour
sspr(sx, sy, sw, sh, dx, dy, [dw, dh], [flip_x], [flip_y]) -- draw texture from spritesheet
tline(x0, y0, x1, y1, mx, my, [mdx], [mdy]) -- Draws a textured line between two points, sampling the map for data
```

#### Input

##### Implemented

```
btn([i, [p]]) -- get button i state for player p
btnp([i, [p]]) -- true when the button was not pressed the last frame; delays 4 frames after button held for 15 frames
```

##### Not Yet Implemented

#### Map

##### Implemented

```
map(cel_x, cel_y, sx, sy, cel_w, cel_h, [layer]) -- draw map; layers from flags; sprite 0 is empty
mget(x, y) -- get map value
mset(x, y, v) -- set map value
```

#### Audio

##### Not Yet Implemented

```
music([n, [fade_len, [channel_mask]]]) -- play music; n = -1: stop
sfx(n, [channel, [offset]]) -- play sfx; n = -1: stop in channel; n = -2: release loop in channel
```

## Current Status

Right now building an experemintal port of another project I have worked on (ibebrett) in rust. The initial commits are going to be hacking and trying things out.