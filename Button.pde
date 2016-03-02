//to be used be used for future advancements
class CustomButton {
  color bcolor;
  int bheight;
  int bwidth;
  int xpos;
  int ypos;
  String text;
  int fontsize;

  CustomButton(color bcolor, String text, int xpos, int ypos, int bwidth, int bheight, int fontsize) {
    this.bcolor = bcolor;
    this.bwidth = bwidth;
    this.bheight = bheight;
    this.xpos = xpos;
    this.ypos = ypos;
    this.text = text;
    this.fontsize = fontsize;
  }
}

public void createButton(color bcolor, String text, int xpos, int ypos, int bwidth, int bheight, int fontsize) {
  pushStyle();
  stroke(255);
  rect(xpos, ypos, bwidth, bheight);
  popStyle();
  pushStyle();
  fill(255);
  font = createFont("Raleway-Light-48.vlw", fontsize);
  textFont(font);
  text (text, xpos+bwidth/2, ypos+bheight/2+fontsize/2);
  textAlign(CENTER);
  popStyle();
}