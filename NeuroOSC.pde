
//import java.util.Arrays; 
import beads.*;
import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.*;

ControlP5 cp5;

controlP5.ScrollableList d;

//variables needed for osc
OscP5 oscP5;
NetAddress myRemoteLocation;

AudioContext ac;

int numSamples = 0; // how many samples are being loaded?
int numPresets = 0; //how many presets have been stored? 
String sourceFile[]; // an array that will contain our sample filenames

SamplePlayer sp[];
Gain g[];
Glide gainValue[];
Gain gMaster;
Glide gainValueMaster;

// these objects allow us to add a delay effect
//TapIn delayIn;
//TapOut delayOut;
//Gain delayGain;
//Glide delayGlide;

// pointers to soundsets, placed in subfolders of the sketch
String[] sounds = {"Tibetan Bowls", "Tibetan Choir", "Indian Drone", "Tanpura", "Digiridrone", 
  "Orchestron", "Aeternitas", "Canyon", "Shruti Box", "Desert Wind", "Summer Night", "Fairy Pond", 
  "Jungle Life", "Tropical Rain", "Crystal Spring", "Distant Thunder", "Fireplace", "Furry Friend", 
  "Comfy Place"};
int soundSetSelected = 0;
String soundSet = sounds[soundSetSelected];

//play flag to enable/disable audio processing and dynamic drawing
boolean play = false; //set true to play soundset immedately on startup


//variables for storing, blending and saving gain presets
float[][] mixerSets; //storage for multiple mixer settings
float[] mixMixer; //target array for combining mixerSet gain values, drives sample player gain inputs
float[] mixWeights = {0.5, 0.5, 0.5, 0.5};  //weighting values for combining mixerSets
float mixMaster = 0.5;

void setup()
{
  size(330, 330);
  frameRate(30);
  oscP5 = new OscP5(this, incomingPort);
  myRemoteLocation = new NetAddress(ipAddress, outgoingPort);

  soundSet = sounds[soundSetSelected];

  PFont pfont = createFont("Arial", 20, true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont, 241);

  cp5 = new ControlP5(this);
  List l = Arrays.asList(sounds);
  /* add a ScrollableList, by default it behaves like a DropdownList */
  d = cp5.addScrollableList("dropdown")
    .setColorBackground(color(0, 0, 0))
    .setColorForeground(color(60, 60, 60))
    .setPosition(0, 0)
    .setSize(120, 330)
    .setBarHeight(22)
    .setItemHeight(16)
    .addItems(l)
    .close()
    .setCaptionLabel(soundSet)
    .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
    ;

  CColor c = new CColor();
  c.setBackground(color(0, 0, 0));
  // (3)
  // change the font and content of the captionlabels 
  cp5.getController("dropdown")
    .getCaptionLabel()     
    .setFont(font)
    .toUpperCase(false)
    .setSize(13)
    ;
  cp5.getController("dropdown")
    .getValueLabel()
    .setFont(font)
    .toUpperCase(false)
    .setSize(12)
    ;

  // adjust the location of a caption label using the 
  // style property of a controller.
  d.getCaptionLabel().getStyle().marginLeft = 2;
  d.getCaptionLabel().getStyle().marginTop = 4;
  d.getValueLabel().getStyle().marginLeft = 2;
  d.getValueLabel().getStyle().marginTop = 2;

  //ControlP5.printPublicMethodsFor(ScrollableList.class);

  ac = new AudioContext(); // create our AudioContext

  numSamples = 0;
  numPresets = 0;

  // count the number of samples and presets in the /soundSet subfolder
  File folder = new File(sketchPath("") + soundSet + "/");
  File[] listOfFiles = folder.listFiles();
  for (int i = 0; i < listOfFiles.length; i++)
  {
    if (listOfFiles[i].isFile())
    {
      if ( listOfFiles[i].getName().endsWith(".mp3") )
      {
        numSamples++;
      } else if (listOfFiles[i].getName().endsWith(".json")) {
        numPresets++;
      }
    }
  }

  // if no samples are found, then end
  if ( numSamples <= 0 )
  {
    println("no samples found in " + sketchPath("") + soundSet + "/");
    println("exiting...");
    exit();
  }

  // read and store the filename for each sample
  sourceFile = new String[numSamples];
  int count = 0;
  for (int i = 0; i < listOfFiles.length; i++)
  {
    if (i==0) println("Loading "+numSamples+" samples:");

    if (listOfFiles[i].isFile())
    {
      if ( listOfFiles[i].getName().endsWith(".mp3") )
      {
        sourceFile[count] = listOfFiles[i].getName();
        println(listOfFiles[i].getPath());
        count++;
      }
    }
  }


  // set up arrays to store multi-channel gain presets
  mixerSets = new float[numPresets][numSamples];
  mixMixer = new float[numSamples];
  for (int i = 0; i < numSamples; i++ ) {
    mixMixer[i] = 0.0;
  }   


  //either load preset files or generate defaults
  if (numPresets > 0) {
    sourceFile = new String[numSamples];
    int preset = 0;
    for (int i = 0; i < listOfFiles.length; i++)
    {
      if (listOfFiles[i].isFile())
      {
        if ( listOfFiles[i].getName().endsWith(".json") )
        {
          sourceFile[preset] = listOfFiles[i].getName();
          //add json file loading code here
          preset++;
        }
      }
    }
  } else {
    println("No preset files found in soundSet folder.");
    println("Generating default presets for " + numSamples + " samples.");

    numPresets = 4;
    mixerSets = new float[numPresets][numSamples];

    for (int i = 0; i < numSamples; i++ ) {
      mixerSets[0][i] = 0;
      mixerSets[1][i] = 1;
      mixerSets[2][i] = float(i)/(numSamples-1);
      mixerSets[3][i] = (1.0-(numSamples-1)/numSamples) - float(i)/(numSamples-1);  //hmph. float math errors?
      //if (i == 0) print("Presets: ");     
      //print(mixerSets[2][i]+" ");
      //if (i == numSamples-1) println();
    }
  }




  // setup arrays of unit generators to accomodate the number of samples to be loaded
  g = new Gain[numSamples];
  gainValue = new Glide[numSamples];
  sp = new SamplePlayer[numSamples];

  //set up master gain control
  gainValueMaster = new Glide(ac, 0.5);
  gainValueMaster.setGlideTime(200);
  gMaster = new Gain(ac, 1, gainValueMaster);
  ac.out.addInput(gMaster);

  /*
  // set up our delay - this is just for taste, to fill out the texture  
   delayIn = new TapIn(ac, 4000);
   delayOut = new TapOut(ac, delayIn, 100.0);
   delayGain = new Gain(ac, 1, 0.15);
   delayGlide = new Glide(ac, 1);
   delayGlide.setGlideTime(200);
   delayGain.addInput(delayOut);
   
   ac.out.addInput(delayGain); // connect the delay to the master output
   */

  // enclose the file-loading in a try-catch block
  try {  
    // run through each file
    for ( count = 0; count < numSamples; count++ )
    {
      // create array of SamplePlayers that will run each file
      sp[count] = new SamplePlayer(ac, new Sample(sketchPath("") + soundSet + "/" + sourceFile[count]));
      //sp[count].setLoopPointsFraction(0.0, 1.0);
      sp[count].setKillOnEnd(false);
      sp[count].setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

      // these unit generators will control aspects of the sample player
      gainValue[count] = new Glide(ac, 0);
      gainValue[count].setGlideTime(100);
      g[count] = new Gain(ac, 1, gainValue[count]);

      g[count].addInput(sp[count]);

      // finally, connect this chain to the delay and to the main out    
      //delayIn.addInput(g[count]);

      gMaster.addInput(g[count]);
    }
  }
  // if there is an error while loading the samples
  catch(Exception e)
  {
    // show that error in the space underneath the processing code
    println("Exception while attempting to load sample!");
    e.printStackTrace();
    exit();
  }

  surfaceWidth = max((numSamples) * 30 + 30, 330);
  if (drawControls) surfaceHeight = 330 + (numPresets*20);
  else surfaceHeight = 330;
  surface.setSize(surfaceWidth, surfaceHeight);

  setBG();

  // begin audio processing
  if (play) ac.start();

  for ( count = 0; count < numSamples; count++ )
  {
    sp[count].start();
  }
}

void keyPressed()
{ 
  if (key == ' ') {
    if (!play) ac.start();
    else ac.stop();
    play = !play;
  }
}