class RangeSentiment{
  String name;
  Float score;
  color textColor;
  color textColorBright;
  color scoreColorPositive;
  color scoreColorNegative;
  
  RangeSentiment(String name, float score, color scoreColorPositive, color scoreColorNegative){
    this.name= name;
    this.score = score;
    this.scoreColorPositive = scoreColorPositive;
    this.scoreColorNegative = scoreColorNegative;
    textColor = color(102, 102, 102, 255);
    textColorBright = color(211, 211, 211);
  }
  
  public void drawScore(int x, int y, int w, int h){
    //Text
    fill(textColor);
    text(name, x, y);
    
    //BackgroundRect
    fill(textColorBright);
    rect(x,y+10,w,h);
    
    if(score > 0){
      fill(scoreColorPositive);
      noStroke();
      rect(x+w/2, y+10, map(score, 0, 1 , 0, w/2), h);
    }
    
    if (score< 0){
      fill(scoreColorNegative);
      noStroke();
      rect(x, y+10, map(score, 0, 1 , 0, w/2), h);
    }
    
    noFill();
    stroke(textColor);
    strokeWeight(2);
    rect(x,y+10,w,h);
    
    line(x+w/2, y+10, x+w/2, y+10+h);
  }
}