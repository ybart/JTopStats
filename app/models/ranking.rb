class Ranking

  include DataMapper::Resource

  property :id, Serial

  property :rank, Integer
  property :progress, Integer
  property :vote_count, Integer
  property :vote_score, Integer
  property :pal_count, Integer
  property :pal_score, Integer

  belongs_to :clip  
  belongs_to :jtop
  belongs_to :prev_jtop, 'Jtop', :required => false
  
  has 1, :artist, :through => :clip
  #has 1, :prev_ranking, 'Ranking', :jtop_id => Ranking.all(:jtop_id.lt => jtop_id).aggregate(:jtop_id.max), :clip_id => clip_id
  
  def prev_ranking
    Ranking.all(:jtop_id => Ranking.all(:jtop_id.lt => jtop_id, :clip_id => clip_id).aggregate(:jtop_id.max), :clip_id => clip_id).first
  end
  
  def formatted_progress controller
    return I18n.t 'ranking.in' if prev_jtop_id.nil?
    
    plus = progress > 0 ? '+' : ''
    str = "#{plus}#{progress}".html_safe
    
    return  controller.link_to("#{str}*", controller.jtop_path(prev_jtop_id)) if jtop_id != prev_jtop_id + 1
    return str
  end
  
  def self.sorted_by_clips direction=:asc
    order = DataMapper::Query::Direction.new(clip.artist.name, direction)
    order2 = DataMapper::Query::Direction.new(clip.title, direction)
    query = all.query
    query.instance_variable_set("@order", [order, order2])
    query.instance_variable_set("@links", [relationships['clip'].inverse, Clip.relationships['artist'].inverse])
    all(query)
  end  
end
