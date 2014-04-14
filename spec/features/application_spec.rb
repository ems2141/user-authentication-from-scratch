require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'User can register to page' do
    visit '/'

    click_on('Register')
    fill_in'user_email', with: 'joe@example.com'
    fill_in'user_password', with: 'hello123'
    click_on('Register')

    expect(page).to have_content('Welcome, joe@example.com')

    click_on('Logout')
    expect(page).to_not have_content('Welcome, joe@example.com')
  end
end