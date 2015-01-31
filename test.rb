require 'feed-normalizer'
require 'open-uri'
require 'twitter'
require 'sqlite3'
require 'pit'
require 'opengraph'

link = "http://www.aitendo.com/product/4323"
img = OpenGraph.fetch(link)
exec( "wget -O './img/" + img.title + ".jpg' " + img.image )
