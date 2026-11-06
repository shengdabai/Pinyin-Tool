#!/usr/bin/env python3
"""Unit tests for pinyin_tool.py extracted functions."""
import unittest
import os
import tempfile
from unittest.mock import patch
from pinyin_tool import convert_pinyin_text, batch_convert_files, convert_to_simplified


class TestConvertPinyinText(unittest.TestCase):
    """Test the pinyin conversion function."""

    def test_tone_style(self):
        result = convert_pinyin_text('你好', 'TONE')
        # TONE = tone-mark diacritics (UI label: 标准声调 zhōng guó), so the
        # expected output is 'nǐ hǎo', not the toneless 'ni hao'.
        self.assertEqual(result, 'nǐ hǎo')

    def test_tone3_style(self):
        result = convert_pinyin_text('你好', 'TONE3')
        self.assertIn('ni3', result)
        self.assertIn('hao3', result)

    def test_normal_style(self):
        result = convert_pinyin_text('你好', 'NORMAL')
        self.assertEqual(result, 'ni hao')

    def test_first_letter_style(self):
        result = convert_pinyin_text('你好', 'FIRST_LETTER')
        self.assertEqual(result, 'n h')

    def test_empty_string(self):
        result = convert_pinyin_text('', 'NORMAL')
        self.assertEqual(result, '')

    def test_mixed_chinese_english(self):
        result = convert_pinyin_text('你好world', 'NORMAL')
        self.assertIn('ni', result)

    def test_unknown_style_defaults_to_tone(self):
        result = convert_pinyin_text('你好', 'UNKNOWN_STYLE')
        self.assertTrue(len(result) > 0)

    def test_simplified_fallback_converts_each_character(self):
        with patch.dict('sys.modules', {'opencc': None}):
            self.assertEqual(convert_to_simplified('繁體轉換與學習'), '繁体转换与学习')


class TestBatchConvertFiles(unittest.TestCase):
    """Test the batch file processing function."""

    def test_existing_output_is_preserved(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            source = os.path.join(tmpdir, 'lesson.txt')
            output = os.path.join(tmpdir, 'lesson_pinyin.txt')
            for path, text in ((source, '你好'), (output, '用户已有内容')):
                with open(path, 'w', encoding='utf-8') as handle:
                    handle.write(text)
            results = batch_convert_files([source], 'NORMAL', tmpdir)
            self.assertFalse(results[0][1])
            with open(output, encoding='utf-8') as handle:
                self.assertEqual(handle.read(), '用户已有内容')

    def test_output_symlink_cannot_overwrite_its_target(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            source = os.path.join(tmpdir, 'lesson.txt')
            with open(source, 'w', encoding='utf-8') as handle:
                handle.write('你好')
            os.symlink(source, os.path.join(tmpdir, 'lesson_pinyin.txt'))
            results = batch_convert_files([source], 'NORMAL', tmpdir)
            self.assertFalse(results[0][1])
            with open(source, encoding='utf-8') as handle:
                self.assertEqual(handle.read(), '你好')

    def test_output_cannot_overwrite_another_selected_input(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            first = os.path.join(tmpdir, 'lesson.txt')
            second = os.path.join(tmpdir, 'lesson_pinyin.txt')
            for path, text in ((first, '你好'), (second, '中国')):
                with open(path, 'w', encoding='utf-8') as handle:
                    handle.write(text)
            results = batch_convert_files([first, second], 'NORMAL', tmpdir)
            self.assertFalse(results[0][1])
            self.assertTrue(results[1][1])
            with open(second, encoding='utf-8') as handle:
                self.assertEqual(handle.read(), '中国')
            with open(os.path.join(tmpdir, 'lesson_pinyin_pinyin.txt'),
                      encoding='utf-8') as handle:
                self.assertEqual(handle.read(), 'zhong guo')

    def test_duplicate_basenames_report_collision(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            files = []
            for folder, text in (('one', '你好'), ('two', '中国')):
                directory = os.path.join(tmpdir, folder)
                os.mkdir(directory)
                path = os.path.join(directory, 'lesson.txt')
                with open(path, 'w', encoding='utf-8') as handle:
                    handle.write(text)
                files.append(path)
            results = batch_convert_files(files, 'NORMAL', tmpdir)
            self.assertEqual([result[1] for result in results], [True, False])
            with open(os.path.join(tmpdir, 'lesson_pinyin.txt'), encoding='utf-8') as handle:
                self.assertEqual(handle.read(), 'ni hao')

    def test_single_file_conversion(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create input file
            input_path = os.path.join(tmpdir, 'test.txt')
            with open(input_path, 'w', encoding='utf-8') as f:
                f.write('你好世界')

            results = batch_convert_files([input_path], 'NORMAL', tmpdir)
            self.assertEqual(len(results), 1)
            name, success, msg = results[0]
            self.assertTrue(success)
            self.assertEqual(name, 'test.txt')

            # Verify output file exists
            output_path = os.path.join(tmpdir, 'test_pinyin.txt')
            self.assertTrue(os.path.exists(output_path))
            with open(output_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self.assertIn('ni', content)

    def test_nonexistent_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            results = batch_convert_files(
                ['/nonexistent/file.txt'], 'NORMAL', tmpdir)
            self.assertEqual(len(results), 1)
            name, success, msg = results[0]
            self.assertFalse(success)

    def test_multiple_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            files = []
            for i in range(3):
                fp = os.path.join(tmpdir, f'file{i}.txt')
                with open(fp, 'w', encoding='utf-8') as f:
                    f.write('中文')
                files.append(fp)

            results = batch_convert_files(files, 'NORMAL', tmpdir)
            self.assertEqual(len(results), 3)
            self.assertTrue(all(s for _, s, _ in results))


if __name__ == '__main__':
    unittest.main()
