TorqueBox.configure do

  service TweetGrabber do
    config( :search_terms => ['sxsw'], :queue => '/queue/tweets' )
  end

  queue '/queue/tweets' do
    processor PlainTextProcessor do
      concurrency 5
      config( :topic => '/topic/messages' )
    end
  end

  topic '/topic/messages'

  stomplet TweetStomplet do
    route '/stomplet/messages'
    config( :topic => '/topic/messages' )
  end

  environment do
  end

end
