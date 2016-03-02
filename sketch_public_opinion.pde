import de.fhpotsdam.unfolding.*;  //<>// //<>//
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.events.MapEvent;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.utils.MapUtils;
import de.fhpotsdam.unfolding.utils.ScreenPosition;

import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;
import java.net.URLEncoder;



import com.ibm.watson.developer_cloud.tone_analyzer.v3.*;
import com.ibm.watson.developer_cloud.tone_analyzer.v3.model.*;
import com.ibm.watson.developer_cloud.alchemy.v1.*;
import com.ibm.watson.developer_cloud.alchemy.v1.model.*;
import com.google.gson.*;
import com.squareup.okhttp.*;
import okio.*;


//States

final int welcomeScreen = 0;
final int visualisationScreen = 1;
int state = welcomeScreen; //current

//Styling
ControlP5 cp5;
PFont font;
PImage startscreenimg;
PImage twitterBird;
Button startButton;
Button button;
DropdownList settingsDropdown;

//Map Constraints
Location boundTopLeft = new Location(52.8, 12.6);
Location boundBottomRight = new Location(52.0, 14.5);


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


//Buffer for Markers
List <StatusMarker> statusMarkerBuffer;
List <SimpleLinesMarker> simpleLinesBuffer;

boolean jsonIsLoaded;

//Markers
MarkerManager<Marker> userMarkerManager;
MarkerManager<Marker> statusMarkerManager;
SimpleLinesMarker linesMarker;
UserMarker userMarker;
Location userMarkerLocation;
int markerAlpha;

//Text of nearby Markers
String textNearby;

ArrayList<Tweet> tweets = new ArrayList();
processing.data.JSONArray tweetLocations;

//colors
color orangeBright, blueTwitter, orangeDark;
color colorAnger = color(231, 76, 60);
color colorDisgust = color(39, 174, 96);
color colorFear= color(41, 128, 185);
color colorJoy = color(241, 196, 15);
color colorSadness= color(44, 62, 80);

//watson
processing.data.JSONObject tweetTone= new processing.data.JSONObject();
processing.data.JSONObject tweetSentiment= new processing.data.JSONObject(); 

//Visualisation of Watson
HashMap<String, Float> hmEmotions = new HashMap<String, Float>();
ArrayList<Range> ranges = new ArrayList();
Range rangeAnger = new Range("Anger", 0.0, colorAnger);
Range rangeDisgust = new Range("Disgust", 0.0, colorDisgust);
Range rangeFear = new Range("Fear", 0.0, colorFear);
Range rangeJoy = new Range("Joy", 0.0, colorJoy);
Range rangeSadness = new Range("Sadness", 0.0, colorSadness);
Float angerScore, disgustScore, fearScore, joyScore, sadnessScore;




void setup () {


  //Styling 
  frameRate(30);
  cp5 = new ControlP5(this);

  // JSON
  tweetLocations  = new processing.data.JSONArray();
  startStream();

  statusMarkerBuffer = new ArrayList <StatusMarker>() ;
  simpleLinesBuffer = new ArrayList<SimpleLinesMarker>();


  //setup canvas
  fullScreen(P2D, SPAN);
  background(0);

  //setup default map

  //loadJson();
  setupMap();
  jsonIsLoaded= false;
  userMarker = new UserMarker(userMarkerLocation);
  userMarkerManager = new MarkerManager();
  statusMarkerManager = new MarkerManager();
  map.addMarkerManager(userMarkerManager);
  map.addMarkerManager(statusMarkerManager);
  //colors
  blueTwitter = color(0, 172, 237, 150);
  orangeBright = color(255, 177, 5, 255);


  //Ranges
  ranges.add(rangeAnger);
  ranges.add(rangeDisgust);
  ranges.add(rangeFear);
  ranges.add(rangeJoy);
  ranges.add(rangeSadness);

  angerScore= 0.05;
  disgustScore= 0.05;
  fearScore = 0.05;
  joyScore = 0.05;
  sadnessScore = 0.05;
}

void draw() {


  switch (state) {
  case welcomeScreen:
    showWelcomeScreen();
    break;

  case visualisationScreen:
    background(255);
    map.draw();
    drawMenuRight();
    showVisualisationScreen();

    break;

  default: 
    //println("You just broke the internet");
    exit ();
    break;
  }
}





public void restrictPanning() {
  Location mapTopLeft = map.getTopLeftBorder();
  Location mapBottomRight = map.getBottomRightBorder();
  ScreenPosition mapTopLeftPos = map.getScreenPosition(mapTopLeft);
  ScreenPosition boundTopLeftPos = map.getScreenPosition(boundTopLeft);
  if (boundTopLeft.getLon() > mapTopLeft.getLon()) {
    map.panBy(mapTopLeftPos.x - boundTopLeftPos.x, 0);
  }
  if (boundTopLeft.getLat() < mapTopLeft.getLat()) {
    map.panBy(0, mapTopLeftPos.y - boundTopLeftPos.y);
  }
  ScreenPosition mapBottomRightPos = map.getScreenPosition(mapBottomRight);
  ScreenPosition boundBottomRightPos = map.getScreenPosition(boundBottomRight);
  if (boundBottomRight.getLon() < mapBottomRight.getLon()) {
    map.panBy(mapBottomRightPos.x - boundBottomRightPos.x, 0);
  }
  if (boundBottomRight.getLat() > mapBottomRight.getLat()) {
    map.panBy(0, mapBottomRightPos.y - boundBottomRightPos.y);
  }
}


void showWelcomeScreen() {
  background(255);
  startscreenimg = loadImage("startscreen.png");
  twitterBird = loadImage("twitterBird.png");
  startscreenimg.resize(width, height);
  image (startscreenimg, 0, 0);
  image (twitterBird, width/2-200, height*0.65);
  fill(255, 0);
  noStroke();

  if (key==ENTER) {    
    fill(0);
    state = visualisationScreen;
  }
}

void showVisualisationScreen() { 
  for (int i = 0; i < statusMarkerBuffer.size(); i++) {   
    statusMarkerManager.addMarker(statusMarkerBuffer.get(i));
  }

  for (int i = 0; i < simpleLinesBuffer.size(); i++) {
    map.addMarkers(simpleLinesBuffer.get(i));
  }  
  drawSentiments();
}

public void drawSentiments() {
  //Draw Emotion Ranges

  for (int i= 0; i<ranges.size(); i++) {    
    translate(0, height*0.165);
    ranges.get(i).drawRange(width*0.7, 0, width*0.25, height*0.07);
  }

  rangeAnger.setScore(angerScore);      
  rangeDisgust.setScore(disgustScore);       
  rangeFear.setScore(fearScore);
  rangeJoy.setScore(joyScore);
  rangeSadness.setScore(sadnessScore);
}

public void saveSentiments() {

  //read JSON Object
  try {
    processing.data.JSONArray emotions = tweetTone.getJSONArray("tone_categories").getJSONObject(0).getJSONArray("tones");

    for (int i=0; i< emotions.size(); i++) {
      String name= emotions.getJSONObject(i).getString("tone_name");
      //println(emotions.getJSONObject(i).getString("tone_name"));
      Float score = emotions.getJSONObject(i).getFloat("score");
      //println(score);
      if (score != null) {
        hmEmotions.put(name, score);
        angerScore = hmEmotions.get("Anger");        
        disgustScore=hmEmotions.get("Disgust");       
        fearScore = hmEmotions.get("Fear");
        joyScore = hmEmotions.get("Joy");        
        sadnessScore=hmEmotions.get("Sadness");
      }
    }
  }
  catch(NullPointerException ne) {
    //println("Array empty");
  }
}



void drawMenuRight() {
  noFill();
  stroke(102, 102, 102, 255);
  strokeWeight(30);
  rect(0, 0, width, height);
  fill(102, 102, 102, 255);
  rect(width*0.66, 0, width*0.33, displayHeight);
  noFill();
  stroke(102, 102, 102, 255);
  strokeWeight(2);
  rect(15, 15, width*0.66, height-30);
}

//Watson 
//this function checks the emotional tone
void analyzeTone(String text) {
  //Tone Analysis
  ToneAnalyzer service = new ToneAnalyzer(ToneAnalyzer.VERSION_DATE_2016_02_11);
  //Username und Passwort das Ihr von der Watson Konsole kriegt
  service.setUsernameAndPassword("03ada96e-b23e-4ab1-933b-09aaec64d2c6", "kXKi86V6rraa");   
  ToneAnalysis tone = service.getTone(text);  
  tweetTone = processing.data.JSONObject.parse(tone.getDocumentTone().toString());
}
//this function analyses if the content of the tweet is positive or negativ
void analyzeSentiment(String text) {
  //Sentiment Analysis
  AlchemyLanguage service = new AlchemyLanguage();
  //API Key der Alchemy API
  service.setApiKey("54ec2b46d89ff069c95cd243a4e3ce7dfebfaaaa");

  if (text != null) {
    HashMap<String, Object> params = new HashMap<String, Object>();
    params.put(AlchemyLanguage.TEXT, text);
    DocumentSentiment sentiment =  service.getSentiment(params);
    tweetSentiment = processing.data.JSONObject.parse(sentiment.toString());
    //println(tweetSentiment);
  }
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
  //keyword "syria" translated to different languages
  String keywords[] = {"syria", "سوريا", 
    "syrien", "siria", "Сирия", "Tanjung", "Syrie", "सीरिया", "叙利亚", "シリア"};
  //filter.language(new String[]{"en"});
  filter.track(keywords);
  twitterStream.filter(filter);
  println("started stream");
}

void setupMap() {  
  map = new UnfoldingMap(this, -100, 0, displayWidth-400, displayHeight-10, new MapBox.WorldLightProvider());
  //default map
  MapUtils.createDefaultEventDispatcher(this, map);  
  userMarker = new UserMarker(userMarkerLocation);
  userMarkerManager = new MarkerManager();
  statusMarkerManager = new MarkerManager();
  map.addMarkerManager(userMarkerManager);
  map.addMarkerManager(statusMarkerManager);
}

synchronized void createMarkers(color markerColor, Tweet tweet) {
  if ((tweet.latitude != 0)&&(tweet.longitude !=0)) {    
    de.fhpotsdam.unfolding.geo.Location loc =
      new de.fhpotsdam.unfolding.geo.Location(tweet.latitude, tweet.longitude);
    StatusMarker marker = new StatusMarker(loc, tweet);      
    marker.setColor(markerColor);
    marker.setStrokeWeight(0);      
    marker.setRadius(10);      
    statusMarkerBuffer.add(marker);    
  }
}

//this function sets the UserMarker on the map
public void mouseClicked() {   
  if (mouseButton == RIGHT) {
    StatusMarker hitMarker = (StatusMarker)statusMarkerManager.getFirstHitMarker(mouseX, mouseY);
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
      //analyze Text with watson              
      userMarkerManager.addMarker(userMarker); 
      textNearby =userMarker.getTextOfNearbyTweets();

      //analyze Text with watson      
      //println("textNearby ist: "+textNearby);
      if ((textNearby !=null)&&(textNearby !="")) {
        Runnable run = new Runnable() {
          public void run() {
            analyzeTone(textNearby);
            //analyzeSentiment(textNearby);o
            saveSentiments();
          }
        };  
        new Thread(run).start();
      }

      //Deselect all other markers
      for (Marker marker : statusMarkerManager.getMarkers()) {
        marker.setSelected(false);
      }
    }
  } else if (mouseButton == LEFT) {

    StatusMarker hitMarker = (StatusMarker)statusMarkerManager.getFirstHitMarker(mouseX, mouseY);
    if (hitMarker != null) {
      // Select current marker 
      for (Marker marker : statusMarkerManager.getMarkers()) {
        marker.setSelected(false);
      }
      hitMarker.setSelected(true);
    }
  }
}


//Check Twitterstatus or if not available TwitterUser for Location
synchronized public de.fhpotsdam.unfolding.geo.Location getLocation(Status status) {
  try {      
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
    //different keys im google api limit is reached
    ////ANNA
    //processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="
    //  +googlePlace+"&key=AIzaSyCGsHm4Drt5aRV3NcRiiTbQaEg1i3l7R0I");

    //YOANA 2
    processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="
      +googlePlace+"&key=AIzaSyBFumopf5_GvjL21byO_aNGeXavLpaKk2I");

    //YOANA 
    //processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="
    //  +googlePlace+"&key=AIzaSyDzCs9jW5Pu3lG5jpD9N-MU8Gwr5iVBXFo");
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
    //println("no Geoinformation found, if there are no markers check if Google Api Key is blocked");
    locTweet= new de.fhpotsdam.unfolding.geo.Location(0, 0);
  }    
  return locTweet;
}

void loadJson() {
  try {
    println("loadjson");
    processing.data.JSONArray tweetLocations = loadJSONArray("data/data.json");
    for (int i =0; i < tweetLocations.size(); i++) {
      processing.data.JSONObject tweetObj = tweetLocations.getJSONObject(i);
      Tweet jsonTweet = new Tweet(tweetObj);
      tweets.add(jsonTweet);
      //println(jsonTweet.toString());
      jsonIsLoaded=true;
    }
    println("json is loaded");
  }
  catch (Exception e) {
    println("jsonempty");
  }
}      

// Implementing StatusListener interface
StatusListener listener = new StatusListener() {
  //@Override
  public void onStatus(Status status) {
    //limit is set to 150 tweets, if limit is to high google api limit is reached very quickly
    if (statusMarkerBuffer.size() < 150) {
      Tweet tweet =  new Tweet(status);
      de.fhpotsdam.unfolding.geo.Location locTweet = getLocation(status);
      tweet.longitude=locTweet.getLon();
      tweet.latitude=locTweet.getLat();
      tweets.add(tweet);
      tweet.addToJson();

      createMarkers(blueTwitter, tweet);
      //println(locTweet);      
      if (status.getRetweetedStatus() != null) {        
        de.fhpotsdam.unfolding.geo.Location locRetweet =
          getLocation(status.getRetweetedStatus());          

        if ((locTweet.getLat() != 0)&&(locTweet.getLon() !=0)
          &&(locRetweet.getLat() !=0)&&(locRetweet.getLon() != 0)) {
          SimpleLinesMarker connectionMarker = new SimpleLinesMarker(locTweet, locRetweet);
          connectionMarker.setColor(blueTwitter);                
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