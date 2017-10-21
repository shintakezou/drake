with System.Debug;
with C.basetsd;
with C.winbase;
with C.windef;
package body System.Storage_Pools.Unbounded is
   use type Storage_Elements.Storage_Offset;
   use type C.windef.WINBOOL;
   use type C.winnt.HANDLE; -- C.void_ptr

   --  implementation

   overriding procedure Initialize (Object : in out Unbounded_Pool) is
   begin
      Object.Heap := C.winbase.HeapCreate (0, 0, 0);
   end Initialize;

   overriding procedure Finalize (Object : in out Unbounded_Pool) is
      Success : C.windef.WINBOOL;
   begin
      Success := C.winbase.HeapDestroy (Object.Heap);
      pragma Check (Debug,
         Check =>
            Success /= C.windef.FALSE
            or else Debug.Runtime_Error ("HeapDestroy failed"));
   end Finalize;

   overriding procedure Allocate (
      Pool : in out Unbounded_Pool;
      Storage_Address : out Address;
      Size_In_Storage_Elements : Storage_Elements.Storage_Count;
      Alignment : Storage_Elements.Storage_Count) is
   begin
      Storage_Address := Address (
         C.winbase.HeapAlloc (
            Pool.Heap,
            0,
            C.basetsd.SIZE_T (Size_In_Storage_Elements)));
      if Storage_Address = Null_Address then
         raise Storage_Error;
      elsif Storage_Address mod Alignment /= 0 then
         Deallocate (
            Pool,
            Storage_Address,
            Size_In_Storage_Elements,
            Alignment);
         raise Storage_Error;
      end if;
   end Allocate;

   overriding procedure Deallocate (
      Pool : in out Unbounded_Pool;
      Storage_Address : Address;
      Size_In_Storage_Elements : Storage_Elements.Storage_Count;
      Alignment : Storage_Elements.Storage_Count)
   is
      pragma Unreferenced (Size_In_Storage_Elements);
      pragma Unreferenced (Alignment);
      Success : C.windef.WINBOOL;
   begin
      Success := C.winbase.HeapFree (
         Pool.Heap,
         0,
         C.windef.LPVOID (Storage_Address));
      pragma Check (Debug,
         Check =>
            Success /= C.windef.FALSE
            or else Debug.Runtime_Error ("HeapFree failed"));
   end Deallocate;

end System.Storage_Pools.Unbounded;
