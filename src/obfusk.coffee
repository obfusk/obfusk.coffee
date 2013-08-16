# <!-- {{{1 -->
#
#     File        : obfusk.coffee
#     Maintainer  : Felix C. Stegerman <flx@obfusk.net>
#     Date        : 2013-08-16
#
#     Copyright   : Copyright (C) 2013  Felix C. Stegerman
#     Licence     : GPLv2 or EPLv1
#
# <!-- }}}1 -->

# functional programming library for js/coffee
#
# https://github.com/obfusk/obfusk.coffee
#
# License: GPLv2 or EPLv1.

# underscore + exports + misc
# ---------------------------

U = this._ || require 'underscore'
O = exports ? this.obfusk ||= {}
misc = O.misc ||= {}


# miscellaneous
# -------------

# make first char of string uppercase
#
#     misc.titleCase 'fOO' # => 'FOO'
misc.titleCase = titleCase = (x) ->
  x.charAt(0).toUpperCase() + x.substr 1

# quote words
#
#     qw 'foo, bar baz' # => ['foo', 'bar', 'baz']
O.qw = qw = (xs...) ->
  xs.join(' ').replace(/,/g,' ').split(/\s+/)

# throw Error
O.error = error = (x) -> throw new Error x


# currying & partial application
# --------

# f.length (or f.arg_length if set)
O.flen = flen = (f) -> f.arg_length ? f.length

# reverse function arguments
#
#     (frev f)(1,2,3) <=> f(3,2,1)
O.frev = frev = (f) ->
  g = (args...) -> f U.clone(args).reverse()...
  g.arg_length = flen f; g

# flip first two arguments
O.flip = flip = (f) ->
  g = (x, y, args...) -> f y, x, args...
  g.arg_length = flen f; g

# fix number of function arguments
#
#     g = fix f, 3  # takes exactly 3 arguments
O.fix = fix = (f, n = flen(f)) ->
  g = (args...) ->
    error "fix: #args != #{n}" if args.length != n
    f args.slice(0, n)...
  g.arg_length = n; g

# <!-- {{{1 -->
#
# curry a function; the curried function take at least one argument at
# a time, until it has either received n arguments in total, or
# receives no arguments (if noargs = true); except, if strict = true,
# then the curried function takes exactly one argument at a time
#
#     f = (a,b,c,d=88,e=99) -> a + b * c / d - e
#     g = curry f
#     g(1)(2,3)(4)(5)
#     g(2,3,4)()
#
# <!-- }}}1 -->
O.curry = curry = (f, n = flen(f), strict = false, noargs = true) ->
  _curry f, n, strict, noargs, []

_curry = (f, n, strict, noargs, xs) ->                          # {{{1
  g = (ys...) ->
    error 'curry: unary function' if strict && ys.length != 1
    zs = xs.concat ys
    if (noargs && ys.length == 0) || zs.length >= n
      f zs...
    else
      _curry f, n, strict, noargs, zs
  g.curried = curry; g
                                                      #  <!-- }}}1 -->

# curry + frev (noargs = false)
O.rcurry = rcurry = (f, n, strict) -> curry frev(f), n, strict, false

# partial application
#
#     f = (a,b,c,d) -> [a,b,c,d]
#     g = partial f, 1, 2
#     g 3, 4  # => [1,2,3,4]
O.partial = partial = (f, xs...) ->
  g = (ys...) -> f xs.concat(ys)...
  g.arg_length = flen(f) - xs.length; g

# partial application, from the right
#
#     f = (a,b,c,d,e=99) -> [a,b,c,d,e]
#     g = rpartial f, 3, 4, 88
#     h = rpartial (fix f, 4), 3, 4
#     g 1, 2  # => [1,2,3,4,88]
#     h 1, 2  # => [1,2,3,4,99]
O.rpartial = rpartial = (f, xs...) ->
  g = (ys...) -> f ys.concat(xs)...
  g.arg_length = flen(f) - xs.length; g


# overloaded arity
# ----------------

# <!-- {{{1 -->
#
# creates a functions with overloaded arity; dispatches bases on
# arguments.length; if no match is found, dispatches to the last
# function with arity 0 (if any)
#
#     f = overload (()              -> 1),
#                  ((x)             -> x),
#                  ((x, y)          -> x + y),
#                  ((x, y, args...) -> f (f x, y), args...)
#
# <!-- }}}1 -->
O.overload = overload = (fs...) ->                              # {{{1
  d = null; t = {}
  for f in fs
    if flen(f) == 0
      d = f
    else if t[flen f]
      error 'overload: multiple functions with same (non-zero) arity'
    t[flen f] ||= f
  (args...) ->
    for x in [t[args.length], d]
      return x args... if x
    error 'overload: no match found'
                                                      #  <!-- }}}1 -->


# multimethods
# ------------

# <!-- {{{1 -->
#
# creates a multimethod with optional default; you can add a new
# method implementation to an existing multimethod with `.method`,
# supplying a predicate and a function; alternatively you can use
# `.withMethod` to create a new multimethod with the implementation
# added; also, `.methodPre` and `.withMethodPre` add the new
# implementation at the front instead of the back so the predicate
# will be checked before the existing ones
#
#     neg = multi((x) -> 'default')
#       .method ((x) -> typeof x == 'number'),
#               ((x) -> -x)
#       .method ((x) -> typeof x == 'boolean'),
#               ((x) -> !x)
#
# <!-- }}}1 -->
O.multi = multi = (f = null) -> _multi [], f

_multi = (fs, def) ->                                           # {{{1
  find = (args...) ->
    for f in fs
      return f.f if f.p args...
    return def
  g = (args...) ->
    if (f = find(args...))? then f args...
    else error 'multi: no match found'
  g.find          = find
  g.method        = (p, f) -> fs.push     p: p, f: f; g
  g.methodPre     = (p, f) -> fs.unshift  p: p, f: f; g
  g.withMethod    = (p, f) -> _multi fs.concat([p: p, f: f]), def
  g.withMethodPre = (p, f) -> _multi [p: p, f: f].concat(fs), def
  g
                                                      #  <!-- }}}1 -->


# lazy
# ----

# is this a lazy object?; see lazy
O.isLazy = isLazy = (x) -> x.lazy == lazy

# lazy object (thunk)
#
#     a = lazy 42; b = lazy -> 42; c = lazy a
#     d = lazy -> console.log 'thunk!'; 42
#     [a(),a(),b(),c(),d(),d()]
#     # => [42,42,42,42,42]; console.log is called only once
#
O.lazy = lazy = (x) ->                                          # {{{1
  return x if isLazy x
  f = if U.isFunction x then x else -> x
  v = null; e = false
  g = -> (v = f(); e = true) unless e; v
  g.lazy = lazy; g
                                                      #  <!-- }}}1 -->


# ADTs
# ----

# algebraic data type; returns an object with `.ctor1`, ...; each
# constructor creates an object using the supplied function, which is
# extended with `.type`, `.ctor`, and `.isCtor1`, ...; see Maybe,
# Either, List
O.data = data = (ctors = {}) ->                                 # {{{1
  type = {}
  for k, v of ctors
    do (v, o = { ctor: k, type: type }) ->
      for k2, v2 of ctors
        o["is#{titleCase k2}"] = k == k2
      type[k] = -> U.extend {}, v(arguments...), o
  type
                                                      #  <!-- }}}1 -->

# run the function matching the constructor
O.match = match = (x, f = {}) -> f[x.ctor]? x


# Maybe
# -----

# Maybe type: optional value
O.Maybe = Maybe = data
  Nothing: -> {}
  Just: (x) -> { value: x }

O.Nothing = Nothing = Maybe.Nothing
O.Just    = Just    = Maybe.Just


# Either
# ------

# Either type: value with two possibilities
O.Either = Either = data
  Left:  (x) -> { value: x }
  Right: (x) -> { value: x }

O.Left  = Left  = Either.Left
O.Right = Right = Either.Right


# List
# ----

# List type: lazy list
O.List = List = data
  Nil: -> {}
  Cons: (h, t) -> { head: h, tail: lazy t }

O.Nil   = Nil   = List.Nil
O.Cons  = Cons  = List.Cons

# create a List from arguments
#
#     list 1, 2, 3
O.list = list = (x, xt...) ->
  if arguments.length == 0 then Nil() else Cons x, -> list xt...


# create a list from arguments + tail
#
#     cons 1, 2, 3, list(4, 5, 6)
O.cons = cons = (xs..., ys) ->
  for x in U.clone(xs).reverse()
    ys = Cons x, ys
  ys


# List functions
# --------------

# List each
#
#     List.each ((x) -> console.log x), list(1,2,3)
List.each = (f, xs) ->
  loop
    return if xs.isNil; f xs.head; xs = xs.tail()

# List to Array
List.toArray = (xs) ->
  ys = []; List.each ((x) -> ys.push x), xs; ys

# List length
List.len = (xs) -> n = 0; List.each (-> ++n), xs; n


# ...
# ---

# ...

# <!-- vim: set tw=70 sw=2 sts=2 et fdm=marker : -->
