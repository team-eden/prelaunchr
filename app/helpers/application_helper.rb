module ApplicationHelper
  def generate_facebook_share_message(referral_code)
    "Thanks to Habit, I\'m following a nutrition plan tailor-made for me. Get $25 off at checkout with code #{referral_code} to get yours. Shop here #{referral_link(referral_code)}"
  end

  def generate_twitter_share_message(referral_code)
    "Thanks to Habit, I\'m following a nutrition plan tailor-made for me. Get $25 off at checkout with code #{referral_code} to get yours. Shop here"
  end

  def referral_link(referral_code)
    "#{papaya_url}/referral?code=#{CGI::escape(referral_code)}"
  end

  def papaya_url
    case Rails.env
    when "test"
      "http://example.com"
    when "development"
      "http://lvh.me:3000"
    # when "staging" # staging
    #   "https://staging.habitbeta.com"
    when "acceptance"
      "https://myacceptance.habitbeta.com"
    # when "qa"
    #   "https://myqa.habitbeta.com"
    when "production"
      "https://my.habit.com"
    else
      fail "missing papaya url for #{Rails.env}"
    end
  end
end
