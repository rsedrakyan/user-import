class User < ApplicationRecord
  require 'bcrypt'

  has_secure_password

  validates :name, presence: true
  validates :password, length: { in: 10..16, allow_blank: true }
  validate :password_strength

  private

  def password_strength
    return if password.nil?

    unless password.match?(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add(:password, I18n.t('errors.messages.user.password_complexity'))
    end

    # Do not allow 3 repeating characters in a row
    return unless password.match?(/(.)\1\1/)

    errors.add(:password, I18n.t('errors.messages.user.password_repeating'))
  end
end
