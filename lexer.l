%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
int addToTable(char* text);
int checkInTable(char* text);
int validPrint(char* text,int flag);
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
    if(checkInTable(yytext)==0){
        printf("Error: undefined array\n");
    }
    else{
        printf("%s ---------- ARRAY\n",yytext);
    }
}
{IDENTIFIER} {
    if(checkInTable(yytext)==0){
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
}
<VARDECLARATIONS>\({INVALID_IDENTIFIER},[ ]*("int"|"char")\); {
    printf("Error: Invalid identifier\n");
}
<VARDECLARATIONS>\({IDENTIFIER},[ ]*("int"|"char")\); {
    if(!addToTable(yytext)){
        printf("Error: Identifier already declared\n");
    }
    else{
        REJECT;
    }
}

<VARDECLARATIONS>\({ARRAY},[ ]*("int"|"char")\); {
    if(!addToTable(yytext)){
        printf("Error: Array identifier already declared\n");
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
    char*s=yytext;
    s+=5;
    char *start=s;
    while(*start!='"'){start++;}
    char *end=start+1;
    while(*end!='"'){end++;}
    int len=end-start-1;
    s=start+1;
    int commacounter=0;
    int atcounter=0;
    int checkFlag=0;
    while(s!=end){
        if(*s!='@' && *s!=',' && *s!=' '){
            checkFlag=1;
            break;
        }
        if(*s==','){
            commacounter++;
        }
        if(*s=='@'){
            atcounter++;
            //printf("atcounter: %d\n",atcounter);
        }
        s++;
    }
    if(commacounter!=atcounter-1){
        //printf("commacounter: %d, atcounter: %d\n",commacounter,atcounter);
        checkFlag=1;
    }
    if(checkFlag==0){
        int flag=validPrint(yytext,1);
        if(flag==0){
            printf(" %s ---------- Error: invalid input statement because of count mismatch\n",yytext);
        }
        else if(flag==2){
            printf("%s ---------- Error: invalid input statement because of undefined vars\n",yytext);
        }
        else{
            printf("%s ---------- Valid input statement\n",yytext);
        }
    }
    else{
        printf("%s ---------- Error: invalid input statement\n",yytext);
    }
}


"scan"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\) {
    printf("%s ---------- Error: Missing semicolon in input statement\n",yytext);
}


"scan"\(\"{STRING_CONST}\".*\) {
    printf("%s ---------- Error: Missing semicolon in input statement\n",yytext);
}

"scan"\(\"{STRING_CONST}\".*\); {
    printf("%s ---------- Invalid input statement\n",yytext);
}
"scan"\(.*\); {
    printf("%s ---------- Invalid input statement\n",yytext);
}

"print"\(\"{STRING_CONST}\"\); {printf("%s ---------- Valid output statement\n",yytext);}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{CHAR_CONST})+\); {
    char *s=yytext;

    s+=6;
    char *start=s;
    while(*start!='"'){start++;}
    char *ends=start+1;
    while(*ends!='"'){ends++;}
    int len=ends-start-1;
    s=start+1;
    int atcounter=0;
    int commacounter=0;
    char*vstart=ends+1;
    char*vends=vstart+1;
    while(*vends!=')'){vends++;}
    int vlen=vends-vstart-1;
    char*v=vstart;

    while(s!=ends){
        if(*s=='@'){
            atcounter++;
        }
        s++;
    }
    while(v!=vends){
        if(*v==','){
            commacounter++;
        }
        v++;
    }
    if(atcounter!=commacounter){
        printf("%s ---------- Error: invalid output statement because of count mismatch\n",yytext);
    }
    else{
        printf("%s ---------- Valid output statement\n",yytext);
    }
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE2})+\); {
    char *s=yytext;

    s+=6;
    char *start=s;
    while(*start!='"'){start++;}
    char *ends=start+1;
    while(*ends!='"'){ends++;}
    int len=ends-start-1;
    s=start+1;
    int atcounter=0;
    int commacounter=0;
    char*vstart=ends+1;
    char*vends=vstart+1;
    while(*vends!=')'){vends++;}
    int vlen=vends-vstart-1;
    char*v=vstart;

    while(s!=ends){
        if(*s=='@'){
            atcounter++;
        }
        s++;
    }
    while(v!=vends){
        if(*v==','){
            commacounter++;
        }
        v++;
    }
    commacounter/=2;   
    if(atcounter!=commacounter){
        printf("%s ---------- Error: invalid output statement because of count mismatch\n",yytext);
    }
    else{
        printf("%s ---------- Valid output statement\n",yytext);
    }
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\); {
    int flag=validPrint(yytext,0);
    if(flag==0){
        printf(" %s ---------- Error: invalid output statement because of count mismatch\n",yytext);
    }
    else if(flag==2){
        printf("%s ---------- Error: invalid output statement because of undefined vars\n",yytext);
    }
    else{
        printf("%s ---------- Valid output statement\n",yytext);
    }
}

"print"\(\"{STRING_CONST}\"\) {
    printf("%s ---------- Error: Missing semicolon in print statement\n",yytext);
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{CHAR_CONST})+\) {
    printf("%s ---------- Error: Missing semicolon in print statement\n",yytext);
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE2})+\) {
    printf("%s ---------- Error: Missing semicolon in print statement\n",yytext);
}

"print"\(\"{STRING_CONST}\"[ ]*(,[ ]*{PRINT_VARIABLE1})+\) {
    printf("%s ---------- Error: Missing semicolon in print statement\n",yytext);
}


"print"\(\"{STRING_CONST}\".*\) {
    printf("%s ---------- Error: Missing semicolon in print statement\n",yytext);
}

"print"\(\"{STRING_CONST}\".*\); {
    printf("%s ---------- Invalid output statement\n",yytext);
}
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
        printf("Error: var table full\n");
        return 0;
    }
    char varName[50],varType[5];
    char*s=text;
    s+=1;
    while(*s==' '){s++;}
    char*varstart=s;
    while(*s!=','){s++;}
    char*varend=s;
    int len=varend-varstart;
    strncpy(varName,varstart,len);
    varName[len]='\0';
    s++;
    while(*s==' '){s++;}
    char*typestart=s;
    while(*s!=')'){s++;}
    char*typeend=s;
    int typelen=typeend-typestart;
    strncpy(varType,typestart,typelen);
    varType[typelen]='\0';
    if(strcmp(varType, "int") != 0 && strcmp(varType, "char") != 0){
        printf("Error: error lexing variable decl\n");
        return 0;
    }


    char base[50];
    int arrayflag=0;
    s=varName;
    while(*s!='\0'){
        if(*s=='['){
            arrayflag=1;
            break;
        }
        s++;
    }
    if(arrayflag==1){
        int arrlen=s-1-varstart+1;
        strncpy(base,varstart,arrlen);
        base[arrlen]='\0';
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
    //printf("%s %s\n",map[mapCount].name,map[mapCount].type);
    mapCount++;
    return 1;
}

int checkInTable(char* text){
    char base[50];
    if(strchr(text, '[')){
        sscanf(text,"%[^[]",base);
    }
    else{
        strcpy(base,text);
    }
    for(int i=0;i<mapCount;i++){
        if(strcmp(map[i].name,base)==0){
            return 1;
        }
    }
    return 0;
}

int validPrint(char*text,int flag_print_scan){
    char stringy[100]="";
    char variables[100]="";
    char *s=text;
    if(flag_print_scan==0){s+=6;}
    else{s+=5;}
    char *start=s;
    while(*start!='"'){start++;}
    char *end=start+1;
    while(*end!='"'){end++;}
    int len=end-start-1;
    strncpy(stringy,start+1,len);
    stringy[len]='\0';
    //printf("stringy: %s\n",stringy);
    s=start+1;

    int atcounter=0;
    int commacounter=0;

    while(s!=end){
        if(*s=='@'){
            atcounter++;
        }
        s++;
    }

    char*varstart=end+1;
    char*varend=varstart+1;
    while(*varend!=')'){varend++;}
    //printf("varstart:%s varend:%s\n",varstart,varend);
    int varlen=varend-varstart;
    strncpy(variables,varstart,varlen);
    variables[varlen]='\0';
    //printf("variables:%s\n",variables);
    char*v=varstart;
    while(v!=varend){
        if(*v==','){
            commacounter++;
        }
        v++;
    }
    
    //printf("%d\n",vars);
    if(commacounter!=atcounter){
        return 0;
    }

    char*var=variables;
    //printf("var:%s\n",var);
    char varBuffer[50];

    while(*var!='\0'){
        while(*var==' '){var++;}
        //printf("var place 2:%s\n",var);
        int i=0;
        while(*var && *var!=',' && *var!=')' && *var!=' ') {
            varBuffer[i++]=*var++;
            //printf("varBuffer:%s\n",varBuffer);
            if(i>=49){
                break;
            }
        }
        varBuffer[i]='\0';
        while(*var==' '||*var==','){var++;}
        //printf("var place 3:%s\n",var);

        if(strlen(varBuffer)>0){
            if(checkInTable(varBuffer)==0){
                return 2;
            }
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