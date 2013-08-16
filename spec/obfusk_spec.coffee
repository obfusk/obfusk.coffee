# --                                                            ; {{{1
#
# File        : obfusk_spec.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

U = require 'underscore'
O = require '../src/obfusk.coffee'

describe 'misc.titleCase', ->                                   # {{{1
  f = O.misc.titleCase
  it 'Foo -> Foo', -> expect(f 'Foo').toBe 'Foo'
  it 'FOO -> FOO', -> expect(f 'FOO').toBe 'FOO'
  it 'fOo -> FOo', -> expect(f 'fOo').toBe 'FOo'
  it 'foo -> Foo', -> expect(f 'foo').toBe 'Foo'
                                                                # }}}1

describe 'qw', ->
  a = ['foo bar,baz', 'qux,,q2x  q3x , q4x, q5x ,q6x']
  b = ['foo', 'bar', 'baz', 'qux', 'q2x', 'q3x', 'q4x', 'q5x', 'q6x']
  it 'works', -> expect(O.qw a...).toEqual b

describe 'lazy', ->                                             # {{{1
  a = O.lazy 42
  b = O.lazy -> 42
  c = O.lazy a

  it 'scalar'     , -> expect(a()).toBe 42
  it 'function'   , -> expect(b()).toBe 42
  it 'lazy'       , -> expect(c()).toBe 42

  it 'no 2x lazy' , -> expect(c).toBe(a)

  it 'isLazy', ->
    expect(O.isLazy(a)).toBe true
    expect(O.isLazy(b)).toBe true
    expect(O.isLazy(c)).toBe true

  describe 'lazyness', ->
    x = null; d = null
    beforeEach ->
      x = []; d = O.lazy -> x.push 'thunk!'; 42

    it 'is lazy', ->
      v1 = d(); v2 = d(); v3 = d()
      expect([v1,v2,v3]).toEqual [42,42,42]
      expect(x.length).toBe 1
                                                                # }}}1

describe 'data', ->
  describe 'Maybe', ->                                          # {{{1
    f =
      Nothing: -> 'Nothing'
      Just: (x) -> "Value: #{x.value}"
    x = O.Maybe.Nothing()
    y = O.Maybe.Just(42)

    describe 'Nothing', ->
      it 'ctor'       , -> expect(x.ctor)       .toBe 'Nothing'
      it '!isJust'    , -> expect(x.isJust)     .toBe false
      it 'isNothing'  , -> expect(x.isNothing)  .toBe true

    describe 'Just', ->
      it 'value'      , -> expect(y.value)      .toBe 42
      it 'ctor'       , -> expect(y.ctor)       .toBe 'Just'
      it 'isJust'     , -> expect(y.isJust)     .toBe true
      it '!isNothing' , -> expect(y.isNothing)  .toBe false

    describe 'match', ->
      a = O.Maybe.match x, f
      b = O.Maybe.match y, f

      it 'Nothing'    , -> expect(a)            .toBe 'Nothing'
      it 'Just'       , -> expect(b)            .toBe 'Value: 42'
                                                                # }}}1
  describe 'Either', ->                                         # {{{1
    f =
      Left:  (x) -> "L: #{x.value}"
      Right: (x) -> "R: #{x.value}"
    x = O.Either.Left(42)
    y = O.Either.Right(37)

    describe 'match', ->
      a = O.Either.match x, f
      b = O.Either.match y, f

      it 'Left' , -> expect(a).toBe 'L: 42'
      it 'Right', -> expect(b).toBe 'R: 37'
                                                                # }}}1
  describe 'List', ->                                           # {{{1
    f =
      Nil: -> 'Nil'
      Cons: (x) -> O.List.toArray(x).join ', '
    x = O.List.Nil()
    y = O.List.Cons(42, O.list(99))
    z = O.list(U.range(10)...)

    it 'toArray', -> expect(O.List.toArray(z)).toEqual U.range(10)
    it 'length' , -> expect(O.List.len(z)).toBe 10

    describe 'match', ->
      a = O.Either.match x, f
      b = O.Either.match y, f

      it 'Nil' , -> expect(a).toBe 'Nil'
      it 'Cons', -> expect(b).toBe '42, 99'
                                                                # }}}1

# ...

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
