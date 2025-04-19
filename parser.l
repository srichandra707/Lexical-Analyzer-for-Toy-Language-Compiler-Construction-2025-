%{
    #include <stdio.h>
    #include <string.h>
    #include "parser.tab.h"
    extern int yywrap();
    int line_num = 1;
%}

DECIMAL       [0-9]
BINARY      [0-1]
OCTAL       [0-7]
ALPHA       [a-z]
ALPHANUMERIC [a-z0-9]
RELATIONAL_OPERATORS (=|>|<|>=|<=|<>)
%%
"//".* {}
"/*"([^*]|"*"[^/])*"*/" {}

"begin program:" {return PROGRAM_BEGIN;}
"end program" {return PROGRAM_END;}
"begin VarDecl:" {return VARDECL_BEGIN;}
"end VarDecl" {return VARDECL_END;}
"print" {return PRINT;}
"scan" {return SCAN;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"to" {return TO;}
"do" {return DO;}
"begin" {return BEGIN_BLOCK;}
"end" {return END_BLOCK;}
"inc" {return INC;}
"dec" {return DEC;}
"int" {return INT_TYPE;}
"char" {return CHAR_TYPE;}
";" {return SEMICOLON;}
"," {return COMMA;}
":" {return COLON;}
"(" {return OB;}
")" {return CB;}
"[" {return OS;}
"]" {return CS;}
"@" {return AT;}
":=" {return ASSIGN;}
"+=" {return PLUS_ASSIGN;}
"-=" {return MINUS_ASSIGN;}
"*=" {return MULT_ASSIGN;}
"/=" {return DIV_ASSIGN;}
"%=" {return MOD_ASSIGN;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"%" {return MOD;}

{RELATIONAL_OPERATORS} {return REL_OPERATORS;}
{ALPHA}({ALPHANUMERIC}|"_"{ALPHANUMERIC}|{ALPHANUMERIC}"_"{ALPHANUMERIC}|{ALPHANUMERIC}"_"|"_")* {return IDENTIFIER;}
\({DECIMAL}+,[ ]*10\) {return INT_CONST;}  
\({BINARY}+,[ ]*2\) {return INT_CONST;}  
\({OCTAL}+,[ ]*8\) {return INT_CONST;}  
\'(\\[tnsr]|[^\'])\' {return CHAR_CONST;}
\"([^\"\n]|\\\")*\" {return STRING_CONST;}
{DECIMAL}+ {return INT_LITERAL;}
[ \t\r] {;}
\n {line_num++;}
. { printf("Lexical error at line %d: Unrecognized character '%s'\n", line_num, yytext); }
%%
int yywrap(){return 1;}