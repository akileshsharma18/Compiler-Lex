%{
	int yylineno;
	char data_type[200];
%}


%nonassoc  NO_ELSE 
%nonassoc  ELSE 
%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP 
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER CONSTANT STRING_LITERAL
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN DEFINE CONST
%token CHAR SHORT INT LONG FLOAT DOUBLE VOID
%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CASE DEFAULT IF ELSE SWITCH CONTINUE BREAK RETURN
%start begin
%union{
	char str[1000];
}
%%
begin: external_declaration
	| begin external_declaration
	| Define begin
	;

primary_expression: IDENTIFIER { insertToHash($<str>1, data_type , yylineno); }
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

Define: DEFINE;

postfix_expression: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	;

argument_expression_list: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	;

unary_operator: '&'| '*'| '+'| '-'| '~'| '!';

cast_expression: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	;

expression: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

declaration: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	;

type_specifier: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	;

parameter_list: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration: declaration_specifiers declarator
	| declaration_specifiers
	;

identifier_list: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

specifier_qualifier_list: type_specifier specifier_qualifier_list
	| type_specifier
	| CONST specifier_qualifier_list
	| CONST
	;

type_name: specifier_qualifier_list
	| specifier_qualifier_list declarator
	;

initializer: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list: initializer
	| initializer_list ',' initializer
	;



statement: compound_statement
	| expression_statement
	| selection_statement
	;

compound_statement: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list: declaration
	| declaration_list declaration
	;

statement_list: statement
	| statement_list statement
	;

expression_statement: ';'
	| expression ';'
	;

pointer: '*'
	| '*' pointer
	;
	
direct_declarator
	: IDENTIFIER
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;


declarator: pointer direct_declarator
	| direct_declarator
	;

storage_class_specifier: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

declaration_specifiers: storage_class_specifier
	| storage_class_specifier declaration_specifiers
	| type_specifier	{ strcpy(data_type, $<str>1); }
	| type_specifier declaration_specifiers
	;

selection_statement: IF '(' expression ')' statement  %prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement
	;
selection_statement: IF '(' expression ')' statement  %prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' IDENTIFIER ')' '{' B '}'
	;


B   :    C B
    |    D
    ;
    
C   :CASE CONSTANT ':' '{' statement '}' C
    | CASE CONSTANT ':'  statement ';' C
    | B
    |   BREAK ';'
    ;

D   :    DEFAULT    ':' statement ';'
    ;
     






external_declaration: function_definition
	| declaration
	;

function_definition: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
	;
%%
#include "lex.yy.c"
#include <stdio.h>
#include <string.h>
int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");

	fclose(yyin);
	display();
	return 0;
}

