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


    //println(oscFloatValue);
    //int oscValue = round(oscFloatValue);
    //if(theOscMessage.addrPattern().equals("/audio/1") == true)
    //{
    //   gainValue[0].setValue(oscFloatValue);
    //   gainValue[1].setValue(oscFloatValue);
    //   gainValue[2].setValue(oscFloatValue);
    //   println("Channels 1 2 set to "+oscFloatValue);
    //}
    //if(theOscMessage.addrPattern().equals("/audio/2") == true)
    //{
    //   gainValue[3].setValue(oscFloatValue);
    //   gainValue[4].setValue(oscFloatValue);
    //   gainValue[5].setValue(oscFloatValue);
    //   println("Channels 3 4 set to "+oscFloatValue);
    //}
    //if(theOscMessage.addrPattern().equals("/audio/3") == true)
    //{
    //   gainValue[6].setValue(oscFloatValue);
    //   gainValue[7].setValue(oscFloatValue);
    //   gainValue[8].setValue(oscFloatValue);
    //   println("Channels 5 6 set to "+oscFloatValue);
    //}
    //if(theOscMessage.addrPattern().equals("/audio/4") == true)
    //{
    //   //delayGlide.setValue(oscFloatValue);
    //   gainValue[9].setValue(oscFloatValue);
    //   println("Channels 9 10  set to "+gainValue[9].getValue());
    //}
    //if(theOscMessage.addrPattern().equals("/audio/M") == true)
    //{
    //   //delayGlide.setValue(oscFloatValue);
    //   gainValueMaster.setValue(oscFloatValue);
    //   println("Master set to "+gainValueMaster.getValue());
    //}
  }
}