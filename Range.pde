class Range {
  String name;
  Float score;
  //Float2 score2;
  color textColor;
  color textColorBright;
  color scoreColor;

  Range(String name, float score, color scoreColor) {
    this.name= name;
    this.score = score;
    this.scoreColor = scoreColor;
    textColor = color(102, 102, 102, 255);
    textColorBright = color(211, 211, 211);
  }

  public void draw() {
  }



  public void drawRange(float x, float y, float w, float h) {

    //Text
    font = createFont("Raleway-Light-48.vlw", 40);
    textFont(font);
    fill(255,255,255);
    //textAlign(CENTER);
    //text(name, x, y);
    //fill(blueTwitter);
    textAlign(LEFT);
    text(name, x, y);


    //BackgroundRect
    fill(textColorBright);
    stroke(textColor);
    strokeWeight(2);
    rect(x, y+15, w, h);

    //Rect of Score
    fill(scoreColor, 255);
    noStroke();
    rect(x, y+15, map(score, 0, 1, 0, w), h);

    /*
  //Rect of Score2
     fill(scoreColor, 50);
     noStroke();
     rect(x, y+10, map(score2, 0, 1 , 0, w), h);
     */

    noFill();
    stroke(textColor);
    strokeWeight(2);
    rect(x, y+15, w, h);

    ////fill(textColor);
    //fill(255, 255, 255, 200);
    //textAlign(LEFT);
    //text(name, x, y+40);
  }  

  public void setScore(Float score) {
    this.score = score;
  }

  public void setColor(color scoreColor) {
    this.scoreColor = scoreColor;
  }
}