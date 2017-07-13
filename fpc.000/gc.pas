program gc;
 
uses
    Sysutils;
 
var
    FastaFile: TextFile;
    CurrentLine: String;
    GCCount: LongInt;
    ATCount: LongInt;
    TotalBaseCount: LongInt;
    c: Char;
    GCFraction: Single;
    PC,PCEnd: PChar;
 
begin
    ATCount := 0;
    GCCount := 0;
    TotalBaseCount := 0;
 
    Assign(FastaFile, 'Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa'); 
    Reset(FastaFile);
    while not EOF(FastaFile) do begin
        Readln(FastaFile, CurrentLine); 
        if CurrentLine[0] <> '>' then begin
            PC := @CurrentLine[1];
            PCEnd := @CurrentLine[Length(CurrentLine)];
            while PC <= PCEnd do
            begin
                c := PC^;
                if c in ['G','C']  then
                    Inc(GCCount)
                else if c in ['A','T'] then
                    Inc(ATCount);
                Inc(PC);
            end;
        end;
    end;
    Close(FastaFile);
    TotalBaseCount := GCCount + ATCount;
    GCFraction := GCCount / TotalBaseCount;
    Writeln(FormatFloat('00.0000', GCFraction * 100));
end.
