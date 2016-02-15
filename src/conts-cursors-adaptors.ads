------------------------------------------------------------------------------
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

--  This file provides adaptors for the standard Ada2012 containers, so that
--  they can be used with the algorithms declared in our containers hierarchy

pragma Ada_2012;
with Ada.Containers.Bounded_Doubly_Linked_Lists;
with Ada.Containers.Bounded_Hashed_Maps;
with Ada.Containers.Bounded_Vectors;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Conts.Properties;

package Conts.Cursors.Adaptors is

   ---------------------------------------------
   -- Adaptor for bounded doubly linked lists --
   ---------------------------------------------

   generic
      with package Lists is
        new Ada.Containers.Bounded_Doubly_Linked_Lists (<>);
   package Bounded_List_Adaptors is
      subtype Element_Type is Lists.Element_Type;
      subtype List is Lists.List;
      subtype Cursor is Lists.Cursor;

      function Element (Self : List; Position : Cursor) return Element_Type
         is (Lists.Element (Position)) with Inline;
      function Has_Element (Self : List; Position : Cursor) return Boolean
         is (Lists.Has_Element (Position)) with Inline;
      function Next (Self : List; Position : Cursor) return Cursor
         is (Lists.Next (Position)) with Inline;
      function Previous (Self : List; Position : Cursor) return Cursor
         is (Lists.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => List'Class,
             Cursor_Type    => Cursor,
             First          => Lists.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Element is new Conts.Properties.Read_Only_Maps
           (List'Class, Cursor, Element_Type, Element);
         package Returned renames Element;
      end Maps;
   end Bounded_List_Adaptors;

   -------------------------------------
   -- Adaptor for doubly linked lists --
   -------------------------------------

   generic
      with package Lists is new Ada.Containers.Doubly_Linked_Lists (<>);
   package List_Adaptors is
      subtype Element_Type is Lists.Element_Type;
      subtype List is Lists.List;
      subtype Cursor is Lists.Cursor;

      function Element (Self : List; Position : Cursor) return Element_Type
         is (Lists.Element (Position)) with Inline;
      function Has_Element (Self : List; Position : Cursor) return Boolean
         is (Lists.Has_Element (Position)) with Inline;
      function Next (Self : List; Position : Cursor) return Cursor
         is (Lists.Next (Position)) with Inline;
      function Previous (Self : List; Position : Cursor) return Cursor
         is (Lists.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => List'Class,
             Cursor_Type    => Cursor,
             First          => Lists.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Element is new Conts.Properties.Read_Only_Maps
           (List'Class, Cursor, Element_Type, Element);
         package Returned renames Element;
      end Maps;
   end List_Adaptors;

   ------------------------------------------------
   -- Adaptor for indefinite doubly linked lists --
   ------------------------------------------------

   generic
      with package Lists is
         new Ada.Containers.Indefinite_Doubly_Linked_Lists (<>);
   package Indefinite_List_Adaptors is
      subtype Element_Type is Lists.Element_Type;
      subtype Returned is Lists.Constant_Reference_Type;
      subtype List is Lists.List;
      subtype Cursor is Lists.Cursor;

      function Element (Self : List; Position : Cursor) return Returned
         is (Lists.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : List; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : List; Position : Cursor) return Boolean
         is (Lists.Has_Element (Position)) with Inline;
      function Next (Self : List; Position : Cursor) return Cursor
         is (Lists.Next (Position)) with Inline;
      function Previous (Self : List; Position : Cursor) return Cursor
         is (Lists.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => List'Class,
             Cursor_Type    => Cursor,
             First          => Lists.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (List'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (List'Class, Cursor, Element_Type, Element);
      end Maps;
   end Indefinite_List_Adaptors;

   ---------------------------------
   -- Adaptor for bounded vectors --
   ---------------------------------

   generic
      with package Vectors is new Ada.Containers.Bounded_Vectors (<>);
   package Bounded_Vector_Adaptors is
      subtype Element_Type is Vectors.Element_Type;
      subtype Vector is Vectors.Vector;
      subtype Cursor is Vectors.Cursor;

      function Element (Self : Vector; Position : Cursor) return Element_Type
         is (Vectors.Element (Position)) with Inline;
      function Has_Element (Self : Vector; Position : Cursor) return Boolean
         is (Vectors.Has_Element (Position)) with Inline;
      function Next (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Next (Position)) with Inline;
      function Previous (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Previous (Position)) with Inline;

      package Cursors is
         --  ??? Should provide random access cursors
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => Vector'Class,
             Cursor_Type    => Cursor,
             First          => Vectors.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Element is new Conts.Properties.Read_Only_Maps
           (Vector'Class, Cursor, Element_Type, Element);
         package Returned renames Element;
      end Maps;
   end Bounded_Vector_Adaptors;

   -------------------------
   -- Adaptor for Vectors --
   -------------------------

   generic
      with package Vectors is new Ada.Containers.Vectors (<>);
   package Vector_Adaptors is
      subtype Element_Type is Vectors.Element_Type;
      subtype Vector is Vectors.Vector;
      subtype Cursor is Vectors.Cursor;

      function Element (Self : Vector; Position : Cursor) return Element_Type
         is (Vectors.Element (Position)) with Inline;
      function Has_Element (Self : Vector; Position : Cursor) return Boolean
         is (Vectors.Has_Element (Position)) with Inline;
      function Next (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Next (Position)) with Inline;
      function Previous (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => Vector'Class,
             Cursor_Type    => Cursor,
             First          => Vectors.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Element is new Conts.Properties.Read_Only_Maps
           (Vector'Class, Cursor, Element_Type, Element);
         package Returned renames Element;
      end Maps;
   end Vector_Adaptors;

   ------------------------------------
   -- Adaptor for indefinite Vectors --
   ------------------------------------

   generic
      with package Vectors is new Ada.Containers.Indefinite_Vectors (<>);
   package Indefinite_Vector_Adaptors is
      subtype Element_Type is Vectors.Element_Type;
      subtype Returned     is Vectors.Constant_Reference_Type;
      subtype Vector       is Vectors.Vector;
      subtype Cursor       is Vectors.Cursor;

      function Element (Self : Vector; Position : Cursor) return Returned
         is (Vectors.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Vector; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Vector; Position : Cursor) return Boolean
         is (Vectors.Has_Element (Position)) with Inline;
      function Next (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Next (Position)) with Inline;
      function Previous (Self : Vector; Position : Cursor) return Cursor
         is (Vectors.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => Vector'Class,
             Cursor_Type    => Cursor,
             First          => Vectors.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Vector'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Vector'Class, Cursor, Element_Type, Element);
      end Maps;
   end Indefinite_Vector_Adaptors;

   -----------------------------
   -- Adaptor for hashed maps --
   -----------------------------

   generic
      with package Hashed_Maps is new Ada.Containers.Hashed_Maps (<>);
   package Hashed_Maps_Adaptors is
      subtype Element_Type is Hashed_Maps.Element_Type;
      subtype Returned     is Hashed_Maps.Constant_Reference_Type;
      subtype Map          is Hashed_Maps.Map;
      subtype Cursor       is Hashed_Maps.Cursor;

      function Element (Self : Map; Position : Cursor) return Returned
         is (Hashed_Maps.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Map; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Map; Position : Cursor) return Boolean
         is (Hashed_Maps.Has_Element (Position)) with Inline;
      function Next (Self : Map; Position : Cursor) return Cursor
         is (Hashed_Maps.Next (Position)) with Inline;

      package Cursors is
         package Forward is new Forward_Cursors
            (Container_Type => Map'Class,
             Cursor_Type    => Cursor,
             First          => Hashed_Maps.First);
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Element_Type, Element);
      end Maps;
   end Hashed_Maps_Adaptors;

   -------------------------------------
   -- Adaptor for bounded hashed maps --
   -------------------------------------

   generic
      with package Hashed_Maps is new Ada.Containers.Bounded_Hashed_Maps (<>);
   package Bounded_Hashed_Maps_Adaptors is
      subtype Element_Type is Hashed_Maps.Element_Type;
      subtype Returned     is Hashed_Maps.Constant_Reference_Type;
      subtype Map          is Hashed_Maps.Map;
      subtype Cursor       is Hashed_Maps.Cursor;

      function Element (Self : Map; Position : Cursor) return Returned
         is (Hashed_Maps.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Map; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Map; Position : Cursor) return Boolean
         is (Hashed_Maps.Has_Element (Position)) with Inline;
      function Next (Self : Map; Position : Cursor) return Cursor
         is (Hashed_Maps.Next (Position)) with Inline;

      package Cursors is
         package Forward is new Forward_Cursors
            (Container_Type => Map'Class,
             Cursor_Type    => Cursor,
             First          => Hashed_Maps.First);
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Element_Type, Element);
      end Maps;
   end Bounded_Hashed_Maps_Adaptors;

   ------------------------------
   -- Adaptor for ordered maps --
   ------------------------------

   generic
      with package Ordered_Maps is new Ada.Containers.Ordered_Maps (<>);
   package Ordered_Maps_Adaptors is
      subtype Element_Type is Ordered_Maps.Element_Type;
      subtype Returned     is Ordered_Maps.Constant_Reference_Type;
      subtype Map          is Ordered_Maps.Map;
      subtype Cursor       is Ordered_Maps.Cursor;

      function Element (Self : Map; Position : Cursor) return Returned
         is (Ordered_Maps.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Map; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Map; Position : Cursor) return Boolean
         is (Ordered_Maps.Has_Element (Position)) with Inline;
      function Next (Self : Map; Position : Cursor) return Cursor
         is (Ordered_Maps.Next (Position)) with Inline;
      function Previous (Self : Map; Position : Cursor) return Cursor
         is (Ordered_Maps.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => Map'Class,
             Cursor_Type    => Cursor,
             First          => Ordered_Maps.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Element_Type, Element);
      end Maps;
   end Ordered_Maps_Adaptors;

   ----------------------------------------
   -- Adaptor for indefinite hashed maps --
   ----------------------------------------

   generic
      with package Hashed_Maps is
         new Ada.Containers.Indefinite_Hashed_Maps (<>);
   package Indefinite_Hashed_Maps_Adaptors is
      subtype Element_Type is Hashed_Maps.Element_Type;
      subtype Returned     is Hashed_Maps.Constant_Reference_Type;
      subtype Map          is Hashed_Maps.Map;
      subtype Cursor       is Hashed_Maps.Cursor;

      function Element (Self : Map; Position : Cursor) return Returned
         is (Hashed_Maps.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Map; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Map; Position : Cursor) return Boolean
         is (Hashed_Maps.Has_Element (Position)) with Inline;
      function Next (Self : Map; Position : Cursor) return Cursor
         is (Hashed_Maps.Next (Position)) with Inline;

      package Cursors is
         package Forward is new Forward_Cursors
            (Container_Type => Map'Class,
             Cursor_Type    => Cursor,
             First          => Hashed_Maps.First);
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Element_Type, Element);
      end Maps;
   end Indefinite_Hashed_Maps_Adaptors;

   -----------------------------------------
   -- Adaptor for indefinite ordered maps --
   -----------------------------------------

   generic
      with package Ordered_Maps is
         new Ada.Containers.Indefinite_Ordered_Maps (<>);
   package Indefinite_Ordered_Maps_Adaptors is
      subtype Element_Type is Ordered_Maps.Element_Type;
      subtype Returned     is Ordered_Maps.Constant_Reference_Type;
      subtype Map          is Ordered_Maps.Map;
      subtype Cursor       is Ordered_Maps.Cursor;

      function Element (Self : Map; Position : Cursor) return Returned
         is (Ordered_Maps.Constant_Reference (Self, Position)) with Inline;
      function Element (Self : Map; Position : Cursor) return Element_Type
         is (Element (Self, Position).Element.all) with Inline;
      function Has_Element (Self : Map; Position : Cursor) return Boolean
         is (Ordered_Maps.Has_Element (Position)) with Inline;
      function Next (Self : Map; Position : Cursor) return Cursor
         is (Ordered_Maps.Next (Position)) with Inline;
      function Previous (Self : Map; Position : Cursor) return Cursor
         is (Ordered_Maps.Previous (Position)) with Inline;

      package Cursors is
         package Bidirectional is new Bidirectional_Cursors
            (Container_Type => Map'Class,
             Cursor_Type    => Cursor,
             First          => Ordered_Maps.First);
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Returned is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Returned, Element);
         package Element is new Conts.Properties.Read_Only_Maps
           (Map'Class, Cursor, Element_Type, Element);
      end Maps;
   end Indefinite_Ordered_Maps_Adaptors;

   ------------------------
   -- Adaptor for arrays --
   ------------------------

   generic
      type Index_Type is (<>);
      type Element_Type is private;
      type Array_Type is array (Index_Type range <>) of Element_Type;
   package Array_Adaptors is
      function First (Self : Array_Type) return Index_Type
         is (Self'First) with Inline;
      function Last (Self : Array_Type) return Index_Type
         is (Self'Last) with Inline;
      function Element
         (Self : Array_Type; Position : Index_Type) return Element_Type
         is (Self (Position)) with Inline;
      function "-" (Left, Right : Index_Type) return Integer
         is (Index_Type'Pos (Left) - Index_Type'Pos (Right)) with Inline;
      function "+"
        (Left : Index_Type; N : Integer) return Index_Type
         is (Index_Type'Val (Index_Type'Pos (Left) + N)) with Inline;

      package Cursors is
         package Random_Access is new Random_Access_Cursors
           (Container_Type => Array_Type,
            Index_Type     => Index_Type,
            First          => First,
            Last           => Last,
            "-"            => "-",
            "+"            => "+");
         package Bidirectional renames Random_Access.Bidirectional;
         package Forward renames Bidirectional.Forward;
      end Cursors;

      package Maps is
         package Element is new Conts.Properties.Read_Only_Maps
           (Array_Type, Index_Type, Element_Type, Element);
         package Returned renames Element;
      end Maps;
   end Array_Adaptors;

end Conts.Cursors.Adaptors;
