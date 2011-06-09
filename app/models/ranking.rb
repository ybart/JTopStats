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
  
  has 1, :artist, :through => :clip
  
  def self.sorted_by_clips direction=:asc
    order = DataMapper::Query::Direction.new(clip.artist.name, direction)
    order2 = DataMapper::Query::Direction.new(clip.title, direction)
    query = all.query
    query.instance_variable_set("@order", [order, order2])
    query.instance_variable_set("@links", [relationships['clip'].inverse, Clip.relationships['artist'].inverse])
    all(query)
  end  
end
