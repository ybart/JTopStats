class Jtop

  include DataMapper::Resource

  property :id, Serial

  property :aired_at, Date
  property :started_at, Date
  property :ended_at, Date

  property :presented_by, String

  has n, :rankings
end
