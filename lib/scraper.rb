require 'rubygems'
require 'open-uri'
require 'nokogiri'

COOKIE = " _ga=GA1.2.1848185124.1556738287; scribophilesessionid=5690db739727ec5cd05d6ddccca52180; __stripe_mid=51934a52-dfdc-4c32-a148-7f887afc1f7d; _gid=GA1.2.1385238478.1557167469"
GROUPS = ['poetic-prose', 'lit-up-the-land-of-little-tales', 'spirit-walking', 'spiritual-memoir-awareness-transcendence-non-duality', 'the-memoir-writers-hearth']
BASE_URL = "https://www.scribophile.com"

class Scraper
  attr_accessor :short_posts, :chapter_posts

  def initialize
    @short_posts = {}
    @chapter_posts = {}
  end

  def self.get_spotlight_posts(kind)
    scraper = new
    if kind == "group"

      puts "in group******"
      scraper._group_spotlight_posts
      scraper._show_spotlights
    else
      scraper._main_spotlight_posts
      scraper._show_spotlights
    end
  end

  def _group_spotlight_posts
    GROUPS.each do |group|
      url = "#{BASE_URL}/groups/#{group}/"
      _get_spotlights(url, group)
    end
  end

  def _main_spotlight_posts
    url = "https://www.scribophile.com/writing/"
    _get_spotlights(url)
  end

  def _get_spotlights(url, group=nil)
    document = _parse_page(url)

    recent_posts = document.css('table.work-list').css('tr')
    puts "Found #{recent_posts.count} in group #{group}" if group

    recent_posts.each do |post|
      if post.css('.work-spotlight-status spotlight')
        title = post.css('.work-details').css('p').text
        url = post.css('.work-details').css('a')[0]
        word_text = group ? post.css('.text').text.split("•")[1] : post.css('.words').text
        word_count = word_text.gsub(/\D/, '')

        chapter = /chapter/.match?(title.downcase)

        if word_count.to_i < 2000
          if chapter
            @chapter_posts[url] = {
              :word_count => word_count,
              :title => title,
            }
          else
            @short_posts[url] = {
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

Scraper.get_spotlight_posts(post_kind)
