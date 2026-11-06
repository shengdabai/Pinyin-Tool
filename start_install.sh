#!/bin/bash
# 拼音标注工具 - 启动安装脚本
# 提供多种安装方式的入口

set -e

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

# 显示主菜单
show_menu() {
    clear
    echo "="*60
    echo "          拼音标注工具 - 安装启动器"
    echo "="*60
    echo
    echo "请选择安装方式："
    echo
    echo "1. 🖥️  图形界面安装 (推荐)"
    echo "2. 💻 命令行安装"
    echo "3. 📋 查看安装状态"
    echo "4. 🗑️  卸载服务"
    echo "5. 📚 查看帮助文档"
    echo "6. 🧪 测试现有服务"
    echo "0. ❌ 退出"
    echo
    read -p "请输入选项 (0-6): " choice
    echo
}

# 图形界面安装
gui_install() {
    print_info "启动图形界面安装器..."
    
    if [[ -f "install_gui.scpt" ]]; then
        osascript install_gui.scpt
    else
        print_error "找不到图形界面安装器文件: install_gui.scpt"
        print_info "正在使用命令行安装..."
        command_line_install
    fi
}

# 命令行安装
command_line_install() {
    print_info "启动命令行安装器..."
    
    if [[ -f "install_automator_service.sh" ]]; then
        chmod +x install_automator_service.sh
        ./install_automator_service.sh
    else
        print_error "找不到安装脚本文件: install_automator_service.sh"
        return 1
    fi
}

# 检查安装状态
check_install_status() {
    print_info "检查安装状态..."
    echo
    
    # 检查服务文件
    SERVICE_PATH="$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
    if [[ -d "$SERVICE_PATH" ]]; then
        print_success "✅ 拼音标注服务已安装"
        echo "   位置: $SERVICE_PATH"
        
        # 检查服务文件的修改时间
        if command -v stat >/dev/null 2>&1; then
            INSTALL_TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$SERVICE_PATH" 2>/dev/null || echo "未知")
            echo "   安装时间: $INSTALL_TIME"
        fi
    else
        print_warning "❌ 拼音标注服务未安装"
    fi
    
    # 检查Python环境
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_success "✅ Python 3 已安装 (版本: $PYTHON_VERSION)"
    else
        print_warning "❌ Python 3 未安装"
    fi
    
    # 检查pypinyin库
    if python3 -c "import pypinyin" 2>/dev/null; then
        PYPINYIN_VERSION=$(python3 -c "import pypinyin; print(pypinyin.__version__)" 2>/dev/null || echo "未知版本")
        print_success "✅ pypinyin 库已安装 (版本: $PYPINYIN_VERSION)"
    else
        print_warning "❌ pypinyin 库未安装"
    fi
    
    # 检查卸载脚本
    UNINSTALL_PATH="$HOME/Library/Services/uninstall_pinyin_service.sh"
    if [[ -f "$UNINSTALL_PATH" ]]; then
        print_success "✅ 卸载脚本可用"
    else
        print_warning "❌ 卸载脚本不存在"
    fi
    
    echo
    read -p "按回车键返回主菜单..." -r
}

# 卸载服务
uninstall_service() {
    print_warning "准备卸载拼音标注服务..."
    echo
    read -p "确定要卸载吗？(y/N): " -r
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        UNINSTALL_PATH="$HOME/Library/Services/uninstall_pinyin_service.sh"
        if [[ -f "$UNINSTALL_PATH" ]]; then
            chmod +x "$UNINSTALL_PATH"
            "$UNINSTALL_PATH"
            print_success "服务已卸载"
        else
            # 手动卸载
            print_info "执行手动卸载..."
            rm -rf "$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
            rm -f "$HOME/Library/Services/uninstall_pinyin_service.sh"
            print_success "手动卸载完成"
        fi
    else
        print_info "取消卸载"
    fi
    
    echo
    read -p "按回车键返回主菜单..." -r
}

# 查看帮助文档
show_help() {
    print_info "打开帮助文档..."
    
    if [[ -f "docs/automator_setup.md" ]]; then
        if command -v open >/dev/null 2>&1; then
            open "docs/automator_setup.md"
            print_success "帮助文档已在默认应用中打开"
        else
            print_info "请手动打开文件: docs/automator_setup.md"
        fi
    else
        print_error "找不到帮助文档: docs/automator_setup.md"
    fi
    
    echo
    read -p "按回车键返回主菜单..." -r
}

# 测试现有服务
test_existing_service() {
    print_info "测试拼音标注服务..."
    
    # 检查服务是否存在
    SERVICE_PATH="$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
    if [[ ! -d "$SERVICE_PATH" ]]; then
        print_error "服务未安装，请先安装服务"
        echo
        read -p "按回车键返回主菜单..." -r
        return
    fi
    
    # 测试Python和pypinyin
    if ! python3 -c "import pypinyin" 2>/dev/null; then
        print_error "pypinyin库未安装，请先安装依赖"
        echo
        read -p "按回车键返回主菜单..." -r
        return
    fi
    
    # 执行测试
    TEST_TEXT="测试中文拼音转换功能"
    print_info "测试文本: $TEST_TEXT"
    
    RESULT=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$TEST_TEXT', style=Style.TONE)))" 2>/dev/null)
    
    if [[ $? -eq 0 ]]; then
        print_success "测试成功！"
        echo "转换结果: $RESULT"
        echo
        echo "服务工作正常，您可以："
        echo "1. 在任何应用中选中中文文本"
        echo "2. 使用快捷键或右键菜单调用服务"
        echo "3. 选择需要的拼音格式"
    else
        print_error "测试失败，请检查安装"
    fi
    
    echo
    read -p "按回车键返回主菜单..." -r
}

# 主循环
main() {
    while true; do
        show_menu
        
        case $choice in
            1)
                gui_install
                ;;
            2)
                command_line_install
                ;;
            3)
                check_install_status
                ;;
            4)
                uninstall_service
                ;;
            5)
                show_help
                ;;
            6)
                test_existing_service
                ;;
            0)
                print_info "感谢使用拼音标注工具！"
                exit 0
                ;;
            *)
                print_error "无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# 检查当前目录
if [[ ! -f "install_automator_service.sh" ]] && [[ ! -f "install_gui.scpt" ]]; then
    print_error "请在拼音标注工具目录中运行此脚本"
    print_info "当前目录: $(pwd)"
    exit 1
fi

# 运行主程序
main