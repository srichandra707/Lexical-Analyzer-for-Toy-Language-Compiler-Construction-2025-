%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line_num;
extern char *yytext;

void yyerror(const char *s);
%}

/* Token definitions */
%token PROGRAM_BEGIN PROGRAM_END
%token VARDECL_BEGIN VARDECL_END
%token PRINT SCAN
%token IF ELSE WHILE FOR TO DO
%token BEGIN_BLOCK END_BLOCK
%token INC DEC
%token SEMICOLON COMMA COLON
%token LPAREN RPAREN LBRACKET RBRACKET
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token PLUS MINUS MULT DIV MOD
%token EQ GT LT GE LE NE
%token INT_TYPE CHAR_TYPE
%token AT
%token IDENTIFIER
%token INT_CONST CHAR_CONST STRING_CONST

/* Precedence and associativity */
%left PLUS MINUS
%left MULT DIV MOD
%left EQ GT LT GE LE NE

%%

program
    : PROGRAM_BEGIN var_declaration statement_list PROGRAM_END
    ;

var_declaration
    : VARDECL_BEGIN var_list VARDECL_END
    ;

var_list
    : var_declr SEMICOLON
    | var_list var_declr SEMICOLON
    ;

var_declr
    : LPAREN IDENTIFIER COMMA type RPAREN
    | LPAREN array_declr COMMA type RPAREN
    ;

array_declr
    : IDENTIFIER LBRACKET decimal RBRACKET
    ;

type
    : INT_TYPE
    | CHAR_TYPE
    ;

statement_list
    : statement
    | statement_list statement
    ;

statement
    : print_stmt
    | scan_stmt
    | assignment_stmt
    | conditional_stmt
    | loop_stmt
    ;

print_stmt
    : PRINT LPAREN STRING_CONST RPAREN SEMICOLON
    | PRINT LPAREN STRING_CONST COMMA identifier_list RPAREN SEMICOLON
    ;

scan_stmt
    : SCAN LPAREN scanf COMMA identifier_list RPAREN SEMICOLON
    ;

scanf
    : AT
    | AT COMMA scanf
    ;

assignment_stmt
    : IDENTIFIER assignment_opr expression SEMICOLON
    ;

assignment_opr
    : ASSIGN
    | PLUS_ASSIGN
    | MINUS_ASSIGN
    | MULT_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    ;

identifier_list
    : IDENTIFIER
    | identifier_list COMMA IDENTIFIER
    ;

conditional_stmt
    : if_stmt
    | if_else_stmt
    ;

if_stmt
    : IF condition block SEMICOLON
    ;

if_else_stmt
    : IF condition block ELSE block SEMICOLON
    ;

loop_stmt
    : while_stmt
    | for_stmt
    ;

while_stmt
    : WHILE LPAREN condition RPAREN block SEMICOLON
    ;

condition
    : expression rel_op expression
    ;

for_stmt
    : FOR IDENTIFIER ASSIGN expression TO expression inc_dec expression DO block SEMICOLON
    ;

inc_dec
    : INC
    | DEC
    ;

block
    : BEGIN_BLOCK block_statements END_BLOCK
    ;

block_statements
    : block_stmt
    | block_statements block_stmt
    ;

block_stmt
    : print_stmt
    | scan_stmt
    | assignment_stmt
    ;

expression
    : term
    | expression add_op term
    ;

term
    : factor
    | term mul_op factor
    ;

factor
    : IDENTIFIER
    | INT_CONST   /* Simplified to handle all types of integer constants */
    | CHAR_CONST
    | STRING_CONST
    | LPAREN expression RPAREN
    ;

add_op
    : PLUS
    | MINUS
    ;

mul_op
    : MULT
    | DIV
    | MOD
    ;

rel_op
    : EQ
    | GT
    | LT
    | GE
    | LE
    | NE
    ;

decimal
    : INT_CONST
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
        printf("Successfully parsed !!!\n");
        return 0;
    } else {
        return 1;
    }
}
