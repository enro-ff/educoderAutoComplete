// 后台脚本
chrome.runtime.onInstalled.addListener(() => {
    console.log('Educoder自动化助手扩展已安装');
    
    chrome.storage.local.get(['serverUrl'], (result) => {
        if (!result.serverUrl) {
            chrome.storage.local.set({
                serverUrl: 'ws://localhost:8000'
            });
        }
    });
});

// 点击扩展图标时在当前页面显示/隐藏浮动窗口
chrome.action.onClicked.addListener((tab) => {
    chrome.tabs.sendMessage(tab.id, { action: 'toggleAssistant' });
});