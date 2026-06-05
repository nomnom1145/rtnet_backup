import pexpect
import os

src = os.environ.get('src', '')
dest = os.environ.get('dest', '')
remote_host = os.environ.get('host_ip')
remote_user = os.environ.get('user', '')
remote_password = os.environ.get('password', '')
port = os.environ.get('port', '')

# SCP 명령어 실행
command = f'scp -P{port} -o "HostKeyAlgorithms=+ssh-rsa" -o "HostKeyAlgorithms=+ssh-dss" -o "KexAlgorithms=+diffie-hellman-group-exchange-sha1" -o "KexAlgorithms=+diffie-hellman-group1-sha1" -o "KexAlgorithms=+diffie-hellman-group14-sha1" {remote_user}@{remote_host}:{src} {dest}'
try:
    # SCP 명령어 실행 및 expect로 패스워드 입력
    child = pexpect.spawn(command)
    
    # connecting 프롬프트 대기
    index = child.expect(['continue connecting', pexpect.TIMEOUT], timeout=3)

    # # connecting 프롬프트 나올 경우
    # if index == 0:
    #     child.sendline('yes')
    #     index = child.expect(['password:', pexpect.TIMEOUT], timeout=3)
    # # connecting 프롬프트 나오지 않을 경우
    # if index == 1:
    #     child.sendline(remote_password)
    #     index = child.expect(pexpect.EOF, timeout=10)
    # print("파일 전송 완료")

    # 연결 시, "continue connecting" 확인 후 yes 입력
    if index == 0:
        child.sendline('yes')
        # 연결 후 비밀번호 입력 대기
        child.expect('password:')
        child.sendline(remote_password)

    # 비밀번호 입력 대기
    elif index == 1:
        child.sendline(remote_password)
        
    # 전송이 완료되면 EOF 대기
    child.expect(pexpect.EOF, timeout=10)
    
    print("파일 전송 완료")

except pexpect.TIMEOUT:
    print("타임아웃 발생")
except pexpect.ExceptionPexpect as e:
    print("파일 전송 중 오류 발생:", e)


