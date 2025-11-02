import asyncio
import websockets
import logging
import json
from openai import AsyncOpenAI
import pyautogui
import time
import os
import win32api
import win32gui
from win32con import WM_INPUTLANGCHANGEREQUEST

# 输入法相关函数
def get_language():
    """获取当前输入法状态"""
    hwnd = win32gui.GetForegroundWindow()
    thread_id = win32api.GetWindowLong(hwnd, 0)
    klid = win32api.GetKeyboardLayout(thread_id)
    lid = klid & (2 ** 16 - 1)
    lid_hex = hex(lid)
    print(lid_hex)
    if lid_hex == '0x409':
        print('当前的输入法状态是英文\n\n')
        return 0
    elif lid_hex == '0x804':
        print('当前的输入法是中文\n\n')
        return 1
    else:
        print('当前的输入法既不是英文也不是中文\n\n')
        return 0


def change_language(language="EN"):
    """
    切换语言
    :param language: EN––English; ZH––Chinese
    :return: bool
    """
    LANGUAGE = {
        "CH": 0x0804,
        "EN": 0x0409
    }
    """
    获取键盘布局
    im_list = win32api.GetKeyboardLayoutList()
    im_list = list(map(hex, im_list))
    print(im_list)
    """
    hwnd = win32gui.GetForegroundWindow()
    language = LANGUAGE.get(language)
    result = win32api.SendMessage(
        hwnd,
        WM_INPUTLANGCHANGEREQUEST,
        0,
        language
    )
    return result == 0

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


if os.path.exists("cache.txt"):
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
        self.client = AsyncOpenAI(
            api_key=DEEPSEEK_API_KEY,
            base_url=DEEPSEEK_BASE_URL
        )
        self.last_question = None
        self.is_first_chunk = True  #标记是否是第一个代码块

    async def get_code_solution(self, question_text):
        """
        使用DeepSeek API获取代码解决方案（流式输出）
        返回异步生成器，逐步产生代码片段
        """
        try:
            logger.info("向DeepSeek发送请求获取代码解决方案...")
            

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
            
            #等待异步调用完成
            response = await self.client.chat.completions.create(
                model="deepseek-coder",
                messages=[
                    {
                        "role": "system", 
                        "content": "你是一个专业的编程助手，只返回代码，不包含任何解释或注释。尤其注意代码前一定不要有```c的标记，代码最后也不要有```的标记。不要return 0这一行。"
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                max_tokens=8192,
                temperature=0.3,
                stream=True
            )
            
            # 初始化
            full_code = ""
            self.is_first_chunk = True
            
            #流式，使用yield逐步返回代码
            async for chunk in response:
                if chunk.choices and chunk.choices[0].delta.content is not None:
                    content = chunk.choices[0].delta.content
                    full_code += content
                    
                    #实时输出代码片段
                    #print(content, end="", flush=True)
                    
                    #逐步返回代码片段
                    yield {
                        "type": "code_chunk",
                        "chunk": content,
                        "is_complete": False
                    }
            
            logger.info(f"代码解决方案流式传输完成，总长度: {len(full_code)} 字符")
            
            #清理响应，确保只包含代码（好像并没有用）
            cleaned_code = self.clean_code_response(full_code)
            
            # 返回完整的清理后的代码
            
            yield {
                "type": "code_complete",
                "full_code": cleaned_code,
                "is_complete": True
            }
            

        except Exception as e:
            logger.error(f"获取DeepSeek响应失败: {e}")
            yield {
                "type": "error",
                "message": f"获取代码解决方案失败: {str(e)}",
                "is_complete": True
            }

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
    
    def simulate_typing_chunk(self, text, is_first_chunk=False):
        """
        模拟键盘输入文本片段
        """
        try:
            if is_first_chunk:
                logger.info("开始模拟键盘输入代码...")
                
                #确保焦点在输入区域
                screen_width, screen_height = pyautogui.size()
                print(f"屏幕宽度: {screen_width}, 屏幕高度: {screen_height}")
                xzuobiao=screen_width/2
                yzuobiao=screen_height/2
                pyautogui.click(x=xzuobiao, y=yzuobiao)

                time.sleep(0.1)
                pyautogui.hotkey('ctrl', 'a')
                time.sleep(0.1)
                pyautogui.hotkey('delete')
                time.sleep(0.5)
                
               
            # 输入当前代码片段
            if text.strip():
                pyautogui.write(text, interval=0.1)
                
            return True
            
        except Exception as e:
            logger.error(f"模拟键盘输入失败: {e}")
            return False
    
    def finalize_code_formatting(self, full_code):
        """
        完成代码输入后的格式化操作
        """
        try:
            left_kuohao = full_code.count('{')
            
            # 执行代码格式化
            time.sleep(0.1)
            pyautogui.hotkey('alt', 'shift', 'f')
            pyautogui.keyDown('down')
            time.sleep(1)
            pyautogui.keyUp('down')

            # 处理多余的大括号
            #pyautogui.press('down', presses=left_kuohao)
            pyautogui.press('end')
            for i in range(left_kuohao):
                time.sleep(0.1)
                #pyautogui.press('backspace')
                #time.sleep(0.1)
                #pyautogui.press('backspace')
                pyautogui.hotkey('ctrl','shift','k')
                pyautogui.press('left')

            logger.info("代码格式化完成")
            pyautogui.alert(text='代码输入已完成', title='提示', button='我知道了')
            return True
            
        except Exception as e:
            logger.error(f"代码格式化失败: {e}")
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
                                await websocket.send("开始实时输入代码到编辑器...")
                                
                                 # 检查并切换输入法
                                ret = get_language()
                                print(ret)
                                if ret == 1:
                                    pyautogui.hotkey('ctrl', 'space')
                                    time.sleep(0.5)

                                # 获取代码解决方案（流式）并实时输入
                                full_code = ""
                                async for code_response in assistant.get_code_solution(question_text):
                                    # 发送每个代码片段到客户端
                                    await websocket.send(json.dumps(code_response, ensure_ascii=False))
                                    
                                    # 如果是代码片段，实时输入到编辑器
                                    if code_response.get("type") == "code_chunk":
                                        chunk = code_response.get("chunk", "")
                                        full_code += chunk
                                        
                                        # 实时输入代码片段
                                        input_success = assistant.simulate_typing_chunk(
                                            chunk, 
                                            is_first_chunk=assistant.is_first_chunk
                                        )
                                        assistant.is_first_chunk = False
                                        
                                        if not input_success:
                                            await websocket.send("代码输入出现错误")
                                    
                                    elif code_response.get("type") == "code_complete":
                                        full_code = code_response.get("full_code", full_code)
                                        
                                        # 完成代码格式化
                                        format_success = assistant.finalize_code_formatting(full_code)
                                        if format_success:
                                            await websocket.send("✅ 代码已完成并自动格式化")
                                        else:
                                            await websocket.send("❌ 代码格式化失败")
                                
                                logger.info("代码生成和输入流程完成")
                                    
                            else:
                                await websocket.send("未找到有效的题目内容")
                                
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
