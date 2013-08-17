# --                                                            ; {{{1
#
# File        : obfusk_spec.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-16
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

U = require 'underscore'
O = require '../src/obfusk.coffee'

describe 'misc.titleCase', ->                                   # {{{1
  f = O.misc.titleCase
  it 'changes Foo to Foo', -> expect(f 'Foo').toBe 'Foo'
  it 'changes FOO to FOO', -> expect(f 'FOO').toBe 'FOO'
  it 'changes fOo to FOo', -> expect(f 'fOo').toBe 'FOo'
  it 'changes foo to Foo', -> expect(f 'foo').toBe 'Foo'
                                                                # }}}1

describe 'qw', ->
  a = ['foo bar,baz', 'qux,,q2x  q3x , q4x, q5x ,q6x']
  b = ['foo', 'bar', 'baz', 'qux', 'q2x', 'q3x', 'q4x', 'q5x', 'q6x']
  it 'splits w/ commas and multiple arguments',
    -> expect(O.qw a...).toEqual b

describe 'error', ->
  it 'throws an Error', -> expect(-> O.error 'foo').toThrow('foo')

describe 'flen + fsetlen + frev', ->                            # {{{1
  f = (a,b,c) -> [a,b,c]
  it 'frev reverses the arguments of a function', ->
    expect(O.frev(f) 1,2,3).toEqual [3,2,1]
  it 'flen of frev is same as original', ->
    expect(O.flen f)          .toBe 3
    expect(O.flen (O.frev f)) .toBe 3
                                                                # }}}1

describe 'flip', ->
  it 'flips the first two args', ->
    expect(O.flip((x,y,z) -> [x,y,z]) 2, 1, 3).toEqual [1,2,3]

describe 'fix', ->                                              # {{{1
  f = (a,b,c = 3) -> [a,b,c]
  g = O.fix f, 2
  it 'fails w/ too few arguments', ->
    expect(-> g 1).toThrow('fix: #args != 2')
  it 'fails w/ too many arguments', ->
    expect(-> g 1, 2, 3).toThrow('fix: #args != 2')
  it 'succeeds w/ right number of rguments', ->
    expect(g 1, 2).toEqual [1,2,3]
                                                                # }}}1

describe 'curry', ->                                            # {{{1
  f = (a,b,c,d=88,e=99) -> [a,b,c,d,e]
  a = O.curry f
  b = O.curry f, 4
  c = O.curry f, null, true
  d = O.rcurry f

  it 'curries one at a time w/ n = length', ->
    expect(a(1)(2)(3)(4)(5)).toEqual [1,2,3,4,5]
  it 'curries one at a time w/ n = 4', ->
    expect(b(1)(2)(3)(4)).toEqual [1,2,3,4,99]
  it 'curries one at a time, stictly', ->
    expect(c(1)(2)(3)(4)(5)).toEqual [1,2,3,4,5]
  it 'succeeds w/ more at a time', ->
    expect(a(1,2)(3)(4,5)).toEqual [1,2,3,4,5]
  it 'succeeds w/ no args to finish', ->
    expect(a(1,2)(3)()).toEqual [1,2,3,88,99]
  it 'fails when strict and not one at a time', ->
    expect(-> c(1)(2,3)).toThrow 'curry: unary function'

  describe 'rcurry', ->
    it 'reverses the arguments', ->
      expect(d(1,2)(3)(4,5)).toEqual [5,4,3,2,1]
                                                                # }}}1

describe 'partial', ->
  f = (a,b,c,d,e=99) -> [a,b,c,d,e]
  g = O.partial f, 1, 2
  it 'partially applies arguments from the left', ->
    expect(g 3, 4).toEqual [1,2,3,4,99]

describe 'rpartial', ->                                         # {{{1
  f = (a,b,c,d,e=99) -> [a,b,c,d,e]
  g = O.rpartial f, 3, 4, 88
  h = O.rpartial (O.fix f, 4), 3, 4
  it 'partially applies arguments from the right', ->
    expect(g 1, 2).toEqual [1,2,3,4,88]
  it 'works nicely with fix', ->
    expect(h 1, 2).toEqual [1,2,3,4,99]
                                                                # }}}1

describe 'compose', ->                                          # {{{1
  f = (x) -> x + 42
  g = (x) -> x * 2
  h = (a,b,c) -> a + b + c
  it 'composes functions', ->
    expect(O.compose(f,g,h)(1,2,3)).toBe 54
                                                                # }}}1

describe 'pipeline', ->                                         # {{{1
  f = (x,y) -> [x,y]
  g = (x) -> U.clone(x).reverse()
  h = (x) -> [1].concat x
  it 'piplelines functions', ->
    expect(O.pipeline(f,g,h)(42,37)).toEqual [1,37,42]
                                                                # }}}1

describe 'iterate', ->                                          # {{{1
  len = (xs) ->
    O.iterate (recur, ys = xs, n = 0) ->
      O.match ys, Nil: (-> n), Cons: ((x) -> recur ys.tail(), n+1)
  it 'loops over a list', ->
    expect(len O.list 1, 2, 3).toBe 3
                                                                # }}}1

describe 'overload', ->                                         # {{{1
  f = O.overload (()              -> 1),
                 ((x)             -> x),
                 ((x, y)          -> x + y),
                 ((x, y, args...) -> f (f x, y), args...)

  it 'works w/ 0 args passed', expect(f())            .toBe 1
  it 'works w/ 1 args passed', expect(f 42)           .toBe 42
  it 'works w/ 2 args passed', expect(f 7, 16)        .toBe 23
  it 'works w/ 3 args passed', expect(f 6, 7, 8)      .toBe 21
  it 'works w/ 5 args passed', expect(f 1, 1, 2, 3, 5).toBe 12
                                                                # }}}1

describe 'multi', ->                                            # {{{1
  neg = O.multi((x) -> 'default')
    .method ((x) -> typeof x == 'number'),
            ((x) -> -x)
    .method ((x) -> typeof x == 'boolean'),
            ((x) -> !x)
    .methodPre ((x) -> x == 37),
               ((x) -> 73)
  neg2 = neg
    .withMethod ((x) -> x == 42),
                ((x) -> 'not the answer')
    .withMethod ((x) -> typeof x == 'string'),
                ((x) -> '-' + x)
  neg3 = neg
    .withMethodPre ((x) -> x == 42),
                   ((x) -> 'not the answer')

  it 'w/ number'        , -> expect(neg 42)     .toBe -42
  it 'w/ boolean'       , -> expect(neg false)  .toBe true
  it 'w/ default'       , -> expect(neg 'oops') .toBe 'default'
  it 'w/ methodPre'     , -> expect(neg 37)     .toBe 73
  it 'w/ withMethod ign', -> expect(neg2 42)    .toBe -42
  it 'w/ withMethod ok' , -> expect(neg2 'foo') .toBe '-foo'
  it 'w/ withMethodPre' , -> expect(neg3 42)    .toBe 'not the answer'
                                                                # }}}1

describe 'lazy', ->                                             # {{{1
  a = O.lazy 42
  b = O.lazy -> 42
  c = O.lazy a

  it 'w/ scalar'        , -> expect(a()).toBe 42
  it 'w/ function'      , -> expect(b()).toBe 42
  it 'w/ lazy'          , -> expect(c()).toBe 42
  it 'keeps lazy as-is' , -> expect(c).toBe(a)

  it 'is identified as lazy', ->
    expect(O.isLazy a).toBe true
    expect(O.isLazy b).toBe true
    expect(O.isLazy c).toBe true

  describe 'lazyness', ->
    x = null; d = null
    beforeEach ->
      x = []; d = O.lazy -> x.push 'thunk!'; 42

    it 'is lazy', ->
      v1 = d(); v2 = d(); v3 = d()
      expect([v1,v2,v3]).toEqual [42,42,42]
      expect(x.length).toBe 1
                                                                # }}}1

describe 'Maybe', ->                                            # {{{1
  f =
    Nothing: -> 'Nothing'
    Just: (x) -> "Value: #{x.value}"
  x = O.Nothing()
  y = O.Just(42)

  describe 'Nothing', ->
    it 'ctor'       , -> expect(x.ctor)       .toBe 'Nothing'
    it 'type'       , -> expect(x.type)       .toBe O.Maybe
    it '!isJust'    , -> expect(x.isJust)     .toBe false
    it 'isNothing'  , -> expect(x.isNothing)  .toBe true

  describe 'Just', ->
    it 'value'      , -> expect(y.value)      .toBe 42
    it 'ctor'       , -> expect(y.ctor)       .toBe 'Just'
    it 'type'       , -> expect(y.type)       .toBe O.Maybe
    it 'isJust'     , -> expect(y.isJust)     .toBe true
    it '!isNothing' , -> expect(y.isNothing)  .toBe false

  describe 'match', ->
    a = O.match x, f
    b = O.match y, f
    c = O.match_(f) y

    it 'Nothing'    , -> expect(a)            .toBe 'Nothing'
    it 'Just'       , -> expect(b)            .toBe 'Value: 42'
    it 'Just (_)'   , -> expect(c)            .toBe 'Value: 42'

  describe 'monad', ->
    a = O.mbind O.Nothing(), (-> O.error 'oops')
    b = O.mbind O.Just(42), (-> O.Nothing())
    c = O.mbind O.Just(42), ((x) -> O.Just x + 1)

    it 'N >== ? == N'   , -> expect(a.isNothing).toBe true
    it 'J >== ->N == N' , -> expect(b.isNothing).toBe true
    it 'J >== ->J == J' , -> expect(c.isJust).toBe true
    it 'J >== ->J has correct value',
      -> expect(c.value).toBe 43
                                                                # }}}1

describe 'Either', ->                                           # {{{1
  f =
    Left:  (x) -> "L: #{x.value}"
    Right: (x) -> "R: #{x.value}"
  x = O.Left(42)
  y = O.Right(37)

  describe 'match', ->
    a = O.match x, f
    b = O.match y, f

    it 'Left' , -> expect(a).toBe 'L: 42'
    it 'Right', -> expect(b).toBe 'R: 37'
                                                                # }}}1

describe 'List', ->                                             # {{{1
  f =
    Nil: -> 'Nil'
    Cons: (x) -> O.List.toArray(x).join ', '
  x = O.Nil()
  y = O.Cons(42, O.list(99))
  z = O.list(U.range(10)...)

  a = O.cons(1,2,3,z)
  b = [1,2,3].concat U.range 10

  it 'toArray', -> expect(O.List.toArray z) .toEqual U.range(10)
  it 'length' , -> expect(O.List.len z)     .toBe 10
  it 'cons',    -> expect(O.List.toArray a) .toEqual b

  describe 'match', ->
    c = O.match x, f
    d = O.match y, f

    it 'Nil' , -> expect(c).toBe 'Nil'
    it 'Cons', -> expect(d).toBe '42, 99'
                                                                # }}}1

# ...

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
