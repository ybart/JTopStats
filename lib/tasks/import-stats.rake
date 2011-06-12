require 'nokogiri'
require 'open-uri'

def getchar
  begin
    system("stty raw -echo")
    str = STDIN.read(1)
  ensure
    system("stty -raw echo")
  end
  return str
end

def content_for entity, name
  entity.css(name).first.content
end

def date_parse str
  d,m,y = str.split('/')
  Time.mktime(y,m,d)
end

namespace :compute do
  namespace :rankings do

    desc "Compute progress values for all rankings"
    task :all => :environment do

    end

    desc "Compute progress values for missing rankings"
    task :missing => :environment do
      Ranking.all(:progress => nil, :prev_jtop => nil).each { |r|
        prev = r.prev_ranking

        if prev
          r.progress = prev.rank - r.rank
          r.prev_jtop_id = prev.jtop_id
          r.save
        end

      }
    end
  end
end

namespace :import do
  desc "Import statistics from Nolife web site"
  task :nolife => :environment do
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

  desc "Import MySQL batch from old J-Top Stats site"
  task :xml => :environment do
    unless ENV.include?("path")
      raise "usage: rake import_xml path=<file_path>"
    end

    doc = Nokogiri::XML(open(ENV['path']))
    unless doc && ['Artiste', 'Clip', 'jTop', 'Notation'].inject(true) {|x, y| x && (doc.css(y).count > 0)}
      puts "The file #{ENV['path']} is not a valid old J-Top MySQL XML export"
      next
    end

    print 'This will override current database. Do you want to continue (y/N) ? '
    unless getchar.downcase == 'y'
      puts 'n'
      next
    end

    puts 'y'

    DataMapper.auto_migrate!

    # Silent logger
    # DataMapper::Logger.new($stderr, :info)

    # Importing Artists
    doc.css('Artiste').each { |a|
      Artist.create(:id => content_for(a, 'id'), :name => content_for(a, 'nom'))
    }

    # Importing Clips
    doc.css('Clip').each { |c|
      Clip.create(:id => content_for(c, 'id'),
      :title => content_for(c, 'titre'),
      :artist_id => content_for(c, 'id_artiste'))
    }

    # Importing J-Tops
    doc.css('jTop').each { |t|
      Jtop.create(:id => content_for(t, 'id'),
      :aired_at => Time.at(content_for(t, 'date_jTop').to_i))
    }

    # Importing Rankings
    doc.css('Notation').each { |r|
      Ranking.create(
      :jtop_id => content_for(r, 'id_jTop'),
      :clip_id => content_for(r, 'id_clip'),
      :rank => content_for(r, 'num_classement'),
      :vote_score => content_for(r, 'score_vote'),
      :vote_count => content_for(r, 'num_votes'),
      :pal_score => content_for(r, 'score_jpote'),
      :pal_count => content_for(r, 'num_jpote'))
    }

  end

end