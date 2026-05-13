
from ansible.plugins.filter.core import FilterModule
from ansible.utils.display import Display
from ansible.errors import AnsibleError
from ntc_templates.parse import parse_output

import os, sys, time, json, datetime, copy, re, textfsm, pathlib, importlib, inspect

display = Display()

class FilterModule(FilterModule):

  _defaultRulePath = '/fap/ansible/scripts/network/modules/fap_templates/'
  #display.v(f"* rulePath = {_rulePath}")
  
  def filters(self):
    return {
        'fap_textfsm': self.execute
    }

  def execute(self, data):
    # Check data
    if data is None or not isinstance(data, dict):
      raise TypeError('Value should be a dictionay')
    
    # Check parameters
    if "fap_vars" not in data:
      raise TypeError('fap_vars must be included')
    if "os_type" not in data:
      raise TypeError('os_type must be included')
    if "command" not in data:
      raise TypeError('command must be included')
    if "config_data" not in data:
      raise TypeError('config_data must be included')
    
    rulePath = data.get('rulePath')
    fap_vars = data.get('fap_vars')
    os_type = data.get('os_type')
    command = data.get('command')
    config_data = data.get('config_data')

    if not rulePath:
      rulePath = self._defaultRulePath;
    
    # ntc templates rule path
    os.environ["NTC_TEMPLATES_DIR"] = rulePath
    
    # Execute textfsm
    _output = parse_output(platform=os_type, command=command, data=config_data)
    
    # Make result data
    resultData = {}
    resultData['job_id'] = fap_vars['job_id']
    resultData['host_id'] = fap_vars['host_id']
    resultData['host_ip'] = fap_vars['host_ip']
    resultData['data_list'] = _output
    
    return resultData