#!/bin/bash

# 快速修复拼音标注服务脚本
# 直接修复现有服务，确保不覆盖原文并添加准确拼音

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

# 检查现有服务
check_existing_services() {
    print_title "检查现有服务"
    
    local services_dir="$HOME/Library/Services"
    local found_services=()
    
    if [ -d "$services_dir" ]; then
        while IFS= read -r -d '' service; do
            if [[ "$(basename "$service")" == *拼音* ]]; then
                found_services+=("$service")
            fi
        done < <(find "$services_dir" -name "*.workflow" -type d -print0 2>/dev/null)
    fi
    
    if [ ${#found_services[@]} -eq 0 ]; then
        print_message $RED "❌ 未找到拼音标注服务"
        print_message $YELLOW "请先运行安装脚本创建服务"
        return 1
    fi
    
    print_message $GREEN "✅ 找到以下拼音标注服务:"
    for service in "${found_services[@]}"; do
        local service_name=$(basename "$service" .workflow)
        print_message $BLUE "  - $service_name"
    done
    
    # 返回最新的服务路径
    echo "${found_services[-1]}"
}

# 测试拼音转换
test_pinyin_conversion() {
    print_title "测试拼音转换功能"
    
    local test_text="中国北京搜狗输入法"
    
    print_message $BLUE "测试Python拼音转换:"
    
    # 测试标准声调
    local result
    result=$(python3 -c "from pypinyin import lazy_pinyin, Style; import sys; text = '$test_text'; result = ' '.join(lazy_pinyin(text, style=Style.TONE, v_to_u=True)); print(result)" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        print_message $GREEN "✅ 输入: $test_text"
        print_message $GREEN "✅ 拼音: $result"
        print_message $GREEN "✅ 期望输出: $test_text ($result)"
        return 0
    else
        print_message $RED "❌ 拼音转换失败"
        print_message $YELLOW "请检查pypinyin库安装: pip3 install pypinyin"
        return 1
    fi
}

# 创建修复后的AppleScript
create_fixed_applescript() {
    local output_file="$1"
    
    cat > "$output_file" << 'EOF'
-- 拼音标注服务 - 修复版本
-- 确保不覆盖原文，在原文后添加拼音标注
-- 格式：原文 (拼音)

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
        -- 构建Python命令，确保使用正确的拼音库和参数
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
        -- 详细的错误处理
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        
        -- 记录错误到系统日志
        set logMessage to "拼音标注服务错误: " & errorMessage
        try
            do shell script "printf '%s\\n' " & quoted form of logMessage & " >> ~/Library/Logs/pinyin_service.log"
        on error
            -- Logging must not prevent returning the original text.
        end try
        
        -- 返回原文，不做修改
        return inputText
    end try
end run
EOF
}

# 提供手动修复指导
provide_manual_fix_guide() {
    local applescript_file="$1"
    
    print_title "手动修复指导"
    
    print_message $YELLOW "由于系统权限限制，需要手动完成以下步骤:"
    echo
    
    print_message $CYAN "步骤 1: 打开脚本编辑器"
    print_message $BLUE "  - 打开应用程序 > 实用工具 > 脚本编辑器"
    print_message $BLUE "  - 或者直接双击: $applescript_file"
    echo
    
    print_message $CYAN "步骤 2: 复制修复后的代码"
    print_message $BLUE "  - 全选脚本编辑器中的内容 (Cmd+A)"
    print_message $BLUE "  - 粘贴修复后的代码 (Cmd+V)"
    print_message $BLUE "  - 点击'编译'按钮验证代码"
    echo
    
    print_message $CYAN "步骤 3: 打开Automator"
    print_message $BLUE "  - 打开应用程序 > Automator"
    print_message $BLUE "  - 文件 > 打开 > 选择现有的拼音标注服务"
    echo
    
    print_message $CYAN "步骤 4: 替换AppleScript代码"
    print_message $BLUE "  - 找到'运行AppleScript'动作"
    print_message $BLUE "  - 全选代码框中的内容"
    print_message $BLUE "  - 粘贴修复后的代码"
    print_message $BLUE "  - 保存服务 (Cmd+S)"
    echo
    
    print_message $CYAN "步骤 5: 测试服务"
    print_message $BLUE "  - 在任意应用中选中中文文本"
    print_message $BLUE "  - 按快捷键 Cmd+Shift+P"
    print_message $BLUE "  - 选择拼音格式"
    print_message $BLUE "  - 验证输出格式: 原文 (拼音)"
    
    # 自动打开相关应用
    print_message $YELLOW "\n正在打开脚本编辑器..."
    open -a "Script Editor" "$applescript_file"
    
    sleep 2
    print_message $YELLOW "正在打开Automator..."
    open -a Automator
}

# 创建测试脚本
create_test_script() {
    local test_file="test_service_manual.sh"
    
    cat > "$test_file" << 'EOF'
#!/bin/bash

# 手动测试拼音标注服务

echo "🧪 拼音标注服务手动测试"
echo "========================"
echo

echo "📋 测试步骤:"
echo "1. 打开任意文本编辑器（如TextEdit）"
echo "2. 输入测试文本: 中国北京搜狗输入法双拼"
echo "3. 选中这些文本"
echo "4. 按快捷键 Cmd+Shift+P"
echo "5. 选择'标准声调'格式"
echo "6. 验证结果是否为: 中国北京搜狗输入法双拼 (zhōng guó běi jīng sōu gǒu shū rù fǎ shuāng pīn)"
echo

echo "✅ 期望结果:"
echo "   输入: 中国北京搜狗输入法双拼"
echo "   输出: 中国北京搜狗输入法双拼 (zhōng guó běi jīng sōu gǒu shū rù fǎ shuāng pīn)"
echo

echo "❌ 如果不工作，请检查:"
echo "   - 快捷键是否正确设置"
echo "   - 服务是否启用"
echo "   - 系统权限是否授予"
echo

read -p "按回车键打开TextEdit进行测试..."
open -a TextEdit
EOF
    
    chmod +x "$test_file"
    print_message $GREEN "✅ 创建测试脚本: $test_file"
}

# 主函数
main() {
    print_title "拼音标注服务快速修复"
    
    print_message $CYAN "此工具将修复现有的拼音标注服务"
    print_message $CYAN "确保不覆盖原文，添加准确的拼音标注"
    echo
    
    # 检查依赖
    if ! command -v python3 &> /dev/null; then
        print_message $RED "❌ Python3 未安装"
        exit 1
    fi
    
    if ! python3 -c "import pypinyin" &> /dev/null; then
        print_message $RED "❌ pypinyin库未安装"
        print_message $YELLOW "正在安装pypinyin..."
        pip3 install pypinyin
    fi
    
    # 测试拼音转换
    if ! test_pinyin_conversion; then
        exit 1
    fi
    
    # 检查现有服务
    local service_path
    service_path=$(check_existing_services)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # 创建修复后的AppleScript
    local fixed_script="fixed_pinyin_service.scpt"
    create_fixed_applescript "$fixed_script"
    print_message $GREEN "✅ 创建修复后的AppleScript: $fixed_script"
    
    # 创建测试脚本
    create_test_script
    
    # 提供手动修复指导
    provide_manual_fix_guide "$fixed_script"
    
    print_title "修复完成"
    print_message $GREEN "🎉 拼音标注服务修复脚本已准备完成！"
    print_message $YELLOW "请按照上述指导完成手动修复步骤"
    print_message $CYAN "修复后的服务将输出格式: 原文 (拼音)"
    
    echo
    read -p "修复完成后按回车键运行测试..."
    ./test_service_manual.sh
}

# 运行主函数
main "$@"
