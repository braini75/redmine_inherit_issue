module InheritIssuesHelper
	def ii_enabled
#		unless Setting.plugin_redmine_inherit_issue['ancestor_attribute'].empty? or Setting.plugin_redmine_inherit_issue['ancestor_attribute'].nil?
		unless Setting.plugin_redmine_inherit_issue['ancestor_attribute'].blank?
			true
		else
			false
		end
	end
	
	def get_custom_field_id
		Setting.plugin_redmine_inherit_issue['ancestor_attribute'].to_i if ii_enabled 
	end
	
	def get_custom_field_name
		CustomField.find(get_custom_field_id).name if ii_enabled
	end
end
