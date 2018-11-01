/* Bug reported by Jan Midtgaard on 2012/09/25. */
/* The bug manifests itself when --explain is provided. */
/* Menhir says:
Warning: one state has shift/reduce conflicts.
Warning: one state has reduce/reduce conflicts.
** Internal failure (Pager's theorem).
** Tokens of interest: R_BRACKET
** Goal state: 14
*/
%{ %}

%token EOF
%token NEW
%token L_BRACKET R_BRACKET
%token ASSIGN
%token <string>INTEGER_LITERAL

%start <unit> goal    /* the entry point */
%%

goal :  assignment EOF  { }
;

primary
  :  INTEGER_LITERAL  { }
  |  array_access     { }
  ;

primary_not_name
  :  array_access                            { }
  |  NEW L_BRACKET expression R_BRACKET  { }
  ;

array_access
  :  expression L_BRACKET primary_not_name R_BRACKET  { }

expression
  :  primary             { }
  |  assignment          { }
  ;

assignment
  :  left_hand_side ASSIGN expression { }
  ;

left_hand_side
  :  primary_not_name  { }
  ;
