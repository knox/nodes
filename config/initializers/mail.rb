# Email settings from config.yml
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => APP_CONFIG['mail']['address']
}
ActionMailer::Base.smtp_settings.merge({
  :port => APP_CONFIG['mail']['port']
}) unless APP_CONFIG['mail']['port'].blank?

ActionMailer::Base.smtp_settings.merge({
  :domain => APP_CONFIG['mail']['domain']
}) unless APP_CONFIG['mail']['domain'].blank?

ActionMailer::Base.smtp_settings.merge({
  :authentication => APP_CONFIG['mail']['authentication'],
  :user_name => APP_CONFIG['mail']['user_name'],
  :password => APP_CONFIG['mail']['password']  
}) unless APP_CONFIG['mail']['authentication'].blank?