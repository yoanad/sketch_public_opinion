import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;

public class UserMarker extends SimplePointMarker{
  PImage img;
  
  
  
  public UserMarker(Location location){
    super(location);    
    img=loadImage("pin_small_80px.png");
    this.setRadius(0);
  }
  
  public void draw(PGraphics pg, float x, float y){  
    super.draw(pg, x, y);
    pg.pushStyle();    
    //pg.noStroke();
    //pg.fill(200, 200, 0, 100);
    //pg.ellipse(x, y, 40, 40);
    //pg.fill(255, 100);
    //pg.ellipse(x, y, 30, 30);
    pg.imageMode(CENTER);
    pg.image(img, x, y);
    pg.popStyle();
  }
  
  public String getTextOfNearbyTweets(){   
 
    String nearbyTweets= "";    
    for (Marker marker : statusMarkerManager.getMarkers()){
      StatusMarker statusMarker = (StatusMarker)marker;
      statusMarker.setColor(blueTwitter);
      Double distance = this.getDistanceTo(statusMarker.getLocation());
         
        if(distance < 3000.0){          
          statusMarker.setColor(orangeBright);          
          nearbyTweets += "";
          nearbyTweets = statusMarker.getStatus().getText();
        }
    }    
    return nearbyTweets;
  }
  

  
}