%{
#include <stdio.h>
%}
IDENTIFIER [a-z][a-z0-9]*_?[a-z0-9]*
KEYWORD (int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec)
SEPERATOR [(|)|{|}|;|,|@|"|‘|’]
ASSIGNMENT_OPERATOR [:=|+=|-=|*=|/=|%=]
ARITHMETIC_OPERATOR [+|-|*|/|%]
RELATIONAL_OPERATOR [=|>|<|>=|<=|<>]
BASE (2|8|10)
INTEGER_CONSTANT \([0-9]+, BASE\)
%%
%%
int yywrap(){return 1;}
int main(){
    yyin=fopen("input.txt","r");
    yylex();
    return 0;
}