class Range{
  String name;
  double score;
  
  Range(String name, double score){
    name ="test";
    score = 0.0;
  }
  
  public void draw(int x, int y){    
    pushStyle();
    fill(255,0,0);
    rect(x,y, 30,30);
    popStyle();
  }
  
  
}