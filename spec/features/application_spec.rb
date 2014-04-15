require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'User can register, login with a valid email/password, and logout of a page' do
    visit '/'

    click_on('Register')
    fill_in 'user_email', with: 'joe@example.com'
    fill_in 'user_password', with: 'hello123'
    click_on('Register')
    expect(page).to have_content('Welcome, joe@example.com')

    click_on('Logout')
    expect(page).to_not have_content('Welcome, joe@example.com')

    click_on('Login')
    fill_in 'login_email', with: 'joe@example.com'
    fill_in 'login_password', with: 'hello123'
    click_on('Login')
    expect(page).to have_content('Welcome, joe@example.com')

    click_on('Logout')
    click_on 'Login'
    fill_in 'login_email', with: 'applepie@example.com'
    fill_in 'login_password', with: 'hello123'
    click_on('Login')
    expect(page).to have_content('Email / Password is invalid')

    fill_in 'login_email', with: 'joe@example.com'
    fill_in 'login_password', with: 'goodbye123'
    click_on('Login')
    expect(page).to have_content('Email / Password is invalid')
  end
end