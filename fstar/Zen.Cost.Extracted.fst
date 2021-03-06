module Zen.Cost.Extracted

open Zen.Base
open Zen.Cost.Realized

val refine_eq_in(#a:Type)(#n:nat):
    mx:cost a n
    -> cost (x:a{x == force mx}) n
let refine_eq_in #_ #_ mx =
    refine_in (fun x -> x == force mx) mx

val refine_eq_out(#a:Type)(#n:nat):
    x:a ->
    cost (y:a{y==x}) n
    -> mx:cost a n{force mx == x}
let refine_eq_out #_ #_ x mx =
    refine_out (fun y -> y == x) mx

val incRet(#a:Type): n:nat -> a -> cost a n
let incRet(#_) n x = inc n (ret x)

(** autoInc adds cost to even out branches.*)
val autoInc(#a:Type)(#m:nat)(#n:nat{m<=n}): cost a m -> cost a n
let autoInc #_ #m #n mx = inc (n-m) mx

val autoRet(#a:Type)(#m:nat): a -> cost a m
let autoRet #_ #_ = ret >> autoInc

val retf(#a #b:Type): (a -> b) -> (a -> cost b 0)
let retf #_ #_ f = f >> ret

unfold val (>>=) (#a #b:Type)(#m #n:nat):
  cost a m -> (a -> cost b n) -> cost b (m+n)
unfold let (>>=) = bind

unfold val (=<<) (#a #b:Type)(#m #n:nat):
  (a -> cost b n) -> cost a m -> cost b (m+n)
unfold let (=<<) #_ #_ #_ #_ f mx = bind mx f

val letBang(#a #b:Type)(#m #n:nat): cost a m -> (a -> cost b n) -> cost b (m+n)
let letBang = bind

(* A dependent variant of bind, useful if the function that we bind into has a refinement on it's domain *)
val bind_dep(#a #b:Type)(#m #n:nat):
    mx:cost a m
    -> (x:a{x == force mx} -> cost b n)
    -> cost b (m+n)
let bind_dep #_ #_ #_ #_ mx f =
    refine_eq_in mx `bind` f

val ifBang(#a:Type)(#m #n:nat):
    mx:cost bool m
    -> (b:bool{b = force mx} -> cost a n)
    -> cost a (m+n)
let ifBang #_ #_ #_ mx f =
    refine_eq_in mx `bind` f

val bind2(#a #b #c:Type)(#n1 #n2 #n3:nat):
  cost a n1 -> cost b n2 -> (a -> b -> cost c n3) -> cost c (n1+n2+n3)
let bind2 #_ #_ #_ #_ #_ #_ mx my f =
  mx >>= (fun x ->
  my >>= (fun y ->
  f x y))

val force_bind2(#a #b #c:Type)(#n1 #n2 #n3:nat):
  mx:cost a n1
  -> my:cost b n2
  -> f:(a -> b -> cost c n3)
  -> Lemma (force (bind2 mx my f) == force (f (force mx) (force my)))
let force_bind2 #_ #_ #_ #_ #_ #_ _ _ _ = ()

val bind3(#a #b #c #d:Type)(#n1 #n2 #n3 #n4:nat):
  cost a n1 -> cost b n2 -> cost c n3 -> (a -> b -> c -> cost d n4)
  -> cost d (n1+n2+n3+n4)
let bind3 #_ #_ #_ #_ #_ #_ #_ #_ mx my mz f =
  mx >>= (fun x ->
  my >>= (fun y ->
  mz >>= (fun z ->
  f x y z)))

val force_bind3(#a #b #c #d:Type)(#n1 #n2 #n3 #n4:nat):
  mx:cost a n1
  -> my:cost b n2
  -> mz:cost c n3
  -> f:(a -> b -> c -> cost d n4)
  -> Lemma (force (bind3 mx my mz f) == force (f (force mx) (force my) (force mz)))
let force_bind3 #_ #_ #_ #_ #_ #_ #_ #_ _ _ _ _ = ()

val join(#a:Type)(#m #n:nat): cost (cost a n) m -> cost a (m+n)
let join #_ #_ #_ x =
  x >>= (fun z -> z)

val map(#a #b:Type)(#n:nat): (a->b) -> cost a n -> cost b n
let map #_ #_ #_ f mx =
  mx >>= (f >> ret)

unfold val (<$>) (#a #b:Type)(#n:nat): (a->b) -> cost a n -> cost b n
unfold let (<$>) = map

unfold val ( $>) (#a #b:Type)(#n:nat): cost a n -> (a->b) -> cost b n
unfold let ( $>) #_ #_ #_ x f = map f x

val force_map(#a #b:Type)(#n:nat): f:(a -> b) -> mx: cost a n
  -> Lemma( f (force mx) == force (map f mx))
     [SMTPat (map f mx ); SMTPat (f <$> mx); SMTPat (mx $> f)]
let force_map #_ #_ #_ _ _ = ()

val ap(#a #b:Type)(#m #n:nat): cost (a->b) m -> cost a n -> cost b (m+n)
let ap #_ #_ #_ #_ mf mx =
  mf >>= (fun f -> map f mx)

unfold val (<*>) (#a #b:Type)(#m #n:nat): cost (a->b) m -> cost a n -> cost b (m+n)
unfold let (<*>) = ap

unfold val ( *>) (#a #b:Type)(#m #n:nat): cost a m -> cost (a->b) n -> cost b (m+n)
unfold let ( *>) #_ #b #m #n mx mf =
  ap mf mx <: cost b (n+m)

val force_ap(#a #b:Type)(#m #n:nat):
  mf:cost (a -> b) n
  -> mx: cost a m
  -> Lemma ( (force mf) (force mx) == force (ap mf mx))
     [SMTPat (ap mf mx); SMTPat (mf <*> mx)]
let force_ap #_ #_ #_ #_ _ _ = ()

val (<~>) (#a #b:Type)(#n:nat): cost (a->b) n -> a -> cost b n
let (<~>) #_ #_ #_ mf = ret >> ap mf

// The "fish". Left to right Kleisli composition of cost.
val (>=>) (#a #b #c:Type)(#m #n:nat):
  (a -> cost b m) -> (b -> cost c n) -> a -> cost c (m+n)
let (>=>) #_ #_ #_ #_ #_ f g = fun x -> f x >>= g

// Right to left Kleisli composition of cost.
val (<=<) (#a #b #c:Type)(#m #n:nat):
  (b -> cost c m) -> (a -> cost b n) -> a-> cost c (m+n)
let (<=<) #_ #_ #_ #_ #_ g f = f >=> g

val force_kleisli(#a #b #c:Type)(#m #n:nat):
    f:(a -> cost b m)
    -> g:(b -> cost c n)
    -> Lemma (forall (x:a). force ((f >=> g) x) == force (g (force (f x))))
       [SMTPat (f >=> g); SMTPat (g <=< f)]
let force_kleisli #_ #_ #_ #_ #_ _ _ = ()
