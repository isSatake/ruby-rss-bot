require 'rss'
require 'nokogiri'
require 'twitter'

client = Twitter::REST::Client.new(
	consumer_key:        "",
	consumer_secret:     "",
	access_token:        "",
	access_token_secret: "",
)

### akizuki begin ###
akizuki = RSS::Parser.parse('http://shokai.herokuapp.com/feed/akizuki.rss')
akizuki.channel.items.each do |item|
	text = item.description
	link = item.link
	ptext = Nokogiri::HTML.parse(text).xpath('//p')
	pimage = Nokogiri::HTML.parse(text).xpath('//img')
	p ptext[1].text
	p link
	p pimage.attribute('src').value
	client.update(ptext[1].text+" "+link+" "+pimage.attribute('src').value)
end
### akizuki end ###

