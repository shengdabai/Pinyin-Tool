-- 快速拼音转换 AppleScript
-- 直接转换选中文本为拼音并替换

-- 获取当前选中的文本
tell application "System Events"
    keystroke "c" using command down
    delay 0.2
end tell

-- 获取剪贴板内容
set selectedText to the clipboard

-- 检查是否有选中文本
if selectedText is "" then
    display notification "请先选中要转换的中文文本" with title "拼音工具"
    return
end if

-- 调用Python脚本进行拼音转换
try
    set toolPath to (path to home folder as string) & "Programming:拼音标注工具:"
    set pythonScript to "import sys; sys.path.append('" & POSIX path of toolPath & "'); from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('" & selectedText & "', style=Style.TONE)))"
    
    set pinyinResult to do shell script "python3 -c \"" & pythonScript & "\""
    
    -- 将拼音结果复制到剪贴板
    set the clipboard to pinyinResult
    
    -- 粘贴拼音结果
    tell application "System Events"
        keystroke "v" using command down
    end tell
    
    -- 显示成功通知
    display notification "已转换为拼音: " & pinyinResult with title "拼音工具" subtitle "转换完成"
    
on error errorMessage
    display notification "转换失败: " & errorMessage with title "拼音工具" subtitle "错误"
end try