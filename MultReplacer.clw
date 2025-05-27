
!Region Notices and Notes
! ================================================================================
! MIT License
! 
! Copyright (c) 2020 Mark Goldberg
! 
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
! 
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
! 
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
! ===============================================================================================
!
!  Description  : A command line tool, to perform multiple search replaces
!  Created      : May 21st, 2025
!  Last Updated : May 21st, 2025
!
!  C:\> MultiReplacer From=%SourceFile% Changes=%SearchReplacePairsControlFile% [SaveAs=%DestinationFile%] [/Debug]
!
! ===============================================================================================
!EndRegion Notices and Notes

! Possible Future Enhancements
! /NoMessage - remove calls to MESSAGE
!              failures will be HALT N, which can be detected by ERRORLEVEL in batch files
! /Overwrite - when not present should prompt when the SaveAs already exists


 PROGRAM
 MAP
   Debug(STRING xMessage)
   ODS  (STRING xMessage)
   MODULE('API')
     OutputDebugString(*CSTRING),RAW,PASCAL,NAME('OutputDebugStringA')
   END
 END

 INCLUDE('StringTheory.inc'),ONCE

ShowODS      BOOL(FALSE)

FormalUsage  EQUATE('MultiReplacer  From=%SourceFile% Changes=%SearchReplacePairsControlFile% [SaveAs=%DestinationFile%]  [/Debug]')
ExampleUsage EQUATE('c:\> MultiReplacer From="C:\Folder with spaces needs double quotes\Yada.txt"  Changes="C:\Some Folder\ControlFile.txt SaveAs=C:\tmp\ChangedYada.txt')
Usage        EQUATE(FormalUsage & '||Example:|' & ExampleUsage )

FromFilename    ANY          ! From    Filename 
ChangesFilename ANY          ! Changes FileName
SaveAsFilename  ANY          ! SaveAs  FileName

FromFile    StringTheory ! LoadFile to be searched and replaced
ChangesFile StringTheory ! Split list Search ; Replace <13,10>

!==========================================================================================
 CODE 
 Debug('MultiReplacer '& COMMAND() )
 ShowODS         = CHOOSE( UPPER(COMMAND('/Debug')) = 'DEBUG') ! controls if Debug messages are sent to OutputDebugString
 FromFilename    = COMMAND('From')
 ChangesFilename = COMMAND('Changes')
 SaveAsFilename  = COMMAND('SaveAs')
    
 IF SaveAsFilename  = '' 
    SaveAsFilename  = FromFilename        
 END 
        
           ! ODS('ShowODS['& ShowODS &']')
                       Debug('Infile    ['& FromFilename      &']')
                       Debug('Changes   ['& ChangesFilename &']')
                       Debug('SaveAsFile['& SaveAsFilename  &']')

 IF ~EXISTS( FromFilename )
     MESSAGE('From['& FromFilename &']|Not found||Usage:|' & Usage  ,'MultiReplacer cannot continue')
     HALT(1)
 END
    
 IF ~EXISTS( ChangesFilename )
     MESSAGE('Changes['& ChangesFilename &']|Not found||Usage:|' & Usage,'MultiReplacer cannot continue')
     HALT(2) 
 END 

    
! Check for folder ?
! IF ~EXISTS( SaveAsFile )
!     MESSAGE('SaveAs['& SaveAsFile &']|Folder Not found||Usage:|' & Usage,'MultipleRepalce cannot continue')
!     HALT(3) 
! END 

 FromFile.LoadFile( FromFilename )
    
 ChangesFile.LoadFile( ChangesFilename )    
 ChangesFile.Split('<13,10>')

 DO SearchReplaceNow
    
 FromFile.SaveFile( SaveAsFileName )
 RETURN     ! think HALT 0


!---------------------------------
SearchReplaceNow           ROUTINE 
 DATA 
RowNum         LONG,AUTO
ShouldCopyFile BOOL
CurrRow        StringTheory
Count          LONG(0)
SearchFor      ANY 
ReplaceWith    ANY
 CODE 

 LOOP RowNum = 1 TO ChangesFile.Records()
   ! Expected Format: search_for ; Replace With <13,10>
   ! lines in changes file starting with ! are considered commentst
        
   CurrRow.SetValue ( CLIP(ChangesFile.GetLine( RowNum ) ) )
        
   IF CurrRow.Length() = 0 OR CurrRow.StartsWith('!')
                    	    Debug('CYCLE:  RowNum['& RowNum &'] ChangesFile.GetLine( RowNum )['& ChangesFile.GetLine( RowNum ) &']')        
      CYCLE 
   END 
        
   CurrRow.Split(';')         
							IF CurrRow.Records() <> 2
								Debug('Split('';'').Records['& CurrRow.Records() &']  RowNum['& RowNum &'] CurrRow['& CurrRow.GetValue() &']')
							END 
        
   SearchFor   = CLIP( CurrRow.GetLine(1) )
   ReplaceWith = CLIP( CurrRow.GetLine(2) )     
   
   Count = FromFile.Replace( SearchFor, ReplaceWith )
                           Debug('SearchFor['& SearchFor & '] ReplaceWith['& ReplaceWith &'] Count['& Count &']')        
 END 
 
!=========================================
Debug PROCEDURE(STRING xMessage)
  CODE 
  IF ShowODS
     ODS(xMessage)
  END 
!=========================================
ODS   PROCEDURE(STRING xMessage)
sz  &CSTRING
  CODE 
  sz &= NEW CSTRING( SIZE(xMessage) + 1)
  sz  = xMessage
  OutputDebugString( sz )
  DISPOSE(sz)
