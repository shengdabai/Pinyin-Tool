#!/usr/bin/env python3
"""Unit tests for type definitions and constants."""
import unittest
import re
from pathlib import Path
from pinyin_types import (
    PIYIN_STYLES,
    SIMPLIFIED_TRADITIONAL,
    TRADITIONAL_SIMPLIFIED,
    ConversionResult,
)


class TestWorkflowEntrypoints(unittest.TestCase):
    def test_referenced_scripts_exist(self):
        root = Path(__file__).resolve().parent
        workflow = (root / '.github/workflows/ci.yml').read_text()
        for script in re.findall(r'\./(scripts/[\w./-]+)', workflow):
            with self.subTest(script=script):
                self.assertTrue((root / script).is_file(), script)


class TestPinyinStyles(unittest.TestCase):
    """Test pinyin style definitions."""

    def test_all_styles_have_descriptions(self):
        for style, desc in PIYIN_STYLES.items():
            self.assertIsInstance(style, str)
            self.assertIsInstance(desc, str)
            self.assertGreater(len(desc), 0)

    def test_five_styles_defined(self):
        self.assertEqual(len(PIYIN_STYLES), 5)
        self.assertIn('TONE', PIYIN_STYLES)
        self.assertIn('NORMAL', PIYIN_STYLES)
        self.assertIn('FIRST_LETTER', PIYIN_STYLES)


class TestCharMapping(unittest.TestCase):
    """Test Simplified-Traditional character mapping."""

    def test_bidirectional_mapping(self):
        for s, t in SIMPLIFIED_TRADITIONAL.items():
            self.assertEqual(TRADITIONAL_SIMPLIFIED[t], s)

    def test_common_characters(self):
        self.assertEqual(SIMPLIFIED_TRADITIONAL['国'], '國')
        self.assertEqual(SIMPLIFIED_TRADITIONAL['学'], '學')
        self.assertEqual(SIMPLIFIED_TRADITIONAL['电'], '電')

    def test_mapping_count(self):
        self.assertGreater(len(SIMPLIFIED_TRADITIONAL), 0)


if __name__ == '__main__':
    unittest.main()
