#!/bin/bash

# 拼音标注服务快捷键修复脚本
# 检查和修复Cmd+Shift+P快捷键无法工作的问题

echo "============================================"
echo "      拼音标注服务 - 快捷键修复工具"
echo "============================================"
echo

# 检查pypinyin库
echo "[1/5] 检查pypinyin库..."
if python3 -c "import pypinyin" 2>/dev/null; then
    echo "✅ pypinyin库已安装"
else
    echo "❌ pypinyin库未安装，正在安装..."
    pip3 install --break-system-packages pypinyin
    if [ $? -eq 0 ]; then
        echo "✅ pypinyin库安装成功"
    else
        echo "❌ pypinyin库安装失败"
        exit 1
    fi
fi
echo

# 检查Automator服务
echo "[2/5] 检查Automator服务..."
SERVICE_PATH="$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
if [ -d "$SERVICE_PATH" ]; then
    echo "✅ Automator服务已安装"
    echo "   位置: $SERVICE_PATH"
else
    echo "❌ Automator服务未找到"
    echo "   请运行 ./start_install.sh 重新安装服务"
    exit 1
fi
echo

# 检查系统权限
echo "[3/5] 检查系统权限..."
echo "请确保以下权限已授予："
echo "1. 系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能"
echo "   - 添加并勾选：Automator, 脚本编辑器"
echo "2. 系统偏好设置 > 安全性与隐私 > 隐私 > 自动化"
echo "   - 确保相关应用有权限控制其他应用"
echo

# 检查快捷键设置
echo "[4/5] 检查快捷键设置..."
echo "请按以下步骤设置快捷键："
echo "1. 打开 系统偏好设置 > 键盘 > 快捷键"
echo "2. 在左侧选择 '服务'"
echo "3. 在右侧找到 '文本' 分类下的 '拼音标注服务-多格式版本'"
echo "4. 点击右侧设置快捷键为 Cmd+Shift+P"
echo

# 测试服务功能
echo "[5/5] 测试服务功能..."
TEST_TEXT="测试文本"
RESULT=$(python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('$TEST_TEXT', style=Style.TONE)))" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 服务功能测试成功"
    echo "   测试结果: $RESULT"
else
    echo "❌ 服务功能测试失败"
    exit 1
fi
echo

echo "============================================"
echo "修复完成！如果快捷键仍不工作，请检查："
echo
echo "1. 快捷键冲突："
echo "   - 检查是否与其他应用快捷键冲突"
echo "   - 尝试使用不同的快捷键组合"
echo
echo "2. 权限问题："
echo "   - 重启相关应用程序"
echo "   - 重新授予系统权限"
echo
echo "3. 手动测试："
echo "   - 选中任意中文文本"
echo "   - 右键 > 服务 > 拼音标注服务-多格式版本"
echo
echo "4. 如果问题仍然存在："
echo "   - 运行: ./start_install.sh 选择选项4卸载服务"
echo "   - 然后选择选项1重新安装"
echo "============================================"