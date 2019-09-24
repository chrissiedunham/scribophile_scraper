require 'rubygems'
require 'open-uri'
require 'nokogiri'

COOKIE = " _ga=GA1.2.1848185124.1556738287; scribophilesessionid=5690db739727ec5cd05d6ddccca52180; __stripe_mid=51934a52-dfdc-4c32-a148-7f887afc1f7d; _gid=GA1.2.1385238478.1557167469"
GROUPS = ['poetic-prose', 'lit-up-the-land-of-little-tales', 'spirit-walking', 'spiritual-memoir-awareness-transcendence-non-duality', 'the-memoir-writers-hearth', 'lets-get-real']
BASE_URL = "https://www.scribophile.com"
MY_URI = "authors/chrissie-dunham/"

class Scraper
  attr_accessor :short_posts, :chapter_posts

  def initialize(max_word_count)
    @max_word_count = max_word_count
    @short_posts = {}
    @chapter_posts = {}
  end

  def self.get_spotlight_posts(kind, max_word_count=1000)
    scraper = new(max_word_count)
    if kind == "group"
      scraper._group_spotlight_posts
    elsif kind == "favs"
      scraper._group_spotlight_posts
    else
      scraper._main_spotlight_posts
    end
    scraper._show_spotlights
  end

  def _group_spotlight_posts
    GROUPS.each do |group|
      url = "#{BASE_URL}/groups/#{group}/"
      _get_spotlights(url, group)
    end
  end

  def _favorite_urls
    document = _parse_page("#{BASE_URL}/#{MY_URI}")
    favorites  = document.css('section#favorites').css('li')
    favorites.map do |fav|
      fav.css('a')[0]['href']
    end
  end

  def _group_spotlight_posts
    _favorite_urls.each do |fav_url|
      url = "#{BASE_URL}/#{fav_url}"

      _get_spotlights(url)
    end
  end

  def _main_spotlight_posts
    url = "#{BASE_URL}/writing/"
    _get_spotlights(url)
  end

  def _get_spotlights(url, group=nil)
    document = _parse_page(url)
    recent_posts = document.css('table.work-list').css('tr')

    recent_posts.each do |post|
      unless post.css('.spotlight').empty?
        title = post.css('.work-details').css('p').text

        post_url = post.css('.work-details').css('a')[0]
        word_text = group ? post.css('.text').text.split("•")[1] : post.css('.words').text
        word_count = word_text.gsub(/\D/, '')
        is_mine = !post.css('a')[0]['href'].match(/dunham/).nil?
        next if is_mine

        chapter = (/chapter/ =~ (title.downcase))

        if word_count.to_i < @max_word_count
          if chapter
            @chapter_posts[post_url] = {
              :word_count => word_count,
              :title => title,
            }
          else
            @short_posts[post_url] = {
              :word_count => word_count,
              :title => title,
              :group => group,
            }
          end
        end
      end
    end
  end

  def _show_spotlights
    puts "STANDALONE POSTS"
    @short_posts.each do |url, post|
      puts "#{post[:word_count]}: #{post[:title]}"
      puts "url: #{BASE_URL}/#{url['href']}"
      puts "group: #{post[:group]}"
      puts ""
    end

    puts "*"*10
    puts "CHAPTER POSTS"
    chapter_posts.each do |url, post|
      puts "#{post[:word_count]}: #{post[:title]}"
      puts "url: #{BASE_URL}/#{url['href']}"
      puts ""
    end
  end

  def _parse_page(url)
    page = open(url, "Cookie" => COOKIE)

    Nokogiri::HTML(page)
  end
end

post_kind = ARGV[0]
max_word_count = ARGV[1].to_i

puts "Please specify [group|main|favs] [max_words]" unless ARGV.length == 2

Scraper.get_spotlight_posts(post_kind, max_word_count)
