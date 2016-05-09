
//dropdown menu currently reloads everything via the setup function 
//eventually be nice to make this more objective

ControlP5 cp5;
controlP5.ScrollableList d;

void dropdown(int n) {
  /* request the selected item based on index n */
  println(n, cp5.get(ScrollableList.class, "dropdown").getItem(n).get("name").toString());
  ac.stop();
  soundSetSelected = n;
  cp5.get(ScrollableList.class, "dropdown").remove();
  //soundSet = cp5.get(ScrollableList.class, "dropdown").getItem(n).get("name").toString();
  //cp5.get(ScrollableList.class, "dropdown").setCaptionLabel(soundSet);
  
  setup();

  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable 
   */

  //CColor c = new CColor();
  //c.setBackground(color(255,0,0));
  //cp5.get(ScrollableList.class, "dropdown").getItem(n).put("color", c);
}

  //complicated crap to make ControlP5 dropdown not look shitty - be nice to replace it or abstract it
void setupDropdown(){
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
}