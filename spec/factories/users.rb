FactoryBot.define do
  factory :user do
    name { "test" }
    email { "test@test.com"}
    password { "12345678"}
    password_confirmation { "12345678"}
  end
end
