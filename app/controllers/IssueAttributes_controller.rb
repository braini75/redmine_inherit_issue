class IssueAttributesController < ApplicationController
  unloadable
  
  
  def get_first_ancestor_with_attribute(issue,custom_field_id)                      
          if custom_field_id.nil?
            custom_field_id=(Setting.plugin_redmine_inherit_issue['ancestor_attribute']).to_i
          end
          
          logger.info "Try to find ancestor from: #{issue}"
          
          unless issue.parent.nil?
            idx= issue.parent.editable_custom_fields.find_index{ |custom_field| custom_field.id==custom_field_id}
  
            if Setting.plugin_redmine_inherit_issue['ancestor_notset_only']
              if issue.custom_field_values[idx].value.length > 0
                return "n.a."
              end
            end
  
            logger.info "Call------------IDX: #{idx} ----------- VAL: #{issue.parent.custom_field_values[idx].value} ----laenge: #{issue.parent.custom_field_values[idx].value.length}"
      
            if issue.parent.custom_field_values[idx].value.length > 0
              # return first occurence of the attribute
              return issue.parent.custom_field_values[idx].value
            else
              get_first_ancestor_with_attribute(issue.parent,custom_field_id)          
            end 
      
          else
            # nothing found
            return "n.a."             
          end          
   end

end
