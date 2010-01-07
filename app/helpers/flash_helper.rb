# found on http://rubypond.com/articles/2008/07/11/useful-flash-messages-in-rails/
# added some fancy effects
module FlashHelper

  FLASH_NOTICE_KEYS = [:error, :notice, :warning, :success]

  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|      
      content_tag :div, :id => 'flash', :class => type.to_s do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    formatted_messages << javascript_tag('flashEffect()', :defer => 'defer') if formatted_messages.size > 0
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end
  
end