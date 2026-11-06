#!/bin/bash

# 拼音标注服务快捷键问题修复脚本
# 专门解决Cmd+Shift+P没有反应的问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 打印标题
print_title() {
    echo
    print_message $CYAN "=" | tr ' ' '=' | head -c 60
    echo
    print_message $CYAN "          $1"
    print_message $CYAN "=" | tr ' ' '=' | head -c 60
    echo
}

print_title "拼音标注服务快捷键修复"

print_message $BLUE "根据诊断结果，您的服务已正确安装，但需要手动设置快捷键和权限。"
echo

print_message $YELLOW "问题分析:"
print_message $RED "❌ 快捷键未设置或设置错误"
print_message $RED "❌ 系统权限可能不足"
print_message $RED "❌ 右键菜单服务不可见"
echo

print_message $GREEN "解决方案:"
echo

# 步骤1：自动打开系统偏好设置
print_message $CYAN "步骤 1: 设置快捷键"
print_message $BLUE "我将为您自动打开系统偏好设置的快捷键页面..."
echo

read -p "按回车键继续..." 

# 使用AppleScript打开系统偏好设置
osascript << 'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.keyboard"
    delay 2
end tell

tell application "System Events"
    tell process "System Preferences"
        try
            click button "快捷键" of toolbar 1 of window 1
            delay 1
            
            tell outline 1 of scroll area 1 of splitter group 1 of tab group 1 of window 1
                repeat with i from 1 to count of rows
                    if value of static text 1 of UI element 1 of row i contains "服务" then
                        select row i
                        exit repeat
                    end if
                end repeat
            end tell
            
            delay 1
        on error
            -- 如果自动操作失败，继续执行
        end try
    end tell
end tell

display dialog "请按以下步骤设置快捷键：\n\n1. 在左侧选择'服务'\n2. 在右侧找到'文本'分类\n3. 找到'拼音标注服务-多格式版本'\n4. ✅ 勾选左侧复选框启用服务\n5. 点击右侧设置快捷键为 Cmd+Shift+P\n\n设置完成后点击'完成'按钮。" buttons {"完成"} default button "完成" with title "快捷键设置指南" with icon note
EOF

print_message $GREEN "✅ 快捷键设置页面已打开"
echo

# 步骤2：设置权限
print_message $CYAN "步骤 2: 设置系统权限"
print_message $BLUE "现在设置系统权限..."
echo

read -p "按回车键继续..." 

# 打开安全性与隐私设置
osascript << 'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.security"
    delay 2
end tell

tell application "System Events"
    tell process "System Preferences"
        try
            click button "隐私" of toolbar 1 of window 1
            delay 1
        on error
            -- 如果自动操作失败，继续执行
        end try
    end tell
end tell

display dialog "请按以下步骤设置权限：\n\n辅助功能权限：\n1. 在左侧选择'辅助功能'\n2. 点击左下角锁图标并输入密码\n3. 确保以下应用已添加并勾选：\n   - ✅ Automator\n   - ✅ 脚本编辑器\n\n自动化权限：\n1. 在左侧选择'自动化'\n2. 确保相关应用有控制权限\n\n设置完成后点击'完成'按钮。" buttons {"完成"} default button "完成" with title "权限设置指南" with icon note
EOF

print_message $GREEN "✅ 权限设置页面已打开"
echo

# 步骤3：测试功能
print_message $CYAN "步骤 3: 测试功能"
print_message $BLUE "现在测试拼音标注功能是否正常工作..."
echo

print_message $YELLOW "测试方法 1: 快捷键测试"
print_message $BLUE "1. 打开任意文本编辑器（如TextEdit）"
print_message $BLUE "2. 输入测试文本: 中国北京搜狗输入法"
print_message $BLUE "3. 选中这些文字"
print_message $BLUE "4. 按 Cmd+Shift+P"
print_message $BLUE "5. 选择拼音格式"
echo

print_message $YELLOW "测试方法 2: 右键菜单测试"
print_message $BLUE "1. 选中中文文字"
print_message $BLUE "2. 右键点击"
print_message $BLUE "3. 选择'服务' > '拼音标注服务-多格式版本'"
echo

read -p "请完成测试后按回车键继续..." 

echo
read -p "快捷键是否正常工作? (y/n): " shortcut_works

if [[ $shortcut_works =~ ^[Yy]$ ]]; then
    print_message $GREEN "🎉 恭喜！快捷键修复成功！"
    print_message $CYAN "现在您可以在任何应用程序中使用 Cmd+Shift+P 来标注拼音了。"
else
    print_message $YELLOW "⚠️  快捷键仍不工作，让我们尝试其他解决方案..."
    echo
    
    read -p "右键菜单是否可以使用? (y/n): " context_menu_works
    
    if [[ $context_menu_works =~ ^[Yy]$ ]]; then
        print_message $BLUE "右键菜单可用说明服务正常，问题在于快捷键设置。"
        echo
        print_message $YELLOW "可能的解决方案:"
        print_message $CYAN "1. 快捷键冲突 - 尝试其他快捷键组合"
        print_message $CYAN "2. 重启应用程序或系统"
        print_message $CYAN "3. 重新设置快捷键"
        echo
        
        print_message $BLUE "推荐的替代快捷键:"
        print_message $GREEN "- Cmd+Shift+Y (拼音的Y)"
        print_message $GREEN "- Cmd+Option+P"
        print_message $GREEN "- Cmd+Control+P"
        
    else
        print_message $RED "服务可能未正确安装或权限不足。"
        print_message $YELLOW "建议重新运行安装脚本: ./start_install.sh"
    fi
fi

echo
print_message $CYAN "修复脚本执行完成。"
print_message $BLUE "如果问题仍然存在，请查看 QUICK_FIX_GUIDE.md 获取更多帮助。"
echo