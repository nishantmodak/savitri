class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :invitable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :email, :name, :username, :role_id, :photo
  has_many :blogs
  has_many :comments
  has_many :notebooks
  has_many :media
  belongs_to :roles

  validates :username, :presence => true,
                      :length => { :minimum => 2 }

  validates :email, :presence => true
  validates :username, :uniqueness => true

  mount_uploader :photo, UserPhotoUploader

  acts_as_follower
  acts_as_followable

  after_initialize :init
  after_commit :follow_admin, :on => :create
  after_commit :flush_cache

  def follow_admin
    self.follow(User.find(1))
  end

  def init
    self.role_id ||= 3
  end

  def role
    Role.find_by_id(self.role_id).name
  end

  def role?(user)
    Role.find_by_id(self.role_id).name
  end

  def admin?
    "Admin" == (role?(self))
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end
  
  def self.admin_cached_blogs(q=1)
    Rail.cache.fetch(["User", q]) { User.find_by_id(q).blogs.order('id') }
  end

  def cached_name
    Rails.cache.fetch([self,"name"]) { name }
  end

  def cached_username
    Rails.cache.fetch([self,"username"]) { username }
  end

  def cached_blogs
    Rails.cache.fetch([self, "blogs"]) { blogs.order("id").to_a }
  end  

  def cached_blogs_count
    Rails.cache.fetch([self, "blogscount"]) { blogs.count }
  end  

  def flush_cache
    Rails.cache.delete(["User",self.id])
    Rails.cache.delete([self.class.name,self.id])

    Rails.cache.delete([self,"name"])
    Rails.cache.delete([self,"username"])
    Rails.cache.delete([self,"blogs"])
    Rails.cache.delete([self, "blogscount"])
  end

end
