; �򻯵�KBLAutoSwitch�ű� - ����ʱ�л���Ӣ�����뷨���˳�
#SingleInstance Force
#NoTrayIcon

; ��ʼ������
global CN_Code := 0x804  ; �������뷨����
global EN_Code := 0x409  ; Ӣ�����뷨����

; ��������ʱֱ���л���Ӣ�����뷨
Gosub, SwitchToEnglish

; �л���Ӣ�ĺ������˳�����
ExitApp

; �л���Ӣ�����뷨
SwitchToEnglish:
    ; ��ȡ��ǰ����ڵ�IME���
    WinGet, win_id, , A
    IMEwin_id := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, win_id, Uint)
    
    ; �л���Ӣ�����뷨
    PostMessage, 0x50, , %EN_Code%, , ahk_id %IMEwin_id%
    
    ; ��Ӷ����ӳ�ȷ���л����
    Sleep, 100
Return