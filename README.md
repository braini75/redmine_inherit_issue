[![Build Status](https://travis-ci.org/braini75/redmine_inherit_issue.svg?branch=master)] (https://travis-ci.org/braini75/redmine_inherit_issue)
#Redmine Plugin: Inherit value from ancestors customfield 
__Requirements__:
Redmine 2.x, 3.x



__Description__:
This Plugin allows to specify a custom_field (see Configuration) and search the first occurrence found, while walking through the genealogical tree of that issue. That value, if found, will be appended as an additional field to the Custom Fields section for each Issue. 

__Installation__:
* go to `{REDMINE_ROOT}/plugin` directory.
* Install:
```bash  
git clone https://github.com/braini75/redmine_inherit_issue.git
```
  
* Restart the redmine service. E.g. `service apache2 restart`
* enjoy!
(There is no need for database migration, as this plugin does not change anything in the database.)

__Usage__:
* Select an issue.
* find an extra Entry (custom_field name + "(inherited)") at the very bottom of the custom fields section
* Select the custom field used with the plugin (Global settings)

__ChangeLog__:  
[1.2] Issue list will show inherit custom_field  
[1.1] Initial Checking  
