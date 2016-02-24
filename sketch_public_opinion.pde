import de.fhpotsdam.unfolding.*; //<>// //<>// //<>//
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

//Twitter Objects
ConfigurationBuilder cb = new ConfigurationBuilder();
FilterQuery filter = new FilterQuery();
QueryResult result;
TwitterStream twitterStream;
Query query;
GeoLocation location;

//Maps & Locations
UnfoldingMap map;
de.fhpotsdam.unfolding.geo.Location locTweet;
de.fhpotsdam.unfolding.geo.Location locRetweet;
//double latitude, longitude; 

//Buffer for Markers
List <StatusMarker> statusMarkerBuffer;
List <SimpleLinesMarker> simpleLinesBuffer;

//Markers
MarkerManager<Marker> userMarkerManager;
MarkerManager<Marker> statusMarkerManager;
SimpleLinesMarker linesMarker;
UserMarker userMarker;
Location userMarkerLocation;
int markerAlpha;

ArrayList<Tweet> tweets = new ArrayList();
processing.data.JSONArray tweetLocations;

//colors
color orangeBright, blueTwitter, orangeDark;


void setup () {

  // JSON
  tweetLocations  = new processing.data.JSONArray();
  startStream();

  statusMarkerBuffer = new ArrayList <StatusMarker>() ;
  simpleLinesBuffer = new ArrayList<SimpleLinesMarker>();

  //setup canvas
  size(800, 580, P2D);
  background(0);

  //setup default map
  loadJson();
  setupMap();
  userMarker = new UserMarker(userMarkerLocation);
  userMarkerManager = new MarkerManager();
  statusMarkerManager = new MarkerManager();
  map.addMarkerManager(userMarkerManager);
  map.addMarkerManager(statusMarkerManager);

  //colors
  blueTwitter = color(0, 172, 237, 150);
  orangeBright = color(255, 177, 5, 255);
}

void draw() {
  background(0);
  map.draw();
  // Get the position of the img1 scrollbar
  // and convert to a value to display the img1 image 
  for (int i = 0; i < statusMarkerBuffer.size(); i++) {   
    statusMarkerManager.addMarker(statusMarkerBuffer.get(i));
  }

  for (int i = 0; i < simpleLinesBuffer.size(); i++) {
    map.addMarkers(simpleLinesBuffer.get(i));
  }
   // TODO: eventually seperate object and draw method for map ->> animation!
}

void startStream() {
  //TWITTER CREDENTIALS
  //twitter authentication Yoana
  cb.setOAuthConsumerKey("OXRFgb05gL9NNfIRn3x0NhVX3");
  cb.setOAuthConsumerSecret("H2v8AOLfYYP6PcI1WCDJSxqZmAwtjQFhbBbtCTsGTPlHawXjns");
  cb.setOAuthAccessToken("1827972638-jBZG9XR43ZG3YdBEa3BMfjZU2kx00bo4pNuD92B");
  cb.setOAuthAccessTokenSecret("H0LRvCSlGs6CmG1UV6gqmaJE7fzwEFmM19IhBfS9JH3PR");

  ////Anna
  //cb.setOAuthConsumerKey("uk9ggy2gw01K7Zb5J1CDMVegG");
  //cb.setOAuthConsumerSecret("kCPUf1qyJAnfsk0u3G83ujdcPAPSdVOpfN5rFKQW0w7ppZOpjJ");
  //cb.setOAuthAccessToken("47693725-KGgz1DzwpoDrWsgqvuVnl8q2tflux5NPQaxPr8qfb");
  //cb.setOAuthAccessTokenSecret("nmuWHccelSJcsA3KEDtCh4ikxfVHIkAkAVCMXt2RQUp20");

  //STREAMING API
  //start stream
  TwitterStream twitterStream = new TwitterStreamFactory( cb.build()
    ).getInstance();      
  //listen to tweets in the stream 
  twitterStream.addListener(listener);
  String keywords[] = {"syria", "سوريا", 
    "syrien", "siria", "Сирия", "Tanjung", "Syrie", "सीरिया", "叙利亚", "シリア"};
  String keywords1[] = {"#syria"};
  filter.language(new String[]{"en"});
  filter.track(keywords1);
  twitterStream.filter(filter);

  println("started stream");
}

void setupMap() {
  map = new UnfoldingMap(this, new MapBox.WorldLightProvider());
  //default map
  MapUtils.createDefaultEventDispatcher(this, map);
}

public void createMarkers(color markerColor, Tweet tweet) {
  if ((tweet.latitude != 0)&&(tweet.longitude !=0)) {    
    de.fhpotsdam.unfolding.geo.Location loc =
    new de.fhpotsdam.unfolding.geo.Location(tweet.latitude, tweet.longitude);
    StatusMarker marker = new StatusMarker(loc, tweet);      
    marker.setColor(markerColor);
    marker.setStrokeWeight(0);      
    marker.setRadius(10);      
    statusMarkerBuffer.add(marker);
    if(userMarker != null){
      userMarker.getTextOfNearbyTweets();
    }
  }
}

public void mouseClicked() {
  StatusMarker hitMarker = (StatusMarker)statusMarkerManager.getFirstHitMarker(mouseX, mouseY);
  //userMarkerLocation = map.getLocationFromScreenPosition(mouseX, mouseY) = 
  //userMarker.setLocation(userMarkerLocation);
  userMarkerLocation =  map.getLocationFromScreenPosition(mouseX, mouseY);
  userMarker.setLocation(userMarkerLocation);
  if (hitMarker != null) {
    // Select current marker 
    for (Marker marker : statusMarkerManager.getMarkers()) {
      marker.setSelected(false);
    }
    hitMarker.setSelected(true);
  } else {
    //control UserMarker
    userMarkerManager.clearMarkers();
    userMarkerManager.addMarker(userMarker); 

    String textNearby = userMarker.getTextOfNearbyTweets();

    println(textNearby);
    //Deselect all other markers
    for (Marker marker : statusMarkerManager.getMarkers()) {
      marker.setSelected(false);
    }
  }
}

//Check Twitterstatus or if not available TwitterUser for Location
public de.fhpotsdam.unfolding.geo.Location getLocation(Status status) {
  try {      
    //println(status.getGeoLocation());
    //GeoLocation location = status.getGeoLocation();
    double latitude = location.getLatitude();
    double longitude= location.getLongitude();
    locTweet= new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
  } 
  catch(NullPointerException ne) {
    //if there is no Geolocation of tweet available check, if there is further information about the place      
    if (status.getPlace()!= null) {
      String googlePlace = URLEncoder.encode(status.getPlace().getFullName());  
      checkGoogleApi(googlePlace);
    } else if (status.getUser().getLocation() != null) {
      String googlePlace = URLEncoder.encode(status.getUser().getLocation());   
      checkGoogleApi(googlePlace);
    }
  }    
  return locTweet;
}

//Look for Geoposition by using Google Search API

public de.fhpotsdam.unfolding.geo.Location checkGoogleApi(String googlePlace) {    
  try {
    //println(googlePlace);
    processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="+googlePlace+"&key=AIzaSyCGsHm4Drt5aRV3NcRiiTbQaEg1i3l7R0I");
    processing.data.JSONArray googleResultsArr = google.getJSONArray("results");
    processing.data.JSONObject googleComponents = googleResultsArr.getJSONObject(0);
    processing.data.JSONObject googleGeometry = googleComponents.getJSONObject("geometry");
    processing.data.JSONObject googleLocation = googleGeometry.getJSONObject("location");
    double latitude = googleLocation.getDouble("lat");
    double longitude = googleLocation.getFloat("lng");        
    locTweet= new de.fhpotsdam.unfolding.geo.Location(latitude, longitude);
  }
  catch (RuntimeException re) {
    //if google finds no place according to the user's place information do this
    println("no Geoinformation found, if there are no markers check if Google Api Key is blocked");
    locTweet= new de.fhpotsdam.unfolding.geo.Location(0, 0);
  }    
  return locTweet;
}

void loadJson() {
  color markerColor = color(0, 172, 237, 150);
  println("json");
  tweetLocations = loadJSONArray("data/data.json");
  for (int i =0; i < tweetLocations.size(); i++) {
    processing.data.JSONObject tweetObj = tweetLocations.getJSONObject(i);
    Tweet jsonTweet = new Tweet(tweetObj);
    tweets.add(jsonTweet);
    createMarkers(markerColor, jsonTweet);
    println(jsonTweet.toString());
  }
}      

// Implementing StatusListener interface
StatusListener listener = new StatusListener() {

  //@Override
  public void onStatus(Status status) {
    if (statusMarkerBuffer.size() < 10) {
      Tweet tweet =  new Tweet(status);
      de.fhpotsdam.unfolding.geo.Location locTweet = getLocation(status);
      tweet.longitude=locTweet.getLon();
      tweet.latitude=locTweet.getLat();
      tweets.add(tweet);
      tweet.addToJson();
      
      createMarkers(blueTwitter, tweet);
      //println(locTweet);
      //for lines must be improved
      if (status.getRetweetedStatus() != null) {        
        de.fhpotsdam.unfolding.geo.Location locRetweet =
          getLocation(status.getRetweetedStatus());          

        if ((locTweet.getLat() != 0)&&(locTweet.getLon() !=0)
          &&(locRetweet.getLat() !=0)&&(locRetweet.getLon() != 0)) {
          SimpleLinesMarker connectionMarker = new SimpleLinesMarker(locTweet, locRetweet);
          connectionMarker.setColor(blueTwitter);          
          //connectionMarker.setStrokeWeight(10);
          simpleLinesBuffer.add(connectionMarker);
        }
      }
    }
  }

  //@Override
  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }

  //@Override
  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
  }
  //@Override
  public void onScrubGeo(long userId, long upToStatusId) {
    System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }

  //@Override
  public void onStallWarning(StallWarning warning) {
    System.out.println("Got stall warning:" + warning);
  }

  //@Override
  public void onException(Exception ex) {
    ex.printStackTrace();
  }
};