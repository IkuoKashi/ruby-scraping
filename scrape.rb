require 'net/http'

def get_from(url)
#     url = 'https://masayuki14.github.io/pit-news/'
#     uri = URI(url)
#     html = Net::HTTP.get(uri)
#   #htmlを返す
#   return 'html'
  Net::HTTP.get(URI(url))
end

def write_file(path, text)
   #pathにテキストを保存する
#   file = File.open(path, 'w')
#   file.write(text)
#   file.close

#  File.open(path, 'w') do |file|
#     file.write(text) 
#  end

 File.open(path, 'w') { |file| file.write(text) }
end

require 'nokogiri'

html = File.open('pitnews.html', 'r') {|f| f.read}
doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
# nodes = doc.xpath('//h6')

pitnews = []
doc.xpath('/html/body/main/section').each_with_index do |section, index|
# section = doc.xpath('/html/body/main/section[2]').first

    next if index.zero?
    contents = {category: nil, news: []}
    contents[:category] = section.xpath('./h6').first.text
    
    section.xpath('./div/div').each do |node|
       title = node.xpath('./p/strong/a').first.text
       url = node.xpath('./p/strong/a').first['href']
       
       news = {title: title, url: url}
       contents[:news] << news
    end
     pitnews << contents
end

pp pitnews

require 'json'
File.open('pitnews.json', 'w') { |file| file.write({pitnews: pitnews}.to_json) }

#リファクタリング
require 'net/http'
require 'nokogiri'
require 'json'

def get_from(url)
    Net::HTTP.get(URI(url))
end

def write_file(path, text)
    File.open(path, 'w') { |file| file.write(text) }
end

def scrape_news(news)
  {
    title: news.xpath('./p/strong/a').first.text,
    url: news.xpath('./p/strong/a').first['href']
  }
end

def scrape_section(section)
  {
    category: section.xpath('./h6').first.text,
    news:  section.xpath('./div/div').map { |node| scrape_news(node) }
  }
end

html = File.read('pitnews.html')
doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
pitnews = doc.xpath('/html/body/main/section[position() > 1]').map { |section| scrape_section(section) }
write_file('pitnews.json', {pitnews: pitnews}.to_json)