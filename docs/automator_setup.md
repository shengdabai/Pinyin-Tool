# Automator 拼音标注服务设置教程

本教程将详细介绍如何在 macOS 的 Automator 中创建拼音标注服务，让您可以通过快捷键快速为选中的中文文本添加拼音标注。

## 目录
- [前置要求](#前置要求)
- [创建 Automator 服务](#创建-automator-服务)
- [AppleScript 代码配置](#applescript-代码配置)
- [快捷键设置](#快捷键设置)
- [权限配置](#权限配置)
- [使用方法](#使用方法)
- [故障排除](#故障排除)
- [使用场景示例](#使用场景示例)

## 前置要求

### 系统要求
- macOS 10.12 或更高版本
- Python 3.6+ 已安装
- pypinyin 库已安装

### 检查环境
```bash
# 检查 Python 版本
python3 --version

# 检查 pypinyin 是否已安装
python3 -c "import pypinyin; print('pypinyin 已安装')"
```

如果 pypinyin 未安装，请运行：
```bash
pip3 install pypinyin
```

## 创建 Automator 服务

### 步骤 1：打开 Automator
1. 按 `Cmd + Space` 打开 Spotlight 搜索
2. 输入 "Automator" 并按回车
3. 或者在 应用程序 > Automator 中找到并打开

### 步骤 2：选择服务模板
1. 在 Automator 启动界面选择 **"服务"** (Service)
2. 点击 "选取" 按钮

### 步骤 3：配置服务基本设置
在工作流程顶部设置：
- **"服务收到选定的"**: 选择 **"文本"**
- **"位于"**: 选择 **"任何应用程序"**

这样配置后，服务将在任何应用程序中选中文本时可用。

### 步骤 4：添加 AppleScript 动作
1. 在左侧 "资源库" 中找到 **"实用工具"** 类别
2. 将 **"运行 AppleScript"** 动作拖拽到右侧工作流程区域

## AppleScript 代码配置

### 基础版本（替换选中文本）
将以下代码复制到 "运行 AppleScript" 动作的代码框中：

```applescript
-- 拼音标注服务 - 基础版本
-- 将选中的中文文本转换为拼音并替换原文本

on run {input, parameters}
    -- 获取输入的文本
    set inputText to input as string
    
    -- 检查输入是否为空
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    try
        -- 构建 Python 脚本命令
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=Style.TONE)); print(result)\" " & quoted form of inputText
        
        -- 执行 Python 脚本获取拼音
        set pinyinResult to do shell script pythonCommand
        
        -- 显示成功通知
        display notification "转换完成: " & pinyinResult with title "拼音标注服务" subtitle "成功"
        
        -- 返回拼音结果
        return pinyinResult
        
    on error errorMessage
        -- 错误处理
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        return inputText
    end try
end run
```

### 高级版本（保留原文+拼音）
如果您希望保留原文并在后面添加拼音，使用以下代码：

```applescript
-- 拼音标注服务 - 高级版本
-- 保留原文并添加拼音标注

on run {input, parameters}
    set inputText to input as string
    
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    try
        -- 构建 Python 脚本命令
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=Style.TONE)); print(result)\" " & quoted form of inputText
        
        -- 执行转换
        set pinyinResult to do shell script pythonCommand
        
        -- 组合原文和拼音
        set finalResult to inputText & " (" & pinyinResult & ")"
        
        display notification "标注完成" with title "拼音标注服务"
        
        return finalResult
        
    on error errorMessage
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        return inputText
    end try
end run
```

### 多格式版本（可选择拼音风格）
支持多种拼音格式的高级版本：

```applescript
-- 拼音标注服务 - 多格式版本
-- 支持选择不同的拼音风格

on run {input, parameters}
    set inputText to input as string
    
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    -- 让用户选择拼音风格
    set styleChoice to choose from list {"标准声调 (zhōng)", "数字声调 (zhong1)", "无声调 (zhong)", "首字母 (z)"} with prompt "选择拼音风格：" default items {"标准声调 (zhōng)"}
    
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
        -- 构建 Python 命令
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=" & pinyinStyle & ")); print(result)\" " & quoted form of inputText
        
        set pinyinResult to do shell script pythonCommand
        
        display notification "转换完成" with title "拼音标注服务"
        
        return pinyinResult
        
    on error errorMessage
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        return inputText
    end try
end run
```

## 保存服务

1. 点击 "文件" > "存储"
2. 输入服务名称，例如："快速拼音转换"
3. 确保保存位置为 `~/Library/Services/`
4. 点击 "存储"

## 快捷键设置

### 方法 1：系统偏好设置
1. 打开 **系统偏好设置** > **键盘**
2. 点击 **快捷键** 标签
3. 在左侧选择 **服务**
4. 在右侧找到 "文本" 分类下的 "快速拼音转换"
5. 点击右侧的 "无" 或现有快捷键
6. 按下您想要的快捷键组合（推荐：`Cmd + Shift + P`）

### 方法 2：通过右键菜单
即使不设置快捷键，您也可以：
1. 选中任意中文文本
2. 右键点击
3. 在菜单中选择 "服务" > "快速拼音转换"

## 权限配置

### 辅助功能权限
如果服务无法正常工作，可能需要授予权限：

1. 打开 **系统偏好设置** > **安全性与隐私**
2. 点击 **隐私** 标签
3. 在左侧选择 **辅助功能**
4. 点击左下角的锁图标并输入密码
5. 确保以下应用已添加并勾选：
   - **Automator**
   - **脚本编辑器** (Script Editor)
   - 您经常使用此服务的应用程序

### 自动化权限
对于 macOS Mojave (10.14) 及更高版本：

1. 在 **系统偏好设置** > **安全性与隐私** > **隐私**
2. 选择 **自动化**
3. 确保相关应用有权限控制其他应用

## 使用方法

### 基本使用流程
1. 在任意应用程序中选中中文文本
2. 按设置的快捷键（如 `Cmd + Shift + P`）
3. 等待转换完成
4. 选中的文本将被替换为拼音（或根据您选择的版本显示）

### 支持的应用程序
- **文本编辑器**：TextEdit, Pages, Word
- **浏览器**：Safari, Chrome, Firefox
- **笔记应用**：Notes, Notion, Obsidian
- **代码编辑器**：VS Code, Xcode
- **聊天应用**：Messages, Slack
- 几乎所有支持文本选择的应用程序

## 故障排除

### 常见问题及解决方案

#### 1. 服务不出现在菜单中
**原因**：服务未正确保存或权限问题
**解决方案**：
- 确认服务保存在 `~/Library/Services/` 目录
- 重启相关应用程序
- 检查系统权限设置

#### 2. 提示 "python3 command not found"
**原因**：Python 未安装或不在 PATH 中
**解决方案**：
```bash
# 检查 Python 安装
which python3

# 如果未找到，安装 Python
brew install python3
# 或从 python.org 下载安装
```

#### 3. 提示 "No module named 'pypinyin'"
**原因**：pypinyin 库未安装
**解决方案**：
```bash
pip3 install pypinyin
```

#### 4. 转换结果不准确
**原因**：多音字或词汇识别问题
**解决方案**：
- 尝试选择更小的文本片段
- 使用标准声调格式获得最佳效果
- 对于专业术语，可能需要手动调整

#### 5. 快捷键不工作
**原因**：快捷键冲突或权限问题
**解决方案**：
- 尝试不同的快捷键组合
- 检查是否与其他应用程序快捷键冲突
- 确认辅助功能权限已授予

#### 6. 服务运行缓慢
**原因**：大量文本或系统性能问题
**解决方案**：
- 分批处理大量文本
- 关闭不必要的应用程序释放内存
- 考虑使用 GUI 版本处理大文本

### 调试技巧

#### 测试 Python 脚本
在终端中直接测试转换功能：
```bash
python3 -c "from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('测试文本', style=Style.TONE)))"
```

#### 查看系统日志
```bash
# 查看 Automator 相关日志
log show --predicate 'process == "Automator"' --last 1h

# 查看脚本执行日志
log show --predicate 'eventMessage contains "AppleScript"' --last 1h
```

## 使用场景示例

### 1. 教育场景
**用途**：为教学材料添加拼音标注
**操作**：
1. 在 Pages 或 Word 中选中需要标注的汉字
2. 使用快捷键转换
3. 使用 "高级版本" 保留原文和拼音

**示例**：
- 原文："学习中文"
- 转换后："学习中文 (xué xí zhōng wén)"

### 2. 语言学习
**用途**：帮助外国学生学习中文发音
**操作**：
1. 在浏览器中选中不认识的中文词汇
2. 快速转换为拼音
3. 使用标准声调格式学习正确发音

### 3. 文档处理
**用途**：为技术文档添加拼音索引
**操作**：
1. 选中专业术语
2. 使用 "多格式版本" 选择合适的拼音风格
3. 用于创建拼音索引或搜索关键词

### 4. 内容创作
**用途**：为博客或社交媒体内容添加拼音
**操作**：
1. 在编辑器中选中关键词
2. 转换为拼音帮助读者理解
3. 特别适用于面向国际读者的内容

### 5. 翻译辅助
**用途**：辅助中英翻译工作
**操作**：
1. 选中难读的人名或地名
2. 转换为拼音作为翻译参考
3. 确保翻译中的拼音准确性

### 6. 数据处理
**用途**：为数据库或表格添加拼音字段
**操作**：
1. 在 Excel 或 Numbers 中选中中文数据
2. 转换为拼音
3. 用于排序或搜索功能

## 高级技巧

### 批量处理
对于大量文本，建议：
1. 使用 GUI 版本的拼音工具
2. 或者编写自定义脚本处理文件
3. 分段处理避免系统卡顿

### 自定义拼音风格
可以修改 AppleScript 中的 Python 代码来：
- 添加自定义拼音格式
- 处理特殊字符
- 集成其他拼音库

### 与其他工具集成
- 结合 Alfred 或 Raycast 创建更强大的工作流
- 与文本扩展工具配合使用
- 集成到 IDE 中用于代码注释

## 更新和维护

### 定期检查
- 确保 Python 和 pypinyin 库保持最新
- 测试服务在系统更新后是否正常工作
- 根据使用需求调整 AppleScript 代码

### 备份配置
建议备份以下文件：
- `~/Library/Services/快速拼音转换.workflow`
- 自定义的 AppleScript 代码
- 快捷键设置

---

## 总结

通过本教程，您已经学会了如何在 macOS 中创建强大的拼音标注服务。这个服务可以：

- ✅ 在任何应用程序中快速转换中文为拼音
- ✅ 支持多种拼音格式
- ✅ 通过快捷键快速访问
- ✅ 高度可定制和扩展

如果您在使用过程中遇到问题，请参考故障排除部分，或者查看项目的其他文档。

**提示**：建议先使用基础版本熟悉功能，然后根据需要升级到高级版本。

---

*最后更新：2024年*
*如有问题或建议，欢迎反馈*