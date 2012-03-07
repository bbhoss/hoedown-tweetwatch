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

class Listener

  include StatusListener

  def onStatus(status)
    puts status.getUser.getName
  end

  def onException(exception)
    exception.printStackTrace
  end
end

stream = TwitterStreamFactory.new.getInstance
stream.addListener(Listener.new)
filter = FilterQuery.new
filter.count(0)
filter.track(["#thewalkingdead"].to_java(:string))
stream.filter(filter)