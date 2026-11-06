-- 自动打开系统偏好设置快捷键页面
-- 帮助用户快速找到拼音标注服务的快捷键设置

tell application "System Preferences"
    activate
    
    -- 打开键盘偏好设置面板
    set current pane to pane "com.apple.preference.keyboard"
    
    -- 等待面板加载
    delay 1
    
    tell application "System Events"
        tell process "System Preferences"
            try
                -- 点击快捷键标签
                click button "快捷键" of toolbar 1 of window 1
                delay 1
                
                -- 选择服务分类
                tell outline 1 of scroll area 1 of splitter group 1 of tab group 1 of window 1
                    -- 查找并选择服务行
                    repeat with i from 1 to count of rows
                        if value of static text 1 of UI element 1 of row i contains "服务" then
                            select row i
                            exit repeat
                        end if
                    end repeat
                end tell
                
                delay 1
                
                -- 显示提示对话框
                display dialog "已打开快捷键设置页面！\n\n请按以下步骤设置：\n\n1. 在右侧找到'文本'分类\n2. 找到'拼音标注服务-多格式版本'\n3. 勾选左侧复选框启用服务\n4. 点击右侧设置快捷键为 Cmd+Shift+P\n\n如果快捷键冲突，可以尝试其他组合键。" buttons {"我知道了"} default button "我知道了" with title "设置指南" with icon note
                
            on error errorMessage
                -- 如果自动操作失败，显示手动指南
                display dialog "无法自动导航到设置页面。\n\n请手动操作：\n\n1. 点击'快捷键'标签\n2. 在左侧选择'服务'\n3. 在右侧找到'文本'分类\n4. 找到'拼音标注服务-多格式版本'\n5. 设置快捷键为 Cmd+Shift+P" buttons {"我知道了"} default button "我知道了" with title "手动设置指南" with icon caution
            end try
        end tell
    end tell
end tell