; 简化的KBLAutoSwitch脚本 - 启动时切换到英文输入法后退出
#SingleInstance Force
#NoTrayIcon

; 初始化变量
global CN_Code := 0x804  ; 中文输入法代码
global EN_Code := 0x409  ; 英文输入法代码

; 程序启动时直接切换到英文输入法
Gosub, SwitchToEnglish

; 切换到英文后立即退出程序
ExitApp

; 切换到英文输入法
SwitchToEnglish:
    ; 获取当前激活窗口的IME句柄
    WinGet, win_id, , A
    IMEwin_id := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, win_id, Uint)
    
    ; 切换到英文输入法
    PostMessage, 0x50, , %EN_Code%, , ahk_id %IMEwin_id%
    
    ; 添加短暂延迟确保切换完成
    Sleep, 100
Return