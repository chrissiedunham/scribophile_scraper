require 'rubygems'
require 'open-uri'
require 'nokogiri'

COOKIE = " _ga=GA1.2.1848185124.1556738287; scribophilesessionid=5690db739727ec5cd05d6ddccca52180; __stripe_mid=51934a52-dfdc-4c32-a148-7f887afc1f7d; _gid=GA1.2.1385238478.1557167469"
GROUPS = ['poetic-prose', 'lit-up-the-land-of-little-tales', 'spirit-walking', 'spiritual-memoir-awareness-transcendence-non-duality', 'the-memoir-writers-hearth']
BASE_URL = "https://www.scribophile.com"

class Scraper
  def self.get_group_posts
    GROUPS.each do |group|
      url = "#{BASE_URL}/groups/#{group}/"
      document = _parse_page(url)
      _get_spotlight_posts(document)
    end
  end

  def self.get_main_spotlight
    url = "https://www.scribophile.com/writing/"
    document = _parse_page(url)

    recent_posts = document.css('table.work-list').css('tr')

    recent_posts.each do |post|
      if post.css('.work-spotlight-status spotlight')
        link = post.css('a')[1]
        title = post.css('.work-details').css('p').text
        url = post.css('.work-details').css('a')[1]
        word_text = post.css('.words').text
        word_count = word_text.gsub(/\D/, '')
        if word_count.to_i < 2000
          puts "#{word_count}: #{title}"
          puts "url: #{BASE_URL}/#{url['href']}"
          puts ""
        end
      end
    end
  end

  def self._get_spotlight_posts(document)
    recent_posts = document.css('#work').css('table.work-list').css('tr')

    recent_posts.each do |post|
      if post.css('.work-spotlight-status spotlight')
        link = post.css('a')[1]
        word_text = post.css('.text').css('div')[0].text
        word_count = word_text.gsub(',', '').scan(/\d+/)[1]
        if word_count.to_i < 2000
          puts "#{word_count}: #{BASE_URL}#{link['href']}"
          puts ""
        end
      end
    end
  end

  def self._parse_page(url)
    page = open(url, "Cookie" => COOKIE)

    document = Nokogiri::HTML(page)
  end
end

Scraper.get_main_spotlight
