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
Status status;
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
SimpleLinesMarker linesMarker;



void setup () {
  
  //TWITTER
  //twitter authentication
  cb.setOAuthConsumerKey("OXRFgb05gL9NNfIRn3x0NhVX3");
  cb.setOAuthConsumerSecret("H2v8AOLfYYP6PcI1WCDJSxqZmAwtjQFhbBbtCTsGTPlHawXjns");
  cb.setOAuthAccessToken("1827972638-jBZG9XR43ZG3YdBEa3BMfjZU2kx00bo4pNuD92B");
  cb.setOAuthAccessTokenSecret("H0LRvCSlGs6CmG1UV6gqmaJE7fzwEFmM19IhBfS9JH3PR");
  
  //TwitterStreamingAPI
  //start stream
  TwitterStream twitterStream = new TwitterStreamFactory( cb.build()
                                          ).getInstance();      
  //listen to tweets in the stream 
  twitterStream.addListener(listener);
  twitterStream.filter(queryText);
  

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
 
  
  //setup canvas
  size(920,640, P2D);
  background(0);
  
  //setup default map
  map = new UnfoldingMap(this, new MapBox.WorldLightProvider());
  
  //default map
  MapUtils.createDefaultEventDispatcher(this,map);  
  
}

//awesome graphic visualisation is handled here
void draw() {
  background(0);
   searchTweetsAndGetLocation();
  //draw map
  map.draw();  
}

public void searchTweetsAndGetLocation() {
    List<Status> searchStatuses = result.getTweets();
    for (int i=0; i<searchStatuses.size(); i++) {      
        try {        
          de.fhpotsdam.unfolding.geo.Location locTweetSearch = getLocation(status);        
          color markerColorSearch = color(0,255,0);
          //createMarkers(locTweetSearch.getLat(), locTweetSearch.getLon(), markerColorSearch);
                
        /*SimplePointMarker marker = new SimplePointMarker(locTweetSearch);
        println("marker!!!");
         marker.setColor(markerColorSearch);
         map.addMarkers(marker);  */       
        
        }catch (NullPointerException ne){
          println("no Marker");
        }
    }
}
  

public de.fhpotsdam.unfolding.geo.Location getLocation(Status status){
  try {      
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

public de.fhpotsdam.unfolding.geo.Location checkGoogleApi(String googlePlace){    
    try{
        println(googlePlace);
        processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="+googlePlace+"&key=AIzaSyDpe_ejIqWEWqut0LvJCRGy-ofvo9ujQoI");
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


public void createMarkers(double latitude, double longitude, color markerColor){
  if ((latitude != 0)&&(longitude !=0)){    
      de.fhpotsdam.unfolding.geo.Location loc = new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
      SimplePointMarker marker = new SimplePointMarker(loc);      
      marker.setColor(markerColor);
      map.addMarkers(marker); 
     }
}

//Anonymous class that implements the StatusListener interface
StatusListener listener = new StatusListener() {  
  //do something with the tweets
  public void onStatus(Status status) {    
      if(status.getRetweetedStatus() != null){      
        de.fhpotsdam.unfolding.geo.Location locRetweet= getLocation(status.getRetweetedStatus());
        color retweetMarkerColor = color(0,0,255);
        createMarkers(locRetweet.getLat(), locRetweet.getLon(), retweetMarkerColor); 
        SimpleLinesMarker linesMarker = new SimpleLinesMarker(locTweet, locRetweet);
        linesMarker.setColor(retweetMarkerColor);
        linesMarker.setStrokeWeight(29);
        
        de.fhpotsdam.unfolding.geo.Location locTweet = getLocation(status);

        //add location on map
        color markerColor = color(255,0,255);
        createMarkers(locTweet.getLat(), locTweet.getLon(), markerColor);
            
        if((locTweet.getLat() != 0)&&(locTweet.getLon() !=0)){
          SimpleLinesMarker connectionMarker = new SimpleLinesMarker(locTweet, locRetweet);
          map.addMarkers(connectionMarker);
        }

    }else{
      
      //get location of tweet        
      de.fhpotsdam.unfolding.geo.Location locTweet = getLocation(status);
  
      //add location on map
      color markerColor = color(255,0,0);
      createMarkers(locTweet.getLat(), locTweet.getLon(), markerColor);
    }
    
    //check if currentweet is retweet of former tweet, if yes show this tweet on map

      //println(status.getText());
      //println("quoted status: "+ status.getQuotedStatus());
      //println("retweeted status: "+status.getRetweetedStatus());
    
    
    
    
    //marker.setStrokeColor(color(255, 0, 0));
    //marker.setStrokeWeight(4);
 
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