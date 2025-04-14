%{
#include <stdio.h>
#include <string.h>
#include "test.tab.h"  /* Include the Bison-generated header */

int line_num = 1;
%}

%option noyywrap
%option yylineno

/* Regular expressions for token patterns */
DIGIT       [0-9]
BINARY      [0-1]
OCTAL       [0-7]
ALPHA       [a-z]
ALPHANUMERIC [a-z0-9]
WHITESPACE  [ \t\r]
NEWLINE     \n

%%

"//".*                { /* Skip single-line comments - don't return a token */ }
"/*"([^*]|"*"[^/])*"*/" { /* Skip multi-line comments - don't return a token */ }

"begin program:"       { return PROGRAM_BEGIN; }
"end program"         { return PROGRAM_END; }
"begin VarDecl:"      { return VARDECL_BEGIN; }
"end VarDecl"         { return VARDECL_END; }
"print"               { return PRINT; }
"scan"                { return SCAN; }
"if"                  { return IF; }
"else"                { return ELSE; }
"while"               { return WHILE; }
"for"                 { return FOR; }
"to"                  { return TO; }
"do"                  { return DO; }
"begin"               { return BEGIN_BLOCK; }
"end"                 { return END_BLOCK; }
"inc"                 { return INC; }
"dec"                 { return DEC; }
"int"                 { return INT_TYPE; }
"char"                { return CHAR_TYPE; }

";"                   { return SEMICOLON; }
","                   { return COMMA; }
":"                   { return COLON; }
"("                   { return LPAREN; }
")"                   { return RPAREN; }
"["                   { return LBRACKET; }
"]"                   { return RBRACKET; }
"@"                   { return AT; }

":="                  { return ASSIGN; }
"+="                  { return PLUS_ASSIGN; }
"-="                  { return MINUS_ASSIGN; }
"*="                  { return MULT_ASSIGN; }
"/="                  { return DIV_ASSIGN; }
"%="                  { return MOD_ASSIGN; }

"+"                   { return PLUS; }
"-"                   { return MINUS; }
"*"                   { return MULT; }
"/"                   { return DIV; }
"%"                   { return MOD; }

"="                   { return EQ; }
">"                   { return GT; }
"<"                   { return LT; }
">="                  { return GE; }
"<="                  { return LE; }
"<>"                  { return NE; }

{ALPHA}({ALPHANUMERIC}|"_"{ALPHANUMERIC}|{ALPHANUMERIC}"_"{ALPHANUMERIC}|{ALPHANUMERIC}"_"|"_")* { 
    return IDENTIFIER; 
}

\({DIGIT}+,{WHITESPACE}{DIGIT}+\)    { return INT_CONST; }  /* For (value,base) format */


\'[^\']\'             { return CHAR_CONST; }
\"[^\"]*\"            { return STRING_CONST; }

{WHITESPACE}          { /* Ignore whitespace */ }
{NEWLINE}             { line_num++;}

.                     { printf("Lexical error at line %d: Unrecognized character '%s'\n", line_num, yytext); }

%%
