module RedmineInheritIssue
	module IssuePatch
		def self.apply
			Issue.class_eval do
				if RUBY_VERSION >= "2.0"
					prepend InstanceMethods
				else
					Issue.send(:include, IssuePatch)
				end
			end unless Issue < InstanceMethods			
		end
		
		# for compatiblity reasons (ruby < 2.0 does not support prepend)
		def self.included(base)
			base.send(:include, InstanceMethods) 
		end
		
		module InstanceMethods
			def find_ancestor_attribute
			  custom_field_id=get_custom_field_id
			  
			  # Special case: return "", if we have a (new) parent or root
			  if Setting.plugin_redmine_inherit_issue['root_hide'].to_i > 0
				idx= self.available_custom_fields.find_index{ |custom_field| custom_field.id==custom_field_id}
				unless idx.nil?       
					if self.custom_field_values[idx].value.to_s.length > 0
						return ""
					end
				end
			  end
			  
			  unless self.parent.nil?
				idx= self.parent.available_custom_fields.find_index{ |custom_field| custom_field.id==custom_field_id}
				unless idx.nil?
					#
					# HIT! custom_field is found at parent
					# 
					logger.info "Call: FindAncestorAttribute - IssueID: #{self.parent} - IDX: #{idx} - VAL: #{self.parent.custom_field_values[idx].value}"       
					if self.parent.custom_field_values[idx].value.to_s.length > 0
						# return only if not empty
						return self.parent.custom_field_values[idx].value
					end
				end    
					
				# NO Hit: check parent instead:
				self.parent.find_ancestor_attribute
			  else
				   # nothing found
				   return ""        
			  end			
			end
			
		end
	
	end
end