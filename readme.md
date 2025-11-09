# MothCore
A standardized skeleton for MothCat Godot projects. Gameplay independent, focused on infrastructure and utilities for production-ready games. Targeted for Steam but will support other platforms as the need arises. Includes a first-person shooter framework that can be easily removed 

## File Structure Overview
In general, follow and mimic the file structure provided in MothCore already. The basic philosophy behind why things are where they are:
- Things that work together belong together. This means that if you have a creature, its art, scripts, and anything else belong in that creature's own folder.
- When something is used in multiple places, it then belongs in a common folder that makes sense, mimicking the heirarchy of how the file is used. Example: an `enemies` folder has the `enemy.gd` script in it. Each specific type of enemy has its own folder within `enemies`.
- You can make an organizing subfolder as needed. Example: creature has a large number of models and textures - you can simply make a `textures` folder within the creature's folder to keep things organized.

The whole point is to spend less timing looking between folders to link things together, and just look for the folder that your subject belongs in. This should also make it easier for artists to simply export working art binaries to the adjacent folder instead of looking for a particular place.


## Naming Conventions
|Type|	Convention|	Info|
|-|-|-|
|File names|	snake_case|	yaml_parsed.gd|
|class_name|	PascalCase	|YAMLParser
|Node names|	PascalCase	|
|Functions|	snake_case	|
|Variables|	snake_case	|
|Signals|	snake_case|	always in past tense "door_opened"
|Constants|	CONSTANT_CASE	|
|enum names|	PascalCase	|
|enum members|	CONSTANT_CASE	|

**Prepend a single underscore (_) to virtual methods functions the user must override, private functions, and private variables.**

### Special Naming Conventions

**.TRES Files**  
Since resources all share the .tres file extension, it may be useful to add prefixes to the file name to visually group and distinguish different types. It doesn't matter what they are, as long as they don't conflict and are consistent. This is especially true for non-built in resource types, since they might not have custom icons. For example:
- SpatialMaterial resource: `mat_dirt.tres`
- WeaponResource : `wep_revolver.tres`

**Scene Inheritance**  
When creating a scene that is meant to be used _exclusively_ as an inherited scene, use `base_` as a prefix. Ie, `base_weapon.tscn` would be the scene that all other weapon scenes inherit from.

## Code Order
#### Meta
1. tool
2. class_name
3. extends
4. `## docstring`

#### Members
4. signals
06. enums
07. constants
08. exported variables
09. public variables
10. private variables
11. onready variables

#### Methods
12. optional built-in virtual _init method
13. built-in virtual _ready method
14. remaining built-in virtual methods
15. public methods
16. private methods

## Options and Settings
There are 3 different option types: 

- **Game Settings**: These are things like the controller rebindings, invert look, etc etc. These are cloud synced.
- **System Settings**: These are things like graphics settings that should be system-specific, ie if the user has 2 different computers. These are non cloud synced.
- **Save Games**: This is for gameplay content to be saved, and there can be multiple of them per user. These are cloud synced.

### Implementing a new setting
1. Go into the correct resource (game or system) for the option you want to add, and create a variable with a setter (and getter if needed).

2. The setter should apply the new setting if needed and call the `write()` function to save the change.

3. Add the appropriate option type that extends `BaseOption` to the option menu. Set the `option_identifier` to the exact name of the variable you made in the resource and make sure the `option_type` matches the resource as well.


## Importing and Managing 3D Assets
The objective here is to have EVERYTHING in the Godot project and on version control. That means Git LFS for tracking blend files, substance painter, etc. It also means that all art files follow the same rules for organization: they belong in the folder they are used in. This means that if a texture file is used for a 3d model in game, the exact same texture file should be referenced from the blender file, substance painter, etc.  

**How Do?**
- We use exported GLTF files. In Blender, you should be able to export with mostly default GLTF settings, except set `geometry > material > images` to `none`.
    - This can be set on the Godot side too but it just creates a duplicate PNG at first which is annoying
- In most cases, just export all the contents of the blend file to the GLTF. Then use Godot importer to skip any objects you didn't actually want to import.
- The blend file and exported GLTF should always be in the same folder.
- You will need to extract the materials and then set them up again in Godot. I am sorry but this is the only way to prevent duplication of texture files. You should only have to do it once.
- Extract animations to files, preserve custom tracks, and then add any custom functions/tracks to the animation files. This way we can add gameplay effects to the animation and still be able to edit the anim.
- Create an inherited scene from the GLTF. Then you can add things like bone attachments and anything else. THIS is the scene that is used in-game.

Now you can edit your blend file at any time and export it, and everything you did in Godot will be preserved and applied on top of whatever you changed in Blender.

> The main reason we aren't just using the blend file directly is there is no way around the duplication of texture pngs in the import settings. There are several cascading bugs and nuisances caused by this so, long story short - I tried. GLTF until I verify several Godot bugs have been fixed.
