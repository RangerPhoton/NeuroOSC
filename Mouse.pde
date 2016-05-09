//set up mouse behaviors
//total brute force hacking here, need to objectify

//variables for UI modes
boolean replaceMix = false;
boolean storeMix = false;
boolean mixMixes = false;
boolean mixMixes2D = true;
boolean changeMapping = false;
boolean changeEquation = false;

float oldGain;
float oldMixWeight;
float mouseScalingY = 100; //set equal to slider height for 1:1 drag ratio
float mouseScalingX = 100; //set equal to slider height for 1:1 drag ratio


void mousePressed() {
  yOffset = mouseY; 
  xOffset = mouseX; 

  //control bar at bottom of window to display mixer and preset GUI 
  if (controlHandle) {
    if (scaleUI) {
      if (height <= 330){
        surfaceHeight = 330 + (numPresets*20);
        drawControls = true;
      } else surfaceHeight = 330;
      scaleUI();
    } else {
      if (height > 330) {
        surfaceHeight = 330;
        scaleUI();
      }
      drawControls = !drawControls; 
    }
  } 

  //Play button
  if (mouseY < 20 && mouseX > width - 20) {
    if (!play) ac.start();
    else ac.stop();
    play = !play;
  }
  
  //old title-bar soundset selection (replaced with ControlP5 dropdown)
  //if (mouseY < 20 && mouseX < width-100 && mouseX > 100) {
  //   ac.stop();
  //   if (soundSetSelected < sounds.length - 1) soundSetSelected = soundSetSelected + 1;
  //   else soundSetSelected = 0;
  //   soundSet = sounds[soundSetSelected];
  //   setup();
  //}
  
  //OSC button
  if (mouseY < 20 && mouseX > width-64 && mouseX < width-30) {
    OSC = !OSC;
  }

  //behaviors if mixer UI is displayed
  if (drawControls) {
    
    //channel selection and mouse-drag axis locking
    if (channel >= 0 && channel < numSamples) oldGain = mixMixer[channel];
    else if (channel == numSamples) oldGain = gainValueMaster.getValue();
    if (channel >= 0) { 
      lockMouseX = true; 
      mixMixes = mixMixes2D = false; //switches to "manual" channel mixer mode
      //brighten = 40;
    } else {
      lockMouseX = false;
      //brighten = 0;
    }

    //load/save buttons
    if (mouseY > height-20 && mouseX > 210 && mouseX < 250) {
      loadJSON();
    }
    if (mouseY > height-20 && mouseX > 260 && mouseX < 300) {
      saveJSON();
    }

    // hit areas for various mixer controls
    // note that modes change depending on where you click, to prep dragging behaviors    
    if (mouseY > 40 && mouseY < 180) { // 2D mixer drag area
      mixMixes2D = true;  // switches to 2D mix mixer mode
      replaceMix = false;
      lockMouseX = true;
      lockMouseY = true;
    }
    //else  mixMixes2D = false;
    if (mouseY > 330 && mouseX < 30) replaceMix = true; // button to recall a mix preset
    else replaceMix = false;
    if (mouseY > 330 && mouseX > 30 && mouseX < 60) storeMix = true; // store a mix preset
    else storeMix = false;
    if (mouseY > 330 && mouseX > 60 && mouseX < 160 ) {  // mix weight slider area
      mixMixes = true;  //switches to mix mixer mode (weighting controls)
      replaceMix = false;
      lockMouseY = true;
      //constrainSliders = false;
    } else if (mouseY < 330 || mouseX < 210) {
      mixMixes = false;
      //constrainSliders = true;
    }
    
    //mapping and equation controls
    if (mouseY > 330 && mouseY < 350 && mouseX > 210) constrainSliders = !constrainSliders; 
    if (mouseY > 350 && mouseY < 370 && mouseX > 270 && mouseX < 290) eq = constrain(eq-1, 1, lasteq); 
    if (mouseY > 350 && mouseY < 370 && mouseX > 290) eq = constrain(eq+1, 1, 4); 
    if (mouseY > 370 && mouseY < 390 && mouseX > 270 && mouseX < 290) map = constrain(map-1, 1, lastmap); 
    if (mouseY > 370 && mouseY < 390 && mouseX > 290) map = constrain(map+1, 1, 4); 
    //println(mouseX+" "+mouseY);

    // loops for recalling mix preset arrays
    for (int i = 0; i < numSamples; i++) {
      if (replaceMix) {
        mixMixer[i] = mixerSets[nextMix][i];
        if (i == 0) print("Recalling Mix "+nextMix+": ");     
        print(mixerSets[nextMix][i]+" ");
        if (i == numSamples-1) println();
      } else if (storeMix) {
        mixerSets[nextMix][i] = mixMixer[i];
        if (i == 0) print("Storing Mix "+nextMix+": ");     
        print(mixerSets[nextMix][i]+" ");
        if (i == numSamples-1) println();
      } else {
        if (nextMix>=0) oldMixWeight = mixWeights[nextMix];
      }
    }
    //print(mixMixes2D);
  }
}

void mouseDragged() {
  if (drawControls && lockMouseX && channel >= 0) { //mixer channel strip drag areas
    float mouseMove = -(mouseY-yOffset);
    float gainChange = oldGain+(mouseMove/mouseScalingY);
    if (constrainSliders) gainChange = constrain(gainChange, 0, 1);

    if (channel < numSamples) {
      mixMixer[channel] = gainChange;
      //println("Channel "+channel+" gain: "+gainChange);
      //println(mouseMove+ " " + oldGain + " " + newGain + " Channel "+channel+" gain: "+mixMixer[channel]);
    } else {
      gainChange = constrain(gainChange, 0, 1);
      mixMaster = gainChange;
      //gainValueMaster.setValue(gainChange);
      //println("Master gain: "+gainChange);
    }
  } else if (drawControls && mixMixes) { //mix weight drag areas
    float mouseMove = (mouseX-xOffset);
    float mixChange = oldMixWeight+(mouseMove/mouseScalingX);
    if (constrainSliders) mixChange = constrain(mixChange, -2, +2);
    if (nextMix>=0) mixWeights[nextMix] = mixChange;
    //combine mix

    //for (int i = 0; i < numSamples; i++) {
    //  mixMixer[i] = 0;
    //  for (int mix = 0; mix < mixerSets.length; mix++) 
    //  {
    //    mixMixer[i] += (mixerSets[mix][i])*(mixWeights[mix]);
    //    //if (mix==mixerSets.length-1) mixMixer[i] = mixMixer[i]/mixerSets.length;
    //    //if (constrainSliders) mixMixer[i] = constrain(mixMixer[i], 0, 1);
    //  }
    //  //println("Mix "+nextMix+" : "+mixChange);
    //}
  } else if  (!drawControls || mixMixes2D) { // 2D mixer drag area
    mixMixerX = constrain(map(mouseX, 17, surfaceWidth-14, 0, 1), 0, 1);
    if (drawControls) mixMixerY = 1-constrain(map(mouseY, 40, 186, 0, 1), 0, 1);
    else {
      mixMixerY = 1-constrain(map(mouseY, 40, height-14, 0, 1), 0, 1);
      controlHandle = false;
    }
    //println("x:"+mouseX+" "+mixMixerX+" x:"+mouseY+" "+mixMixerY);
    if (!drawControls && !play) {
      ac.start();
      play = !play;
    }
  }
}

void mouseReleased() {
  lockMouseX = 
    lockMouseY = 
    changeMapping = 
    changeEquation = 
    //replaceMix = 
    storeMix = false;
  brighten = 0;
}