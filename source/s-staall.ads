pragma License (Unrestricted);
--  runtime unit
with System.Storage_Elements;
package System.Standard_Allocators is
   pragma Preelaborate;

   --  heap (s-memory.ads)

   function Allocate (
      Size : Storage_Elements.Storage_Count)
      return Address
      with Export, Convention => C, External_Name => "__gnat_malloc";

   procedure Free (Storage_Address : Address)
      with Export, Convention => C, External_Name => "__gnat_free";

   function Reallocate (
      Storage_Address : Address;
      Size : Storage_Elements.Storage_Count)
      return Address
      with Export, Convention => C, External_Name => "__gnat_realloc";

   --  raise Storage_Error with "heap exhausted"

   procedure Raise_Heap_Exhausted;
   pragma No_Return (Raise_Heap_Exhausted);

end System.Standard_Allocators;
