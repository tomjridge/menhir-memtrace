(* This lexer is used to read the sentences provided on the standard input
   channel when [--interpret] is enabled. *)

{

  open Lexing
  open SentenceParser
  open Grammar

  (* A short-hand. *)

  let error2 lexbuf msg =
    Error.error (Positions.two lexbuf.lex_start_p lexbuf.lex_curr_p) msg

}

let newline   = ('\010' | '\013' | "\013\010")

let whitespace = [ ' ' '\t' ';' ]

let lowercase = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']

let uppercase = ['A'-'Z' '\192'-'\214' '\216'-'\222']

let identchar = ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '0'-'9'] (* '\'' forbidden *)

let comment = '#' [^'\010''\013']* newline

let skip = newline whitespace* newline

rule lex = parse
  (* An identifier that begins with an lowercase letter is considered a
     non-terminal symbol. It should be a start symbol. *)
  | (lowercase identchar *) as lid
      { try
	  let nt = Nonterminal.lookup lid in
	  if StringSet.mem lid Front.grammar.UnparameterizedSyntax.start_symbols then
	    NONTERMINAL nt
	  else
	    error2 lexbuf (Printf.sprintf "\"%s\" is not a start symbol." lid)
	with Not_found ->
	  error2 lexbuf (Printf.sprintf "\"%s\" is not a known non-terminal symbol." lid)
      }
  (* An identifier that begins with an uppercase letter is considered a
     terminal symbol. *)
  | (uppercase identchar *) as uid
      { try
	  TERMINAL (Terminal.lookup uid)
	with Not_found ->
	  error2 lexbuf (Printf.sprintf "\"%s\" is not a known terminal symbol." uid)
      }
  (* Whitespace is ignored. *)
  | whitespace
      { lex lexbuf }
  (* The end of a line is translated to [EOL]. *)
  | newline
      { new_line lexbuf; EOL }
  (* A comment is ignored. *)
  | comment
      { new_line lexbuf; lex lexbuf }
  (* The end of file is translated to [EOF]. *)
  | eof
      { EOF }
  (* A colon. *)
  | ':'
      { COLON }
  | _
      { error2 lexbuf "unexpected character." }

