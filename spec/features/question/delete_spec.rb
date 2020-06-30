# frozen_string_literal: true

require 'rails_helper'
feature 'User can delete his question', "
The user should be able to delete his question
but not someone else’s
" do
  given(:user)     { create(:user) }
  given(:user_2)   { create(:user) }
  given(:question) { user.questions.create(attributes_for(:question)) }
  background do
    sign_in(user)
    create_question(question)
  end

  scenario 'User try delete his question' do
    click_on 'Delete'
    expect(page).to have_content 'Question successfully deleted.'
  end
end
