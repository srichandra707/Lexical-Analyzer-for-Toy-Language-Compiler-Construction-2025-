%{
#include <stdio.h>
#include <string.h>
int addToTable(char* text);
int checkInTable(char* text);
#define MAX_VARIABLES 100

typedef struct{
    char name[50];
    char type[4];
} variable;

variable map[MAX_VARIABLES];
int mapCount=0;
%}

%x VARDECLARATIONS
%x COMMENT

IDENTIFIER [a-z][a-z0-9]*_?[a-z0-9]*
ARRAY [a-z][a-z0-9]*_?[a-z0-9]*\[[0-9]+\]
INVALID_IDENTIFIER ([^a-z][^,]*|[a-z0-9]*_{2,}[a-z0-9]*|[a-z0-9_]*[^a-z0-9_][a-z0-9_]*) 
KEYWORD (int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec)
SEPERATOR [\(\)\{\};:,@\"\']
ASSIGNMENT_OPERATOR (:=|(\+|-|\*|\/|%)=)
ARITHMETIC_OPERATOR (\+|\-|\*|/|%)
RELATIONAL_OPERATOR (=|>|<|>=|<=|<>)
DECIMAL \([0-9]+,[ ]*10\)
OCTAL \([0-7]+,[ ]*8\)
BINARY \([0-1]+,[ ]*2\)

CHAR_CONST \'(\\[tnsr]|[a-zA-Z])\'
STRING_CONST \"[A-Za-z0-9+-.]+\"
%%
{KEYWORD} {printf("%s ---------- KEYWORD\n",yytext);}
{SEPERATOR} {printf("%s ---------- SEPERATOR\n",yytext);}
{ASSIGNMENT_OPERATOR} {printf("%s ---------- ASSIGNMENT_OPERATOR\n",yytext);}
{IDENTIFIER} {
    if(checkInTable(yytext)){
        printf("Error: undefined identifier\n");
    }
    else{
        printf("%s ---------- IDENTIFIER\n",yytext);
    }
}
[ \t\n]+ {}
"begin VarDecl:" {printf("Entering VARDECLARATIONS STATE\n");BEGIN(VARDECLARATIONS);REJECT;}

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
<VARDECLARATIONS>\({ARRAY},[ ]*("int"|"char")\); {
    if(!addToTable(yytext)){
        printf("Error: Array identifier already declared\n");
        for(int i=0;i<4;i++){printf(".\n");}
    }
    else{
        REJECT;
    }
}
<VARDECLARATIONS>[ \t\n]+ {}
<VARDECLARATIONS>{KEYWORD} {printf("%s ---------- KEYWORD\n",yytext);}
<VARDECLARATIONS>{SEPERATOR} {printf("%s ---------- SEPERATOR\n",yytext);}
<VARDECLARATIONS>{IDENTIFIER} {printf("%s ---------- IDENTIFIER\n",yytext);}
<VARDECLARATIONS>{ARRAY} {printf("%s ---------- ARRAY DECLARATION\n",yytext);}
<VARDECLARATIONS>"end VarDecl" {printf("Leaving VARDECLARATIONS STATE\n");BEGIN(0);REJECT;}

{IDENTIFIER}[ ]*":="[ ]*{IDENTIFIER} { 
    if(checkInTable(yytext)){
        printf("Error: Assignment to an undefined identifier\n");
    } else {
        printf("%s ---------- ASSIGNMENT STATEMENT\n", yytext);
    }
}

{IDENTIFIER}[ ]*":="[ ]*({DECIMAL}|{OCTAL}|{BINARY}) {
    if(checkInTable(yytext)){
        printf("Error: Assignment to an undefined identifier\n");
    } else {
        printf("%s ---------- ASSIGNMENT STATEMENT\n", yytext);
    }
}

"if"[ ]*"\("[ ]*{IDENTIFIER}[ ]*{RELATIONAL_OPERATOR}[ ]*({IDENTIFIER}|{DECIMAL}|{OCTAL}|{BINARY})[ ]*"\)" {
    printf("%s ---------- CONDITIONAL STATEMENT\n", yytext);
}

"while"[ ]*"\("[ ]*{IDENTIFIER}[ ]*{RELATIONAL_OPERATOR}[ ]*({IDENTIFIER}|{DECIMAL}|{OCTAL}|{BINARY})[ ]*"\)" {
    printf("%s ---------- LOOP STATEMENT\n", yytext);
}

"for"[ ]*"\("[ ]*{IDENTIFIER}[ ]*":="[ ]*({DECIMAL}|{IDENTIFIER})[ ]*";"[ ]*{IDENTIFIER}[ ]*{RELATIONAL_OPERATOR}[ ]*({DECIMAL}|{IDENTIFIER})[ ]*";"[ ]*{IDENTIFIER}[ ]*(\+\+|--)[ ]*"\)" {
    printf("%s ---------- FOR LOOP STATEMENT\n", yytext);
}

{DECIMAL} {printf("%s ---------- INTEGER constant\n",yytext);}
{OCTAL} {printf("%s ---------- INTEGER constant\n",yytext);}
{BINARY} {printf("%s ---------- INTEGER constant\n",yytext);}

\([0-9]+,[ ]*[0-9]*\) {printf("Error: invalid integer constant\n");}

"//".*\n {printf("Single line comment - ignored");}
"/*" {printf("Entering COMMENT state");BEGIN(COMMENT);}
<COMMENT>. {}
<COMMENT>"*/" {printf("Leaving COMMENT state\n");BEGIN(0);}
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

    char base[50];
    if(strchr(varName, '[')){
        sscanf(varName,"%[^[]",base);
    }
    else{
        strcpy(base,varName);
    }
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,base)==0){
            return 0;
        }
    }
    strcpy(map[mapCount].name,base);
    strcpy(map[mapCount].type,varType); 
    mapCount++;
    return 1;
}

int checkInTable(char* text){
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,text)==0){
            return 0;
        }
    }
    return 1;
}
