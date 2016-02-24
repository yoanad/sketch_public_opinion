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
  long retweetedFrom;
  boolean isRetweet;

  Tweet(Status status) {
    //make the Status object a Tweet
    //tweet = status;
    //println(status.getId());
    try {
      latitude = status.getGeoLocation().getLatitude();
      longitude = status.getGeoLocation().getLongitude();
    } 
    catch (Exception e) {
      println("No location");
    }
    id = status.getId();
    username = status.getUser().getScreenName();
    date = hour()+ ";" +minute() + ";" + second();
    text = status.getText();
    followersCount = status.getUser().getFollowersCount();
    retweetedFrom = status.getRetweetedStatus().getId();
    isRetweet = status.isRetweet();
  }

  Tweet(processing.data.JSONObject tweetObj) {
    id = tweetObj.getLong("id");
    username = tweetObj.getString("username");
    latitude = tweetObj.getDouble("latitude");
    longitude = tweetObj.getDouble("longitude");
    date  = tweetObj.getString("date");
    text = tweetObj.getString("text");
    followersCount = tweetObj.getInt("followersCount", 1);
    retweetedFrom = tweetObj.getLong("retweetedFrom");
    isRetweet = tweetObj.getBoolean("isRetweet");
  }

  String toString() {
    return id + ": " + username;
  }
  

  //collects tweet data from stream and saves it in an JSONArray
  void addToJson() {
    processing.data.JSONObject tweets = new processing.data.JSONObject();
    processing.data.JSONArray retweets = new processing.data.JSONArray();

    tweets.setLong("id", id);
    tweets.setString("username", username);
    tweets.setDouble("latitude", latitude);
    tweets.setDouble("longitude", longitude);
    tweets.setString("date", date);
    tweets.setString("text", text);
    tweets.setInt("followersCount", followersCount);
    tweetLocations.append(tweets);
    tweets.setJSONArray("retweets", retweets);
    retweets.setLong(1, retweetedFrom);
    saveJSONArray(tweetLocations, "data/data.json");
  }
}