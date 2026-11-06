-- 拼音标注工具 GUI 安装器
-- 提供图形化安装界面

-- 显示欢迎对话框
set welcomeResult to display dialog "欢迎使用拼音标注工具安装器！\n\n本工具将为您安装AppleScript多格式版本的拼音标注服务。\n\n功能特性：\n• 支持多种拼音格式（标准声调、数字声调等）\n• 可在任何应用程序中使用\n• 支持快捷键和右键菜单调用\n• 智能多音字处理\n\n是否继续安装？" buttons {"取消", "继续安装"} default button "继续安装" with icon note with title "拼音标注工具安装器"

if button returned of welcomeResult is "取消" then
	return
end if

-- 检查安装选项
set installOptions to display dialog "请选择安装选项：" buttons {"快速安装", "自定义安装", "取消"} default button "快速安装" with title "安装选项"

if button returned of installOptions is "取消" then
	return
end if

set installMode to button returned of installOptions

-- 如果选择自定义安装，显示更多选项
if installMode is "自定义安装" then
	set customOptions to display dialog "自定义安装选项：\n\n请选择要安装的服务类型：" buttons {"基础版本", "高级版本", "多格式版本"} default button "多格式版本" with title "自定义安装"
	set serviceType to button returned of customOptions
else
	set serviceType to "多格式版本"
end if

-- 显示安装进度
display dialog "正在开始安装...\n\n请稍候，安装程序将自动检查系统要求并安装必要组件。" buttons {"确定"} default button "确定" with title "安装进行中" giving up after 2

-- 执行安装脚本
try
	set scriptPath to (path to home folder as string) & "Programming:拼音标注工具:install_automator_service.sh"
	set posixPath to POSIX path of scriptPath
	
	-- 检查脚本是否存在
	tell application "System Events"
		if not (exists file posixPath) then
			display dialog "错误：找不到安装脚本\n\n请确保 install_automator_service.sh 文件存在于：\n" & posixPath buttons {"确定"} default button "确定" with icon stop
			return
		end if
	end tell
	
	-- 运行安装脚本
	set installCommand to "cd " & quoted form of (POSIX path of (path to home folder as string) & "Programming/拼音标注工具") & " && chmod +x install_automator_service.sh && ./install_automator_service.sh"
	
	-- 在终端中运行安装脚本
	tell application "Terminal"
		activate
		set newWindow to do script installCommand
		-- 等待脚本完成
		repeat
			delay 1
			if not busy of newWindow then exit repeat
		end repeat
	end tell
	
	-- 显示安装完成对话框
	display dialog "安装完成！\n\n拼音标注服务已成功安装到您的系统中。\n\n使用方法：\n1. 在任何应用程序中选中中文文本\n2. 按快捷键（Cmd+Shift+P）或右键选择服务\n3. 选择您需要的拼音格式\n\n如需卸载，请运行：\n~/Library/Services/uninstall_pinyin_service.sh" buttons {"完成"} default button "完成" with icon note with title "安装成功"
	
on error errorMessage
	-- 显示错误信息
	display dialog "安装过程中发生错误：\n\n" & errorMessage & "\n\n请检查：\n• Python 3 是否已安装\n• 网络连接是否正常\n• 是否有足够的系统权限\n\n您也可以手动运行安装脚本：\n./install_automator_service.sh" buttons {"确定"} default button "确定" with icon stop with title "安装失败"
end try

-- 询问是否需要查看使用教程
set tutorialResult to display dialog "是否需要查看使用教程？\n\n教程包含：\n• 详细的使用方法\n• 快捷键设置指南\n• 常见问题解答\n• 故障排除方法" buttons {"不需要", "查看教程"} default button "查看教程" with title "使用教程"

if button returned of tutorialResult is "查看教程" then
	-- 打开教程文档
	try
		set tutorialPath to (path to home folder as string) & "Programming:拼音标注工具:docs:automator_setup.md"
		tell application "Finder"
			open file tutorialPath
		end tell
	on error
		display dialog "无法打开教程文档\n\n请手动打开：\n~/Programming/拼音标注工具/docs/automator_setup.md" buttons {"确定"} default button "确定"
	end try
end if

-- 结束安装
display dialog "感谢使用拼音标注工具！\n\n如有问题或建议，请访问项目主页获取帮助。" buttons {"确定"} default button "确定" with icon note with title "安装器"