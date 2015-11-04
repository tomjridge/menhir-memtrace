(** Semantic action's type. *)
type t

(** [compose x a1 a2] builds the action [let x = a1 in a2]. This
    feature is used during the processing of the %inline keyword. *)
val compose : string -> t -> t -> t

(* TEMPORARY document this: *)

type sw =
  Keyword.subject * Keyword.where

type keyword_renaming =
  string * sw * sw

(** [rename_inner keyword_renaming phi a] builds the action
    [let x1 = x1' and ... xn = xn' in a] if [phi] is [(x1, x1') ... (xn, xn')].
    Moreover, [renaming_env] is used to correctly replace $startpos/$endpos
    present in the semantic action. *)
val rename_inner:
  keyword_renaming
  -> (string * string) list -> t -> t

(** [rename_outer keyword_renaming phi a] updates the occurrences of the
    inlined non terminal in the action [a].
*)
val rename_outer:
  keyword_renaming
  -> (string * string) list -> t -> t

(** Semantic actions are translated into [IL] code using the
    [IL.ETextual] and [IL.ELet] constructors. *)
val to_il_expr: t -> IL.expr

(** A semantic action might be the inlining of several others. The
    filenames of the different parts are given by [filenames a]. This
    can be used, for instance, to check whether all parts come from
    the standard library. *)
val filenames: t -> string list

(** [pkeywords a] returns a list of all keyword occurrences in [a]. *)
val pkeywords: t -> Keyword.keyword Positions.located list

(** [keywords a] is the set of keywords used in the semantic action [a]. *)
val keywords: t -> Keyword.KeywordSet.t

(** [print f a] prints [a] to channel [f]. *)
val print: out_channel -> t -> unit

(** [from_stretch s] builds an action out of a textual piece of code. *)
val from_stretch: Stretch.t -> t

(** Check whether the keyword $syntaxerror is used in the action. *)
val has_syntaxerror: t -> bool

(** Check whether the keyword $start is used in the action. *)
val has_leftstart: t -> bool

(** Check whether the keyword $end is used in the action. *)
val has_leftend: t -> bool

