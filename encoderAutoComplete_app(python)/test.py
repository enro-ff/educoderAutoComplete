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
            "model": "deepseek-reasoner",  # 使用 deepseek-reasoner 模型
            "messages": messages,
            "stream": True,
            "temperature": temperature,
            "deep_thinking": True  # 启用深度思考模式
        }
        
        full_response = ""
        print("AI: ", end='', flush=True)
        
        try:
            with requests.post(self.base_url, headers=headers, json=data, stream=True) as response:
                if response.status_code != 200:
                    print(f"\nAPI 错误: {response.status_code} - {response.text}")
                    return full_response
                
                for line in response.iter_lines():
                    if line:
                        try:
                            # 处理可能的解码错误
                            decoded_line = line.decode('utf-8')
                            
                            if decoded_line.startswith('data: '):
                                data_str = decoded_line[6:]
                                if data_str.strip() == '[DONE]':
                                    break
                                
                                try:
                                    data_obj = json.loads(data_str)
                                    choice = data_obj.get('choices', [{}])[0]
                                    delta = choice.get('delta', {})
                                    
                                    # 关键修复：处理 content 为 None 的情况
                                    content = delta.get('content')
                                    if content is not None:  # 确保 content 不是 None
                                        print(content, end='', flush=True)
                                        full_response += content
                                    
                                except json.JSONDecodeError as e:
                                    print(f"\nJSON 解析错误: {e}")
                                    continue
                        except UnicodeDecodeError:
                            # 忽略非文本数据
                            continue
        except requests.exceptions.RequestException as e:
            print(f"\n请求异常: {e}")
        
        return full_response

# 使用示例
if __name__ == "__main__":
    # 替换为您的 API 密钥
    client = DeepSeekReasonerStreamClient("sk-f184e296fd3a485181874f0613fd5d44")
    
    messages = [
        {"role": "user", "content": "请详细解释量子计算的基本原理及其应用前景"}
    ]
    
    print("正在获取回答...")
    response = client.stream_chat(messages)
    print("\n\n完整回答:", response)