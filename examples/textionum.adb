with Ada.Text_IO;
with Ada.Float_Text_IO;
procedure textionum is
	type M is mod 100;
	type D1 is delta 0.1 digits 3;
	package D1IO is new Ada.Text_IO.Decimal_IO (D1);
	type D2 is delta 10.0 digits 3;
	package D2IO is new Ada.Text_IO.Decimal_IO (D2);
	S7 : String (1 .. 7);
	S : String (1 .. 12);
begin
	D1IO.Put (S7, 10.0);
	pragma Assert (S7 = "   10.0");
	D1IO.Put (S7, -12.3, Aft => 3);
	pragma Assert (S7 = "-12.300");
	D2IO.Put (S7, 10.0);
	pragma Assert (S7 = "   10.0");
	D2IO.Put (S7, -1230.0);
	pragma Assert (S7 = "-1230.0");
	D2IO.Put (S7, 0.0);
	pragma Assert (S7 = "    0.0");
	pragma Assert (Integer (Float'(5490.0)) = 5490);
	Ada.Float_Text_IO.Put (S, 5490.0);
	pragma Assert (S = " 5.49000E+03");
	Test_Enumeration_IO : declare
		package Boolean_IO is new Ada.Text_IO.Enumeration_IO (Boolean);
		Boolean_Item : Boolean;
		package Character_IO is new Ada.Text_IO.Enumeration_IO (Character);
		Character_Item : Character;
		package Wide_Character_IO is new Ada.Text_IO.Enumeration_IO (Wide_Character);
		Wide_Character_Item : Wide_Character;
		package Wide_Wide_Character_IO is new Ada.Text_IO.Enumeration_IO (Wide_Wide_Character);
		Wide_Wide_Character_Item : Wide_Wide_Character;
		type E is (A, B, C);
		package E_IO is new Ada.Text_IO.Enumeration_IO (E);
		E_Item : E;
		package Integer_IO is new Ada.Text_IO.Enumeration_IO (Integer);
		Integer_Item : Integer;
		package M_IO is new Ada.Text_IO.Enumeration_IO (M);
		M_Item : M;
		Last : Natural;
	begin
		Boolean_IO.Get ("True", Boolean_Item, Last);
		pragma Assert (Boolean_Item and then Last = 4);
		begin
			Boolean_IO.Get ("null", Boolean_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		Character_IO.Get ("Hex_FF", Character_Item, Last);
		pragma Assert (Character_Item = Character'Val (16#FF#) and then Last = 6);
		begin
			Character_IO.Get ("Hex_100", Character_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		Wide_Character_IO.Get ("Hex_FFFF", Wide_Character_Item, Last);
		pragma Assert (Wide_Character_Item = Wide_Character'Val (16#FFFF#) and then Last = 8);
		begin
			Wide_Character_IO.Get ("Hex_10000", Wide_Character_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		Wide_Wide_Character_IO.Get ("Hex_7FFFFFFF", Wide_Wide_Character_Item, Last);
		pragma Assert (Wide_Wide_Character_Item = Wide_Wide_Character'Val (16#7FFFFFFF#) and then Last = 12);
		begin
			Wide_Wide_Character_IO.Get ("Hex_80000000", Wide_Wide_Character_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		E_IO.Get ("A", E_Item, Last);
		pragma Assert (E_Item = A and then Last = 1);
		begin
			E_IO.Get ("D", E_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		Integer_IO.Get ("10", Integer_Item, Last);
		pragma Assert (Integer_Item = 10 and then Last = 2);
		begin
			Integer_IO.Get ("1A", Integer_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
		M_IO.Get ("10", M_Item, Last);
		pragma Assert (M_Item = 10 and then Last = 2);
		begin
			M_IO.Get ("1A", M_Item, Last);
			raise Program_Error;
		exception
			when Ada.Text_IO.Data_Error => null;
		end;
	end Test_Enumeration_IO;
	pragma Debug (Ada.Debug.Put ("OK"));
end textionum;
