import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;

public class StatusMarker extends SimplePointMarker{
  Status status;
  
  
  public StatusMarker(Location location, Status status){
    super(location);
    this.status= status;
    
  }
  
  public void draw(PGraphics pg, float x, float y){
  this.setRadius(map(this.getStatus().getUser().getFollowersCount(), 0, 100000, 5, 100) );
    super.draw(pg, x, y);
    pg.pushStyle();    
    pg.fill(255,0,0);    
    if(this.isSelected() == true){        
      pg.fill(0,0,0);
      pg.text(this.getStatus().getUser().getName(), this.getScreenPosition(map).x, this.getScreenPosition(map).y -30, 100, 100);     
      pg.text(this.getStatus().getText(), this.getScreenPosition(map).x, this.getScreenPosition(map).y, 100, 100);
      //this.getStatus().getUser().
    }
    pg.popStyle();
  }
  
  public Status getStatus(){
    return status;
  }
  
  public void setStatus(Status status){
    this.status= status;
  }
  
  public void displayTweet(){
    
  }
  
}