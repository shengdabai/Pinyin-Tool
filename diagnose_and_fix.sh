#!/bin/bash

# 拼音标注服务综合诊断和修复脚本
# 一键解决Cmd+Shift+P快捷键无法工作的所有问题

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}    拼音标注服务 - 综合诊断修复工具${NC}"
echo -e "${BLUE}============================================${NC}"
echo

# 函数：检查并修复pypinyin
check_pypinyin() {
    echo -e "${YELLOW}[1/6] 检查pypinyin库...${NC}"
    if python3 -c "import pypinyin" 2>/dev/null; then
        echo -e "${GREEN}✅ pypinyin库已安装${NC}"
        return 0
    else
        echo -e "${RED}❌ pypinyin库未安装${NC}"
        echo -e "${YELLOW}正在安装pypinyin...${NC}"
        
        # 尝试多种安装方法
        if pip3 install --break-system-packages pypinyin 2>/dev/null; then
            echo -e "${GREEN}✅ pypinyin安装成功（系统级）${NC}"
        elif pip3 install --user pypinyin 2>/dev/null; then
            echo -e "${GREEN}✅ pypinyin安装成功（用户级）${NC}"
        else
            echo -e "${RED}❌ pypinyin安装失败，请手动安装${NC}"
            return 1
        fi
    fi
}

# 函数：检查Automator服务
check_service() {
    echo -e "${YELLOW}[2/6] 检查Automator服务...${NC}"
    SERVICE_PATH="$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
    if [ -d "$SERVICE_PATH" ]; then
        echo -e "${GREEN}✅ Automator服务已安装${NC}"
        echo -e "   位置: $SERVICE_PATH"
        return 0
    else
        echo -e "${RED}❌ Automator服务未找到${NC}"
        echo -e "${YELLOW}请运行 ./start_install.sh 重新安装服务${NC}"
        return 1
    fi
}

# 函数：测试服务功能
test_service() {
    echo -e "${YELLOW}[3/6] 测试服务功能...${NC}"
    TEST_TEXT="测试文本"
    RESULT=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$TEST_TEXT', style=Style.TONE)))" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 服务功能测试成功${NC}"
        echo -e "   测试结果: $RESULT"
        return 0
    else
        echo -e "${RED}❌ 服务功能测试失败${NC}"
        return 1
    fi
}

# 函数：检查权限设置
check_permissions() {
    echo -e "${YELLOW}[4/6] 检查系统权限...${NC}"
    echo -e "${BLUE}请手动检查以下权限设置：${NC}"
    echo "1. 系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能"
    echo "   - 添加并勾选：Automator, 脚本编辑器"
    echo "2. 系统偏好设置 > 安全性与隐私 > 隐私 > 自动化"
    echo "   - 确保相关应用有权限控制其他应用"
    echo
    read -p "权限已正确设置？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ 权限设置确认${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  请先设置权限后再继续${NC}"
        return 1
    fi
}

# 函数：检查快捷键设置
check_shortcut() {
    echo -e "${YELLOW}[5/6] 检查快捷键设置...${NC}"
    echo -e "${BLUE}是否需要打开快捷键设置页面？${NC}"
    read -p "打开设置页面？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}正在打开系统偏好设置...${NC}"
        osascript open_shortcut_settings.scpt 2>/dev/null || {
            echo -e "${YELLOW}请手动打开：系统偏好设置 > 键盘 > 快捷键 > 服务${NC}"
        }
    fi
    
    echo -e "${BLUE}快捷键设置步骤：${NC}"
    echo "1. 打开 系统偏好设置 > 键盘 > 快捷键"
    echo "2. 在左侧选择 '服务'"
    echo "3. 在右侧找到 '文本' 分类下的 '拼音标注服务-多格式版本'"
    echo "4. 点击右侧设置快捷键为 Cmd+Shift+P"
    echo
    read -p "快捷键已设置？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ 快捷键设置确认${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  请先设置快捷键后再继续${NC}"
        return 1
    fi
}

# 函数：最终测试
final_test() {
    echo -e "${YELLOW}[6/6] 最终测试...${NC}"
    echo -e "${BLUE}请按以下步骤测试快捷键：${NC}"
    echo "1. 在任意应用中选中一些中文文本"
    echo "2. 按 Cmd+Shift+P 快捷键"
    echo "3. 选择拼音格式"
    echo "4. 查看文本是否转换为拼音"
    echo
    read -p "快捷键工作正常？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}🎉 恭喜！拼音标注服务已完全修复！${NC}"
        return 0
    else
        echo -e "${RED}❌ 快捷键仍不工作${NC}"
        return 1
    fi
}

# 主程序
main() {
    local errors=0
    
    check_pypinyin || ((errors++))
    echo
    
    check_service || ((errors++))
    echo
    
    test_service || ((errors++))
    echo
    
    check_permissions || ((errors++))
    echo
    
    check_shortcut || ((errors++))
    echo
    
    if [ $errors -eq 0 ]; then
        final_test
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}============================================${NC}"
            echo -e "${GREEN}           修复完成！${NC}"
            echo -e "${GREEN}============================================${NC}"
            exit 0
        fi
    fi
    
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}          发现问题，需要手动处理${NC}"
    echo -e "${RED}============================================${NC}"
    echo
    echo -e "${YELLOW}故障排除建议：${NC}"
    echo "1. 重启相关应用程序"
    echo "2. 重新授予系统权限"
    echo "3. 尝试不同的快捷键组合"
    echo "4. 使用右键菜单测试服务"
    echo "5. 重新安装服务：./start_install.sh"
    echo
    echo -e "${BLUE}如需帮助，请查看 INSTALL.md 文档${NC}"
}

# 运行主程序
main