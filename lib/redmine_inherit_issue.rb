module RedmineInheritIssue

	
	def	self.setup
		IssuePatch.apply
	end
	
	module IssueAttributes
	 
		class Hooks < Redmine::Hook::ViewListener    
			# Hooks for the Redmine-Plugin redmine_inherit_issue
			# 
			# Author:: Thomas Koch
		
			# This class holds all hooks for redmine_inherit_issue     

			def view_issues_show_details_bottom(context={})         
			  context[:controller].send(:render_to_string, {
				:partial => 'hooks/view_issues_show_details_bottom',
				:locals => context
			  })
			end        
			

		end  
	end
end
