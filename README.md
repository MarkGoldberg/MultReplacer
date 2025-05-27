# MultReplacer
Command line utility that uses a control file to specify a collection of Search-Replacements


Usage
------
C:\> MultReplacer From=%SourceFile% Changes=%SearchReplacePairsControlFile% SaveAs=%DestinationFile% [/Debug]

---
**/Debug**
will write messages to OutputDebugString (ODS)

My favorite ODS viewer is [DebugViewPP](https://github.com/CobaltFusion/DebugViewPP)

Examples
---------
```c:\> MultReplacer```

Error, will show a usage window

---



```c:\> MultReplacer From="C:\Folder with spaces needs double quotes\Yada.txt"  SaveAs=C:\tmp\ChangedYada.txt Changes="C:\Some Folder\ControlFile.txt```

will perform multiple searches and replacements

the FROM argument is required

The SaveAs argument can be omitted, 
   in which case the From file will be used as the To file

The CHANGES argument is required

