require "sinatra"
require "sinatra/reloader"
require "httparty"
def view(template); erb template.to_sym; end

get "/" do
  ### Get the weather
  # Evanston, Kellogg Global Hub... replace with a different location if you want
  lat = 42.0574063
  long = -87.6722787

  units = "imperial" # or metric, whatever you like
  key = "3ffb98e14fd1149bd00d96159af71960" # replace this with your real OpenWeather API key

  # construct the URL to get the API data (https://openweathermap.org/api/one-call-api)
  url = "https://api.openweathermap.org/data/2.5/onecall?lat=#{lat}&lon=#{long}&units=#{units}&appid=3ffb98e14fd1149bd00d96159af71960"

  # make the call
  @forecast = HTTParty.get(url).parsed_response.to_hash

  # We want to show the current weather description, and if there are strong winds. Also want to know the current temperature and feels-like temperature.
  @current_description = "#{@forecast["current"]["weather"][0]["main"]}"
    
  current_winds = []
  if #{@forecast["current"]["wind_speed"]} < 20
    current_winds = "Gentle breeze at #{@forecast["current"]["wind_speed"]} mph."
  else
    current_winds = "Strong winds at #{@forecast["current"]["wind_speed"]} mph."
  end
  
  @current_weather = ["It is currently #{@forecast["current"]["temp"]} degrees, and feels like #{@forecast["current"]["feels_like"]} degrees.", current_winds]
  puts @current_weather
  
  # We want to show the forecast for the next 5 days
  total_forecast = []
  day_number = 1
  for day in @forecast["daily"]
    total_forecast << "#{day_number} days from now: #{day["weather"][0]["description"]}. It will be #{day["temp"]["day"]} degrees during the day, and #{day["temp"]["night"]} at night."
    day_number = day_number + 1
  end
    
  @five_day_weather = total_forecast[0, 5]

  ### Get the news

  # First, get the business news.
  newskey = "9ed515ea0d554c8bb952c108581da9e0"
  category1 = "business"
  url = "https://newsapi.org/v2/top-headlines?country=us&category=#{category1}&apiKey=#{newskey}"
  @usbiznews = HTTParty.get(url).parsed_response.to_hash
  
  all_biz_articles = []
  biz_article_number = 1
  for article in @usbiznews["articles"]
    all_biz_articles << "#{article["url"]}>#{biz_article_number}. #{article["title"]}" 
    biz_article_number = biz_article_number + 1
  end

  @top_5_biz_articles = all_biz_articles[0,5]
  
# Next, get the sports news.
  category2 = "sports"
  url = "https://newsapi.org/v2/top-headlines?country=us&category=#{category2}&apiKey=#{newskey}"
  @ussportsnews = HTTParty.get(url).parsed_response.to_hash
  
  all_sports_articles = []
  sports_article_number = 1
  for article in @ussportsnews["articles"]
    all_sports_articles << "#{article["url"]}>#{sports_article_number}. #{article["title"]}" 
    sports_article_number = sports_article_number + 1
  end

  @top_5_sports_articles = all_sports_articles[0,5]

  view "news"
end