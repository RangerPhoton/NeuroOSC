//colors for channel strips
color off = color(0, 0, 0);
color on = color(200, 200, 200);
color label = color(200, 200, 200);
//using integers for slider colors (resulting in grayscale), simplify math for hover colors
int blank = 140; 
int blankline = 160;
int sliderAlpha = 160;

//variables for surface size, so we can change it based on channel count
//also used for waveform size calculation
int surfaceWidth;
int surfaceHeight;

//variables for mouse dragging behaviors - locking permits off-axis mouse moves on sliders
boolean lockMouseX = false;
boolean lockMouseY = false;
float xOffset = 0.0; 
float yOffset = 0.0; 

//variables for mouse hover behaviors
int channel = -1; //active channel, -1 is none
int brighten = 0; //mouse pressed color
int darken = 0; //ghosted

//variables for storing, blending and saving gain presets
float[][] mixerSets; //storage for multiple mixer settings
float[] mixMixer; //target array for combining the mixerSet arrays - the result is then used to set the actual sample player gain inputs
float[] mixWeights = {0.5, 0.5, 0.5, 0.5};  //weighting values for combining mixerSets - this array is driven by the 
float mixMaster = 0.5; // Master output gain 

//variables for 3D input mixer
float mixMixerX = 0.5;
float mixMixerY = 0.5;
float mixMixerZ = 0;

int mixMixerDotX;
int mixMixerDotY;
int mixMixerDotZ;

boolean zAxis = false;

//variables for UI display states
boolean scaleUI = false;
boolean drawControls = false;
boolean controlHandle = false;
boolean constrainSliders = true;

//variables for managing internal states
boolean OSC = true;
int nextMix;
int map = 1;
int lastmap = 3;
int eq = 1;
int lasteq = 3;

//play flag to enable/disable audio processing and dynamic drawing
boolean play = false; //set true here to play soundset immedately on startup


void draw()
{
  background(off);
  if (bgimage) image (img, -targetleft, -targettop);

  //experimental - applying mapping and weighting equations to mixes
  //it may be possible to do all of this with the map() function, and easily store maps in a JSON array
  if (!drawControls || (mixMixes2D && !replaceMix)) {
    if (map == 1 && !mixMixes) {
      mixWeights[0] = 1-mixMixerY;
      mixWeights[1] = mixMixerY;
      mixWeights[2] = mixMixerX;
      mixWeights[3] = 1-mixMixerX;
    }
    if (map == 2 && !mixMixes) {
      mixWeights[0] = 1-mixMixerY*2;
      mixWeights[1] = -0.5+mixMixerY*2;
      mixWeights[2] = -0.5+mixMixerX*2;
      mixWeights[3] = 1-mixMixerX*2;
    }
    if (map == 3 && !mixMixes) {
      mixWeights[0] = map(mixMixerY, 0.5, 0, 0, 0.5);
      mixWeights[1] = map(mixMixerY, 0, 0.5, 0, 0.5);
      mixWeights[2] = map(mixMixerX, 0, 0.5, 0, 0.5);
      mixWeights[3] = map(mixMixerX, 0.5, 0, 0, 0.5);
    }

    // variables for Gaussian function 
    float center; //channel position at peak amplitude
    float sigma; //curve width
    float xfloor = 1/numSamples/2; // limit left edge position 
    float xceil = numSamples-1;  //limit right edge position

    for (int i = 0; i < numSamples; i++) {
      mixMixer[i] = 0;
      if (eq == 1) {
        for (int mix = 0; mix < mixerSets.length; mix++) 
        {
          mixMixer[i] += (mixerSets[mix][i]*2-1)*(mixWeights[mix]);
          if (constrainSliders) mixMixer[i] = constrain(mixMixer[i], 0, 1);
        }
      } else if (eq == 2) {
        for (int mix = 0; mix < mixerSets.length; mix++) 
        {
          mixMixer[i] += ((mixerSets[mix][i])*(mixWeights[mix]));
        }
        mixMixer[i] = mixMixer[i]-0.5;
        if (constrainSliders) mixMixer[i] = constrain(mixMixer[i], 0, 1);
      } else if (eq == 3) {
        for (int mix = 0; mix < mixerSets.length; mix++) 
        {
          mixMixer[i] += map(mixerSets[mix][i], 0, 1, -0.5, 0.5)*mixWeights[mix];
        }
        mixMixer[i] = mixMixer[i]+0.5;
        if (constrainSliders) mixMixer[i] = constrain(mixMixer[i], 0, 1);
      } else if (eq == 4) {   //gaussian function - bypasses mix presets and weight mapping
        center = map(mixMixerX, 0, 1, xfloor, xceil); //map to number of channels, align peak at first and last channel
        sigma = map(mixMixerY, 0, 1, 1.2, 4); //adjust min and max curve width
        mixMixer[i] = ( 1 / sigma*(sqrt(TAU) )) * ( exp(-sq(i - center) / (2*sq(sigma )) ) );
        if (constrainSliders) mixMixer[i] = constrain(mixMixer[i], 0, 1);
      }

      //println("Mix "+mixWeights[0]+" : "+mixWeights[1]+" : "+mixWeights[2]+" : "+mixWeights[3]);
    }
  }

  //draw moving dot 
  stroke(blankline);
  strokeWeight(1);
  fill(on);
  mixMixerDotX = round(map(mixMixerX, 0, 1, 17, width-14))-2;
  if (drawControls) mixMixerDotY = round(map(1-mixMixerY, 0, 1, 40, 186))-5;
  else mixMixerDotY = round(map(1-mixMixerY, 0, 1, 40, height-14))-5;
  ellipse(mixMixerDotX, mixMixerDotY, (ac.out.getValue(0, 1)*80)+2, (ac.out.getValue(0, 1)*80)+2); 

  //draw moving distance ring 
  if (zAxis==true && mixMixerZ>0) {
    stroke(on);
    stroke(on, mixMixerZ*200);
    strokeWeight(3);
    noFill();
    float size = 1-mixMixerZ;
    ellipse(mixMixerDotX, mixMixerDotY, map(size, 0, 1, 150, 15), map(size, 0, 1, 150, 15)); 
    strokeWeight(2);
    if(mixMixerZ>.05) ellipse(mixMixerDotX, mixMixerDotY, map(size, 0, 1, 100, 10), map(size, 0, 1, 100, 10)); 
    strokeWeight(1);
    if(mixMixerZ>.10) ellipse(mixMixerDotX, mixMixerDotY, map(size, 0, 1, 50, 5), map(size, 0, 1, 50, 5));
  }

  if (drawControls) {
    if (height > 330) {
      //Draw reticule and labels for 2D mixer
      strokeWeight(1);
      stroke(off);
      line(width/2, 34, width/2, 182);
      line(14, 108, width-15, 108);
      noFill();
      rect(14, 34, width-14-15, 182-34 );
      textSize(11);
      textAlign(RIGHT, CENTER);
      text(round(mixMixerX*100), width-16, 106);
      textAlign(CENTER, TOP);
      text(round((mixMixerY)*100), width/2, 34);
      textAlign(CENTER, CENTER);
      text(round((mixMixerZ)*100), width/2, 106);
    }

    //mouse-over behaviors
    //note locking to allow for off-axis mouse moves when dragging
    //-1 indicates null selection
    if (mouseY > 210 && mouseY < 310 && !lockMouseY) {  // && !OSC
      for (int i = 0; i <= numSamples; i++) {
        if (mouseX > 4 + i * 30 && mouseX < i * 30 + 26 && !lockMouseX) 
          channel = i;
      }
    } else {
      if (!lockMouseX) {
        channel = -1;
      }
    }

    if (mouseY > 330 && mouseX < 160 && !lockMouseX) {  
      for (int p = 0; p < numPresets; p++) {
        if (mouseY > 330+(p*20) && mouseY < 350+(p*20) && !lockMouseY) {
          nextMix = p;
        }
      }
    } else {
      if (!lockMouseY) {
        nextMix = -1;
      }
    }
  }

  if (drawControls) {
    // draw mix preset controls
    for (int p = 0; p < numPresets; p++)
    {
      fill(off);
      strokeWeight(1);
      stroke(blankline);
      rect(8, 332+p*20, 16, 16, 4, 4, 4, 4);
      rect(28, 332+p*20, 16, 16, 4, 4, 4, 4);

      fill(label);
      textAlign(CENTER, CENTER);
      textSize(13);
      text(p, 16, 338+p*20);
      text("<", 36, 338+p*20);

      strokeWeight(2);
      stroke(blankline);
      fill(on);
      if (nextMix == p) {
        stroke(180 - darken + brighten);
        fill(off);
      } else {
        stroke(blankline - darken);
        fill(off);
      }
      rect(52, 332+p*20, 100, 16, 6, 6, 6, 6);
      noStroke();
      if (nextMix == p) {
        //println(180 + brighten);
        //stroke(180 - darken + brighten);
        fill(180 - darken + brighten);
      } else {
        //stroke(blank - darken);
        fill(blank - darken);
      }
      if (mixWeights[p] > 0) rect(102, 334+p*20, ((mixWeights[p])/4*97), 13, 0, 4, 4, 0);
      else rect(102, 334+p*20, ((mixWeights[p])/4*97), 13, 4, 0, 0, 4);
      stroke(blankline);
      strokeWeight(1);
      line(101, 334+p*20, 101, 347+p*20);
      fill(label);
      textAlign(LEFT, CENTER);
      textSize(11);
      text(round(mixWeights[p]*100), 156, 338+p*20);
    }

    //draw load / save buttons
    textAlign(CENTER, CENTER);
    strokeWeight(1);

    fill(off);
    stroke(blankline);
    rect(210, 410-20, 40, 18, 4, 4, 4, 4);
    fill(label);
    text("Load", 230, 410-12);

    fill(off);
    stroke(blankline);
    rect(260, 410-20, 40, 18, 4, 4, 4, 4);
    fill(label);
    text("Save", 280, 410-12);

    //parameter controls
    textAlign(LEFT, TOP);
    fill(label);
    text("Constrain = "+constrainSliders, 210, 330);
    text("Equation = < "+eq+" >", 210, 350);
    text("Mapping = < "+map+" >", 210, 370);


    //textAlign(CENTER, CENTER);
    //fill(label);
    //text(soundSet, width/2, 10);
  }

  //draw UI access bar
  if (mouseY > 310 && mouseY < 330) {  
    controlHandle = true;
    if (mouseX > 100 && mouseX < width - 100) scaleUI = false;
    else scaleUI = true;
  } else {
    controlHandle = false;
    scaleUI = false;
  }

  if (controlHandle && !lockMouseX && !lockMouseY) {
    fill(off);
    stroke(blankline);
    //rect(0, 330-14, width, 14);
    if (!scaleUI && drawControls) {
      triangle (width/2-4, 330-12, width/2, 330-4, width/2+4, 330-12);
    } 
    if (!scaleUI && !drawControls) {
      triangle (width/2, 330-12, width/2-4, 330-4, width/2+4, 330-4);
    }
    if (scaleUI && height>330) {
      triangle (width-6, 330-12, width-10, 330-4, width-2, 330-4);
      triangle (6, 330-12, 10, 330-4, 2, 330-4);
    } 
    if (scaleUI && height<=330) {
      triangle (width-10, 330-12, width-6, 330-4, width-2, 330-12);
      triangle (10, 330-12, 6, 330-4, 2, 330-12);
    }
  }

  //draw play / stop button
  if (play) {
    stroke(180, 30, 30);
    fill(160, 20, 20);
    rect(width-20, 2, 18, 18, 2, 2, 2, 2);
  } else {
    stroke(30, 180, 30);
    fill(20, 160, 20);
    triangle (width-18, 2, width-18, 20, width-2, 11);
  }

  //draw OSC button
  textSize(12);
  textAlign(CENTER, CENTER);
  if (OSC) {
    fill(10, 100, 10);
    stroke(18, 180, 18);
    rect(width-64, 2, 32, 18, 4, 4, 4, 4);
    fill(20, 200, 20);
    text("OSC", width-47, 10);
    if (!mixMixes && !mixMixes2D) {
      darken = 40;
      brighten = 0;
    } else {
      darken = 0;
      brighten = 40;
    }
  } else {
    fill(off);
    stroke(blankline);
    rect(width-64, 2, 32, 18, 4, 4, 4, 4);
    fill(label);
    text("OSC", width-47, 10);
    darken = 0;
  }

  //Draw main mixer channels
  int i;
  for (i = 0; i <= numSamples; i++)
  {
    //Update gain values from mixMixer
    //print(i+" ");
    if (i < numSamples) gainValue[i].setValue(constrain(mixMixer[i], 0, 1));


    //Draw channel strips for sample players 
    //note use of variables for hover/click colors
    if (drawControls && i < numSamples) {
      strokeWeight(2);
      if (channel == i) {
        stroke(180 - darken + brighten, sliderAlpha);
        fill(off, sliderAlpha);
      } else {
        stroke(blankline - darken, sliderAlpha);
        fill(off, sliderAlpha);
      }
      rect(4 + i * 30, 230, 20, 50, 6, 6, 6, 6); //outline
      noStroke();
      fill(blank - darken, sliderAlpha);
      if (!constrainSliders) rect(6 + i * 30, 279-(mixMixer[i]*47), 17, (mixMixer[i]*47), 4, 4, 4, 4); //unconstrained value

      if (channel == i) {
        //println(180 + brighten);
        //stroke(180 - darken + brighten);
        fill(180 - darken + brighten, sliderAlpha);
      } else {
        //stroke(blank - darken);
        fill(blank - darken, sliderAlpha);
      }
      rect(6 + i * 30, 279-(constrain(mixMixer[i], 0, 1)*47), 17, (constrain(mixMixer[i], 0, 1)*47), 4, 4, 4, 4); //constrained gain value
      //else rect(6 + i * 30, 279-(mixMixer[i]*47), 17, mixMixer[i]*47, 4, 4, 4, 4);
      stroke(blankline, sliderAlpha);
      fill(on, sliderAlpha);
      ellipse(i * 30 + 14, 205, (sp[i].getValue(0, i)*gainValue[i].getValue()*50)+1, (sp[i].getValue(0, i)*gainValue[i].getValue()*50)+1);
      ellipse(i * 30 + 14, 315, (sp[i].getValue(0, i)*50)+1, (sp[i].getValue(0, i)*50)+1);
      fill(label, sliderAlpha);
      textAlign(CENTER, CENTER);
      textSize(11);
      text(round(mixMixer[i]*100), i * 30 + 14, 220);
      textSize(13);
      text(i, i * 30 + 14, 290);
    }

    //Draw channel strip for master gain
    if (drawControls && i == numSamples) {
      strokeWeight(2);
      stroke(blankline, sliderAlpha);
      fill(on, sliderAlpha);
      ellipse(i * 30 + 14, 205, (ac.out.getValue(0, 1)*50)+1, (ac.out.getValue(0, 1)*50)+1);
      if (channel == numSamples) {
        stroke(180 - darken + brighten, sliderAlpha);
        fill(off, sliderAlpha);
      } else {
        stroke(blankline - darken, sliderAlpha);
        fill(off, sliderAlpha);
      }
      rect(4 + i * 30, 230, 20, 50, 6, 6, 6, 6);
      noStroke();
      if (channel == numSamples) {
        //println(180 + brighten);
        //stroke(180 - darken + brighten);
        fill(180 - darken + brighten, sliderAlpha);
      } else {
        //stroke(blank - darken);
        fill(blank - darken, sliderAlpha);
      }
      //rect(6 + i * 30, 279-(gainValueMaster.getValue()*47), 17, (gainValueMaster.getValue()*47), 4, 4, 4, 4);    
      rect(6 + i * 30, 279-(mixMaster*47), 17, (mixMaster*47), 4, 4, 4, 4);    
      fill(label, sliderAlpha);
      textSize(11);
      text(round(mixMaster*100), i * 30 + 14, 220);
      text(round(gainValueMaster.getValue()*100), i * 30 + 14, 312);
      textSize(13);
      text("M", i * 30 + 14, 290);
    }
  }

  gainValueMaster.setValue(mixMaster); 
  reverbGlide.setValue(mixMixerZ);

  //send outgoing OSC messages - 
  //hack: brute force experiments

  //delay(300);
  OscMessage LevelMaster = new OscMessage("/pwm/4");
  LevelMaster.add(ac.out.getValue(0, 1));
  oscP5.send(LevelMaster, myRemoteLocation);
  //println(LevelMaster+" "+ac.out.getValue(0, 1));

  OscMessage GainMaster = new OscMessage("/pwm/5");
  GainMaster.add(gainValueMaster.getValue());
  oscP5.send(GainMaster, myRemoteLocation);
  //println(GainMaster+" "+gainValueMaster.getValue());

  OscMessage Play = new OscMessage("/pwm/6");
  float playflag;
  if (play) playflag = 1;
  else playflag = 0;
  Play.add(playflag);
  oscP5.send(Play, myRemoteLocation); 
  //println(Play);


  //draw audio waveform - adapted from Beads library sample code
  //note addition of scaling, shift and contraints 
  //Beads sample code assumed waveform was centered within a square window!
  if (play) {
    int vshift = 16; //shift waveform up or down in window
    if (drawControls) {
      if (height > 330) vshift = -74-(numPresets*30);
      else vshift = -114;
    }

    float vscale = 1; //scale waveform height
    loadPixels();
    //scan across the pixels
    for (int p = 0; p < width; p++) {
      //for each pixel work out where in the current audio buffer we are
      int buffIndex = p * ac.getBufferSize() / width;
      //then work out the pixel height of the audio data at that point
      // * note addition of scale and shift factors
      int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)*vscale) * (height+vshift) / 2); 
      //draw into Processing's convenient 1-D array of pixels
      // * note addition of constraint to keep pixels within window's total pixel count    
      pixels[constrain(vOffset * width + p, 0, width*height-1)] = on;
      //if(first) {
      //  println(width + " " + height + " " + windowAspect);
      //  first = false;
      //}
    }
    updatePixels();
  }
}

//boolean first = true; //flag for triggering tests on only first loop