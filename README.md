# 拼音标注工具 (Pinyin Annotation Tool)

> **一键为中文添加拼音标注** — 专为中文学习者、教师和双拼用户设计的桌面工具，支持系统级快捷键、繁简转换和批量文件处理。

[![CI](https://github.com/shengdabai/pinyin-tool/actions/workflows/ci.yml/badge.svg)](https://github.com/shengdabai/pinyin-tool/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 产品简介

拼音标注工具是一个 macOS 原生中文拼音标注工具，提供 GUI 界面和系统级快捷键两种使用方式。复制任意中文文本，一键转换为拼音，支持标准声调、数字声调、无声调、首字母四种输出风格。新增繁简转换和批量文件处理能力。

**适合谁用：**
- 中文学习者：快速为学习材料添加拼音标注
- 中文教师：备课时批量处理教材文件
- 双拼用户：搜狗输入法双拼用户专属优化
- 内容创作者：为中文内容添加拼音标注
- 繁体中文使用者：一键繁简转换

## 功能特性

- **智能拼音转换**: 使用 pypinyin 库，支持四种拼音风格
  - 标准声调 (nǐ hǎo)、数字声调 (ni3 hao3)、无声调 (ni hao)、首字母 (nh)
- **繁简转换**: 内置简繁双向转换，无需额外依赖
  - 支持 opencc 库（可选安装）获得更准确的转换结果
- **批量文件处理**: 一键处理多个文本文件，自动输出带 `_pinyin` 后缀的结果文件
- **GUI 界面**: 基于 Tkinter 的用户友好界面，支持窗口缩放
- **系统级快捷键**: 通过 AppleScript 实现全局快捷键，任何应用中都能调用
- **一键复制**: 生成的拼音可直接复制到剪贴板

## 快速开始

### 方法一：使用启动脚本 (推荐)

```bash
cd /path/to/拼音标注工具
./start_install.sh
```

### 方法二：手动安装

```bash
# 1. 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 2. 安装依赖
pip install -r requirements.txt

# 3. (可选) 安装 opencc 获得更好的繁简转换质量
pip install opencc-python-reimplemented

# 4. 运行应用
python pinyin_tool.py
```

### 设置快捷键 (可选)

使用提供的 AppleScript 脚本设置系统级快捷键，实现"选中文字 → 按快捷键 → 自动转换拼音"的流畅体验。

## 定价

| 计划 | 价格 | 功能 |
|------|------|------|
| 免费版 | ¥0 | 完整功能：拼音转换 + 繁简转换 + 批量处理，无限制使用 |
| 教师版 | ¥49/年 | 批量文件处理 + 自定义词典 + 导出 PDF + 优先技术支持 |

> 当前所有功能免费使用，教师版功能规划中。

## 项目结构

```
拼音标注工具/
├── README.md                    # 项目说明
├── pinyin_tool.py               # 主程序 (300+ 行)
├── test_pinyin_tool.py          # 核心 pypinyin 单元测试
├── test_pinyin_functions.py     # 提取函数单元测试（含批量处理）
├── start_install.sh             # 交互式安装脚本
├── requirements.txt             # Python 依赖列表
├── scripts/
│   ├── pinyin_shortcut.scpt     # AppleScript 快捷键脚本
│   └── quick_pinyin.scpt        # 快速拼音转换脚本
├── docs/
│   └── usage.md                 # 详细使用说明
└── .github/
    ├── FUNDING.yml              # 赞助配置
    └── workflows/
        └── ci.yml               # GitHub Actions CI
```

## 许可证

MIT License

## 支持项目

如果这个工具对你有帮助，欢迎 [赞助支持](https://github.com/sponsors/shengdabai) ☕

---

**拼音标注工具** — 一键为中文添加拼音标注
