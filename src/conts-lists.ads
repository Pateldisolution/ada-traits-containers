--  Unbounded lists of constrained elements

pragma Ada_2012;
with Conts.Generic_Elements;
with Conts.Lists_Impl;
with Conts.Unbounded_List_Nodes;

generic
   type Element_Type is private;

   Enable_Asserts : Boolean := False;
   --  If True, extra asserts are added to the code. Apart from them, this
   --  code runs with all compiler checks disabled.

package Conts.Lists is

   function Identity (E : Element_Type) return Element_Type is (E);
   pragma Inline (Identity);
   package Elements is new Conts.Generic_Elements
      (Element_Type        => Element_Type,
       Stored_Element_Type => Element_Type,
       Convert_From        => Identity,
       Convert_To          => Identity);

   package Nodes is new Conts.Unbounded_List_Nodes (Elements);

   package Lists is new Conts.Lists_Impl
      (All_Nodes      => Nodes.Nodes,
       Enable_Asserts => Enable_Asserts);
   use Lists;

   subtype List is Lists.List;
   subtype Cursor is Lists.Cursor;

   procedure Append
      (Self : in out List'Class; Element : Element_Type) renames Lists.Append;
   function Length (Self : List'Class) return Count_Type renames Lists.Length;
   function First (Self : List'Class) return Cursor renames Lists.First;
   function Element (Self : List'Class; Position : Cursor) return Element_Type
      renames Lists.Element;
   function Has_Element (Self : List'Class; Position : Cursor) return Boolean
      renames Lists.Has_Element;
   function Next (Self : List'Class; Position : Cursor) return Cursor
      renames Lists.Next;
   function Previous (Self : List'Class; Position : Cursor) return Cursor
      renames Lists.Previous;
   --  Renames for all the subprograms in Lists, for people that do not use
   --  the Ada2012 notation for primitive operations.

   package Bidirectional_Cursors is new Bidirectional_Cursors_Traits
      (Container    => List'Class,
       Cursor       => Cursor,
       Element_Type => Element_Type);
   package Forward_Cursors renames Bidirectional_Cursors.Forward_Cursors;
end Conts.Lists;