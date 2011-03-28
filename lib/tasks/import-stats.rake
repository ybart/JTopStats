require 'nokogiri'
require 'open-uri'

def date_parse str
  d,m,y = str.split('/')
  Time.mktime(y,m,d)
end

desc "Import statistics from Nolife web site"
task :import_stats => :environment do
  doc = Nokogiri::HTML(open('http://www.nolife-tv.com/resultats_j-top'))

  headers = doc.css('.TBnl th').collect {|h| h.content}
  expected_headers = ["Ordre", "Progression", "Artiste", "Clip", "Votes J-Top", "Score J-Top", "Votes J-Pote", "Score J-Pote", "Score Total"]

  unless expected_headers == headers
    throw Exception.new("Cannot find expected valid results data table. Aborting import.")
  end

  period = doc.css('#abonnement i').first.content
  start = date_parse(period.split(' ')[2])
  stop = date_parse(period.split(' ')[4])

  data = doc.css('.TBnl tr').collect{|r| r.css('td').collect{|d| d.content}}
end
