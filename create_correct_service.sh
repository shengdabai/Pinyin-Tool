#!/bin/bash

# 创建正确的拼音标注服务脚本
# 确保不覆盖原文，添加准确的拼音标注

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_title() {
    echo
    print_message $CYAN "=" | tr ' ' '=' | head -c 60
    echo
    print_message $CYAN "          $1"
    print_message $CYAN "=" | tr ' ' '=' | head -c 60
    echo
}

# 检查依赖
check_dependencies() {
    print_title "检查系统依赖"
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        print_message $RED "❌ Python3 未安装"
        exit 1
    fi
    print_message $GREEN "✅ Python3 已安装: $(python3 --version)"
    
    # 检查pypinyin
    if ! python3 -c "import pypinyin" &> /dev/null; then
        print_message $YELLOW "⚠️  pypinyin 未安装，正在安装..."
        pip3 install pypinyin
    fi
    print_message $GREEN "✅ pypinyin 已安装: $(python3 -c 'import pypinyin; print(pypinyin.__version__)')"
}

# 创建AppleScript代码
create_applescript() {
    cat << 'EOF'
-- 拼音标注服务 - 保留原文版本
-- 在原文后添加拼音标注，格式：中文 (拼音)

on run {input, parameters}
    set inputText to input as string
    
    -- 检查输入是否为空
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    -- 让用户选择拼音风格
    set styleChoice to choose from list {"标准声调 (zhōng guó)", "数字声调 (zhong1 guo2)", "无声调 (zhong guo)", "首字母 (z g)"} with prompt "选择拼音风格：" default items {"标准声调 (zhōng guó)"}
    
    if styleChoice is false then
        return inputText
    end if
    
    -- 根据选择设置样式
    set selectedStyle to item 1 of styleChoice
    if selectedStyle contains "标准声调" then
        set pinyinStyle to "Style.TONE"
    else if selectedStyle contains "数字声调" then
        set pinyinStyle to "Style.TONE3"
    else if selectedStyle contains "无声调" then
        set pinyinStyle to "Style.NORMAL"
    else if selectedStyle contains "首字母" then
        set pinyinStyle to "Style.FIRST_LETTER"
    end if
    
    try
        -- 构建Python命令，确保使用正确的拼音库
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=" & pinyinStyle & ", v_to_u=True)); print(result)\" " & quoted form of inputText
        
        -- 执行Python脚本获取拼音
        set pinyinResult to do shell script pythonCommand
        
        -- 组合原文和拼音，格式：原文 (拼音)
        set finalResult to inputText & " (" & pinyinResult & ")"
        
        -- 显示成功通知
        display notification "标注完成: " & pinyinResult with title "拼音标注服务" subtitle "成功"
        
        -- 返回组合结果
        return finalResult
        
    on error errorMessage
        -- 错误处理
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        return inputText
    end try
end run
EOF
}

# 创建Automator工作流
create_automator_service() {
    print_title "创建Automator服务"
    
    local service_name="拼音标注服务-正确版本"
    local temp_dir
    temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/pinyin_service.XXXXXX") || return 1
    local temp_script="$temp_dir/pinyin_service.scpt"
    
    # 创建AppleScript文件
    (umask 077; create_applescript > "$temp_script") || return 1
    
    print_message $BLUE "创建的AppleScript代码已保存到: $temp_script"
    print_message $YELLOW "请按照以下步骤手动创建Automator服务:"
    echo
    
    print_message $CYAN "步骤 1: 打开Automator"
    print_message $BLUE "  - 打开应用程序 > Automator"
    print_message $BLUE "  - 选择'服务'模板"
    echo
    
    print_message $CYAN "步骤 2: 配置服务设置"
    print_message $BLUE "  - '服务收到选定的': 文本"
    print_message $BLUE "  - '位于': 任何应用程序"
    echo
    
    print_message $CYAN "步骤 3: 添加AppleScript动作"
    print_message $BLUE "  - 从左侧拖拽'运行AppleScript'到工作流"
    print_message $BLUE "  - 复制以下文件内容到代码框: $temp_script"
    echo
    
    print_message $CYAN "步骤 4: 保存服务"
    print_message $BLUE "  - 文件 > 存储"
    print_message $BLUE "  - 服务名称: $service_name"
    echo
    
    # 自动打开相关应用
    print_message $YELLOW "正在打开Automator..."
    open -a Automator
    
    print_message $YELLOW "正在打开AppleScript文件..."
    open -a "Script Editor" "$temp_script"
    
    echo
    read -p "完成Automator服务创建后按回车键继续..."
}

# 测试服务功能
test_service() {
    print_title "测试拼音转换功能"
    
    local test_texts=("测试" "中国" "搜狗输入法" "双拼")
    
    print_message $BLUE "测试Python拼音转换:"
    
    for text in "${test_texts[@]}"; do
        echo -n "$text -> "
        
        # 测试标准声调
        local result
        result=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$text', style=Style.TONE, v_to_u=True)))" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$result" ]; then
            print_message $GREEN "$text ($result) ✅"
        else
            print_message $RED "转换失败 ❌"
        fi
    done
    
    echo
    print_message $CYAN "预期的服务输出格式:"
    print_message $GREEN "输入: 中国北京"
    print_message $GREEN "输出: 中国北京 (zhōng guó běi jīng)"
}

# 设置快捷键指导
setup_shortcut_guide() {
    print_title "设置快捷键指导"
    
    print_message $YELLOW "请按照以下步骤设置快捷键:"
    echo
    
    print_message $CYAN "1. 打开系统偏好设置"
    print_message $BLUE "   - 系统偏好设置 > 键盘 > 快捷键 > 服务"
    echo
    
    print_message $CYAN "2. 找到拼音标注服务"
    print_message $BLUE "   - 在'文本'分类下找到'拼音标注服务-正确版本'"
    print_message $BLUE "   - 勾选左侧复选框启用服务"
    echo
    
    print_message $CYAN "3. 设置快捷键"
    print_message $BLUE "   - 点击右侧设置快捷键为: Cmd+Shift+P"
    print_message $BLUE "   - 如果冲突，可以使用: Cmd+Shift+Y"
    echo
    
    print_message $CYAN "4. 测试功能"
    print_message $BLUE "   - 在任意应用中选中中文文本"
    print_message $BLUE "   - 按设置的快捷键"
    print_message $BLUE "   - 选择拼音格式"
    print_message $BLUE "   - 验证结果格式: 原文 (拼音)"
    
    # 自动打开系统偏好设置
    print_message $YELLOW "正在打开系统偏好设置..."
    open "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts"
}

# 主函数
main() {
    print_title "拼音标注服务修复工具"
    
    print_message $CYAN "此工具将创建正确的拼音标注服务"
    print_message $CYAN "确保不覆盖原文，添加准确的拼音标注"
    echo
    
    # 检查依赖
    check_dependencies
    
    # 测试拼音转换
    test_service
    
    # 创建服务
    create_automator_service
    
    # 设置指导
    setup_shortcut_guide
    
    print_title "完成"
    print_message $GREEN "🎉 拼音标注服务修复完成！"
    print_message $YELLOW "请按照上述指导完成快捷键设置和测试"
}

# 运行主函数
main "$@"
