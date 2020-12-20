class Course < ApplicationRecord
  validates :title, :short_description, :language, :price, :level, presence: true
  validates :description, presence: true, length: { :minimum => 5 }
  validates :title, uniqueness: true

  belongs_to :user, counter_cache: true
  #User.find_each { |user| User.reset_counters(user.id, :courses)}
  has_many :lessons, dependent: :destroy
  has_many :enrollments
  has_many :user_lessons, through: :lessons


  scope :latest_courses, -> { limit(3).order(created_at: :desc) }
  scope :top_rated_courses, -> { limit(3).order(average_rating: :desc, created_at: :desc) }
  scope :popular_courses, -> { limit(3).order(enrollments_count: :desc, created_at: :desc) }

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user rescue nil }

  def to_s
    title
  end

  has_rich_text :description

  extend FriendlyId
  friendly_id :title, use: :slugged

  # Generate random slug on create

  #friendly_id :generate_slug, use: :slugged
  #def generate_slug
  #  require 'securerandom'
  #  @random_slug ||= persisted? ? friendly_id: SecureRandom.hex(4)
  #end

  LANGUAGES = [:"English", :"Portuguese", :"Spanish"]
  def self.languages
    LANGUAGES.map { |language| [language, language] }
  end

  LEVELS = [:"Beginner", :"Intermediate", :"Advanced"]
  def self.levels
    LEVELS.map { |level| [level, level] }
  end

  def bought(user)
    self.enrollments.where(user_id: [user.id], course_id: [self.id]).any?
  end

  def progress(user)
    unless self.lessons_count.zero?
      (user_lessons.where(user: user).count.to_f/self.lessons_count.to_f) * 100
    end
  end

  def update_rating
    if enrollments.any? && enrollments.where.not(rating: nil).any?
      update_column :average_rating, (enrollments.average(:rating).round(2, :truncate).to_f)
    else
      update_column :average_rating, (0.0)
    end
  end

end
