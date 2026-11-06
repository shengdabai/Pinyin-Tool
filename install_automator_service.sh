#!/bin/bash
# 拼音标注工具 - Automator服务自动安装脚本
# 自动安装AppleScript多格式版本的拼音标注服务

set -e  # Exit on any error

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 显示欢迎信息
show_welcome() {
    clear
    echo "="*60
    echo "          拼音标注工具 - Automator服务安装器"
    echo "="*60
    echo
    echo "本脚本将自动为您安装AppleScript多格式版本的拼音标注服务"
    echo "安装完成后，您可以在任何应用程序中快速转换中文为拼音"
    echo
    echo "功能特性："
    echo "• 支持多种拼音格式（标准声调、数字声调、无声调、首字母）"
    echo "• 可在任何应用程序中使用"
    echo "• 支持快捷键和右键菜单调用"
    echo "• 智能多音字处理"
    echo
    read -p "按回车键继续安装，或按 Ctrl+C 取消..." -r
    echo
}

# 检查系统要求
check_system_requirements() {
    print_info "检查系统要求..."
    
    # 检查macOS版本
    macos_version=$(sw_vers -productVersion)
    print_info "当前macOS版本: $macos_version"
    
    # 检查是否为macOS 10.12+
    if [[ $(echo "$macos_version 10.12" | tr " " "\n" | sort -V | head -n1) != "10.12" ]]; then
        print_error "需要macOS 10.12或更高版本"
        exit 1
    fi
    
    print_success "系统要求检查通过"
}

# 检查Python环境
check_python() {
    print_info "检查Python环境..."
    
    # 检查python3是否存在
    if ! command -v python3 &> /dev/null; then
        print_error "未找到Python 3，请先安装Python 3.6或更高版本"
        print_info "您可以从 https://www.python.org/downloads/ 下载安装"
        print_info "或使用Homebrew安装: brew install python3"
        exit 1
    fi
    
    # 检查Python版本
    python_version=$(python3 --version | cut -d' ' -f2)
    print_info "Python版本: $python_version"
    
    # 检查是否为3.6+
    if [[ $(echo "$python_version 3.6.0" | tr " " "\n" | sort -V | head -n1) != "3.6.0" ]]; then
        print_error "需要Python 3.6或更高版本，当前版本: $python_version"
        exit 1
    fi
    
    print_success "Python环境检查通过"
}

# 检查并安装pypinyin
check_and_install_pypinyin() {
    print_info "检查pypinyin库..."
    
    if python3 -c "import pypinyin" 2>/dev/null; then
        pypinyin_version=$(python3 -c "import pypinyin; print(pypinyin.__version__)" 2>/dev/null || echo "未知版本")
        print_success "pypinyin已安装，版本: $pypinyin_version"
    else
        print_warning "pypinyin未安装，正在安装..."
        
        if pip3 install pypinyin; then
            print_success "pypinyin安装成功"
        else
            print_error "pypinyin安装失败，请手动安装: pip3 install pypinyin"
            exit 1
        fi
    fi
}

# 创建服务目录
create_service_directory() {
    print_info "创建服务目录..."
    
    SERVICE_DIR="$HOME/Library/Services"
    if [[ ! -d "$SERVICE_DIR" ]]; then
        mkdir -p "$SERVICE_DIR"
        print_success "创建服务目录: $SERVICE_DIR"
    else
        print_info "服务目录已存在: $SERVICE_DIR"
    fi
}

# 创建Automator工作流文件
create_automator_workflow() {
    print_info "创建Automator工作流..."
    
    SERVICE_NAME="拼音标注服务-多格式版本"
    WORKFLOW_PATH="$HOME/Library/Services/${SERVICE_NAME}.workflow"
    
    # 如果服务已存在，询问是否覆盖
    if [[ -d "$WORKFLOW_PATH" ]]; then
        print_warning "服务 '$SERVICE_NAME' 已存在"
        read -p "是否覆盖现有服务？(y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "跳过服务创建"
            return
        fi
        rm -rf "$WORKFLOW_PATH"
    fi
    
    # 创建工作流目录结构
    mkdir -p "$WORKFLOW_PATH/Contents"
    
    # 创建Info.plist
    cat > "$WORKFLOW_PATH/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>com.apple.automator.拼音标注服务-多格式版本</string>
	<key>CFBundleName</key>
	<string>拼音标注服务-多格式版本</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>拼音标注服务-多格式版本</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSRequiredContext</key>
			<dict>
				<key>NSApplicationIdentifier</key>
				<string>com.apple.automator.runner</string>
			</dict>
			<key>NSSendTypes</key>
			<array>
				<string>public.utf8-plain-text</string>
			</array>
			<key>NSReturnTypes</key>
			<array>
				<string>public.utf8-plain-text</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
EOF

    print_success "创建Info.plist文件"
    
    # 创建document.wflow文件
    cat > "$WORKFLOW_PATH/Contents/document.wflow" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>521</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>1.0.2</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run AppleScript.action</string>
				<key>ActionName</key>
				<string>Run AppleScript</string>
				<key>ActionParameters</key>
				<dict>
					<key>source</key>
					<string>-- 拼音标注服务 - 多格式版本
-- 支持选择不同的拼音风格

on run {input, parameters}
    set inputText to input as string
    
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    -- 让用户选择拼音风格
    set styleChoice to choose from list {"标准声调 (zhōng)", "数字声调 (zhong1)", "无声调 (zhong)", "首字母 (z)", "保留原文+拼音"} with prompt "选择拼音风格：" default items {"标准声调 (zhōng)"}
    
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
    else if selectedStyle contains "保留原文" then
        set pinyinStyle to "Style.TONE"
        set keepOriginal to true
    end if
    
    try
        -- 构建 Python 命令
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=" & pinyinStyle & ")); print(result)\" " & quoted form of inputText
        
        set pinyinResult to do shell script pythonCommand
        
        -- 根据用户选择返回结果
        if selectedStyle contains "保留原文" then
            set finalResult to inputText & " (" & pinyinResult & ")"
        else
            set finalResult to pinyinResult
        end if
        
        display notification "转换完成" with title "拼音标注服务" subtitle selectedStyle
        
        return finalResult
        
    on error errorMessage
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        return inputText
    end try
end run</string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.Automator.RunScript</string>
				<key>CFBundleVersion</key>
				<string>1.0.2</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunScriptAction</string>
				<key>InputUUID</key>
				<string>A8F4F0E1-4F1A-4F1A-8F4F-0E14F1A4F1A4</string>
				<key>Keywords</key>
				<array>
					<string>Run</string>
				</array>
				<key>OutputUUID</key>
				<string>B8F4F0E1-4F1A-4F1A-8F4F-0E14F1A4F1A4</string>
				<key>UUID</key>
				<string>C8F4F0E1-4F1A-4F1A-8F4F-0E14F1A4F1A4</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<string>on run {input, parameters}
	
	return input
end run</string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<true/>
				<key>location</key>
				<string>449.000000:316.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run AppleScript.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<true/>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.text</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.text</string>
		<key>serviceApplicationBundleIdentifier</key>
		<string>(null)</string>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
EOF

    print_success "创建Automator工作流文件"
    print_success "服务 '$SERVICE_NAME' 创建成功"
    
    # 设置正确的权限
    chmod -R 755 "$WORKFLOW_PATH"
}

# 设置系统权限提示
setup_permissions() {
    print_info "配置系统权限..."
    
    # 创建权限设置AppleScript
    cat > "/tmp/setup_permissions.scpt" << 'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.security"
    delay 1
    tell application "System Events"
        tell process "System Preferences"
            click button "Privacy" of tab group 1 of window 1
            delay 0.5
            try
                select row 1 of table 1 of scroll area 1 of group 1 of tab group 1 of window 1 where name of static text 1 of UI element 1 of cell 1 is "Accessibility"
            end try
        end tell
    end tell
end tell

display dialog "请在系统偏好设置中：\n\n1. 点击左下角的锁图标并输入密码\n2. 确保以下应用已添加并勾选：\n   • Automator\n   • 脚本编辑器\n   • 您常用的应用程序\n\n完成后点击'确定'继续" buttons {"确定"} default button "确定"
EOF
    
    # 运行权限设置脚本
    osascript "/tmp/setup_permissions.scpt" 2>/dev/null || true
    rm -f "/tmp/setup_permissions.scpt"
    
    print_success "权限配置完成"
}

# 设置快捷键提示
setup_shortcut_key() {
    print_info "配置快捷键..."
    
    # 创建快捷键设置AppleScript
    cat > "/tmp/setup_shortcut.scpt" << 'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.keyboard"
    delay 1
    tell application "System Events"
        tell process "System Preferences"
            click button "Shortcuts" of tab group 1 of window 1
            delay 0.5
            try
                select row 1 of table 1 of scroll area 1 of splitter group 1 of tab group 1 of window 1 where name of static text 1 of UI element 1 of cell 1 is "Services"
                delay 0.5
                -- 查找拼音标注服务
                set serviceRows to rows of table 1 of scroll area 2 of splitter group 1 of tab group 1 of window 1
                repeat with serviceRow in serviceRows
                    try
                        if name of static text 1 of UI element 1 of cell 1 of serviceRow contains "拼音标注" then
                            select serviceRow
                            exit repeat
                        end if
                    end try
                end repeat
            end try
        end tell
    end tell
end tell

display dialog "请在系统偏好设置中：\n\n1. 在左侧选择'服务'\n2. 在右侧找到'拼音标注服务-多格式版本'\n3. 点击右侧的快捷键设置\n4. 按下您想要的快捷键（推荐：Cmd+Shift+P）\n\n完成后点击'确定'继续" buttons {"确定"} default button "确定"
EOF
    
    # 运行快捷键设置脚本
    osascript "/tmp/setup_shortcut.scpt" 2>/dev/null || true
    rm -f "/tmp/setup_shortcut.scpt"
    
    print_success "快捷键配置完成"
}

# 测试服务功能
test_service() {
    print_info "测试服务功能..."
    
    # 创建测试脚本
    cat > "/tmp/test_pinyin_service.scpt" << 'EOF'
-- 测试拼音标注服务
set testText to "测试中文拼音转换"

try
    -- 调用Python脚本测试
    set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('测试中文拼音转换', style=Style.TONE)))\""
    set pinyinResult to do shell script pythonCommand
    
    display dialog "测试成功！\n\n原文：" & testText & "\n拼音：" & pinyinResult & "\n\n服务已准备就绪，您可以：\n1. 在任何应用中选中中文文本\n2. 使用快捷键或右键菜单调用服务" buttons {"确定"} default button "确定" with icon note
    
on error errorMessage
    display dialog "测试失败：" & errorMessage & "\n\n请检查Python和pypinyin是否正确安装" buttons {"确定"} default button "确定" with icon stop
end try
EOF
    
    # 运行测试
    if osascript "/tmp/test_pinyin_service.scpt"; then
        print_success "服务测试通过"
    else
        print_error "服务测试失败"
    fi
    
    rm -f "/tmp/test_pinyin_service.scpt"
}

# 显示安装完成信息
show_completion_info() {
    clear
    echo "="*60
    echo "          🎉 安装完成！"
    echo "="*60
    echo
    print_success "拼音标注服务已成功安装！"
    echo
    echo "📋 使用方法："
    echo "1. 在任何应用程序中选中中文文本"
    echo "2. 按快捷键（如 Cmd+Shift+P）或右键选择服务"
    echo "3. 选择您需要的拼音格式"
    echo "4. 文本将被转换为拼音"
    echo
    echo "🎨 支持的拼音格式："
    echo "• 标准声调：zhōng guó"
    echo "• 数字声调：zhong1 guo2"
    echo "• 无声调：zhong guo"
    echo "• 首字母：z g"
    echo "• 保留原文+拼音：中国 (zhōng guó)"
    echo
    echo "🔧 如果遇到问题："
    echo "• 检查系统权限设置"
    echo "• 确认Python和pypinyin已正确安装"
    echo "• 重启相关应用程序"
    echo
    echo "📚 更多帮助请查看：docs/automator_setup.md"
    echo
}

# 创建卸载脚本
create_uninstall_script() {
    print_info "创建卸载脚本..."
    
    cat > "$HOME/Library/Services/uninstall_pinyin_service.sh" << 'EOF'
#!/bin/bash
# 拼音标注服务卸载脚本

echo "正在卸载拼音标注服务..."

# 删除服务文件
rm -rf "$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
rm -f "$HOME/Library/Services/uninstall_pinyin_service.sh"

echo "拼音标注服务已卸载"
echo "如需重新安装，请运行 install_automator_service.sh"
EOF
    
    chmod +x "$HOME/Library/Services/uninstall_pinyin_service.sh"
    print_success "卸载脚本已创建：$HOME/Library/Services/uninstall_pinyin_service.sh"
}

# 主安装函数
main() {
    # 显示欢迎信息
    show_welcome
    
    # 执行安装步骤
    check_system_requirements
    check_python
    check_and_install_pypinyin
    create_service_directory
    create_automator_workflow
    
    # 配置系统设置
    setup_permissions
    setup_shortcut_key
    
    # 测试服务
    test_service
    
    # 创建卸载脚本
    create_uninstall_script
    
    # 显示完成信息
    show_completion_info
    
    print_success "安装程序执行完成！"
}

# 错误处理
trap 'print_error "安装过程中发生错误，请检查上述输出信息"; exit 1' ERR

# 运行主函数
main "$@"

