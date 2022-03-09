class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}
  validates :star,presence:true, numericality: {
    less_than_or_equal_to: 5,
    greater_than_or_equal_to: 1,
  }
  validates :category, presence: true

  is_impressionable counter_cache:

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  #検索方法の分岐
  def self.looks(search, word)
    if search == "perfect_match"
      @book = Book.where("title LIKE? OR category LIKE?", "#{word}","#{word}")
    elsif search == "forward_match"
      @book = Book.where("title LIKE?", "#{word}%")
    elsif search == "backward_match"
      @book = Book.where("title LiKE?", "%#{word}")
    elsif search == "partial_match"
      @book = Book.where("title LIKE? OR category LIKE?", "%#{word}%","%#{word}%")
    else
      @book = Book.all
    end
  end

  def self.search(search_word)
    Book.where(['category LIKE?', "#{search_word}"])
  end

  scope :newest, -> {order(created_at: :desc)}
  scope :review, -> {order(star: :desc)}

  scope :created_today, -> {where(created_at: Time.zone.now.all_day)}
  scope :created_yesterday, -> {where(created_at: 1.day.ago.all_day)}
  scope :created_this_week, -> {where(created_at: 6.day.ago.beginning_of_day..Time.zone.now.end_of_day)}
  scope :created_last_week, -> {where(created_at: 2.week.ago.beginning_of_day..1.week.ago.end_of_day)}
  scope :created_day, -> (num) {where(created_at: (num).days.ago.all_day)}
end
