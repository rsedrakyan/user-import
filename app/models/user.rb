class User < ApplicationRecord
  require 'bcrypt'

  has_secure_password

  validates :name, presence: true
  validates :password, presence: true, length: { in: 10..16 }
  validate :password_strength

  private

  def password_strength
    return if password.nil?

    unless password.match?(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add(:password, I18n.t('errors.messages.user.password_complexity'))
    end

    # Does not contain repeating characters
    return unless password.match?(/(.)\1\1/)

    errors.add(:password, I18n.t('errors.messages.user.password_repeating'))
  end
end
