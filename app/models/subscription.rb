class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  with_options if: -> { user.present? } do
    validates :user, uniqueness: {scope: :event_id}
    validate :user_email_self_subscription
  end

  with_options unless: -> { user.present? } do
    validates :user_name, presence: true, length: {maximum: 25}
    validates :user_email, presence: true, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/, length: {maximum: 40}
    validates :user_email, uniqueness: {scope: :event_id}
    validate :user_email_busyness
  end

  def user_name
    user&.name || super
  end

  def user_email
    user&.email || super
  end

  private

  def user_email_self_subscription
    errors.add(:user_email, :self_subscription) if user == event.user
  end

  def user_email_busyness
    errors.add(:user_email, :taken) if User.find_by(email: user_email).present?
  end
end
