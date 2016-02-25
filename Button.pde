class CustomButton {
  color bcolor;
  int bheight;
  int bwidth;
  int xpos;
  int ypos;
  String text;


  CustomButton(color bcolor, String text, int xpos, int ypos, int bwidth, int bheight) {
    this.bcolor = bcolor;
    this.bwidth = bwidth;
    this.bheight = bheight;
    this.xpos = xpos;
    this.ypos = ypos;
    this.text = text;
  }
}

public void createButton(color bcolor, String text, int xpos, int ypos, int bwidth, int bheight) {
    rect(xpos, ypos, bwidth, bheight);
    pushStyle();
    font = createFont("Raleway-Light-48.vlw", 40);
    textFont(font);
    text (text + " >", xpos/2, ypos/2);
    popStyle();
}