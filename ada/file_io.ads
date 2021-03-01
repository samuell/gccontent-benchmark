with Ada.Text_IO;

--  This package is introduced to provide an exception free API
--  for text file input. The subprograms in the Ada.Text_IO package
--  may raise exceptions and they are therefore hidden in the body
--  of this package. A subprogram contains a declarative part and
--  and executable part:
--
--  procedure Subprogram_Name is
--     <declarative part>
--  begin
--     <executable part>
--  end Subprogram_Name;
--
--  To convince yourself that all subprograms in this package are
--  exception-free note that the declarative part of all subprogram
--  bodies are empty. This is important because introduction of a variable
--  here may raise Storage exception due to out of stack space.
--  Also note that each subprogram body contains an exception handler
--  that handles any exception raised in the executable part.
package File_IO with SPARK_Mode => On is

   type Open_Result is (File_Open,
                        File_Closed,
                        Open_Error);

   type File_Type is limited private with
     Default_Initial_Condition => Open_Status (File_Type) = File_Closed;

   procedure Open_Input_File (Name       : String;
                              File       : in out File_Type;
                              Is_Success : out Boolean) with
     Pre  => Open_Status (File) = File_Closed ,
     Post => (if Is_Success then Open_Status (File) = File_Open);

   function Open_Status (File : File_Type) return Open_Result;

   type EOF_Result is (End_Reached,
                       More_Data_Exists,
                       EOF_Error);

   function End_Of_File (File : File_Type) return EOF_Result;

   subtype Last_Type is Natural range 0 .. 120;

   type Read_Result (Last : Last_Type) is record
      Is_Success : Boolean;
      Text : String (1 .. Last);
   end record;

   function Read_Line (File : File_Type) return Read_Result;

   procedure Close (File       : in out File_Type;
                    Is_Success : out Boolean) with
     Pre    => Open_Status (File) = File_Open,
     Post   => Open_Status (File) = File_Closed;

private
   pragma SPARK_Mode (Off);

   type File_Type is limited record
      Value : Ada.Text_IO.File_Type;
   end record;

end File_IO;
