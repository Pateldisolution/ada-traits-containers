pragma Ada_2012;
with Formal_Hashed_Sets;
pragma Elaborate_All (Formal_Hashed_Sets);

package Use_Sets with SPARK_Mode is
   package My_Sets is new Formal_Hashed_Sets
     (Element_Type => Integer);
   use My_Sets;
   use type My_Sets.Cursor;
   use My_Sets.P;
   use My_Sets.E;
   use My_Sets.M;

   function My_Contains (S : My_Sets.Set; E : Integer) return Boolean is
     (Find (S, E) /= No_Element) with
   Post => My_Contains'Result = Contains (S, E);

   function My_Find (S : My_Sets.Set; E : Integer) return Cursor with
     Post => My_Find'Result = Find (S, E);
   --  Iterate through the set to find E.

   function F (E : Integer) return Integer is
      (if E in -100 .. 100 then E * 2 else E);

   procedure Apply_F (S : My_Sets.Set; R : in out My_Sets.Set) with
     Pre  => Capacity (R) >= Length (S),
     Post => (for all E of S => Contains (R, F (E)))
     and (for all G of R => (for some E of S => G = F (E)));
   --  Store in R the image of every element of S through F. Note that F is not
   --  injective.

   function Are_Disjoint (S1, S2 : My_Sets.Set) return Boolean with
     Post => Are_Disjoint'Result =
       Is_Empty (Intersection (Model (S1), Model (S2)));
   --  Check wether two sets are disjoint.

   function Are_Disjoint_2 (S1, S2 : My_Sets.Set) return Boolean with
     Post => Are_Disjoint_2'Result =
       (for all E of Model (S2) => not Mem (Model (S1), E));
   --  Same as before except that it is specified it using a quantified
   --  expression instead of set intersection.

   function P (E : Integer) return Boolean is
     (E >= 0);

   procedure Union_P (S1 : in out My_Sets.Set; S2 : My_Sets.Set) with
     Pre  => (for all E of S1 => P (E))
     and (for all E of S2 => P (E))
     and Capacity (S1) - Length (S1) > Length (S2),
     Post => (for all E of S1 => P (E));
   --  Compute the union of two sets for which P is true.

   procedure Move (S1, S2 : in out My_Sets.Set) with
     Pre  => Capacity (S2) >= Length (S1),
     Post => Model (S1)'Old = Model (S2) and Length (S1) = 0;
   --  Move the content of a set into another set. Already included element are
   --  excluded from the first set during iteration.

   procedure Move_2 (S1, S2 : in out My_Sets.Set) with
     Pre  => Capacity (S2) >= Length (S1),
     Post => Model (S1)'Old = Model (S2) and Length (S1) = 0;
   --  Same as before except that S1 is cleared at the end.

   Count : constant := 6;

   procedure Insert_Count (S : in out My_Sets.Set)
   --  Include elements 1 .. Count in S.

   with
     Pre  => Capacity (S) - Count > Length (S),
     Post => Length (S) <= Length (S)'Old + Count
     and Inc (Model (S)'Old, Model (S))
     and (for all E in 1 .. Count => Contains (S, E))
     and (for all E of S => Mem (Model (S)'Old, E) or E in 1 .. Count);

   --  Test links between high-level model, lower-level position based model
   --  and lowest-level, cursor based model of a set.

   function Q (E : Integer) return Boolean;
   --  Any property Q on an Integer E.

   procedure From_Elements_To_Model (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all I in 1 .. Length (S) =>
                    Q (Get (Elements (S), I))),
     Post   => (for all E of S => Q (E));
   --  Test that the link can be done from a property on the elements of a
   --  low level, position based view of a container and its high level view.

   procedure From_Model_To_Elements (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all E of S => Q (E)),
     Post   => (for all I in 1 .. Length (S) =>
                    Q (Get (Elements (S), I)));
   --  Test that the link can be done from a property on the elements of a
   --  high level view of a container and its lower level, position based view.

   procedure From_Elements_To_Cursors (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all I in 1 .. Length (S) =>
                    Q (Get (Elements (S), I))),
     Post   => (for all Cu in S => Q (Element (S, Cu)));
   --  Test that the link can be done from a property on the elements of a
   --  position based view of a container and its lowest level, cursor aware
   --  view.

   procedure From_Cursors_To_Elements (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all Cu in S => Q (Element (S, Cu))),
     Post   => (for all I in 1 .. Length (S) =>
                    Q (Get (Elements (S), I)));
   --  Test that the link can be done from a property on the elements of a
   --  cursor aware view of a container and its position based view.

   procedure From_Model_To_Cursors (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all E of S => Q (E)),
     Post   => (for all Cu in S => Q (Element (S, Cu)));
   --  Test that the link can be done from a property on the elements of a
   --  high level view of a container and its lowest level, cursor aware view.

   procedure From_Cursors_To_Model (S : My_Sets.Set) with
     Ghost,
     Global => null,
     Pre    => (for all Cu in S => Q (Element (S, Cu))),
     Post   => (for all E of S => Q (E));
   --  Test that the link can be done from a property on the elements of a
   --  low level, cursor aware view of a container and its high level view.
end Use_Sets;
