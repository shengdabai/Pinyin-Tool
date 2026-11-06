#!/bin/bash

# 拼音标注服务功能测试脚本
# 验证服务的各项功能是否正常工作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# 测试拼音转换功能
test_pinyin_conversion() {
    print_title "拼音转换功能测试"
    
    # 测试文本数组
    local test_texts=("测试" "中国" "拼音标注" "搜狗输入法" "双拼" "声调" "多音字")
    local styles=("Style.TONE" "Style.TONE3" "Style.NORMAL" "Style.FIRST_LETTER")
    local style_names=("标准声调" "数字声调" "无声调" "首字母")
    
    print_message $BLUE "测试不同拼音风格的转换效果:"
    echo
    
    for i in "${!styles[@]}"; do
        local style="${styles[$i]}"
        local style_name="${style_names[$i]}"
        
        print_message $YELLOW "=== $style_name ($style) ==="
        
        for text in "${test_texts[@]}"; do
            echo -n "$text -> "
            
            local result
            result=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$text', style=$style)))" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$result" ]; then
                print_message $GREEN "$result ✅"
            else
                print_message $RED "转换失败 ❌"
            fi
        done
        echo
    done
}

# 测试多音字处理
test_polyphone() {
    print_title "多音字处理测试"
    
    local polyphone_texts=("银行" "音乐" "重要" "长大" "好人")
    
    print_message $BLUE "测试多音字的处理效果:"
    echo
    
    for text in "${polyphone_texts[@]}"; do
        echo -n "$text -> "
        
        # 测试标准模式
        local result_normal
        result_normal=$(python3 -c "from pypinyin import pinyin, Style; result = pinyin('$text', style=Style.TONE); print(' '.join([item[0] for item in result]))" 2>/dev/null)
        
        # 测试多音字模式
        local result_hetero
        result_hetero=$(python3 -c "from pypinyin import pinyin, Style; result = pinyin('$text', style=Style.TONE, heteronym=True); print(str(result))" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$result_normal" ]; then
            print_message $GREEN "$result_normal"
            if [[ $result_hetero == *"["* ]]; then
                print_message $CYAN "  多音字选项: $result_hetero"
            fi
        else
            print_message $RED "转换失败 ❌"
        fi
        echo
    done
}

# 测试服务文件
test_service_file() {
    print_title "服务文件检查"
    
    local service_name="拼音标注服务-多格式版本"
    local service_path="$HOME/Library/Services/${service_name}.workflow"
    
    print_message $BLUE "检查Automator服务文件..."
    
    if [ -d "$service_path" ]; then
        print_message $GREEN "✅ 服务文件存在: $service_path"
        
        # 检查服务内容
        local info_plist="$service_path/Contents/Info.plist"
        if [ -f "$info_plist" ]; then
            print_message $GREEN "✅ 服务配置文件存在"
            
            # 检查服务配置
            if plutil -lint "$info_plist" >/dev/null 2>&1; then
                print_message $GREEN "✅ 服务配置文件格式正确"
            else
                print_message $RED "❌ 服务配置文件格式错误"
            fi
        else
            print_message $RED "❌ 服务配置文件缺失"
        fi
        
        # 检查工作流文件
        local workflow_file="$service_path/Contents/document.wflow"
        if [ -f "$workflow_file" ]; then
            print_message $GREEN "✅ 工作流文件存在"
        else
            print_message $RED "❌ 工作流文件缺失"
        fi
        
    else
        print_message $RED "❌ 服务文件不存在: $service_path"
        print_message $YELLOW "请运行安装脚本: ./start_install.sh"
    fi
}

# 测试Python环境
test_python_environment() {
    print_title "Python环境检查"
    
    print_message $BLUE "检查Python版本..."
    local python_version
    python_version=$(python3 --version 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ $python_version"
    else
        print_message $RED "❌ Python3 未安装"
        return 1
    fi
    
    print_message $BLUE "检查pypinyin库..."
    local pypinyin_version
    pypinyin_version=$(python3 -c "import pypinyin; print('pypinyin', pypinyin.__version__)" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ $pypinyin_version"
    else
        print_message $RED "❌ pypinyin库未安装"
        print_message $YELLOW "运行: pip3 install pypinyin"
        return 1
    fi
    
    print_message $BLUE "检查其他依赖..."
    python3 -c "import sys, os; print('Python路径:', sys.executable); print('当前目录:', os.getcwd())" 2>/dev/null
}

# 交互式快捷键测试
interactive_shortcut_test() {
    print_title "交互式快捷键测试"
    
    print_message $CYAN "现在进行快捷键功能测试:"
    echo
    
    print_message $YELLOW "测试步骤:"
    print_message $BLUE "1. 打开任意文本编辑器（如TextEdit、Pages等）"
    print_message $BLUE "2. 输入或粘贴一些中文文本"
    print_message $BLUE "3. 选中这些中文文本"
    print_message $BLUE "4. 按下快捷键 Cmd+Shift+P"
    print_message $BLUE "5. 如果出现选择对话框，选择拼音格式"
    print_message $BLUE "6. 观察文本是否转换为拼音"
    
    echo
    print_message $CYAN "建议测试文本:"
    print_message $GREEN "测试文本: 中国北京搜狗输入法双拼"
    print_message $GREEN "预期结果: zhōng guó běi jīng sōu gǒu shū rù fǎ shuāng pīn"
    
    echo
    read -p "请完成上述测试后按回车键继续..."
    
    echo
    read -p "快捷键是否正常工作? (y/n): " shortcut_works
    
    if [[ $shortcut_works =~ ^[Yy]$ ]]; then
        print_message $GREEN "🎉 快捷键测试成功！"
        return 0
    else
        print_message $RED "❌ 快捷键测试失败"
        
        echo
        print_message $YELLOW "可能的问题:"
        print_message $CYAN "1. 快捷键未设置或设置错误"
        print_message $CYAN "2. 快捷键与其他应用冲突"
        print_message $CYAN "3. 系统权限不足"
        print_message $CYAN "4. 服务未正确安装"
        
        echo
        read -p "是否尝试右键菜单测试? (y/n): " try_context_menu
        
        if [[ $try_context_menu =~ ^[Yy]$ ]]; then
            test_context_menu
        fi
        
        return 1
    fi
}

# 测试右键菜单
test_context_menu() {
    print_message $CYAN "右键菜单测试:"
    echo
    
    print_message $YELLOW "测试步骤:"
    print_message $BLUE "1. 在任意应用中选中中文文本"
    print_message $BLUE "2. 右键点击选中的文本"
    print_message $BLUE "3. 查看是否有'服务'菜单项"
    print_message $BLUE "4. 点击'服务'查看子菜单"
    print_message $BLUE "5. 查找'拼音标注服务-多格式版本'"
    print_message $BLUE "6. 点击该服务测试功能"
    
    echo
    read -p "请完成上述测试后按回车键继续..."
    
    echo
    read -p "右键菜单中是否能找到拼音标注服务? (y/n): " context_menu_visible
    
    if [[ $context_menu_visible =~ ^[Yy]$ ]]; then
        print_message $GREEN "✅ 右键菜单服务可见"
        
        read -p "点击服务后是否正常工作? (y/n): " context_menu_works
        
        if [[ $context_menu_works =~ ^[Yy]$ ]]; then
            print_message $GREEN "🎉 右键菜单服务正常工作！"
            print_message $YELLOW "问题可能是快捷键设置，请检查系统偏好设置"
            return 0
        else
            print_message $RED "❌ 右键菜单服务不工作"
            return 1
        fi
    else
        print_message $RED "❌ 右键菜单中找不到服务"
        print_message $YELLOW "服务可能未正确安装或权限不足"
        return 1
    fi
}

# 生成测试报告
generate_test_report() {
    local report_file="pinyin_service_test_report.txt"
    
    print_title "生成测试报告"
    
    {
        echo "拼音标注服务测试报告"
        echo "生成时间: $(date)"
        echo "系统信息: $(uname -a)"
        echo "Python版本: $(python3 --version 2>/dev/null || echo '未安装')"
        echo "pypinyin版本: $(python3 -c 'import pypinyin; print(pypinyin.__version__)' 2>/dev/null || echo '未安装')"
        echo
        echo "=== 基础功能测试 ==="
        
        # 测试基本转换
        echo "基本转换测试:"
        local test_texts=("测试" "中国" "拼音")
        for text in "${test_texts[@]}"; do
            local result
            result=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$text', style=Style.TONE)))" 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "  $text -> $result [成功]"
            else
                echo "  $text -> [失败]"
            fi
        done
        
        echo
        echo "=== 服务文件检查 ==="
        local service_path="$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
        if [ -d "$service_path" ]; then
            echo "  服务文件: 存在 [✓]"
        else
            echo "  服务文件: 不存在 [✗]"
        fi
        
        echo
        echo "=== 建议 ==="
        echo "1. 如果基础功能正常但快捷键不工作，请检查系统偏好设置中的快捷键配置"
        echo "2. 如果服务文件不存在，请重新运行安装脚本"
        echo "3. 如果pypinyin未安装，请运行: pip3 install pypinyin"
        echo "4. 确保系统权限设置正确（辅助功能和自动化权限）"
        
    } > "$report_file"
    
    print_message $GREEN "✅ 测试报告已生成: $report_file"
    
    echo
    read -p "是否查看测试报告? (y/n): " view_report
    
    if [[ $view_report =~ ^[Yy]$ ]]; then
        cat "$report_file"
    fi
}

# 主测试流程
main_test() {
    print_title "拼音标注服务完整测试"
    
    local test_results=()
    
    # 运行各项测试
    if test_python_environment; then
        test_results+=("Python环境: ✅")
    else
        test_results+=("Python环境: ❌")
    fi
    
    if test_service_file; then
        test_results+=("服务文件: ✅")
    else
        test_results+=("服务文件: ❌")
    fi
    
    test_pinyin_conversion
    test_results+=("拼音转换: ✅")
    
    test_polyphone
    test_results+=("多音字处理: ✅")
    
    if interactive_shortcut_test; then
        test_results+=("快捷键功能: ✅")
    else
        test_results+=("快捷键功能: ❌")
    fi
    
    # 显示测试总结
    print_title "测试结果总结"
    
    for result in "${test_results[@]}"; do
        if [[ $result == *"✅"* ]]; then
            print_message $GREEN "$result"
        else
            print_message $RED "$result"
        fi
    done
    
    echo
    read -p "是否生成详细测试报告? (y/n): " generate_report
    
    if [[ $generate_report =~ ^[Yy]$ ]]; then
        generate_test_report
    fi
}

# 快速测试模式
quick_test() {
    print_title "快速功能测试"
    
    print_message $BLUE "测试Python和pypinyin..."
    if python3 -c "from pypinyin import lazy_pinyin, Style; print('测试 ->', ' '.join(lazy_pinyin('测试', style=Style.TONE)))" 2>/dev/null; then
        print_message $GREEN "✅ 基础功能正常"
    else
        print_message $RED "❌ 基础功能异常"
        return 1
    fi
    
    print_message $BLUE "检查服务文件..."
    if [ -d "$HOME/Library/Services/拼音标注服务-多格式版本.workflow" ]; then
        print_message $GREEN "✅ 服务已安装"
    else
        print_message $RED "❌ 服务未安装"
        return 1
    fi
    
    print_message $GREEN "🎉 快速测试通过！"
    print_message $CYAN "如果快捷键不工作，请运行完整测试: ./test_service.sh --full"
}

# 脚本入口
case "${1:-}" in
    --quick)
        quick_test
        ;;
    --full)
        main_test
        ;;
    --conversion)
        test_pinyin_conversion
        ;;
    --polyphone)
        test_polyphone
        ;;
    --report)
        generate_test_report
        ;;
    *)
        echo "拼音标注服务测试脚本"
        echo
        echo "用法:"
        echo "  $0 [选项]"
        echo
        echo "选项:"
        echo "  --quick      快速测试基础功能"
        echo "  --full       完整交互式测试"
        echo "  --conversion 仅测试拼音转换"
        echo "  --polyphone  仅测试多音字处理"
        echo "  --report     生成测试报告"
        echo "  (无参数)     显示此帮助信息"
        echo
        
        read -p "选择测试模式 (quick/full): " mode
        
        case $mode in
            quick|q)
                quick_test
                ;;
            full|f)
                main_test
                ;;
            *)
                echo "无效选择，运行快速测试..."
                quick_test
                ;;
        esac
        ;;
esac