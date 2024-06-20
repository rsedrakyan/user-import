require 'rails_helper'

RSpec.feature 'User Upload', type: :feature, js: true do
  scenario 'User uploads a valid CSV file' do
    visit root_path
    attach_file('file', Rails.root.join('spec/fixtures/files/users.csv'))
    click_button I18n.t('users.upload.button')

    expect(page).to have_content(I18n.t('users.upload.results.title'))

    within('ol') do
      expect(page).to have_selector('li', text: I18n.t('users.upload.results.statuses.success'))
      expect(page).to have_selector('li', text: I18n.t('users.upload.results.statuses.skip'))
      expect(page).to have_selector('li', text: I18n.t('users.upload.results.statuses.error'))
    end
  end

  scenario 'User uploads an invalid CSV file' do
    visit root_path
    attach_file('file', Rails.root.join('spec/fixtures/files/invalid_file.txt'))
    click_button I18n.t('users.upload.button')

    within('.error') do
      expect(page).to have_content(I18n.t('users.upload.errors.invalid_csv_file'))
    end
  end

  scenario 'User uploads a CSV file with missing columns' do
    visit root_path
    attach_file('file', Rails.root.join('spec/fixtures/files/missing_columns_users.csv'))
    click_button I18n.t('users.upload.button')

    within('.error') do
      expect(page).to have_content(I18n.t('users.upload.errors.invalid_csv_content'))
    end
  end
end
