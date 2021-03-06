# frozen_string_literal: true

require 'rails_helper'
feature 'User can edit his answer', "
In order to correct mistakes
As an author of answer
I'd like ot be able to edit my answer
" do
  given!(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: user) }

  describe 'Authenticated user', js: true do
    background { sign_in(user) }
    background { visit question_path(question) }

    scenario 'edits his answer' do
      within '.answers' do
        within "#answer-id-#{answer.id}" do
          click_on I18n.t('edit_answer')

          fill_in 'Your answer', with: 'edited answer'

          click_on I18n.t('helpers.submit.answer.update')
          expect(page).not_to have_content answer.body
          expect(page).to have_content 'edited answer'
          expect(page).not_to have_selector 'textarea'
        end
      end
    end
    context 'Links' do
      given(:url) { 'https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#using-factories' }
      subject do
        click_on I18n.t('edit_answer')
        click_on I18n.t('add_link')
      end

      scenario 'try add one link' do
        within "#answer-id-#{answer.id}" do
          subject

          fill_in I18n.t('link_name'), with: 'GIST'
          fill_in I18n.t('link_url'), with: url

          click_on I18n.t('helpers.submit.answer.update')
          expect(page).to have_link 'GIST'
        end
      end

      scenario 'try add links' do
        within "#answer-id-#{answer.id}" do
          subject

          within first('.nested-fields') do
            fill_in I18n.t('link_name'), with: 'GIST'
            fill_in I18n.t('link_url'), with: url
          end
          click_on I18n.t('add_link')

          within all('.nested-fields')[1] do
            fill_in I18n.t('link_name'), with: 'GIST_2'
            fill_in I18n.t('link_url'), with: url
          end

          click_on I18n.t('helpers.submit.answer.update')

          expect(page).to have_link 'GIST'
          expect(page).to have_link 'GIST_2'
        end
      end

      context 'try delete link' do
        given!(:answer) { create(:answer, :with_link, question: question, user: user) }

        scenario 'delete one link' do
          within "#answer-id-#{answer.id}" do
            expect(page).to have_content(answer.reload.links.first.name)
            click_on I18n.t('edit_answer')

            within "#edit-answer-#{answer.id}" do
              within ".link-id-#{answer.links.first.id}" do
                click_on I18n.t('links.link.delete_link')
              end
            end
            expect(page).to_not have_content(answer.links.first.name)
          end
        end
      end

      context 'try delete links' do
        given!(:answer) { create(:answer, :with_links, question: question, user: user) }

        scenario 'add links' do
          within '.answers' do
            within "#answer-id-#{answer.id}" do
              click_on I18n.t('edit_answer')

              within "#edit-answer-#{answer.id}" do
                expect(page).to have_content(answer.reload.links.first.name)
                expect(page).to have_content(answer.links.last.name)

                within ".link-id-#{answer.links.first.id}" do
                  click_on I18n.t('links.link.delete_link')
                end

                expect(page).to_not have_content(answer.links.first.name)
                expect(page).to have_content(answer.links.last.name)
              end
            end
          end
        end
      end
    end

    scenario 'with attached file' do
      within '.answers' do
        within "#answer-id-#{answer.id}" do
          click_on I18n.t('edit_answer')
          attach_file 'Files', Rails.root.join('spec', 'rails_helper.rb')
          click_on I18n.t('helpers.submit.answer.update')
          expect(page).to have_link('rails_helper.rb')
        end
      end
    end

    scenario 'with attached files' do
      within '.answers' do
        within "#answer-id-#{answer.id}" do
          click_on I18n.t('edit_answer')

          attach_file 'Files', [
            Rails.root.join('spec', 'rails_helper.rb'),
            Rails.root.join('spec', 'spec_helper.rb')
          ]

          click_on I18n.t('helpers.submit.answer.update')
          expect(page).to have_link('rails_helper.rb')
          expect(page).to have_link('spec_helper.rb')
        end
      end
    end

    context 'delete attachment' do
      given!(:answer) { create(:answer, :with_file, question: question, user: user) }
      given!(:attachment) { answer.files.first }

      scenario 'try delete attachment' do
        within '.answers' do
          within "#answer-id-#{answer.id}" do
            click_on I18n.t('edit_answer')

            within '.attachments' do
              click_on I18n.t('delete_attachment')
            end
            click_on I18n.t('helpers.submit.answer.update')
            expect(page).to_not have_content have_content(attachment.filename)
          end
        end
      end
    end

    context 'try delete one of two attachment' do
      given!(:answer) { create(:answer, :with_files, question: question, user: user) }
      given(:attachment_first) { answer.files.first }
      given(:attachment_second) { answer.files.last }

      scenario 'attached file' do
        within '.answers' do
          within "#answer-id-#{answer.id}" do
            click_on I18n.t('edit_answer')

            within '.attachments' do
              expect(page).to have_content(attachment_first.filename)
              expect(page).to have_content(attachment_second.filename)

              within ".attachment-id-#{attachment_first.id}" do
                click_on I18n.t('delete_attachment')
              end

              expect(page).to_not have_content(attachment_first.filename)
              expect(page).to have_content(attachment_second.filename)
            end
          end
        end
      end
    end

    describe 'edits his answer with errors' do
      scenario 'type empty Body' do
        within '.answers' do
          click_on 'Edit'
          fill_in 'Body', with: ''
          click_on I18n.t('helpers.submit.answer.update')
          expect(page).to have_content "Body can't be blank"
        end
      end
    end
  end

  scenario 'Unauthenticated can not edit answer' do
    visit question_path(question)

    within '.answers' do
      expect(page).not_to have_link 'Edit'
    end
  end
end
