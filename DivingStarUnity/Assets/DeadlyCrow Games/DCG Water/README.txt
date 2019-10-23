Hello and thanks, please check out all this important information:

VERSION 1.0:

- New asset, with the following features:
	- Shader DX11 tessellation
	- Planar reflections
	- Reflection probes
	- Realtime mesh deformation, through C# job system.
	- Improved Caustics
	- Improved Underwater effect (WIP)
	- Improved Wet lens effect (WIP)
	- two main shaders, Realistic water and Lowpoly water.
	- Improved buoyancy and physics

---------------------
Quick instructions:
---------------------

1) Regarding the script "DCGWater.cs"

	- Water Mesh Size: This value controls the scale in world units of the generated mesh.
	- Vertex Density: This controls the density of the vertices across the mesh. High values will increase the polycount and also the CPU cost.
	- Water Depth: The distance in world units in the Y axis of the generated water volume.
	- Trigger Offset: This controls how much offset in the Y axis the "Water" trigger would be. This is useful when you have very big waves, 
		so the floating objects stays in a "water zone" and the script can work properly. Also for underwater effects.
	- Update Settings (Button): With this button you will update the generated mesh with all new modified settings.
	- Water Profile: Here is the input of a WaterProfile scriptable object, which contains the behaviour of the water and its materials.
	- Collision Checkbox: When enabled it will turn green and enables the trigger that tells the floating objects that they are in a "water zone".

2) Regarding the "Buoyancy.cs" script:

	*IMPORTANT* Remember you need to have a collider attached to the object to make it work.

	- Density: How dense is the object related to water.
	- Slices Per Axis: How many physical floating points will have the object per axis.
	- Sleep Time: This is a delay with the purpose of not overheat the CPU and produce lag and low fps count.
	- Force Power: This is a mulplier of the forces applied to the object.

--------------------------------
MATERIAL INSTRUCTIONS:
--------------------------------

- Tessellation: You have two sliders that controls the edge length and the phong strength.
- Shore blend distance: this controls the fade between the mesh and any intersection.
- Water normal: input of the water normal texture.
- Normal power: slider that controls how strong is the water normal.
- Larger Waves Normal power: This controls the intensity of a bigger waves generated with the same normal map, to break the visual tiling of the water.
- Gloss: the glossiness of the water.
- Specular power: How intense is the glossiness of the water.
- Invert Coordinates: This checkbox allow you to invert the coordinates that the uv's of the mesh are read. It is useful when you use the materials in custom meshes or in any situation you notice the normals are inverted.
- Water Tint: the tint of the water used in the depth coloring calculation. softer colors are the most realistic ones.
- Scattering Tint: the tint of the fake light scattering produced by the water.
- Density: the density of the water.
- Water Emission: Global water scattering tint intensity.
- Scattering intensity: Intensity of th detailed scattering in the waves.
- Water Height: Height map to displace the water in the Y axis.
- Displacement: Intensity of the displacement controlled by the previous texture.
- Height Offset: Distance offset in the Y axis of the mesh.
- Use script reflection: this checkbox controls wether you want to use reflection probes in the shader, or the "_ReflectionTex" input, which needs to be feed through a script.
- Reflection fresnel: The fresnel value of the reflection. Higher values will decrease the reflection area in the surface.
- Reflection distortion: How much distortion will be applied to the reflection.
- Refraction distortion: How much distortion will be applied to the refraction of the water.
- Refraction Chromatic Aberration: This controls how much color aberration will be applied to the refraction image underneath the water surface.
- Foam: Texture input to be used as foam, in the intersection borders of the mesh.
- Foam Tiling: The tiling scale of the foam.
- Foam Speed: The speed of the foam.
- Foam Distance: this controls how much far away from an intersection the foam border will be rendered.
- Foam Intensity: The intensity of the foam.

Render Queue: Try to leave this value at 2600. If not, do it at your own risk. Keep in mind this will change the rendering order of the water.

********************
***IMPORTANT THINGS***
********************

**Custom ASE inspector of materials is disabled in the shaders, for the people who don't own ASE**
**The Shaders were made to be used with Deferred rendering in Linear Color space.**
**Use HDR on your camera if you experience flipped reflections**
**For mobile projects i do NOT recommend you to use the script reflection with a resolution above 64px, or to not use it at all, and a high poly mesh, Otherwise you will experiencie performance issues.**
**Also for mobile projects it is not recommended to use the mesh deformation feature.**
**Example materials and Prefabs are included in the package in the prefabs folder.**

- Buoyancy script NEED some collider to work, otherwise it will add a meshcollider in the start, i didn't do this automatic because there is a lot of collider options, some may want to use mesh collider, others box, sphere, etc... So you have to add it by yourself.
- To get better results you should work with deffered rendering mode in linear color space, the overall look of the shader is done in a way that looks good on linear color space. But if you are using gamma, just tweak your custom material as needed to get a desired result.

If you have some problem, advice or just want to say something, contact me through my social media:

Facebook:	https://www.facebook.com/deadlycrow.games
Gmail:    	Deadlykrow@gmail.com
Twitter: 	@DeadlyCrowGames

PD: Are you making a game with any of my assets? Please contact me, we are building a big showcase :)

Enjoy :) !

Please do not forget you are not allowed to re-distribute this asset in any way, thats an illegal move, also keep in mind this is my work and my source of living, thanks :) !
