from ansible.plugins.vars import BaseVarsPlugin
from ansible.utils.display import Display
from ansible.errors import AnsibleError

import os, time
import requests
import configparser
import warnings
from urllib3.exceptions import InsecureRequestWarning

# Suppress only urllib3 InsecureRequestWarning
warnings.simplefilter("ignore", InsecureRequestWarning)

display = Display()

class VarsModule(BaseVarsPlugin):

  _cache_data = None
  _cache_timestamp = None
  _cache_ttl = 300

  def get_vars(self, loader, path, entities, cache=True):
    variables = {}
    
    current_time = time.time()
    
    if VarsModule._cache_data is None:
      self._fetch_api_data()
    elif VarsModule._cache_timestamp is None:
      self._fetch_api_data()
    elif current_time - VarsModule._cache_timestamp > VarsModule._cache_ttl:
      self._fetch_api_data()
    

    # Check exist _cache_data
    if VarsModule._cache_data is None:
      return variables

    # Loop entities
    for entity in entities:
    
      # Check host only
      if entity.__class__.__name__ != 'Host':
        continue
      
      host_ip = entity.vars.get('ansible_host', entity.name)
      
      # From cache data
      host_custom_vars = None
      if host_ip in VarsModule._cache_data:
        host_custom_vars = VarsModule._cache_data[host_ip]

      # copy host_vars
      host_vars = entity.vars.copy()
      
      # Append custom_vars
      if host_custom_vars and 'fap' in host_vars:
        host_vars['fap']['custom_vars'] = host_custom_vars
        variables[entity.name] = host_vars
        
    return variables

    
  # Fetch custom_vars API data
  def _fetch_api_data(self):
    
    iniPath = '/fap/ansible/conf/fap.conf'
  
    # Check the config file exists.
    if os.path.isfile(iniPath) == False:
      raise AnsibleError(f'Not found config file. {iniPath}')

    # Config parser
    config = configparser.ConfigParser()
    config.read(iniPath)
    
    # API
    api_url = config.get('API_SERVER', 'API_URL')
    api_token = config.get('API_SERVER', 'API_TOKEN')
    
    headers = {'Cache-Control':'no-cache', 'x-auth-token':'Bearer '+api_token}
    
    api_url = api_url + f'/api/host/custom_vars'
        
    display.v(f'Query vars_plugin API: {api_url}')

    try:
      # Suppress InsecureRequestWarning only for this request
      with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        try:
          from urllib3.exceptions import InsecureRequestWarning
          warnings.simplefilter("ignore", InsecureRequestWarning)
        except Exception:
          pass
        
        response = requests.get(api_url, headers=headers, verify=False)
        response.raise_for_status()
      
      # JSON
      jsonData = response.json()
      #display.vv(f"Data fetched: {jsonData}")
      
      custom_vars = {}
      if jsonData and 'data' in jsonData:
        custom_vars = jsonData['data']
      
      VarsModule._cache_data = custom_vars
      VarsModule._cache_timestamp = time.time()
      
      #if VarsModule._cache_data:
      #  display.vv(f"Data fetched: {VarsModule._cache_data}")
      
    except requests.exceptions.RequestException as e:
      display.error(f"Failed to fetch data for: {str(e)}")
      raise AnsibleError(f"Failed to fetch data from API: {str(e)}")