"""Unit tests for pinyin conversion core logic using pypinyin directly."""
import unittest
from pypinyin import pinyin, Style


class TestPinyinConversion(unittest.TestCase):
    """Test the core pinyin conversion functionality used by the tool."""

    def test_basic_conversion_normal(self):
        """Test basic Chinese to pinyin conversion."""
        result = pinyin('你好', style=Style.NORMAL)
        self.assertEqual(result, [['ni'], ['hao']])

    def test_conversion_with_tones(self):
        """Test pinyin with tone marks."""
        result = pinyin('你好', style=Style.TONE)
        # Style.TONE emits tone-mark diacritics (pypinyin docs), not plain
        # letters or digits. 你=nǐ, 好=hǎo (both 3rd tone; Hanyu Pinyin
        # orthography does not write the 3rd-tone sandhi, so no "ní hǎo").
        self.assertEqual(result, [['nǐ'], ['hǎo']])

    def test_conversion_initials(self):
        """Test initials-only mode."""
        result = pinyin('你好', style=Style.FIRST_LETTER)
        self.assertEqual(result, [['n'], ['h']])

    def test_empty_string(self):
        """Test empty string input."""
        result = pinyin('', style=Style.NORMAL)
        self.assertEqual(result, [])

    def test_mixed_chinese_english(self):
        """Test mixed Chinese and English text."""
        result = pinyin('你好world', style=Style.NORMAL)
        # Each Chinese char gets its own pinyin group; pypinyin keeps the
        # contiguous non-Chinese run 'world' as ONE group. 你, 好, world => 3.
        self.assertEqual(result, [['ni'], ['hao'], ['world']])

    def test_long_text(self):
        """Test conversion of longer text."""
        text = '今天天气很好'
        result = pinyin(text, style=Style.NORMAL)
        self.assertEqual(len(result), len(text))
        for group in result:
            self.assertTrue(len(group[0]) > 0)

    def test_style_tone2(self):
        """Test TONE2 style (tone number after vowel)."""
        result = pinyin('你好', style=Style.TONE2)
        self.assertTrue('ni' in result[0][0])


if __name__ == '__main__':
    unittest.main()
