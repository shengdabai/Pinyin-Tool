"""Regression tests for AppleScript trust boundaries and installer output.

Native AppleScript checks run on macOS without invoking clipboard or GUI APIs.
The installer checks use shell stubs so they never install services or open apps.
"""
import os
from pathlib import Path
import plistlib
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

from pypinyin import lazy_pinyin, Style

ROOT = Path(__file__).resolve().parent
OSASCRIPT = shutil.which('osascript')


def source(name):
    return (ROOT / name).read_text(encoding='utf-8')


def apple_string(text):
    return '"' + (text.replace('\\', '\\\\').replace('"', '\\"')
                  .replace('\n', '\\n').replace('\r', '\\r')) + '"'


def apple_eval(script):
    result = subprocess.run([OSASCRIPT, '-e', script], check=True,
                            capture_output=True, text=True, timeout=15)
    return result.stdout.removesuffix('\n')


def matching_line(text, fragment):
    return next(line.strip() for line in text.splitlines() if fragment in line)


class TestScriptBoundaries(unittest.TestCase):
    def test_error_log_data_is_shell_quoted(self):
        for name in ('fixed_pinyin_service.scpt', 'quick_fix_service.sh'):
            with self.subTest(name=name):
                command = matching_line(source(name), 'do shell script "printf')
                self.assertIn('quoted form of logMessage', command)

    def test_clipboard_is_an_argument_not_python_source(self):
        text = source('scripts/quick_pinyin.scpt')
        code = matching_line(text, 'set pythonScript to')
        self.assertNotIn('selectedText', code)
        self.assertIn('sys.argv[1]', code)
        command = matching_line(text, 'set pinyinResult to do shell script')
        self.assertIn('quoted form of pythonScript', command)
        self.assertIn('quoted form of selectedText', command)

    @unittest.skipUnless(OSASCRIPT, 'Native AppleScript requires macOS')
    def test_clipboard_shell_and_python_payloads_are_literal(self):
        text = source('scripts/quick_pinyin.scpt')
        code = matching_line(text, 'set pythonScript to')
        expression = matching_line(text, 'set pinyinResult to do shell script')
        expression = expression.split('do shell script ', 1)[1]
        with tempfile.TemporaryDirectory() as directory:
            payloads = ['你好', "中国'); __import__('os').system('touch python_marker'); #",
                        '你好\'\" $(touch shell_marker) `touch backtick_marker`\n\\世界']
            for payload in payloads:
                with self.subTest(payload=payload):
                    command = apple_eval('set selectedText to ' + apple_string(payload)
                                         + '\n' + code + '\nreturn ' + expression)
                    self.assertTrue(command.startswith('python3 '))
                    command = shlex.quote(sys.executable) + command[len('python3'):]
                    result = subprocess.run(['/bin/sh', '-c', command], cwd=directory,
                                            capture_output=True, text=True, timeout=15)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    expected = ' '.join(lazy_pinyin(payload, style=Style.TONE))
                    self.assertEqual(result.stdout, expected + '\n')
            self.assertEqual(list(Path(directory).iterdir()), [])

    @unittest.skipUnless(OSASCRIPT, 'Native AppleScript requires macOS')
    def test_project_path_remains_one_shell_argument(self):
        command_line = matching_line(source('scripts/pinyin_shortcut.scpt'),
                                     'set pythonCommand to')
        project = "/tmp/example's project; $(touch path_marker)"
        command = apple_eval('set projectPath to ' + apple_string(project)
                             + '\n' + command_line + '\nreturn pythonCommand')
        self.assertEqual(shlex.split(command), ['python3', project + '/pinyin_tool.py'])

    @unittest.skipUnless(OSASCRIPT, 'Native AppleScript requires macOS')
    def test_service_error_messages_cannot_run_shell_commands(self):
        for name in ('fixed_pinyin_service.scpt', 'quick_fix_service.sh'):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
                text = source(name)
                message = "bad input'; touch marker; # $(touch other_marker)\n中文"
                assignment = matching_line(text, 'set logMessage to')
                expression = matching_line(text, 'do shell script "printf')
                expression = expression.split('do shell script ', 1)[1]
                command = apple_eval('set errorMessage to ' + apple_string(message)
                                     + '\n' + assignment + '\nreturn ' + expression)
                sink = ' >> ~/Library/Logs/pinyin_service.log'
                self.assertTrue(command.endswith(sink))
                log = Path(directory) / 'error.log'
                command = command[:-len(sink)] + ' >> ' + shlex.quote(str(log))
                subprocess.run(['/bin/sh', '-c', command], cwd=directory,
                               check=True, capture_output=True, timeout=15)
                self.assertEqual(log.read_text(), '拼音标注服务错误: ' + message + '\n')
                self.assertEqual(list(Path(directory).iterdir()), [log])

    @unittest.skipUnless(OSASCRIPT, 'Native AppleScript requires macOS')
    def test_logging_failure_still_returns_original_text(self):
        for name in ('fixed_pinyin_service.scpt', 'quick_fix_service.sh'):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
                text = source(name)
                block = text.split('-- 记录错误到系统日志\n', 1)[1]
                block = block.split('\n    end try', 1)[0]
                missing_sink = str(Path(directory) / 'missing' / 'error.log')
                block = block.replace('~/Library/Logs/pinyin_service.log', missing_sink)
                result = apple_eval('set inputText to "原文"\nset errorMessage to "error"\n'
                                    + block)
                self.assertEqual(result, '原文')


class TestInstallerOutput(unittest.TestCase):
    def test_workflow_templates_are_valid_plists(self):
        templates = re.findall(r'<\?xml.*?</plist>',
                               source('install_automator_service.sh'), re.S)
        self.assertEqual(len(templates), 2)
        info, workflow = [plistlib.loads(template.encode()) for template in templates]
        self.assertTrue(info['NSServices'])
        script = workflow['actions'][0]['action']['ActionParameters']['source']
        self.assertIn('& quoted form of inputText', script)
        self.assertIn('inputText & " (" & pinyinResult & ")"', script)
        self.assertNotIn('&amp;', script)

    def run_function(self, name, function, directory, extra=''):
        # Loading definitions only avoids the interactive installer entry point.
        script = re.sub(r'^main "\$@"\s*$', '', source(name), flags=re.M)
        harness = '''
osascript() { printf '%s\n' "$1" >> "$CAPTURE"; test -s "$1"; }
open() { if [ "$#" -eq 3 ]; then printf '%s\n' "$3" >> "$CAPTURE"; fi; }
read() { return 0; }
'''
        env = dict(os.environ, TMPDIR=str(directory), CAPTURE=str(directory / 'capture'))
        return subprocess.run(['bash', '-c', script + harness + extra + '\n'
                               + function + '\n' + function], env=env,
                              capture_output=True, text=True, timeout=15)

    def test_temporary_scripts_are_private_unique_and_cleaned(self):
        cases = [('install_automator_service.sh', 'setup_permissions', 'setup_permissions.scpt'),
                 ('install_automator_service.sh', 'setup_shortcut_key', 'setup_shortcut.scpt'),
                 ('install_automator_service.sh', 'test_service', 'test_pinyin_service.scpt'),
                 ('create_correct_service.sh', 'create_automator_service', 'pinyin_service.scpt')]
        for name, function, legacy in cases:
            with self.subTest(function=function), tempfile.TemporaryDirectory() as tmp:
                self.assertNotIn('"/tmp/' + legacy + '"', source(name))
                directory = Path(tmp) / 'temporary scripts'
                directory.mkdir()
                victim = directory / 'preserve.txt'
                victim.write_text('keep')
                (directory / legacy).symlink_to(victim)
                result = self.run_function(name, function, directory)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(victim.read_text(), 'keep')
                paths = (directory / 'capture').read_text().splitlines()
                self.assertEqual(len(paths), 2)
                self.assertEqual(len(set(paths)), 2)
                for path in set(paths):
                    path = Path(path)
                    if function == 'create_automator_service':
                        self.assertEqual(path.parent.parent, directory)
                        self.assertEqual(path.suffix, '.scpt')
                        self.assertEqual(stat.S_IMODE(path.parent.stat().st_mode), 0o700)
                        self.assertTrue(path.read_text().startswith('-- 拼音标注服务'))
                        self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o600)
                    else:
                        self.assertEqual(path.parent, directory)
                        self.assertFalse(path.exists())

    def test_temporary_file_creation_failure_stops_execution(self):
        cases = [('install_automator_service.sh', 'setup_permissions'),
                 ('install_automator_service.sh', 'setup_shortcut_key'),
                 ('install_automator_service.sh', 'test_service'),
                 ('create_correct_service.sh', 'create_automator_service')]
        for name, function in cases:
            with self.subTest(function=function), tempfile.TemporaryDirectory() as tmp:
                directory = Path(tmp)
                result = self.run_function(name, function, directory,
                                           'mktemp() { return 1; }')
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(list(directory.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
