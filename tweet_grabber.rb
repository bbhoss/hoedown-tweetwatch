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
    @tweet_count += 1
    @queue.publish( :message => status.getText, :sender => status.getUser.getName, :timestamp => Time.now.ctime )
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
    filter.track(@search_terms.to_java(:string))
    stream.filter(filter)
    stream.shutdown if !@running
  end
  
end