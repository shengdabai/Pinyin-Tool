# 拼音标注工具 - 自动化安装指南

本文档介绍如何使用自动化安装脚本来快速安装 AppleScript 多格式版本的拼音标注服务。

## 🚀 快速开始

### 方法一：一键启动器（推荐）

```bash
# 在拼音标注工具目录中运行
./start_install.sh
```

这将打开一个交互式菜单，提供以下选项：
- 🖥️ 图形界面安装
- 💻 命令行安装
- 📋 查看安装状态
- 🗑️ 卸载服务
- 📚 查看帮助文档
- 🧪 测试现有服务

### 方法二：图形界面安装

```bash
# 直接运行图形界面安装器
osascript install_gui.scpt
```

### 方法三：命令行安装

```bash
# 直接运行命令行安装脚本
./install_automator_service.sh
```

## 📋 安装内容

### 自动安装的组件

1. **系统检查**
   - macOS 版本检查（需要 10.12+）
   - Python 3 环境检查（需要 3.6+）
   - pypinyin 库安装

2. **服务文件**
   - `~/Library/Services/拼音标注服务-多格式版本.workflow`
   - 完整的 Automator 工作流文件
   - 多格式 AppleScript 代码

3. **系统集成**
   - 自动权限配置提示
   - 快捷键设置指导
   - 右键菜单集成

4. **辅助工具**
   - 卸载脚本：`~/Library/Services/uninstall_pinyin_service.sh`
   - 服务测试功能
   - 错误诊断工具

## 🎨 功能特性

### 支持的拼音格式

| 格式类型 | 示例 | 说明 |
|---------|------|------|
| 标准声调 | zhōng guó | 使用声调符号，最标准的格式 |
| 数字声调 | zhong1 guo2 | 用数字1-4表示声调 |
| 无声调 | zhong guo | 纯字母，无声调信息 |
| 首字母 | z g | 只显示拼音首字母 |
| 保留原文+拼音 | 中国 (zhōng guó) | 原文和拼音并存 |

### 使用场景

- **教育教学**：为教材添加拼音标注
- **语言学习**：帮助外国人学习中文发音
- **文档处理**：技术文档拼音索引
- **内容创作**：博客、社交媒体内容
- **翻译辅助**：人名地名拼音标注
- **数据处理**：数据库拼音字段生成

## ⚙️ 安装过程详解

### 1. 系统要求检查

脚本会自动检查：
- macOS 版本（需要 10.12 Sierra 或更高）
- Python 3 安装状态（需要 3.6 或更高）
- 必要的系统权限

### 2. 依赖安装

自动安装 pypinyin 库：
```bash
pip3 install pypinyin
```

### 3. 服务创建

创建完整的 Automator 工作流：
- Info.plist 配置文件
- document.wflow 工作流文件
- 嵌入式 AppleScript 代码

### 4. 权限配置

自动打开系统偏好设置，指导用户：
- 辅助功能权限设置
- 自动化权限配置
- 应用程序权限授予

### 5. 快捷键设置

引导用户设置快捷键：
- 推荐快捷键：`Cmd + Shift + P`
- 自动打开键盘快捷键设置
- 定位到服务设置项

## 🔧 故障排除

### 常见问题

#### 1. "python3 command not found"

**解决方案**：
```bash
# 使用 Homebrew 安装 Python
brew install python3

# 或从官网下载安装
# https://www.python.org/downloads/
```

#### 2. "No module named 'pypinyin'"

**解决方案**：
```bash
pip3 install pypinyin
```

#### 3. 服务不出现在菜单中

**解决方案**：
- 重启相关应用程序
- 检查服务文件权限
- 验证 `~/Library/Services/` 目录

#### 4. 权限被拒绝

**解决方案**：
1. 打开 **系统偏好设置** > **安全性与隐私** > **隐私**
2. 选择 **辅助功能**
3. 添加并勾选：
   - Automator
   - 脚本编辑器
   - 您使用的应用程序

#### 5. 快捷键不工作

**解决方案**：
- 检查快捷键冲突
- 重新设置快捷键
- 确认服务已正确安装

### 调试工具

#### 检查安装状态
```bash
./start_install.sh
# 选择选项 3：查看安装状态
```

#### 测试服务功能
```bash
./start_install.sh
# 选择选项 6：测试现有服务
```

#### 手动测试 Python 脚本
```bash
python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('测试', style=Style.TONE)))"
```

## 🗑️ 卸载服务

### 自动卸载
```bash
./start_install.sh
# 选择选项 4：卸载服务
```

### 手动卸载
```bash
# 删除服务文件
rm -rf "$HOME/Library/Services/拼音标注服务-多格式版本.workflow"

# 删除卸载脚本
rm -f "$HOME/Library/Services/uninstall_pinyin_service.sh"
```

## 📚 使用方法

### 基本使用

1. **选中文本**：在任何应用程序中选中中文文本
2. **调用服务**：
   - 按快捷键（如 `Cmd + Shift + P`）
   - 或右键选择 "服务" > "拼音标注服务-多格式版本"
3. **选择格式**：在弹出的对话框中选择拼音格式
4. **获得结果**：文本将被转换为选定格式的拼音

### 支持的应用程序

- **文本编辑器**：TextEdit, Pages, Word, VS Code
- **浏览器**：Safari, Chrome, Firefox
- **笔记应用**：Notes, Notion, Obsidian
- **聊天应用**：Messages, Slack, Discord
- **几乎所有支持文本选择的应用程序**

## 🔄 更新和维护

### 更新 pypinyin 库
```bash
pip3 install --upgrade pypinyin
```

### 重新安装服务
```bash
# 先卸载
./start_install.sh  # 选择卸载

# 再安装
./start_install.sh  # 选择安装
```

### 备份配置
```bash
# 备份服务文件
cp -r "$HOME/Library/Services/拼音标注服务-多格式版本.workflow" ~/Desktop/
```

## 📞 获取帮助

### 文档资源
- **详细教程**：`docs/automator_setup.md`
- **使用指南**：`docs/usage.md`
- **故障排除**：本文档的故障排除部分

### 常用命令
```bash
# 查看安装状态
./start_install.sh

# 测试服务
python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('测试', style=Style.TONE)))"

# 检查服务文件
ls -la "$HOME/Library/Services/拼音标注服务-多格式版本.workflow"
```

---

## 🎉 安装完成后

安装成功后，您将拥有一个强大的拼音标注工具，可以：

✅ 在任何应用程序中快速转换中文为拼音  
✅ 支持多种拼音格式，满足不同需求  
✅ 智能处理多音字，提供准确的拼音  
✅ 完美适配搜狗双拼用户的使用习惯  
✅ 系统级集成，稳定可靠  

**开始使用吧！选中任意中文文本，按 `Cmd + Shift + P` 体验拼音转换的便捷！**