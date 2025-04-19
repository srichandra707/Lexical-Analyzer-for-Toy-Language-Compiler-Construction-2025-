%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern void yyerror(const char *s);
extern FILE *yyin;
extern int line_num;
extern char *yytext;
%}

%token PROGRAM_BEGIN PROGRAM_END
%token VARDECL_BEGIN VARDECL_END
%token BEGIN_BLOCK END_BLOCK
%token INT_TYPE CHAR_TYPE
%token PRINT SCAN
%token IF ELSE
%token WHILE FOR TO DO
%token INC DEC
%token IDENTIFIER CHAR_CONST STRING_CONST INT_CONST INT_LITERAL
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token PLUS MINUS MUL DIV MOD
%token REL_OPERATORS
%token SEMICOLON COMMA COLON
%token OB CB OS CS
%token AT

%left PLUS MINUS
%left MUL DIV MOD
%left REL_OPERATORS
%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN

%start program

%%
program: PROGRAM_BEGIN var_declaration statement_list PROGRAM_END {}
;

var_declaration: VARDECL_BEGIN var_list VARDECL_END
;

var_list: var_declr SEMICOLON
| var_list var_declr SEMICOLON
;

var_declr: OB IDENTIFIER COMMA type CB
| OB array_declr COMMA type CB
;

type: INT_TYPE
| CHAR_TYPE
;

array_declr: IDENTIFIER OS INT_LITERAL CS
;

statement_list: statement
| statement_list statement
;

statement: print_stmt
| scan_stmt
| assignment_stmt
| conditional_stmt
| loop_stmt
;

print_stmt: PRINT OB STRING_CONST CB SEMICOLON
| PRINT OB STRING_CONST COMMA identifier_list CB SEMICOLON
;   

identifier_list: IDENTIFIER
| identifier_list COMMA IDENTIFIER
;

scan_stmt: SCAN OB scanf COMMA identifier_list CB SEMICOLON
;

scanf: AT
| scanf COMMA AT
;

assignment_stmt: IDENTIFIER assignment_op expression SEMICOLON
| IDENTIFIER OS expression CS assignment_op expression SEMICOLON
;

assignment_op: ASSIGN
| PLUS_ASSIGN
| MINUS_ASSIGN
| MULT_ASSIGN
| DIV_ASSIGN
| MOD_ASSIGN
;

conditional_stmt: if_stmt
| if_else_stmt
;

if_stmt: IF condition block SEMICOLON
;

if_else_stmt: IF condition block ELSE block SEMICOLON
;

condition: expression REL_OPERATORS expression
;


expression: term
| expression add_op term
;

add_op:PLUS 
| MINUS
;

term: factor
| term mul_op factor
;

mul_op: MUL
| DIV
| MOD
;

factor: IDENTIFIER
| IDENTIFIER OS expression CS
| constant
| OB expression CB
;

constant: INT_CONST
| CHAR_CONST
| STRING_CONST
;

loop_stmt: while_stmt
| for_stmt
;

while_stmt: WHILE OB condition CB block SEMICOLON
;

for_stmt: FOR IDENTIFIER ASSIGN expression TO expression inc_dec expression DO block SEMICOLON
;

inc_dec: INC 
| DEC
;

block: BEGIN_BLOCK block_statements END_BLOCK 
;

block_statements: block_stmt
| block_statements block_stmt
;

block_stmt: print_stmt
| scan_stmt
| assignment_stmt
;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", line_num, s);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }
    
    int parse_result = yyparse();
    fclose(yyin);
    
    if (parse_result == 0) {
        printf("Successfully parsed!\n");
        return 0;
    } else {
        return 1;
    }
}