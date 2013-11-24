# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submission do
    user_id 1
    name "MyString"
    rating 1
    orientation "MyString"
    description "MyText"
  end
end
