require 'java'

Dir.glob('lib/*.jar') { | jar | 
  require File.expand_path("../#{jar}", __FILE__)
}

def twitter4j
  Java::Twitter4j
end

import twitter4j.Status
import twitter4j.StatusAdapter
import twitter4j.StatusDeletionNotice
import twitter4j.StatusListener
import twitter4j.TwitterException
import twitter4j.TwitterStream
import twitter4j.TwitterStreamFactory
import twitter4j.FilterQuery
import twitter4j.conf.ConfigurationBuilder

class Listener
  include StatusListener

  def initialize(options)
    @queue = TorqueBox::Messaging::Queue.new(options['queue'])
    @tweet_count = 0
  end

  def onStatus(status)
    return unless status.getGeoLocation and status.getUser.getLang == "en"
    @tweet_count += 1
    sani_status = status.getText.encode('ASCII', :invalid => :replace, :undef => :replace)
    tweet_text = <<TWEET_TEXT
<span class="tweettext">
  #{sani_status}
</span>
<a target="_blank" href="http://twitter.com/#{status.getUser.getScreenName}/status/#{status.getId}">Tweet Link</a>
TWEET_TEXT
    geojson = { 
      "type" => "Feature",
      "geometry" => { 
          "type" => "Point", 
          "coordinates" => [status.getGeoLocation.getLongitude, status.getGeoLocation.getLatitude]
      }, 
      "properties" => {
          "name" => tweet_text
      }
    }
    @queue.publish( :message => status.getText, :sender => status.getUser.getScreenName, :timestamp => Time.now.ctime, :latitude => status.getGeoLocation.getLatitude, :longitude => status.getGeoLocation.getLongitude, :geojson => geojson)
    puts "Processed #{@tweet_count} tweets" if @tweet_count % 10 == 0
  end

  def onException(exception)
    exception.printStackTrace
  end
end

class TweetGrabber

  def initialize(options)
    @search_terms = options['search_terms']
    @running = true
    @listener = Listener.new(options)
    config = ConfigurationBuilder.new
    config.setDebugEnabled(true)
    config.setOAuthConsumerKey(ENV['consumer_key'])
    config.setOAuthConsumerSecret(ENV['consumer_secret'])
    config.setOAuthAccessToken(ENV['access_token'])
    config.setOAuthAccessTokenSecret(ENV['access_token_secret'])
    @twitter_configuration = config.build
  end

  def start
    @thread = Thread.new { run }
  end

  def stop
    @running = false
    @thread.join
  end
  
  def run
    puts "Starting TweetGrabber with #{@search_terms}"
    
    stream = TwitterStreamFactory.new(@twitter_configuration).instance
    stream.addListener(@listener)
    filter = FilterQuery.new
    filter.count(0)
    #filter.track(@search_terms.to_java(:string))
    #filter.locations([[-87.168274,34.533147],[-86.318722, 34.931823]].to_java(Java::double[])) #North AL
    #filter.locations([[-74,40],[-73,41]].to_java(Java::double[])) #NY
    #filter.locations([[-122.75,36.8],[-121.75,37.8]].to_java(Java::double[])) #SFO
    #filter.locations([[1.63147,48.665571],[3.262939, 49.29468]].to_java(Java::double[])) #Paris
    #filter.locations([[-180,-90],[180, 90]].to_java(Java::double[])) #ALL
    filter.locations([[-121.68457, 27.469287,],[-64.226074, 50.34546]].to_java(Java::double[])) #USA
    stream.filter(filter)
    #stream.sample
    stream.shutdown if !@running
  end
  
end