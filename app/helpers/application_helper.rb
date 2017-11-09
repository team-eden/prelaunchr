module ApplicationHelper
  def papaya_url
    case Rails.env
    when "test"
      "http://example.com"
    when "development"
      "http://localhost:3000"
    when "staging" # staging
      "https://staging.habitbeta.com"
    when "acceptance" # staging
      "https://myacceptance.habitbeta.com"
    when "qa"
      "https://myqa.habitbeta.com"
    when "production"
      "https://my.habit.com"
    else
      fail "missing papaya url for #{Rails.env}"
    end
  end
end
