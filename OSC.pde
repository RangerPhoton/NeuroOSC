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
    oscFloatValue = min(oscFloatValue, 1);

    if (theOscMessage.addrPattern().equals("/mix/x") == true) mixMixerX = oscFloatValue;
    if (theOscMessage.addrPattern().equals("/mix/y") == true) mixMixerY = 1-oscFloatValue;

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