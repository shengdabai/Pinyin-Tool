-- 拼音标注工具 AppleScript 快捷键脚本
-- 用于通过快捷键快速调用拼音标注功能

-- 获取当前选中的文本
tell application "System Events"
    -- 复制选中的文本
    keystroke "c" using command down
    delay 0.2
end tell

-- 获取剪贴板内容
set selectedText to the clipboard

-- 检查是否有选中文本
if selectedText is "" then
    display dialog "请先选中要转换的中文文本" buttons {"确定"} default button 1
    return
end if

-- 获取项目路径 - 根据实际情况修改
-- 默认路径: ~/Desktop/项目开发/08-中文教学项目/拼音标注工具
set projectPath to POSIX path of (path to home folder) & "Desktop/项目开发/08-中文教学项目/拼音标注工具"

-- 运行拼音转换工具
try
    set pythonCommand to "python3 '" & projectPath & "/pinyin_tool.py'"

    -- 在后台运行Python脚本
    do shell script pythonCommand & " &"

    -- 显示成功通知
    display notification "拼音标注工具已启动" with title "拼音工具" subtitle "请在应用中粘贴文本进行转换"
    
on error errorMessage
    display dialog "启动拼音工具失败: " & errorMessage buttons {"确定"} default button 1
end try