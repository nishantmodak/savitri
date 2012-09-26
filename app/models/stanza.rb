class Stanza < ActiveRecord::Base
  attr_accessible :stanzno, :canto_id
  has_many :lines
  belongs_to :canto

  validates :stanzno , :uniqueness => true
end
