
//variables for background image scaling
boolean bgimage = true;
PImage img;
int targetleft;
int targettop;

void scaleUI() {
  bgimage = false;
  background(off);
  surface.setSize(surfaceWidth, surfaceHeight);
  //delay(0);
  bgimage = true;
  //setBG();
}

void setBG()
{
  // load and crop background image to fit
  if (bgimage) {
    try { 
      img = loadImage(sketchPath("") + "/soundsets/"+ soundSet + "/" + "bg.jpg");
    }
    catch(Exception e) { 
      println("Exception while attempting to load image!"); 
      e.printStackTrace();
      exit();
    }
    int srcwidth=img.width;
    int srcheight=img.height;
    int targetwidth = surfaceWidth;
    int targetheight = 330;
    int scalewidth;
    int scaleheight;
    boolean fLetterBox = false;

    int scaleX1 = targetwidth;
    int scaleY1 = (srcheight * targetwidth) / srcwidth;

    // scale to the target height
    int scaleX2 = (srcwidth * targetheight) / srcheight;
    int scaleY2 = targetheight;

    // now figure out which one we should use
    boolean fScaleOnWidth;
    if (scaleX2 > targetwidth) fScaleOnWidth=true;
    else  fScaleOnWidth=false;
    if (fScaleOnWidth) {
      fScaleOnWidth = fLetterBox;
    } else {
      fScaleOnWidth = !fLetterBox;
    }

    if (fScaleOnWidth) {
      scalewidth = floor(scaleX1);
      scaleheight = floor(scaleY1);
    } else {
      scalewidth = floor(scaleX2);
      scaleheight = floor(scaleY2);
    }
    targetleft = -floor((targetwidth - scalewidth) / 2);
    targettop = -floor((targetheight - scaleheight) / 2);

    img.resize(scalewidth, scaleheight);
    //background(0);
    //image (img, -targetleft, -targettop);
    //copy(img, targetleft, targettop, surfaceWidth, surfaceHeight, 0, 0, surfaceWidth, surfaceHeight);

    //println(fScaleOnWidth + " " + width + " " + height + " " + img.width + " " + img.height + " " + targetleft + " " + targettop);
    //background(img);
  }
}