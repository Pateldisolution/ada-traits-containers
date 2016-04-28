pragma Ada_2012;
with Conts.Vectors.Indefinite_Unbounded;

generic
   type Index_Type is (<>);
   --  To avoid Constraint_Error being raised at runtime, Index_Type'Base
   --  should have at least one more element at the left than Index_Type.

   type Element_Type (<>) is private;
package Functional_Sequences with SPARK_Mode is

   type Sequence is private
     with Default_Initial_Condition => Natural'(Length (Sequence)) = 0;
   --  Sequences are empty when default initialized.
   --  The qualification is required for Length not to be mistaken to
   --  Element_Lists.Length (though I don't know how this could happen,
   --  Sequence being private...)
   --  Quantification over sequences can be done using the regular
   --  quantification over its range.

   --  Sequences are axiomatized using Length and Get providing respectively
   --  the length of a sequence and an accessor to its Nth element:

   function Length (S : Sequence) return Natural with
     Global => null;
   function Get (S : Sequence; N : Index_Type) return Element_Type with
     Global => null,
     Pre    => N in Index_Type'First ..
          (Index_Type'Val
             ((Index_Type'Pos (Index_Type'First) - 1) + Length (S)));

   function "=" (S1, S2 : Sequence) return Boolean with
   --  Extensional equality over sequences.

     Global => null,
     Post   => "="'Result =
       (Length (S1) = Length (S2)
        and then (for all N in Index_Type'First ..
          (Index_Type'Val
             ((Index_Type'Pos (Index_Type'First) - 1) + Length (S1))) =>
            Get (S1, N) = Get (S2, N)));

   function Is_Replace
     (S : Sequence; N : Index_Type; E : Element_Type; Result : Sequence)
      return Boolean
   --  Returns True if Result is S where the Nth element has been replaced by
   --  E.

   with
     Global => null,
       Post   => Is_Replace'Result =
         (N in Index_Type'First ..
          (Index_Type'Val
             ((Index_Type'Pos (Index_Type'First) - 1) + Length (S)))
          and then Length (Result) = Length (S)
          and then Get (Result, N) = E
          and then (for all M in Index_Type'First ..
            (Index_Type'Val
               ((Index_Type'Pos (Index_Type'First) - 1) + Length (S))) =>
              (if M /= N then Get (Result, M) = Get (S, M))));

   function Replace
     (S : Sequence; N : Index_Type; E : Element_Type) return Sequence
   --  Returns S where the Nth element has been replaced by E.
   --  Is_Replace (S, N, E, Result) should be instead of than
   --  Result = Replace (S, N, E) whenever possible both for execution and for
   --  proof.

   with
     Global => null,
     Pre    => N in Index_Type'First ..
          (Index_Type'Val
             ((Index_Type'Pos (Index_Type'First) - 1) + Length (S))),
     Post   => Is_Replace (S, N, E, Replace'Result);

   function Is_Add
     (S : Sequence; E : Element_Type; Result : Sequence) return Boolean
   --  Returns True if Result is S appended with E.

   with
     Global => null,
     Post   => Is_Add'Result =
         (Length (Result) = Length (S) + 1
          and then Get (Result, Index_Type'Val
            ((Index_Type'Pos (Index_Type'First) - 1) + Length (Result))) = E
          and then (for all M in Index_Type'First ..
            (Index_Type'Val
               ((Index_Type'Pos (Index_Type'First) - 1) + Length (S))) =>
              Get (Result, M) = Get (S, M)));

   function Add (S : Sequence; E : Element_Type) return Sequence with
   --  Returns S appended with E.
   --  Is_Add (S, E, Result) should be used instead of Result = Add (S, E)
   --  whenever possible both for execution and for proof.

     Global => null,
     Pre    => Length (S) < Natural'Last
     and then ((Index_Type'Pos (Index_Type'First) - 1) + Length (S)) <
       Index_Type'Pos (Index_Type'Last),
     Post   => Is_Add (S, E, Add'Result);

private
   pragma SPARK_Mode (Off);

   type Neither_Controlled_Nor_Limited is tagged null record;

   --  Functional sequences are neither controlled nor limited. As a result,
   --  no primitive should be provided to modify them. Note that we
   --  should definitely not use limited types for those as we need to apply
   --  'Old on them.
   --  ??? Should we make them controlled to avoid memory leak ?

   package Element_Lists is new Conts.Vectors.Indefinite_Unbounded
     (Element_Type        => Element_Type,
      Index_Type          => Index_Type,
      Container_Base_Type => Neither_Controlled_Nor_Limited);

   type Sequence is new Element_Lists.Vector with null record;
end Functional_Sequences;
