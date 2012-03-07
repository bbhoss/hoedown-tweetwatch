require 'torquebox-messaging'
require 'json'

class PlainTextProcessor < TorqueBox::Messaging::MessageProcessor

  def initialize(opts)
    @topic = TorqueBox::Messaging::Topic.new( opts['topic'] )
  end
  
  def on_message(data)
    data[:type] = :tweet
    chrome_encoding_hack(data[:message])
    chrome_encoding_hack(data[:sender])
    @topic.publish( data.to_json )
  end

  def chrome_encoding_hack(string)
  	string.encode!('ASCII', :invalid => :replace, :undef => :replace)
  end
end
