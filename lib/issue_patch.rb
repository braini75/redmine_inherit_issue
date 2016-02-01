require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a function to recursively find  
# an Attribut from ancestor

module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :deliverable
      
    end

  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods

    def find_ancestor_attribute
      custom_field_id=(Setting.plugin_redmine_inherit_issue['ancestor_attribute']).to_i
      
      # Special case: return "n.a.", if we have a (new) parent or root
      if Setting.plugin_redmine_inherit_issue['ancestor_notset_only'].to_i > 0
          idx= self.available_custom_fields.find_index{ |custom_field| custom_field.id==custom_field_id}
        unless idx.nil?       
            if self.custom_field_values[idx].value.to_s.length > 0
                return "n.a."
            end
        end
      end
      
      unless self.parent.nil?
          idx= self.parent.available_custom_fields.find_index{ |custom_field| custom_field.id==custom_field_id}
          unless idx.nil?
            #
            # HIT! custom_field is found at parent
            # 
              logger.info "Call------------IDX: #{idx} ----------- VAL: #{self.parent.custom_field_values[idx].value} ----laenge: #{self.parent.custom_field_values[idx].value.length}"       
              if self.parent.custom_field_values[idx].value.length > 0
                # return only if not empty
                return self.parent.custom_field_values[idx].value
              end
            end    
            
            # NO Hit: check parent:
            self.parent.find_ancestor_attribute
        else
           # nothing found
           return "n.a."        
      end      

      
    end
  end    
end

# Add module to Issue
Issue.send(:include, IssuePatch)