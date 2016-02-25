import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;

public class StatusMarker extends SimplePointMarker{
  Tweet tweet;
  
  
  public StatusMarker(Location location, Tweet tweet){
    super(location);
    this.tweet= tweet;
    
  }
  
  public void draw(PGraphics pg, float x, float y){
  this.setRadius(map(tweet.followersCount, 0, 100000, 5, 30) );
    super.draw(pg, x, y);
    pg.pushStyle();          
    if(this.isSelected() == true){        
      pg.fill(0,0,0);
      pg.text(tweet.username, this.getScreenPosition(map).x, this.getScreenPosition(map).y -30, 100, 100);     
      pg.text(tweet.text, this.getScreenPosition(map).x, this.getScreenPosition(map).y, 100, 100);
      //this.getTweet().getUser().
    }
    pg.popStyle();
  }
}