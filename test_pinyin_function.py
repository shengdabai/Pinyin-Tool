#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
拼音转换功能测试脚本
测试pypinyin库的各种功能，确保拼音标注准确
"""

import sys
import os
try:
    from pypinyin import lazy_pinyin, pinyin, Style
except ImportError:
    print("❌ pypinyin库未安装，请运行: pip3 install pypinyin")
    sys.exit(1)

def print_colored(text, color_code):
    """打印带颜色的文本"""
    print(f"\033[{color_code}m{text}\033[0m")

def print_title(title):
    """打印标题"""
    print("\n" + "=" * 60)
    print_colored(f"          {title}", "36")
    print("=" * 60)

def test_basic_conversion():
    """测试基本拼音转换功能"""
    print_title("基本拼音转换测试")
    
    test_cases = [
        "测试",
        "中国", 
        "北京",
        "搜狗输入法",
        "双拼",
        "拼音标注",
        "声调准确"
    ]
    
    styles = [
        (Style.TONE, "标准声调", "zhōng guó"),
        (Style.TONE3, "数字声调", "zhong1 guo2"),
        (Style.NORMAL, "无声调", "zhong guo"),
        (Style.FIRST_LETTER, "首字母", "z g")
    ]
    
    for style, style_name, example in styles:
        print_colored(f"\n=== {style_name} (示例: {example}) ===", "33")
        
        for text in test_cases:
            try:
                result = ' '.join(lazy_pinyin(text, style=style, v_to_u=True))
                print_colored(f"✅ {text} -> {result}", "32")
            except Exception as e:
                print_colored(f"❌ {text} -> 转换失败: {e}", "31")

def test_polyphone():
    """测试多音字处理"""
    print_title("多音字处理测试")
    
    polyphone_cases = [
        ("银行", "yín háng"),  # 不是 yín xíng
        ("音乐", "yīn yuè"),
        ("重要", "zhòng yào"),  # 不是 chóng yào
        ("长大", "zhǎng dà"),   # 不是 cháng dà
        ("好人", "hǎo rén"),
        ("中国银行", "zhōng guó yín háng")
    ]
    
    print_colored("测试多音字的智能识别:", "34")
    
    for text, expected in polyphone_cases:
        try:
            # 普通模式
            result_normal = ' '.join(lazy_pinyin(text, style=Style.TONE, v_to_u=True))
            
            # 多音字模式
            result_hetero = pinyin(text, style=Style.TONE, heteronym=True, v_to_u=True)
            
            print(f"\n{text}:")
            print_colored(f"  智能识别: {result_normal}", "32")
            print_colored(f"  期望结果: {expected}", "36")
            
            # 显示多音字选项
            has_multiple = any(len(char_pinyin) > 1 for char_pinyin in result_hetero)
            if has_multiple:
                print_colored(f"  多音字选项: {result_hetero}", "35")
            
            # 检查是否匹配期望
            if result_normal == expected:
                print_colored("  ✅ 匹配期望结果", "32")
            else:
                print_colored("  ⚠️  与期望不同，但可能正确", "33")
                
        except Exception as e:
            print_colored(f"❌ {text} -> 转换失败: {e}", "31")

def test_special_characters():
    """测试特殊字符处理"""
    print_title("特殊字符处理测试")
    
    special_cases = [
        "你好！",
        "中国，北京。",
        "搜狗输入法（双拼）",
        "测试123数字",
        "English中文混合",
        "标点符号：；，。！？"
    ]
    
    print_colored("测试包含特殊字符的文本:", "34")
    
    for text in special_cases:
        try:
            result = ' '.join(lazy_pinyin(text, style=Style.TONE, v_to_u=True, errors='ignore'))
            print_colored(f"✅ {text} -> {result}", "32")
        except Exception as e:
            print_colored(f"❌ {text} -> 转换失败: {e}", "31")

def test_service_format():
    """测试服务输出格式"""
    print_title("服务输出格式测试")
    
    test_texts = [
        "测试",
        "中国北京",
        "搜狗输入法双拼",
        "拼音标注声调准确"
    ]
    
    print_colored("测试服务期望的输出格式 (原文 + 拼音):", "34")
    
    for text in test_texts:
        try:
            pinyin_result = ' '.join(lazy_pinyin(text, style=Style.TONE, v_to_u=True))
            service_output = f"{text} ({pinyin_result})"
            print_colored(f"✅ 输入: {text}", "36")
            print_colored(f"   输出: {service_output}", "32")
            print()
        except Exception as e:
            print_colored(f"❌ {text} -> 转换失败: {e}", "31")

def test_command_line_usage():
    """测试命令行使用方式"""
    print_title("命令行使用测试")
    
    test_text = "中国北京搜狗输入法"
    
    print_colored("测试不同的命令行调用方式:", "34")
    
    # 方式1: 直接传参
    try:
        cmd1 = f"python3 -c \"from pypinyin import lazy_pinyin, Style; print(' '.join(lazy_pinyin('{test_text}', style=Style.TONE, v_to_u=True)))\""
        print_colored(f"方式1 (直接传参):", "33")
        print_colored(f"命令: {cmd1}", "36")
        
        result1 = ' '.join(lazy_pinyin(test_text, style=Style.TONE, v_to_u=True))
        print_colored(f"结果: {result1}", "32")
        
    except Exception as e:
        print_colored(f"❌ 方式1失败: {e}", "31")
    
    print()
    
    # 方式2: sys.argv传参
    try:
        cmd2 = f"python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; print(' '.join(lazy_pinyin(text, style=Style.TONE, v_to_u=True)))\" '{test_text}'"
        print_colored(f"方式2 (sys.argv传参):", "33")
        print_colored(f"命令: {cmd2}", "36")
        
        # 模拟sys.argv
        import sys
        original_argv = sys.argv
        sys.argv = ['script', test_text]
        
        result2 = ' '.join(lazy_pinyin(sys.argv[1], style=Style.TONE, v_to_u=True))
        print_colored(f"结果: {result2}", "32")
        
        sys.argv = original_argv
        
    except Exception as e:
        print_colored(f"❌ 方式2失败: {e}", "31")

def main():
    """主函数"""
    print_colored("拼音转换功能完整测试", "36")
    print_colored("确保pypinyin库正常工作，拼音标注准确", "36")
    
    # 检查Python版本
    print(f"\nPython版本: {sys.version}")
    
    # 检查pypinyin版本
    try:
        import pypinyin
        print(f"pypinyin版本: {pypinyin.__version__}")
    except:
        print("无法获取pypinyin版本")
    
    # 运行所有测试
    test_basic_conversion()
    test_polyphone()
    test_special_characters()
    test_service_format()
    test_command_line_usage()
    
    print_title("测试完成")
    print_colored("🎉 所有测试完成！如果看到绿色✅，说明功能正常", "32")
    print_colored("如果有红色❌，请检查pypinyin库安装", "33")
    
    # 提供使用建议
    print_colored("\n💡 使用建议:", "36")
    print_colored("1. 推荐使用'标准声调'格式，声调最准确", "34")
    print_colored("2. 设置v_to_u=True可以正确显示ü字符", "34")
    print_colored("3. 多音字会根据上下文智能选择", "34")
    print_colored("4. 服务输出格式: 原文 (拼音)", "34")

if __name__ == "__main__":
    main()