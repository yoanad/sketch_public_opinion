public class UserMarker extends SimplePointMarker {
  PImage img;
  
  public UserMarker(Location location) {
    super(location);    
    img=loadImage("pin_small_80px.png");
    this.setRadius(0);
  }

  public void draw(PGraphics pg, float x, float y) {  
    super.draw(pg, x, y);
    pg.pushStyle();   
    pg.imageMode(CENTER);
    pg.image(img, x, y);
    pg.popStyle();
  }

//with this function the texts of all tweets in the distance of 3000km of the Usermarker are added to a single String
  public String getTextOfNearbyTweets() {   
    String nearbyTweets= "";    
    for (Marker marker : statusMarkerManager.getMarkers()) {
      StatusMarker statusMarker = (StatusMarker)marker;
      statusMarker.setColor(blueTwitter);
      de.fhpotsdam.unfolding.geo.Location markerLocation = new de.fhpotsdam.unfolding.geo.Location (statusMarker.tweet.latitude, statusMarker.tweet.longitude);
      Double distance = this.getDistanceTo(markerLocation);
      if (distance < 3000.0) {          
        statusMarker.setColor(orangeBright);          
        nearbyTweets += "";
        nearbyTweets = statusMarker.tweet.text;
      }
    }    
    return nearbyTweets;
  }

}