"""Type hints and constants for pinyin annotation tool."""

from typing import List, Dict, Optional, Tuple

# Pinyin styles supported by pypinyin
PIYIN_STYLES = {
    'TONE': 'Tone marks (nǐ hǎo)',
    'TONE2': 'Tone numbers after vowels (ni3 hao3)',
    'TONE3': 'Tone numbers at end (ni3 hao3)',
    'NORMAL': 'No tone marks (ni hao)',
    'FIRST_LETTER': 'Initials only (n h)',
}

# Simplified-Traditional mapping (common characters)
SIMPLIFIED_TRADITIONAL: Dict[str, str] = {
    '体': '體', '国': '國', '学': '學', '电': '電', '车': '車',
    '门': '門', '长': '長', '风': '風', '马': '馬', '鱼': '魚',
}

TRADITIONAL_SIMPLIFIED: Dict[str, str] = {v: k for k, v in SIMPLIFIED_TRADITIONAL.items()}

# Common conversion results
ConversionResult = Tuple[str, bool, str]
FileBatchResult = List[ConversionResult]
