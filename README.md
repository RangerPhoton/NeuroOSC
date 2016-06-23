# NeuroOSC
Multichannel audio neurofeedback tool: OSC driving the Beads library

This is designed as an authoring environment for neurofeedback and biofeedback audio experiences.  For quick experimentation, there's a 3D drag area that emulates the three current primary OSC input channels: /mix/x and /mix/y.  There are also multiple OSC mappings to directly control individual mixer channels.

For this sketch to run, the sketch folder must contain a soundsets/ folder, with at least one subfolder containing multiple .mp3 sample files plus a "bg.jpg" image file that will appear in the UI.  
The sample files will be played in continuous loops, controlled by a mixer UI generated to control the levels of each sample, accessed by a small tool bar at the bottom.  
There is also a mix weighting control UI below the mix that allows the storage and retrieval of multiple multi-channel mix presets, with weighting sliders that can be used to combine the mix presets on-the-fly.  
The weighting values are then controlled via mapping alhorithms from the 3D mixer, which is in turn controllable via OSC paths /mix/x, /mix/y and /mix/z from neurofeedback or biofeedback apps such as NeuroMore.
Load and Save buttons access JSON files in the current soundset folder to store and recall the mix presets and weights.  (next up: store equations and mappings as well).
