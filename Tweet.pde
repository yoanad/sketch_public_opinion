class Tweet {
  Status tweet;
  de.fhpotsdam.unfolding.geo.Location locations;
  
  Tweet(Status status) {
    //make the Status object a Tweet
    tweet = status;
    //println(status.getId());
  }

  void addToJson() {
    processing.data.JSONObject locations = new processing.data.JSONObject();
    processing.data.JSONArray retweets = new processing.data.JSONArray();
    double latitude = tweet.getGeoLocation().getLatitude();
    double longitude = tweet.getGeoLocation().getLongitude();
    locations.setLong("id", tweet.getId());
    locations.setDouble("latitude",  latitude);
    locations.setDouble("longitude", longitude);
    locations.setString("date",hour()+ ";" +minute() + ";" + second());
    locations.setString("tweet", tweet.getText());
    tweetLocations.append(locations);
      if (tweet.getRetweetedStatus() != null) {
         locations.setJSONArray("retweets", retweets);
      }
    saveJSONArray(tweetLocations, "data/data.json");
  }
}