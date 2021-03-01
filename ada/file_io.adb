package body File_IO with SPARK_Mode => Off is

   use all type Ada.Text_IO.File_Type;

   function Open_Status (File : File_Type) return Open_Result is
   begin
      if Is_Open (File.Value) then
         return File_Open;
      else
         return File_Closed;
      end if;
   exception
      when others =>
         return Open_Error;
   end Open_Status;

   procedure Open_Input_File (Name       : String;
                              File       : in out File_Type;
                              Is_Success : out Boolean) is
   begin
      Open (File => File.Value,
            Mode => Ada.Text_IO.In_File,
            Name => Name);
      Is_Success := True;
   exception
      when others =>
         Is_Success := False;
   end Open_Input_File;

   procedure Close (File       : in out File_Type;
                    Is_Success : out Boolean) is
   begin
      Close (File.Value);
      Is_Success := True;
   exception
      when others =>
         Is_Success := False;
   end Close;

   function End_Of_File (File : File_Type) return EOF_Result is
   begin
      if End_Of_Line (File.Value) then
         return End_Reached;
      else
         return More_Data_Exists;
      end if;
   exception
      when others =>
         return EOF_Error;
   end End_Of_File;

   function Read_Line (File : File_Type) return Read_Result is
   begin
      declare
         Line : constant String := Get_Line (File.Value);
      begin
         return (Is_Success => True, Last => Line'Last, Text => Line);
      end;
   exception
      when others =>
         return (Is_Success => False, Last => 0, Text => (others => ' '));
   end Read_Line;

end File_IO;
