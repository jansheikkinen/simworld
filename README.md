# simworld

a (likely CLI-based) simulated natural environment written in rust


## ideas

### engine

+ library-esque engine in rust, with frontend and mods all written in lua
  + lua chosen over rhai predominantly because i'm more familiar with it, and
  it has first-class function support, which rhai doesn't
+ tick-based, with separate rendering and simulation threads
+ save/load/create worlds
+ mod api written such that modded creatures/biomes/etc can hook into general
  categories, to make it easy for mods to interop.
  + i.e. make it easy to define carnivores and herbivores, so that creatures
  labelled as carnivores automatically eat anything declared as an herbivore
  + but also make it so a creature can also specifically add custom interop with
  mods, to add extra functionality when both are present
+ way to read stats about world and specific creatures
+ renderer should be as self-contained as possible, such that little-to-nothing
  extra should be done outside the renderer to get both gui and cli rendering
+ level editor?


### creatures

+ mods to add new creatures with custom AI and everything
+ hook into external attribute mods, such that a common interface is provided
  for both sides of two or more creatures' interactions in one place
  + i.e. a poison attribute that gives an interface both for poisonous creatures
  *and* creatures that eat poisonous creatures, allowing you to specify poison
  resistance and the like, if desired
  + attributes should be modifiable at runtime, for things like status effects
+ stats:
  + health
    + disease?
    + body part health?
    + lifespan can be represented implicitly as a gradual decline of health
  + hunger
  + thirst
+ line of sight


### environment

+ full 3d world
  + just a 2d tile-based world with tile heights; no caves
+ climate factors such as weather, temperature, and seasons
+ day/night cycles
+ biomes and terrain generation
  + akin to factorio for ease of representaion in terminal?
  + how should it act when two terrain gen mods are installed?
    + attempt to run both at once?
    + force player to select one at world creation?
    + add specific requirement for mods to define some way to interop, such that
    they all dynamically create one unified terrain generator?


## design
