import asyncio
import websockets
import logging
import json
from openai import OpenAI
import pyautogui
import time
import ctypes
from ctypes import wintypes
import os

class InputMethodSwitcher:
    def __init__(self):
        self.user32 = ctypes.WinDLL('user32')
        self.WM_INPUTLANGCHANGEREQUEST = 0x0050
        
    def get_current_input_method(self):
        """获取当前输入法"""
        hwnd = self.user32.GetForegroundWindow()
        thread_id = self.user32.GetWindowThreadProcessId(hwnd, None)
        hkl = self.user32.GetKeyboardLayout(thread_id)
        return hkl
    
    def list_available_input_methods(self):
        """列出所有可用的输入法"""
        layout_count = self.user32.GetKeyboardLayoutList(0, None)
        layout_list = (wintypes.HANDLE * layout_count)()
        self.user32.GetKeyboardLayoutList(layout_count, layout_list)
        
        input_methods = []
        for layout in layout_list:
            lang_id = layout & 0xFFFF
            input_methods.append({
                'handle': layout,
                'lang_id': lang_id,
                'is_english': lang_id == 0x0409
            })
        return input_methods
    
    def switch_to_english(self):
        """切换到英文输入法"""
        input_methods = self.list_available_input_methods()
        english_methods = [im for im in input_methods if im['is_english']]
        
        if not english_methods:
            return False
        
        # 使用第一个找到的英文输入法
        english_layout = english_methods[0]['handle']
        hwnd = self.user32.GetForegroundWindow()
        
        # 激活输入法
        result = self.user32.ActivateKeyboardLayout(english_layout, 0)
        return result != 0


# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
#DeepSeek API 配置
#替换为实际API密钥
DEEPSEEK_API_KEY = "sk-f184e296fd3a485181874f0613fd5d44"

if(os.path.exists("cache.txt")):
    with open("cache.txt", "r", encoding="utf-8") as f:
        caches = f.read()
        DEEPSEEK_API_KEY = caches.strip()
else:
    DEEPSEEK_API_KEY = input("请输入你的DeepSeek API Key: ").strip()
    with open("cache.txt", "w", encoding="utf-8") as f:
        f.write(DEEPSEEK_API_KEY)


DEEPSEEK_BASE_URL = "https://api.deepseek.com/v1"

class EducoderAssistant:
    def __init__(self):
        self.client = OpenAI(
            api_key=DEEPSEEK_API_KEY,
            base_url=DEEPSEEK_BASE_URL
        )
        self.last_question = None
        
    async def get_code_solution(self, question_text):
        """
        使用DeepSeek API获取代码解决方案
        """
        try:
            logger.info("向DeepSeek发送请求获取代码解决方案...")
            
            # 构建提示词，要求只返回代码
            prompt = f"""
请根据以下编程题目要求，只提供完整的代码解决方案，不要包含任何解释、注释或其他文本。

题目内容：
{question_text}

要求：
1. 代码应完整且可运行,包含头文件,主函数必须int main()形式
2. 只返回代码，不要有任何额外的文字说明
3. 使用标准库和常见的编程实践
4. 所有的代码都是C语言



请直接返回代码：
"""
            
            response = self.client.chat.completions.create(
                model="deepseek-coder",
                messages=[
                    {
                        "role": "system", 
                        "content": "你是一个专业的编程助手，只返回代码，不包含任何解释或注释。"
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                max_tokens=2000,
                temperature=0.3,
                stream=False
            )
            
            code_solution = response.choices[0].message.content.strip()
            logger.info(f"成功获取代码解决方案，长度: {len(code_solution)} 字符")
            
            # 清理响应，确保只包含代码
            code_solution = self.clean_code_response(code_solution)
            
            return code_solution
            
        except Exception as e:
            logger.error(f"获取DeepSeek响应失败: {e}")
            return None
    
    def clean_code_response(self, response):
        """
        清理API响应，确保只包含代码
        """
        # 移除可能存在的代码块标记
        lines = response.split('\n')
        cleaned_lines = []
        
        in_code_block = False
        for line in lines:
            # 跳过代码块开始标记
            if line.strip().startswith('```'):
                in_code_block = not in_code_block
                continue
            
            # 如果在代码块中或者是普通代码行，则保留
            if in_code_block or (line.strip() and not line.strip().startswith('//') and not line.strip().startswith('#')):
                cleaned_lines.append(line)
        
        cleaned_response = '\n'.join(cleaned_lines).strip()
        
        # 如果清理后为空，返回原始响应
        return cleaned_response if cleaned_response else response
    
    def simulate_typing(self, text, typing_speed=0.1, enter_delay=1.0):
        """
        模拟键盘输入文本
        """
        left_kuohao = text.count('{')
        try:
            logger.info(f"开始模拟键盘输入，文本长度: {len(text)} 字符")
            
            # 确保焦点在输入区域（可能需要根据实际情况调整延迟）
            time.sleep(2)
            time.sleep(0.1)
            pyautogui.hotkey('ctrl', 'a')
            time.sleep(0.1)
            pyautogui.hotkey('delete')
            time.sleep(0.5)
            #切换至英文输入法
            switcher = InputMethodSwitcher()

            # 获取当前输入法
            current = switcher.get_current_input_method()
            print(f"当前输入法: {hex(current)}")

            # 列出所有输入法
            methods = switcher.list_available_input_methods()
            for method in methods:
               status = "英文" if method['is_english'] else "其他"
               print(f"输入法: {hex(method['handle'])} - {status}")

            # 切换到英文
            if switcher.switch_to_english():
                print("成功切换到英文输入法")
            else:
              print("切换英文输入法失败")

            # 分段输入，避免一次性输入过长文本
            lines = text.split('\n')
            for i, line in enumerate(lines):
                if line.strip():  # 跳过空行
                    # 输入当前行
                    pyautogui.write(line, interval=typing_speed)
                
                # 如果不是最后一行，按回车
                if i < len(lines) - 1:
                    time.sleep(0.1)
                    pyautogui.press('enter')
                    time.sleep(0.05)
                
            time.sleep(0.1)
            pyautogui.hotkey('alt', 'shift', 'f')
            pyautogui.keyDown('down')
            time.sleep(1)
            pyautogui.keyUp('down')

            pyautogui.press('down',presses=left_kuohao)
            for i in range(left_kuohao):
                time.sleep(0.1)
                pyautogui.press('backspace')
                time.sleep(0.1)
                pyautogui.press('backspace')
            logger.info("键盘输入完成")
            return True
            
        except Exception as e:
            logger.error(f"模拟键盘输入失败: {e}")
            return False

async def server(websocket):
    """
    WebSocket服务器处理函数
    """
    logger.info(f"客户端连接: {websocket.remote_address}")
    assistant = EducoderAssistant()
    
    try:
        await websocket.send("欢迎使用Educoder助手服务")
        
        async for message in websocket:
            try:
                if isinstance(message, str):
                    # 解析JSON消息
                    try:
                        data = json.loads(message)
                        
                        if data.get('type') == 'educoder_content':
                            logger.info("收到Educoder题目内容")
                            
                            # 提取题目文本
                            question_text = data.get('content', {}).get('text', '')
                            if question_text:
                                logger.info(f"题目内容长度: {len(question_text)} 字符")
                                
                                # 发送确认消息
                                await websocket.send("已收到题目内容，正在向DeepSeek请求代码解决方案...")
                                
                                # 获取代码解决方案
                                code_solution = await assistant.get_code_solution(question_text)
                                
                                if code_solution:
                                    # 发送代码到客户端
                                    response_data = {
                                        "type": "code_solution",
                                        "code": code_solution,
                                        "timestamp": time.time()
                                    }
                                    await websocket.send(json.dumps(response_data, ensure_ascii=False))
                                    
                                    # 询问是否要自动输入
                                    await websocket.send("代码已生成，是否要自动输入到网页？(3秒后开始自动输入)")
                                    
                                    # 等待3秒后自动输入
                                    await asyncio.sleep(3)
                                    
                                    # 模拟键盘输入
                                    input_success = assistant.simulate_typing(code_solution)
                                    
                                    if input_success:
                                        await websocket.send("✅ 代码已自动输入到网页")
                                    else:
                                        await websocket.send("❌ 自动输入失败，请手动复制代码")
                                    
                                else:
                                    await websocket.send("❌ 无法获取代码解决方案，请重试")
                                    
                            else:
                                await websocket.send("❌ 未找到有效的题目内容")
                                
                        else:
                            # 普通文本消息
                            logger.info(f"收到文本: {message}")
                            await websocket.send(f"服务器回复: {message}")
                            
                    except json.JSONDecodeError:
                        # 非JSON文本消息
                        logger.info(f"收到文本: {message}")
                        await websocket.send(f"服务器回复: {message}")
                
                elif isinstance(message, bytes):
                    # 二进制消息处理
                    logger.info(f"收到二进制数据: {message.hex()}")
                    await websocket.send(message[::-1])
                    
            except Exception as e:
                logger.error(f"处理消息时出错: {e}")
                await websocket.send(f"错误: {str(e)}")
    
    except websockets.ConnectionClosed:
        logger.info("客户端断开连接")
    except Exception as e:
        logger.error(f"服务器错误: {e}")
    finally:
        logger.info("连接关闭")

async def main():
    """
    主函数，启动WebSocket服务器
    """
    server_config = websockets.serve(
        server,
        "localhost",
        8000,
        ping_interval=20,
        ping_timeout=10,
        close_timeout=10
    )
    
    async with server_config:
        logger.info("🎯 Educoder助手服务器启动在 localhost:8000")
        logger.info("📝 服务功能:")
        logger.info("  - 接收Educoder题目内容")
        logger.info("  - 使用DeepSeek生成代码解决方案")
        logger.info("  - 自动模拟键盘输入代码到网页")
        logger.info("⚠️  请确保:")
        logger.info("  - 已安装pyautogui: pip install pyautogui")
        logger.info("  - 已设置正确的DeepSeek API密钥")
        logger.info("  - 浏览器输入框已获得焦点")
        
        await asyncio.Future()  # 永久运行

if __name__ == "__main__":
    try:
        # 检查依赖
        try:
            import pyautogui
        except ImportError:
            logger.error("请安装pyautogui: pip install pyautogui")
            exit(1)
            
        try:
            from openai import OpenAI
        except ImportError:
            logger.error("请安装openai: pip install openai")
            exit(1)
        
        # 检查API密钥
        if DEEPSEEK_API_KEY == "your_deepseek_api_key_here":
            logger.error("请设置正确的DeepSeek API密钥")
            exit(1)
            
        asyncio.run(main())
        
    except KeyboardInterrupt:
        logger.info("服务器被用户中断")
    except Exception as e:
        logger.error(f"服务器启动失败: {e}")