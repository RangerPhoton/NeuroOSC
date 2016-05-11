
import beads.*;
import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.*;
//import java.util.Arrays; 

//variables for audio setup in Beads
int numFolders = 0; // how many soundSet subfolders are there in the soundsets/ folder?
int numSamples = 0; // how many samples are in the current folder?
int numPresets = 0; //how many presets have been stored? 
String sourceFile[]; // an array that will contain our sample filenames

//Beads setup
AudioContext ac;
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
//String[] soundSets 
// = {"Tibetan Bowls", "Tibetan Choir", "Indian Drone", "Tanpura", "Digiridrone", 
// "Orchestron", "Aeternitas", "Canyon", "Shruti Box", "Desert Wind", "Summer Night", "Fairy Pond", 
// "Jungle Life", "Tropical Rain", "Crystal Spring", "Distant Thunder", "Fireplace", "Furry Friend", 
// "Comfy Place"};
String[] soundSets = new String[0]; //= {"test"};
int soundSetSelected = 0;
String soundSet ; // = soundSets[soundSetSelected];

void setup()
{
  size(330, 330);
  frameRate(30);
  oscP5 = new OscP5(this, incomingPort);
  myRemoteLocation = new NetAddress(ipAddress, outgoingPort);

  numFolders = 0;
  numSamples = 0;
  numPresets = 0;

  // scan the soundsets/ folder and generate a list of soundSet subfolders
  // select the first soundset and populate the soundset selection dropdown
  File subFolder = new File(sketchPath("") + "soundsets/");
  File[] listOfFolders = subFolder.listFiles();
  for (int i = 0; i < listOfFolders.length; i++)
  {
    if (listOfFolders[i].isDirectory())
    {
      numFolders++; 
      soundSets = splice(soundSets, listOfFolders[i].getName(), numFolders-1);
      println(numFolders+": listitem"+i+": "+listOfFolders[i].getName());
    }
  }  
  soundSet = soundSets[soundSetSelected];
  setupDropdown();

  // count the number of samples and presets in the selected soundSet subfolder
  File folder = new File(sketchPath("") + "soundsets/"+ soundSet + "/");
  File[] listOfFiles = folder.listFiles();
  for (int i = 0; i < listOfFiles.length; i++)
  {
    if (listOfFiles[i].isFile())
    {
      if ( listOfFiles[i].getName().endsWith(".mp3") )
      {
        numSamples++;
      }
    }
  }

  // if no samples are found, then end with an error
  if ( numSamples <= 0 )
  {
    println("no samples found in " + sketchPath("") + "soundsets/"+ soundSet + "/");
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


  // set up arrays to store multi-channel gain presets and the mix mixer target array
  mixerSets = new float[numPresets][numSamples];
  mixMixer = new float[numSamples];
  for (int i = 0; i < numSamples; i++ ) {
    mixMixer[i] = 0.0;
  }   


  // in process: load preset files or generate defaults
  // auto-loading is the eventual desired behavior once everything is working right
  //if (numPresets > 0) {
  //  sourceFile = new String[numSamples];
  //  int preset = 0;
  //  for (int i = 0; i < listOfFiles.length; i++)
  //  {
  //    if (listOfFiles[i].isFile())
  //    {
  //      if ( listOfFiles[i].getName().endsWith(".json") )
  //      {
  //        sourceFile[preset] = listOfFiles[i].getName();
  //        //eventually add json file loading code here
  //        preset++;
  //      }
  //    }
  //  }
  //} else {
    //println("No preset files found in soundSet folder.");
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
  //}



  // Audio setup for Beads library
  // setup arrays of unit generators to accomodate the number of samples to be loaded
  ac = new AudioContext();
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
      sp[count] = new SamplePlayer(ac, new Sample(sketchPath("") + "soundsets/"+ soundSet + "/" + sourceFile[count]));
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

//adapt window to fit UI
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