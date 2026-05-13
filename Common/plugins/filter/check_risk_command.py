
from ansible.plugins.filter.core import FilterModule
from ansible.utils.display import Display
from ansible.errors import AnsibleError

import os, sys, json, datetime, re, textfsm, pathlib, importlib, inspect

display = Display()

class FilterModule(FilterModule):

  def filters(self):
    return {
        'exec_check_risk_command': self.execute_filter
    }

  def execute_filter(self, commands):
    # Check risk commands
    return self.checkRiskCommands(commands)

  #==================================================
  # Check risk commands
  #==================================================
  def checkRiskCommands(self, commands):
    if commands is None or not isinstance(commands, list):
      raise TypeError('Value should be a list')
    
    riskPatterns = []
    riskPatterns.append(r'^\s*(reload|reboot)\s*$')
    riskPatterns.append(r'^\s*(write erease|(erase|delete) startup-config|unconfigure switch all)\s*$')
    riskPatterns.append(r'^\s*(debug \S+|debug all)\s*$')
    
    display.v(f'* riskPatterns = {riskPatterns}')
    
    # Commands
    for cmd_item in commands:
      command = self._getDicValue(cmd_item, 'command', None)
      if not command: continue
      
      display.v(f'* command = {command}')
      
      # check risk patterns
      for pattern in riskPatterns:
      
        match = re.search(pattern, command, re.IGNORECASE|re.MULTILINE)
        if match and match.group():
          risk_cmd = match.group()
          return risk_cmd.strip()
    
    return None

  def _getDicValue(self, dic, column, default_value):
    if column in dic:
      if dic[column] is None:
        return default_value
      else:
        return dic[column]
    else:
      return default_value