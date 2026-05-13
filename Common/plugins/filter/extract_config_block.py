from ansible.plugins.filter.core import FilterModule
from ansible.errors import AnsibleError

import re

class FilterModule(FilterModule):

  def filters(self):
    return {
        'extract_config_block': self.execute_config_block
    }
  
  def execute_config_block(self, config, startPattern, exclude=None, include=None):
    
    pattern = rf'[\r\n]({startPattern}[\s\S]+?)(?=\n\S|\Z)'

    find_list = []

    for find in re.findall(pattern, '\n'+config):
      if exclude and re.findall(rf'{exclude}', find):
        continue
      if include and not re.findall(rf'{include}', find):
        continue
      
      find_list.append(find)
    
    return find_list