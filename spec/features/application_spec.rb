require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'User can register, login with a valid email/password, and logout of a page' do
    visit '/'

    click_on('Register')
    fill_in 'user_email', with: 'joe@example.com'
    fill_in 'user_password', with: 'hello123'
    fill_in 'pw_confirmation', with: 'hello123'
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

  scenario 'If a user is an admin, they can view all user emails and ids' do

    visit '/'
    click_on('Register')
    fill_in 'user_email', with: 'sam@example.com'
    fill_in 'user_password', with: 'hello123'
    fill_in 'pw_confirmation', with: 'hello123'
      click_on('Register')
    click_on('Logout')

    click_on('Register')
    fill_in 'user_email', with: 'jim@example.com'
    fill_in 'user_password', with: 'hello123'
    fill_in 'pw_confirmation', with: 'hello123'
      click_on('Register')
    click_on('Logout')

    DB[:users].where(email: 'sam@example.com').update(administrator: true)

    click_on 'Login'
    fill_in 'login_email', with: 'jim@example.com'
    fill_in 'login_password', with: 'hello123'
    click_on('Login')
    expect(page).to have_content('Welcome, jim@example.com')
    expect(page).to_not have_content('View all users')

    visit '/users'
    expect(page).to have_content('You do not have rights to visit this page.')

    visit '/'
    click_on 'Logout'

    click_on 'Login'
    fill_in 'login_email', with: 'sam@example.com'
    fill_in 'login_password', with: 'hello123'
    click_on('Login')
    expect(page).to have_content('Welcome, sam@example.com')
    click_on('View all users')
    expect(page).to have_content('sam@example.com')
    expect(page).to have_content('jim@example.com')
    expect(page).to have_content('1')
    expect(page).to have_content('2')
  end

  scenario 'Passwords cannot be blank, must match, and be greater than 3 characters for registration' do

    visit '/'
    click_on ('Register')
    fill_in 'user_email', with: '123@abc.com'
    fill_in 'user_password', with: '1234'
    fill_in 'pw_confirmation', with: 'abcd'
    click_on ('Register')
    expect(page).to have_content 'Passwords must match'

    fill_in 'user_email', with: '123@abc.com'
    fill_in 'user_password', with: '12'
    fill_in 'pw_confirmation', with: '12'
    click_on ('Register')
    expect(page).to have_content 'Password must be at least 3 characters'

    fill_in 'user_email', with: '123@abc.com'
    fill_in 'user_password', with: '     '
    fill_in 'pw_confirmation', with: '     '
    click_on ('Register')
    expect(page).to have_content 'Password field cannot be blank'

  end

  scenario 'User cannot register with an email address that already has an account' do

    visit '/'
    click_on('Register')
    fill_in 'user_email', with: 'jamie@example.com'
    fill_in 'user_password', with: 'hello123'
    fill_in 'pw_confirmation', with: 'hello123'
    click_on('Register')
    expect(page).to have_content('Welcome, jamie@example.com')

    click_on('Logout')
    expect(page).to_not have_content('Welcome, jamie@example.com')

    click_on('Register')
    fill_in 'user_email', with: 'jamie@example.com'
    fill_in 'user_password', with: 'hello123'
    fill_in 'pw_confirmation', with: 'hello123'
    click_on('Register')
    expect(page).to have_content('This email address has already been registered')

  end
end