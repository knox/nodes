# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25,
  :domain => "db.hannover.freifunk.net",
  :authentication => :none #,
  #:user_name => "",
  #:password => ""  
}