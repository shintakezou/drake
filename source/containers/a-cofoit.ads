pragma License (Unrestricted);
--  extended unit
with Ada.IO_Exceptions;
with Ada.Iterator_Interfaces;
private with Ada.Finalization;
private with Ada.Streams;
generic
   type Input_Cursor is private;
   with function Has_Element (Position : Input_Cursor) return Boolean is <>;
   with package Input_Iterator_Interfaces is
      new Iterator_Interfaces (Input_Cursor, Has_Element);
   Input_Iterator : Input_Iterator_Interfaces.Forward_Iterator'Class;
   type Element_Type (<>) is limited private;
   with function Element (Position : Input_Cursor) return Element_Type is <>;
package Ada.Containers.Forward_Iterators is
   --  This package makes a normal forward iterator
   --    from a non-rollbackable forward iterator (input iterator).
   pragma Preelaborate;

   type Cursor is private;
   pragma Preelaborable_Initialization (Cursor);

   function Has_Element (Position : Cursor) return Boolean;

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is null record
      with Implicit_Dereference => Element;

   function Constant_Reference (Position : Cursor)
      return Constant_Reference_Type;

   package Iterator_Interfaces is
      new Ada.Iterator_Interfaces (Cursor, Has_Element);

   function Iterate return Iterator_Interfaces.Forward_Iterator'Class;

   Status_Error : exception
      renames IO_Exceptions.Status_Error;

private

   type Element_Access is access Element_Type;

   type Node;
   type Node_Access is access Node;
   type Node is limited record
      Reference_Count : Integer;
      Next : Node_Access;
      Item : Element_Access;
   end record;

   package Controlled is

      type Cursor is private;

      function Create (Node : Node_Access) return Cursor;

      function Reference (Position : Forward_Iterators.Cursor)
         return Node_Access;
      pragma Inline (Reference);

   private

      type Cursor is new Finalization.Controlled with record
         Node : Node_Access;
      end record;

      overriding procedure Adjust (Object : in out Cursor);
      overriding procedure Finalize (Object : in out Cursor);

      package Streaming is

         procedure Missing_Read (
            Stream : access Streams.Root_Stream_Type'Class;
            Item : out Cursor)
            with Import,
               Convention => Ada, External_Name => "__drake_program_error";
         procedure Missing_Write (
            Stream : access Streams.Root_Stream_Type'Class;
            Item : Cursor)
            with Import,
               Convention => Ada, External_Name => "__drake_program_error";
         function Missing_Input (
            Stream : not null access Streams.Root_Stream_Type'Class)
            return Cursor
            with Import,
               Convention => Ada, External_Name => "__drake_program_error";

         pragma No_Return (Missing_Read);
         pragma No_Return (Missing_Write);
         pragma Machine_Attribute (Missing_Input, "noreturn");

      end Streaming;

      for Cursor'Read use Streaming.Missing_Read;
      for Cursor'Write use Streaming.Missing_Write;
      for Cursor'Input use Streaming.Missing_Input;

   end Controlled;

   type Cursor is new Controlled.Cursor;

   type State_Type is (First, Next, No_Element);
   pragma Discard_Names (State_Type);

   type Iterator is limited new Finalization.Limited_Controlled
      and Iterator_Interfaces.Forward_Iterator with
   record
      Last_Input_Cursor : Input_Cursor;
      Last : Node_Access;
      State : State_Type;
   end record;

   overriding procedure Finalize (Object : in out Iterator);

   overriding function First (Object : Iterator) return Cursor;
   overriding function Next (Object : Iterator; Position : Cursor)
      return Cursor;

end Ada.Containers.Forward_Iterators;
