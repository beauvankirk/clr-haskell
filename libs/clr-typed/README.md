# clr-typed - A strongly typed Haskell interface to the CLR type system

## Status

[![unix build status](https://gitlab.com/tim-m89/clr-haskell/badges/master/build.svg)](https://gitlab.com/tim-m89/clr-haskell/commits/master)[![Windows Build status](https://ci.appveyor.com/api/projects/status/073rvyuyvxrcqvsw?svg=true&label=Windows%20build)](https://ci.appveyor.com/project/TimMatthews/clr-haskell)

## Overview

This package provides a library to implement a strongly typed flavour for CLR <-> Haskell interoperability. It includes an encoding of OOP type system semantics within the GHC Haskell type system.

See the [**example**](https://gitlab.com/tim-m89/clr-haskell/blob/master/examples/clr-typed-demo/src/Main.hs) for what it is currently capable of and how to use it.

## What it looks like

* CLR member & type names are specified with a type level [`Symbol`](https://downloads.haskell.org/~ghc/latest/docs/html/libraries/base-4.9.0.0/GHC-TypeLits.html#t:Symbol), and are expected to be applied via the `TypeApplications` extension.
* Arguments are tupled, so that overload resolution can see the full type up front. Unit is used for argument-less methods.
* Method identifier comes first due to type applications.

```haskell
resulta <- invokeI @"ObjMethodName" object ()  -- No arguments
resultb <- invokeI @"ObjMethodName" object "arg0"
resultc <- invokeI @"ObjMethodName" object ("arg1", 3, "hi")

```
* Similarly for static methods. Method identifier again comes first for consistency with instance methods.

```haskell
invokeS @"DoStuff" @"SomeClass" ()
```

* Constructors are used in a similar fashion

```haskell
obj <- new @"SomeType" ()
```

* Generic type instantiations are done using a promoted tuple instead of just a Symbol

```haskell
strList <- new @'("List", "String") ()
```

* Generics may be used in a method identifier position in the same way

```haskell
invokeS @'("SomeGenericMethod", "Integer") @"SomeClass" ()
```
