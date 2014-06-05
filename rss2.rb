require 'feed-normalizer'
require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'sqlite3'

client = Twitter::REST::Client.new(
	consumer_key:        "",
	consumer_secret:     "",
	access_token:        "",
	access_token_secret: "",
)

db = SQLite3::Database.open "ruby-rss-bot.sqlite3"
record_akizuki = db.execute "select * from akizuki order by time desc limit 20;"  
record_aitendo = db.execute "select * from aitendo order by time desc limit 20;"
record_slinux = db.execute "select * from slinux order by time desc limit 20;"

def tweet(twitter_client, db, record_data, record_name, text)
	repeated = false
	record_data.each do |data|
		if data[0] == text then
			repeated = true
		end
	end
	if !repeated then	
		time = Time.now.strftime("%Y-%m-%d %H:%M:%S")	
		db.execute "insert into #{record_name} values ('#{text}', '#{time}');"
		twitter_client.update(text)
	end	
end

### akizuki begin ###
akizuki = FeedNormalizer::FeedNormalizer.parse open('http://shokai.herokuapp.com/feed/akizuki.rss')
akizuki_item = akizuki.entries

(2..21).each do |num|	
	text = akizuki_item[num].description
	link = akizuki_item[num].url
	ptext = Nokogiri::HTML.parse(text).xpath('//p')
	pimage = Nokogiri::HTML.parse(text).xpath('//img')
	akizuki_feed = ptext[1].text+" "+link+" "+pimage.attribute('src').value

	tweet(client, db, record_akizuki, "akizuki", akizuki_feed)
end
### akizuki end ###

### aitendo begin ##
aitendo = FeedNormalizer::FeedNormalizer.parse open('http://www.aitendo.com/rss/rss.php')
aitendo_item = aitendo.entries

(0..19).each do |num|
	title = aitendo_item[num].title
	link = aitendo_item[num].url
	aitendo_feed = title+" "+link

	tweet(client, db, record_aitendo, "aitendo", aitendo_feed)
end
###aitendo end ###

###strawberry-linux begin###
uri = URI.parse 'http://pipes.yahoo.com/pipes/pipe.run?_id=43d7a8defa45bcda73071c0a157abadf&_render=rss'
slinux = FeedNormalizer::FeedNormalizer.parse open(uri)
slinux_item = slinux.entries

(0..19).each do |num|
	title = slinux_item[num].title
	link = slinux_item[num].url
	slinux_feed = title+" "+link

	tweet(client, db, record_slinux, "slinux", slinux_feed)
end
###strawberry-linux end###

p "end"
