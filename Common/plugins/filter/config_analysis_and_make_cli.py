from ansible.plugins.filter.core import FilterModule
from ansible.utils.display import Display
from ansible.errors import AnsibleError

import re

display = Display()

class FilterModule(FilterModule):
    def filters(self):
        return {
            'config_analysis_and_make_cli': self.config_analysis_and_make_cli
        }
    
    def config_analysis_and_make_cli(self, data):
        try:
            analysis_type = data.get("analysis_item").get("type")
            analysis_when_exist = data.get("analysis_item").get("when_exist")
            analysis_when_not_exist = data.get("analysis_item").get("when_not_exist")
            analysis_name = data.get("analysis_item").get("name")
            excute_command = data.get("analysis_item").get("exec_commands")
            config_extract_result = data.get("config_extract_result")
            network_os = data.get("fap_vars").get("network_os")

            result = dict (
                is_success = True,
                err_msg = None,
                analysis_type = analysis_type,
                analysis_when_exist = analysis_when_exist,
                analysis_when_not_exist = analysis_when_not_exist,
                excute_command = excute_command,
                excute_flag = False
            )

            if not analysis_type or (analysis_when_exist == None and analysis_when_exist == None):
                raise Exception("변수 정의확인필요")
            
            analsys_func_result = globals()[f"_{network_os}_{analysis_type}"](
                result,
                analysis_type,
                analysis_when_exist,
                analysis_when_not_exist,
                analysis_name,
                excute_command,
                config_extract_result
            )

            result.update(analsys_func_result)

            return result
        
        except Exception as e:
            result.update(dict(
                err_msg = str(e)
            ))
            return result 

def _cisco_ios_ospf(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 
        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, ospfs = [], [], []

        for ospf_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(ospf_info) 
                if result1:
                    matched_result1.append(result1)
                    ospfs.append(ospf_info.split('\n')[0])

            if analysis_when_not_exist:
                result2 = pattern2.findall(ospf_info) 
                if not result2:
                    matched_result2.append(result2)
                    ospfs.append(ospf_info.split('\n')[0])

        if ospfs:
            ospfs = sorted(list(set(ospfs)))
            ospfs = [ospf + "\n" + excute_command[0].get("command") + "exit\n" for ospf in ospfs]
            ospfs = {"command": "configure terminal\n" + '\n'.join(ospfs) + "end\n"}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [ospfs]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _hp_comware_ospf(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 
        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, ospfs = [], [], []

        for ospf_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(ospf_info) 
                if result1:
                    matched_result1.append(result1)
                    ospfs.append(ospf_info.split('\n')[0])

            if analysis_when_not_exist:
                result2 = pattern2.findall(ospf_info) 
                if not result2:
                    matched_result2.append(result2)
                    ospfs.append(ospf_info.split('\n')[0])

        if ospfs:
            ospfs = sorted(list(set(ospfs)))
            ospfs = [ospf + "\n" + excute_command[0].get("command") + "quit\n" for ospf in ospfs]
            ospfs = {"command": "system-view\n" + '\n'.join(ospfs) + "return\n"}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [ospfs]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result





def _cisco_ios_vty(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 

        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, vtys = [], [], []
        
        for vty_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(vty_info) 
                if result1:
                    matched_result1.append(result1)
                    vtys.append(vty_info.split('\n')[0])


            if analysis_when_not_exist:
                result2 = pattern2.findall(vty_info) 
                if not result2:
                    matched_result2.append(result2)
                    vtys.append(vty_info.split('\n')[0])

        if vtys:
            vtys = sorted(list(set(vtys)))
            vtys = [vty + "\n" + excute_command[0].get("command") + "exit\n" for vty in vtys]
            vtys = {"command": "configure terminal\n" + '\n'.join(vtys) + "end\n"}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [vtys]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _hp_comware_vty(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 

        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, vtys = [], [], []
        
        for vty_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(vty_info) 
                if result1:
                    matched_result1.append(result1)
                    vtys.append(vty_info.split('\n')[0])


            if analysis_when_not_exist:
                result2 = pattern2.findall(vty_info) 
                if not result2:
                    matched_result2.append(result2)
                    vtys.append(vty_info.split('\n')[0])

        if vtys:
            vtys = sorted(list(set(vtys)))
            vtys = [vty + "\n" + excute_command[0].get("command") + "quit\n" for vty in vtys]
            vtys = {"command": "system-view\n" + '\n'.join(vtys) + "return\n"}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [vtys]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _cisco_ios_interface(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 

        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, interfaces = [], [], []
        
        for interface_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(interface_info) 
                if result1:
                    matched_result1.append(result1)
                    interfaces.append(interface_info.split('\n')[0])


            if analysis_when_not_exist:
                result2 = pattern2.findall(interface_info) 
                if not result2:
                    matched_result2.append(result2)
                    interfaces.append(interface_info.split('\n')[0])

        if interfaces:
            interfaces = sorted(list(set(interfaces)))
            interfaces = [interface + "\n" + excute_command[0].get("command") + "exit\n" for interface in interfaces]
            interfaces = {"command": "configure terminal\n" + '\n'.join(interfaces) + "end\n", "is_save": True}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [interfaces]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _hp_comware_interface(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):
    if isinstance(config_extract_result, list): 

        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)
        matched_result1, matched_result2, interfaces = [], [], []
        
        for interface_info in config_extract_result:
            if analysis_when_exist:
                result1 = pattern1.findall(interface_info) 
                if result1:
                    matched_result1.append(result1)
                    interfaces.append(interface_info.split('\n')[0])


            if analysis_when_not_exist:
                result2 = pattern2.findall(interface_info) 
                if not result2:
                    matched_result2.append(result2)
                    interfaces.append(interface_info.split('\n')[0])

        if interfaces:
            interfaces = sorted(list(set(interfaces)))
            interfaces = [interface + "\n" + excute_command[0].get("command") + "quit\n" for interface in interfaces]
            interfaces = {"command": "system-view\n" + '\n'.join(interfaces) + "return\n"}
            result.update(dict(
                excute_flag = True
            ))
        
        result.update(dict(
            matched_result1 = matched_result1,
            matched_result2 = matched_result2,
            excute_command = [interfaces]
        ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _cisco_ios_global(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):

    if isinstance(config_extract_result, list): 

        excute_flag = []
        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)                
       
        if analysis_when_exist:
            result1 = pattern1.findall(config_extract_result[0]) 
            result.update(dict(
                matched_result1 = result1
            ))
            if result1: excute_flag = True

        if analysis_when_exist:
            result2 = pattern2.findall(config_extract_result[0]) 
            result.update(dict(
                matched_result2 = result2
            ))
            if not result2: excute_flag = True

        if excute_flag:
            excute_command.insert(0,{'command': 'configure terminal'})
            excute_command.insert(len(excute_command),{'command': 'end'})
            result.update(dict(
                excute_flag = True,
                excute_command = excute_command
            ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result

def _hp_comware_global(result, analysis_type, analysis_when_exist, analysis_when_not_exist, analysis_name, excute_command, config_extract_result):

    if isinstance(config_extract_result, list): 

        excute_flag = []
        pattern1 = re.compile(rf"{analysis_when_exist}", re.MULTILINE)
        pattern2 = re.compile(rf"{analysis_when_not_exist}", re.MULTILINE)                
       
        if analysis_when_exist:
            result1 = pattern1.findall(config_extract_result[0]) 
            result.update(dict(
                matched_result1 = result1
            ))
            if result1: excute_flag = True
        if analysis_when_exist:
            result2 = pattern2.findall(config_extract_result[0]) 
            result.update(dict(
                matched_result2 = result2
            ))
            if not result2: excute_flag = True

        if excute_flag:
            excute_command.insert(0,{'command': 'configure terminal'})
            excute_command.insert(len(excute_command),{'command': 'end'})
            result.update(dict(
                excute_flag = True,
                excute_command = excute_command
            ))
    else:
        return result.update(dict(
            is_success = False,
            err_msg = '추출한 컨피그 데이터에 문제가 있습니다.'
        ))
    
    return result