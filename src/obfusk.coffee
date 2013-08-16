# --                                                            ; {{{1
#
# File        : obfusk.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

U = this._ || require 'underscore'
O = exports ? this.obfusk ||= {}
misc = O.misc ||= {}

# --

misc.titleCase = titleCase = (x) ->
  x.charAt(0).toUpperCase() + x.substr 1

O.qw = qw = (xs...) ->
  xs.join(' ').replace(/,/g,' ').split(/\s+/)

# --

O.isLazy = isLazy = (x) -> x.lazy == lazy

O.lazy = lazy = (x) ->                                          # {{{1
  return x if isLazy x
  f = if U.isFunction x then x else -> x
  v = null; e = false
  g = -> (v = f(); e = true) unless e; v
  g.lazy = lazy; g
                                                                # }}}1

# --

O.data = data = (ctors = {}) ->                                 # {{{1
  type = {}
  for k, v of ctors
    do (v, o = { ctor: k }) ->
      for k2, v2 of ctors
        o["is#{titleCase k2}"] = k == k2
      type[k] = -> U.extend {}, v(arguments...), o
  type.match = (x, f = {}) -> f[x.ctor]? x
  type.type = type; type
                                                                # }}}1

# --

O.Maybe = Maybe = data
  Nothing: -> {}
  Just: (x) -> { value: x }

O.Nothing = Nothing = Maybe.Nothing
O.Just    = Just    = Maybe.Just

# --

O.Either = Either = data
  Left:  (x) -> { value: x }
  Right: (x) -> { value: x }

O.Left  = Left  = Either.Left
O.Right = Right = Either.Right

# --

O.List = List = data
  Nil: -> {}
  Cons: (h, t) -> { head: h, tail: lazy t }

O.Nil   = Nil   = List.Nil
O.Cons  = Cons  = List.Cons

# --

O.list = list = (x, xt...) ->
  if arguments.length == 0 then Nil() else Cons x, lazy -> list xt...

List.each = (f, xs) ->
  loop
    return if xs.isNil; f(xs.head); xs = xs.tail()

List.toArray = (xs) ->
  ys = []; List.each ((x) -> ys.push x), xs; ys

List.len = (xs) -> n = 0; List.each (-> ++n), xs; n

# --

# ...

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
