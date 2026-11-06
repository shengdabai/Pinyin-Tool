#!/bin/bash
# 拼音标注工具启动脚本

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 切换到项目目录
cd "$SCRIPT_DIR"

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    echo "创建虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
source venv/bin/activate

# 检查依赖是否已安装
if ! python -c "import pypinyin, pyperclip" 2>/dev/null; then
    echo "安装依赖库..."
    pip install -r requirements.txt
fi

# 启动应用
echo "启动拼音标注工具..."
python pinyin_tool.py