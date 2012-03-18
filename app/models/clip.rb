class Clip
  include DataMapper::Resource

  property :id, Serial

  property :title, String
  property :featuring, String

  property :top10_count, Integer
  property :top20_count, Integer

  belongs_to :artist
  has n, :rankings

  def gold?
    top10_count && top20_count && ((top10_count >= 1 && top20_count >= 7) || (top10_count >= 10))
  end

  def self.classics
    all(:top10_count.gte => 1, :top20_count.gte => 7) | all(:top10_count.gte => 10)
  end

  def self.sorted_by_title direction=:asc
    artist_name = DataMapper::Query::Direction.new(artist.name, direction)

    query = all.query.update(:order => [artist_name, :title],
                             :links => [relationships['artist'].inverse])
    all(query)
  end
end
