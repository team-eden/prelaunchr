require "net/http"
require "uri"

class UsersController < ApplicationController
  include ApplicationHelper

  before_filter :skip_first_page, only: :new
  # before_filter :handle_ip, only: :create

  helper_method :social_callback_url
  helper_method :referral_link

  def new
    @bodyId = 'new'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    ref_code = cookies[:h_ref]
    email = params[:user][:email]
    @user = User.new(email: email)
    @user.referrer = User.find_by_referral_code(ref_code) if ref_code

    if @user.save
      cookies[:h_email] = { value: @user.email }

      # post user email and referral code to papaya
      begin
        uri = URI.parse("#{papaya_url}/referrals")
        logger.info("Sending referral info to #{uri}, code: #{@user.referral_code} sender: #{@user.email}")
        Net::HTTP.post_form(uri, {"code" => @user.referral_code, "sender" => @user.email})
      rescue StandardError => e
        logger.info("Error saving user with email, #{email}")
        redirect_to root_path, alert: 'Something went wrong! ' + e.message
      end

      redirect_to '/refer-a-friend'
    else
      logger.info("Error saving user with email, #{email}")
      redirect_to root_path, alert: 'Something went wrong! ' + @user.errors.full_messages.join("\n")
    end
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?

    @user = User.find_by_email(cookies[:h_email])

    respond_to do |format|
      if @user.nil?
        format.html { redirect_to root_path, alert: 'Something went wrong!' }
      else
        @facebook_share_message = generate_facebook_share_message @user.referral_code
        @twitter_share_message = generate_twitter_share_message @user.referral_code

        format.html # refer.html.erb
      end
    end
  end

  def policy
  end

  def redirect
    redirect_to root_path, status: 404
  end

  private

  def referral_link(referral_code)
    "#{social_callback_url}buy?ref=#{CGI::escape(referral_code)}"
  end

  def generate_facebook_share_message(referral_code)
     "Thanks to Habit, Im following a nutrition plan tailor- made for me. Get $25 off at checkout with code #{referral_code} to get yours. Shop here #{referral_link(referral_code)}"
  end

  def generate_twitter_share_message(referral_code)
    "Thanks to Habit, I\'m following a nutrition plan tailor- made for me. Get $25 off at checkout with code #{referral_code} to get yours. Shop here"
  end

  def social_callback_url
    case Rails.env
    when "development"
      "http://lvh.me:3000/"
    when "production"
      Rails.application.config.papya_url
    else
      fail "missing papaya url for #{Rails.env}"
    end
  end

  def skip_first_page
    return if Rails.application.config.ended

    email = cookies[:h_email]
    if email && User.find_by_email(email)
      redirect_to '/refer-a-friend'
    else
      cookies.delete :h_email
    end
  end

  def handle_ip
    # Prevent someone from gaming the site by referring themselves.
    # Presumably, users are doing this from the same device so block
    # their ip after their ip appears three times in the database.

    address = request.env['HTTP_X_FORWARDED_FOR']
    return if address.nil?

    current_ip = IpAddress.find_by_address(address)
    if current_ip.nil?
      current_ip = IpAddress.create(address: address, count: 1)
    elsif current_ip.count > 2
      logger.info('IP address has already appeared three times in our records.
                 Redirecting user back to landing page.')
      return redirect_to root_path
    else
      current_ip.count += 1
      current_ip.save
    end
  end
end
