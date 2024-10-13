@echo off
setlocal enabledelayedexpansion

REM 获取当前日期和时间
for /f "tokens=1-8 delims=/:. " %%a in ("%date% %time%") do (
    set year=%%a
    set month=%%b
    set day=%%c
    set hour=%%e
    set minute=%%f
    set second=%%g
)
set lastUpdated=%year%-%month%-%day% %hour%:%minute%:%second% +08:00

REM 获取本次提交的 .md 文件列表并更新每个文件中的 lastUpdated 字段
for /f "tokens=2 delims= " %%f in ('svn status ^| findstr /r "^[AM] .*\.md$"') do (
    set "file=%%f"
    set "hasFrontMatter=false"
    set "hasLastUpdated=false"
    set "output="
    set "lineCount=0"

    REM 读取文件的前32行以检查 front matter
    for /f "usebackq delims=" %%a in ("!file!") do (
        set /a lineCount+=1
        if "!lineCount!" leq "32" (
            if "%%a"=="---" (
                if "!hasFrontMatter!"=="tbd" (
                    REM 如果已经有 FrontMatter 结束行，则标记成功
                    set "output=!output!%%a\r\n"
                    set "hasFrontMatter=true"
                    break
                ) else (
                    REM 如果有 FrontMatter 起始行，则标记待定
                    set "hasFrontMatter=tbd"
                )
            ) else if "!hasFrontMatter!"=="false" (
                REM 如果没有 FrontMatter 起始行，则标记失败
                break
            ) else if "%%a:~0,12!"=="lastUpdated:" (
                REM 如果已经有 lastUpdated 字段，则标记
                set "hasLastUpdated=true"
            ) else (
                REM 其他情况，直接复制
            )
            set "output=!output!%%a\r\n"
        ) else (
            REM 如果超过32行还未检测到FrontMatter结束行，则不再检测
            set "hasFrontMatter=false"
            set "hasLastUpdated=false"
            break
        )
    )

    if "!hasFrontMatter!"=="false" (
        REM 如果没有 front matter，则添加
        set "output=---\r\nlastUpdated: %lastUpdated%\r\n---\r\n!output!"
    ) else if "!hasLastUpdated!"=="false" (
        REM 如果没有 lastUpdated字段，则添加
        set "output=!output!lastUpdated: %lastUpdated%\r\n"
    ) else (
        REM 如果有 lastUpdated字段，则更新
        set "output="
        for /f "usebackq delims=" %%l in ("!file!") do (
            set "line=%%l"
            if "!line:~0,12!"=="lastUpdated:" (
                set "output=!output!lastUpdated: %lastUpdated%\r\n"
            ) else (
                set "output=!output!%%l\r\n"
            )
        )
    )

    REM 将修改后的内容写回源文件
    > "!file!" (echo !output!)
)

exit /b