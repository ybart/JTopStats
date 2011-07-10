class Artist

  include DataMapper::Resource

  property :id, Serial

  property :name, String

  has n, :clips

  def clip_count
    clips.count
  end
end
