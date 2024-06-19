require 'rails_helper'

RSpec.describe User, type: :model do
  it 'encrypts the password using bcrypt' do
    password = 'A1b2C3d4E5'
    user = create(:user, password:)

    expect(user.password_digest).not_to eq(password)
    expect(user.authenticate(password)).to eq(user)
    expect(user.authenticate('wrong_password')).to eq(false)
  end

  it 'is valid with a valid name and password' do
    user = build :user
    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    user = build :user, name: nil
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without a password' do
    user = build :user, password: nil
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'is invalid if the password is too short' do
    user = build :user, password: 'A1b2c3d4'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include('is too short (minimum is 10 characters)')
  end

  it 'is invalid if the password is too long' do
    user = build :user, password: 'A1b2c3d4e5f6g7h8i9j'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include('is too long (maximum is 16 characters)')
  end

  it 'is invalid if the password does not contain at least one lowercase letter' do
    user = build :user, password: 'ABCDEFGHI1'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(I18n.t('errors.messages.user.password_complexity'))
  end

  it 'is invalid if the password does not contain at least one uppercase letter' do
    user = build :user, password: 'abcdefghi1'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(I18n.t('errors.messages.user.password_complexity'))
  end

  it 'is invalid if the password does not contain at least one digit' do
    user = build :user, password: 'AbCdEfGhIj'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(I18n.t('errors.messages.user.password_complexity'))
  end

  it 'is invalid if the password contains three repeating characters in a row' do
    user = build :user, password: 'Abbbcdefg1'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(I18n.t('errors.messages.user.password_repeating'))
  end
end
