@ECHO OFF
SET IRVINE=C:\Irvine
SET FILEBASE=%~n1
echo Handling Source: %FILEBASE%
setlocal

rem REPLACE THESE PATHS WITH YOUR asm_CSE3120 PATHS FROM THE ASSIGNMENT Lab Start - Configuring Windows Command-Line Compilers
set "PATH=C:\Program Files (x86);...;%PATH%"

set "PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin;C:\Program Files (x86)\Windows Kits\8.1\bin\x86;;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\tools;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\ide;C:\Program Files (x86)\HTML Help Workshop;;C:\Program Files (x86)\MSBuild\14.0\bin\;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\;C:\WINDOWS\SysWow64;;C:\Program Files\Common Files\Oracle\Java\javapath;C:\Program Files (x86)\Common Files\Oracle\Java\java8path;C:\Program Files (x86)\Common Files\Oracle\Java\javapath;c:\windows\system32;c:\windows;c:\windows\system32\wbem;c:\windows\system32\windowspowershell\v1.0\;c:\windows\system32\openssh\;c:\program files\nvidia corporation\nvidia nvdlisr;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Program Files\dotnet\;C:\Program Files\GitHub CLI\;C:\Program Files\Git\cmd;C:\Program Files\PuTTY\;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\CMake\bin;C:\Program Files\Docker\Docker\resources\bin;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;C:\Users\User\AppData\Local\Programs\Python\Launcher\;C:\Users\User\AppData\Local\Microsoft\WindowsApps;C:\Program Files\7-zip;C:\ProgramData\User\GitHubDesktop\bin;C:\Users\User\AppData\Local\GitHubDesktop\bin;"


set "LIB=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\lib;;C:\Program Files (x86)\Windows Kits\10\lib\10.0.10240.0\ucrt\x86;;;C:\Program Files (x86)\Windows Kits\8.1\lib\winv6.3\um\x86;;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\Lib\um\x86"


set "LIBPATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\lib;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib;"


set "INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\include;;C:\Program Files (x86)\Windows Kits\10\Include\10.0.10240.0\ucrt;;;C:\Program Files (x86)\Windows Kits\8."
rem END OF PATHS TO EDIT

ml /c /coff /Zi /I "C:\Irvine" SourceFiles/main.asm SourceFiles/attack_manager.asm SourceFiles/draw_manager.asm SourceFiles/units.asm
link /subsystem:console /libpath:"C:\Irvine" irvine32.lib kernel32.lib user32.lib main.obj attack_manager.obj draw_manager.obj units.obj
endlocal
