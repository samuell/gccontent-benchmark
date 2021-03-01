with Ada.Text_IO;
with Ada.Long_Float_Text_IO;
--  No need to put pragma Elaborate_All on standard library packages.

with File_IO;
pragma Elaborate_All (File_IO);
--  Imagine some developer in the future introduces a dependency
--  upon the code in this file in the File_IO package or any of the code
--  that it depends upon by writing "with Gc;". Putting a pragma Elaborate_All
--  on the package enables the compiler to detect such circular dependencies.

--  This application can be compiled with two compilers:
--     1. The GNAT CE (Community Edition) 2020 compiler (gcc)
--     2. The GNAT LLVM compiler
--  All proofs can be recreated using the SPARK tools part of GNAT CE 2020.
--  In GNAT Studio select SPARK -> Prove All Sources, proof level 2.
--
--  To compile the code using GNAT CE 2020:
--
--    gprbuild -P default.gpr
--
--  To compile using the GNAT-LLVM compiler:
--
--    llvm-gnatmake -P default.gpr
--
procedure Gc with SPARK_Mode is

   --  The code in this file is SPARK code and can successfully be formally
   --  verified by the SPARK tools which means it is safe to suppress
   --  the following run-time checks the compiler otherwise would genereate
   --  unless it can itself prove a check is unnecessary.
   pragma Suppress (Discriminant_Check);
   pragma Suppress (Division_Check);
   pragma Suppress (Index_Check);
   pragma Suppress (Length_Check);
   pragma Suppress (Range_Check);
   pragma Suppress (Tag_Check);
   pragma Suppress (Overflow_Check);
   --  Note that overflow checks are expensive performance-wise.
   --  These checks can here be safely turned off since it can be
   --  mathematically proven that it cannot happen with any of the variables
   --  used in this application.

   use all type File_IO.Read_Result;
   use all type File_IO.EOF_Result;
   --  use all type enables use of enumeration values without need
   --  for prefixing them with the package name.

   subtype Nucleotide_Count is Long_Integer range 0 .. Long_Integer'Last / 4;
   --  The restriction on the maximum allowed value can be relaxed
   --  but will make the contracts more cumbersome to write.

   A : Nucleotide_Count := 0;
   T : Nucleotide_Count := 0;
   G : Nucleotide_Count := 0;
   C : Nucleotide_Count := 0;

   procedure Handle_Read_Line (Line           : File_IO.Read_Result;
                               Shall_Continue : in out Boolean) with
     Global => (In_Out => (A, T, G, C, Ada.Text_IO.File_System)),
     Pre    => A + T + G + C <= Nucleotide_Count'Last - 120,
     Post   => A + T + G + C <= A'Old + T'Old + G'Old + C'Old + 120;

   procedure Handle_Read_Line (Line           : File_IO.Read_Result;
                               Shall_Continue : in out Boolean)
   is
      Initial_Value : constant Long_Integer := A + T + G + C with Ghost;
      --  Ghost variables are only used in proofs, not application code.
   begin
      for I in Line.Text'Range loop
         case Line.Text (I) is
            when 'A'    => A := A + 1;
            when 'C'    => C := C + 1;
            when 'G'    => G := G + 1;
            when 'T'    => T := T + 1;
            when 'N'    => null;  --  Ingore undecisive
            when others =>
               Ada.Text_IO.Put_Line ("Forbidden character detected.");
               Shall_Continue := False;
               return;
         end case;
         pragma Loop_Invariant (A + T + G + C <= Initial_Value + Long_Integer (I));
      end loop;
   end Handle_Read_Line;

   type Counter_Type is range 1 .. Nucleotide_Count'Last / 128;

   Ghost_Sum : Long_Integer := 0 with Ghost;
   --  Ghost variables are only used in proofs, not application code.

   File : File_IO.File_Type;
   Is_Success : Boolean;

   Is_File_Too_Large : Boolean := True;

   Shall_Continue : Boolean := True;

   File_Name : constant String := "chry_multiplied.fa";
begin
   File_IO.Open_Input_File (File_Name, File, Is_Success);

   if Is_Success then
      for Counter in Counter_Type'Range loop
         pragma Loop_Invariant (Ghost_Sum <= 120 * (Long_Integer (Counter) - 1));
         pragma Loop_Invariant (A + T + G + C <= Ghost_Sum);
         case End_Of_File (File) is
            when End_Reached =>
               Is_File_Too_Large := False;
               exit;
            when More_Data_Exists =>
               declare
                  Line : File_IO.Read_Result := Read_Line (File);
               begin
                  if Line.Is_Success then
                     if Line.Text'Length > 0 then
                        if Line.Text (1) = '>' then
                           null;  --  Ignore comments in input file
                        else
                           Handle_Read_Line (Line, Shall_Continue);
                           if not Shall_Continue then
                              return;  --  error was detected
                           end if;
                           Ghost_Sum := Ghost_Sum + 120;
                        end if;
                     else
                        null;  --  Ignore empty lines in input file
                     end if;
                  else
                     Ada.Text_IO.Put_Line ("Error reading file. Hardware issue?");
                     return;
                  end if;
               end;
            when EOF_Error =>
               Ada.Text_IO.Put_Line ("Error checking for end of file. Hardware issue?");
               return;
         end case;
      end loop;

      if Is_File_Too_Large then
         Ada.Text_IO.Put_Line ("Too many rows of data.");
         Ada.Text_IO.Put_Line ("Variables not large enough to store result.");
      else
         declare
            Gc_Count    : constant Long_Float := Long_Float (G + C);
            Total_Count : constant Long_Float := Long_Float (A + T + G + C);
         begin
            if Total_Count > 0.0 then
               Ada.Long_Float_Text_IO.Put (Item => 100.0 * (Gc_Count / Total_Count),
                                           Exp  => 0);
               Ada.Text_IO.New_Line;
            else
               Ada.Text_IO.Put_Line ("No nucleotide A, T, G nor C found in input file.");
            end if;
         end;
      end if;
   else
      Ada.Text_IO.Put_Line ("Can't open file " & File_Name);
   end if;
end Gc;
