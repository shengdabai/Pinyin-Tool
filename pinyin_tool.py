#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
拼音标注工具 - 主程序
为中文文本自动生成带声调的拼音标注
特别适合搜狗输入法双拼用户使用
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
import pyperclip
from pypinyin import pinyin, lazy_pinyin, Style
import sys
import os

# === Pure functions extracted for testability ===

def convert_pinyin_text(text: str, style_name: str) -> str:
    """Convert Chinese text to pinyin with the specified style."""
    style_map = {
        "TONE": Style.TONE,
        "TONE3": Style.TONE3,
        "NORMAL": Style.NORMAL,
        "FIRST_LETTER": Style.FIRST_LETTER,
    }
    selected_style = style_map.get(style_name, Style.TONE)

    if style_name == "FIRST_LETTER":
        result = lazy_pinyin(text, style=selected_style)
        return ' '.join(result)
    else:
        result = pinyin(text, style=selected_style, heteronym=False)
        return ' '.join([item[0] for item in result])


def batch_convert_files(file_paths: list, style_name: str, output_dir: str) -> list:
    """Batch convert multiple text files to pinyin. Returns list of (filename, success, message)."""
    results = []
    for fp in file_paths:
        try:
            with open(fp, 'r', encoding='utf-8') as f:
                content = f.read()
            converted = convert_pinyin_text(content, style_name)
            base = os.path.basename(fp)
            name, ext = os.path.splitext(base)
            out_path = os.path.join(output_dir, f"{name}_pinyin{ext}")
            # Exclusive creation preserves existing output and selected inputs
            # whose names happen to match another file's output name.
            with open(out_path, 'x', encoding='utf-8') as f:
                f.write(converted)
            results.append((base, True, f"已输出到 {out_path}"))
        except Exception as e:
            results.append((os.path.basename(fp), False, str(e)))
    return results


def convert_to_simplified(text: str) -> str:
    """Convert traditional Chinese to simplified using opencc if available."""
    try:
        import opencc
        cc = opencc.OpenCC('t2s')
        return cc.convert(text)
    except ImportError:
        # Fallback: simple mapping for common traditional chars
        simple_map = {
            '國': '国', '國': '国', '為': '为', '學': '学', '習': '习',
            '電': '电', '腦': '脑', '漢': '汉', '語': '语', '體': '体',
            '簡': '简', '轉': '转', '換': '换', '麼': '么',
            '們': '们', '這': '这', '個': '个', '會': '会', '來': '来',
            '說': '说', '過': '过', '時': '时', '實': '实', '現': '现',
            '認': '认', '識': '识', '開': '开', '發': '发', '機': '机',
            '關': '关', '門': '门', '問': '问', '題': '题', '長': '长',
            '風': '风', '氣': '气', '東': '东', '西': '西', '車': '车',
            '書': '书', '畫': '画', '愛': '爱', '無': '无', '從': '从',
            '與': '与', '對': '对', '應': '应', '該': '该', '還': '还',
            '邊': '边', '遠': '远', '進': '进', '連': '连', '選': '选',
            '點': '点', '線': '线', '麵': '面', '鬥': '斗', '餘': '余',
            '鬆': '松', '準': '准', '備': '备', '僅': '仅', '價': '价',
        }
        result = []
        for ch in text:
            result.append(simple_map.get(ch, ch))
        return ''.join(result)


def convert_to_traditional(text: str) -> str:
    """Convert simplified Chinese to traditional using opencc if available."""
    try:
        import opencc
        cc = opencc.OpenCC('s2t')
        return cc.convert(text)
    except ImportError:
        simple_map = {
            '国': '國', '为': '為', '学': '學', '习': '習',
            '电': '電', '脑': '腦', '汉': '漢', '语': '語', '体': '體',
            '简': '簡', '繁': '繁', '转': '轉', '换': '換', '么': '麼',
            '们': '們', '这': '這', '个': '個', '会': '會', '来': '來',
            '说': '說', '过': '過', '时': '時', '实': '實', '现': '現',
            '认': '認', '识': '識', '开': '開', '发': '發', '机': '機',
            '关': '關', '门': '門', '问': '問', '题': '題', '长': '長',
            '风': '風', '气': '氣', '东': '東', '西': '西', '车': '車',
            '书': '書', '画': '畫', '爱': '愛', '无': '無', '从': '從',
            '与': '與', '对': '對', '应': '應', '该': '該', '还': '還',
            '边': '邊', '远': '遠', '进': '進', '连': '連', '选': '選',
            '点': '點', '线': '線', '面': '麵', '斗': '鬥', '余': '餘',
            '松': '鬆', '准': '準', '备': '備', '仅': '僅', '价': '價',
        }
        result = []
        for ch in text:
            result.append(simple_map.get(ch, ch))
        return ''.join(result)


class PinyinTool:
    """拼音标注工具主类"""

    def __init__(self, root):
        """
        初始化拼音工具界面

        Args:
            root: tkinter根窗口对象
        """
        self.root = root
        self.setup_window()
        self.create_widgets()

    def setup_window(self):
        """设置主窗口属性"""
        self.root.title("拼音标注工具 - Pinyin Annotation Tool")
        self.root.geometry("800x600")
        self.root.resizable(True, True)

        # Set minimum window size
        self.root.minsize(600, 400)

        # Center the window
        self.center_window()

    def center_window(self):
        """将窗口居中显示"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")

    def create_widgets(self):
        """创建界面组件"""
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(2, weight=1)
        main_frame.rowconfigure(4, weight=1)

        # Title
        title_label = ttk.Label(main_frame, text="拼音标注工具",
                                font=("SF Pro Display", 18, "bold"))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))

        # Input section
        input_label = ttk.Label(main_frame, text="输入中文文本:")
        input_label.grid(row=1, column=0, sticky=tk.W, pady=(0, 5))

        self.input_text = scrolledtext.ScrolledText(main_frame, height=8, width=60,
                                                    font=("PingFang SC", 12))
        self.input_text.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S),
                             pady=(0, 10))

        # Style selection frame
        style_frame = ttk.LabelFrame(main_frame, text="拼音风格选择", padding="10")
        style_frame.grid(row=3, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(0, 10))

        self.style_var = tk.StringVar(value="TONE")

        # Style options
        styles = [
            ("标准声调 (zhōng guó)", "TONE"),
            ("数字声调 (zhong1 guo2)", "TONE3"),
            ("无声调 (zhong guo)", "NORMAL"),
            ("首字母 (z g)", "FIRST_LETTER")
        ]

        for i, (text, value) in enumerate(styles):
            ttk.Radiobutton(style_frame, text=text, variable=self.style_var,
                            value=value).grid(row=i//2, column=i%2, sticky=tk.W, padx=10, pady=2)

        # Control buttons frame
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=4, column=0, columnspan=3, pady=(0, 10))

        # Buttons
        convert_btn = ttk.Button(button_frame, text="生成拼音", command=self.convert_pinyin,
                                 style="Accent.TButton")
        convert_btn.pack(side=tk.LEFT, padx=(0, 10))

        copy_btn = ttk.Button(button_frame, text="复制结果", command=self.copy_result)
        copy_btn.pack(side=tk.LEFT, padx=(0, 10))

        # 繁简转换按钮
        simp_btn = ttk.Button(button_frame, text="繁→简", command=self.to_simplified)
        simp_btn.pack(side=tk.LEFT, padx=(0, 10))

        trad_btn = ttk.Button(button_frame, text="简→繁", command=self.to_traditional)
        trad_btn.pack(side=tk.LEFT, padx=(0, 10))

        batch_btn = ttk.Button(button_frame, text="批量处理", command=self.batch_process)
        batch_btn.pack(side=tk.LEFT, padx=(0, 10))

        clear_btn = ttk.Button(button_frame, text="清空内容", command=self.clear_all)
        clear_btn.pack(side=tk.LEFT)

        # Output section
        output_label = ttk.Label(main_frame, text="拼音结果:")
        output_label.grid(row=5, column=0, sticky=tk.W, pady=(10, 5))

        self.output_text = scrolledtext.ScrolledText(main_frame, height=8, width=60,
                                                     font=("PingFang SC", 12),
                                                     state=tk.DISABLED)
        self.output_text.grid(row=6, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Status bar
        self.status_var = tk.StringVar(value="就绪")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var,
                               relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=7, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))

        # Bind Enter key to convert
        self.root.bind('<Command-Return>', lambda e: self.convert_pinyin())

    def convert_pinyin(self):
        """
        转换中文文本为拼音
        根据用户选择的风格生成相应的拼音标注
        """
        try:
            # Get input text
            text = self.input_text.get("1.0", tk.END).strip()
            if not text:
                messagebox.showwarning("警告", "请输入要转换的中文文本")
                return

            self.status_var.set("正在转换...")
            self.root.update()

            # Get selected style
            style_name = self.style_var.get()

            # Convert to pinyin
            pinyin_result = convert_pinyin_text(text, style_name)

            # Display result
            self.output_text.config(state=tk.NORMAL)
            self.output_text.delete("1.0", tk.END)
            self.output_text.insert("1.0", pinyin_result)
            self.output_text.config(state=tk.DISABLED)

            # Update status
            char_count = len([c for c in text if '一' <= c <= '鿿'])
            self.status_var.set(f"转换完成 - 处理了 {char_count} 个汉字")

        except Exception as e:
            messagebox.showerror("错误", f"转换过程中出现错误:\n{str(e)}")
            self.status_var.set("转换失败")

    def copy_result(self):
        """
        复制拼音结果到剪贴板
        """
        try:
            result = self.output_text.get("1.0", tk.END).strip()
            if not result:
                messagebox.showwarning("警告", "没有可复制的内容")
                return

            pyperclip.copy(result)
            self.status_var.set("已复制到剪贴板")
            messagebox.showinfo("成功", "拼音结果已复制到剪贴板")

        except Exception as e:
            messagebox.showerror("错误", f"复制失败:\n{str(e)}")

    def to_simplified(self):
        """将输入文本转换为简体"""
        try:
            text = self.input_text.get("1.0", tk.END).strip()
            if not text:
                messagebox.showwarning("警告", "请输入要转换的中文文本")
                return
            converted = convert_to_simplified(text)
            self.input_text.delete("1.0", tk.END)
            self.input_text.insert("1.0", converted)
            self.status_var.set("已转换为简体中文")
        except Exception as e:
            messagebox.showerror("错误", f"转换失败:\n{str(e)}")

    def to_traditional(self):
        """将输入文本转换为繁体"""
        try:
            text = self.input_text.get("1.0", tk.END).strip()
            if not text:
                messagebox.showwarning("警告", "请输入要转换的中文文本")
                return
            converted = convert_to_traditional(text)
            self.input_text.delete("1.0", tk.END)
            self.input_text.insert("1.0", converted)
            self.status_var.set("已转换为繁体中文")
        except Exception as e:
            messagebox.showerror("错误", f"转换失败:\n{str(e)}")

    def batch_process(self):
        """批量处理文件"""
        try:
            file_paths = filedialog.askopenfilenames(
                title="选择要处理的文本文件",
                filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
            )
            if not file_paths:
                return

            output_dir = filedialog.askdirectory(title="选择输出目录")
            if not output_dir:
                return

            style_name = self.style_var.get()
            self.status_var.set(f"正在批量处理 {len(file_paths)} 个文件...")
            self.root.update()

            results = batch_convert_files(list(file_paths), style_name, output_dir)

            success_count = sum(1 for _, s, _ in results if s)
            fail_count = len(results) - success_count

            detail = "\n".join(
                f"✓ {name}" if ok else f"✗ {name}: {msg}"
                for name, ok, msg in results
            )
            messagebox.showinfo(
                "批量处理完成",
                f"成功: {success_count}\n失败: {fail_count}\n\n{detail}"
            )
            self.status_var.set(f"批量处理完成 - {success_count} 成功, {fail_count} 失败")

        except Exception as e:
            messagebox.showerror("错误", f"批量处理失败:\n{str(e)}")

    def clear_all(self):
        """
        清空所有文本内容
        """
        self.input_text.delete("1.0", tk.END)
        self.output_text.config(state=tk.NORMAL)
        self.output_text.delete("1.0", tk.END)
        self.output_text.config(state=tk.DISABLED)
        self.status_var.set("已清空内容")


def main():
    """主函数"""
    try:
        # Check if pypinyin is installed
        import pypinyin
    except ImportError:
        print("错误: 未安装 pypinyin 库")
        print("请运行: pip install pypinyin")
        sys.exit(1)

    try:
        # Check if pyperclip is installed
        import pyperclip
    except ImportError:
        print("警告: 未安装 pyperclip 库，复制功能将不可用")
        print("建议运行: pip install pyperclip")

    # Create and run the application
    root = tk.Tk()
    app = PinyinTool(root)

    try:
        root.mainloop()
    except KeyboardInterrupt:
        print("\n程序被用户中断")
        sys.exit(0)


if __name__ == "__main__":
    main()
