%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int validPrint(char* text,int flag);
int checkInTable(char* text);
char* findfirstOcc(char*text,int ch);
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
%x COMMENT


INVALID_IDENTIFIER ([a-z]([a-z0-9]*_)([a-z0-9]*_)+[a-z0-9]+|[^a-z].*)
IDENTIFIER [a-z][a-z0-9]*_?[a-z0-9]*

ARRAY [a-z][a-z0-9]*_?[a-z0-9]*\[[0-9]+\]
KEYWORD (int|char|if|else|then|while|for|to|do|main|begin|end|print|scan|program|VarDecl|inc|dec)
SEPERATOR [\(\)\{\};:,\"\']
ASSIGNMENT_OPERATOR (:=|(\+|-|\*|\/|%)=)
ARITHMETIC_OPERATOR (\+|-|\*|\/|%)
RELATIONAL_OPERATOR (=|>|<|>=|<=|<>)
DECIMAL \([0-9]+,[ ]*10\)
OCTAL \([0-7]+,[ ]*8\)
BINARY \([0-1]+,[ ]*2\)

PRINT_VARIABLE1 ({IDENTIFIER}|{ARRAY})
PRINT_VARIABLE2 ({DECIMAL}|{OCTAL}|{BINARY})
CHAR_CONST \'(\\[tnsr]|[a-zA-Z])\'
STRING_CONST [^\"]*
%%
{KEYWORD} {printf("%s ---------- KEYWORD\n",yytext);}
{SEPERATOR} {printf("%s ---------- SEPERATOR\n",yytext);}
{ASSIGNMENT_OPERATOR} {printf("%s ---------- ASSIGNMENT_OPERATOR\n",yytext);}
{ARITHMETIC_OPERATOR} {printf("%s ---------- ARITHMETIC_OPERATOR\n",yytext);}
{RELATIONAL_OPERATOR} {printf("%s ---------- RELATIONAL_OPERATOR\n",yytext);}
{ARRAY} {
    if(checkInTable(yytext)==0){printf("Error: undefined array\n");}
    else{printf("%s ---------- ARRAY\n",yytext);}
}
{IDENTIFIER} {
    if(checkInTable(yytext)==0){printf("Error: undefined identifier\n");}
    else{printf("%s ---------- IDENTIFIER\n",yytext);}
}
[ \t\n]+ {}
"begin VarDecl:" {printf("Entering VARDECLARATIONS STATE\n");BEGIN(VARDECLARATIONS);REJECT;}
<VARDECLARATIONS>\({KEYWORD},[ ]*("int"|"char")\); {printf("Error: Keyword is used as an identifier\n");}
<VARDECLARATIONS>\({INVALID_IDENTIFIER},[ ]*("int"|"char")\); {printf("Error: Invalid identifier\n");}
<VARDECLARATIONS>\({IDENTIFIER},[ ]*("int"|"char")\); {
    if(!addToTable(yytext)){printf("Error: Identifier already declared\n");}
    else{REJECT;}
}
<VARDECLARATIONS>\({ARRAY},[ ]*("int"|"char")\); {
if(!addToTable(yytext)){printf("Error: Array identifier already declared\n");}
else{REJECT;}
}
<VARDECLARATIONS>[ \t\n]+ {}
<VARDECLARATIONS>{KEYWORD} {printf("%s ---------- KEYWORD\n",yytext);}
<VARDECLARATIONS>{SEPERATOR} {printf("%s ---------- SEPERATOR\n",yytext);}
<VARDECLARATIONS>{IDENTIFIER} {printf("%s ---------- IDENTIFIER\n",yytext);}
<VARDECLARATIONS>{ARRAY} {printf("%s ---------- ARRAY DECLARATION\n",yytext);}
<VARDECLARATIONS>"end VarDecl" {printf("Leaving VARDECLARATIONS STATE\n");BEGIN(0);REJECT;}

"0" {printf("0 ---------- INTEGER constant\n");}
{DECIMAL} {printf("%s ---------- INTEGER constant\n",yytext);}
{OCTAL} {printf("%s ---------- INTEGER constant\n",yytext);}
{BINARY} {printf("%s ---------- INTEGER constant\n",yytext);}

\([0-9]+,[ ]*[0-9]*\) {printf("%s ---------- Error: invalid integer constant\n",yytext);}

"//"[^\n]*\n {printf("Single line comment - ignored\n");}
"//"[^\n]* {printf("Single line comment - ignored\n");}

<VARDECLARATIONS>"//"[^\n]*\n {printf("Single line comment - ignored\n");}
<VARDECLARATIONS>"//"[^\n]* {printf("Single line comment - ignored\n");}

"/*" {printf("Entering COMMENT state");BEGIN(COMMENT);}
<COMMENT>. {}
<COMMENT>"*/" {printf("Leaving COMMENT state\n");BEGIN(0);}

"scan"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\); {
    int flag=validPrint(yytext,1);
    if(flag==0){printf(" %s ---------- Error: invalid input statement because of count mismatch\n",yytext);}
    else if(flag==2){printf("%s ---------- Error: invalid input statement because of undefined vars\n",yytext);}
    else{printf("%s ---------- Valid input statement\n",yytext);}
}
"scan"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\) {
    printf("%s ---------- Error: Invalid input statement because of Missing semicolon\n",yytext);
}
"scan"\(\"{STRING_CONST}\".*\) {
    printf("%s ---------- Error: Invalid input statement because of Missing semicolon\n",yytext);
}
"scan"\(\"{STRING_CONST}\".*\); {
    printf("%s ---------- Invalid input statement\n",yytext);
}


"print"\(\"{STRING_CONST}\"\); {printf("%s ---------- Valid output statement\n",yytext);}
"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{CHAR_CONST})+\); {
    char stringy[100]="";
    char variables[100]="";
    char *s=yytext;
    s+=6;
    char *stringStart =findfirstOcc(s,'"');
    char *stringEnd =strrchr(s,'"');
    int len=stringEnd-stringStart-1;
    strncpy(stringy,stringStart+1,len);
    stringy[len]='\0';

    char* varStart =findfirstOccr(stringEnd+1,',');
    varStart++;
    char* varEnd =strrchr(varStart,')');
    int varLen=varEnd-varStart;
    strncpy(variables,varStart,varLen);
    variables[varLen]='\0';

    int count=0;
    int vars=1;
    for(char *c=stringy;*c;c++){
        if(*c=='@'){count++;}
    }
    
    for(char *c=variables;*c;c++){
        if(*c==','){
            vars++;
        }
    }
    if(count!=vars){printf("%s ---------- Error: invalid output statement because of count mismatch\n",yytext);}
    else{printf("%s ---------- Valid output statement\n",yytext);}
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE2})+\); {
    char stringy[100]="";
    char variables[100]="";
    char *s=yytext;
    s+=6;
    char *stringStart =findfirstOccr(s,'"');
    char *stringEnd =strrchr(s,'"');
    int len=stringEnd-stringStart-1;
    strncpy(stringy,stringStart+1,len);
    stringy[len]='\0';

    char* varStart =findfirstOccr(stringEnd+1,',');
    varStart++;
    char* varEnd =strrchr(varStart,')');
    int varLen=varEnd-varStart;
    strncpy(variables,varStart,varLen);
    variables[varLen]='\0';

    int count=0;
    int vars=1;    
    for(char *c=stringy;*c;c++){
        if(*c=='@'){
            count++;
        }
    }
    
    for(char *c=variables;*c;c++){
        if(*c==','){
            vars++;
        }
    }
    vars/=2;
    if(count!=vars){printf("%s ---------- Error: invalid output statement because of count mismatch\n",yytext);}
    else{printf("%s ---------- Valid output statement\n",yytext);}
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\); {
    int flag=validPrint(yytext,0);
    if(flag==0){printf(" %s ---------- Error: invalid output statement because of count mismatch\n",yytext);
    }
    else if(flag==2){printf("%s ---------- Error: invalid output statement because of undefined vars\n",yytext);}
    else{printf("%s ---------- Valid output statement\n",yytext);}
}

"print"\(\"{STRING_CONST}\"\) {
    printf("%s ---------- Error: Invalid print statement because of Missing semicolon \n\n",yytext);
}
"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{CHAR_CONST})+\) {
    printf("%s ---------- Error: Invalid print statement Missing semicolon\n",yytext);
}
"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE2})+\) {
    printf("%s ---------- Error: Invalid print statement Missing semicolon\n",yytext);
}
"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\) {
    printf("%s ---------- Error: Invalid print statement because of Missing semicolon\n",yytext);
}
"print"\(\"{STRING_CONST}\".*\) {
    printf("%s ---------- Error: Invalid print statement because of Missing semicolon\n",yytext);
}
"print"\(\"{STRING_CONST}\".*\); {
    printf("%s ---------- Invalid output statement\n",yytext);
}
%%
int yywrap(){return 1;}
int main(){
    yyin=fopen("input.txt","r");
    if(!yyin){
        printf("Error: File not found (404)\n");
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
    if(findfirstOccr(varName, '[')){
        sscanf(varName,"%[^[]",base);
    }
    else{
        strcpy(base,varName);
    }
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,base)==0){return 0;}
    }
    strcpy(map[mapCount].name,base);
    strcpy(map[mapCount].type,varType); 
    mapCount++;
    return 1;
}

int checkInTable(char* text){
    char base[50];
    if(findfirstOccr(text, '[')){
        sscanf(text,"%[^[]",base);
    }
    else{
        strcpy(base,text);
    }
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,base)==0){return 1;}
    }
    return 0;
}

int validPrint(char*text,int flag_print_scan){
    char stringy[100]="";
    char variables[100]="";
    char *s=text;
    if(flag_print_scan==0){s+=6;}
    else{s+=5;}
    char *stringStart=findfirstOccr(s,'"');
    char *stringEnd=strrchr(s,'"');
    int len=stringEnd-stringStart-1;
    strncpy(stringy,stringStart+1,len);
    stringy[len]='\0';

    char* varStart =findfirstOccr(stringEnd+1,',');
    varStart++;
    char* varEnd=strrchr(varStart,')');
    int varLen=varEnd-varStart;
    strncpy(variables,varStart,varLen);
    variables[varLen]='\0';

    int count=0;
    int vars=1;
    
    for(char *c=stringy;*c;c++){
        if(*c=='@'){
            count++;
        }
    }
    //printf("%d\n",count);
    for(char *c=variables;*c;c++){
        if(*c==','){
            vars++;
        }
    }
    //printf("%d\n",vars);
    if(count!=vars){
        return 0;
    }

    char *var=variables;
    char varBuffer[50];
    while(*var) {
        while(*var==' ') var++;
        int i = 0;
        while(*var && *var!=',' && *var!=')' && *var!=' ') {
            varBuffer[i++]=*var++;
            if(i>=49) {break;}
        }
        varBuffer[i]='\0';
        while(*var==' ' || *var==',') {var++;}
        if(strlen(varBuffer)>0) {
            if(checkInTable(varBuffer)==0) {return 2;}
        }
    }
    return 1;
}

char* findfirstOcc(char*text,int ch) {
    while(*text) {
        if(*text==(char)ch) {return (char*)text;}
        text++;
    }
    return NULL;
}
