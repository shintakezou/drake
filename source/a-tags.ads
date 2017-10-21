pragma License (Unrestricted);
private with System.Storage_Elements;
package Ada.Tags is
   pragma Preelaborate;

   type Tag is private;
   pragma Preelaborable_Initialization (Tag);

   No_Tag : constant Tag;

   function Expanded_Name (T : Tag) return String;
   function Wide_Expanded_Name (T : Tag) return Wide_String;
   function Wide_Wide_Expanded_Name (T : Tag) return Wide_Wide_String;
   function External_Tag (T : Tag) return String;
   function Internal_Tag (External : String) return Tag;

   function Descendant_Tag (External : String; Ancestor : Tag) return Tag;
   function Is_Descendant_At_Same_Level (Descendant, Ancestor : Tag)
      return Boolean;

   function Parent_Tag (T : Tag) return Tag;

   type Tag_Array is array (Positive range <>) of Tag;

   function Interface_Ancestor_Tags (T : Tag) return Tag_Array;

   function Is_Abstract (T : Tag) return Boolean; -- Ada 2012

   Tag_Error : exception;

private

   subtype Fixed_String is String (Positive);

   type Object_Specific_Data_Array is array (Positive range <>) of Positive;
   pragma Suppress_Initialization (Object_Specific_Data_Array);

   --  required types by compiler (a-tags.ads)

   type Prim_Ptr is access procedure;
   for Prim_Ptr'Storage_Size use 0;
   type Address_Array is array (Positive range <>) of Prim_Ptr;
   pragma Suppress_Initialization (Address_Array);
   subtype Dispatch_Table is Address_Array (1 .. 1); -- gdb knows

   --  full declarations

   type Tag is access all Dispatch_Table;
   for Tag'Storage_Size use 0;

   No_Tag : constant Tag := null;

   --  required types by compiler (a-tags.ads)

   type Cstring_Ptr is access all Fixed_String;
   for Cstring_Ptr'Storage_Size use 0;

   type Offset_To_Top_Function_Ptr is access function (
      Object : System.Address)
      return System.Storage_Elements.Storage_Offset;

   type Interface_Data_Element is record
      Iface_Tag : Tag;
      Static_Offset_To_Top : Boolean;
      Offset_To_Top_Value : System.Storage_Elements.Storage_Offset;
      Offset_To_Top_Func : Offset_To_Top_Function_Ptr;
      Secondary_DT : Tag;
   end record;
   pragma Suppress_Initialization (Interface_Data_Element);

   type Interfaces_Array is array (Natural range <>) of Interface_Data_Element;
   pragma Suppress_Initialization (Interfaces_Array);

   type Interface_Data (Nb_Ifaces : Positive) is record
      Ifaces_Table : Interfaces_Array (1 .. Nb_Ifaces);
   end record;
   pragma Suppress_Initialization (Interface_Data);

   type Interface_Data_Ptr is access all Interface_Data; -- not req
   for Interface_Data_Ptr'Storage_Size use 0;

   type Prim_Op_Kind is (
      POK_Function,
      POK_Procedure,
      POK_Protected_Entry,
      POK_Protected_Function,
      POK_Protected_Procedure,
      POK_Task_Entry,
      POK_Task_Function,
      POK_Task_Procedure);
   pragma Discard_Names (Prim_Op_Kind);

   type Select_Specific_Data_Element is record -- not req
      Index : Positive;
      Kind : Prim_Op_Kind;
   end record;
   pragma Suppress_Initialization (Select_Specific_Data_Element);

   type Select_Specific_Data_Array is
      array (Positive range <>) of Select_Specific_Data_Element; -- not req
   pragma Suppress_Initialization (Select_Specific_Data_Array);

   type Select_Specific_Data (Nb_Prim : Positive) is record
      SSD_Table : Select_Specific_Data_Array (1 .. Nb_Prim);
   end record;
   pragma Suppress_Initialization (Select_Specific_Data);

   type Select_Specific_Data_Ptr is access all Select_Specific_Data; -- not req
   for Select_Specific_Data_Ptr'Storage_Size use 0;

   type Interface_Tag is access all Dispatch_Table; -- gdb knows
   for Interface_Tag'Storage_Size use 0;

   type Tag_Ptr is access all Tag;
   for Tag_Ptr'Storage_Size use 0;

   type Offset_To_Top_Ptr is access all System.Storage_Elements.Storage_Offset;
   for Offset_To_Top_Ptr'Storage_Size use 0;

   type Tag_Table is array (Natural range <>) of Tag;
   pragma Suppress_Initialization (Tag_Table);

   type Size_Ptr is access function (A : System.Address)
      return Long_Long_Integer;

   type Type_Specific_Data (Idepth : Natural) is record -- gdb knows
      Access_Level : Natural;
      Alignment : Natural;
      Expanded_Name : Cstring_Ptr;
      External_Tag : Cstring_Ptr;
      HT_Link : Tag_Ptr;
      Transportable : Boolean;
      Type_Is_Abstract : Boolean;
      Needs_Finalization : Boolean;
      Size_Func : Size_Ptr;
      Interfaces_Table : Interface_Data_Ptr;
      SSD : Select_Specific_Data_Ptr;
      Tags_Table : Tag_Table (0 .. Idepth);
   end record;
   pragma Suppress_Initialization (Type_Specific_Data);

   type Type_Specific_Data_Ptr is access all Type_Specific_Data;
   for Type_Specific_Data_Ptr'Storage_Size use 0;

   type Signature_Kind is (
      Unknown,
      Primary_DT,
      Secondary_DT);
   pragma Discard_Names (Signature_Kind);

   type Tagged_Kind is (
      TK_Abstract_Limited_Tagged,
      TK_Abstract_Tagged,
      TK_Limited_Tagged,
      TK_Protected,
      TK_Tagged,
      TK_Task);
   pragma Discard_Names (Tagged_Kind);

   type Dispatch_Table_Wrapper (Num_Prims : Natural) is record
      Signature : Signature_Kind;
      Tag_Kind : Tagged_Kind;
      Predef_Prims : System.Address;
      Offset_To_Top : System.Storage_Elements.Storage_Offset;
      TSD : System.Address; -- or OSD, if Signature = Secondary_DT
      Prims_Ptr : aliased Address_Array (1 .. Num_Prims);
   end record;
   pragma Suppress_Initialization (Dispatch_Table_Wrapper);

   type Dispatch_Table_Ptr is access all Dispatch_Table_Wrapper; -- not req
   for Dispatch_Table_Ptr'Storage_Size use 0;

   type No_Dispatch_Table_Wrapper is record
      NDT_TSD : System.Address;
      NDT_Prims_Ptr : Natural;
   end record;
   pragma Suppress_Initialization (No_Dispatch_Table_Wrapper);

   DT_Predef_Prims_Size : constant :=
      Standard'Address_Size / Standard'Storage_Unit; -- not req

   DT_Offset_To_Top_Size : constant :=
      Standard'Address_Size / Standard'Storage_Unit; -- not req

   DT_Typeinfo_Ptr_Size : constant :=
      Standard'Address_Size / Standard'Storage_Unit;

   DT_Offset_To_Top_Offset : constant :=
      DT_Typeinfo_Ptr_Size + DT_Offset_To_Top_Size;

   DT_Predef_Prims_Offset : constant :=
      DT_Typeinfo_Ptr_Size + DT_Offset_To_Top_Size + DT_Predef_Prims_Size;

   type Object_Specific_Data (OSD_Num_Prims : Positive) is record
      OSD_Table : Object_Specific_Data_Array (1 .. OSD_Num_Prims);
   end record;
   pragma Suppress_Initialization (Object_Specific_Data);

   Max_Predef_Prims : constant := 15;

   type Predef_Prims_Table_Ptr is access Address_Array (1 .. Max_Predef_Prims);
   for Predef_Prims_Table_Ptr'Storage_Size use 0;

   type Addr_Ptr is access System.Address;
   for Addr_Ptr'Storage_Size use 0;

   --  Note: All type tags have TSD but not always have DT.
   --    TAGGED_RECORD'Tag has a primary DT with TSD.
   --    INTERFACE'Tag has a NDT with TSD.
   --  On the other hand, all object tags have DT but not always have TSD.
   --    Base_Address (Object) is TAGGED_RECORD'Tag.
   --    INTERFACE'Class (Object) has a secondary DT with OSD.

   --  required by compiler (a-tags.ads)
   --  for INTERFACE'Class (Object)'Access (exp_attr.adb)
   --  for accessibility checks of new access INTERFACE'Class (exp_ch4.adb)
   --  for accessibility checks of return access INTERFACE'Class (exp_ch6.adb)
   --  for Unchecked_Deallocation of access INTERFACE'Class (exp_intr.adb)
   function Base_Address (Object : System.Address) return System.Address;

   --  optionally required by compiler (a-tags.ads)
   --  for Duplicated_Tag_Check (exp_disp.adb)
--  procedure Check_TSD (TSD : Type_Specific_Data_Ptr);

   --  required by compiler (a-tags.ads)
   --  for downcast to INTERFACE'Class (exp_ch3.adb)
   --  for new INTERFACE'Class'(...) (exp_ch4.adb)
   --  for non-statically upcast to INTERFACE'Class (exp_disp.adb)
   --  for assignment to INTERFACE'Class (exp_util.adb)
   function Displace (Object : System.Address; T : Tag)
      return System.Address;

   --  required by compiler (a-tags.ads)
   --  for elaborating dispatch tables of derived types (exp_atag.adb)
   function DT (T : Tag) return Dispatch_Table_Ptr;

   --  required by compiler (a-tags.ads)
   --  for requeue statements using synchronized interface (exp_ch9.adb)
   --  for implicit primitives of synchronized interface (exp_disp.adb)
   function Get_Entry_Index (T : Tag; Position : Positive) return Positive;

   --  required by compiler (a-tags.ads)
   --  for select statements using synchronized interface (exp_sel.adb)
   function Get_Offset_Index (Object_T : Tag; Position : Positive)
      return Positive;

   --  required by compiler (a-tags.ads)
   --  for select statements using synchronized interface (exp_atag.adb)
   --  for implicit primitives of synchronized interface (exp_disp.adb)
   function Get_Prim_Op_Kind (T : Tag; Position : Positive)
      return Prim_Op_Kind;

   --  required by compiler (a-tags.ads)
   --  for select statements using synchronized interface (exp_sel.adb)
   function Get_Tagged_Kind (Object_T : Tag) return Tagged_Kind;

   --  required by compiler (a-tags.ads)
   --  for Object in INTERFACE'Class (exp_ch4.adb)
   --  for Generic_Dispatching_Constructor (exp_intr.adb)
   function IW_Membership (Object : System.Address; T : Tag) return Boolean;

   --  required by compiler (a-tags.ads)
   --  for deferencing access values associated to Checked_Pool (exp_ch4.adb)
   --  for Unchecked_Deallocation of access TAGGED'Class (exp_util.adb)
   function Needs_Finalization (Object_T : Tag) return Boolean;

   --  optionally required by compiler (a-tags.ads)
   --  for implicit primitives derived from plural parent types (exp_disp.adb)
--  function Offset_To_Top (Object : System.Address)
--    return System.Storage_Elements.Storage_Offset;

   --  required by compiler (a-tags.ads)
   --  for types implementing interfaces (exp_ch3.adb)
   procedure Register_Interface_Offset (
      Object : System.Address;
      Interface_T : Tag;
      Is_Static : Boolean;
      Offset_Value : System.Storage_Elements.Storage_Offset;
      Offset_Func : Offset_To_Top_Function_Ptr);

   --  optionally required by compiler (a-tags.ads)
   --  for finalizers (exp_ch7.adb)
   --  for elaborating dispatch tables (exp_disp.adb)
   --  [gcc-5] generates _finalize_spec/body without _elabs/_elabb
   --    and gnatbind generates wrong code, if Register_Tag is null.
--  procedure Register_Tag (T : Tag) is null; -- unimplemented

   --  required by compiler (a-tags.ads)
   --  for Generic_Dispatching_Constructor (exp_intr.adb)
   function Secondary_Tag (T, Iface : Tag) return Tag;

   --  required by compiler (a-tags.ads)
   --  for variable-sized types implementing interfaces (exp_ch3.adb)
--  procedure Set_Dynamic_Offset_To_Top (
--    Object : System.Address;
--    Interface_T : Tag;
--    Offset_Value : System.Storage_Elements.Storage_Offset;
--    Offset_Func : Offset_To_Top_Function_Ptr);

   --  required by compiler (a-tags.ads)
   --  for elaborating dispatch tables of synchronized interface (exp_disp.adb)
   procedure Set_Entry_Index (
      T : Tag;
      Position : Positive;
      Value : Positive);
   procedure Set_Prim_Op_Kind (
      T : Tag;
      Position : Positive;
      Value : Prim_Op_Kind);

   --  required by compiler (a-tags.ads)
   --  for Generic_Dispatching_Constructor (exp_intr.adb)
   function Type_Is_Abstract (T : Tag) return Boolean
      renames Is_Abstract;

   --  optionally required by compiler (a-tags.ads)
   --  for finalizers (exp_ch7.adb, exp_util.adb)
--  procedure Unregister_Tag (T : Tag) is null; -- unimplemented

   --  interface delegation

   type Get_Delegation_Handler is access function (
      Object : System.Address;
      Interface_Tag : Tag)
      return System.Address;
   pragma Favor_Top_Level (Get_Delegation_Handler);

   Get_Delegation : Get_Delegation_Handler := null;
   pragma Atomic (Get_Delegation);

end Ada.Tags;
