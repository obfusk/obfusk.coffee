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
#     neg = O.multi((x) -> 'default')
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
    else error 'no match found for multimethod'
  g.find          = find
  g.method        = (p, f) -> fs.push     p: p, f: f; g
  g.methodPre     = (p, f) -> fs.unshift  p: p, f: f; g
  g.withMethod    = (p, f) -> _multi fs.concat([p: p, f: f]), def
  g.withMethodPre = (p, f) -> _multi [p: p, f: f].concat(fs), def
  g
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
  if arguments.length == 0 then Nil() else Cons x, lazy -> list xt...


# List functions
# --------------

# List each
#
#     List.each ((x) -> console.log x), list(1,2,3)
List.each = (f, xs) ->
  loop
    return if xs.isNil; f(xs.head); xs = xs.tail()

# List to Array
List.toArray = (xs) ->
  ys = []; List.each ((x) -> ys.push x), xs; ys

# List length
List.len = (xs) -> n = 0; List.each (-> ++n), xs; n


# ...
# ---

# ...

# <!-- vim: set tw=70 sw=2 sts=2 et fdm=marker : -->
