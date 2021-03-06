# frozen_string_literal: true

require 'rails_helper'
feature 'User can create answer for question', "
To write the answer to the question as an authorized user
I would like to write an answer to the question
" do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  describe 'Authernticated user', js: true do
    background do
      sign_in(user)
    end

    subject { fill_in 'Body', with: 'Answer body' }

    scenario 'create answer for question' do
      visit question_path(question)
      within '.new-answer' do
        subject
        attach_file 'Files', Rails.root.join('spec', 'rails_helper.rb')
        click_on I18n.t('helpers.submit.answer.create')
      end
      within '.answers' do
        expect(page).to have_content 'Answer body'
        expect(page).to have_link('rails_helper.rb')
      end
    end

    scenario 'create answer for question with errors' do
      visit question_path(question)
      within '.new-answer' do
        fill_in 'Body', with: ''
        click_on I18n.t('helpers.submit.answer.create')
      end
      expect(page).to have_content "Body can't be blank"
    end

    scenario 'send an answer with link' do
      visit question_path(question)
      within '.new-answer' do
        subject
        click_on I18n.t('add_link')

        fill_in I18n.t('link_name'), with: 'GIST LINK'
        fill_in I18n.t('link_url'), with: 'https://gist.github.com/SynthesisOne/6b6c203392c75d2dd2e57c5fd4ac411d'

        click_on I18n.t('helpers.submit.answer.create')
      end
      expect(page).to have_link 'GIST LINK'
    end

    scenario 'asks a question with invalid link' do
      visit question_path(question)
      within '.new-answer' do
        subject
        click_on I18n.t('add_link')

        fill_in I18n.t('link_name'), with: 'GIST LINK'
        fill_in I18n.t('link_url'), with: 'INVALID TEXT'

        click_on I18n.t('helpers.submit.answer.create')
      end
      expect(page).to have_content 'Links url is invalid'
    end

    scenario 'send an answer with empty link' do
      visit question_path(question)
      within '.new-answer' do
        subject
        click_on I18n.t('add_link')

        fill_in I18n.t('link_name'), with: 'GIST LINK'
        fill_in I18n.t('link_url'), with: ''

        click_on I18n.t('helpers.submit.answer.create')
      end
      expect(page).to have_content "Links url can't be blank"
    end
  end

  scenario 'Unauthenticated user try create answer' do
    visit question_path(question)
    within '.new-answer' do
      fill_in 'Body', with: ''
      click_on I18n.t('helpers.submit.answer.create')
    end
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  describe 'multiple sessions' do
    let(:another_question) { create(:question) }

    scenario "answer appears on another user's page", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        within '.new-answer' do
          fill_in 'Body', with: 'This is test answer for some question'
          click_on I18n.t('helpers.submit.answer.create')
        end
        expect(page).to have_content 'This is test answer for some question'
      end

      Capybara.using_session('guest') do
        expect(page).to have_content 'This is test answer for some question'
      end
    end

    scenario "answer do not appears on another question's page", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(another_question)
      end

      Capybara.using_session('user') do
        within '.new-answer' do
          fill_in 'Body', with: 'This is test answer for some question'
          click_on I18n.t('helpers.submit.answer.create')
        end
        expect(page).to have_content 'This is test answer for some question'
      end

      Capybara.using_session('guest') do
        expect(page).to_not have_content 'This is test answer for some question'
      end
    end
  end
end
