require 'rss'
require 'nokogiri'
require 'twitter'
require 'sqlite3'

client = Twitter::REST::Client.new(
	consumer_key:        "",
	consumer_secret:     "",
	access_token:        "",
	access_token_secret: "",
)

db = SQLite3::Database.open "ruby-rss-bot.sqlite3"
record = db.execute "select text from akizuki limit 10;"  

### akizuki begin ###
akizuki = RSS::Parser.parse('http://shokai.herokuapp.com/feed/akizuki.rss')
item = akizuki.channel.items
(2..11).each do |num|
	text = item[num].description
	link = item[num].link
	ptext = Nokogiri::HTML.parse(text).xpath('//p')
	pimage = Nokogiri::HTML.parse(text).xpath('//img')
	akizuki_feed = ptext[1].text+" "+link+" "+pimage.attribute('src').value
	time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

	record.each do |data|
		if  data != akizuki_feed then
			client.update(akizuki_feed)
			db.execute "insert into akizuki values ('#{akizuki_feed}', '#{time}');"
			p "tweet!"
		else
			break
		end
	end
end
### akizuki end ###
