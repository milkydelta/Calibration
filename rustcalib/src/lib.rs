mod rcalib;

use godot::prelude::*;

struct CalibExtension;

#[gdextension]
unsafe impl ExtensionLibrary for CalibExtension {}
