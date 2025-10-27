# -*- coding: gbk -*-  # 

import requests
import json

class DeepSeekReasonerStreamClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://api.deepseek.com/chat/completions"
    
    def stream_chat(self, messages, temperature=0.7):
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        data = {
            "model": "deepseek-reasoner",  # ʹ�� deepseek-reasoner ģ��
            "messages": messages,
            "stream": True,
            "temperature": temperature,
            "deep_thinking": True  # �������˼��ģʽ
        }
        
        full_response = ""
        print("AI: ", end='', flush=True)
        
        try:
            with requests.post(self.base_url, headers=headers, json=data, stream=True) as response:
                if response.status_code != 200:
                    print(f"\nAPI ����: {response.status_code} - {response.text}")
                    return full_response
                
                for line in response.iter_lines():
                    if line:
                        try:
                            # ������ܵĽ������
                            decoded_line = line.decode('utf-8')
                            
                            if decoded_line.startswith('data: '):
                                data_str = decoded_line[6:]
                                if data_str.strip() == '[DONE]':
                                    break
                                
                                try:
                                    data_obj = json.loads(data_str)
                                    choice = data_obj.get('choices', [{}])[0]
                                    delta = choice.get('delta', {})
                                    
                                    # �ؼ��޸������� content Ϊ None �����
                                    content = delta.get('content')
                                    if content is not None:  # ȷ�� content ���� None
                                        print(content, end='', flush=True)
                                        full_response += content
                                    
                                except json.JSONDecodeError as e:
                                    print(f"\nJSON ��������: {e}")
                                    continue
                        except UnicodeDecodeError:
                            # ���Է��ı�����
                            continue
        except requests.exceptions.RequestException as e:
            print(f"\n�����쳣: {e}")
        
        return full_response

# ʹ��ʾ��
if __name__ == "__main__":
    # �滻Ϊ���� API ��Կ
    client = DeepSeekReasonerStreamClient("sk-f184e296fd3a485181874f0613fd5d44")
    
    messages = [
        {"role": "user", "content": "����ϸ�������Ӽ���Ļ���ԭ����Ӧ��ǰ��"}
    ]
    
    print("���ڻ�ȡ�ش�...")
    response = client.stream_chat(messages)
    print("\n\n�����ش�:", response)