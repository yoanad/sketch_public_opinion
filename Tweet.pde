class Tweet {
  //Status tweet;
  de.fhpotsdam.unfolding.geo.Location locations;
  double latitude;
  double longitude;
  long id;
  String username;
  String date;
  String text;
  int followersCount;
  
  Tweet(Status status) {
    //make the Status object a Tweet
    //tweet = status;
    //println(status.getId());
    try {
    latitude = status.getGeoLocation().getLatitude();
    longitude = status.getGeoLocation().getLongitude();
    } catch (Exception e) {
      println("No location");
    }
    id = status.getId();
    username = status.getUser().getScreenName();
    date = hour()+ ";" +minute() + ";" + second();
    text = status.getText();
    followersCount = status.getUser().getFollowersCount();
  }
  
  Tweet(processing.data.JSONObject tweetObj) {
    id = tweetObj.getLong("id");
    username = tweetObj.getString("username");
    latitude = tweetObj.getDouble("latitude");
    longitude = tweetObj.getDouble("longitude");
    date  = tweetObj.getString("date");
    text = tweetObj.getString("text");
    followersCount = tweetObj.getInt("followersCount", 1);
  }
  
  String toString() {
    return id + ": " + username;
  }
  
  //collects tweet data from stream and saves it in an JSONArray
  void addToJson() {
    processing.data.JSONObject locations = new processing.data.JSONObject();
    processing.data.JSONArray retweets = new processing.data.JSONArray();
     
    locations.setLong("id", id);
    locations.setString("username", username);
    locations.setDouble("latitude",  latitude);
    locations.setDouble("longitude", longitude);
    locations.setString("date", date);
    locations.setString("text", text);
    locations.setInt("followersCount", followersCount);
    tweetLocations.append(locations);
      //if (tweet.getRetweetedStatus() != null) {
      //   locations.setJSONArray("retweets", retweets);
      //}
    saveJSONArray(tweetLocations, "data/data.json");
  }
  
  //Loads data from json array
  //
  
  //void readFromJSON() {
  //  processing.data.JSONArray resultsArr = loadJSONArray("data/data.json");
  //  for (int i =0; i < resultsArr.size(); i++) {
  //  processing.data.JSONObject tweetObj = resultsArr.getJSONObject(i);
  //  long id = tweetObj.getLong("id");
  //  String name = tweetObj.getString("username");
  //  double latitude = tweetObj.getDouble("latitude");
  //  double longitude = tweetObj.getDouble("longitude");
  //  String date  = tweetObj.getString("date");
  //  String text = tweetObj.getString("text");
  //  //println(id + name + latitude + longitude + date + text);
  //  }
     
  //  return Tweet(id,name,latitude,date,text);
  //}
}