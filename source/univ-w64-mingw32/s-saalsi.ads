pragma License (Unrestricted);
--  implementation unit specialized for Windows
function System.Standard_Allocators.Allocated_Size (
   Storage_Address : Address)
   return Storage_Elements.Storage_Count;
pragma Preelaborate (System.Standard_Allocators.Allocated_Size);
