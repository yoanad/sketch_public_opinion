import de.fhpotsdam.unfolding.*;  //<>//
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

//wordcram doesn't work with unfolding
//import wordcram.*;

import com.ibm.watson.developer_cloud.tone_analyzer.v3.*;
import com.ibm.watson.developer_cloud.tone_analyzer.v3.model.*;
import com.ibm.watson.developer_cloud.alchemy.v1.*;
import com.ibm.watson.developer_cloud.alchemy.v1.model.*;
import com.google.gson.*;
import com.squareup.okhttp.*;
import okio.*;

import controlP5.*;


//States

final int welcomeScreen = 0;
final int visualisationScreen = 1;
int state = welcomeScreen; //current

//Styling
ControlP5 cp5;
PFont font;

//Map Constraints
Location boundTopLeft = new Location(52.8, 12.6);
Location boundBottomRight = new Location(52.0, 14.5);
//Location boundTopLeft = new Location(-180, -90);
//Location boundBottomRight = new Location(180, 90);

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

//Text of nearby Markers
String textNearby;

ArrayList<Tweet> tweets = new ArrayList();
processing.data.JSONArray tweetLocations;

//colors
color orangeBright, blueTwitter, orangeDark;
//color colorAnger, colorDisgust, colorFear, colorJoy, colorSadness;
color colorAnger = color(255, 177, 5, 255);
color colorDisgust = color(0, 177, 5, 255);
color colorFear= color(255, 0, 5, 255);
color colorJoy = color(255, 177, 2555, 255);
color colorSadness= color(255, 255, 5, 255);

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



void setup () {

  //Styling 
  cp5 = new ControlP5(this);
  Button startButton = cp5.addButton("Start visualisation");
  font = createFont("Raleway-Light-48.vlw", 30);


  // JSON
  tweetLocations  = new processing.data.JSONArray();
  startStream();

  statusMarkerBuffer = new ArrayList <StatusMarker>() ;
  simpleLinesBuffer = new ArrayList<SimpleLinesMarker>();


  //setup canvas
  //fullScreen(P2D, SPAN);
  size(1920, 1080, P2D);
  //canvas = createGraphics(640, 480, JAVA2D);
  //size(displayWidth, displayHeight, P3D);
  //fullScreen();
  background(0);

  //setup default map
  //loadJson();
  setupMap();
  //map.setZoomRange(10, 12);
  //map.zoomAndPanTo(new Location(52.5, 13.4f), 10);
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
}

void draw() {

  switch (state) {
  case welcomeScreen:
    showWelcomeScreen();
    break;

  case visualisationScreen:
    background(255);
    //restrictPanning();
    //map.setOffset(0,0);
    map.draw();
    showVisualisationScreen();
    break;

  default: 
    println("You just broke the internet");
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
  fill(4, 193, 192);
  textFont(font);
  text ("How does public opinion change around the world?", 
    width/2, height/2-100);
  textAlign(CENTER);
  cp5.addButton("Start visualisation")
    .setPosition(width/2-200, height/2-50).setSize(400, 100);
  //cp5.getController("Start visualisation").setFont(font);
  //rect(width/2-200, height/2-50, 400, 100);
  fill(4, 193, 192);
  if (mousePressed) {
    if (mouseX > width/2-200 && mouseX < width/2-200+400 && mouseY>height/2-50 && mouseY <height/2-50+100) {
      println("The mouse is pressed and over the button");
      fill(0);
      state = visualisationScreen;
      cp5.remove("Start visualisation");
    }
  }
}

void showVisualisationScreen() {
  // Get the position of the img1 scrollbar
  // and convert to a value to display the img1 image 

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
    translate(0, 100);
    ranges.get(i).drawRange(0, 0, 200, 80);
  }




  try {
    if (hmEmotions.get("Anger") != null) {      
      rangeAnger.setScore(hmEmotions.get("Anger"));      
      rangeDisgust.setScore(hmEmotions.get("Disgust"));       
      rangeFear.setScore(hmEmotions.get("Fear"));
      rangeFear.setScore(hmEmotions.get("Joy"));
      rangeFear.setScore(hmEmotions.get("Sadness"));
    }
  }
  catch(NullPointerException ne) {
  }
}

public void saveSentiments() {

  //Range range1 = new Range("hallo", 0.7, blueTwitter);
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
      }
    }
  }
  catch(NullPointerException ne) {
    println("Array empty");
  }

  drawMenuRight();
}

void drawMenuRight() {
  fill(255);
  rect(400, 0, 400, displayHeight);
  //map = new UnfoldingMap(this, (-200), 0, displayWidth-200, displayHeight-10, new MapBox.WorldLightProvider());
}

//Watson example
void analyzeTone(String text) {
  //Tone Analysis
  ToneAnalyzer service = new ToneAnalyzer(ToneAnalyzer.VERSION_DATE_2016_02_11);
  //Username und Passwort das Ihr von der Watson Konsole kriegt
  service.setUsernameAndPassword("03ada96e-b23e-4ab1-933b-09aaec64d2c6", "kXKi86V6rraa");   
  ToneAnalysis tone = service.getTone(text);  
  tweetTone = processing.data.JSONObject.parse(tone.getDocumentTone().toString());
  //println(tweetTone);
}

void analyzeSentiment(String text) {
  //Sentiment Analysis
  AlchemyLanguage service = new AlchemyLanguage();
  //API Key der Alchemy API
  service.setApiKey("54ec2b46d89ff069c95cd243a4e3ce7dfebfaaaa");

  if (text != null) {
    HashMap<String, Object> params = new HashMap<String, Object>();
    params.put(AlchemyLanguage.TEXT, text);
    DocumentSentiment sentiment =  service.getSentiment(params);
    processing.data.JSONObject tweetSentiment = processing.data.JSONObject.parse(sentiment.toString());
    println(tweetSentiment);
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
  String keywords[] = {"syria", "سوريا", 
    "syrien", "siria", "Сирия", "Tanjung", "Syrie", "सीरिया", "叙利亚", "シリア"};
  String keywords1[] = {"#syria"};
  //filter.language(new String[]{"en"});
  filter.track(keywords);
  twitterStream.filter(filter);

  println("started stream");
}

void setupMap() {
  //map.setRectangularPanningRestriction(180,90);
  map = new UnfoldingMap(this, (-200), 0, displayWidth-200, displayHeight-10, new MapBox.WorldLightProvider());
  //default map
  MapUtils.createDefaultEventDispatcher(this, map);
  //map.setTweening(false);
  //userMarkerLocation = new de.fhpotsdam.unfolding.geo.Location(48.1448, 11.558);
  userMarker = new UserMarker(userMarkerLocation);
  userMarkerManager = new MarkerManager();
  statusMarkerManager = new MarkerManager();
  map.addMarkerManager(userMarkerManager);
  map.addMarkerManager(statusMarkerManager);
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
    /*if(userMarker != null){
     userMarker.getTextOfNearbyTweets();      
     }*/
  }
}


  public void mousePressed() {   
    if (state==1) {
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
        println("textNearby ist: "+textNearby);
        if ((textNearby !=null)&&(textNearby !="")) {
          Runnable run = new Runnable() {
            public void run() {
              analyzeTone(textNearby);
              //analyzeSentiment(textNearby);
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

      //ANNA
      processing.data.JSONObject google = loadJSONObject("https://maps.googleapis.com/maps/api/geocode/json?address="
        +googlePlace+"&key=AIzaSyCGsHm4Drt5aRV3NcRiiTbQaEg1i3l7R0I");

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
      if (statusMarkerBuffer.size() < 40) {
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