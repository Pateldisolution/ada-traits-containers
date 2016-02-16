#!/usr/bin/env python
"""
This script is used to generate test for the various container combinations.
"""

############
# Comments #
############

class Comments(object):
    def __init__(self, **kwargs):
        self.comments = kwargs

    def __getattr__(self, key):
        return self.comments.get(key, '')

#############
# Templates #
#############

def wrap(name, text, group=True, expected=True):
    repl = dict(
      name=name,
      group="True" if group else "False",
      text=text)

    r = """

      Co := 0;
      Stdout.Start_Test ("%(name)s", "{comments.%(name)s}", Start_Group => %(group)s);""" % repl
      
    r += text
    r += "\n      Stdout.End_Test;" % repl

    if expected:
        r += """\n      Assert (Co, {expected}, "%(name)s");""" % repl
    return r

class Templates(object):
    """
    Text for the various steps to be performed in tests.
    """

    # Contents of the .ads file

    spec = """
with Report; use Report;
pragma Style_Checks (Off);
procedure {test_name}
   (Stdout : not null access Output'Class);"""

    # Header for the .adb file

    body_header = """
{withs}
pragma Style_Checks (Off);
pragma Warnings (Off, "unit * is not referenced");
with Perf_Support;  use Perf_Support;
with Ada.Finalization;
with Conts.Algorithms;
with Conts.Adaptors;
pragma Warnings (On, "unit * is not referenced");
procedure {test_name}
   (Stdout : not null access Output'Class)
is
   {instance}
   use Container;{adaptors}

   procedure Run (V2 : in out Container.{type});
   --  Force dynamic dispatching for the container (if relevant), as a
   --  a way to check we do not waste time there.

   procedure Run (V2 : in out Container.{type}) is
      It : Container.Cursor;
      Co : Natural;
   begin"""

    # Footer for the .adb file

    body_footer = """
   end Run;

begin
   Stdout.Start_Container_Test
      ("{base}", "{definite}", "{nodes}", "{category}", {favorite});
   for C in 1 .. Repeat_Count loop
      declare
         V : Container.{type}{discriminant};
      begin
         Stdout.Save_Container_Size (V'Size / 8);  --  in bytes
         Run (V);{clear}
      end;
   end loop;
   Stdout.End_Container_Test;
end {test_name};"""

    # Filling a list or a vector

    list_fill = wrap("fill", """
      for C in 1 .. Items_Count loop
         {append}
      end loop;""", group=True, expected=False)

    # Copying a list or a vector

    list_copy = wrap("copy", """
      declare
         V_Copy : Container.{type}'Class := V2{copy};
         pragma Unreferenced (V_Copy);
      begin
         --  Measure the time before we destroy the copy
         Stdout.End_Test;{clear_copy}
      end;""", group=False, expected=False)

    # Count with a cursor loop for list or vector (integers)

    list_int_cursor_loop = wrap("cursor loop", """
      It := V2.First;
      while {prefix}Has_Element (It) loop
         if {prefix}Element (It) <= 2 then
            Co := Co + 1;
         end if;
         It := {prefix}Next (It);
      end loop;""", group=True)

    # Count with a cursor loop for list or vector (strings)

    list_str_cursor_loop = wrap("cursor loop", """
      It := V2.First;
      while {prefix}Has_Element (It) loop
         if Predicate ({prefix}Element (It)) then
            Co := Co + 1;
         end if;
         It := {prefix}Next (It);
      end loop;""", group=True)

    # Count with a for-of loop (integers)

    list_int_for_of_loop = wrap("for-of loop", """
      for E of V2 loop
         if E <= 2 then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    # Count with a for-of loop (strings)

    list_str_for_of_loop = wrap("for-of loop", """
      for E of V2 loop
         if Predicate (E) then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    # Count_If with an algorithm

    list_count_if = wrap("count_if", """
      Co := Count_If (V2, Predicate'Access);""", group=False)

    # loop using Constant_Indexing

    int_int_indexing_loop = wrap("indexed", """
      for C in 1 .. Items_Count loop
         if V2 (C) <= 2 then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    int_str_indexing_loop = wrap("indexed", """
      for C in 1 .. Items_Count loop
         if Predicate (V2 (C)) then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    str_str_indexing_loop = wrap("indexed", """
      for C in 1 .. Items_Count loop
         if Predicate (V2 ("1")) then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    # Filling a map

    map_fill = wrap("fill", """
      for C in 1 .. Items_Count loop
         {append}
      end loop;""", group=True, expected=False)

    # Copying a map

    map_copy = wrap("copy", """
      declare
         V_Copy : Container.{type}'Class := V2{copy};
         pragma Unreferenced (V_Copy);
      begin
         --  Measure the time before we destroy the copy
         Stdout.End_Test;{clear_copy}
      end;""", group=False, expected=False)

    # cursor loop for map

    map_cursor_loop = wrap("cursor loop", """
      It := V2.First;
      while {prefix}Has_Element (It) loop
         if Predicate ({prefix}Element (It)) then
            Co := Co + 1;
         end if;
         It := {prefix}Next (It);
      end loop;""", group=True)

    # for-of loop for map

    map_for_of_loop = wrap("for-of loop", """
      for E of V2 loop
         if Predicate (E) then
            Co := Co + 1;
         end if;
      end loop;""", group=False)

    # count_if for map

    map_count_if = wrap("count_if", """
      Co := Count_If (V2, Predicate'Access);""", group=False)

    # find for map

    map_find = wrap("find", """
      for C in 1 .. Items_Count loop
         if Predicate (V2{get}) then
            Co := Co + 1;
         end if;
      end loop;""", group=True)

    @staticmethod
    def lists(elem_type):
        if elem_type == "integer":
            return (Templates.list_fill, Templates.list_copy,
                    Templates.list_int_cursor_loop,
                    Templates.list_int_for_of_loop, Templates.list_count_if)
        else:
            return (Templates.list_fill, Templates.list_copy,
                    Templates.list_str_cursor_loop,
                    Templates.list_str_for_of_loop, Templates.list_count_if)

    @staticmethod
    def vectors(elem_type):
        if elem_type == "integer":
            return (Templates.list_fill, Templates.list_copy,
                    Templates.list_int_cursor_loop,
                    Templates.list_int_for_of_loop, Templates.list_count_if,
                    Templates.int_int_indexing_loop)
        else:
            return (Templates.list_fill, Templates.list_copy,
                    Templates.list_str_cursor_loop,
                    Templates.list_str_for_of_loop, Templates.list_count_if,
                    Templates.int_str_indexing_loop)

    @staticmethod
    def maps(elem_type):
        if elem_type == "intint":
            return (Templates.map_fill, Templates.map_copy,
                    Templates.map_cursor_loop, Templates.map_for_of_loop,
                    Templates.map_count_if, Templates.int_int_indexing_loop,
                    Templates.map_find)
        else:
            return (Templates.map_fill, Templates.map_copy,
                    Templates.map_cursor_loop, Templates.map_for_of_loop,
                    Templates.map_count_if, Templates.str_str_indexing_loop,
                    Templates.map_find)

#########
# Tests #
#########

class Tests(object):

    def write(self):
        filename = self.args['test_name'].lower()

        ads = open("tests/generated/%s.ads" % filename, "w")
        ads.write(Templates.spec.format(**self.args))
        ads.close()

        adb = open("tests/generated/%s.adb" % filename, "w")
        adb.write(Templates.body_header.format(**self.args))
        for t in self.tests():
            adb.write(t.format(**self.args))
        adb.write(Templates.body_footer.format(**self.args))
        adb.close()

    def gen(self, adaptor):
        self.args['prefix'] = 'V2.'
        self.args['adaptors'] = """
   function Count_If is new Conts.Algorithms.Count_If
      (Container.Cursors.Forward, Container.Maps.%s);""" % adaptor
        self.write()

    def gen_ada2012(self,
                    disable_checks=False,
                    adaptor="Returned",
                    adaptors='{type}_Adaptors'):
        """
        Generate tests for the Ada 2012 containers
        """

        adapt = adaptors.format(**self.args)
        suppress = "pragma Suppress (Container_Checks);\n" if disable_checks else ""

        self.args['adaptors'] = """
   %spackage Adaptors is new Conts.Adaptors.%s (Container);
   function Count_If is new Conts.Algorithms.Count_If
      (Adaptors.Cursors.Forward, Adaptors.Maps.%s);""" % (suppress, adapt, adaptor)

        self.write()

########
# List #
########

class List(Tests):
    type = "List"

    def __init__(
        self,
        elem_type,   # "integer", "string",...
        base,        # "controlled", "limited", ...
        definite,    # "definite", "indefinite", ...
        nodes,       # "bounded", "unbounded", ...
        instance,    # instantiation for the container "package Container is ..."
        withs,       # extra withs for the body
        comments=None, # instance of Comments
        favorite=False # Whether this should be highlighted in the results
    ):
        self.elem_type = elem_type.lower()

        # We use two default strings (one short, one long), to test various
        # approaches of storing elements

        if elem_type.lower() == "integer":
            category = '%s %s' % (elem_type, self.type)
            append = "V2.Append (C);"
            expected = "2"

        elif elem_type.lower() == "string":
            category = '%s %s' % (elem_type, self.type)
            expected = "Items_Count"
            append = """
         if C mod 2 = 0 then
             V2.Append ("foo");
         else
             V2.Append ("foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoo");
         end if;"""

        elif elem_type.lower() == "unbounded_string":
            category = 'String %s' % (self.type, )
            expected = "Items_Count"
            append = """
         if C mod 2 = 0 then
             V2.Append (To_Unbounded_String ("foo"));
         else
             V2.Append (To_Unbounded_String
                ("foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoo"));
         end if;"""
        else:
            raise Exception("Unknown element type: %s" % elem_type)

        self.args = dict(
            base=base,
            definite=definite,
            nodes=nodes,
            expected=expected,
            category=category,
            type=self.type,
            elem_type=elem_type,
            instance=instance,
            withs=withs,
            copy='',
            call_count_if='',
            discriminant='',
            favorite=favorite,
            comments=comments or Comments(),
            clear='',       # Explicit clear the container
            clear_copy='',  # Explicit clear the copy of the container
            prefix='',      # Prefix for Element, Next and Has_Element
            adaptors='',    # Creating adaptors for standard containers
            append=append)

        if self.args['base'].lower() == "limited":
            # Need an explicit copy, since ":=" is not defined for limited types
            self.args['copy'] = '.Copy'
            self.args['clear'] = '\n      V.Clear;'
            self.args['clear_copy'] = '\n         V_Copy.Clear;'

        if self.args['nodes'].lower() == "bounded":
            self.args['discriminant'] = ' (Capacity => Items_Count)'

        self.args['test_name'] = \
            "{type}_{base}_{definite}_{nodes}_{elem_type}".format(**self.args)

    def tests(self):
        return Templates.lists(self.elem_type)

#######
# Map #
#######

class Map(Tests):

    def __init__(
        self,
        elem_type,   # "intint", "strstr",...
        base,        # "controlled", "limited", ...
        key,         # "definite", "indefinite", ...
        value,       # "definite", "indefinite", ...
        nodes,       # "bounded", "unbounded", ...
        instance,    # instantiation for the container "package Container is ..."
        withs,       # extra withs for the body
        comments=None, # instance of Comments
        favorite=False, # Whether this should be highlighted in the results
        ada2012=False
    ):
        type="Map"
        category = '%s %s' % (elem_type, type)

        self.elem_type = elem_type.lower()

        if self.elem_type == "strstr":
            get_val = 'Image (C)'
            expected = "Items_Count"
            append = """
        --   ??? Can't use V2 (V'Img) := "foo"
        V2.{set} (Image (C), "foo");
"""

        elif elem_type.lower() == "intint":
            get_val = 'C'
            expected = "2"
            append = """
        V2.{set} (C, C);
"""

        if ada2012:
            set = "Include"
            get = '.Element (%s)' % get_val
        else:
            set = "Set"
            get = '.Get (%s)' % get_val

        self.args = dict(
            base=base,
            key=key,
            value=value,
            definite="%s-%s" % (key, value),
            nodes=nodes,
            category=category,
            type=type,
            elem_type=elem_type,
            instance=instance,
            withs=withs,
            expected=expected,
            copy='',
            get=get,
            set=set,
            call_count_if='',
            discriminant='',
            favorite=favorite,
            comments=comments or Comments(),
            clear='',       # Explicit clear the container
            clear_copy='',  # Explicit clear the copy of the container
            prefix='',      # Prefix for Element, Next and Has_Element
            adaptors='',    # Creating adaptors for standard containers
            append=append.format(set=set))

        if self.args['nodes'].lower() == "bounded":
            self.args['discriminant'] = ' (Capacity => Items_Count, ' + \
                ' Modulus => Default_Modulus (Items_Count))'

        self.args['test_name'] = \
            "{type}_{base}_{key}_{value}_{nodes}_{elem_type}".format(
                **self.args)

    def tests(self):
        return Templates.maps(self.elem_type)

##########
# Vector #
##########

class Vector(List):
    type = "Vector"

    def tests(self):
        return Templates.vectors(self.elem_type)


# Integer lists

i = " (Integer);"
ci = " (Integer);"
s = " (String);"
cs = " (String);"

List("Integer", "Ada12", "Def", "Bounded",
     "package Container is new Ada.Containers.Bounded_Doubly_Linked_Lists" + i,
     "with Ada.Containers.Bounded_Doubly_Linked_Lists;").gen_ada2012(
        adaptors='Bounded_List_Adaptors')
List("Integer", "Ada12", "Def", "Unbounded",
     "package Container is new Ada.Containers.Doubly_Linked_Lists" + i,
     "with Ada.Containers.Doubly_Linked_Lists;").gen_ada2012()
List("Integer", "Ada12", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Doubly_Linked_Lists" +
     " (Integer);",
     "with Ada.Containers.Indefinite_Doubly_Linked_Lists;").gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_List_Adaptors')
List("Integer", "Ada12_No_Checks", "Def", "Unbounded",
     "package Container is new Ada.Containers.Doubly_Linked_Lists" + i,
     "with Ada.Containers.Doubly_Linked_Lists;",
     favorite=True).gen_ada2012(disable_checks=True)
List("Integer", "Controlled", "Indef", "Unbounded",
     "package Container is new Conts.Lists.Indefinite_Unbounded" + ci,
     "with Conts.Lists.Indefinite_Unbounded;").gen(adaptor="Returned")
List("Integer", "Controlled", "Def", "Unbounded",
     "package Container is new Conts.Lists.Definite_Unbounded" + ci,
     "with Conts.Lists.Definite_Unbounded;",
     favorite=True,
     comments=Comments(forofloop=
          "Because of dynamic dispatching -- When avoided, we gain 40%")
    ).gen(adaptor="Returned")
List("Integer", "Controlled", "Def", "Bounded",
     "package Container is new Conts.Lists.Definite_Bounded" + ci,
     "with Conts.Lists.Definite_Bounded;").gen(adaptor="Returned")
List("Integer", "Limited", "Indef_Spark", "Unbounded_Spark",
     "package Container is new Conts.Lists.Indefinite_Unbounded_SPARK" + i,
     "with Conts.Lists.Indefinite_Unbounded_SPARK;").gen(adaptor="Returned")

# String lists

List("String", "Ada12", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Doubly_Linked_Lists" + s,
     "with Ada.Containers.Indefinite_Doubly_Linked_Lists;",
     favorite=False).gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_List_Adaptors')
List("String", "Ada12_No_Checks", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Doubly_Linked_Lists" + s,
     "with Ada.Containers.Indefinite_Doubly_Linked_Lists;",
     favorite=True).gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_List_Adaptors',
         disable_checks=True)
List("String", "Controlled", "Indef", "Unbounded",
     "package Container is new Conts.Lists.Indefinite_Unbounded" + cs,
     "with Conts.Lists.Indefinite_Unbounded;",
     comments=Comments(cursorloop="Cost if for copying the string")).gen(adaptor="Returned")
List("String", "Controlled", "Indef", "Unbounded_Ref",
     "package Container is new Conts.Lists.Indefinite_Unbounded_Ref" + cs,
     "with Conts.Lists.Indefinite_Unbounded_Ref;",
     comments=Comments(
         countif="Conversion from Reference_Type to Element_Type"),
     favorite=True).gen(adaptor="Element")
List("Unbounded_String", "Controlled", "Def", "Unbounded",
     "package Container is new Conts.Lists.Definite_Unbounded"
       + "(Unbounded_String);",
     "with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;\n" +
     "with Conts.Lists.Definite_Unbounded;",
     comments=Comments(
         cursorloop="Maybe because of the atomic counters or controlled elements")
    ).gen(adaptor="Returned")
List("String", "Controlled", "Strings_Specific", "Unbounded",
     "package Container renames Conts.Lists.Strings;",
     "with Conts.Lists.Strings;",
     comments=Comments(
         countif='conversion to String',
         fill='strange, since we are doing fewer mallocs. Faster if we only' +
             'preallocate a 1 element array')
    ).gen(adaptor="Element")

# Integer vectors

p = " (Positive, Integer);"
cp = " (Positive, Integer, Ada.Finalization.Controlled);"
lp = " (Positive, Integer, Conts.Limited_Base);"

Vector("Integer", "Ada12", "Def", "Bounded",
     "package Container is new Ada.Containers.Bounded_Vectors" + p,
     "with Ada.Containers.Bounded_Vectors;").gen_ada2012(
        adaptors='Bounded_Vector_Adaptors')
Vector("Integer", "Ada12", "Def", "Unbounded",
     "package Container is new Ada.Containers.Vectors" + p,
     "with Ada.Containers.Vectors;").gen_ada2012()
Vector("Integer", "Ada12", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Vectors" + p,
     "with Ada.Containers.Indefinite_Vectors;").gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_Vector_Adaptors')
Vector("Integer", "Ada12_No_Checks", "Def", "Unbounded",
     "package Container is new Ada.Containers.Vectors" + p,
     "with Ada.Containers.Vectors;",
     favorite=True).gen_ada2012(disable_checks=True)
Vector("Integer", "Controlled", "Indef", "Unbounded",
     "package Container is new Conts.Vectors.Indefinite_Unbounded" + p,
     "with Conts.Vectors.Indefinite_Unbounded;").gen(adaptor="Returned")
Vector("Integer", "Controlled", "Def", "Unbounded",
     "package Container is new Conts.Vectors.Definite_Unbounded" + cp,
     "with Conts.Vectors.Definite_Unbounded;",
       comments=Comments(
           cursorloop='test in Next to see if we reached end of loop'),
     favorite=True).gen(adaptor="Returned")
Vector("Integer", "Controlled", "Def", "Bounded",
     "package Container is new Conts.Vectors.Definite_Bounded" + p,
     "with Conts.Vectors.Definite_Bounded;").gen(adaptor="Returned")

# String vectors

p = " (Positive, String);"
cp = " (Positive, String, Ada.Finalization.Controlled);"

Vector("String", "Ada12", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Vectors" + p,
     "with Ada.Containers.Indefinite_Vectors;").gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_Vector_Adaptors')
Vector("String", "Ada12_No_Checks", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Vectors" + p,
     "with Ada.Containers.Indefinite_Vectors;",
     favorite=True).gen_ada2012(
         adaptor="Element",
         adaptors='Indefinite_Vector_Adaptors',
         disable_checks=True)
Vector("String", "Controlled", "Indef", "Unbounded",
     "package Container is new Conts.Vectors.Indefinite_Unbounded" + p,
     "with Conts.Vectors.Indefinite_Unbounded;").gen(adaptor="Returned")
Vector("String", "Controlled", "Indef", "Unbounded_Ref",
     "package Container is new Conts.Vectors.Indefinite_Unbounded_Ref" + cp,
     "with Conts.Vectors.Indefinite_Unbounded_Ref;", favorite=True).gen(
         adaptor="Element")

# Integer-Integer maps

Map("IntInt", "Ada12_ordered", "Def", "Def", "Unbounded",
     "package Container is new Ada.Containers.Ordered_Maps" +
         " (Integer, Integer);",
     "with Ada.Containers.Ordered_Maps;",
     ada2012=True).gen_ada2012(
         adaptor="Element",
         adaptors="Ordered_Maps_Adaptors")
Map("IntInt", "Ada12_hashed", "Def", "Def", "Unbounded",
    'function Hash (K : Integer) return Conts.Hash_Type is\n'
     + '   (Conts.Hash_Type (K)) with Inline;\n'
     + 'package Container is new Ada.Containers.Hashed_Maps'
     + ' (Integer, Integer, Hash, "=");',
     "with Ada.Containers.Hashed_Maps;",
     ada2012=True).gen_ada2012(
         adaptor="Element",
         adaptors="Hashed_Maps_Adaptors")
Map("IntInt", "Ada12_hashed", "Def", "Def", "Bounded",
    'function Hash (K : Integer) return Conts.Hash_Type is\n'
     + '   (Conts.Hash_Type (K)) with Inline;\n'
     + 'package Container is new Ada.Containers.Bounded_Hashed_Maps'
     + ' (Integer, Integer, Hash, "=");',
     "with Ada.Containers.Bounded_Hashed_Maps;",
     ada2012=True).gen_ada2012(
         adaptor="Element",
         adaptors="Bounded_Hashed_Maps_Adaptors")
Map("IntInt", "hashed", "Def", "Def", "Unbounded",
    'function Hash (K : Integer) return Conts.Hash_Type is\n'
    + '   (Conts.Hash_Type (K)) with Inline;\n'
    + 'package Container is new Conts.Maps.Def_Def_Unbounded\n'
    + '   (Integer, Integer, Ada.Finalization.Controlled, Hash);'
    + 'function Predicate (P : Container.Pair_Type) return Boolean\n'
    + '   is (Predicate (Container.Value (P))) with Inline;',
    'with Conts.Maps.Def_Def_Unbounded;',
    favorite=True).gen(adaptor="Pair")
Map("IntInt", "hashed_linear_probing", "Def", "Def", "Unbounded",
    'function Hash (K : Integer) return Conts.Hash_Type is\n'
     + '   (Conts.Hash_Type (K)) with Inline;\n'
    + 'package Container is new Conts.Maps.Def_Def_Unbounded\n'
    + '   (Integer, Integer, Ada.Finalization.Controlled, Hash);'
    + 'function Predicate (P : Container.Pair_Type) return Boolean\n'
    + '   is (Predicate (Container.Value (P))) with Inline;',
    'with Conts.Maps.Def_Def_Unbounded;',
    favorite=True).gen(adaptor="Pair")

# String-String maps

Map("StrStr", "Ada12_ordered", "Indef", "Indef", "Unbounded",
     "package Container is new Ada.Containers.Indefinite_Ordered_Maps" +
         " (String, String);",
     "with Ada.Containers.Indefinite_Ordered_Maps;",
     ada2012=True).gen_ada2012(
         adaptor="Element",
         adaptors="Indefinite_Ordered_Maps_Adaptors")
Map("StrStr", "Ada12_hashed", "Indef", "Indef", "Unbounded",
     'package Container is new Ada.Containers.Indefinite_Hashed_Maps' +
         ' (String, String, Ada.Strings.Hash, "=");',
     "with Ada.Strings.Hash;\n" +
     "with Ada.Containers.Indefinite_Hashed_Maps;",
     ada2012=True).gen_ada2012(
         adaptor="Element",
         adaptors="Indefinite_Hashed_Maps_Adaptors")
Map("StrStr", "hashed", "Indef", "Indef", "Unbounded",
    'package Container is new Conts.Maps.Indef_Indef_Unbounded\n'
    + '   (String, String, Ada.Finalization.Controlled, Ada.Strings.Hash);'
    + 'function Predicate (P : Container.Pair_Type) return Boolean\n'
    + '   is (Predicate (Container.Value (P))) with Inline;',
    'with Conts.Maps.Indef_Indef_Unbounded, Ada.Strings.Hash;',
    favorite=True).gen(adaptor="Pair")
Map("StrStr", "hashed_linear_probing", "Indef", "Indef", "Unbounded",
    'package Container is new Conts.Maps.Indef_Indef_Unbounded\n'
    + '   (String, String, Ada.Finalization.Controlled, Ada.Strings.Hash);'
    + 'function Predicate (P : Container.Pair_Type) return Boolean\n'
    + '   is (Predicate (Container.Value (P))) with Inline;',
    'with Conts.Maps.Indef_Indef_Unbounded, Ada.Strings.Hash;',
    favorite=True).gen(adaptor="Pair")
