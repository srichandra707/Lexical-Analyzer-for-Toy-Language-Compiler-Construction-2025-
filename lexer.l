%{
#include <stdio.h>
#include <string.h>
int addToTable(char* text);

#define MAX_VARIABLES 100

typedef struct{
    char name[50];
    char type[4];
} variable;

variable map[MAX_VARIABLES];
int mapCount=0;
%}

%x VARDECLARATIONS

IDENTIFIER [a-z][a-z0-9]*_?[a-z0-9]*
INVALID_IDENTIFIER ([^a-z][^,]*|[a-z0-9]*_{2,}[a-z0-9]*|[a-z0-9_]*[^a-z0-9_][a-z0-9_]*) 
KEYWORD (int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec)
SEPERATOR [(|)|{|}|;|:|,|@|"|'|']
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
[ \t\n]+ {}
"begin VarDecl:" {BEGIN(VARDECLARATIONS);REJECT;}

<VARDECLARATIONS>\({KEYWORD},[ ]*("int"|"char")\); {
    printf("Error: Keyword is used as an identifier\n");
    for(int i=0;i<4;i++){yymore();printf(".\n");}
}
<VARDECLARATIONS>\({INVALID_IDENTIFIER},[ ]*("int"|"char")\);
{
    printf("Error: invalid identifier\n");
}
<VARDECLARATIONS>\({IDENTIFIER},[ ]*("int"|"char")\); {
    if(!addToTable(yytext)){
        printf("Error: Identifier already declared\n");
        for(int i=0;i<4;i++){printf(".\n");}
    }
    else{
        REJECT;
    }
}
<VARDECLARATIONS>[ \t\n]+ {}
<VARDECLARATIONS>{KEYWORD} {printf("KEYWORD\n");}
<VARDECLARATIONS>{SEPERATOR} {printf("SEPERATOR\n");}
<VARDECLARATIONS>{IDENTIFIER} {printf("IDENTIFIER\n");}

"end VarDecl" {BEGIN(0);REJECT;}
%%
int yywrap(){return 1;}
int main(){
    yyin=fopen("input.txt","r");
    if(!yyin){
        printf("Error: File not found\n");
        return 1;
    }
    yylex();
    return 0;
}
int addToTable(char* text){
    if(mapCount>=MAX_VARIABLES){
        printf("Error: Variable table full\n");
        return 0;
    }
    char varName[50],varType[4];
    if(sscanf(text,"(%[^,], %[^)])",varName,varType)!=2 ||
    (strcmp(varType, "int") != 0 && strcmp(varType, "char") != 0)){
        printf("Error: error lexing variable decl\n");
        return 0;
    }
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,varName)==0){
            return 0;
        }
    }
    strcpy(map[mapCount].name,varName);
    strcpy(map[mapCount].type,varType); 
    mapCount++;
    for(int i=0;i<mapCount;i++){
        printf("%s----%s\n",map[i].name,map[i].type);
    }
    return 1;
}