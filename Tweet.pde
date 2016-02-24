class Tweet {
  Status tweet;
  de.fhpotsdam.unfolding.geo.Location locations;
  double latitude;
  double longitude;
  
  Tweet(Status status) {
    //make the Status object a Tweet
    tweet = status;
    //println(status.getId());
  }
  
  //collects tweet data from stream and saves it in an JSONArray
  void addToJson() {
    processing.data.JSONObject locations = new processing.data.JSONObject();
    processing.data.JSONArray retweets = new processing.data.JSONArray();
    try {
    latitude = tweet.getGeoLocation().getLatitude();
    longitude = tweet.getGeoLocation().getLongitude();
    } catch (Exception e) {
      println("No location");
    }
    locations.setLong("id", tweet.getId());
    locations.setString("username", tweet.getUser().getScreenName());
    locations.setDouble("latitude",  latitude);
    locations.setDouble("longitude", longitude);
    locations.setString("date",hour()+ ";" +minute() + ";" + second());
    locations.setString("text", tweet.getText());
    tweetLocations.append(locations);
      if (tweet.getRetweetedStatus() != null) {
         locations.setJSONArray("retweets", retweets);
      }
    saveJSONArray(tweetLocations, "data/data.json");
  }
  
  //Loads data from json array
  //
  
  public Tweet loadFromJson(Tweet tweetObj) {
    //processing.data.JSONArray resultsArr = loadJSONArray("data/data.json");
    //for (int i =0; i < resultsArr.size(); i++) {
    //  processing.data.JSONObject tweetObj = resultsArr.getJSONObject(i);
    //  long id = tweetObj.getLong("id");
    //  String name = tweetObj.getString("username");
    //  double latitude = tweetObj.getDouble("latitude");
    //  double longitude = tweetObj.getDouble("longitude");
    //  String date  = tweetObj.getString("date");
    //  String text = tweetObj.getString("text");
    //  //println(id + name + latitude + longitude + date + text);
    //}
    //return tweetObj;
  ////}
}