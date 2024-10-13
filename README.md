## DESCRIPTION

- 该脚本设计为在 TortoiseSVN 中作为 pre-commit hook 使用，以在提交更改之前自动更新 Markdown 文件的 front matter。

- 它将处理当前目录中根据 SVN 状态已添加或修改的所有 Markdown (.md) 文件。它会在每个文件的 front matter 中更新或添加一个 "lastUpdated" 字段，格式为 ISO8601 格式 "yyyy-MM-ddTHH:mm:ssZ" 的当前日期和时间。

- 该脚本假设 front matter 包含在 "---" 行内。
  - 如果文件没有 front matter，它会在文件开头添加 front matter。
  - 如果文件有 front matter 但没有 "lastUpdated" 字段，它会添加该字段。
  - 如果文件已经有 "lastUpdated" 字段，它会用当前日期和时间更新该字段。

### 示例

- .\update.ps1
- 这将使用当前日期和时间更新当前目录中所有已添加或修改的 Markdown 文件的 front matter。

### 示例

- 在 TortoiseSVN 中设置提交钩子的示例：

  1. 打开 TortoiseSVN 设置。
  2. 导航到 "Hook Scripts"。
  3. 为 "Commit" 钩子添加一个新的钩子脚本。
     ```powershell
     powershell -ExecutionPolicy ByPass -File "\path\to\file.ps1"
     ```
  4. 设置此脚本的路径。
  5. 保存设置。

### 注意事项

- 确保脚本在提交过程中具有执行的必要权限。
- 脚本使用 UTF-8 编码读取和写入文件。
- 脚本最多会检测文件前 32 行，超过此范围的 front matter 会认为无效。
- 如果 front matter 中有多个 lastUpdated 字段，只有最后一个会被更新。
- 新添加的 lastUpdated 字段将插入到 front matter 的最后一行。
- 如果文件末尾没有换行符，将在文件末尾添加一个换行符。
- 脚本使用 "UTC" 时区格式的当前日期和时间。
- 脚本设计为与 TortoiseSVN 一起使用，但可以适应其他版本控制系统。
- 脚本设计为与 Windows PowerShell 一起使用，但可以适应其他 shell。
- 脚本设计为与 Markdown 文件一起使用，但可以适应其他文件类型。

### 解释

这段 PowerShell 脚本的主要目的是更新 SVN 仓库中所有 `.md` 文件的 front matter（文件头部信息），特别是更新或添加 `lastUpdated` 字段。

首先，脚本通过 `Get-Date` 获取当前的日期和时间，并将其存储在 `$dateTime` 变量中。接着，使用 `svn status` 命令获取当前提交中所有 `.md` 文件的列表，并通过 `Select-String -Pattern "^[AM] .*\.md$"` 过滤出新增或修改的 `.md` 文件。

对于每个文件，脚本首先移除 SVN 状态信息，只保留文件路径。然后，读取文件内容并存储在 `$fileContent` 变量中。为了方便处理，文件内容被转换为 [`ArrayList`] 类型。

接下来，脚本检查文件的前 32 行是否包含 front matter。如果找到 front matter 的起始和结束标记（`---`），则标记 `$frontMatterIndex` 为 [`true`]。如果找到 `lastUpdated` 字段，则记录其所在行号。

根据检查结果，脚本会执行不同的操作：

1. 如果文件内容为空，则创建一个新的 front matter 并添加 `lastUpdated` 字段。
2. 如果文件没有 front matter，则在文件开头插入一个新的 front matter，并添加 `lastUpdated` 字段。
3. 如果文件有 front matter 但没有 `lastUpdated` 字段，则在适当位置插入 `lastUpdated` 字段。
4. 如果文件已有 `lastUpdated` 字段，则更新其值为当前日期和时间。

最后，脚本将更新后的内容写回文件，并输出更新结果。
