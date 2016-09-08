require 'twitter'
require 'sentimental'
require 'gemoji'

class CherTweet

  attr_reader :username, :client, :tweets, :analyzer

  def initialize(username = 'cher')
    @username = username
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONS']
      config.consumer_secret     = ENV['TWITTER_SEC']
      config.access_token        = ENV['TWITTER_ACC']
      config.access_token_secret = ENV['TWITTER_ACC_SEC']
    end
    @tweets = get_tweets(24)
    @analyzer = Sentimental.new
    analyzer.load_defaults
  end

  def get_most_retweets()
    output = tweets[0]
    tweets.each do |tweet|
      if tweet.retweet_count > output.retweet_count
        output = tweet
      end
    end
    output
  end

  def get_least_retweets()
    output = tweets[0]
    tweets.each do |tweet|
      if tweet.retweet_count < output.retweet_count
        output = tweet
      end
    end
    output
  end

  def get_over_all_mood
    moods = Hash.new(0)
    tweets.each do |tweet|
      moods[get_tweet_mood(tweet)] += 1
    end
    moods.max_by { |k, v| v }[0]
  end

  def tweets_with_hearts
    output = []
    tweets.each do |tweet|
      output << tweet if has_hearts(tweet)
    end
    output
  end

  def print_tweet(tweet)
    puts "-----------------------------"
      puts tweet.retweet_count
      puts tweet.text
      puts tweet.source
      puts "Sentiment: #{analyzer.sentiment tweet.text}"
  end

  private

  def get_tweets(count)
    client.user_timeline(username, count: count)
  end

  def has_hearts(tweet)
    text = tweet.text
    text.split('').each do |char|
      if char.chomp == "\u1F489".encode('utf-8')
        puts 'here'
        return true
      end
    end
    return false
  end

  def get_tweet_mood(tweet)
    analyzer.sentiment tweet.text
  end
end
