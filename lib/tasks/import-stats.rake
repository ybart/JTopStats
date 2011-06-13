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

def compute_rankings rankings
  # Silent logger
  DataMapper::Logger.new($stderr, :info)

  count = 0
  rankings.each { |r|
    prev = r.prev_ranking

    if prev
      r.progress = prev.rank - r.rank
      r.prev_jtop_id = prev.jtop_id
      r.save
    end

    count += 1
    puts "Processed: #{count}" if count % 10000 == 0
  }
end

def fix_sequence model
  model.transaction do
    max = model.aggregate(:id.max)
    model.find_by_sql("SELECT setval('#{model.storage_name}_id_seq', #{max+1})")
  end
end

namespace :db do
  task :fix_sequences => :environment do
    [Ranking, Clip, Artist, Jtop].each {|model| fix_sequence model}
  end
end

namespace :compute do
  namespace :rankings do

    desc "Compute progress values for all rankings"
    task :all => :environment do
      compute_rankings Ranking.all
    end

    desc "Compute progress values for missing rankings"
<<<<<<< HEAD
    task :missing => :environment do
      Ranking.all(:progress => nil, :prev_jtop => nil).each { |r|
        prev = r.prev_ranking

        if prev
          r.progress = prev.rank - r.rank
          r.prev_jtop_id = prev.jtop_id
          r.save
        end

      }
=======
    task :fix => :environment do
      compute_rankings Ranking.all(:progress => 0, :prev_jtop => nil)
    end

    desc "Compute progress values for missing rankings"
    task :new => :environment do
      compute_rankings Ranking.all(:progress => nil, :prev_jtop => nil)
>>>>>>> e1cbae0... Nolife Website importer
    end
  end
  task :progress => 'progress:new'
end


namespace :import do
  desc "Import statistics from Nolife web site"
  task :nolife => :environment do
    jtop_id = ENV['jtop'] ? ENV['jtop'].to_i : Jtop.aggregate(:id.max)  + 1
    url = 'http://www.nolife-tv.com/resultats_j-top'
    url += "?periode=#{jtop_id + 8}"

    puts "Fetching J-Top #{jtop_id} at #{url}"

    doc = Nokogiri::HTML(open(url), nil, "utf8")

    headers = doc.css('.TBnl th').collect {|h| h.content}
    expected_headers = ["Ordre", "Progression", "Artiste", "Clip", "Votes J-Top", "Score J-Top", "Votes J-Pote", "Score J-Pote", "Score Total"]

    unless expected_headers == headers
      throw Exception.new("Cannot find expected valid results data table. Aborting import.")
    end

    # Silent logger
    DataMapper::Logger.new($stderr, :info) if ENV["silent"]

    period = doc.css('#abonnement i').first.content
    start = date_parse(period.split(' ')[2])
    stop = date_parse(period.split(' ')[4])

    data = doc.css('.TBnl tr').collect{|r| r.css('td').collect{|d| d.content}}

    Jtop.transaction do
      Ranking.all(:jtop_id.gte => jtop_id).destroy!
      Jtop.all(:id.gte => jtop_id).destroy!
      [Ranking, Clip, Artist, Jtop].each {|model| fix_sequence model}

      Jtop.create(:id => jtop_id, :aired_at => stop.in(2.days), :started_at => start, :ended_at => stop)

      count = 0
      old_rank = 0
      Ranking.raise_on_save_failure = true
      data.each { |rank, progress, artist, clip, vote_count, vote_score, pal_count, pal_score|
        artist = Artist.first_or_create(:name => artist.chomp)
        clip = Clip.first_or_create(:title => clip.chomp, :artist_id => artist.id)

        r = Ranking.new(:jtop_id => jtop_id, :rank => rank, :clip_id => clip.id,
                        :vote_count => vote_count, :vote_score => vote_score,
                        :pal_count => pal_count, :pal_score => pal_score)

        prev_ranking = r.prev_ranking
        if prev_ranking
          r.prev_jtop_id = prev_ranking.jtop_id
          r.progress = prev_ranking.rank - r.rank
        end
        r.save

        count += 1
        puts "Imported #{count} rankings" if count % 100 == 0
        throw "Uh Oh #{r.rank} != #{old_rank}+1" if r.rank != old_rank + 1
        old_rank += 1
      }
    end
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

    if ENV.include?("non_interactive")
      puts "This will override current database."
    else
      print 'This will override current database. Do you want to continue (y/N) ? '
      unless getchar.downcase == 'y'
        puts 'n'
        next
      end

      puts 'y'
    end

    DataMapper.auto_migrate!
    puts "DB Size: " + Clip.find_by_sql("SELECT pg_size_pretty(pg_database_size('postgres')) as artist_id").first.artist_id

    # Silent logger
    DataMapper::Logger.new($stderr, :info)

    # Importing Artists
    puts "Migrating Artists..."
    doc.css('Artiste').each { |a|
      Artist.create(:id => content_for(a, 'id'), :name => content_for(a, 'nom'))
    }
    puts "DB Size: " + Clip.find_by_sql("SELECT pg_size_pretty(pg_database_size('postgres')) as artist_id").first.artist_id

    # Importing Clips
    puts "Migrating Clips..."
    doc.css('Clip').each { |c|
      Clip.create(:id => content_for(c, 'id'),
      :title => content_for(c, 'titre'),
      :artist_id => content_for(c, 'id_artiste'))
    }
    puts "DB Size: " + Clip.find_by_sql("SELECT pg_size_pretty(pg_database_size('postgres')) as artist_id").first.artist_id

    # Importing J-Tops
    puts "Migrating J-Tops..."
    doc.css('jTop').each { |t|
      Jtop.create(:id => content_for(t, 'id'),
      :aired_at => Time.at(content_for(t, 'date_jTop').to_i))
    }

    # Importing Rankings
    puts "Migrating Rankings..."
    count = 0
    doc.css('Notation').each { |r|
      Ranking.create(
      :jtop_id => content_for(r, 'id_jTop'),
      :clip_id => content_for(r, 'id_clip'),
      :rank => content_for(r, 'num_classement'),
      :vote_score => content_for(r, 'score_vote'),
      :vote_count => content_for(r, 'num_votes'),
      :pal_score => content_for(r, 'score_jpote'),
      :pal_count => content_for(r, 'num_jpote'))
      count += 1
      if count % 10000 == 0
        puts "Added rankings: " + Ranking.count.to_s
      end
    }
  end
end

task :import => 'import:nolife'
