//variables needed for osc setup
OscP5 oscP5;
NetAddress myRemoteLocation;

//set/change port numbers here
int incomingPort = 13000;
int outgoingPort = 12001;
//set/change the IP address that the OSC data is being sent to
//127.0.0.1 is the local address (for sending osc to an application on the same computer)
String ipAddress = "127.0.0.1";

void oscEvent(OscMessage theOscMessage) 
{
  if (OSC) { // && play
    // print the address pattern and the typetag of the received OscMessage
    //print("### received an osc message.");
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //print(" typetag: "+theOscMessage.typetag());
    //print(" value: "+theOscMessage.get(0).floatValue() +"\n");
    //-----------------------------------------------------------------------

    int i;
    float oscFloatValue = theOscMessage.get(0).floatValue(); //sets the incoming value of the OSC message to the oscValue variable
    oscFloatValue = max(min(oscFloatValue, 1), 0);

    if (theOscMessage.addrPattern().equals("/mix/x")) mixMixerX = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/mix/y")) mixMixerY = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/mix/z")) {
      if (!zAxis) zAxis = true;
      mixMixerZ = oscFloatValue;
      mixMaster = map(oscFloatValue, 0, 1, 0.2, 0.7);
    }
    
    if (theOscMessage.addrPattern().equals("/leap/x")) mixMixerX = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/leap/y")) mixMixerY = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/leap/z")) {
      if (!zAxis) zAxis = true;
      mixMixerZ = oscFloatValue;
      mixMaster = map(1-oscFloatValue, 0, 1, 0.1, 0.7);
    }
    if (theOscMessage.addrPattern().equals("/metaverse/x")) mixMixerX = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/metaverse/y")) mixMixerY = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/metaverse/z")) {
      if (!zAxis) zAxis = true;
      mixMixerZ = 1-oscFloatValue;
      mixMaster = map(oscFloatValue, 0, 1, 0.1, 0.7);
    }

    if (!mixMixes && !mixMixes2D) {
      for (i = 0; i < numSamples; i++) {
        if (theOscMessage.addrPattern().equals("/audio/"+i) == true) mixMixer[i] = oscFloatValue;
      }
    }

    if(theOscMessage.addrPattern().equals("/audio/M") == true)
    {
      gainValueMaster.setValue(oscFloatValue);
    }
  }
}