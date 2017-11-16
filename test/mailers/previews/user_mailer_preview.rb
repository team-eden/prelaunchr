class UserMailerPreview < ActionMailer::Preview
  def signup_email
    UserMailer.signup_email(User.last)
  end
end
