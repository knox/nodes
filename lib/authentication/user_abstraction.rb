module Authentication
  module UserAbstraction

    # Stuff directives into including module
    def self.included( recipient )
      recipient.extend( ModelClassMethods )
      recipient.class_eval do
        include ModelInstanceMethods
				        
  				validates_presence_of     :login
  				validates_length_of       :login,    :within => 3..40
  				validates_uniqueness_of   :login
  				validates_format_of       :login,    :with => /\A[\w\-\ @]*\z/, 
																							 :message => Authentication.bad_login_message,
                                               :allow_blank => true

  				validates_format_of       :name,     :with => Authentication.name_regex,  
																							 :message => Authentication.bad_name_message, 
																							 :allow_blank => true
  				validates_length_of       :name,     :maximum => 100, :allow_blank => true

  				validates_presence_of     :email
  				validates_length_of       :email,    :within => 6..100, :allow_blank => true #r@a.wk
  				validates_uniqueness_of   :email
  				validates_format_of       :email,    :with => Authentication.email_regex, 
																							 :message => Authentication.bad_email_message,
                                               :allow_blank => true

				  before_create :make_activation_code
 
					has_and_belongs_to_many :roles

      end
    end # #included directives
    #
    # Class Methods
    #
    module ModelClassMethods

			def send_new_activation_code(email = nil, &block) #yield error, message, path
				u = find :first, :conditions => ['email = ?', email]
				case 
				when (email.blank? || u.nil?)
					yield :error, "Could not find a user with that email address.", "resend_activation_path"
				when (u.send(:make_activation_code) && u.save(false))
					@lost_activation = true
					yield :notice, "A new activation code has been sent to your email address.", "root_path"
				else
					yield :error, "There was a problem resending your activation code, please try again or %s.", 							"resend_activation_path"
				end
			end

			def find_with_activation_code(activation_code = nil, &block) #yield error, message, path
				u = find :first, :conditions => ['activation_code = ?', activation_code]				
				case
				when activation_code.nil?
					yield :error, "The activation code was missing, please follow the URL from your email.", "root_path"
				when u.nil?
					yield :error, "We couldn't find a user with that activation code, please check your email and try 						again, or %s.", "root_path"
				when u.active?
					yield :notice, "Your account has already been activated. You can log in below", "login_path"
				when u
					u.activate!
					path = ((u.user_type == "OpenidUser") ? "login_with_openid_path" : "login_path")
					yield :notice, "Signup complete! Please sign in to continue.", path
				end
			end

      # Password authentication method
      # yield user, message, item_msg, item_path
      def authenticate(login, password, &block)
        yield nil, "Username and password cannot be blank.", nil, nil and
          return if (login.blank? || password.blank?)
        u = find :first, :conditions => ['login = ?', login], :include => :roles
        yield nil, "Could not log you in as '#{CGI.escapeHTML(login)}', your username or password is incorrect.", nil, 
          nil and return unless (u && u.authenticated?(password))
        case
        when !u.active?
          yield nil, "Your account has not been activated, please check your email or %s.", "request a new activation code", "resend_activation_path"
        when !u.enabled?
          yield nil, "Your account has been disabled, please %s.", "contact the administrator", "login_path"
        else
          yield u, nil, nil, nil
        end
      end
    
      # Password reset method
      # yield error, message, path, failure
      def find_and_reset_password(password, password_confirmation, reset_code, &block) 
        u = find :first, :conditions => ['password_reset_code = ?', reset_code]
        case 
        when (reset_code.blank? || u.nil?)
          yield :error, "Invalid password reset code, please check your email and try again.", "root_path", true
        when (password.blank? || (password != password_confirmation))
          yield :error, "Password and password confirmation did not match.", nil, false
        else
          u.password = password
          u.password_confirmation = password_confirmation
          if !u.valid?
            yield :error, "Password #{u.errors.on(:password)}", nil, false
          elsif u.save
            u.reset_password!
            yield :notice, "Password reset.", "login_path", false
          else
            yield :error, "There was a problem resetting your password.", "root_path", false
          end       
        end         
      end
    
      # Password reset method
      def find_for_forget(email)
        u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
        return false if (email.blank? || u.nil?)
        (u.forgot_password && u.save(false)) ? true : false
      end

    end # class methods

    #
    # Instance Methods
    #
    module ModelInstanceMethods

  		def login=(value)
    		write_attribute :login, (value ? value.downcase : nil)
  		end

  		def email=(value)
    		write_attribute :email, (value ? value.downcase : nil)
  		end

      def to_param
        login
      end

		  def has_role?(role_in_question)
		    @_list ||= self.roles.collect(&:name)
				#Users with role "admin" can access any role protected resource
				#Comment the next line to disable this feature
		    #return true if @_list.include?("admin")
		    (@_list.include?(role_in_question.to_s) )
		  end

			def change_password!(old_password, new_password, new_confirmation)
				errors.add_to_base("New password does not match the password confirmation.") and
					return false if (new_password != new_confirmation)
				errors.add_to_base("New password cannot be blank.") and
					return false if new_password.blank? 
				errors.add_to_base("You password was not changed, your old password is incorrect.") and
					return false unless self.authenticated?(old_password) 
        self.password, self.password_confirmation = new_password, new_confirmation
				save(false)
			end

		  # Activates the user in the database.
		  def activate!
		    @activated = true
		    self.activated_at = Time.now.utc
				#Leave activation code in place to determine if already activated.
		    #self.activation_code = nil
		    save(false)
		  end

		  def recently_activated?
		    @activated
		  end

		  def active?
				# If the activated_at date has not been set the user is not active
		    !activated_at.blank?
		  end

		  def forgot_password
		    self.make_password_reset_code
		    @forgotten_password = true
		  end

		  def reset_password!
		    # First update the password_reset_code before setting the
		    # reset_password flag to avoid duplicate email notifications.
		    update_attribute(:password_reset_code, nil)
		    @reset_password = true
		  end

		  #used in user_observer
		  def recently_forgot_password?
		    @forgotten_password
		  end

			def lost_activation_code?
				@lost_activation
			end

		  def recently_reset_password?
		    @reset_password
		  end

		  def recently_created?
		    @created
		  end

		  protected
		    
		  def make_activation_code
        if !active?  
		      self.activation_code = self.class.make_token
				  @created = true
        end
		  end

		  def make_password_reset_code
		    self.password_reset_code = self.class.make_token
		  end

			private

    end # instance methods

  end
end
