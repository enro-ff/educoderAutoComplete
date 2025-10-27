
Label_ScriptSetting: ; �ű�ǰ��������
	Process, Priority, , Realtime					;�ű������ȼ�
	#MenuMaskKey vkE8
	#Persistent										;�ýű��־�����(�رջ�ExitApp)
	#SingleInstance Force							;����������У�ͨ��Single_Run���Ƶ���
	#WinActivateForce								;ǿ�Ƽ����
	#MaxHotkeysPerInterval 2000						;ʱ���ڰ��ȼ�������
	#HotkeyModifierTimeout 100						;��סmodifier��(�����ͷź��ٰ�һ��)�����ض����ǰ�����
	SetBatchLines, -1								;�ű�ȫ��ִ��
	SetControlDelay -1								;�ؼ��޸������Զ���ʱ,-1����ʱ��0��С��ʱ
	CoordMode Menu Window							;������Ի����
	CoordMode Mouse Screen							;����������������(������Ļ)
	ListLines, Off									;����ʾ���ִ�еĽű���
	SendMode Input									;���ٶȺͿɿ���ʽ���ͼ��̵��
	SetTitleMatchMode 2								;���ڱ���ģ��ƥ��;RegEx����ƥ��
	DetectHiddenWindows on							;��ʾ���ش���
	SetWorkingDir, %A_ScriptDir%


Label_DefVar: ; ��ʼ������
	global StartTick:=A_TickCount ; ������ʼʱ��
	global ScriptIniting := 1 ; �ű���ʼ����
	global APPName := "KBLAutoSwitch"
	global APPVersion := "2.4.0"
	global APPVersion := "2.4.1"
	global INI := A_ScriptDir "\KBLAutoSwitch.ini" ; �����ļ�
	global AutoSwitchFrequency := 0 ; �Զ��л�����ͳ��
	global APPType := RegExMatch(APPVersion, "\d*\.\d*\.\d*\.\d*")?"�����԰棩":"",APPVersion := APPVersion APPType
	; �̶�������ʼ��
	global State_ShowTime := 1000 ; ��Ϣ��ʾʱ��
	global FontType := "Microsoft YaHei" ; ��������
	global CN_Code:=0x804,EN_Code:=0x409 ; KBL����
	global Display_Cn := "��",Display_CnEn := "Ӣ",Display_En := "En" ; KBL��ʾ��Ϣ
	global Auto_Reload_MTime:=2000 ; �Զ�����ʱ��
	; ����INI�����ļ���������
	global Auto_Launch,Launch_Admin,Auto_Switch,Default_Keyboard
	global TT_OnOff_Style,TT_Display_Time,TT_Font_Size,TT_Transparency,TT_Shift,TT_Pos_Coef
	global Tray_Display,Tray_Display_KBL,Tray_Double_Click,Tray_Display_Style
	global Disable_HotKey_App_List,Disable_Switch_App_List,Disable_TTShow_App_List,No_TwiceSwitch_App_List,FocusControl_App_List
	global Cur_Launch,Cur_Launch_Style,Cur_Size
	global Hotkey_Add_To_Cn,Hotkey_Add_To_CnEn,Hotkey_Add_To_En,Hotkey_Remove_From_All
	global Hotkey_Set_Chinese,Hotkey_Set_ChineseEnglish,Hotkey_Set_English,Hotkey_Display_KBL,Hotkey_Reset_KBL,Hotkey_Toggle_CN_CNEN,Hotkey_Toggle_CN_EN
	global Hotkey_Stop_KBLAS,Hotkey_Get_KeyBoard
	global Hotkey_Left_Shift,Hotkey_Right_Shift,Hotkey_Left_Ctrl,Hotkey_Right_Ctrl,Hotkey_Left_Alt,Hotkey_Right_Alt
	global Open_Ext,Outer_InputKey_Compatible,Left_Mouse_ShowKBL,Left_Mouse_ShowKBL_Up,SetTimer_Reset_KBL,Reset_CapsLock,Enter_Inputing_Content,GuiTTColor,TrayTipContent,AutoCheckUpdate
	global LatestCheckDateTime
	global Custom_Win_Group,Custom_Hotstring
	global INI_CN,INI_CNEN,INI_EN

Label_AdminLaunch: ; ����Ա����
	iniread, Launch_Admin, %INI%, ��������, ����Ա����, 1
	if (!A_IsAdmin && Launch_Admin=1)
	{
	    try
	    {
	        if A_IsCompiled
	            Run *RunAs "%A_ScriptFullPath%" /restart
	        else
	            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	    }catch{
	    	MsgBox, 1,, �ԡ�����ԱȨ�ޡ�����ʧ�ܣ�������ͨȨ������������ԱӦ�ô��ڽ�ʧЧ��
			IfMsgBox OK
			{
				if A_IsCompiled
	            	Run "%A_ScriptFullPath%" /restart
	       		else
	            	Run "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
	    }
	    ExitApp
	}

Label_SystemVersion: ; ��ȡwinϵͳ�汾
	global OSVersion := StrReplace(A_OSVersion, ".")
	If (OSVersion="WIN_7")
		OSVersion := 7
	Else If (OSVersion<10022000)
		OSVersion := 10
	Else If (OSVersion>=10022000)
		OSVersion := 11
	Else
		OSVersion := 0

Label_WindowsMonitor: ; ��ȡwindows��ʾ����Ϣ
	OnMessage(0x007E, "monitorChange")
	SysGet, MonitorCount, MonitorCount
	global MonitorAreaObjects := Object()
	Loop, %MonitorCount%
	{
	    SysGet, Monitor, Monitor, %A_Index%
	    MonitorAreaObject := Object()
	    MonitorAreaObject[1] := MonitorLeft
	    MonitorAreaObject[2] := MonitorTop
	    MonitorAreaObject[3] := MonitorRight
	    MonitorAreaObject[4] := MonitorBottom
	    MonitorAreaObject[5] := Abs(MonitorRight-MonitorLeft)<Abs(MonitorBottom-MonitorTop)?Abs(MonitorRight-MonitorLeft):Abs(MonitorBottom-MonitorTop)
	    MonitorAreaObjects[A_Index] := MonitorAreaObject
	}

Label_SystemVersion_Var: ; ����winϵͳ�汾��Ӧ����
	global Ico_path := Object()
	global Ico_num := Object()
	If (OSVersion=10){
		Ico_path["�رղ˵�"] := "imageres.dll",Ico_num["�رղ˵�"] := 233
		Ico_path["�����ĵ�"] := "imageres.dll",Ico_num["�����ĵ�"] := 100
		Ico_path["������"] := "shell32.dll",Ico_num["������"] := 14
		Ico_path["������ѡ��"] := "imageres.dll",Ico_num["������ѡ��"] := 110
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 317
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 77
		Ico_path["ֹͣ"] := "imageres.dll",Ico_num["ֹͣ"] := 208
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 229
		Ico_path["�˳�"] := "imageres.dll",Ico_num["�˳�"] := 230
	}Else If (OSVersion=11){
		Ico_path["�رղ˵�"] := "imageres.dll",Ico_num["�رղ˵�"] := 234
		Ico_path["�����ĵ�"] := "imageres.dll",Ico_num["�����ĵ�"] := 110
		Ico_path["������"] := "shell32.dll",Ico_num["������"] := 14
		Ico_path["������ѡ��"] := "imageres.dll",Ico_num["������ѡ��"] := 110
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 315
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 77
		Ico_path["ֹͣ"] := "imageres.dll",Ico_num["ֹͣ"] := 208
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 230
		Ico_path["�˳�"] := "imageres.dll",Ico_num["�˳�"] := 231
	}Else If (OSVersion=7){
		Ico_path["�رղ˵�"] := "imageres.dll",Ico_num["�رղ˵�"] := 102
		Ico_path["�����ĵ�"] := "imageres.dll",Ico_num["�����ĵ�"] := 110
		Ico_path["������"] := "shell32.dll",Ico_num["������"] := 14
		Ico_path["������ѡ��"] := "imageres.dll",Ico_num["������ѡ��"] := 110
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 64
		Ico_path["����"] := "imageres.dll",Ico_num["����"] := 77
		Ico_path["ֹͣ"] := "imageres.dll",Ico_num["ֹͣ"] := 207
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 239
		Ico_path["�˳�"] := "shell32.dll",Ico_num["�˳�"] := 216
	}Else If (OSVersion=0){
		Ico_path["�رղ˵�"] := "shell32.dll",Ico_num["�رղ˵�"] := 3
		Ico_path["�����ĵ�"] := "shell32.dll",Ico_num["�����ĵ�"] := 3
		Ico_path["������"] := "shell32.dll",Ico_num["������"] := 14
		Ico_path["������ѡ��"] := "shell32.dll",Ico_num["������ѡ��"] := 3
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 3
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 3
		Ico_path["ֹͣ"] := "shell32.dll",Ico_num["ֹͣ"] := 3
		Ico_path["����"] := "shell32.dll",Ico_num["����"] := 3
		Ico_path["�˳�"] := "shell32.dll",Ico_num["�˳�"] := 3
	}

Label_KBLDetect: ; ��ע�����KBL
	KBLObj := Object()
	Loop, Reg, HKEY_CURRENT_USER\Keyboard Layout\Preload, V
	{
	    RegRead, OutputVar
	    OutputVar := SubStr(OutputVar,-2)
	    KBLObj[OutputVar] := 1
	}
	If KBLObj.HasKey(804){
	    If KBLObj.HasKey(409)
	        KBLEnglish_Exist := 1
	    Else
	        KBLEnglish_Exist := 0
	}Else{
		MsgBox,16,,δ��װ�����ġ����뷨���밲װ�������뷨�����ԣ�
		ExitApp
	}

Label_ReadINI: ; ��ȡINI�����ļ�
	if !FileExist(INI)
		Gosub,Label_Init_INI

	; ��ȡ��������
	iniread, Auto_Launch, %INI%, ��������,��������, 0
	iniread, Auto_Switch, %INI%, ��������, �Զ��л�, 1
	iniread, Default_Keyboard, %INI%, ��������, Ĭ�����뷨, 1

	iniread, TT_OnOff_Style, %INI%, ��������, �л���ʾ, 4
	iniread, TT_Display_Time, %INI%, ��������, �л���ʾʱ��, 1500
	iniread, TT_Font_Size, %INI%, ��������, �л���ʾ���ִ�С, 15,30
	iniread, TT_Transparency, %INI%, ��������, �л���ʾ͸����, 235,180
	iniread, TT_Shift, %INI%, ��������, �л���ʾƫ��, 0,0
	iniread, TT_Pos_Coef, %INI%, ��������, �л���ʾ�̶�λ��, 50,30

	iniread, Tray_Display, %INI%, ��������,����ͼ����ʾ, 1
	iniread, Tray_Double_Click, %INI%, ��������,����ͼ��˫��, 2
	iniread, Tray_Display_KBL, %INI%, ��������,����ͼ����ʾ���뷨, 1
	iniread, Tray_Display_Style, %INI%, ��������,����ͼ����ʽ, ԭ��
	iniread, Cur_Launch, %INI%, ��������,���ָ����ʾ���뷨, 1
	iniread, Cur_Launch_Style, %INI%, ��������,���ָ����ʽ, ԭ��
	iniread, Cur_Size, %INI%, ��������,���ָ���Ӧ�ֱ���, 0

	; ��ȡ���δ����б�
	iniread, Disable_HotKey_App_List, %INI%, �ȼ����δ����б�
	iniread, Disable_Switch_App_List, %INI%, �л����δ����б�
	iniread, Disable_TTShow_App_List, %INI%, �л���ʾ���δ����б�
	iniread, No_TwiceSwitch_App_List, %INI%, �����л����δ����б�
	iniread, FocusControl_App_List, %INI%, ����ؼ��л������б�

	; ��ȡ�ȼ�
	iniread, Hotkey_Add_To_Cn, %INI%, �ȼ�����,��������Ĵ���, %A_Space%
	iniread, Hotkey_Add_To_CnEn, %INI%, �ȼ�����,�����Ӣ��(����)����, %A_Space%
	iniread, Hotkey_Add_To_En, %INI%, �ȼ�����,�����Ӣ�����뷨����, %A_Space%
	iniread, Hotkey_Remove_From_All, %INI%, �ȼ�����,�Ƴ�����Ӣ�Ĵ���, %A_Space%

	iniread, Hotkey_Set_Chinese, %INI%, �ȼ�����,�л�����, %A_Space%
	iniread, Hotkey_Set_ChineseEnglish, %INI%, �ȼ�����,�л�Ӣ��(����), %A_Space%
	iniread, Hotkey_Set_English, %INI%, �ȼ�����,�л�Ӣ�����뷨, %A_Space%
	iniread, Hotkey_Toggle_CN_CNEN, %INI%, �ȼ�����,�л���Ӣ��(����), %A_Space%
	iniread, Hotkey_Toggle_CN_EN, %INI%, �ȼ�����,�л���Ӣ�����뷨, %A_Space%
	iniread, Hotkey_Display_KBL, %INI%, �ȼ�����,��ʾ��ǰ���뷨, %A_Space%
	iniread, Hotkey_Reset_KBL, %INI%, �ȼ�����,���õ�ǰ���뷨, %A_Space%
	iniread, Hotkey_Stop_KBLAS, %INI%, �ȼ�����,ֹͣ�Զ��л�, %A_Space%
	iniread, Hotkey_Get_KeyBoard, %INI%, �ȼ�����,��ȡ���뷨IME����, %A_Space%

	; ��ȡ�����ȼ�
	iniread, Hotkey_Left_Shift, %INI%, �����ȼ�,��Shift, 1
	iniread, Hotkey_Right_Shift, %INI%, �����ȼ�,��Shift, 2
	iniread, Hotkey_Left_Ctrl, %INI%, �����ȼ�,��Ctrl, 0
	iniread, Hotkey_Right_Ctrl, %INI%, �����ȼ�,��Ctrl, 0
	iniread, Hotkey_Left_Alt, %INI%, �����ȼ�,��Alt, 0
	iniread, Hotkey_Right_Alt, %INI%, �����ȼ�,��Alt, 0
	
	; ��ȡ�߼�����
	iniread, Open_Ext, %INI%, �߼�����, �ڲ�����, %A_Space%
	iniread, Outer_InputKey_Compatible, %INI%, �߼�����, ��ݼ�����, 1
	iniread, Left_Mouse_ShowKBL, %INI%, �߼�����, ����������λ����ʾ���뷨״̬, 1|ȫ�ִ���
	iniread, Left_Mouse_ShowKBL_Up, %INI%, �߼�����, ����������ʾ���뷨״̬��Ч����, Code.exe
	iniread, SetTimer_Reset_KBL, %INI%, �߼�����, ��ʱ�������뷨, 60|�༭��
	iniread, Reset_CapsLock, %INI%, �߼�����, �л����ô�Сд, 1
	iniread, Enter_Inputing_Content, %INI%, �߼�����, �����ַ�����, 2|1
	iniread, GuiTTColor, %INI%, �߼�����, ��ʾ��ɫ, 333434|dfe3e3|02ecfb|ff0000
	iniread, TrayTipContent, %INI%, �߼�����, ������ʾ����, %A_Space%
	iniread, AutoCheckUpdate, %INI%, �߼�����, �Զ�������, 0

	; ��ȡ�Զ��崰������Զ������
	iniread, Custom_Win_Group, %INI%, �Զ��崰����
	iniread, Custom_Hotstring, %INI%, �Զ������
	
	; ��ȡ����
	iniread, INI_CN, %INI%, ���Ĵ���
	IniRead, INI_CNEN, %INI%, Ӣ�Ĵ���
	IniRead, INI_EN, %INI%, Ӣ�����뷨����

	; ��ȡ��Ϣ����
	iniread, LatestCheckDateTime, %INI%, ��Ϣ����, �������������, 2000-01-01 00:00:00

	; �����Զ��崰����
	global WinMenuObj := Object()
	global Custom_Win_Group_Cn,Custom_Win_Group_CnEn,Custom_Win_Group_En
	global groupNameList := "��",groupNameObj := Object(),groupNumObj := Object()
	groupNameObj["��"] := 0
	groupNumObj[0] := "��"
	Loop, parse, Custom_Win_Group, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		groupNum := MyVar[1]
		groupName := MyVar[2]
		groupState := MyVar[3]
		groupVal := MyVar[4]			
		groupNameList .= "|" groupName
		groupNameObj[groupName] := groupNum
		groupNumObj[groupNum] := groupName
		getINISwitchWindows(groupVal,groupName,"|")
		If (Auto_Switch=1){ ; ����Զ��鵽�Զ��л���
			Switch groupState
			{
				Case 1:GroupAdd, cn_ahk_group_custom, ahk_group%A_Space%%groupName%
				Case 2:GroupAdd, cnen_ahk_group_custom, ahk_group%A_Space%%groupName%
				Case 3:GroupAdd, en_ahk_group_custom, ahk_group%A_Space%%groupName%
			}
		}
	}

	; �����Զ��л����뷨������
If (Auto_Switch=1) {
	getINISwitchWindows(INI_CN,"cn_ahk_group") ; �������뷨����ģʽ����
	getINISwitchWindows(INI_CNEN,"cnen_ahk_group")  ; �������뷨Ӣ����ģʽ����
	If (KBLEnglish_Exist=0)
		getINISwitchWindows(INI_EN,"cnen_ahk_group") ; Ӣ�����뷨����
	Else
		getINISwitchWindows(INI_EN,"en_ahk_group") ; Ӣ�����뷨����
	;-------------------------------------------------------
	; ���л�������
	GroupAdd, unswitch_ahk_group, ahk_class tooltips_class32 ; ������С��ͷ
	GroupAdd, unswitch_ahk_group_after, ahk_class Qt5QWindowToolSaveBits
	GroupAdd, unswitch_ahk_group_after, ahk_class Windows.UI.Core.CoreWindow
	GroupAdd, unswitch_ahk_group_after, ahk_exe HipsTray.exe
	GroupAdd, unswitch_ahk_group_after, ahk_exe rundll32.exe
	GroupAdd, unswitch_ahk_group_before, ahk_class MultitaskingViewFrame ; alt+tab�л�
	GroupAdd, unswitch_ahk_group_before, ahk_class TaskListThumbnailWnd ; ��������ͼ
	GroupAdd, unswitch_ahk_group_before, ahk_class Shell_TrayWnd ; ������
	GroupAdd, unswitch_ahk_group_before, ahk_class NotifyIconOverflowWindow ; ������С��ͷ
}
	; Ĭ�Ͻ���ؼ�����
	GroupAdd, focus_control_ahk_group, ahk_exe ApplicationFrameHost.exe ; uwpӦ��
	GroupAdd, focus_control_ahk_group, ahk_exe explorer.exe ; �ļ���Դ������
	
	; ��ȡ������λ��sleep��
	GroupAdd, GetCaretSleep_ahk_group, ahk_class Chrome_WidgetWin_1 ; Chromium��Ӧ��
	
	; ���뷨�����ѡ����
	GroupAdd, IMEInput_ahk_group, ahk_class SoPY_Comp			; �ѹ����뷨
	GroupAdd, IMEInput_ahk_group, ahk_class SoWB_Comp			; �ѹ�������뷨
	GroupAdd, IMEInput_ahk_group, ahk_class QQWubiCompWndII		; QQ������뷨
	GroupAdd, IMEInput_ahk_group, ahk_class QQPinyinCompWndTSF	; QQƴ�����뷨
	GroupAdd, IMEInput_ahk_group, ahk_class PalmInputUICand 	; �������뷨
	GroupAdd, IMEInput_ahk_group, ahk_class i)^ATL: 			; ����������뷨


Label_DisableAppList: ; ��ȡ���δ����б�
	getINISwitchWindows(Disable_HotKey_App_List,"DisableHotKeyAppList_ahk_group") ; �ȼ�����
	getINISwitchWindows(Disable_Switch_App_List,"DisableSwitchAppList_ahk_group") ; �л�����
	getINISwitchWindows(Disable_TTShow_App_List,"DisableTTShowAppList_ahk_group") ; �л���ʾ����
	getINISwitchWindows(No_TwiceSwitch_App_List,"NoTwiceSwitchAppList_ahk_group") ; �����л����δ����б�
	getINISwitchWindows(FocusControl_App_List,"focus_control_ahk_group")

Label_Hotstring: ; �Զ������
	global TarFunList := Object(),TarHotFunFlag := 0
	Loop, parse, Custom_Hotstring, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		TargroupName := groupNumObj[MyVar[2]]
		TarHotFlag := SubStr(MyVar[3], 1, 2)
		TarHotVal := SubStr(MyVar[3], 3)
		Hotkey, IfWinActive, ahk_group%A_Space%%TargroupName%
		Loop, parse, TarHotVal, "|"
		{
			TarFunList[A_LoopField] := MyVar[4]
			If (TarHotFlag="s-")
				Hotstring(":*XB0:" A_LoopField, "TarHotFun")
			Else If (TarHotFlag="k-")
				try Hotkey, %A_LoopField%, TarHotFun
		}
	}

Label_ReadExtRunList: ; ��ȡ�ڲ�����
	If (Open_Ext!=""){
		global openExtRunList := Object() ; �ڲ�����·���Ӳ���
    	global openExtRunList_Parm := Object() ; �ڲ���������
    	global openExtRunList_num := ReadExtRunList(Open_Ext,"ini|folder") ; ��ȡ�ڲ�������������
	}  

Label_IcoLaunch: ; ����Win������������ͼ������·��
	Gosub, Label_ReadExistIcoStyles
	global SystemUsesLightTheme
	RegRead, SystemUsesLightTheme, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, SystemUsesLightTheme
	SystemUsesLightTheme_Str := SystemUsesLightTheme=0?"black":"white"
	If (Tray_Display=1 && Tray_Display_KBL=1){
		ACNico_path = %A_ScriptDir%\Icos\%Tray_Display_Style%\%SystemUsesLightTheme_Str%_A_CN.ico
		AENico_path = %A_ScriptDir%\Icos\%Tray_Display_Style%\%SystemUsesLightTheme_Str%_A_EN.ico
		CNico_path = %A_ScriptDir%\Icos\%Tray_Display_Style%\%SystemUsesLightTheme_Str%_Cn.ico
		CNENico_path = %A_ScriptDir%\Icos\%Tray_Display_Style%\%SystemUsesLightTheme_Str%_CnEn.ico
		ENico_path = %A_ScriptDir%\Icos\%Tray_Display_Style%\%SystemUsesLightTheme_Str%_En.ico	
		global ACNIcon := LoadPicture(ACNico_path,,ImageType)
		global AENIcon := LoadPicture(AENico_path,,ImageType)
		global CNIcon := LoadPicture(CNico_path,,ImageType)
		global CNENIcon := LoadPicture(CNENico_path,,ImageType)
		global ENIcon := LoadPicture(ENico_path,,ImageType)
	}

Label_CurLaunch: ; ���ָ���ʼ��
	Gosub, Label_ReadExistCurStyles
	global ExistCurSize := "" ; ���ָ��ֱ����ַ���
	Loop Files, %A_ScriptDir%\Curs\%Cur_Launch_Style%\*, D
		ExistCurSize := ExistCurSize "|" A_LoopFileName
	If (Cur_Launch=1){
		global OCR_IBEAM := 32513,OCR_NORMAL := 32512,OCR_APPSTARTING := 32650,OCR_WAIT := 32514,OCR_HAND := 32649
		global OCR_CROSS:=32515,OCR_HELP:=32651,OCR_NO:=32648,OCR_UP:=32516
		global OCR_SIZEALL:=32646,OCR_SIZENESW:=32643,OCR_SIZENS:=32645,OCR_SIZENWSE:=32642,OCR_SIZEWE:=32644
		global 	CurPathObjs := Object()
		Loop, % MonitorAreaObjects.Length(){
			If (ExistCurSize=""){
				realWindowsHeight := 0
			}Else{
				WindowsHeight := MonitorAreaObjects[A_Index][5]
				realWindowsHeight := WindowsHeight
			}
			If (!FileExist(A_ScriptDir "\Curs\" Cur_Launch_Style "\" realWindowsHeight)){
				Loop, parse, ExistCurSize, |
				{
					If (A_Index=1)
						Continue
					Else If (A_Index=2)
						realWindowsHeight := A_LoopField
					Else
						realWindowsHeight := Abs(A_LoopField-WindowsHeight)<Abs(WindowsHeight-realWindowsHeight)?A_LoopField:realWindowsHeight
				}
			}
			If (Cur_Size)
				realWindowsHeight := Cur_Size
			MonitorAreaObjects[A_Index][5] := realWindowsHeight
			CurPathObjs[MonitorAreaObjects[A_Index][5]] := 1
		}
		For k, v in CurPathObjs{
			CurPathObj := Object()
			CurPathObj[1] := getCurPath(Cur_Launch_Style,k,"IBEAM_Cn_A")
			CurPathObj[2] := getCurPath(Cur_Launch_Style,k,"IBEAM_En_A")
			CurPathObj[3] := getCurPath(Cur_Launch_Style,k,"IBEAM_Cn")
			CurPathObj[4] := getCurPath(Cur_Launch_Style,k,"IBEAM_En")
			CurPathObj[5] := getCurPath(Cur_Launch_Style,k,"NORMAL_Cn_A")
			CurPathObj[6] := getCurPath(Cur_Launch_Style,k,"NORMAL_En_A")
			CurPathObj[7] := getCurPath(Cur_Launch_Style,k,"NORMAL_Cn")
			CurPathObj[8] := getCurPath(Cur_Launch_Style,k,"NORMAL_En")
			CurPathObj[9] := getCurPath(Cur_Launch_Style,k,"APPSTARTING")
			CurPathObj[10] := getCurPath(Cur_Launch_Style,k,"WAIT")
			CurPathObj[11] := getCurPath(Cur_Launch_Style,k,"HAND")
			
			CurPathObj[12] := getCurPath(Cur_Launch_Style,k,"CROSS")
			CurPathObj[13] := getCurPath(Cur_Launch_Style,k,"HELP")
			CurPathObj[14] := getCurPath(Cur_Launch_Style,k,"NO")
			CurPathObj[15] := getCurPath(Cur_Launch_Style,k,"UP")

			CurPathObj[16] := getCurPath(Cur_Launch_Style,k,"SIZEALL")
			CurPathObj[17] := getCurPath(Cur_Launch_Style,k,"SIZENESW")
			CurPathObj[18] := getCurPath(Cur_Launch_Style,k,"SIZENS")
			CurPathObj[19] := getCurPath(Cur_Launch_Style,k,"SIZENWSE")
			CurPathObj[20] := getCurPath(Cur_Launch_Style,k,"SIZEWE")
			
			CurPathObjs[k] := CurPathObj
		}
	}


Label_NecessaryVar:	; �����Ҫ����
	global lastKBLCode56,LastKBLState56 ; �л����뷨��־
	global shellMessageFlag := 1 ; �����л���־
	global NextChangeFlag := 0 ; �´��л���־
	global CheckDateTimeInterval := 0 ; �����ϴμ���������
	global AutoCheckOnceFlag := 1 ; һ�μ����±�־
	global KBLTempFilePath := A_Temp "\KBLAutoSwitch.ahk"
	global KBLDownloadPath := A_Temp "\KBLDownload.ahk"
	global SwitchTT_id,TT_Edit_Hwnd,TT_Edit_Hwnd1 ; Gui�Ϳؼ����
	global LastKBLState,LastCapsState,LastMonitorNum,gl_Active_IMEwin_id ; ǰһ��KBL����Сд����Ļ���״̬���������IME���
	; Ĭ�����뷨����
	global Real_Default_Keyboard := Default_Keyboard
	If (KBLEnglish_Exist=0 && Default_Keyboard=3)
		Real_Default_Keyboard := 2
	GuiTTColorObj := StrSplit(GuiTTColor, "|") ; Gui��ɫ
	global GuiTTBackCnColor:=GuiTTColorObj[1],GuiTTBackEnColor:=GuiTTColorObj[2],GuiTTCnColor:=GuiTTColorObj[3],GuiTTEnColor:=GuiTTColorObj[4]
	Enter_Inputing_ContentObj := StrSplit(Enter_Inputing_Content, "|") ; ����
	global Enter_Inputing_Content_Core := Enter_Inputing_ContentObj[1],Enter_Inputing_Content_CnTo := Enter_Inputing_ContentObj[2]
	global ImmGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "imm32", "Ptr"), "AStr", "ImmGetDefaultIMEWnd", "Ptr")
	; ������Ϣ��ȡ�ı���ַ
	global AppInfoUrl := "https://gitee.com/flyinclouds/KBLAutoSwitch/raw/master/AppInfo.txt"
	
	; �Զ������
	global ����ʱ�� := A_YYYY "/" A_MM "/" A_DD "  " A_Hour ":" A_Min ":" A_Sec
	global Ȩ�� := A_IsAdmin=1?"����Ա":"�ǹ���Ա"
	global �汾 := "v" APPVersion
	global ����ʱ�� := 0
	

Label_DropDownListData: ; �����б�����
	global OnOffState := "��ֹ|����"
	global KBLSwitchState := "��|����|Ӣ��(����)|Ӣ��"
	global TrayFuncState := "��|������ѡ��|����|ֹͣ"
	global OperationState := "��|�л�������|�л���Ӣ��(����)|�л���Ӣ�����뷨|�л���Ӣ��(����)|�л���Ӣ�����뷨|�������뷨"
	global ListViewKBLState := "��|��|Ӣ(��)|Ӣ"
	global DefaultCapsLockState := "��|Сд|��д"

Label_Init: ; ��ʼ������
	Gosub, Label_Init_ShowKBLGui ; ��ʼ���л���ʾGUI
	Gosub, Label_Init_ResetINI ; ��ʱ��������ļ�
	
Label_Left_Mouse_ShowKBL: ; �����ʾ���뷨
	StrSplit(Left_Mouse_ShowKBL,"|",,2)
	Left_Mouse_ShowKBL_temp := StrSplit(Left_Mouse_ShowKBL,"|",,2)
	Left_Mouse_ShowKBL_State := Left_Mouse_ShowKBL_temp[1]
	getINISwitchWindows(Left_Mouse_ShowKBL_temp[2],"Left_Mouse_ShowKBL_WinGroup","|")
	Hotkey, IfWinActive, ahk_group Left_Mouse_ShowKBL_WinGroup
	If (Left_Mouse_ShowKBL_State=1 && TT_OnOff_Style!=0){
		Hotkey, ~LButton, Label_Click_showSwitch
		Hotkey, ~WheelUp, Label_Hide_All
		Hotkey, ~WheelDown, Label_Hide_All
	}
	getINISwitchWindows(Left_Mouse_ShowKBL_Up,"Left_Mouse_ShowKBL_Up_WinGroup","|")

Label_CreateHotkey:	; �����ȼ�
	Hotkey, IfWinNotActive, ahk_group DisableHotKeyAppList_ahk_group
	if (Hotkey_Add_To_Cn != "")
		Hotkey, %Hotkey_Add_To_Cn%, Add_To_Cn
	if (Hotkey_Add_To_CnEn != "")
		Hotkey, %Hotkey_Add_To_CnEn%, Add_To_CnEn
	if (Hotkey_Add_To_En != "")
		Hotkey, %Hotkey_Add_To_En%, Add_To_En
	if (Hotkey_Remove_From_All != "")
		Hotkey, %Hotkey_Remove_From_All%, Remove_From_All

	if (Hotkey_Set_Chinese != ""){
		TarFunList[Hotkey_Set_Chinese] := 1
		try Hotkey, %Hotkey_Set_Chinese%, TarHotFun
	}
	if (Hotkey_Set_ChineseEnglish != ""){
		TarFunList[Hotkey_Set_ChineseEnglish] := 2
		try Hotkey, %Hotkey_Set_ChineseEnglish%, TarHotFun
	}
	if (Hotkey_Set_English != ""){
		TarFunList[Hotkey_Set_English] := 3
		try Hotkey, %Hotkey_Set_English%, TarHotFun
	}
	if (Hotkey_Toggle_CN_CNEN != ""){
		TarFunList[Hotkey_Toggle_CN_CNEN] := 4
		try Hotkey, %Hotkey_Toggle_CN_CNEN%, TarHotFun
	}
	if (Hotkey_Toggle_CN_EN != ""){
		TarFunList[Hotkey_Toggle_CN_EN] := 5
		try Hotkey, %Hotkey_Toggle_CN_EN%, TarHotFun
	}
	if (Hotkey_Reset_KBL != ""){
		TarFunList[Hotkey_Reset_KBL] := 6
		try Hotkey, %Hotkey_Reset_KBL%, TarHotFun
	}

	if (Hotkey_Display_KBL != "")
		Hotkey, %Hotkey_Display_KBL%, Display_KBL
	if (Hotkey_Stop_KBLAS != "")
		Hotkey, %Hotkey_Stop_KBLAS%, Stop_KBLAS
	if (Hotkey_Get_KeyBoard != "")
		Hotkey, %Hotkey_Get_KeyBoard%, Get_KeyBoard

Label_BoundHotkey: ; �������ȼ�
	If (Outer_InputKey_Compatible=1)
		extraKey := " Up"
	BoundHotkey("~LShift" extraKey,Hotkey_Left_Shift)
	BoundHotkey("~RShift" extraKey,Hotkey_Right_Shift)
	BoundHotkey("~LControl" extraKey,Hotkey_Left_Ctrl)
	BoundHotkey("~RControl" extraKey,Hotkey_Right_Ctrl)
	BoundHotkey("~LAlt" extraKey,Hotkey_Left_Alt)
	BoundHotkey("~RAlt" extraKey,Hotkey_Right_Alt)

Label_SetTimer: ; ��ʱ���ȹ���
	If (KBLObj.Length()>1){ ; ��ʱKBL״̬���
		If (Tray_Display=1)
			try Gosub, Label_Create_Tray
		If ((Tray_Display=1 && Tray_Display_KBL=1) || Cur_Launch=1 || TT_OnOff_Style!=0){
			Gosub, Label_KBLState_Detect
			SetTimer, Label_KBLState_Detect, 100
		}
	}
	; ��ʱ�������뷨
	SetTimer_Reset_KBL_temp := StrSplit(SetTimer_Reset_KBL,"|",,2)
	SetTimer_Reset_KBL_Time := SetTimer_Reset_KBL_temp[1]
	getINISwitchWindows(SetTimer_Reset_KBL_temp[2],"SetTimer_Reset_KBL_WinGroup","|")

	global Reset_CapsLock_State := SubStr(Reset_CapsLock, 1, 1)
	getINISwitchWindows(SubStr(Reset_CapsLock, 3),"Inner_AHKGroup_NoCapsLock","|")

Label_AutoSwitch: ; ���������л����뷨
	DllCall("ChangeWindowMessageFilter", "UInt", 0x004A, "UInt" , 1) ; ���ܷǹ���ԱȨ��RA��Ϣ
	If (Auto_Switch=1){ ; ����������Ϣ
		DllCall("RegisterShellHookWindow", UInt, A_ScriptHwnd)
		global shell_msg_num := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")
		OnMessage(shell_msg_num, "shellMessage")		
		shellMessage(1,1)
	}
	OnMessage(0x004A, "Receive_WM_COPYDATA")

Label_End: ; ��β����
	OnExit("ExitFunc") ; �˳�ִ��
	VarSetCapacity(Ico_path, 0)
	VarSetCapacity(Ico_num, 0)
	ScriptIniting := 0 ; �ű���ʼ������
	����ʱ�� := Round((A_TickCount-StartTick)/1000,3) " ��"
	Gosub, Label_Change_TrayTip ; ����������ʾ
	SetTimer, Label_GetLatestAppInfo, -10 ; ��ȡ������Ϣ
	SetTimer, Label_ClearMEM, -1000 ; �����ڴ�

Label_Return: ; ������־
Return

;-----------------------------------�������������ܡ�-----------------------------------------------
Label_KBLState_Detect: ; ���뷨״̬���
	showSwitch()
Return

ExitFunc() { ; �˳�ִ��-��ԭ���ָ��
	DllCall( "SystemParametersInfo", "UInt",0x57, "UInt",0, "UInt",0, "UInt",0 ) ;��ԭ���ָ��
	Gosub, Label_CloseKBLDownload
}


Label_Change_TrayTip: ; �ı�����ͼ����ʾ
	�Զ��л����� := Format("{:d}", AutoSwitchFrequency/2)
	Transform, TrayTipContent_new, Deref, % TrayTipContent
	TrayTipContent_new := TrayTipContent_new=""?"KBLAutoSwitch":TrayTipContent_new
	Menu, Tray, Tip, %TrayTipContent_new%
Return

Label_GetLatestAppInfo: ; ��ȡ������Ϣ
	try{
		AppInfo := UrlDownloadToVar(AppInfoUrl)
		Loop, parse, AppInfo, `n, `r  ; �� `r ֮ǰָ�� `n, ��������ͬʱ֧�ֶ� Windows �� Unix �ļ��Ľ���.
		{
			word_array := StrSplit(A_LoopField, ":",,2)
			varName := word_array[1]
			varValue := word_array[2]
			try SetEnv, %varName%, %varValue%
		}
	}catch e {
		���°汾 := "v0.0.0"
	}
	Gosub, Label_Change_TrayTip ; ����������ʾ
	If (AutoCheckOnceFlag=1){
		AutoCheckOnceFlag := 0
		If (AutoCheckUpdate!=0)
			Gosub, Label_AutoCheckUpdate
	}
Return

Label_AutoCheckUpdate: ; �Զ���������ʾ
	Gosub, Label_UpdateCheckDateTimeInterval
	If (CheckDateTimeInterval!="" && CheckDateTimeInterval<AutoCheckUpdate)
		Return
	If (AutoCheckOnceFlag=1)
		Gosub, Label_GetLatestAppInfo
Return



Label_ClearMEM: ; �����ڴ�
    pid:=() ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
Return

;-----------------------------------�������ļ���⹦�ܡ�-----------------------------------------------
Label_AutoReload_MTime: ; ��ʱ���¼��ؽű�
	RegRead, mtime_ini_path_reg, HKEY_CURRENT_USER, Software\KBLAutoSwitch, %INI%
	FileGetTime, mtime_ini_path, %INI%, M  ; ��ȡ�޸�ʱ��.
	RegRead, SystemUsesLightTheme_new, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, SystemUsesLightTheme
	if (mtime_ini_path_reg != mtime_ini_path || SystemUsesLightTheme_new != SystemUsesLightTheme){
		gosub, Menu_Reload
	}
	SystemUsesLightTheme := SystemUsesLightTheme_new
Return

Label_Init_ResetINI: ; �����ļ����ĺ��Զ����¼��������ļ�
	FileGetTime, mtime_ini_path, %INI%, M  ; ��ȡ�޸�ʱ��.
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\KBLAutoSwitch, %INI%, %mtime_ini_path%
	if (Auto_Reload_MTime>0)
		SetTimer, Label_AutoReload_MTime, %Auto_Reload_MTime%
Return

;-----------------------------------�����뷨�Զ��л����ܡ�-----------------------------------------------
shellMessage(wParam, lParam) { ; ����ϵͳ���ڻص���Ϣ�л����뷨, ��һ����ʵʱ���ڶ����Ǳ���
	If ( wParam=1 || wParam=32772 || wParam=5 || wParam=4) {
		shellMessageFlag := 1
		SetTimer, Label_SetTimer_ResetshellMessageFlag,-500
		Gosub, Label_Shell_KBLSwitch
		If !WinActive("ahk_group NoTwiceSwitchAppList_ahk_group")
			SetTimer, Label_Shell_KBLSwitch, -100
	}Else If (wParam=56){
		NextChangeFlag := 1
		lastKBLCode56 := getIMEKBL(gl_Active_IMEwin_id)
		LastKBLState56 := (lastKBLCode56!=EN_Code?(getIMECode(gl_Active_IMEwin_id)!=0?0:1):2)
	}Else If (NextChangeFlag=1 && wParam=2){
		NextChangeFlag := 0
		KBLCode56 := getIMEKBL(gl_Active_IMEwin_id)
		If (KBLCode56=CN_Code && KBLCode56=lastKBLCode56 && LastKBLState56!=2){
			shellMessageFlag := 1
			SetTimer, Label_SetTimer_ResetshellMessageFlag,-500
			Gosub, Label_KBLSwitch_LastKBLState56
			If !WinActive("ahk_group NoTwiceSwitchAppList_ahk_group")
				SetTimer, Label_KBLSwitch_LastKBLState56, -100
		}
		Else If (KBLCode56=CN_Code && KBLCode56!=lastKBLCode56){
			shellMessageFlag := 1
			SetTimer, Label_SetTimer_ResetshellMessageFlag,-500
			Gosub, Label_KBLSwitch_LastKBLState561
			If !WinActive("ahk_group NoTwiceSwitchAppList_ahk_group")
				SetTimer, Label_KBLSwitch_LastKBLState561, -100
		}
		lastKBLCode56 := KBLCode56
	}
}

Label_KBLSwitch_LastKBLState561: ; Ӣ�����뷨�л����������뷨ʱ
	If WinActive("ahk_group cn_ahk_group"){ ;�л��������뷨
		setKBLlLayout(0,1)
	}Else If WinActive("ahk_group cnen_ahk_group"){ ;�л�Ӣ��(����)���뷨
		setKBLlLayout(1,1)
	}Else If WinActive("ahk_group cn_ahk_group_custom"){ ;�������л��������뷨
		setKBLlLayout(0,1)
	}Else If WinActive("ahk_group cnen_ahk_group_custom"){ ;�������л�Ӣ��(����)���뷨
		setKBLlLayout(1,1)
	}
Return

Label_KBLSwitch_LastKBLState56: ; �������뷨�л����������뷨ʱ
	setKBLlLayout(LastKBLState56,1)
Return

Label_SetTimer_ResetshellMessageFlag: ; ��ʱ����δ�ڽ����л���Ϣ
	shellMessageFlag := 0
Return

Label_Shell_KBLSwitch: ; ���ݼ�����л����뷨
	Critical On
	If (SetTimer_Reset_KBL_Time>0 && WinActive("ahk_group SetTimer_Reset_KBL_WinGroup")) ; �޲�����ʱ�������뷨
		SetTimer, Label_SetTimer_ResetKBL, % SetTimer_Reset_KBL_Time*1000/60
	Else If (SetTimer_Reset_KBL_Time>0)
		SetTimer, Label_SetTimer_ResetKBL, Delete
	If WinActive("ahk_group unswitch_ahk_group") ;�������л������γ���
		Return
	If WinActive("ahk_group DisableSwitchAppList_ahk_group"){ ;�������л������γ���
		showSwitch()
	}Else If WinActive("ahk_group unswitch_ahk_group_before"){ ;û��Ҫ�л��Ĵ���ǰ����֤�л���ʾ�߼�����ȷ
		setKBLlLayout(LastKBLState)
	}Else If WinActive("ahk_group cn_ahk_group"){ ;�л��������뷨
		setKBLlLayout(0,1)
	}Else If WinActive("ahk_group cnen_ahk_group"){ ;�л�Ӣ��(����)���뷨
		setKBLlLayout(1,1)
	}Else If WinActive("ahk_group en_ahk_group"){ ;�л�Ӣ�����뷨
		setKBLlLayout(2,1)
	}Else If WinActive("ahk_group cn_ahk_group_custom"){ ;�������л��������뷨
		setKBLlLayout(0,1)
	}Else If WinActive("ahk_group cnen_ahk_group_custom"){ ;�������л�Ӣ��(����)���뷨
		setKBLlLayout(1,1)
	}Else If WinActive("ahk_group en_ahk_group_custom"){ ;�������л�Ӣ�����뷨
		setKBLlLayout(2,1)
	}Else If WinActive("ahk_group unswitch_ahk_group_after"){ ;û��Ҫ�л��Ĵ��ں󣬱�֤�л���ʾ�߼�����ȷ
		setKBLlLayout(LastKBLState)
	}Else {
		setKBLlLayout(Real_Default_Keyboard-1,1)
	}
	Critical Off
Return

Label_SetTimer_ResetKBL: ; ��ʱ�������뷨״̬
	If (A_TimeIdle>SetTimer_Reset_KBL_Time*1000){
		SendInput, {F22 up}
		gosub, Reset_KBL
	}
Return


;-----------------------------------�����뷨�л����ܡ�-----------------------------------------------
setKBLlLayout(KBL:=0,Source:=0) { ; �������뷨���̲���
	AutoSwitchFrequency += Source
	gl_Active_IMEwin_id := getIMEwinid()
	CapsLockState := LastCapsState
	If !WinActive("ahk_group Inner_AHKGroup_NoCapsLock") { ; ���ô�Сд
		Switch Reset_CapsLock_State
		{
			Case 1: SetCapsLockState, Off
			Case 2: SetCapsLockState, On
		}
		If (Reset_CapsLock_State>0)
			CapsLockState := Reset_CapsLock_State-1
	}
	LastKBLCode := getIMEKBL(gl_Active_IMEwin_id)
	If (KBL=0){ ; �л��������뷨
		If (LastKBLCode=CN_Code){
			setIME(1,gl_Active_IMEwin_id)
		}Else{
			SendMessage, 0x50, , %CN_Code%, , ahk_id %gl_Active_IMEwin_id%,,,,1000
			Sleep,50
			setIME(1,gl_Active_IMEwin_id)
		}
	}Else If (KBL=1){ ; �л�Ӣ��(����)���뷨
		If (LastKBLCode=CN_Code){
			setIME(0,gl_Active_IMEwin_id)
		}Else{
			SendMessage, 0x50, , %CN_Code%, , ahk_id %gl_Active_IMEwin_id%,,,,1000
			Sleep,50
			setIME(0,gl_Active_IMEwin_id)
		}
	}Else If (KBL=2){ ; �л�Ӣ�����뷨
		If (LastKBLCode!=EN_Code)
			PostMessage, 0x50, , %EN_Code%, , ahk_id %gl_Active_IMEwin_id%
	}
	try showSwitch(KBL,CapsLockState,1)
	SetTimer, Label_Change_TrayTip, -1000
}

setIME(setSts, win_id:="") { ; �������뷨״̬-��ȡ״̬-ĩλ����
	SendMessage 0x283, 0x001, 0, , ahk_id %win_id%,,,,1000
	CONVERSIONMODE := 2046&ErrorLevel, CONVERSIONMODE += setSts
    SendMessage 0x283, 0x002, CONVERSIONMODE, , ahk_id %win_id%,,,,1000
    SendMessage 0x283, 0x006, setSts, , ahk_id %win_id%,,,,1000
    Return ErrorLevel
}

getIMEwinid() { ; ��ȡ�����IME�߳�id
	If WinActive("ahk_class ConsoleWindowClass"){
		WinGet, win_id, , ahk_exe conhost.exe
	}Else If WinActive("ahk_group focus_control_ahk_group"){
		ControlGetFocus, CClassNN, A
		If (CClassNN = "")
			WinGet, win_id, , A
		Else
			ControlGet, win_id, Hwnd, , %CClassNN%
	}Else
		WinGet, win_id, , A
	IMEwin_id := DllCall(ImmGetDefaultIMEWnd, Uint, win_id, Uint)
	Return IMEwin_id
}

getIMEKBL(win_id:="") { ; ��ȡ����ڼ��̲���
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", win_id, "UInt", 0)
	IME_State := DllCall("GetKeyboardLayout", "UInt", thread_id)
	Switch IME_State
	{
		Case 134481924:Return 2052
		Case 67699721:Return 1033
		Default:Return IME_State
	}
}

getIMECode(win_id:="") { ; ��ȡ����ڼ��̲�����Ӣ��״̬
	SendMessage 0x283, 0x005, 0, , ahk_id %win_id%,,,,1000
	IME_Input_State := ErrorLevel
	If (IME_Input_State=1){		
		SendMessage 0x283, 0x001, 0, , ahk_id %win_id%,,,,1000
		IME_Input_State := 1&ErrorLevel
	}
	Return IME_Input_State
}

;-----------------------------------��״̬��ʾ���ܡ�-----------------------------------------------
showSwitch(KBLState:="",CapsLockState:="",ForceShowSwitch:=0) { ; ��ʾ��Ӣ��״̬������ͼ�ꡢ����ꡢGui��TT��
	If (KBLState=""){
		gl_Active_IMEwin_id := getIMEwinid()
		LastKBLCode := getIMEKBL(gl_Active_IMEwin_id)
		KBLState := (LastKBLCode!=EN_Code?(getIMECode(gl_Active_IMEwin_id)!=0?0:1):2)
	}
	WinGetClass, class, A
	If (class="" || class="ForegroundStaging") ; alt+tab���ֵ�ahk_class
		KBLState := LastKBLState
	If (CapsLockState="")
		CapsLockState := DllCall("GetKeyState", UInt, 20) & 1
	If (Cur_Size)
		MonitorNum := 1
	Else{
		CoordMode, Mouse , Screen
		MouseGetPos, OutputVarX, OutputVarY
		MonitorNum := getMonitorNum(OutputVarX,OutputVarY)
	}
	Display_KBL_Flag := Object()
	If (ForceShowSwitch=0 && LastKBLState=KBLState && LastCapsState=CapsLockState && LastMonitorNum=MonitorNum)
		Return
	If (ForceShowSwitch!=0 || LastKBLState!=KBLState || LastCapsState!=CapsLockState){
		LastKBLState:=KBLState
		LastCapsState:=CapsLockState
		If (Display_KBL_Flag[1]!=1){
			Display_KBL_Flag[1]:=1
			TT_Display_KBL(KBLState,LastCapsState)
		}
		If (Display_KBL_Flag[2]!=1){
			Display_KBL_Flag[2]:=1
			Tray_Display_KBL(KBLState,CapsLockState)
		}
		If (Display_KBL_Flag[3]!=1){
			Display_KBL_Flag[3]:=1
			Cur_Display_KBL(KBLState,CapsLockState,MonitorNum)
		}
	}
	If (ForceShowSwitch!=0 && LastMonitorNum!=MonitorNum){
		LastMonitorNum := MonitorNum
		static 	LastMonitorW:=0
		If (Display_KBL_Flag[3]!=1 && LastMonitorW!=MonitorAreaObjects[MonitorNum][5]){
			Display_KBL_Flag[3]:=1
			LastMonitorW := MonitorAreaObjects[MonitorNum][5]
			Cur_Display_KBL(KBLState,CapsLockState,MonitorNum)
		}
	}

}

Label_Init_ShowKBLGui: ; �������뷨״̬GUI
	If (TT_OnOff_Style!=0){
		TT_Transparency := StrReplace(TT_Transparency, "��", ",")
		TT_Transparency_Input := StrSplit(TT_Transparency, ",")[1]
		TT_Transparency_Fix := StrSplit(TT_Transparency, ",")[2]
		TT_Transparency_Fix := TT_Transparency_Fix=""?TT_Transparency_Input:TT_Transparency_Fix
		TT_Font_Size := StrReplace(TT_Font_Size, "��", ",")
		TT_Font_Size_Input := StrSplit(TT_Font_Size, ",")[1]
		TT_Font_Size_Fix := StrSplit(TT_Font_Size, ",")[2]
		TT_Font_Size_Fix := TT_Font_Size_Fix=""?TT_Font_Size_Input:TT_Font_Size_Fix	
		TT_Shift := StrReplace(TT_Shift, "��", ",")
		TT_Shift_X := StrSplit(TT_Shift, ",")[1]
		TT_Shift_Y := StrSplit(TT_Shift, ",")[2]
		TT_Shift_X := TT_Shift_X=""?0:TT_Shift_X,TT_Shift_Y := TT_Shift_Y=""?0:TT_Shift_Y
		TT_Pos_Coef := StrReplace(TT_Pos_Coef, "��", ",")
		global TT_Pos_Coef_X := StrSplit(TT_Pos_Coef, ",")[1]
		global TT_Pos_Coef_Y := StrSplit(TT_Pos_Coef, ",")[2]
		TT_Pos_Coef_X := TT_Pos_Coef_X=""?0:TT_Pos_Coef_X,TT_Pos_Coef_Y := TT_Pos_Coef_Y=""?0:TT_Pos_Coef_Y
		If (TT_OnOff_Style!=3){
			Gui, SwitchTT:Destroy
			Gui, SwitchTT:-SysMenu +ToolWindow +AlwaysOnTop -Caption -DPIScale +HwndSwitchTT_id +E0x20
			Gui, SwitchTT:Color, %GuiTTBackCnColor%
			Gui, SwitchTT:Font, c%GuiTTCnColor% s%TT_Font_Size_Input%, %FontType%
			Gui, SwitchTT:Add,Text, x18 y3 HwndTT_Edit_Hwnd Center, %Display_En%
			ControlGetPos, , , Text_W, Text_H, , ahk_id %TT_Edit_Hwnd%
			global TT_W := Text_W+18
			global TT_H := Text_H+8
			WinSet, Transparent,%TT_Transparency_Input%, ahk_id %SwitchTT_id%
			WinSet, Region, 10-0 W%TT_W% H%TT_H% R5-5, ahk_id %SwitchTT_id%
			global TT_Shift_X_Real:=TT_Shift_X-TT_W-12
			global TT_Shift_Y_Real:=TT_Shift_Y-2-TT_H
		}
		If (TT_OnOff_Style=3 || TT_OnOff_Style=4){
			Gui, SwitchTT1:Destroy
			Gui, SwitchTT1:-SysMenu +ToolWindow +AlwaysOnTop -Caption -DPIScale +HwndSwitchTT_id1 +E0x20
			Gui, SwitchTT1:Color, %GuiTTBackCnColor%
			Gui, SwitchTT1:Font, c%GuiTTCnColor% s%TT_Font_Size_Fix%, %FontType%
			Gui, SwitchTT1:Add,Text, x18 y3 HwndTT_Edit_Hwnd1 Center, %Display_En%
			ControlGetPos, , , Text_W, Text_H, , ahk_id %TT_Edit_Hwnd1%
			global TT_W1 := Text_W+18
			global TT_H1 := Text_H+8
			WinSet, Transparent,%TT_Transparency_Fix%, ahk_id %SwitchTT_id1%
			WinSet, Region, 10-0 W%TT_W1% H%TT_H1% R5-5, ahk_id %SwitchTT_id1%
		}
	}
Return

TT_Display_KBL(KBLState,CapsLockState) { ; ��ʾ���뷨״̬-TT��ʽ
	If (TT_OnOff_Style=0 || WinExist("ahk_class #32768") || WinActive("ahk_group DisableTTShowAppList_ahk_group")){
		Gosub, Label_Hide_All
		Return
	}
	KBLMsg := CapsLockState!=0?"A":KBLState=0?Display_Cn:KBLState=1?Display_CnEn:Display_En
	TT_Shift_flag := 0
	If (TT_OnOff_Style=1){
		MouseGetPos, CaretX, CaretY	
	}Else{
		If (TT_OnOff_Style=3){
			Caret := getDisplayPos(TT_Pos_Coef_X,TT_Pos_Coef_Y,TT_W1,TT_H1)
			CaretX := Caret["x"],CaretY := Caret["y"]
			TT_Shift_flag := 1
		}Else{
			GetCaret(CaretX, CaretY)
			If (TT_OnOff_Style=2 && A_Cursor="IBeam" && CaretX=0 && CaretY=0)
				MouseGetPos, CaretX, CaretY
			Else If (TT_OnOff_Style=4 && CaretX=0 && CaretY=0){
				Caret := getDisplayPos(TT_Pos_Coef_X,TT_Pos_Coef_Y,TT_W1,TT_H1)
				CaretX := Caret["x"],CaretY := Caret["y"]
				TT_Shift_flag := 1
			}
		}
	}
	If (TT_Shift_flag=0){
		Gui, SwitchTT1:Hide
		Gosub, Label_Change_SwitchTT
		CaretX := CaretX+TT_Shift_X_Real, CaretY := CaretY+TT_Shift_Y_Real
		try Gui, SwitchTT:Show, x%CaretX% y%CaretY% NoActivate
	}Else{
		Gui, SwitchTT:Hide
		Gosub, Label_Change_SwitchTT
		try Gui, SwitchTT1:Show, x%CaretX% y%CaretY% NoActivate
	}
	SetTimer, Hide_TT, %TT_Display_Time%
	Return

	Hide_TT: ;����GUI
		SetTimer, Hide_TT, Off
		Gui, SwitchTT:Hide
		Gui, SwitchTT1:Hide
	Return

	Label_Change_SwitchTT: ; ����SwitchTT
		If (KBLState=0){
			If (TT_OnOff_Style!=3){
				Gui, SwitchTT:Color, %GuiTTBackCnColor%
				Gui, SwitchTT:Font, c%GuiTTCnColor%, %FontType%
			}
			If (TT_OnOff_Style=3 || TT_OnOff_Style=4){
				Gui, SwitchTT1:Color, %GuiTTBackCnColor%
				Gui, SwitchTT1:Font, c%GuiTTCnColor%, %FontType%
			}
		}Else{
			If (TT_OnOff_Style!=3){
				Gui, SwitchTT:Color, %GuiTTBackEnColor%
				Gui, SwitchTT:Font, c%GuiTTEnColor%, %FontType%
			}
			If (TT_OnOff_Style=3 || TT_OnOff_Style=4){
				Gui, SwitchTT1:Color, %GuiTTBackEnColor%
				Gui, SwitchTT1:Font, c%GuiTTEnColor%, %FontType%
			}
		}
		If (TT_OnOff_Style!=3){
			GuiControl, Text, %TT_Edit_Hwnd%, %KBLMsg%
			GuiControl, Font, %TT_Edit_Hwnd%
			Gui SwitchTT:+AlwaysOnTop
		}
		If (TT_OnOff_Style=3 || TT_OnOff_Style=4){
			GuiControl, Text, %TT_Edit_Hwnd1%, %KBLMsg%
			GuiControl, Font, %TT_Edit_Hwnd1%
			Gui SwitchTT:+AlwaysOnTop
		}
	Return
}

Tray_Display_KBL(KBL_Flag:=0,CapsLock_Flag:=0) { ; ��ʾ���뷨״̬-����ͼ�귽ʽ
	If (Tray_Display=0){
		Menu, Tray, NoIcon
	}Else If (Tray_Display_KBL=0){
		Menu, Tray, Icon, %A_AhkPath%
	}Else{
		try{
			If (KBL_Flag=0)
				If (CapsLock_Flag=1)
					Menu, Tray, Icon, HICON:*%ACNIcon%
				Else
					Menu, Tray, Icon, HICON:*%CNIcon%
			Else If (KBL_Flag=1)
				If (CapsLock_Flag=1)
					Menu, Tray, Icon, HICON:*%AENIcon%
				Else
					Menu, Tray, Icon, HICON:*%CNENIcon%
			Else If (KBL_Flag=2)
				If (CapsLock_Flag=1)
					Menu, Tray, Icon, HICON:*%AENIcon%
				Else
					Menu, Tray, Icon, HICON:*%ENIcon%
		}		
	}
}

Cur_Display_KBL(KBL_Flag:=0,CapsLock_Flag:=0,MonitorNum:=0) { ; ��ʾ���뷨״̬-����귽ʽ
	If (Cur_Launch!=1)
		Return
	If (KBL_Flag=0){
		If (CapsLock_Flag = 1){
			Cur_IBEAM := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][1], "Ptr")
			Cur_NORMAL := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][5], "Ptr")
		}Else{	
			Cur_IBEAM := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][3], "Ptr")
			Cur_NORMAL := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][7], "Ptr")
		}
	}Else{
		If (CapsLock_Flag = 1){
			Cur_IBEAM := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][2], "Ptr")
			Cur_NORMAL := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][6], "Ptr")
		}Else{
			Cur_IBEAM := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][4], "Ptr")
			Cur_NORMAL := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][8], "Ptr")
		}
	}
	DllCall("SetSystemCursor", "Ptr", Cur_IBEAM, "Int", OCR_IBEAM)
	DllCall("SetSystemCursor", "Ptr", Cur_NORMAL, "Int", OCR_NORMAL)
	If (ScriptIniting=1){
		Cur_APPSTARTING := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][9], "Ptr")
		Cur_WAIT := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][10], "Ptr")
		Cur_HAND := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][11], "Ptr")
		Cur_CROSS := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][12], "Ptr")
		Cur_HELP := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][13], "Ptr")
		Cur_NO := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][14], "Ptr")
		Cur_UP := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][15], "Ptr")
		Cur_SIZEALL := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][16], "Ptr")
		Cur_SIZENESW := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][17], "Ptr")
		Cur_SIZENS := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][18], "Ptr")
		Cur_SIZENWSE := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][19], "Ptr")
		Cur_SIZEWE := DllCall("LoadCursorFromFile", "Str",CurPathObjs[MonitorAreaObjects[MonitorNum][5]][20], "Ptr")
		DllCall("SetSystemCursor", "Ptr", Cur_APPSTARTING, "Int", OCR_APPSTARTING)
		DllCall("SetSystemCursor", "Ptr", Cur_WAIT, "Int", OCR_WAIT)
		DllCall("SetSystemCursor", "Ptr", Cur_HAND, "Int", OCR_HAND)
		DllCall("SetSystemCursor", "Ptr", Cur_CROSS, "Int", OCR_CROSS)
		DllCall("SetSystemCursor", "Ptr", Cur_HELP, "Int", OCR_HELP)
		DllCall("SetSystemCursor", "Ptr", Cur_NO, "Int", OCR_NO)
		DllCall("SetSystemCursor", "Ptr", Cur_UP, "Int", OCR_UP)		
		DllCall("SetSystemCursor", "Ptr", Cur_SIZEALL, "Int", OCR_SIZEALL)
		DllCall("SetSystemCursor", "Ptr", Cur_SIZENESW, "Int", OCR_SIZENESW)
		DllCall("SetSystemCursor", "Ptr", Cur_SIZENS, "Int", OCR_SIZENS)
		DllCall("SetSystemCursor", "Ptr", Cur_SIZENWSE, "Int", OCR_SIZENWSE)
		DllCall("SetSystemCursor", "Ptr", Cur_SIZEWE, "Int", OCR_SIZEWE)
	}
}

;-----------------------------------����ʼ�����ܡ�-----------------------------------------------
Label_Init_INI: ; ��ʼ�������ļ�INI
	FileAppend,[��������]`n, %INI%
	FileAppend,��������=0`n, %INI%
	FileAppend,����Ա����=1`n, %INI%
	FileAppend,�Զ��л�=1`n, %INI%
	FileAppend,Ĭ�����뷨=1`n, %INI%

	FileAppend,�л���ʾ=4`n, %INI%
	FileAppend,�л���ʾʱ��=1500`n, %INI%
	FileAppend,�л���ʾ���ִ�С=15,30`n, %INI%
	FileAppend,�л���ʾ͸����=235,180`n, %INI%
	FileAppend,�л���ʾƫ��=0,0`n, %INI%
	FileAppend,�л���ʾ�̶�λ��=50,30`n, %INI%

	FileAppend,����ͼ����ʾ=1`n, %INI%
	FileAppend,����ͼ����ʾ���뷨=1`n, %INI%
	FileAppend,����ͼ��˫��=2`n, %INI%

	FileAppend,���ָ����ʾ���뷨=1`n, %INI%
	FileAppend,���ָ���Ӧ�ֱ���=0`n, %INI%

	FileAppend,[�ȼ����δ����б�]`n, %INI%
	FileAppend,[�л����δ����б�]`n, %INI%
	FileAppend,[�л���ʾ���δ����б�]`n, %INI%
	FileAppend,�����л�=ahk_class MultitaskingViewFrame`n, %INI%
	FileAppend,[�����л����δ����б�]`n, %INI%
	FileAppend,TC�½��ļ���=ahk_class TCOMBOINPUT`n, %INI%
	FileAppend,TC����=ahk_class TFindFile`n, %INI%
	FileAppend,TC����=ahk_class TQUICKSEARCH`n, %INI%
	FileAppend,[����ؼ��л������б�]`n, %INI%
	FileAppend,Xshell=ahk_exe Xshell.exe`n, %INI%
	FileAppend,Steam=ahk_exe Steam.exe`n, %INI%
	FileAppend,�е��ʵ�=ahk_exe YoudaoDict.exe`n, %INI%

	FileAppend,[�ȼ�����]`n, %INI%
	FileAppend,��������Ĵ���=`n, %INI%
	FileAppend,�����Ӣ��(����)����=`n, %INI%
	FileAppend,�����Ӣ�����뷨����=`n, %INI%
	FileAppend,�Ƴ�����Ӣ�Ĵ���=`n, %INI%
	FileAppend,�л�����=`n, %INI%
	FileAppend,�л�Ӣ��(����)=`n, %INI%
	FileAppend,�л�Ӣ�����뷨=`n, %INI%
	FileAppend,�л���Ӣ��(����)=`n, %INI%
	FileAppend,�л���Ӣ�����뷨=`n, %INI%
	FileAppend,��ʾ��ǰ���뷨=`n, %INI%
	FileAppend,���õ�ǰ���뷨=`n, %INI%
	FileAppend,ֹͣ�Զ��л�=`n, %INI%
	FileAppend,��ȡ���뷨IME����=`n, %INI%

	FileAppend,[�����ȼ�]`n, %INI%
	FileAppend,��Shift=1`n, %INI%
	FileAppend,��Shift=2`n, %INI%
	FileAppend,��Ctrl=0`n, %INI%
	FileAppend,��Ctrl=0`n, %INI%
	FileAppend,��Alt=0`n, %INI%
	FileAppend,��Alt=0`n, %INI%

	FileAppend,[�߼�����]`n, %INI%
	FileAppend,�ڲ�����=..\RunAny\RunAnyConfig.ini`n, %INI%
	FileAppend,��ݼ�����=1`n, %INI%
	FileAppend,����������λ����ʾ���뷨״̬=1|ȫ�ִ���`n, %INI%
	FileAppend,����������ʾ���뷨״̬��Ч����=Code.exe`n, %INI%
	FileAppend,��ʱ�������뷨=60|�༭��`n, %INI%
	FileAppend,�л����ô�Сд=1`n, %INI%
	FileAppend,�����ַ�����=2|1`n, %INI%
	FileAppend,��ʾ��ɫ=333434|dfe3e3|02ecfb|ff0000`n, %INI%
	FileAppend,������ʾ����=KBLAutoSwitch��`%Ȩ��`%��``n`%����ʱ��`%``n�汾��`%�汾`%``n���°汾��`%���°汾`%``n�Զ��л�ͳ�ƣ�`%�Զ��л�����`%`n, %INI%
	FileAppend,�Զ�������=30`n, %INI%

	FileAppend,[�Զ��崰����]`n, %INI%
	FileAppend,1=ȫ�ִ���=0=AllGlobalWin=ȫ�ִ�����`n, %INI%
	FileAppend,2=�༭��=2=sublime_text.exe|Code.exe=�༭��������`n, %INI%
	FileAppend,3=�����ô�Сд��=1=RunAny_SearchBar ahk_exe RunAny.exe=�л����ڲ����ô�Сд`n, %INI%
	FileAppend,4=TC=2=ahk_exe TOTALCMD.exe|TotalCMD64.exe=TC`n, %INI%
	FileAppend,[�Զ������]`n, %INI%
	FileAppend,1=2=s-; |# =1=ahk��pyע���л�����`n, %INI%
	FileAppend,2=2=k-~Enter|~Esc=6=�س���Esc�л�Ӣ��`n, %INI%
	FileAppend,3=4=k-~F2|~F7|~^s=1=TC�л�����`n, %INI%
	FileAppend,4=4=k-~Enter|~Esc=6=TC�س���ESC�������뷨`n, %INI%

	FileAppend,[���Ĵ���]`n, %INI%
	FileAppend,win������=ahk_exe SearchApp.exe`n, %INI%
	FileAppend,OneNote for Windows 10=uwp  OneNote for Windows 10`n, %INI%

	FileAppend,[Ӣ�Ĵ���]`n, %INI%
	FileAppend,win����=ahk_class WorkerW ahk_exe explorer.exe`n, %INI%
	FileAppend,win����=ahk_class Progman ahk_exe explorer.exe`n, %INI%
	FileAppend,�ļ���Դ������=ahk_class CabinetWClass ahk_exe explorer.exe`n, %INI%
	FileAppend,cmd=ahk_exe cmd.exe`n, %INI%
	FileAppend,���������=ahk_exe taskmgr.exe`n, %INI%

	FileAppend,[Ӣ�����뷨����]`n, %INI%
	FileAppend,����ϸ��=ahk_exe deadcells.exe`n, %INI%
	FileAppend,���Ӻ�ʱ��=uwp ���Ӻ�ʱ��`n, %INI%

	FileAppend,[��Ϣ����]`n, %INI%
	FileAppend,�������������=2000-01-01 00:00:00`n, %INI%
Return

Label_Create_Tray: ; �����Ҽ����̲˵�
	Menu, Tray, NoStandard
	Menu, Tray, Add, �رղ˵�, Menu_Close
	Menu, Tray, Icon, �رղ˵�, % Ico_path["�رղ˵�"], % Ico_num["�رղ˵�"]
	Menu, Tray, Add, ������, gMenu_CheckUpdate
	Menu, Tray, Icon, ������, % Ico_path["������"], % Ico_num["������"]
	Menu, Tray, Add, �����ĵ�, gMenu_Help
	Menu, Tray, Icon, �����ĵ�, % Ico_path["�����ĵ�"], % Ico_num["�����ĵ�"]
	Menu, Tray, Add, ������ѡ��, Menu_Language
	Menu, Tray, Icon, ������ѡ��, % Ico_path["������ѡ��"], % Ico_num["������ѡ��"]
	Menu, Tray, Add 
	Menu, Tray, Add, ����, Menu_Settings_Gui
	Menu, Tray, Icon, ����, % Ico_path["����"], % Ico_num["����"]
	Menu, Tray, Add 
	Menu, Tray, Add, ����, Menu_About
	Menu, Tray, Icon, ����, % Ico_path["����"], % Ico_num["����"]
	Menu, Tray, Add 
	Menu, Tray, Add, ֹͣ, Menu_Stop
	Menu, Tray, Icon, ֹͣ, % Ico_path["ֹͣ"], % Ico_num["ֹͣ"]
	Menu, Tray, unCheck, ֹͣ
	Menu, Tray, Add, ����, Menu_Reload
	Menu, Tray, Icon, ����, % Ico_path["����"], % Ico_num["����"]
	Menu, Tray, Add, �˳�, Menu_Exit
	Menu, Tray, Icon, �˳�, % Ico_path["�˳�"], % Ico_num["�˳�"]
	If (Tray_Double_Click>0){
		Menu, Tray, Click, 2
		Switch Tray_Double_Click 
		{
			Case 1: Menu, Tray, Default ,������ѡ��
			Case 2: Menu, Tray, Default ,����
			Case 3: Menu, Tray, Default ,ֹͣ
		}	
	}
Return

;-----------------------------------���Ҽ��˵����ܡ�-----------------------------------------------
Menu_Close: ; �رղ˵�
	Gosub, Menu_Reload
Return

gMenu_CheckUpdate: ; ������
	AutoCheckOnceFlag := 0
	Gosub, Label_GetLatestAppInfo
	Gosub, Label_Update_LatestCheckDateTime
	If (���°汾="v0.0.0"){
		MsgBox, 49, %APPName%������, �޷���ȡ���°汾�������������������`n`n����ǰ��github���������ֶ����ظ���`n`nȷ��ǰ�������ĵ���
		IfMsgBox OK
			Gosub, gMenu_Help
		else
   			Return
	}Else{
		NewAppVersion := GetVersionComp(���°汾)
		OldAppVersion := GetVersionComp(APPVersion)
		If (NewAppVersion>OldAppVersion){
			MsgBox, 52, %APPName%������, ���µİ汾���Ը��£��Ƿ���£�`n`n���°汾��%���°汾%`n`n��ǰ�汾��v%APPVersion%
			IfMsgBox Yes
				Gosub, Label_Update_App
		}Else{
			MsgBox, 64, %APPName%������, ��ϲ���İ汾Ϊ���°汾��������£�`n`n���°汾��%���°汾%`n`n��ǰ�汾��v%APPVersion%
		}
	}
Return

gMenu_Help: ; �򿪰����ĵ�
	run, %�����ĵ�%
Return

Menu_Language: ; ��������ѡ��
	If (OSVersion<=7)
		Run,rundll32.exe shell32.dll`,Control_RunDLL input.dll
	Else
		Run,ms-settings:regionlanguage
Return

Menu_Settings_Gui: ; ����ҳ��Gui
	Critical On
	Gosub, Label_ReadCustomKBLWinGroup
	Gosub, Label_ReadExistEXEIcos
	Gosub, Label_ReadExistIcoStyles
	Gosub, Label_ReadExistCurStyles
	Gosub, Label_UpdateCheckDateTimeInterval
	Menu, Tray, Icon, %A_AhkPath%
	global EditSliderobj := Object()
	Edit_Hwnd:="",Slider_Hwnd:=""
	Gui_width_55 := 520
	tab_width_55 := Gui_width_55-20
	group_width_55 := tab_width_55-20
	global group_list_width_55 := tab_width_55-40
	text_width := 110
	left_margin := 12
	Gui, 55:Destroy
	Gui, 55:Default
	Gui, 55:Margin, 30, 20
	Gui, 55:Font, W400, Microsoft YaHei
	Gui, 55:Add, Tab3, x10 y10 w%tab_width_55% h593 vConfigTab +0x8000, ��������1|��������2|�ȼ�����|��Ӣ����|�߼�����|�߼�����
	
	Gui, 55:Tab, ��������1
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h69, ������������
	Gui, 55:Add, Text, xm+%left_margin% yp+30, ��������
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vAuto_Launch, %OnOffState%
	GuiControl, Choose, Auto_Launch, % Auto_Launch+1
	Gui, 55:Add, Text, x+82 yp+2 cred, ����Ȩ��
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vLaunch_Admin, ��ͨ|����Ա
	GuiControl, Choose, Launch_Admin, % Launch_Admin+1

	Gui, 55:Add, GroupBox, xm-10 y+26 w%group_width_55% h69, �����뷨�л�������
	Gui, 55:Add, Text, xm+%left_margin% yp+30 cred, �Զ��л�
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vAuto_Switch, %OnOffState%
	GuiControl, Choose, Auto_Switch, % Auto_Switch+1
	Gui, 55:Add, Text, x+70 yp+2 cred, Ĭ�����뷨
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vDefault_Keyboard, %KBLSwitchState%
	GuiControl, Choose, Default_Keyboard, % Default_Keyboard+1

	Gui, 55:Add, GroupBox, xm-10 y+26 w%group_width_55% h149, ���л���ʾ������
	Gui, 55:Add, Text, cred xm+%left_margin% yp+30, �л���ʾ
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vTT_OnOff_Style, �ر�|���λ��|����+���λ��|�̶�λ��|����+�̶�λ��
	GuiControl, Choose, TT_OnOff_Style, % TT_OnOff_Style+1
	Gui, 55:Add, Text, x+82 yp+2, ��ʾʱ��
	Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vTT_Display_Time, %TT_Display_Time%
	Gui, 55:Add, Text, x+10 yp+2, ����
	Gui, 55:Add, Text, xm+%left_margin% yp+40, ���ִ�С
	Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vTT_Font_Size, %TT_Font_Size%
	Gui, 55:Add, Text, x+10 yp+2, �� (����,�̶�)
	Gui, 55:Add, Text, x+59 yp, ͸����
	Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vTT_Transparency, %TT_Transparency%
	Gui, 55:Add, Text, x+10 yp-5, (0-255)`n(����,�̶�)
	Gui, 55:Add, Text, xm+%left_margin% yp+47, ��ʾƫ��
	Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vTT_Shift, %TT_Shift%
	Gui, 55:Add, Text, x+10 yp+2, (x,y) ���� (����)
	Gui, 55:Add, Text, x+35 yp, �̶�λ��
	Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vTT_Pos_Coef, %TT_Pos_Coef%
	Gui, 55:Add, Text, x+10 yp+2, (x,y) (0-100)

	Gui, 55:Add, GroupBox, xm-10 y+32 w%group_width_55% h109, ������ͼ�꡿����
	Gui, 55:Add, Text, cred xm+%left_margin% yp+30, ����ͼ��
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vTray_Display, �ر�|��ʾ
	GuiControl, Choose, Tray_Display, % Tray_Display+1
	Gui, 55:Add, Text, x+82 yp+2, ˫��ͼ��
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vTray_Double_Click, %TrayFuncState%
	GuiControl, Choose, Tray_Double_Click, % Tray_Double_Click+1
	Gui, 55:Add, Text, xm+left_margin-12 yp+43, ͼ�����뷨
	Gui, 55:Add, DropDownList, x+5 yp-3 w%text_width% vTray_Display_KBL, %OnOffState%
	GuiControl, Choose, Tray_Display_KBL, % Tray_Display_KBL+1
	Gui, 55:Add, Text, x+82 yp+3, ͼ����ʽ
	Gui, 55:Add, DropDownList, x+5 yp-3 w%text_width% vTray_Display_Style ggChange_Tray_Display_Style, %ExistIcoStyles%
	GuiControl, Choose, Tray_Display_Style, % TransformStateReverse(ExistIcoStyles,Tray_Display_Style)+1
	Gui, 55:Add, Picture, x+10 yp w24 h24 HwndTray_Display_Style_Pic_hwnd, % CNico_path
	Gosub, gChange_Tray_Display_Style

	Gui, 55:Add, GroupBox, xm-10 y+25 w%group_width_55% h109, �����ָ�롿����
	Gui, 55:Add, Text, cred xm+left_margin-12 yp+30, ������뷨
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vCur_Launch, %OnOffState%
	GuiControl, Choose, Cur_Launch, % Cur_Launch+1
	Gui, 55:Add, Text, x+82 yp+2, �����ʽ
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vCur_Launch_Style ggChange_Cur_Launch_Style, %ExistCurStyles%
	GuiControl, Choose, Cur_Launch_Style, % TransformStateReverse(ExistCurStyles,Cur_Launch_Style)+1
	Gui, 55:Add, Picture, x+10 yp w24 h24 HwndCur_Launch_Style_Pic_hwnd, % CurPathObj[7]
	Gosub, gChange_Cur_Launch_Style
	Gui, 55:Add, Text, xm+left_margin-12 yp+43, ���ֱ���
	Gui, 55:Add, DropDownList, x+5 yp-3 w%text_width% vCur_Size, �Զ�%ExistCurSize%
	GuiControl, Choose, Cur_Size, % !Cur_Size?1:getIndexDropDownList(ExistCurSize,Cur_Size)

	Gui, 55:Tab
	gui, 55:Font, underline
	Gui, 55:Add, Text, Cblue x30 y625  GgMenu_CheckUpdate, ������
	gui, 55:Font, Norm
	Gui, 55:Add, Button, Default w75 x110 y625 GgSet_OK, ȷ��
	Gui, 55:Add, Button, w75 x+20 yp G55GuiClose, ȡ��
	Gui, 55:Add, Button, w75 x+20 yp GgSet_ReSet, �ָ�Ĭ��
	gui, 55:Font, underline
	Gui, 55:Add, Text, Cblue x+20 yp-5  GgMenu_Config, �����ļ�
	Gui, 55:Add, Text, Cblue xp+60 yp GgMenu_Icos, ͼ���ļ�
	Gui, 55:Add, Text, Cblue xp-60 yp+20 GgMenu_Curs, ����ļ�
	Gui, 55:Add, Text, Cblue xp+60 yp GgMenu_Help, �����ĵ�
	Gui, 55:Font, norm , Microsoft YaHei

	Gui, 55:Tab, ��������2
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h310, �����Ρ����ã����зָ���
	Gui, 55:Add, Edit, xm yp+45 w%group_list_width_55% r3 vDisable_HotKey_App_List HwndDisableHotKey_hwnd, %Disable_HotKey_App_List%
	Gui, 55:Add, Text, cred xm yp-24, ���ȼ���
	Gui, 55:Add, Text, x+5 yp, ���δ����б�
	Gui, 55:Add, Button, w30 h20 x380 yp vvCurrentWin_Add_Disable_HotKey ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_Disable_HotKey ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_Disable_HotKey ggReset_Value, R
	Gui, 55:Add, Text, cred xm yp+95, ���Զ��л���
	Gui, 55:Add, Text, x+5 yp, ���δ����б�
	Gui, 55:Add, Button, w30 h20 x380 yp vvCurrentWin_Add_Disable_Switch ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_Disable_Switch ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_Disable_Switch ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+24 w%group_list_width_55% r3 vDisable_Switch_App_List HwndDisableSwitch_hwnd, %Disable_Switch_App_List%
	Gui, 55:Add, Text, cred xm yp+71, ���л���ʾ��
	Gui, 55:Add, Text, x+5 yp, ���δ����б�
	Gui, 55:Add, Button, w30 h20 x380 yp vvCurrentWin_Add_Disable_TTShow ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_Disable_TTShow ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_Disable_TTShow ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+24 w%group_list_width_55% r3 vDisable_TTShow_App_List HwndDisableTTShow_hwnd, %Disable_TTShow_App_List%

	Gui, 55:Add, GroupBox, xm-10 y+26 w%group_width_55% h223, �����ⴰ�ڡ����ã����зָ���
	Gui, 55:Add, Text, cred xm yp+21, �������л���
	Gui, 55:Add, Text, x+5 yp, ���δ����б������ֶ�������ӣ�һ����ϸ߼�����ʹ�ã�
	Gui, 55:Add, Button, w30 h20 x450 yp vvReset_No_TwiceSwitch ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+24 w%group_list_width_55% r3 vNo_TwiceSwitch_App_List HwndNoTwiceSwitch_hwnd, %No_TwiceSwitch_App_List%
	Gui, 55:Add, Text, cred xm yp+71, ������ؼ��л���
	Gui, 55:Add, Text, x+5 yp, �����б����������ӣ��л���Чʱʹ�ã�
	Gui, 55:Add, Button, w30 h20 x380 yp vvCurrentWin_Add_FocusControl ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_FocusControl ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_FocusControl ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+24 w%group_list_width_55% r3 vFocusControl_App_List HwndFocusControl_hwnd, %FocusControl_App_List%
	
	Gui, 55:Tab, �ȼ�����
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h110, �����ڡ�����Ƴ���ݼ�
	Gui, 55:Add, Text, xm+%left_margin% yp+22, %A_Space%�����`n���Ĵ���
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Add_To_Cn, %Hotkey_Add_To_Cn%
	Gui, 55:Add, Text, x+70 yp-6,  �����Ӣ��`n(����)����
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Add_To_CnEn, %Hotkey_Add_To_CnEn%
	Gui, 55:Add, Text, xm+left_margin-12 yp+35, �����Ӣ��`n���뷨����
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Add_To_En, %Hotkey_Add_To_En%
	Gui, 55:Add, Text, x+70 yp-6,  %A_Space%%A_Space%�Ƴ���`n��Ӣ�Ĵ���
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Remove_From_All, %Hotkey_Remove_From_All%

	Gui, 55:Add, GroupBox, xm-10 y+22 w%group_width_55% h192, �����뷨����ݼ�
	Gui, 55:Add, Text, xm+left_margin-12 yp+30, ��ʾ���뷨
	Gui, 55:Add, Hotkey, x+5 yp-2 w%text_width% vHotkey_Display_KBL, %Hotkey_Display_KBL%
	Gui, 55:Add, Text, x+70 yp+2, �л�������
	Gui, 55:Add, Hotkey, x+5 yp-2 w%text_width% vHotkey_Set_Chinese, %Hotkey_Set_Chinese%
	Gui, 55:Add, Text, xm+left_margin-12 yp+35, �л���Ӣ��`n%A_Space%%A_Space%(����)
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Set_ChineseEnglish, %Hotkey_Set_ChineseEnglish%
	Gui, 55:Add, Text, x+70 yp-6, �л���Ӣ��`n%A_Space%���뷨
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Set_English, %Hotkey_Set_English%
	Gui, 55:Add, Text, xm+left_margin-12 yp+35, �л���Ӣ��`n%A_Space%%A_Space%(����)
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Toggle_CN_CNEN, %Hotkey_Toggle_CN_CNEN%
	Gui, 55:Add, Text, x+70 yp-6, �л���Ӣ��`n%A_Space%���뷨
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Toggle_CN_EN, %Hotkey_Toggle_CN_EN%
	Gui, 55:Add, Text, xm+left_margin-12 yp+43, �������뷨
	Gui, 55:Add, Hotkey, x+5 yp-2 w%text_width% vHotkey_Reset_KBL, %Hotkey_Reset_KBL%


	Gui, 55:Add, GroupBox, xm-10 y+21 w%group_width_55% h69, ���Զ��л��������ݼ�
	Gui, 55:Add, Text, xm+%left_margin% yp+22, %A_Space%%A_Space%ֹͣ`n�Զ��л�
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Stop_KBLAS, %Hotkey_Stop_KBLAS%
	Gui, 55:Add, Text, x+70 yp-6, ��ȡ���뷨`n%A_Space%%A_Space%IME����
	Gui, 55:Add, Hotkey, x+5 yp+6 w%text_width% vHotkey_Get_KeyBoard, %Hotkey_Get_KeyBoard%

	Gui, 55:Add, GroupBox, xm-10 y+24 w%group_width_55% h158, �����⡿�ȼ�����ر����뷨�ڵ���Ӣ�л���ݼ�������Shift��
	temp := left_margin + 7
	Gui, 55:Add, Text, xm+%temp% yp+30 cred, ��Shift%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Left_Shift, %OperationState%
	GuiControl, Choose, Hotkey_Left_Shift, % Hotkey_Left_Shift+1
	Gui, 55:Add, Text, x+89 yp+2 cred, ��Shift%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Right_Shift, %OperationState%
	GuiControl, Choose, Hotkey_Right_Shift, % Hotkey_Right_Shift+1
	temp := left_margin + 12
	Gui, 55:Add, Text, xm+%temp% yp+43, ��Ctrl%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Left_Ctrl, %OperationState%
	GuiControl, Choose, Hotkey_Left_Ctrl, % Hotkey_Left_Ctrl+1
	Gui, 55:Add, Text, x+94 yp+2, ��Ctrl%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Right_Ctrl, %OperationState%
	GuiControl, Choose, Hotkey_Right_Ctrl, % Hotkey_Right_Ctrl+1
	temp := left_margin + 17
	Gui, 55:Add, Text, xm+%temp% yp+43, ��Alt%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Left_Alt, %OperationState%
	GuiControl, Choose, Hotkey_Left_Alt, % Hotkey_Left_Alt+1
	Gui, 55:Add, Text, x+99 yp+2, ��Alt%A_Space%
	Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vHotkey_Right_Alt, %OperationState%
	GuiControl, Choose, Hotkey_Right_Alt, % Hotkey_Right_Alt+1

	Gui, 55:Tab, ��Ӣ����
	group_list_width_55_KBLwin := group_list_width_55*0.75
	group_list_width_55_KBLwinGroup := group_list_width_55-group_list_width_55_KBLwin-10
	wingroupXpos := group_list_width_55_KBLwin+50
	wingroupAddButtonXpos := group_list_width_55_KBLwin-50-30
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h548, ����Ӣ�Ĵ��ڡ����ã��ֶ�����밴��ʾ����ʽ��
	Gui, 55:Add, Edit, xm yp+45 w%group_list_width_55_KBLwin% r5 vINI_CN HwndKBLWinsCN_hwnd, %INI_CN%
	Gui, 55:Add, Edit, +ReadOnly cgreen x+10 yp w%group_list_width_55_KBLwinGroup% r5 , %Custom_Win_Group_Cn%
	Gui, 55:Add, Text, cred xm yp-24, �����ġ�
	Gui, 55:Add, Text, x+5 yp, ����
	Gui, 55:Add, Button, w30 h20 x%wingroupAddButtonXpos% yp vvCurrentWin_Add_Cn ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_Cn ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_Cn ggReset_Value, R
	Gui, 55:Add, Text, x%wingroupXpos% yp cred, �������顿
	Gui, 55:Add, Text, cred xm yp+137, ��Ӣ�ġ�
	Gui, 55:Add, Text, x+5 yp, ���ڣ��������뷨��
	Gui, 55:Add, Button, w30 h20 x%wingroupAddButtonXpos% yp vvCurrentWin_Add_CnEn ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_CnEn ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_CnEn ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+22 w%group_list_width_55_KBLwin% r11 vINI_CNEN HwndKBLWinsCNEN_hwnd, %INI_CNEN%
	Gui, 55:Add, Edit, +ReadOnly cgreen x+10 yp w%group_list_width_55_KBLwinGroup% r11 , %Custom_Win_Group_CnEn%
	Gui, 55:Add, Text, cred xm yp+209, ��Ӣ�ġ�
	Gui, 55:Add, Text, x+5 yp, ���ڣ�Ӣ�����뷨��
	Gui, 55:Add, Button, w30 h20 x%wingroupAddButtonXpos% yp vvCurrentWin_Add_En ggCurrentWin_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vvCurrentWin_Sub_En ggCurrentWin_Sub, -
	Gui, 55:Add, Button, w30 h20 x+5 yp vvReset_En ggReset_Value, R
	Gui, 55:Add, Edit, xm yp+22 w%group_list_width_55_KBLwin% r7 vINI_EN HwndKBLWinsEN_hwnd, %INI_EN%
	Gui, 55:Add, Edit, +ReadOnly cgreen x+10 yp w%group_list_width_55_KBLwinGroup% r7 , %Custom_Win_Group_En%

	Gui, 55:Tab, �߼�����
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h275, ���Զ��塿�����飨˫���༭�鿴��|�ָ�����������ݣ�
	Gui, 55:Add, ListView, Count1 vahkGroupWin ggAdvanced_Config xm yp+22 r10 w%group_list_width_55%, ���|������|״̬|����|˵��
	Gui, 55:Add, Button, w30 h20 xm+380 yp-25 vButton1 ggAdvanced_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vButton2 ggAdvanced_Remove, -
		ListViewUpdate_Custom_Win_Group(Custom_Win_Group)

	Gui, 55:Add, GroupBox, xm-10 y+277 w%group_width_55% h254, �Զ��������˫���༭�鿴��|�ָ������ִ����ȼ���
	Gui, 55:Add, ListView, Count1 vCustomOperation ggAdvanced_Config xm yp+22 r9 w%group_list_width_55%, ���|������|���ִ�(s-)���ȼ�(k-)|����|˵��
	Gui, 55:Add, Button, w30 h20 xm+380 yp-25 vButton3 ggAdvanced_Add, +
	Gui, 55:Add, Button, w30 h20 x+5 yp vButton4 ggAdvanced_Remove, -
		ListViewUpdate_Custom_Hotstring(Custom_Hotstring)

	Gui, 55:Tab, �߼�����
	Gui, 55:Add, GroupBox, xm-10 y+10 w%group_width_55% h548, ���߼������ã�˫���༭�鿴��
	Gui, 55:Add, ListView, Count3 vAdvancedConfig ggAdvanced_Config xm yp+22 r23 w%group_list_width_55%, ���|��������|״̬|ֵ|˵��
		LV_Add(, 1, "�ڲ�����", openExtRunList_num, Open_Ext,"-�ڲ������ļ�·�������ڴ������ļ���·����`n-֧�����·��������RA[RunAnyConfig.ini]����������Ӣ����-�Ƴ�����������RA��·����ʾͼ�꣩")
		LV_Add(, 2, "��ݼ�����", Outer_InputKey_Compatible, Outer_InputKey_Compatible,"-����ڿ�ݼ����ݣ�`n0������������shift�ֱ��Ӧ��Ӣ�ĳ�����`n1�������ڵ�shift�л���Ӣ�ĳ������������뷨����Ӱ����Ӣ�ķ�������")
		LV_Add(, 3, "����������λ����ʾ���뷨״̬", Left_Mouse_ShowKBL_State, Left_Mouse_ShowKBL,"-��ָ����������������ʾ���뷨��`n1.����1Ϊ���أ�����2Ϊ��Ч������`n2.����ʹ��|�ָ�")
		LV_Add(, 4, "����������ʾ���뷨״̬��Ч����", Left_Mouse_ShowKBL_State, Left_Mouse_ShowKBL_Up,"-��ָ����������������ʾ���뷨ʱ��ʹ�����������Ӧ��`n����Ϊ���ڻ򴰿���")
		LV_Add(, 5, "��ʱ�������뷨", "��", SetTimer_Reset_KBL,"-�޲����̶�ʱ���������뷨���룩��`n1.����1Ϊʱ�䣬����2Ϊ������`n2.����ʹ��|�ָ�")
		LV_Add(, 6, "�л����ô�Сд", TransformState(DefaultCapsLockState,Reset_CapsLock_State), Reset_CapsLock,"-�л����뷨���Զ����ô�Сд��`n1.����1Ϊ��Сд״̬��0Ϊ�����ã�1ΪСд��2Ϊ��д��������2Ϊ���δ����飬�ô����齫����Ч`n2.����ʹ��|�ָ�")
		LV_Add(, 7, "�����ַ�����", Enter_Inputing_ContentObj.Count(), Enter_Inputing_Content,"-�������뷨״̬��������������ַ�����`n-��ر����뷨shift����������ڿ�ݼ��л���`n1.����1��ʾ����ʽ������0��ʾʹ�����뷨����1��ʾ�����ַ���2��ʾ�����ַ���3��ʾ������һ����ѡ����`n2.����2��ʾ�����л���ݼ��Ƿ�����`nĿǰ��֧�����뷨���ѹ����뷨��QQ������뷨��QQƴ�����뷨���������뷨���������")
		LV_Add(, 8, "��ʾ��ɫ", GuiTTColorObj.Count(), GuiTTColor,"-�л���ʾ��ɫ���ã�`n�����ĸ�������|�����������ı���ɫ|Ӣ�ı���ɫ|����������ɫ|Ӣ��������ɫ")
		LV_Add(, 9, "������ʾ����", StrSplit(TrayTipContent, "``n").Count(), StrReplace(TrayTipContent, "``n", "`n"),"-������ʾ���ݣ�`n1.��������ʹ���ڲ�������ahk������winϵͳ����`n2.����ʹ�ðٷֺŰ�����%������%��������������鿴�����ĵ�")
		LV_Add(, 10, "�Զ�������", CheckDateTimeInterval " ��", AutoCheckUpdate,"-�Զ������£�`n0��ʾ�������£���0��ʾ�������`n״̬��ʾ�����ϴμ������Ѿ�������")
		LV_ModifyCol(1,group_list_width_55*0.08 " Integer Center")
		LV_ModifyCol(2,group_list_width_55*0.22)
		LV_ModifyCol(3,group_list_width_55*0.08 " Integer Center")
		LV_ModifyCol(4,group_list_width_55*0.38)
		LV_ModifyCol(5,group_list_width_55*0.235)

	GuiTitleContent := A_IsAdmin=1?"������Ա��":"���ǹ���Ա��"
	Gui, 55:Show,w%Gui_width_55%, ���ã�%APPName% v%APPVersion%%GuiTitleContent%
	Critical off
Return

Menu_About: ; ����ҳ��Gui
	If (AutoCheckOnceFlag=1)
		Gosub, Label_GetLatestAppInfo
	Critical On
	Menu, Tray, Icon, %A_AhkPath%
	Gui, 99:Destroy
	Gui, 99:Color, FFFFFF
	Gui, 99:Add, ActiveX, x0 y0 w700 h570 voWB, shell explorer
	oWB.Navigate("about:blank")
	vHtml = 
	(
		<html>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<title>APPName</title>
			<body style="font-family:Microsoft YaHei">
				<h2 align="center">��%APPName%��</h2>
				<h3 align="center">�Զ��л����뷨 v%APPVersion%</h3>
				<b>���°汾��%���°汾%</b>
				<h4>�����ɫ</h4>
				<ol>
				  <li>���ݳ��򴰿��л���Ӣ�����뷨</li>
				  <li>�����л���ʾ������ͼ�ꡢ���ָ��������ʾ���뷨״̬����</li>
				  <li>���ÿ�ݼ��������ָ������</li>
				</ol>
				<h4>ʹ�ý���</h4>
				<ol>
				  <li>����ʹ��win10������ϵͳ</li>
				  <li>�����ġ�ʹ�á��ѹ����뷨�����뷨���ǹ�棩</li>
				  <li>�����ġ����뷨ȡ����<kbd>Shift</kbd>���л���Ӣ�ģ��������-�ȼ�����-�����⡿�ȼ�������<kbd>Shift</kbd>�л����뷨����</li>
				</ol>
				<h4>����˵��</h4>
				<ol>
				  <li style="color:red">�������Ӣ��״̬ʶ��������������Ҫ����<kbd>Shift</kbd>�ֱ������л����ܣ����齫���뷨��<kbd>Shift</kbd>�л��رգ������-�ȼ�����-�����⡿�ȼ�������<kbd>Shift</kbd>�л����뷨����</li>
				  <li>��֧�ַ���Ӣ�����뷨�л�</li>
				  <li>���κ�������Լ��롾����Ⱥ��һ�������ۣ����߲鿴�·���Ѷ�ĵ�</li>
				</ol>
			</body>
		</html>
	)
	oWB.document.write(vHtml)
	oWB.Refresh()
	Gui, 99:Font, s11 Bold, Microsoft YaHei
	Gui, 99:Add, Link, xm+18 y+10, ����Ⱥ��<a href="%����Ⱥ%">%����Ⱥ��Ϣ%</a>
	Gui, 99:Add, Link, xm+18 y+10, �����ĵ���<a href="%�����ĵ�%">%�����ĵ�%</a>
	Gui, 99:Add, Link, xm+18 y+10, github��ַ��<a href="%github��ַ%">%github��ַ%</a>
	Gui, 99:Add, Link, xm+18 y+10, ���ص�ַ��<a href="%���ص�ַ%">%���ص�ַ%  ��ȡ�룺%���ص�ַ��ȡ��%</a>
	Gui, 99:Add, Link, xm+18 y+10, RunAny������<a href="https://hui-zz.gitee.io/runany/#/">https://hui-zz.gitee.io/runany/#/</a>
	Gui, 99:Add, Link, xm+18 y+10, RunAny����Ⱥ��<a href="https://jq.qq.com/?_wv=1027&k=445Ug7u">246308937��RunAny��������һ�����ݡ�</a>
	Gui, 99:Add, Link, xm+18 y+10, AHK������̳��<a href="https://www.autoahk.com/">https://www.autoahk.com/</a>
	Gui, 99:Font
	Critical Off
	GuiTitleContent := A_IsAdmin=1?"������Ա��":"���ǹ���Ա��"
	Gui, 99:Show, AutoSize Center, ���ڣ�%APPName% v%APPVersion%%GuiTitleContent%
return

Menu_Stop: ; ֹͣ�ű�
	If (A_IsSuspended){
		OnMessage(shell_msg_num, "shellMessage")
		Gosub, UnSuspendedApp
	}Else{
		OnMessage(shell_msg_num, "")
		Gosub, SuspendedApp
	}
Return

Menu_Reload: ; �����ű�
	try Reload
	Sleep, 1000
	Run, %A_AhkPath%%A_Space%"%A_ScriptFullPath%"
	ExitApp
Return

Menu_Exit: ; �˳��ű�
	ExitApp
Return

Label_Hide_All: ; ��������Gui��TT
	Gui, SwitchTT:Hide
	Gui, SwitchTT1:Hide
Return

SuspendedApp: ; ����ű�
	try Menu, Tray, Rename, ֹͣ, �ָ�
	try Menu, Tray, Check, �ָ�
	try Gosub, Label_Hide_All
	Suspend, On
Return

UnSuspendedApp: ; �ָ�����ű�
	try Menu, Tray, Rename, �ָ�, ֹͣ
	try Menu, Tray, UnCheck, ֹͣ
	gosub, Reset_KBL
	Suspend, Off
Return

;-----------------------------------������ҳ�湦�ܡ�-----------------------------------------------
gSet_OK: ; ����ȷ�ϰ�ť����
	Critical On
	Thread, NoTimers,True
	Gui, Submit
	FileDelete, %INI%
	Auto_Launch := TransformStateReverse(OnOffState,Auto_Launch)
	Launch_Admin := Launch_Admin="��ͨ"?0:1
	Auto_Switch := TransformStateReverse(OnOffState,Auto_Switch)
	Default_Keyboard := TransformStateReverse(KBLSwitchState,Default_Keyboard)

	TT_OnOff_Style := TT_OnOff_Style="�ر�"?0:TT_OnOff_Style="���λ��"?1:TT_OnOff_Style="����+���λ��"?2:TT_OnOff_Style="�̶�λ��"?3:4

	Tray_Display := Tray_Display="�ر�"?0:1
	Tray_Display_KBL := TransformStateReverse(OnOffState,Tray_Display_KBL)
	Tray_Double_Click := TransformStateReverse(TrayFuncState,Tray_Double_Click)

	Cur_Launch := TransformStateReverse(OnOffState,Cur_Launch)
	Cur_Size := Cur_Size="�Զ�"?0:Cur_Size

	Hotkey_Left_Shift := TransformStateReverse(OperationState,Hotkey_Left_Shift)
	Hotkey_Right_Shift := TransformStateReverse(OperationState,Hotkey_Right_Shift)
	Hotkey_Left_Ctrl := TransformStateReverse(OperationState,Hotkey_Left_Ctrl)
	Hotkey_Right_Ctrl := TransformStateReverse(OperationState,Hotkey_Right_Ctrl)
	Hotkey_Left_Alt := TransformStateReverse(OperationState,Hotkey_Left_Alt)
	Hotkey_Right_Alt := TransformStateReverse(OperationState,Hotkey_Right_Alt)

	IniWrite, %Auto_Launch%, %INI%, ��������, ��������
	IniWrite, %Launch_Admin%, %INI%, ��������, ����Ա����
	IniWrite, %Auto_Switch%, %INI%, ��������, �Զ��л�
	IniWrite, %Default_Keyboard%, %INI%, ��������, Ĭ�����뷨

	IniWrite, %TT_OnOff_Style%, %INI%, ��������, �л���ʾ
	IniWrite, %TT_Display_Time%, %INI%, ��������, �л���ʾʱ��
	IniWrite, %TT_Font_Size%, %INI%, ��������, �л���ʾ���ִ�С
	IniWrite, %TT_Transparency%, %INI%, ��������, �л���ʾ͸����
	IniWrite, %TT_Shift%, %INI%, ��������, �л���ʾƫ��
	IniWrite, %TT_Pos_Coef%, %INI%, ��������, �л���ʾ�̶�λ��
	
	If (Tray_Display=0){
		MsgBox, 305, �Զ��л����뷨 KBLAutoSwitch, ͼ�����غ��޷�������ҳ�棬����ͨ���޸������ļ���KBLAutoSwitch.ini��-������ͼ����ʾ=1���ָ���`nȷ��Ҫ����ͼ����
		IfMsgBox, OK
			IniWrite, %Tray_Display%, %INI%, ��������, ����ͼ����ʾ
	}Else{
		IniWrite, %Tray_Display%, %INI%, ��������, ����ͼ����ʾ
	}
	IniWrite, %Tray_Double_Click%, %INI%, ��������, ����ͼ��˫��
	IniWrite, %Tray_Display_KBL%, %INI%, ��������, ����ͼ����ʾ���뷨
	IniWrite, %Tray_Display_Style%, %INI%, ��������, ����ͼ����ʽ
	IniWrite, %Cur_Launch%, %INI%, ��������, ���ָ����ʾ���뷨
	IniWrite, %Cur_Launch_Style%, %INI%, ��������, ���ָ����ʽ
	IniWrite, %Cur_Size%, %INI%, ��������, ���ָ���Ӧ�ֱ���

	IniWrite, % Trim(Disable_HotKey_App_List, " `t`n"), %INI%, �ȼ����δ����б�
	IniWrite, % Trim(Disable_Switch_App_List, " `t`n"), %INI%, �л����δ����б�
	IniWrite, % Trim(Disable_TTShow_App_List, " `t`n"), %INI%, �л���ʾ���δ����б�
	IniWrite, % Trim(No_TwiceSwitch_App_List, " `t`n"), %INI%, �����л����δ����б�
	IniWrite, % Trim(FocusControl_App_List, " `t`n"), %INI%, ����ؼ��л������б�

	IniWrite, %Hotkey_Add_To_Cn%, %INI%, �ȼ�����, ��������Ĵ���
	IniWrite, %Hotkey_Add_To_CnEn%, %INI%, �ȼ�����, �����Ӣ��(����)����
	IniWrite, %Hotkey_Add_To_En%, %INI%, �ȼ�����, �����Ӣ�����뷨����
	IniWrite, %Hotkey_Remove_From_All%, %INI%, �ȼ�����, �Ƴ�����Ӣ�Ĵ���

	IniWrite, %Hotkey_Set_Chinese%, %INI%, �ȼ�����, �л�����
	IniWrite, %Hotkey_Set_ChineseEnglish%, %INI%, �ȼ�����, �л�Ӣ��(����)
	IniWrite, %Hotkey_Set_English%, %INI%, �ȼ�����, �л�Ӣ�����뷨
	IniWrite, %Hotkey_Toggle_CN_CNEN%, %INI%, �ȼ�����, �л���Ӣ��(����)
	IniWrite, %Hotkey_Toggle_CN_EN%, %INI%, �ȼ�����, �л���Ӣ�����뷨
	IniWrite, %Hotkey_Display_KBL%, %INI%, �ȼ�����, ��ʾ��ǰ���뷨
	IniWrite, %Hotkey_Reset_KBL%, %INI%, �ȼ�����, ���õ�ǰ���뷨

	IniWrite, %Hotkey_Stop_KBLAS%, %INI%, �ȼ�����, ֹͣ�Զ��л�
	IniWrite, %Hotkey_Get_KeyBoard%, %INI%, �ȼ�����, ��ȡ���뷨IME����

	IniWrite, %Hotkey_Left_Shift%, %INI%, �����ȼ�, ��Shift
	IniWrite, %Hotkey_Right_Shift%, %INI%, �����ȼ�, ��Shift
	IniWrite, %Hotkey_Left_Ctrl%, %INI%, �����ȼ�, ��Ctrl
	IniWrite, %Hotkey_Right_Ctrl%, %INI%, �����ȼ�, ��Ctrl
	IniWrite, %Hotkey_Left_Alt%, %INI%, �����ȼ�, ��Alt
	IniWrite, %Hotkey_Right_Alt%, %INI%, �����ȼ�, ��Alt

	Gui, ListView, AdvancedConfig
	LV_ModifyCol(1,"Sort")
	Loop, % LV_GetCount()
	{
		LV_GetText(OutputVar, A_Index , 4)
		OutputVar := StrReplace(Trim(OutputVar, "|"), "`n", "``n")
		Switch A_Index
		{
			Case 1: IniWrite, %OutputVar%, %INI%, �߼�����, �ڲ�����
			Case 2: IniWrite, %OutputVar%, %INI%, �߼�����, ��ݼ�����
			Case 3: IniWrite, %OutputVar%, %INI%, �߼�����, ����������λ����ʾ���뷨״̬
			Case 4: IniWrite, %OutputVar%, %INI%, �߼�����, ����������ʾ���뷨״̬��Ч����
			Case 5: IniWrite, %OutputVar%, %INI%, �߼�����, ��ʱ�������뷨
			Case 6: IniWrite, %OutputVar%, %INI%, �߼�����, �л����ô�Сд
			Case 7: IniWrite, %OutputVar%, %INI%, �߼�����, �����ַ�����
			Case 8: IniWrite, %OutputVar%, %INI%, �߼�����, ��ʾ��ɫ
			Case 9: IniWrite, %OutputVar%, %INI%, �߼�����, ������ʾ����
			Case 10: IniWrite, %OutputVar%, %INI%, �߼�����, �Զ�������
		}
	}

	Gui, ListView, ahkGroupWin
	SetListViewData("�Զ��崰����")

	Gui, ListView, CustomOperation
	SetListViewData("�Զ������")

	IniWrite, % Trim(INI_CN, " `t`n"), %INI%, ���Ĵ���
	IniWrite, % Trim(INI_CNEN, " `t`n"), %INI%, Ӣ�Ĵ���
	IniWrite, % Trim(INI_EN, " `t`n"), %INI%, Ӣ�����뷨����

	IniWrite, %LatestCheckDateTime%, %INI%, ��Ϣ����, �������������

	gosub, Menu_Reload
return

gSet_ReSet: ; ���ð�ť�Ĺ���
	MsgBox, 49, ������������,�˲�����ɾ������KBLAutoSwitch�������ã�ȷ��ɾ��������
	IfMsgBox Ok
	{
		RegDelete, HKEY_CURRENT_USER, Software\KBLAutoSwitch
		FileDelete, %INI%
		gosub, Menu_Reload
	}
return

gMenu_Config: ; �������ļ�����
	FilePathRun(INI)
Return

gMenu_Icos: ; ��ͼ���ļ�·��
	FilePathRun(A_ScriptDir "\Icos\" Tray_Display_Style)
Return

gMenu_Curs: ; �����ָ���ļ�·��
	FilePathRun(A_ScriptDir "\Curs\" Cur_Launch_Style "\" WindowsHeight)
Return

gReset_Value: ; ����Ĭ��ֵ
	Switch A_GuiControl
	{
		Case "vReset_Disable_HotKey":tempVar:="",Hwnd:=DisableHotKey_hwnd
		Case "vReset_Disable_Switch":tempVar:="",Hwnd:=DisableSwitch_hwnd
		Case "vReset_Disable_TTShow":tempVar:="�����л�=ahk_class MultitaskingViewFrame",Hwnd:=DisableTTShow_hwnd
		Case "vReset_No_TwiceSwitch":tempVar:="TC�½��ļ���=ahk_class TCOMBOINPUT`nTC����=ahk_class TFindFile`nTC����=ahk_class TQUICKSEARCH",Hwnd:=NoTwiceSwitch_hwnd
		Case "vReset_FocusControl":tempVar:="Xshell=ahk_exe Xshell.exe`nSteam=ahk_exe Steam.exe`nYoudaoDict=ahk_exe YoudaoDict.exe",Hwnd:=FocusControl_hwnd
		
		Case "vReset_Cn":tempVar:="win������=ahk_exe SearchApp.exe`nOneNote for Windows 10=uwp  OneNote for Windows 10",Hwnd:=KBLWinsCN_hwnd
		Case "vReset_CnEn":tempVar:="win����=ahk_class WorkerW ahk_exe explorer.exe`nwin����=ahk_class Progman ahk_exe explorer.exe`n�ļ���Դ������=ahk_class CabinetWClass ahk_exe explorer.exe`ncmd=ahk_exe cmd.exe`n���������=ahk_exe taskmgr.exe",Hwnd:=KBLWinsCNEN_hwnd
		Case "vReset_En":tempVar:="����ϸ��=ahk_exe deadcells.exe`n���Ӻ�ʱ��=uwp ���Ӻ�ʱ��",Hwnd:=KBLWinsEN_hwnd
	}
	GuiControl,, %Hwnd%, %tempVar%
Return

gChange_Tray_Display_Style: ; �������ͼ��
	GuiControlGet, OutputVar,, Tray_Display_Style
	GuiControl,, %Tray_Display_Style_Pic_hwnd%, %A_ScriptDir%\Icos\%OutputVar%\%SystemUsesLightTheme_Str%_Cn.ico
Return

gChange_Cur_Launch_Style: ; ������ָ��
	GuiControlGet, OutputVar,, Cur_Launch_Style
	ExistCurSize_Show := ""
	Loop Files, %A_ScriptDir%\Curs\%OutputVar%\*, D
		ExistCurSize_Show := ExistCurSize_Show "|" A_LoopFileName
	If (ExistCurSize_Show="")
		CurSize_Show := 0
	Else
		CurSize_Show := StrSplit(ExistCurSize_Show, "|")[2]
	GuiControl,, Cur_Size, |�Զ�%ExistCurSize_Show%
	GuiControl, Choose, Cur_Size, % !Cur_Size?1:!getIndexDropDownList(ExistCurSize_Show,Cur_Size)?1:getIndexDropDownList(ExistCurSize_Show,Cur_Size)
	GuiControl,, %Cur_Launch_Style_Pic_hwnd%, % getCurPath(OutputVar,CurSize_Show,"NORMAL_Cn")
Return

gCurrentWin_Add: ; ��ӵ�ǰ���д�����KBL
	global CurrentWin_AddFlag := A_GuiControl
	Switch CurrentWin_AddFlag
	{
		Case "vCurrentWin_Add_Cn":GuiControlGet, KBLWins,, %KBLWinsCN_hwnd%
		Case "vCurrentWin_Add_CnEn":GuiControlGet, KBLWins,, %KBLWinsCNEN_hwnd%
		Case "vCurrentWin_Add_En":GuiControlGet, KBLWins,, %KBLWinsEN_hwnd%
		Case "vCurrentWin_Add_Disable_HotKey":GuiControlGet, KBLWins,, %DisableHotKey_hwnd%
		Case "vCurrentWin_Add_Disable_Switch":GuiControlGet, KBLWins,, %DisableSwitch_hwnd%
		Case "vCurrentWin_Add_Disable_TTShow":GuiControlGet, KBLWins,, %DisableTTShow_hwnd%
		Case "vCurrentWin_Add_FocusControl":GuiControlGet, KBLWins,, %FocusControl_hwnd%
	}
	Menu, Menu_KBLWin, Add, Item1,Label_Return
	Menu, Menu_KBLWin, DeleteAll
	Menu, Menu_KBLWin, Add, --ȡ��--����ӣ�, Label_Return
	Try Menu, Menu_KBLWin, Icon, --ȡ��--����ӣ�,shell32.dll,132,24
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows off
	NoRepeatObj := Object()
	WinGet windows, List
	Loop %windows%
	{
		id := windows%A_Index%
		item_key_val := getINIItem("ahk_id " id)
		item_key := item_key_val[0]
		item_val := item_key_val[1]
		item_regex := item_key_val[2]
		If NoRepeatObj.HasKey(item_val)
			Continue
		If IsHasSameRegExStr(KBLWins,item_regex)
			Continue
		if AddMenu_KBLWin(id,item_key)
			NoRepeatObj[item_val] := 1
	}
	GuiControlGet, ControlHwnd, Hwnd, %A_GuiControl%
    ControlGetPos, x, y, w, h, ,ahk_id %ControlHwnd%
	Menu, Menu_KBLWin, Show,% x,% y+h+2
	DetectHiddenWindows %Prev_DetectHiddenWindows%
Return

gCurrentWin_Sub: ; ɾ�����д���
	global CurrentWin_SubFlag := A_GuiControl
	Switch CurrentWin_SubFlag
	{
		Case "vCurrentWin_Sub_Cn":GuiControlGet, KBLWins,, %KBLWinsCN_hwnd%
		Case "vCurrentWin_Sub_CnEn":GuiControlGet, KBLWins,, %KBLWinsCNEN_hwnd%
		Case "vCurrentWin_Sub_En":GuiControlGet, KBLWins,, %KBLWinsEN_hwnd%
		Case "vCurrentWin_Sub_Disable_HotKey":GuiControlGet, KBLWins,, %DisableHotKey_hwnd%
		Case "vCurrentWin_Sub_Disable_Switch":GuiControlGet, KBLWins,, %DisableSwitch_hwnd%
		Case "vCurrentWin_Sub_Disable_TTShow":GuiControlGet, KBLWins,, %DisableTTShow_hwnd%
		Case "vCurrentWin_Sub_FocusControl":GuiControlGet, KBLWins,, %FocusControl_hwnd%
	}
	Menu, Menu_KBLWin, Add, Item1,Label_Return
	Menu, Menu_KBLWin, DeleteAll
	Menu, Menu_KBLWin, Add, --ȡ��--���Ƴ���, Label_Return
	Try Menu, Menu_KBLWin, Icon, --ȡ��--���Ƴ���,shell32.dll,132,24
	Loop, parse, KBLWins, `n, `r
	{
		If (A_LoopField="")
			Continue
		If (euqalPos := InStr(A_LoopField, "=")){
			ReadyKey := SubStr(A_LoopField,1,euqalPos-1)
			ReadyValue := SubStr(A_LoopField,euqalPos+1)
		}Else{
			ReadyKey := ""
			ReadyValue := A_LoopField
		}
		If (SubStr(ReadyValue, -3)=".exe" and !InStr(ReadyValue, "ahk_exe"))
			ReadyValue := "ahk_exe " ReadyValue
		WinGet, IcoPath, ProcessPath, %ReadyValue%
		If (IcoPath=""){
			RegExMatch(ReadyValue, "ahk_exe (.*\.exe)", SubPat)
			IcoPath := getExeIcoPath(SubPat1)
		}
		Menu, Menu_KBLWin, Add, %A_LoopField%, Label_Sub_KBLWin
		If (IcoPath) {
			IcoPath := StrSplit(IcoPath, ","),IcoNum := IcoPath[2],IcoPath := IcoPath[1]
			Try Menu, Menu_KBLWin, Icon, %A_LoopField%, %IcoPath%,%IcoNum%,32
			Catch
				Menu, Menu_KBLWin, Icon, %A_LoopField%,shell32.dll,3,32
		}Else
			Menu, Menu_KBLWin, Icon, %A_LoopField%,shell32.dll,3,32
	}
	GuiControlGet, ControlHwnd, Hwnd, %A_GuiControl%
    ControlGetPos, x, y, w, h, ,ahk_id %ControlHwnd%
	Menu, Menu_KBLWin, Show,% x,% y+h+2
Return

gAdvanced_Add: ; �Զ��崰�����
	ButtonNum := SubStr(A_GuiControl,7)
	If (ButtonNum=1)
		Gui, ListView, ahkGroupWin
	Else If (ButtonNum=3)
		Gui, ListView, CustomOperation
	RunRowNumber := LV_GetCount()+1
	ACvar1 := RunRowNumber,ACvar2 := ACvar3 := ACvar4 := ACvar5 := ""
	If (ButtonNum=1){
		gosub, Label_ahkGroupWin_Var
		Showvar := "��Ӵ���"
		NewOrder := getLVNewOrder()
	}
	Else If (ButtonNum=3){
		gosub, Label_CustomOperation_Var
		Showvar := "��Ӳ���"
		NewOrder := getLVNewOrder()
	}
	gosub, Menu_AdvancedConfigEdit_Gui
Return

gAdvanced_Remove: ; �Զ��崰��ɾ��
	ButtonNum := SubStr(A_GuiControl,7)
	If (ButtonNum=2)
		Gui, ListView, ahkGroupWin
	Else If (ButtonNum=4)
		Gui, ListView, CustomOperation
	Loop
	{
	    RowNumber := LV_GetNext(RowNumber)  ; ��ǰһ���ҵ���λ�ú��������.
	    if not RowNumber  ; ���淵����, ����ѡ������Ѿ����ҵ���.
	        break
	    LV_Delete(RowNumber)
	}
	gosub, Label_Update_ListView
Return

99GuiClose: ; �ر�GUI�¼�
	gosub,Menu_Reload
Return

55GuiClose: ; �ر�GUI�¼�
	gosub,Menu_Reload
return

ListViewUpdate_Custom_Win_Group(Custom_Win_Group) { ; ����Custom_Win_Group����
	Gui, ListView, ahkGroupWin
	LV_Delete()
	Loop, parse, Custom_Win_Group, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		LV_Add(, MyVar[1], MyVar[2], TransformState(ListViewKBLState,MyVar[3]), MyVar[4],MyVar[5])
	}
	LV_ModifyCol(1,group_list_width_55*0.08 " Integer Center")
	LV_ModifyCol(2,group_list_width_55*0.17)
	LV_ModifyCol(3,group_list_width_55*0.10 " Integer Center")
	LV_ModifyCol(4,group_list_width_55*0.4)
	LV_ModifyCol(5,group_list_width_55*0.24)
}

ListViewUpdate_Custom_Hotstring(Custom_Hotstring) { ; ����Custom_Hotstring����
	Gui, ListView, CustomOperation
	LV_Delete()
	Loop, parse, Custom_Hotstring, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		LV_Add(, MyVar[1], groupNumObj[MyVar[2]], MyVar[3], TransformState(OperationState,MyVar[4]),MyVar[5])
	}
	LV_ModifyCol(1,group_list_width_55*0.08 " Integer Center")
	LV_ModifyCol(2,group_list_width_55*0.17)
	LV_ModifyCol(3,group_list_width_55*0.28)
	LV_ModifyCol(4,group_list_width_55*0.22)
	LV_ModifyCol(5,group_list_width_55*0.24)
}

ListViewUpdate_Custom_Advanced_Config() { ; ���¸߼���������
	Gui, ListView, AdvancedConfig
	LV_GetText(OutputVar, 6, 4)
	LV_Modify(6, "Col3", TransformState(DefaultCapsLockState,SubStr(OutputVar, 1, 1)))
}	

TransformState(String,State) { ; ��״̬ת��Ϊ����
	Loop, parse, String, |
	    If (State+1=A_Index)
			Return A_LoopField
	Return State
}

TransformStateReverse(String,State) { ; ������ת��Ϊ״̬
	Loop, parse, String, |
	    If (State=A_LoopField)
			Return A_Index-1
	Return State	
}

getIndexDropDownList(Str,objStr) { ; �����ַ�������DropDownList��λ��
	Loop, parse, Str, |
	{
	    If (A_LoopField=objStr)
	    	pos := A_Index
	}
	Return pos
}

getListViewData(Section) { ; ��ȡListview����
	Loop, % LV_GetCount()
	{
		LV_GetText(OutputVar, A_Index, 1)
		LV_GetText(OutputVar0, A_Index, 2)
		LV_GetText(OutputVar1, A_Index, 3)
		LV_GetText(OutputVar2, A_Index, 4)
		LV_GetText(OutputVar3, A_Index, 5)
		If (Section="�Զ��崰����")
			IniWrite_Str .= OutputVar "=" OutputVar0 "=" TransformStateReverse(ListViewKBLState,OutputVar1) "=" Trim(OutputVar2,"|") "=" OutputVar3 "`n"
		Else If (Section="�Զ������")
			IniWrite_Str .= OutputVar "=" groupNameObj[OutputVar0] "=" Trim(OutputVar1,"|") "=" TransformStateReverse(OperationState,OutputVar2) "=" OutputVar3 "`n"
		Else
			IniWrite_Str .= OutputVar "=" OutputVar0 "=" OutputVar1 "=" OutputVar2 "=" OutputVar3 "`n"
	}
	Return Trim(IniWrite_Str,"`n")
}

SetListViewData(Section) { ; ����Listview����
	LV_ModifyCol(1,"Sort")
	IniDelete, %INI%, %Section%
	IniWrite_Str := getListViewData(Section)
	IniWrite, %IniWrite_Str%, %INI%, %Section%
}

AddMenu_KBLWin(id,MenuItem) { ; ��Ӵ���Menu
	WinGetTitle title, ahk_id %id%
	WinGet, ExStyle, ExStyle, ahk_id %id%
	if (ExStyle & 0x20 || title = "" || title = "Program Manager")
		Return 0
	WinGetClass class, ahk_id %id%
	If (class = "ApplicationFrameWindow"){
		WinGetText, text, ahk_id %id%
		If (text = "")
		{
			WinGet, style, style, ahk_id %id%
			If !(style = "0xB4CF0000")	 ; the window isn't minimized
				Return 0
		}
	}
	WinGet, IcoPath, ProcessPath, ahk_id %id%
	If StrLen(MenuItem)>56 {
		endPos := InStr(MenuItem, "-",,0,1)
		endPos := endPos=0?-10:endPos
		leastLen := endPos=0?(StrLen(MenuItem)-10):endPos
		If (leastLen<46)
			MenuItem := SubStr(MenuItem,1,leastLen) "..." SubStr(MenuItem,endPos)
		Else
			MenuItem := SubStr(MenuItem,1,20) "..." SubStr(MenuItem,endPos-26)
	}
	Menu, Menu_KBLWin, Add,%MenuItem%, Label_Add_KBLWin
	Try Menu, Menu_KBLWin, Icon,%MenuItem%, %IcoPath%,,32
	Catch
		Menu, Menu_KBLWin, Icon,%MenuItem%,shell32.dll,3,32
	WinMenuObj[MenuItem] := id
	Return 1
}

Label_Add_KBLWin: ; ���KBL����
	WinId := WinMenuObj[A_ThisMenuItem]
	item_key_val := getINIItem("ahk_id " WinId)
	item := item_key_val[0] "=" item_key_val[1]
	item := KBLWins=""?item:"`n" item
	item_regex := item_key_val[2]
	KBLWinsNew := KBLWins item
	Switch CurrentWin_AddFlag
	{
		Case "vCurrentWin_Add_Cn":KBLWins_hwnd:=KBLWinsCN_hwnd,RemoveFlag:=1
		Case "vCurrentWin_Add_CnEn":KBLWins_hwnd:=KBLWinsCNEN_hwnd,RemoveFlag:=1
		Case "vCurrentWin_Add_En":KBLWins_hwnd:=KBLWinsEN_hwnd,RemoveFlag:=1
		Case "vCurrentWin_Add_Disable_HotKey":KBLWins_hwnd:=DisableHotKey_hwnd,RemoveFlag:=0
		Case "vCurrentWin_Add_Disable_Switch":KBLWins_hwnd:=DisableSwitch_hwnd,RemoveFlag:=0
		Case "vCurrentWin_Add_Disable_TTShow":KBLWins_hwnd:=DisableTTShow_hwnd,RemoveFlag:=0
		Case "vCurrentWin_Add_FocusControl":KBLWins_hwnd:=FocusControl_hwnd,RemoveFlag:=0
	}
	GuiControl,, %KBLWins_hwnd% , %KBLWinsNew%
	WinMenuObj := Object()
	If (RemoveFlag!=1)
		Return
	KBLList := KBLWinsCN_hwnd "," KBLWinsCNEN_hwnd "," KBLWinsEN_hwnd
	Loop, parse, KBLList, `,
	{
	    If (A_LoopField=KBLWins_hwnd)
	    	Continue
	    Else {
	    	GuiControlGet, KBLWins,, %A_LoopField%
	    	RegExStr := IsHasSameRegExStr(KBLWins,item_regex)
	    	KBLWinsNew := RegExReplace(KBLWins, RegExStr)
	    	GuiControl,, %A_LoopField% , %KBLWinsNew%
	    }
	}
Return

Label_Sub_KBLWin: ; �Ƴ�KBL����
	KBLWinsNew := StrReplace(KBLWins, "`n" A_ThisMenuItem)
	KBLWinsNew := StrReplace(KBLWinsNew, A_ThisMenuItem "`n")
	KBLWinsNew := StrReplace(KBLWinsNew, A_ThisMenuItem)
	Switch CurrentWin_SubFlag
	{
		Case "vCurrentWin_Sub_Cn":GuiControl,, %KBLWinsCN_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_CnEn":GuiControl,, %KBLWinsCNEN_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_En":GuiControl,, %KBLWinsEN_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_Disable_HotKey":GuiControl,, %DisableHotKey_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_Disable_Switch":GuiControl,, %DisableSwitch_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_Disable_TTShow":GuiControl,, %DisableTTShow_hwnd% , %KBLWinsNew%
		Case "vCurrentWin_Sub_FocusControl":GuiControl,, %FocusControl_hwnd% , %KBLWinsNew%
	}
Return

getLVNewOrder() { ; ��ȡȱʧ���
	Loop % LV_GetCount()
	{
	    LV_GetText(Order, A_Index)
	    If (Order!=A_Index)
	    	Return A_Index
	}
	Return Order+1
}

getExeIcoPath(exeName){ ; ����exe���ƻ�ȡexe����·��
	If (exeName!="" && RunAnyEvFullPath!="")
		try IniRead, ExeIcoPath, %RunAnyEvFullPath%, FullPath, %exeName%, %A_Space%
	If (ExeIcoPath=""){
		Switch exeName
		{
			Case "Taskmgr.exe":ExeIcoPath:="C:\Windows\System32\Taskmgr.exe"
			Case "cmd.exe":ExeIcoPath:="C:\Windows\System32\cmd.exe"
			Case "explorer.exe":ExeIcoPath:="C:\Windows\explorer.exe"
		}
	}Else{
		Attributes := DllCall("GetFileAttributes", "str", ExeIcoPath, "uint")
		If (Attributes=4294967295) ; �ļ�������
			ExeIcoPath := ""
		Else If (Attributes&4194304) ; �������δ�ڱ���
			ExeIcoPath := "imageres.dll,232"
	}
	Return ExeIcoPath
}

;-----------------------------------���߼����ù��ܡ�-----------------------------------------------
Menu_AdvancedConfigEdit_Gui: ; �༭����Gui
	global Advanced_Config_Edit_Hwnd,Advanced_Config_Edit_Hwnd0,Advanced_Config_Edit_Hwnd1,Advanced_Config_Edit_Hwnd2
	global Advanced_Config_Group_Hwnd
	global Advanced_Config_Edit_Text0
	Gui,ConfigEdit:Destroy
	Gui,ConfigEdit:Default
	Gui,ConfigEdit:+Owner55
	Gui,ConfigEdit:Margin,20,20
	Gui,ConfigEdit:Font,,Microsoft YaHei
	Gui,ConfigEdit:Add, GroupBox,xm-10 y+10 w450 h%ConfigEdit_h% HwndAdvanced_Config_Group_Hwnd, %ACvar1%.%A_Space%%Showvar%��%Showvar4%
	If (ConfigEdit_Flag=1){
		Gui,ConfigEdit:Add, Text, Center xm yp+30 w%Text_w%,%Showvar1%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd x+5 yp-2 w350 r2, %ACvar2%
		Gui,ConfigEdit:Add, Text, Center xm yp+50 w%Text_w%, %Showvar2%
		Gui,ConfigEdit:Add, DropDownList, HwndAdvanced_Config_Edit_Hwnd0 x+5 yp-2 w120, %ListViewKBLState%
		GuiControl, Choose, %Advanced_Config_Edit_Hwnd0%, % TransformStateReverse(ListViewKBLState,ACvar3)+1
		Gui,ConfigEdit:Add, Text, Center xm yp+35 w%Text_w%,%Showvar3%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd1 x+5 yp-2 w350 r2, %ACvar4%
		Gui,ConfigEdit:Add, Text, Center xm yp+50 w%Text_w%,˵��
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd2 x+5 yp-2 w350 r4 -WantReturn, %ACvar5%
	}Else If (ConfigEdit_Flag=2){
		Gui,ConfigEdit:Add, Text, Center xm yp+30 w%Text_w%, %Showvar1%
		Gui,ConfigEdit:Add, DropDownList, HwndAdvanced_Config_Edit_Hwnd x+5 yp-2 w120, %groupNameList%
		GuiControl, Choose, %Advanced_Config_Edit_Hwnd%, % groupNameObj[ACvar2]+1
		tempVar := SubStr(Showvar2, -2,2)
		If (tempVar="s-")
			tempVar1 := "+default",tempVar2 := ""
		Else
			tempVar2 := "+default",tempVar1 := ""
		Gui, ConfigEdit:Add, Button, %tempVar1% w50 h25 xm+300 yp ggOperation_Flag_HotString, ���ִ�
		Gui, ConfigEdit:Add, Button, %tempVar2% w50 h25 xm+360 yp ggOperation_Flag_HotKey, �ȼ�
		Gui,ConfigEdit:Add, Text, HwndAdvanced_Config_Edit_Text0 Center xm yp+35 w%Text_w%,%Showvar2%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd0 x+5 yp-2 w350 r2, %ACvar3%
		Gui,ConfigEdit:Add, Text, Center xm yp+50 w%Text_w%,%Showvar3%
		Gui,ConfigEdit:Add, DropDownList, HwndAdvanced_Config_Edit_Hwnd1 x+5 yp-2 w120, %OperationState%
		GuiControl, Choose, %Advanced_Config_Edit_Hwnd1%, % TransformStateReverse(OperationState,ACvar4)+1
		Gui,ConfigEdit:Add, Text, Center xm yp+35 w%Text_w%,˵��
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd2 x+5 yp-2 w350 r4 -WantReturn, %ACvar5%
	}Else If (ConfigEdit_Flag=3){
		Gui,ConfigEdit:Add, Button, xm+350 yp-5 vButton11 ggAdvanced_Default, �ָ�Ĭ��
		Gui,ConfigEdit:Add, Text, Center xm yp+35 w%Text_w%,%Showvar1%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd x+5 yp-2 w350 r2, %ACvar2%
		Gui,ConfigEdit:Add, Text, Center xm yp+50 w%Text_w%, %Showvar2%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd0 x+5 yp-2 w350 r2, %ACvar3%
		GuiControl, Hide, %Advanced_Config_Edit_Hwnd%
		GuiControl, Hide, %Advanced_Config_Edit_Hwnd0%
		Gui,ConfigEdit:Add, Text, Center xm yp-46 w%Text_w%,%Showvar3%
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd1 x+5 yp-2 w350 r4, %ACvar4%
		Gui,ConfigEdit:Add, Text, Center xm yp+90 w%Text_w%,˵��
		Gui,ConfigEdit:Add, Edit, HwndAdvanced_Config_Edit_Hwnd2 x+5 yp-2 w350 r4 -WantReturn +ReadOnly, %ACvar5%
	}
	Gui,ConfigEdit:Font
	Gui,ConfigEdit:Add,Button,Default xm+140 y+25 w75 ggSetAdvancedConfig,����(&S)
	Gui,ConfigEdit:Add,Button,x+20 w75 GgSet_Cancel,ȡ��(&C)
	Gui,ConfigEdit:Show,,%title%
Return

gAdvanced_Config: ; �༭�߼�����
	if (A_GuiEvent="DoubleClick" && A_EventInfo>0){
		RunRowNumber := A_EventInfo
		Gui, ListView, %A_GuiControl%
		LV_GetText(ACvar1,RunRowNumber,1)
		LV_GetText(ACvar2,RunRowNumber,2)
		LV_GetText(ACvar3,RunRowNumber,3)
		LV_GetText(ACvar4,RunRowNumber,4)
		LV_GetText(ACvar5,RunRowNumber,5)
		If (A_GuiControl="AdvancedConfig")
			gosub,Label_AdvancedConfig_Var
		Else If (A_GuiControl="ahkGroupWin")
			gosub,Label_ahkGroupWin_Var
		Else If (A_GuiControl="CustomOperation")
			gosub,Label_CustomOperation_Var
		gosub, Menu_AdvancedConfigEdit_Gui
	}
Return

gAdvanced_Default: ; �߼����ûָ�Ĭ��
	Switch RunRowNumber
	{
		Case 1:tempVar:="..\RunAny\RunAnyConfig.ini"
		Case 2:tempVar:=1
		Case 3:tempVar:="1|ȫ�ִ���"
		Case 4:tempVar:="Code.exe"
		Case 5:tempVar:="60|�༭��"
		Case 6:tempVar:=1
		Case 7:tempVar:="2|1"
		Case 8:tempVar:="333434|dfe3e3|02ecfb|ff0000"
		Case 9:tempVar:="KBLAutoSwitch��%Ȩ��%��`n%����ʱ��%`n�汾��%�汾%`n�Զ��л�ͳ�ƣ�%�Զ��л�����%"
		Case 10:tempVar:=30
	}
	GuiControl,, %Advanced_Config_Edit_Hwnd1%, %tempVar%
Return

gSetAdvancedConfig: ; ����߼�����
	Gui,55:Default
	GuiControlGet, OutputVar,, %Advanced_Config_Edit_Hwnd%
	GuiControlGet, OutputVar0,, %Advanced_Config_Edit_Hwnd0%
	GuiControlGet, OutputVar1,, %Advanced_Config_Edit_Hwnd1%
	GuiControlGet, OutputVar2,, %Advanced_Config_Edit_Hwnd2%
	If (substr(Showvar,1,2)="���" && ConfigEdit_Flag=1 && !groupNumObj.HasKey(NewOrder) && groupNameObj.HasKey(OutputVar)){
		FocusNum := LVFocusNum(2,OutputVar)
	}Else If (OutputVar!=""){
		If (!LV_GetText(tempVar, RunRowNumber , 1)){
			LV_Add(,RunRowNumber)
			LV_Modify(RunRowNumber, "Col1",NewOrder)
			FocusNum := NewOrder
		}Else
			FocusNum := RunRowNumber
		LV_Modify(RunRowNumber, "Col2",OutputVar)
		GuiControlGet, tempVar ,, %Advanced_Config_Edit_Text0%
		tempVar := SubStr(tempVar, -2,2)
		If (tempVar="s-" || tempVar="k-")
			LV_Modify(RunRowNumber, "Col3", tempVar . OutputVar0)
		Else
			LV_Modify(RunRowNumber, "Col3",OutputVar0)
		LV_Modify(RunRowNumber, "Col4",OutputVar1)
		LV_Modify(RunRowNumber, "Col5",OutputVar2)		
	}
	Gui,ConfigEdit:Destroy
	gosub, Label_Update_ListView
	If (ConfigEdit_Flag=1){
		Gui, ListView, ahkGroupWin
	}Else If (ConfigEdit_Flag=2){
		Gui, ListView, CustomOperation
	}Else If (ConfigEdit_Flag=3){
		Gui, ListView, AdvancedConfig
	}
	LV_Modify(FocusNum, "+Focus +Select +Vis")
Return

gSet_Cancel: ; ȡ������
	Gui,Destroy
return

gOperation_Flag_HotString: ; �Զ����������Ϊ���ִ�����
	GuiControlGet, OutputVar ,, %Advanced_Config_Group_Hwnd%
	GuiControl,, %Advanced_Config_Group_Hwnd%, % StrReplace(OutputVar, "�ȼ�", "���ִ�")
	GuiControl,, %Advanced_Config_Edit_Text0%, ���ִ�(s-)
Return

gOperation_Flag_HotKey: ; �Զ����������Ϊ�ȼ�����
	GuiControlGet, OutputVar ,, %Advanced_Config_Group_Hwnd%
	GuiControl,, %Advanced_Config_Group_Hwnd%, % StrReplace(OutputVar, "���ִ�", "�ȼ�")
	GuiControl,, %Advanced_Config_Edit_Text0%, �ȼ�(k-)
Return

LVFocusNum(col,val) { ; ��ȡ������
	Loop % LV_GetCount()
	{
	    LV_GetText(OutputVar, A_Index, col)
	    if (OutputVar=val)
	        Return A_Index
	}
}

Label_ahkGroupWin_Var: ; �������Ӧ����
	ConfigEdit_Flag := 1
	ConfigEdit_h := 247
	Text_w := 50
	Showvar := "����״̬"
	Showvar1 := "������"
	Showvar2 := "״̬"
	Showvar3 := "����"
	Showvar4 := ACvar3 . "��" StrSplit(Trim(ACvar4,"|"), "|").Length() . "�� | �ָ�"
	title := "�߼�����"
Return

Label_CustomOperation_Var: ; �Զ��������Ӧ����
	ConfigEdit_Flag := 2
	ConfigEdit_h := 232
	Text_w := 60
	Showvar := "�߼�����"
	Showvar1 := "������"
	Showvar2 := SubStr(ACvar3, 1, 2)="s-"?"���ִ�(s-)":"�ȼ�(k-)"
	Showvar3 := "����"
	Showvar4 := (SubStr(ACvar3, 1, 2)="s-"?"���ִ�":"�ȼ�") . "��" StrSplit(Trim(ACvar3,"|"), "|").Length() . "�� | �ָ�"
	ACvar3 := SubStr(ACvar3, 3)
	title := "�߼�����"
Return

Label_AdvancedConfig_Var: ; �߼����ö�Ӧ����
	ConfigEdit_Flag := 3
	ConfigEdit_h := 202
	Text_w := 50
	Showvar := ACvar2
	Showvar1 := ""
	Showvar2 := ""
	Showvar3 := A_Space "ֵ"
	Showvar4 := ACvar3
	title := "�߼�����"
Return

Label_Update_ListView: ; ����չʾ����
	Gui, ListView, ahkGroupWin
	Custom_Win_Group_temp := getListViewData("�Զ��崰����")
	Gui, ListView, CustomOperation
	Custom_Hotstring_temp := getListViewData("�Զ������")
	global groupNameList := "��",groupNameObj := Object(),groupNumObj := Object()
	groupNameObj["��"] := 0
	groupNumObj[0] := "��"
	Loop, parse, Custom_Win_Group_temp, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")		
		groupNameList .= "|" MyVar[2]
		groupNameObj[MyVar[2]] := MyVar[1]
		groupNumObj[MyVar[1]] := MyVar[2]
	}
	ListViewUpdate_Custom_Win_Group(Custom_Win_Group_temp)
	ListViewUpdate_Custom_Hotstring(Custom_Hotstring_temp)
	ListViewUpdate_Custom_Advanced_Config()
Return

;-----------------------------------���Զ���������ܡ�-----------------------------------------------
TarHotFun: ; ���ִ����ܴ���
	TarHotFunFlag := 2 ; 1��ʾ���ַ�����2��ʾ�ȼ�
	TarHotVal := A_ThisHotkey
	If (SubStr(TarHotVal, 1, 6)=":*XB0:"){
		TarHotVal := SubStr(TarHotVal, 7)
		TarHotFunFlag := 1
	}
	Switch % TarFunList[TarHotVal]
	{
		Case 1: Gosub, Set_Chinese
		Case 2: Gosub, Set_ChineseEnglish
		Case 3: Gosub, Set_English
		Case 4: Gosub, Toggle_CN_CNEN
		Case 5: Gosub, Toggle_CN_EN
		Case 6: Gosub, Reset_KBL
	}
	TarHotFunFlag := 0
Return

BoundHotkey(BoundHotkey,Hotkey_Fun) { ; �������ȼ�
	Switch Hotkey_Fun
	{
		Case 1: Hotkey, %BoundHotkey%, Set_Chinese
		Case 2: Hotkey, %BoundHotkey%, Set_ChineseEnglish
		Case 3: Hotkey, %BoundHotkey%, Set_English
		Case 4: Hotkey, %BoundHotkey%, Toggle_CN_CNEN
		Case 5: Hotkey, %BoundHotkey%, Toggle_CN_EN
		Case 6: Hotkey, %BoundHotkey%, Reset_KBL
	}
}

Label_Click_showSwitch: ; ��������ʾ
	If (A_Cursor!="IBeam"){
		If (shellMessageFlag=0)
			SetTimer, Label_Hide_All, -100
		Return
	}
	If WinActive("ahk_group Left_Mouse_ShowKBL_Up_WinGroup"){
		KeyWait, LButton, L
	}
	If OSVersion<=7
		SetTimer,SetTimer_Label_Click_showSwitch,-100
	Else
		SetTimer,SetTimer_Label_Click_showSwitch,-20
	Return

	SetTimer_Label_Click_showSwitch:
		showSwitch(LastKBLState,LastCapsState,1)
Return

Label_ToEnglishInputingOpera: ; �л���Ӣ��ʱ������������ַ�
	Thread, NoTimers, True
	DetectHiddenWindows off
	SetTitleMatchMode, RegEx
	WinGet, binglingCount, Count, ahk_class i)^ATL:
	If (Enter_Inputing_Content_Core!=0 && WinExist("ahk_group IMEInput_ahk_group") && binglingCount!=1){
		Switch Enter_Inputing_Content_Core
		{
			Case 1:SendInput, {Esc}
			Case 2:SendInput, {Enter}
			Case 3:SendInput, {Space}
		}
	}
	SetTitleMatchMode, 2
	DetectHiddenWindows on
	Thread, NoTimers, False
Return

;-----------------------------------����ʾ����ع��ܡ�-----------------------------------------------
monitorChange(ByRef wParam,ByRef lParam) { ; ��ʾ���ֱ��ʸ���-�����ű�
    SetTimer, Menu_Reload, -1000
}

getDisplayPos(X=0, Y=0, W=0, H=0) { ; ������Ļ�ķֱ��ʻ�ȡ���뷨״̬��ʾλ��
	WinGetPos, WinX, WinY, , , A
	MonitorNum := getMonitorNum(WinX,WinY)
	SysGet, Mon, MonitorWorkArea, MonitorNum
	MonWidth := MonRight-MonLeft
	MonHeight := MonBottom-MonTop
	X := MonLeft+MonWidth*X*0.01
	Y := MonTop+MonHeight*Y*0.01
	X := X+W>MonWidth-10?MonWidth-W-10:X
	Y := Y+H>MonHeight-10?MonHeight-H-10:Y
	return {x:X, y:Y}
}

getMonitorNum(X,Y) { ; ����ָ��λ�û�ȡ��ʾ�����
    Loop,% MonitorAreaObjects.Length()
    {
        If (X>MonitorAreaObjects[A_Index][1] && X<MonitorAreaObjects[A_Index][3] && Y>MonitorAreaObjects[A_Index][2] && Y<MonitorAreaObjects[A_Index][4])
        	Return A_Index
    }
    Return 1
}

;-----------------------------------���Զ��幦�ܡ�-----------------------------------------------
Add_To_Cn: ; ��ӵ����Ĵ���
	AddToKBLWin("���Ĵ���","���Ĵ���,Ӣ�Ĵ���,Ӣ�����뷨����")
Return

Add_To_CnEn: ; ��ӵ�Ӣ�Ĵ��ڣ����ģ�
	AddToKBLWin("Ӣ�Ĵ���","���Ĵ���,Ӣ�Ĵ���,Ӣ�����뷨����")
Return

Add_To_En: ; ��ӵ�Ӣ�����뷨����
	AddToKBLWin("Ӣ�����뷨����","���Ĵ���,Ӣ�Ĵ���,Ӣ�����뷨����")
Return

Remove_From_All: ; �����ô������Ƴ����ָ�ΪĬ�����뷨
	AddToKBLWin("","���Ĵ���,Ӣ�Ĵ���,Ӣ�����뷨����")
Return

Set_Chinese: ; ��ǰ������Ϊ����
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	If (Enter_Inputing_Content_CnTo=1)
		Gosub, Label_ToEnglishInputingOpera
	setKBLlLayout(0)
Return

Set_ChineseEnglish: ; ��ǰ������ΪӢ�ģ��������뷨��
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	Gosub, Label_ToEnglishInputingOpera
	setKBLlLayout(1)
Return

Set_English: ; ��ǰ������ΪӢ��
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	Gosub, Label_ToEnglishInputingOpera
	setKBLlLayout(2)
Return

Toggle_CN_CNEN: ; �л���Ӣ��(����)
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	KBLState := (getIMEKBL(gl_Active_IMEwin_id)!=EN_Code?(getIMECode(gl_Active_IMEwin_id)!=0?0:1):2)
	If (KBLState=0){
		Gosub, Label_ToEnglishInputingOpera
		setKBLlLayout(1)
	}Else If (KBLState=1 || KBLState=2)
		setKBLlLayout(0)
Return

Toggle_CN_EN: ; �л���Ӣ�����뷨
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	KBLState := (getIMEKBL(gl_Active_IMEwin_id)!=EN_Code?(getIMECode(gl_Active_IMEwin_id)!=0?0:1):2)
	If (KBLState=0){
		Gosub, Label_ToEnglishInputingOpera
		If (KBLEnglish_Exist=1)
			setKBLlLayout(2)
		Else
			setKBLlLayout(1)
	}Else If (KBLState=1 || KBLState=2)
		setKBLlLayout(0)
Return

Display_KBL: ; ��ʾ��ǰ�����뷨״̬
	showSwitch(,,1)
Return

Reset_KBL: ; ���õ�ǰ���뷨���̲���
	If (TarHotFunFlag=0 && Outer_InputKey_Compatible=1 && A_ThisHotkey!="" && A_PriorKey!=RegExReplace(A_ThisHotkey, "iS)(~|\s|up|down)", ""))
		Return
	gosub, Label_Shell_KBLSwitch
Return

Stop_KBLAS: ; ֹͣ���뷨�Զ��л�
	gosub, Menu_Stop
Return

Get_KeyBoard: ; �ֶ������̲��ֺ���
	InputLocaleID := Format("{1:#x}", getIMEKBL(gl_Active_IMEwin_id))
	Clipboard := InputLocaleID
	MsgBox, ���̲��ֺ��룺%InputLocaleID%`n`n�Ѹ��Ƶ�������
Return

getINIItem(TarWin:="") { ; ��ȡ����INI�ļ���key-val
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows off
	item_key_val := Object()
	TarWin := TarWin=""?"A":TarWin
	WinGet, ahk_value, ProcessName, %TarWin%
	If (ahk_value = "taskmgr.exe"){
		item_key := "���������"
		item_val = ahk_exe taskmgr.exe
		item_regex := item_val
	}Else If (ahk_value = "explorer.exe"){ ; ���explorer���Ż�
		WinGetClass, ahk_value, %TarWin%
		If (ahk_value="CabinetWClass")
			item_key := "�ļ���Դ������"
		Else
			item_key := SubStr(ahk_value, 1, StrLen(ahk_value))
		item_val = ahk_class %ahk_value% ahk_exe explorer.exe
		item_regex := item_val
	}Else If (ahk_value = "ApplicationFrameHost.exe"){ ; ���uwpӦ�õ��Ż�
		WinGetTitle uwp_title, %TarWin%
		startPos := InStr(uwp_title,"-",,0)+1
		item_key := SubStr(uwp_title, startPos)
		item_val = uwp %item_key%
		item_regex := item_val
	}Else{
		item_key := SubStr(ahk_value, 1, StrLen(ahk_value)-4)
		item_val = ahk_exe %ahk_value%
		item_regex := item_val "-|-" ahk_value
	}
	item_key_val[0] := item_key
	item_key_val[1] := item_val
	item_key_val[2] := item_regex
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	Return item_key_val
}

IsHasSameRegExStr(Content,Value) { ; Content����ƥ�����
	RegExStr:=""
	Loop, parse, Content, `n, `r
	{
		If (euqalPos := InStr(A_LoopField, "=")){
			ReadyKey := SubStr(A_LoopField,1,euqalPos-1)
			ReadyValue := SubStr(A_LoopField,euqalPos+1)
		}Else{
			ReadyKey := ""
			ReadyValue := A_LoopField
		}
		word_array := StrSplit(Value, "-|-")
		For K, V in word_array {	
			If (ReadyValue=V)
				RegExStr .= "|\n" A_LoopField "|" A_LoopField "\n|" A_LoopField
		}
	}
	RegExStr := Trim(RegExStr,"|")
	return RegExStr=""?RegExStr:"(" RegExStr ")"
}

GetRealItem_key(Section,item_key) { ; ��ȡ���ʵ�Item_key
	original_item_key := item_key
	Loop
	{
		IniRead, res, %INI%, %Section%, %item_key%
		If (res!="ERROR"){
			item_key := original_item_key "_����" A_Index
		}Else{
			Return item_key
		}
	}
}

AddToKBLWin(KBLName,KBLList,TarWin:="") { ; ����ǰ���������ָ��KBL���ڣ�KBL����Ϊ����ȥ��
	Thread, NoTimers , True
	item_key_val := getINIItem(TarWin)
	item_key := item_key_val[0]
	item_val := item_key_val[1]
	item_regex := item_key_val[2]
	If (item_key = "")
		Return
	If (KBLName!=""){	
		IniRead, res, %INI%, %KBLName%
		TarItem_keys := IsHasSameRegExStr(res,item_regex)
		If (TarItem_keys!="") {
			msg := "��" TarItem_keys[1] "�� �Ѵ����ڡ�" KBLName "����"
		}Else{
			item_key := GetRealItem_key(KBLName,item_key)
			IniWrite, %item_val%, %INI%, %KBLName%, %item_key%
			msg := "��" item_key "�� ��ӵ���" KBLName "�� ���ɹ�����"
		}
	}Else
		msg := "��" item_key "�� �Ƴ� ���ɹ�����"
	Loop, parse, KBLList, `,
	{
	    If (A_LoopField=KBLName)
	    	Continue
	    Else {
	    	IniRead, res, %INI%, %A_LoopField%
	    	RegExStr := IsHasSameRegExStr(res,item_regex)
	    	resNew := RegExReplace(res, RegExStr)
	    	IniDelete, %INI%, %A_LoopField%
	    	IniWrite, %resNew%, %INI%, %A_LoopField%
	    }
	}
	showToolTip(msg, State_ShowTime)
	Thread, NoTimers , False
}

;-----------------------------------�����ö�ȡ���ܡ�-----------------------------------------------
Label_ReadCustomKBLWinGroup: ; ��ȡ�Զ���KBL������
	Loop, parse, Custom_Win_Group, `n, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		groupName := MyVar[2]
		groupState := MyVar[3]
		Switch groupState
		{
			Case 1:Custom_Win_Group_Cn .= "`n-" groupName
			Case 2:Custom_Win_Group_CnEn .= "`n-" groupName
			Case 3:Custom_Win_Group_En .= "`n-" groupName
		}
		Custom_Win_Group_Cn := Trim(Custom_Win_Group_Cn," `t`n")
		Custom_Win_Group_CnEn := Trim(Custom_Win_Group_CnEn," `t`n")
		Custom_Win_Group_En := Trim(Custom_Win_Group_En," `t`n")
	}
Return

Label_ReadExistIcoStyles: ; ��ȡIcos�ļ���ͼ��
	global ExistIcoStyles := "" ;���ָ��ֱ����ַ���
	Loop Files, %A_ScriptDir%\Icos\*, D
		ExistIcoStyles := ExistIcoStyles "|" A_LoopFileName
	if (Tray_Display_Style="" or !InStr(ExistIcoStyles, "|" Tray_Display_Style))
		Tray_Display_Style := TransformState(ExistIcoStyles,1)
	ExistIcoStyles := Trim(ExistIcoStyles,"|")
Return

Label_ReadExistCurStyles: ; ��ȡCurs�ļ������ָ��
	global ExistCurStyles := "" ;���ָ��ֱ����ַ���
	Loop Files, %A_ScriptDir%\Curs\*, D
		ExistCurStyles := ExistCurStyles "|" A_LoopFileName
	if (Cur_Launch_Style="" or !InStr(ExistCurStyles, "|" Cur_Launch_Style))
		Cur_Launch_Style := TransformState(ExistCurStyles,1)
	ExistCurStyles := Trim(ExistCurStyles,"|")
Return

Label_ReadExistEXEIcos: ; ��ȡexeͼ��
	global RunAnyEvFullPath := ""
	If (InStr(Open_Ext, "RunAnyConfig.ini"))
		IniRead, RunAEvFullPathIniDir, % GetAbsPath(Open_Ext), Config, RunAEvFullPathIniDir, %A_Space%
		If (RunAEvFullPathIniDir="")
			RunAnyEvFullPath := A_AppData "\RunAny\RunAnyEvFullPath.ini"
		Else
			RunAnyEvFullPath := GetAbsPath(RunAEvFullPathIniDir) "\RunAnyEvFullPath.ini"
		If (!FileExist(RunAnyEvFullPath))
			RunAnyEvFullPath := ""
Return

;-----------------------------------��������Ϣ���ܡ�-----------------------------------------------
Receive_WM_COPYDATA(ByRef wParam,ByRef lParam) { ; ������Ϣ
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; ��ȡ CopyDataStruct �� lpData ��Ա.
    CopyOfData := StrGet(StringAddress)  ; �ӽṹ�и����ַ���.
    Remote_Dyna_Run(CopyOfData)
    return 1  ; ���� 1(true) �ǻظ�����Ϣ�Ĵ�ͳ��ʽ.
}

Remote_Dyna_Run(remoteRun) { ; ������Ϣִ��ָ����ǩ
	if(IsLabel(remoteRun)){
		Gosub,%remoteRun%
		return
	}
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle, wParam:=0) { ; ������Ϣ
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; ����ṹ���ڴ�����.
    ; �������ýṹ�� cbData ��ԱΪ�ַ����Ĵ�С, ������������ֹ��:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; ����ϵͳҪ�������Ҫ���.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; ���� lpData Ϊ���ַ��������ָ��.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := 4000  ; ��ѡ��. �ȴ� receiver.ahk ��Ӧ�ĺ�����. Ĭ���� 5000
    ; ����ʹ�÷��� SendMessage ������Ͷ�� PostMessage.
    SendMessage, 0x004A, %wParam%, &CopyDataStruct,, %TargetScriptTitle%  ; 0x004A Ϊ WM_COPYDAT
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; �ָ�������ԭ��������.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; ͬ��.
    return ErrorLevel  ; ���� SendMessage �Ļظ������ǵĵ�����.
}

;-----------------------------------���ڲ��������ܡ�-----------------------------------------------
FilePathRun(FilePath) { ; ʹ���ڲ��������ļ�
	FileGetAttrib, Attributes, %FilePath%
	If InStr(Attributes, "D")
		FileExt := "folder"
	Else{
		SplitPath, FilePath,,, FileExt  ; ��ȡ�ļ���չ��.
		If (FileExt="")
			FileExt := SubStr(FilePath,InStr(FilePath, ".",,0))
		If (FileExt="lnk"){		
			FileGetShortcut, %FilePath%, FilePath
			SplitPath, FilePath,,, FileExt
			If (FileExt="")
				FileExt := SubStr(FilePath,InStr(FilePath, ".",,0))
		}
	}
	FilePathOpenExe := openExtRunList[FileExt]
	FilePathOpenExe_Parm := openExtRunList_Parm[FileExt]
	try
		Run, %FilePathOpenExe% %FilePathOpenExe_Parm% "%FilePath%"
	Catch{
		Try
			Run, "%FilePath%"
		Catch
			Run, "%A_ScriptDir%"
	}
}

ReadExtRunList(Open_Ext,openExtList:="") { ; ��ȡ�ڲ�����
	openExtListObj := Object()
	Loop, parse, openExtList, |
	    openExtListObj[A_LoopField]:=1
	if (openExtListObj.Count()=0)
        openExtListObj := 0
    Open_Ext_Abs := GetAbsPath(Open_Ext)
    SplitPath, Open_Ext_Abs, OutFileName
    If (OutFileName="RunAnyConfig.ini")
        ReadExtRunList_RA(Open_Ext_Abs,openExtListObj)
    Return openExtRunList.Count()
}

ReadExtRunList_RA(openExtConfig,openExtListObj) { ; ��ȡ�ڲ�����-RA
    IniRead, openExtVar, %openExtConfig%, OpenExt
    openExtVar := StrReplace(openExtVar, "`%A_ScriptDir`%", "`%A_WorkingDir`%")
    SplitPath, openExtConfig, OutFileName, OutDir
    WorkingDirOld := A_WorkingDir
    SetWorkingDir, %OutDir%
    Loop, parse, openExtVar, `n, `r
    {
        File_Open_Exe_Parm := ""
        itemList := StrSplit(A_LoopField,"=",,2)
        File_Open_Exe := itemList[1]
        File_Open_Exe_Parm_Pos := InStr(File_Open_Exe, ".exe ")
        If (File_Open_Exe_Parm_Pos!=0){
            File_Open_Exe_Parm := SubStr(File_Open_Exe, File_Open_Exe_Parm_Pos+5)
            File_Open_Exe := SubStr(File_Open_Exe, 1, File_Open_Exe_Parm_Pos+3)
        }
        File_Open_Exe := GetOpenExe(File_Open_Exe,openExtConfig)
        If (File_Open_Exe!=""){
            Loop, parse,% itemList[2], %A_Space%
            {
            	if (openExtListObj!=0 && openExtListObj.Count()=0)
            		Break
                extLoopField:=RegExReplace(A_LoopField,"^\.","")
                If(extLoopField="http" or extLoopField="https" or extLoopField="www" or extLoopField="ftp")
                    extLoopField := "html"
                if (openExtListObj=0 || openExtListObj.HasKey(extLoopField)){
                	openExtRunList[extLoopField] := File_Open_Exe
                	openExtRunList_Parm[extLoopField] := File_Open_Exe_Parm
                	openExtListObj.Delete(extLoopField)
                }
            }
        }
    }
    SetWorkingDir %WorkingDirOld%
    WorkingDirOld := A_WorkingDir
}

GetOpenExe(Open_Exe,RunAnyConfigPath) { ; ��ȡ�򿪺�׺��Ӧ�ã�RA��·����
    IniRead, RunAEvFullPathIniDir, %RunAnyConfigPath%, Config, RunAEvFullPathIniDir, %A_Space%
    If (RunAEvFullPathIniDir="")
        RunAnyEvFullPath := A_AppData "\RunAny\RunAnyEvFullPath.ini"
    Else{
        Transform, RunAnyEvFullPath, Deref, % RunAEvFullPathIniDir
        RunAnyEvFullPath := RunAnyEvFullPath "\RunAnyEvFullPath.ini"
    }
    If (Open_Exe="")
        Return Open_Exe
    Open_Exe_Abs := GetAbsPath(Open_Exe)
    If !FileExist(Open_Exe_Abs)
        IniRead, Open_Exe, %RunAnyEvFullPath%, FullPath, %Open_Exe%, %Open_Exe%
    Else
        Open_Exe := Open_Exe_Abs
    Return Open_Exe
}

GetAbsPath(filePath) { ; ��ȡ�ļ�����·��
    Transform, filePath, Deref, %filePath%
    SplitPath, filePath, OutFileName, OutDir
    WorkingDirOld := A_WorkingDir
    SetWorkingDir, %OutDir%
    filePath := A_WorkingDir "\" OutFileName
    SetWorkingDir %WorkingDirOld%
    WorkingDirOld := A_WorkingDir
    Return filePath
}

;-----------------------------------���������ع��ܡ�-----------------------------------------------
; ��Դ�� https://www.autoahk.com/archives/12670
UrlDownloadToVar(url,mode:="Get",headers:="") { ; �����ļ�������
	static whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.SetTimeouts(500,2000,2000,5000)
	whr.Open(mode, url, true)
	if (headers != "") 
		for key, value in headers
			whr.SetRequestHeader(key, value)
	whr.Send()
	whr.WaitForResponse()
	return whr.ResponseText
}

; ��Դ�� https://www.autoahk.com/archives/37095
DownloadFile(url,filename,SaveFileAs,ExpectedFileSize := 0) { ; �����ļ�
	global downurl := url
	global downfilename := filename
	global downfilepath := SaveFileAs
	global FinalFileSize := ExpectedFilesize
	global DownloadPid := URLDownloadToFile(downurl,downfilepath)
	;����������
	global DownloadProgress_hwnd,DownloadTime_hwnd,DownloadTitleText_hwnd,DownloadText_hwnd,ReUpdateDownload_hwnd,Reload_hwnd
	try{
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		;Download the headers
		WebRequest.Open("HEAD", StrReplace(downurl, "*0 "))
		WebRequest.Send()
		try {
			FinalFileSize := WebRequest.GetResponseHeader("Content-Length")	;��ȡ�ļ���С
		}catch e { ;�޷���ȡ�ļ���С
			FinalFileSize := ExpectedFilesize ; ���ڴ����ֵ
		}
	}
	Gui, DownloadProgress:Destroy
	gui, DownloadProgress:font, s15
	Gui, DownloadProgress:Add, Text,w500 HwndDownloadTitleText_hwnd Center, %���°汾% �汾���ظ�����...
	gui, DownloadProgress:font, s13
	Gui, DownloadProgress:Add, Text,w280, % "�ļ�����: " downfilename
	Gui, DownloadProgress:Add, Text,x+50 yp w170 HwndDownloadTime_hwnd, ��ʱ: 0s
	Gui, DownloadProgress:Add, Text,xm y+10 w280 HwndDownloadFileSize_hwnd, % "�ļ���С: 0KB/" FileSizeFormat(FinalFileSize)
	Gui, DownloadProgress:Add, Text,x+50 yp w170 HwndDownloadPercent_hwnd, ���ؽ���: 0.00 `%
	Gui, DownloadProgress:Add, Progress, xm w500 h35 cGreen BackgroundSilver Range0-1000 HwndDownloadProgress_hwnd, 0
	Gui, DownloadProgress:Add, Text,w200 HwndDownloadText_hwnd, �����ٶ�: 0.00 KB`/s
	Gui, DownloadProgress:Add, Text,y+10 w400 HwndDownloadText1_hwnd, Ԥ��ʣ��ʱ��: 0��
	Gui, DownloadProgress:Font, underline
	Gui, DownloadProgress:Add, Text,x420 yp Cblue GgMenu_Help, ���¼�¼
	Gui, DownloadProgress:Add, Button, x235 yp-35 Default w80 ggReUpdateDownload HwndReUpdateDownload_hwnd, ��������
	Gui, DownloadProgress:Add, Button, x235 yp Default w80 gMenu_Reload HwndReload_hwnd, �������
	GuiControl, Hide, %Reload_hwnd%
	Gui, DownloadProgress:Font, norm
	Gui, DownloadProgress:Show, ,%APPName% %���°汾% �汾����
	LastSizeTick := 0
	LastSize := 0
	global DownloadStartTime := A_TickCount
	global CurrentSizeTick := A_TickCount
	; ��ʱ���½�����
	SetTimer, __UpdateProgressBar, 100
}

Label_CloseKBLDownload: ; �ر����ؽ���
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows on
	WinGet, OutputVar, PID , KBLDownload.ahk ahk_exe KBLAutoSwitch.exe
	Process, Close , %OutputVar%
	DetectHiddenWindows %Prev_DetectHiddenWindows%
Return

DownloadProgressGuiClose: ; ����Gui�ر�
	SetTimer, __UpdateProgressBar, off
	Gosub, Label_CloseKBLDownload
	Gui, DownloadProgress:Destroy
Return
	
__UpdateProgressBar: ; �������ؽ�����
	;��ȡ��ǰ�������ļ���С
	CurrentSize := FileOpen(downfilepath, "r").Length ;FileGetSize wouldn't return reliable results
	CurrentSizeTick := A_TickCount
	;���������ٶ� /1024ת�� "KB/s"
	Duration := "��ʱ: " SecondsFormat((CurrentSizeTick-DownloadStartTime)/1000)
	PercentDone := Round(CurrentSize/FinalFileSize*100,2)
	;���½������ı�
	GuiControl,, %DownloadTime_hwnd%, %Duration%
	GuiControl,, %DownloadFileSize_hwnd%, % "�ļ���С: " FileSizeFormat(CurrentSize) "/" FileSizeFormat(FinalFileSize)
	GuiControl,, %DownloadProgress_hwnd%, % PercentDone*10
	GuiControl,, %DownloadPercent_hwnd%, ���ؽ���: %PercentDone% `%
	If (ProgressCount=10){
		ProgressCount := 0
		SpeedOrig := Round((CurrentSize-LastSize)/((CurrentSizeTick-LastSizeTick)/1000), 2)
		SpeedText := "�����ٶ�: " SpeedFormat(SpeedOrig)
		;�����ļ���С �� ���ε��õ�ʱ��tick
		LastSizeTick := CurrentSizeTick
		LastSize := FileOpen(downfilepath, "r").Length
		RemainTime := "Ԥ��ʣ��ʱ��: " SecondsFormat((FinalFileSize - CurrentSize)/SpeedOrig) ;�ļ���С��1024ת��KB
		GuiControl,, %DownloadText_hwnd%, %SpeedText%
		GuiControl,, %DownloadText1_hwnd%, %RemainTime%
	}Else{
		ProgressCount += 1
	}
	If (PercentDone=100)
		Gosub, Label_DownloadComplete
Return

Label_DownloadComplete: ; �������
	SetTimer, __UpdateProgressBar, off
	FileReadLine, downfileLine, %downfilepath%, 2
	FileGetSize, downfileSize, %downfilepath%
	SpeedOrig := Round(downfileSize/((CurrentSizeTick-DownloadStartTime)/1000), 2)
	SpeedText := "�����ٶ�: " SpeedFormat(SpeedOrig)
	GuiControl,, %DownloadText_hwnd%, %SpeedText%
	If (InStr(downfileLine, ���°汾) && downfileSize=ahk�ļ���С){
		GuiControl,, %DownloadTitleText_hwnd%, ��ϲ��%���°汾% �汾������ɣ����������Ч��
		Gosub, Label_Update_LatestCheckDateTime
		Gosub, Label_Update_Backup
		FileMove, %downfilepath%, %A_ScriptFullPath%, 1
		GuiControl, Hide, %ReUpdateDownload_hwnd%
		GuiControl, Show, %Reload_hwnd%
		MsgBox, 52, %APPName%, �Ƿ�򿪡������ĵ����鿴��������־����
		IfMsgBox Yes
		{
			Gosub, gMenu_Help
			Sleep, 500
		}
		Gui, DownloadProgress:Show
	}Else{
		GuiControl, +cred, %DownloadProgress_hwnd%
		GuiControl,, %DownloadTitleText_hwnd%, %���°汾% �汾����ʧ�ܣ�����
		GuiControl, Hide, %Reload_hwnd%
		GuiControl, Show, %ReUpdateDownload_hwnd%
	}
Return

Label_Update_Backup: ; ���°汾���ݾɰ汾
	if !FileExist(A_ScriptDir "\Backups")
    	FileCreateDir, %A_ScriptDir%\Backups
	FileCopy, %A_ScriptFullPath%, %A_ScriptDir%\Backups\KBLAutoSwitch_v%APPVersion%.ahk, 1
	FileCopy, %INI%, %A_ScriptDir%\Backups\KBLAutoSwitch_v%APPVersion%.ini, 1
Return

gReUpdateDownload: ; ���������°汾
	GuiControl, , %DownloadProgress_hwnd%, 0
	GuiControl, +cGreen, %DownloadProgress_hwnd%, 0
	GuiControl, Hide, %Reload_hwnd%
		GuiControl, Show, %ReUpdateDownload_hwnd%
	DownloadStartTime := A_TickCount
	GuiControl,, %DownloadTitleText_hwnd%, %���°汾% �汾���ظ�����...
	DownloadPid := URLDownloadToFile(downurl,downfilepath)
	SetTimer, __UpdateProgressBar, 100
Return

URLDownloadToFile(url,SaveFileAs){ ; �����µ�ahk���������ļ�
	Gosub, Label_CloseKBLDownload
	If (FileExist(KBLDownloadPath))
		FileDelete, %KBLDownloadPath%
	If (FileExist(SaveFileAs))
		FileDelete, %SaveFileAs%
	FileAppend,
	(
#NoEnv
#SingleInstance Force
#NoTrayIcon
	UrlDownloadToFile, %url%, %SaveFileAs%
),%KBLDownloadPath%
	Sleep,100
	Run, *RunAs %A_AhkPath%%A_Space%%KBLDownloadPath%, , , OutputVarPID
	Return OutputVarPID
}

FileSizeFormat(FileSize){ ; ��ʽ���ļ���С
	unit := 0
	Loop, 5{
		If (FileSize<1024)
			Break
		Else{
			FileSize := FileSize/1024
			unit ++
		}
	}
	If (unit=0)
		unit := "B"
	Else If (unit=1)
		unit := "KB"
	Else If (unit=2)
		unit := "MB"
	Else If (unit=3)
		unit := "GB"
	Else If (unit=4)
		unit := "TB"
	return Round(FileSize, 2) " " unit
}

SecondsFormat(Seconds){ ; ��ʽ��ʱ��
	TimeString := ""
	If (Seconds>=31536000){
		TimeString .= Round(Seconds/31536000) "��"
		Seconds := Mod(Seconds, 31536000)
	}
	If (Seconds>=2592000){
		TimeString .= Round(Seconds/2592000) "��"
		Seconds := Mod(Seconds, 2592000)
	}
	If (Seconds>=86400){
		TimeString .= Round(Seconds/86400) "��"
		Seconds := Mod(Seconds, 86400)
	}
	If (Seconds>=3600){
		TimeString .= Round(Seconds/3600) "Сʱ"
		Seconds := Mod(Seconds, 3600)
	}
	If (Seconds>60){
		TimeString .= Round(Seconds/60) "����"
		Seconds := Mod(Seconds, 60)
	}
	TimeString .= Round(Seconds) "��"
	return TimeString
}

SpeedFormat(Speed){ ; ��ʽ�������ٶ�
	;������λ
	SpeedUnit := "B/s"
	If (Speed>1073741824) {
		; ת��MB/s
		SpeedUnit := "GB/s"
		Speed := Round(Speed/1073741824, 2)
	}Else If (Speed>1048576) {
		; ת��MB/s
		SpeedUnit := "MB/s"
		Speed := Round(Speed/1048576, 2)
	}Else If (Speed>1024) {
		; ת��MB/s
		SpeedUnit := "KB/s"
		Speed := Round(Speed/1024, 2)
	}
	SpeedText := Speed " " SpeedUnit
	Return SpeedText
}

;-----------------------------------�������������ܡ�-----------------------------------------------
GetVersionComp(Version){ ; ��ȡ�汾�ַ���
	Version:=LTrim(LTrim(Version, "v"), "V")
	NewStr := StrReplace(Version, ".")
	If (StrLen(NewStr)=3){
		NewStr := NewStr . "0"
	}
	Return NewStr
}

; ��Դ�� https://www.autoahk.com/archives/16443
GetCaret(Byref CaretX="", Byref CaretY="") { ; ��ȡ������λ��
	static init
	CoordMode, Caret, Screen
	Loop 2
	{
		CaretX:=A_CaretX, CaretY:=A_CaretY
		If (CaretX or CaretY)
			Break
		Else
			Sleep 10
	}
	If WinActive("ahk_group GetCaretSleep_ahk_group") {
		LoopCount := 10
	}Else
		LoopCount := 1
	if (!CaretX or !CaretY){
		Loop %LoopCount%
		{
			Try {
				if (!init)
					init:=DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "oleacc", "Ptr"), "AStr", "AccessibleObjectFromWindow", "Ptr")
				VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
				, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
				, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
				if DllCall(init, "Ptr",WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0 {
					Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
					, Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0)
					, ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
					, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"),ObjRelease(pacc)
				}
			}
			If (CaretX or CaretY)
				Break
			Else
				Sleep 20
		}
	}
	return {x:CaretX, y:CaretY}
}

getINISwitchWindows(INIVar:="",groupName:="",Delimiters:="`n") { ; �������ļ���ȡ�л�����
	Loop, parse, INIVar, %Delimiters%, `r
	{
		MyVar := StrSplit(Trim(A_LoopField), "=")
		MyVar_Key := MyVar[1]
		MyVar_Val := MyVar[2]
		If (MyVar_Key="")
			continue
		If (MyVar_Val="")
			MyVar_Val := MyVar_Key
		prefix := SubStr(MyVar_Val, 1, 4)
		If (MyVar_Val="AllGlobalWin")
			GroupAdd, %groupName%
		Else If (groupNameObj.HasKey(MyVar_Val))
			GroupAdd, %groupName%, ahk_group%A_Space%%MyVar_Val%
		Else If (prefix="uwp "){
			uwp_app := SubStr(MyVar_Val, 5)
			GroupAdd, %groupName%, ahk_exe ApplicationFrameHost.exe, %uwp_app%
			GroupAdd, %groupName%, %uwp_app%
		}Else If (!InStr(MyVar_Val, A_Space) && SubStr(MyVar_Val, -3)=".exe")
	    	GroupAdd, %groupName%, ahk_exe %MyVar_Val%
	    Else
	    	GroupAdd, %groupName%, %MyVar_Val%
	}
}

showToolTip(Msg="", ShowTime=1000) { ; ToolTip��ʾ��Ϣ
	ToolTip, %Msg%
	SetTimer, Timer_Remove_ToolTip, %ShowTime%
	Return
	
	Timer_Remove_ToolTip:  ; �Ƴ�ToolTip
		SetTimer, Timer_Remove_ToolTip, Off
		ToolTip
	Return
}

getCurPath(Cur_Style:="",CurSize:=1080,CurName:="") { ; ��ȡ���ָ��·��
	If (!CurSize)
		CurPath := A_ScriptDir "\Curs\" Cur_Style "\" CurName
	Else
		CurPath := A_ScriptDir "\Curs\" Cur_Style "\" CurSize "\" CurName
	if FileExist(CurPath ".ani")
    	CurPath := CurPath ".ani"
    Else
    	CurPath := CurPath ".cur"
    Return CurPath
}