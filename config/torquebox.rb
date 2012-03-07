TorqueBox.configure do

  service TweetGrabber do
    config( :search_terms => ['halo 4'], :queue => '/queue/tweets' )
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
    consumer_key "5pHqu6h25i1qm0Ob4eOGw"
    consumer_secret "l5QAhYT8ZAcTuzHkgtUYOl728LYu88MwSVKdIZMc"
    access_token "14313508-FdtcFIfyWpX8mcTVQFs3mxRpW5B1u7D5DapJzHXc"
    access_token_secret "BIf1uy6s9aCfCjaALDT5e4Pp6FS8nmsISXq1cjpeWNg"
  end

end
