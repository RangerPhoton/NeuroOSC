JSONArray mixesOut;
JSONArray mixWeightsOut;
JSONArray mixAxesOut;

void saveJSON() {
  mixesOut = new JSONArray();
  JSONArray mix;
  for (int m = 0; m < mixerSets.length; m++) { 
    mix = new JSONArray();
    for (int c = 0; c < mixerSets[m].length; c++) {       
      JSONObject gains = new JSONObject();
      gains.setFloat("ch"+c, mixerSets[m][c]);      
      mix.setJSONObject(c, gains);
      //mix.setFloat(c, mixerSets[m][c]);
    }
    mixesOut.setJSONArray(m, mix);
  }
  saveJSONArray(mixesOut, "/soundsets/"+ soundSet + "/data/mixerSets.json");
  println(mixesOut);


  mixWeightsOut = new JSONArray();
  for (int i = 0; i < mixWeights.length; i++) { 
    JSONObject weights = new JSONObject();
    weights.setFloat("w"+i, mixWeights[i]);      
    mixWeightsOut.setJSONObject(i, weights);
    //mixWeightsOut.setFloat(m, mixWeights[i]);
  }
  saveJSONArray(mixWeightsOut, "/soundsets/"+ soundSet + "/data/mixWeights.json");
  println(mixWeightsOut);
  
}




JSONArray weightsin;
JSONArray mixesin;

void loadJSON() {

  mixesin = loadJSONArray("/soundsets/"+ soundSet + "/data/mixerSets.json");

  for (int m = 0; m < mixesin.size(); m++) {
    if (m == 0) println("Loading MixerSets: ");
    print("Set " + m + ": ");
    JSONArray mixes = mixesin.getJSONArray(m); 
    for (int c = 0; c < numSamples; c++) { 
      JSONObject mix = mixes.getJSONObject(c);
      //println(mix);
      mixerSets[m][c] = mix.getFloat("ch"+c);
      print(mix.getFloat("ch"+c)+" ");
    }
    
    println();
  }
  
  weightsin = loadJSONArray("/soundsets/"+ soundSet + "/data/mixWeights.json");

  for (int i = 0; i < weightsin.size(); i++) {
    if (i == 0) println("Loading mixWeights: ");

    JSONObject item = weightsin.getJSONObject(i); 
    mixWeights[i] = item.getFloat("w"+i);
    //println(item);
    print(mixWeights[i]+" ");
  }
  
}