with Ada.Text_IO.Formatting;
with System.Formatting.Fixed;
with System.Formatting.Float;
with System.Formatting.Literals.Float;
package body Ada.Text_IO.Fixed_IO is

   procedure Put_To_Field (
      To : out String;
      Fore_Last, Last : out Natural;
      Item : Num;
      Aft : Field;
      Exp : Field);
   procedure Put_To_Field (
      To : out String;
      Fore_Last, Last : out Natural;
      Item : Num;
      Aft : Field;
      Exp : Field)
   is
      Triming_Sign_Marks : constant System.Formatting.Sign_Marks :=
         ('-', System.Formatting.No_Sign, System.Formatting.No_Sign);
      Aft_Width : constant Field := Field'Max (1, Aft);
   begin
      if Exp /= 0 then
         System.Formatting.Float.Image (
            Long_Long_Float (Item),
            To,
            Fore_Last,
            Last,
            Signs => Triming_Sign_Marks,
            Aft_Width => Aft_Width,
            Exponent_Digits_Width => Exp - 1); -- excluding '.'
      else
         System.Formatting.Fixed.Image (
            Long_Long_Float (Item),
            To,
            Fore_Last,
            Last,
            Signs => Triming_Sign_Marks,
            Aft_Width => Aft_Width);
      end if;
   end Put_To_Field;

   procedure Get_From_Field (
      From : String;
      Item : out Num;
      Last : out Positive);
   procedure Get_From_Field (
      From : String;
      Item : out Num;
      Last : out Positive)
   is
      Base_Item : Long_Long_Float;
      Error : Boolean;
   begin
      System.Formatting.Literals.Float.Get_Literal (
         From,
         Last,
         Base_Item,
         Error => Error);
      if Error
         or else Base_Item not in
            Long_Long_Float (Num'First) .. Long_Long_Float (Num'Last)
      then
         raise Data_Error;
      end if;
      Item := Num (Base_Item);
   end Get_From_Field;

   --  implementation

   procedure Get (
      File : File_Type;
      Item : out Num;
      Width : Field := 0) is
   begin
      if Width /= 0 then
         declare
            S : String (1 .. Width);
            Last_1 : Natural;
            Last_2 : Natural;
         begin
            Formatting.Get_Field (File, S, Last_1); -- checking the predicate
            Get_From_Field (S (1 .. Last_1), Item, Last_2);
            if Last_2 /= Last_1 then
               raise Data_Error;
            end if;
         end;
      else
         declare
            S : constant String :=
               Formatting.Get_Numeric_Literal (
                  File, -- checking the predicate
                  Real => True);
            Last : Natural;
         begin
            Get_From_Field (S, Item, Last);
            if Last /= S'Last then
               raise Data_Error;
            end if;
         end;
      end if;
   end Get;

   procedure Get (
      Item : out Num;
      Width : Field := 0) is
   begin
      Get (Current_Input.all, Item, Width);
   end Get;

   procedure Get (
      File : not null File_Access;
      Item : out Num;
      Width : Field := 0) is
   begin
      Get (File.all, Item, Width);
   end Get;

   procedure Put (
      File : File_Type;
      Item : Num;
      Fore : Field := Default_Fore;
      Aft : Field := Default_Aft;
      Exp : Field := Default_Exp)
   is
      S : String (
         1 ..
         Integer'Max (Num'Width, Long_Long_Float'Width) + Aft + Exp);
      Fore_Last, Last : Natural;
   begin
      Put_To_Field (S, Fore_Last, Last, Item, Aft, Exp);
      Formatting.Tail (
         File, -- checking the predicate
         S (1 .. Last),
         Last - Fore_Last + Fore);
   end Put;

   procedure Put (
      Item : Num;
      Fore : Field := Default_Fore;
      Aft : Field := Default_Aft;
      Exp : Field := Default_Exp) is
   begin
      Put (Current_Output.all, Item, Fore, Aft, Exp);
   end Put;

   procedure Put (
      File : not null File_Access;
      Item : Num;
      Fore : Field := Default_Fore;
      Aft : Field := Default_Aft;
      Exp : Field := Default_Exp) is
   begin
      Put (File.all, Item, Fore, Aft, Exp);
   end Put;

   procedure Get (
      From : String;
      Item : out Num;
      Last : out Positive) is
   begin
      Formatting.Get_Tail (From, First => Last);
      Get_From_Field (From (Last .. From'Last), Item, Last);
   end Get;

   procedure Put (
      To : out String;
      Item : Num;
      Aft : Field := Default_Aft;
      Exp : Field := Default_Exp)
   is
      S : String (
         1 ..
         Integer'Max (Num'Width, Long_Long_Float'Width) + Aft + Exp);
      Fore_Last, Last : Natural;
   begin
      Put_To_Field (S, Fore_Last, Last, Item, Aft, Exp);
      Formatting.Tail (To, S (1 .. Last));
   end Put;

end Ada.Text_IO.Fixed_IO;
