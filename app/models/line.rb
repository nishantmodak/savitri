class Line < ActiveRecord::Base
  attr_accessible :line, :no, :stanza_id
  belongs_to :stanza

  validates :no, :uniqueness => true
  validates :line, :no, :stanza_id, :presence => true

  accepts_nested_attributes_for :stanza, :allow_destroy => :true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }


  def to_param
  	no
  end

   searchable do 
     text :line
     text :no
     integer :id
#  --facets below--
     string :section
     string :canto
     string :lbook
     string :length
     string :category
   end

  def category
    self.class.name + "s"
  end

  def runningno
    stanza.runningno
  end

  def share_url
    "/read/"+section.to_s+"."+stanza.runningno.to_s
  end

  def section
    Section.find(Stanza.find(self.stanza_id).section_id).no
  end

  def canto
    Canto.find(Section.find_by_no(section).canto_id).no
  end

  def book
    Book.find(Canto.find_by_no(canto).book_id).no
  end

  def lbook
    book
  end

  def length
    Stanza.find(self.stanza_id).lines.count
  end
end
