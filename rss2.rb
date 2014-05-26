require 'rss'
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
record_akizuki = db.execute "select * from akizuki order by time desc limit 10;"  
record_aitendo = db.execute "select * from aitendo order by time desc limit 10;"

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
akizuki = RSS::Parser.parse('http://shokai.herokuapp.com/feed/akizuki.rss')
akizuki_item = akizuki.channel.items
(2..11).each do |num|
	text = akizuki_item[num].description
	link = akizuki_item[num].link
	ptext = Nokogiri::HTML.parse(text).xpath('//p')
	pimage = Nokogiri::HTML.parse(text).xpath('//img')
	akizuki_feed = ptext[1].text+" "+link+" "+pimage.attribute('src').value

	tweet(client, db, record_akizuki, "akizuki", akizuki_feed)
end
### akizuki end ###

### aitendo begin ##
aitendo = Nokogiri::HTML(open('http://www.aitendo.com/rss/rss.php'))
aitendo_titles = []
aitendo_links = []

aitendo.xpath('//title').each do |title|
	aitendo_titles << title.text
end
aitendo.xpath('//item').each do |link|
	aitendo_links << link.attribute('rdf:about').value	
end
# サイトのタイトルを削除
aitendo_titles.delete_at(0)

(0..9).each do |num|
	title = aitendo_titles[num]	
	link = aitendo_links[num]
	aitendo_feed = title+" "+link
	time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

	tweet(client, db, record_aitendo, "aitendo", aitendo_feed)
end
###aitendo end ###
