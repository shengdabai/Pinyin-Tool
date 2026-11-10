-- 拼音标注服务 - 修复版本
-- 确保不覆盖原文，在原文后添加拼音标注
-- 格式：原文 (拼音)

on run {input, parameters}
    set inputText to input as string
    
    -- 检查输入是否为空
    if inputText is "" then
        display notification "请先选中要转换的中文文本" with title "拼音标注服务"
        return inputText
    end if
    
    -- 让用户选择拼音风格
    set styleChoice to choose from list {"标准声调 (zhōng guó)", "数字声调 (zhong1 guo2)", "无声调 (zhong guo)", "首字母 (z g)"} with prompt "选择拼音风格：" default items {"标准声调 (zhōng guó)"}
    
    if styleChoice is false then
        return inputText
    end if
    
    -- 根据选择设置样式
    set selectedStyle to item 1 of styleChoice
    if selectedStyle contains "标准声调" then
        set pinyinStyle to "Style.TONE"
    else if selectedStyle contains "数字声调" then
        set pinyinStyle to "Style.TONE3"
    else if selectedStyle contains "无声调" then
        set pinyinStyle to "Style.NORMAL"
    else if selectedStyle contains "首字母" then
        set pinyinStyle to "Style.FIRST_LETTER"
    end if
    
    try
        -- 构建Python命令，确保使用正确的拼音库和参数
        set pythonCommand to "python3 -c \"from pypinyin import lazy_pinyin, Style; import sys; text = sys.argv[1]; result = ' '.join(lazy_pinyin(text, style=" & pinyinStyle & ", v_to_u=True)); print(result)\" " & quoted form of inputText
        
        -- 执行Python脚本获取拼音
        set pinyinResult to do shell script pythonCommand
        
        -- 组合原文和拼音，格式：原文 (拼音)
        set finalResult to inputText & " (" & pinyinResult & ")"
        
        -- 显示成功通知
        display notification "标注完成: " & pinyinResult with title "拼音标注服务" subtitle "成功"
        
        -- 返回组合结果
        return finalResult
        
    on error errorMessage
        -- 详细的错误处理
        display notification "转换失败: " & errorMessage with title "拼音标注服务" subtitle "错误"
        
        -- 记录错误到系统日志
        set logMessage to "拼音标注服务错误: " & errorMessage
        try
            do shell script "printf '%s\\n' " & quoted form of logMessage & " >> ~/Library/Logs/pinyin_service.log"
        on error
            -- Logging must not prevent returning the original text.
        end try
        
        -- 返回原文，不做修改
        return inputText
    end try
end run
