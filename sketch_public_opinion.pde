import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;
import java.net.URLEncoder;


ConfigurationBuilder cb = new ConfigurationBuilder();
ConfigurationBuilder cb_search = new ConfigurationBuilder();
Query queryForTwitter;
FilterQuery keyword = new FilterQuery();
QueryResult result;
TwitterStream twitterStream;
Twitter twitter;
Query query;
String queryText = "syria";
UnfoldingMap map;
de.fhpotsdam.unfolding.geo.Location locTweet;
de.fhpotsdam.unfolding.geo.Location locRetweet;
de.fhpotsdam.unfolding.geo.Location locTweetSearch;
double latitude, longitude; 
GeoLocation location;
TweetsResources tweetsResources;
List <StatusMarker> statusMarkerBuffer;
List <SimpleLinesMarker> simpleLinesBuffer;

SimpleLinesMarker linesMarker;
int markerAlpha;



void setup () {
  
  //TWITTER
  //twitter authentication Yoana
  /*cb.setOAuthConsumerKey("OXRFgb05gL9NNfIRn3x0NhVX3");
  cb.setOAuthConsumerSecret("H2v8AOLfYYP6PcI1WCDJSxqZmAwtjQFhbBbtCTsGTPlHawXjns");
  cb.setOAuthAccessToken("1827972638-jBZG9XR43ZG3YdBEa3BMfjZU2kx00bo4pNuD92B");
  cb.setOAuthAccessTokenSecret("H0LRvCSlGs6CmG1UV6gqmaJE7fzwEFmM19IhBfS9JH3PR");*/
  
  //Anna
  cb.setOAuthConsumerKey("uk9ggy2gw01K7Zb5J1CDMVegG");
  cb.setOAuthConsumerSecret("kCPUf1qyJAnfsk0u3G83ujdcPAPSdVOpfN5rFKQW0w7ppZOpjJ");
  cb.setOAuthAccessToken("47693725-KGgz1DzwpoDrWsgqvuVnl8q2tflux5NPQaxPr8qfb");
  cb.setOAuthAccessTokenSecret("nmuWHccelSJcsA3KEDtCh4ikxfVHIkAkAVCMXt2RQUp20");
  
  
  //TwitterStreamingAPI
  //start stream
  TwitterStream twitterStream = new TwitterStreamFactory( cb.build()
                                          ).getInstance();      
  //listen to tweets in the stream 
  twitterStream.addListener(listener);

  twitterStream.filter("syria", "سوريا", "syrien", "siria", "Сирия", "Tanjung", "Syrie", "सीरिया", "叙利亚", "シリア");


  //TwitterSearchAPI    
  Twitter twitter = new TwitterFactory (cb_search.build()).getInstance();
  //start search
  try{  

    Query query = new Query (queryText);
    query.setSince("2016-22-02");

    result = twitter.search(query);
  }catch (TwitterException te){
    println("Can't find"+query);
  }
  
  //searchTweetsAndGetLocation();
  //new query
  //TODO YOANA: use a global query variable here 
 //setup Tweet Buffer
 
  
  //setup canvas
  size(920,640, P2D);
  background(0);
   
  //setup default map
  map = new UnfoldingMap(this, new MapBox.WorldLightProvider());
  
  //default map
  MapUtils.createDefaultEventDispatcher(this,map);  
  
  //Setup buffer
  statusMarkerBuffer = new ArrayList<StatusMarker>();
  simpleLinesBuffer = new ArrayList<SimpleLinesMarker>();
  
  int markerAlpha= 200;
  
}

//awesome graphic visualisation is handled here
void draw() {
  background(0);
   //searchTweetsAndGetLocation();
  //draw map
  for (int i = 0; i < statusMarkerBuffer.size(); i++){
    map.addMarkers(statusMarkerBuffer.get(i));
  }
  
  for (int i = 0; i < simpleLinesBuffer.size(); i++){
    map.addMarkers(simpleLinesBuffer.get(i));
  }
  

  //searchTweetsAndGetLocation();
  map.draw();  
  
}



/*public void searchTweetsAndGetLocation() {
    List<Status> searchStatuses = result.getTweets();
    for (int i=0; i<searchStatuses.size(); i++) {           
        try {        
          de.fhpotsdam.unfolding.geo.Location locTweetSearch = getLocation(status);        
          color markerColorSearch = color(0,255,0);
          createMarkers(locTweetSearch.getLat(), locTweetSearch.getLon(), markerColorSearch);
                
          
        
        }catch (NullPointerException ne){
          println(ne + "Couldn't load Status");
        }
    }
}*/

  
//Check Twitterstatus or if not available TwitterUser for Location
public de.fhpotsdam.unfolding.geo.Location getLocation(Status status){
  try {      
        //println(status.getGeoLocation());
        GeoLocation location = status.getGeoLocation();
        latitude = location.getLatitude();
        longitude= location.getLongitude();
        locTweet= new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
        
      } catch(NullPointerException ne) {
    //if there is no Geolocation of tweet available check, if there is further information about the place      
      if(status.getPlace()!= null){
        String googlePlace = URLEncoder.encode(status.getPlace().getFullName());  
        checkGoogleApi(googlePlace);          
      }else if (status.getUser().getLocation() != null){
        String googlePlace = URLEncoder.encode(status.getUser().getLocation());   
        checkGoogleApi(googlePlace);          
      }      
    }    
    return locTweet;
}

//Look for Geoposition by using Google Search API
public de.fhpotsdam.unfolding.geo.Location checkGoogleApi(String googlePlace){    
    try{
        println(googlePlace);
        processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="+googlePlace+"&key=AIzaSyCGsHm4Drt5aRV3NcRiiTbQaEg1i3l7R0I");
        processing.data.JSONArray googleResultsArr = google.getJSONArray("results");
        processing.data.JSONObject googleComponents = googleResultsArr.getJSONObject(0);
        processing.data.JSONObject googleGeometry = googleComponents.getJSONObject("geometry");
        processing.data.JSONObject googleLocation = googleGeometry.getJSONObject("location");
        latitude = googleLocation.getDouble("lat");
        longitude = googleLocation.getFloat("lng");        
        locTweet= new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
        
    }
    catch (RuntimeException re){
      //if google finds no place according to the user's place information do this
      println(re + "Google Api Key blocked");
      locTweet= new de.fhpotsdam.unfolding.geo.Location(0, 0);
    }    
    return locTweet;
}

public void mouseClicked() {
    StatusMarker hitMarker = (StatusMarker)map.getFirstHitMarker(mouseX, mouseY);
    if (hitMarker != null) {
        // Select current marker 
        for (Marker marker : map.getMarkers()) {
            marker.setSelected(false);
        }
        hitMarker.setSelected(true); 
    } else {
      de.fhpotsdam.unfolding.geo.Location userMarkerLocation = new de.fhpotsdam.unfolding.geo.Location(map.getLocationFromScreenPosition(mouseX, mouseY));        
      SimplePointMarker userMarker = new SimplePointMarker(userMarkerLocation);
      userMarker.setId("usermarker");      
      for(Marker marker: map.getMarkers()){ 
        try{
          if (marker.getId() == "usermarker"){
            userMarker.setLocation(userMarkerLocation);            
          }
        }catch(NullPointerException ne){
          
        }          
      }
      map.addMarkers(userMarker);
      
      
          
        
        
        // Deselect all other markers
        for (Marker marker : map.getMarkers()) {
            marker.setSelected(false);
        }
    }
}



public void createMarkers(double latitude, double longitude, color markerColor, Status status){
  if ((latitude != 0)&&(longitude !=0)){    
      de.fhpotsdam.unfolding.geo.Location loc = new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
      StatusMarker marker = new StatusMarker(loc, status);      
      marker.setColor(markerColor);
      marker.setStrokeWeight(0);      
      marker.setRadius(10);      
      statusMarkerBuffer.add(marker);
      //map.addMarkers(marker); 
      
     }
}

//Anonymous class that implements the StatusListener interface
StatusListener listener = new StatusListener() {  
  //do something with the tweets
  public void onStatus(Status status) {    
    
    color markerColor = color(0,172, 237, 150);
    if(statusMarkerBuffer.size() < 200){
      de.fhpotsdam.unfolding.geo.Location locTweet = getLocation(status);
      if(status.getRetweetedStatus() != null){        
        de.fhpotsdam.unfolding.geo.Location locRetweet= getLocation(status.getRetweetedStatus());          
        if((locTweet.getLat() != 0)&&(locTweet.getLon() !=0) &&(locRetweet.getLat() !=0)&&(locRetweet.getLon() != 0)){
          SimpleLinesMarker connectionMarker = new SimpleLinesMarker(locTweet, locRetweet);
          connectionMarker.setColor(markerColor);          
          //connectionMarker.setStrokeWeight(10);
          simpleLinesBuffer.add(connectionMarker);        
        }
      }
    }
    //add location on map
    ;
    createMarkers(locTweet.getLat(), locTweet.getLon(), markerColor, status);

 
  }
  //Called upon location deletion messages.
  public void onDeletionNotice (StatusDeletionNotice statusDeletionNotice) {
    println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }
  //This notice will be sent each time a limited stream becomes unlimited.
  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    println("Got track limitation notice:" + numberOfLimitedStatuses);
  }
  //Called upon location deletion messages.
  public void onScrubGeo(long userId, long upToStatusId) {
    println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }
  
  public void onException(Exception ex) {
    ex.printStackTrace();
  }
  //Called when receiving stall warnings.
  public void onStallWarning(StallWarning warning) {
   //TODO: BLABLA
  }
};