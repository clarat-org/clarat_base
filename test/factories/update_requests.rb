require 'ffaker'

FactoryBot.define do
  factory :update_request do
    search_location 'MyString'
    email { FFaker::Internet.email }
  end
end
