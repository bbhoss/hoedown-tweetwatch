require 'torquebox-stomp'
require 'json'

class TweetStomplet < TorqueBox::Stomp::JmsStomplet

  def configure(opts)
    super
    @topic = TorqueBox::Messaging::Topic.new( opts[:topic] )
  end

  def on_subscribe(subscriber)
    subscribe_to( subscriber, @topic )
  end

  def on_message(message, headers)
    puts "Message Received!\n"*5
    puts message.getContentAsString
    return message.getContentAsString
  end

end
