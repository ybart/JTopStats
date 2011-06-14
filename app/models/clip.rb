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
    top10_count >= 1 && top20_count >= 7
  end
end
