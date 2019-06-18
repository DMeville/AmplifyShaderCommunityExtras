Who: Created by DMeville

What: Implimentation of "proper" refraction, where objects above the surface are masked out from being refracted (like normal unity refraction does).
Based on the tutorial here: https://catlikecoding.com/unity/tutorials/flow/looking-through-water/


Found from the thread here: http://amplify.pt/forum/viewtopic.php?f=23&t=1038#p4581

Depth blend is refracted correctly too, allowing you to make underwater objects foggy, but still refracted correctly.
All the heavy lifting is done in a custom expression because I couldn't make ASE work with the stuff required to make this work
See the additional surface options and additional directives on the shader. We have to inject the declaration of the depth texture here, and hook into the final color function to reset the alpha so that we can change the surface opacity correctly

Can use the included MirrorReflection script (for the unify wiki) to have planar reflections on the shader