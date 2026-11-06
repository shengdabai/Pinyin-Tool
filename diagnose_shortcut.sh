#!/bin/bash

# 拼音标注服务快捷键诊断脚本
# 交互式诊断和修复Cmd+Shift+P快捷键问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 服务名称
SERVICE_NAME="拼音标注服务-多格式版本"
SERVICE_PATH="$HOME/Library/Services/${SERVICE_NAME}.workflow"

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

# 检查服务是否存在
check_service_exists() {
    print_message $BLUE "[检查] 验证Automator服务是否存在..."
    
    if [ -d "$SERVICE_PATH" ]; then
        print_message $GREEN "✅ 服务已安装: $SERVICE_PATH"
        return 0
    else
        print_message $RED "❌ 服务未找到: $SERVICE_PATH"
        return 1
    fi
}

# 检查pypinyin库
check_pypinyin() {
    print_message $BLUE "[检查] 验证pypinyin库..."
    
    if python3 -c "import pypinyin; print('pypinyin version:', pypinyin.__version__)" 2>/dev/null; then
        print_message $GREEN "✅ pypinyin库正常工作"
        return 0
    else
        print_message $RED "❌ pypinyin库未安装或有问题"
        return 1
    fi
}

# 测试Python脚本功能
test_python_conversion() {
    print_message $BLUE "[测试] 验证拼音转换功能..."
    
    local test_text="测试"
    local result
    
    result=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$test_text', style=Style.TONE)))" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        print_message $GREEN "✅ 拼音转换正常: $test_text -> $result"
        return 0
    else
        print_message $RED "❌ 拼音转换失败"
        return 1
    fi
}

# 检查快捷键设置
check_shortcut_settings() {
    print_message $BLUE "[检查] 验证快捷键设置..."
    
    # 检查plist文件中的快捷键设置
    local plist_file="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
    
    if [ -f "$plist_file" ]; then
        print_message $YELLOW "⚠️  快捷键设置需要手动验证"
        print_message $CYAN "请检查: 系统偏好设置 > 键盘 > 快捷键 > 服务"
        return 1
    else
        print_message $RED "❌ 快捷键配置文件未找到"
        return 1
    fi
}

# 检查系统权限
check_permissions() {
    print_message $BLUE "[检查] 验证系统权限..."
    
    # 检查辅助功能权限（这个需要用户手动验证）
    print_message $YELLOW "⚠️  系统权限需要手动验证:"
    print_message $CYAN "1. 系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能"
    print_message $CYAN "2. 确保Automator和脚本编辑器已添加并勾选"
    print_message $CYAN "3. 系统偏好设置 > 安全性与隐私 > 隐私 > 自动化"
    print_message $CYAN "4. 确保相关应用有控制权限"
    
    return 1
}

# 测试右键菜单
test_context_menu() {
    print_message $BLUE "[测试] 检查右键菜单服务..."
    
    print_message $YELLOW "请手动测试:"
    print_message $CYAN "1. 在任意应用中选中一些中文文本"
    print_message $CYAN "2. 右键点击选中的文本"
    print_message $CYAN "3. 查看是否有'服务'菜单"
    print_message $CYAN "4. 在服务菜单中查找'$SERVICE_NAME'"
    
    echo
    read -p "右键菜单中是否能看到拼音标注服务? (y/n): " context_menu_visible
    
    if [[ $context_menu_visible =~ ^[Yy]$ ]]; then
        print_message $GREEN "✅ 右键菜单服务可见"
        return 0
    else
        print_message $RED "❌ 右键菜单服务不可见"
        return 1
    fi
}

# 修复pypinyin库
fix_pypinyin() {
    print_message $YELLOW "[修复] 安装pypinyin库..."
    
    if pip3 install pypinyin; then
        print_message $GREEN "✅ pypinyin库安装成功"
        return 0
    else
        print_message $RED "❌ pypinyin库安装失败"
        return 1
    fi
}

# 打开系统偏好设置
open_system_preferences() {
    print_message $YELLOW "[操作] 打开系统偏好设置..."
    
    # 使用AppleScript打开快捷键设置
    osascript << 'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.keyboard"
    delay 1
    tell application "System Events"
        tell process "System Preferences"
            click button "快捷键" of toolbar 1 of window 1
            delay 1
            tell outline 1 of scroll area 1 of splitter group 1 of tab group 1 of window 1
                select row 8 -- 服务
            end tell
        end tell
    end tell
end tell
EOF
    
    print_message $GREEN "✅ 已打开快捷键设置页面"
    print_message $CYAN "请在左侧选择'服务'，然后在右侧找到'文本'分类下的'$SERVICE_NAME'"
}

# 提供手动设置指南
show_manual_setup_guide() {
    print_title "手动设置快捷键指南"
    
    print_message $CYAN "步骤 1: 打开系统偏好设置"
    print_message $YELLOW "  - 点击苹果菜单 > 系统偏好设置"
    print_message $YELLOW "  - 或按 Cmd+Space 搜索'系统偏好设置'"
    
    echo
    print_message $CYAN "步骤 2: 进入键盘设置"
    print_message $YELLOW "  - 点击'键盘'图标"
    print_message $YELLOW "  - 点击'快捷键'标签"
    
    echo
    print_message $CYAN "步骤 3: 找到服务设置"
    print_message $YELLOW "  - 在左侧列表中点击'服务'"
    print_message $YELLOW "  - 在右侧找到'文本'分类"
    
    echo
    print_message $CYAN "步骤 4: 设置快捷键"
    print_message $YELLOW "  - 找到'$SERVICE_NAME'"
    print_message $YELLOW "  - 勾选左侧的复选框启用服务"
    print_message $YELLOW "  - 点击右侧的'无'或现有快捷键"
    print_message $YELLOW "  - 按下 Cmd+Shift+P 设置快捷键"
    
    echo
    print_message $CYAN "步骤 5: 验证设置"
    print_message $YELLOW "  - 关闭系统偏好设置"
    print_message $YELLOW "  - 在任意应用中选中中文文本"
    print_message $YELLOW "  - 按 Cmd+Shift+P 测试"
    
    echo
    read -p "是否需要自动打开系统偏好设置? (y/n): " open_prefs
    
    if [[ $open_prefs =~ ^[Yy]$ ]]; then
        open_system_preferences
    fi
}

# 提供替代快捷键方案
show_alternative_shortcuts() {
    print_title "替代快捷键方案"
    
    print_message $CYAN "如果 Cmd+Shift+P 冲突，可以尝试以下快捷键:"
    echo
    print_message $YELLOW "推荐选项:"
    print_message $GREEN "  - Cmd+Shift+Y (拼音的Y)"
    print_message $GREEN "  - Cmd+Option+P"
    print_message $GREEN "  - Cmd+Control+P"
    print_message $GREEN "  - Cmd+Shift+Z"
    
    echo
    print_message $YELLOW "其他选项:"
    print_message $BLUE "  - F1-F12 功能键"
    print_message $BLUE "  - Cmd+Shift+数字键"
    print_message $BLUE "  - Cmd+Option+字母键"
    
    echo
    print_message $CYAN "设置方法相同，只需在快捷键设置时按下不同的组合键即可。"
}

# 创建测试脚本
create_test_script() {
    local test_script="test_pinyin_service.sh"
    
    print_message $BLUE "[创建] 生成测试脚本..."
    
cat > "$test_script" << 'EOF'
#!/bin/bash

# 拼音标注服务测试脚本

echo "=== 拼音标注服务功能测试 ==="
echo

# 测试文本
test_texts=("测试" "中国" "拼音标注" "搜狗输入法")

echo "测试拼音转换功能:"
for text in "${test_texts[@]}"; do
    echo -n "$text -> "
    result=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$text', style=Style.TONE)))" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$result ✅"
    else
        echo "转换失败 ❌"
    fi
done

echo
echo "请手动测试快捷键功能:"
echo "1. 在任意应用中选中上述测试文本"
echo "2. 按 Cmd+Shift+P (或您设置的快捷键)"
echo "3. 选择拼音格式"
echo "4. 验证文本是否正确转换为拼音"
EOF

    chmod +x "$test_script"
    print_message $GREEN "✅ 测试脚本已创建: $test_script"
    
    echo
    read -p "是否立即运行测试脚本? (y/n): " run_test
    
    if [[ $run_test =~ ^[Yy]$ ]]; then
        ./$test_script
    fi
}

# 主诊断流程
main_diagnosis() {
    print_title "拼音标注服务快捷键诊断"
    
    local issues_found=0
    
    # 检查服务存在
    if ! check_service_exists; then
        ((issues_found++))
        print_message $RED "请先运行安装脚本: ./start_install.sh"
        return 1
    fi
    
    # 检查pypinyin库
    if ! check_pypinyin; then
        ((issues_found++))
        echo
        read -p "是否立即修复pypinyin库? (y/n): " fix_lib
        if [[ $fix_lib =~ ^[Yy]$ ]]; then
            fix_pypinyin
        fi
    fi
    
    # 测试Python转换功能
    if ! test_python_conversion; then
        ((issues_found++))
    fi
    
    # 检查快捷键设置
    if ! check_shortcut_settings; then
        ((issues_found++))
    fi
    
    # 检查权限
    if ! check_permissions; then
        ((issues_found++))
    fi
    
    # 测试右键菜单
    echo
    if ! test_context_menu; then
        ((issues_found++))
    fi
    
    # 总结诊断结果
    echo
    print_title "诊断结果总结"
    
    if [ $issues_found -eq 0 ]; then
        print_message $GREEN "🎉 所有检查都通过了！"
        print_message $CYAN "如果快捷键仍然不工作，可能是快捷键冲突问题。"
    else
        print_message $YELLOW "⚠️  发现 $issues_found 个问题需要解决"
    fi
    
    return $issues_found
}

# 交互式菜单
show_menu() {
    while true; do
        print_title "快捷键问题诊断和修复工具"
        
        echo "请选择操作:"
        echo
        print_message $CYAN "1. 🔍 完整诊断 (推荐)"
        print_message $CYAN "2. 📖 手动设置指南"
        print_message $CYAN "3. ⚙️  打开系统偏好设置"
        print_message $CYAN "4. 🔄 替代快捷键方案"
        print_message $CYAN "5. 🧪 创建测试脚本"
        print_message $CYAN "6. 🔧 仅修复pypinyin库"
        print_message $CYAN "0. ❌ 退出"
        echo
        
        read -p "请输入选项 (0-6): " choice
        
        case $choice in
            1)
                main_diagnosis
                ;;
            2)
                show_manual_setup_guide
                ;;
            3)
                open_system_preferences
                ;;
            4)
                show_alternative_shortcuts
                ;;
            5)
                create_test_script
                ;;
            6)
                fix_pypinyin
                ;;
            0)
                print_message $GREEN "再见！"
                exit 0
                ;;
            *)
                print_message $RED "无效选项，请重新选择"
                ;;
        esac
        
        echo
        read -p "按回车键返回主菜单..." 
    done
}

# 脚本入口
if [ "$1" = "--auto" ]; then
    # 自动模式，直接运行完整诊断
    main_diagnosis
else
    # 交互模式
    show_menu
fi