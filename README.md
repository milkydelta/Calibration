# Camera Calibration Tool

name pending.

## Usage

Launch the program

### Choosing a runtime

This is an OpenXR application, so you'll need a runtime, and there's more than a few choices.

The best option is SteamVR, because it supports `XR_EXT_render_model`, which is the OpenXR extension Godot uses to get controller models. You can still calibrate without controller models. I show spheres instead, but you'll have to figure out where those spheres would be on your controllers.

During development, I do/did most of my testing on Monado, using the QWERTY driver.

I have also used the Windows Mixed Reality runtime on Windows 10.

<details>
<summary> A thing to note </summary>

I was able to launch the tool with SteamVR on Windows exactly once. The controller models appeared, and everything was great. Then, I closed it to change the camera. After that, SteamVR broke. The tool would launch, but with no controller tracking, and the headset view was a fully black 16px texture. The same thing then happened with all other OpenXR games, but no OpenVR games. The problem persisted across reboots, and when I switched my runtime to another one and back. Everything worked fine on the WMR runtime.

I don't know if this was because of the tool, if it was something else I did, or if it was entirely coincidental. Just keep that in mind.

If you know how to fix that issue, let me know. I would like to use SteamVR again.
</details>

### Choosing a camera

In the bottom-right is some white text. Click that, and a pop-up menu will appear, with a single entry for each available camera. Choose your camera, and it's feed will appear as the window background, stretched to the window dimensions.

### Choosing a method

There are three ways to do calibration, though only one is finished

The 3-point "Magic Triangle" method will be familiar to anyone who has used existing solutions.

The N-point method is something I'm undecided on. I'd like it to be similar to above in terms of difficulty, but without a camera lens point. Estimating the optical centre from other readings could mean fewer adjustments are required.

The 9-point DLT method uses an algorithm called Direct Linear Transform. Don't ask me to explain what that is. It's apparently somewhat common in camera calibration for computer vision. Given at least 6 points, it will estimate the camera matrix. My Maths skills have atrophied significantly, so instead of writing the algorithm myself in GDScript, I have used an open-source library written in rust. That's why there's a rust GDExtension in the repo. Unfortunately, the camera extrinsics are off, and I don't know why.

### Collecting points

A line of text at the top of the screen will tell you which point is next expected. The + textures are there as guides. Each point should be at the centre of it's corresponding +. The point collection button is `khr/simple_controller`'s `menu` input, which should map to your menu button, unsurprisingly. 

A small red sphere will be left at each point

You may be asked to collect a point at the camera lens. That description is not entirely accurate. The point collected is used as the "optical centre" of the camera, which is where all four frustum lines converge. For smaller cameras, those two locations are roughly the same, within an acceptable margin of error. For larger cameras, the optical centre may be a significant distance behind the lens. The camera's forward vector should still be accurate, so a small adjustment on +Z and -fov should fix it.

### Adjusting the estimation

Once enough points have been collected, point collection is disabled, and the overlaid spectator camera is given the estimated details of your physical camera. In the top left is a panel with some sliders you can use to adjust the camera parameters. Those adjustments are in the Godot coordinate system, so forward is -Z. Distance is adjusted in cm and angles are adjusted in degrees, both with 1 decimal place of precision.

When you're happy with your calibration, press the button in the bottom-right. That'll export it to a file called `externalcamera.cfg`, next to the main executable. Exported coordinates are first converted to the Unity coordinate system.

## Building

Install Godot 4.7

Install a rust toolchain for your platform

For non-Linux builds, install the CameraServer GDExtension from (this repo)[https://github.com/j20001970/godot-cameraserver-extension]

Inside rustcalib, run `cargo build` to build the dlt GDExtension.

That's everything. You can then run the project from the editor, or export it as a standalone build.
