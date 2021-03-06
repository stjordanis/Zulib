#light "off"
module Zen.Cost.Realized

type cost<'Aa, 'An> =
  | C of Lazy<'Aa>

type t<'Aa, 'An> = cost<'Aa, 'An>

let __force ( C x : cost<'Aa, 'An> ) : 'Aa = x.Value

let uu___is_C ( _: Prims.nat)
              ( _: cost<'Aa, Prims.unit> ) = true

let __proj__C__item__inj ( _: Prims.nat)
                         ( C x : cost<'Aa, Prims.unit>)
                         : 'Aa = x.Value

let ret ( x : 'Aa) : cost<'Aa, Prims.unit> = C (lazy x)

let bind ( _: Prims.nat)
         ( _: Prims.nat)
         ( C x : cost<'Aa, Prims.unit> )
         ( f : 'Aa ->  cost<'Ab, Prims.unit> )
         : cost<'Ab, Prims.unit> =
    lazy ( x.Value |> f |> __force)
    |> C

let inc ( _: Prims.nat)
        ( _: Prims.nat )
        ( mx : cost<'Aa, Prims.unit> )
        : cost<'Aa, Prims.unit> = mx

let force ( _: Prims.nat)
          ( _: cost<'Aa, Prims.unit> ) : 'Aa =
          failwith "force is not allowed in executable code."

let refine_in (_:Prims.nat)
              (_:Prims.unit)
              (x: cost<'A, Prims.unit>)
              : cost<'A, Prims.unit> = x

let refine_out (_:Prims.nat)
               (_:Prims.unit)
               (x: cost<'A, Prims.unit>)
               : cost<'A, Prims.unit> = x

let left_id ( _: Prims.nat)
            ( _: 'Aa)
            ( _: 'Aa -> cost<'Ab, Prims.unit> )
            : Prims.unit = ()

let right_id ( _: Prims.nat)
             ( _: cost<'Aa, Prims.unit> )
             : Prims.unit = ()

let assoc ( _: Prims.nat)
          ( _: Prims.nat)
          ( _: Prims.nat)
          ( _: cost<'Aa, Prims.unit> )
          ( _: 'Aa -> cost<'Ab, Prims.unit> )
          ( _: 'Ab -> cost<'Ac, Prims.unit> )
          : Prims.unit = ()

let force_ret ( _: 'Aa) : Prims.unit = ()

let force_inc ( _: Prims.nat)
              ( _: Prims.nat)
              ( _: cost<'Aa, Prims.unit> )
              : Prims.unit = ()

let force_bind ( _: Prims.nat)
               ( _: Prims.nat)
               ( _: cost<'Aa, Prims.unit> )
               ( _: 'Aa -> cost<'Ab, Prims.unit> )
               : Prims.unit = ()

let force_bind_inc ( _: Prims.nat)
                   ( _: Prims.nat)
                   ( _: cost<'Aa, Prims.unit> )
                   ( _: 'Aa -> cost<'Ab, Prims.unit> )
                   : Prims.unit = ()
