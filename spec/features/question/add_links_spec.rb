# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to question', "
In order to provide additional info to my question
As an question's author
I'd like to be able to add links
" do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/SynthesisOne/6b6c203392c75d2dd2e57c5fd4ac411d' }

  scenario 'User adds link when asks question', js: true do
    sign_in(user)

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text text text'
    click_on I18n.t('add_link')
    fill_in I18n.t('link_name'), with: 'My gist'
    fill_in I18n.t('link_url'), with: gist_url

    click_on I18n.t('helpers.submit.question.create')

    expect(page).to have_link 'My gist', href: gist_url
  end
end
