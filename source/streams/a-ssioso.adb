with Ada.Exception_Identification.From_Here;
with Ada.Exceptions.Finally;
with Ada.Streams.Stream_IO.Naked;
with System.Native_IO;
package body Ada.Streams.Stream_IO.Sockets is
   use Exception_Identification.From_Here;
   use type System.Native_IO.Sockets.End_Point;
--  use type System.Native_IO.Handle_Type;
--  use type System.Native_IO.Sockets.Listener;

   --  client

   function Get (
      Data : System.Native_IO.Sockets.End_Point)
      return End_Point;
   function Get (
      Data : System.Native_IO.Sockets.End_Point)
      return End_Point is
   begin
      if Data = null then
         Raise_Exception (Use_Error'Identity);
      else
         return Result : End_Point do
            Reference (Result).all := Data;
         end return;
      end if;
   end Get;

   --  implementation of client

   function Is_Assigned (Peer : End_Point) return Boolean is
   begin
      return Reference (Peer).all /= null;
   end Is_Assigned;

   function Resolve (Host_Name : String; Service : String)
      return End_Point
   is
      Peer : constant System.Native_IO.Sockets.End_Point :=
         System.Native_IO.Sockets.Resolve (Host_Name, Service);
   begin
      return Get (Peer);
   end Resolve;

   function Resolve (Host_Name : String; Port : Port_Number)
      return End_Point
   is
      Peer : constant System.Native_IO.Sockets.End_Point :=
         System.Native_IO.Sockets.Resolve (
            Host_Name,
            System.Native_IO.Sockets.Port_Number (Port));
   begin
      return Get (Peer);
   end Resolve;

   procedure Connect (
      File : in out File_Type;
      Peer : End_Point)
   is
      pragma Check (Dynamic_Predicate,
         Check => Is_Assigned (Peer) or else raise Status_Error);
      use type System.Native_IO.Handle_Type;
      procedure Finally (X : not null access System.Native_IO.Handle_Type);
      procedure Finally (X : not null access System.Native_IO.Handle_Type) is
         Empty_Name : aliased System.Native_IO.Name_String :=
            (0 => System.Native_IO.Name_Character'Val (0));
      begin
         if X.all /= System.Native_IO.Invalid_Handle then
            System.Native_IO.Close_Ordinary (
               X.all,
               Empty_Name (0)'Unchecked_Access,
               Raise_On_Error => False);
         end if;
      end Finally;
      package Holder is
         new Exceptions.Finally.Scoped_Holder (
            System.Native_IO.Handle_Type,
            Finally);
      Handle : aliased System.Native_IO.Handle_Type :=
         System.Native_IO.Invalid_Handle;
   begin
      Holder.Assign (Handle'Access);
      System.Native_IO.Sockets.Connect (
         Handle,
         Reference (Peer).all);
      if Handle = System.Native_IO.Invalid_Handle then
         Raise_Exception (Use_Error'Identity);
      else
         Naked.Open (
            File,
            Append_File, -- Inout
            Handle,
            To_Close => True);
         --  complete
         Holder.Clear;
      end if;
   end Connect;

   function Connect (
      Peer : End_Point)
      return File_Type is
   begin
      return Result : File_Type do
         Connect (
            Result,
            Peer); -- checking the predicate
      end return;
   end Connect;

   package body End_Points is

      function Reference (
         Object : End_Point)
         return not null access System.Native_IO.Sockets.End_Point is
      begin
         return Object.Data'Unrestricted_Access;
      end Reference;

      overriding procedure Finalize (Object : in out End_Point) is
      begin
         System.Native_IO.Sockets.Finalize (Object.Data);
      end Finalize;

   end End_Points;

   --  implementation of server

   function Is_Open (Server : Listener) return Boolean is
      use type System.Native_IO.Sockets.Listener;
   begin
      return Reference (Server).all /=
         System.Native_IO.Sockets.Invalid_Listener;
   end Is_Open;

   function Listen (Port : Port_Number) return Listener is
      use type System.Native_IO.Sockets.Listener;
   begin
      return Result : Listener do
         declare
            Server_Handle : System.Native_IO.Sockets.Listener
               renames Reference (Result).all;
         begin
            System.Native_IO.Sockets.Listen (
               Server_Handle,
               System.Native_IO.Sockets.Port_Number (Port));
            if Server_Handle = System.Native_IO.Sockets.Invalid_Listener then
               Raise_Exception (Use_Error'Identity);
            end if;
         end;
      end return;
   end Listen;

   procedure Close (Server : in out Listener) is
      pragma Check (Pre,
         Check => Is_Open (Server) or else raise Status_Error);
      Server_Handle : System.Native_IO.Sockets.Listener
         renames Reference (Server).all;
   begin
      System.Native_IO.Sockets.Close_Listener (
         Server_Handle,
         Raise_On_Error => True);
      Server_Handle := System.Native_IO.Sockets.Invalid_Listener;
   end Close;

   procedure Accept_Socket (
      Server : Listener;
      File : in out File_Type)
   is
      Dummy : Socket_Address;
   begin
      Accept_Socket (
         Server, -- checking the predicate
         File,
         Dummy);
   end Accept_Socket;

   procedure Accept_Socket (
      Server : Listener;
      File : in out File_Type;
      Remote_Address : out Socket_Address)
   is
      pragma Check (Dynamic_Predicate,
         Check => Is_Open (Server) or else raise Status_Error);
      use type System.Native_IO.Handle_Type;
      procedure Finally (X : not null access System.Native_IO.Handle_Type);
      procedure Finally (X : not null access System.Native_IO.Handle_Type) is
         Empty_Name : aliased System.Native_IO.Name_String :=
            (0 => System.Native_IO.Name_Character'Val (0));
      begin
         if X.all /= System.Native_IO.Invalid_Handle then
            System.Native_IO.Close_Ordinary (
               X.all,
               Empty_Name (0)'Unchecked_Access,
               Raise_On_Error => False);
         end if;
      end Finally;
      package Holder is
         new Exceptions.Finally.Scoped_Holder (
            System.Native_IO.Handle_Type,
            Finally);
      Handle : aliased System.Native_IO.Handle_Type :=
         System.Native_IO.Invalid_Handle;
   begin
      Holder.Assign (Handle'Access);
      System.Native_IO.Sockets.Accept_Socket (
         Reference (Server).all,
         Handle,
         System.Native_IO.Sockets.Socket_Address (Remote_Address));
      if Handle = System.Native_IO.Invalid_Handle then
         Raise_Exception (Use_Error'Identity);
      else
         Naked.Open (
            File,
            Append_File, -- Inout
            Handle,
            To_Close => True);
         --  complete
         Holder.Clear;
      end if;
   end Accept_Socket;

   package body Listeners is

      function Reference (Object : Listener)
         return not null access System.Native_IO.Sockets.Listener is
      begin
         return Object.Data'Unrestricted_Access;
      end Reference;

      overriding procedure Finalize (Object : in out Listener) is
         use type System.Native_IO.Sockets.Listener;
      begin
         if Object.Data /= System.Native_IO.Sockets.Invalid_Listener then
            System.Native_IO.Sockets.Close_Listener (
               Object.Data,
               Raise_On_Error => False);
         end if;
      end Finalize;

   end Listeners;

end Ada.Streams.Stream_IO.Sockets;
