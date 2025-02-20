%{
#include <stdio.h>
int addToTable(char* text);
%}

%x VARDECLARATIONS

IDENTIFIER [a-z][a-z0-9]*_?[a-z0-9]*
KEYWORD (int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec)
SEPERATOR [(|)|{|}|;|,|@|"|'|']
ASSIGNMENT_OPERATOR [:=|+=|-=|*=|/=|%=]
ARITHMETIC_OPERATOR [+|-|*|/|%]
RELATIONAL_OPERATOR [=|>|<|>=|<=|<>]
DECIMAL \([0-9]+, 10\)
OCTAL \([0-7]+, 8\)
BINARY \([0-1]+, 2\)

CHAR_CONST \'(\\[tnsr]|[a-zA-Z])\'
STRING_CONST \"[A-Za-z0-9+-.]+\"
%%
{KEYWORD} {printf("KEYWORD\n");}
{SEPERATOR} {printf("SEPERATOR\n");}

"begin VarDecl:" {BEGIN(VARDECLARATIONS);REJECT;}
<VARDECLARATIONS>{KEYWORD} {printf("KEYWORD\n");}
<VARDECLARATIONS>{SEPERATOR} {printf("SEPERATOR\n");}
<VARDECLARATIONS>{IDENTIFIER} {printf("IDENTIFIER\n");}
<VARDECLARATIONS>\({KEYWORD},("int"|"char")\); {
    printf("Error: Keyword is used as an identifier");
    for(int i=0;i<4;i++){yyinput();printf(".\n");}
}
<VARDECLARATIONS>\({IDENTIFIER},("int"|"char")\); {
    if(addToTable(yytext)==0){
        printf("Error: Identifier already declared");
        for(int i=0;i<4;i++){yyinput();printf(".\n");}
    }
    else{
        REJECT;
    }
}
"end VarDecl" {BEGIN(0);REJECT;}
%%
int yywrap(){return 1;}
int main(){
    yyin=fopen("input.txt","r");
    yylex();
    return 0;
}
int addToTable(char* text){
    
}