alpha [a-zA-Z]
digit [0-9]
fl	(f|F|l|L)
space [ ]
exp   [Ee][+-]?{digit}+
%{
#include<stdio.h>
#include<string.h>
//#include "y.tab.h"
char datatype[100];
int tl;
char next;
%}
%%
\n   { yylineno = yylineno + 1;}
"/*"    {multi();}
"//"    {single();}
"#include<"({alpha})*".h>" {}
"#define"({space})""({alpha})""({alpha}|{digit})*""({space})""({digit})+"" 			{ return DEFINE;}
"#define"({space})""({alpha}({alpha}|{digit})*)""({space})""(({digit}+)\.({digit}+))"" 		{ return DEFINE;}
"#define"({space})""({alpha}({alpha}|{digit})*)""({space})""({alpha}({alpha}|{digit})*)"" 	{ return DEFINE;}

{digit}+    				{  insertToConstTable(yytext, yylineno, "INT"); return CONSTANT; }
({digit}+)\.({digit}+) 			{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}+{exp}{fl}?			{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}*"."{digit}+({exp})?{fl}?	{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}+"."{digit}*({exp})?{fl}?	{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }

{alpha}?\"(\\.|[^\\"])*\"		{  insertToConstTable(yytext, yylineno, "STRING"); return STRING_LITERAL; } 

"->"			{  return PTR_OP; }
"++"			{  return INC_OP; }
"--"			{  return DEC_OP; }
"<<"			{  return LEFT_OP; }
">>"			{  return RIGHT_OP; }
"<="			{  return LE_OP; }
">="			{  return GE_OP; }
"=="			{  return EQ_OP; }
"!="			{  return NE_OP; }
"&&"			{  return AND_OP; }
"||"			{  return OR_OP; }
"*="			{  return MUL_ASSIGN; }
"/="			{  return DIV_ASSIGN; }
"%="			{  return MOD_ASSIGN; }
"+="			{  return ADD_ASSIGN; }
"-="			{  return SUB_ASSIGN; }
"break"			{ return BREAK; }
"case"			{ return CASE; }
"const"			{ return CONST; }
"char"			{ return CHAR; }
"continue"		{ return CONTINUE; }
"default"		{ return DEFAULT; }
"else"			{ return ELSE; }
"if"            { return IF; }
"return"		{ return RETURN; }
"switch"		{ return SWITCH; }
"void"			{ return VOID; }
"long"			{ return LONG; }
"short"			{ return SHORT; }
"double"		{ return DOUBLE; }
"float"			{ strcpy(datatype, "FLOAT"); tl = yylineno; return FLOAT; }
"int"			{ strcpy(datatype, "INT"); tl = yylineno; return INT; }
";"			{  strcpy(datatype, "dummy"); return(';'); }
("{"|"<%")		{  return('{'); }
("}"|"%>")		{  return('}'); }
","			{  return(','); }
":"			{  return(':'); }
"="			{  return('='); }
"("			{  return('('); }
")"			{  return(')'); }
("["|"<:")		{  return('['); }
("]"|":>")		{  return(']'); }
"."			{  return('.'); }
"&"			{  return('&'); }
"!"			{  return('!'); }
"-"			{  return('-'); }
"+"			{  return('+'); }
"*"			{  return('*'); }
"/"			{  return('/'); }
"%"			{  return('%'); }
"<"			{  return('<'); }
">"			{  return('>'); }
"^"			{  return('^'); }
"|"			{  return('|'); }

"printf"|"scanf"	{ insertToHash(yytext,"PROCEDURE",yylineno); return IDENTIFIER; }
"main" 			{ insertToHash(yytext,"PROCEDURE",yylineno); return IDENTIFIER; }
{alpha}({alpha}|{digit})*    		{  
						if(strcmp(datatype, "dummy")==0)
							return IDENTIFIER;
						else 
						{
							insertToHash(yytext,datatype,yylineno);
							return IDENTIFIER; 
						}
					}
[ \t\v\n\f]		{  }
.			{ /* ignore bad characters */ }
%%
struct cnode
{
    char num[50];
    char type[20];
};
struct cnode table[100];
int ccount=0;
void insertToConstTable(char *num,int l ,char *type)
{
    strcpy(table[ccount].num,num);
    strcpy(table[ccount].type,type);
    ccount++;
}

struct node
{
    char token[100];
    char attr[100];
    int line_count;
    struct node *next;
};
struct hash
{
    struct node*head;
    int hash_count;
};

struct hash Htable[1000];
int eleCount=1000;

struct node * createNode(char *token,char *attr,int l)
{
    struct node *newnode;
    newnode=(struct node*)malloc(sizeof(struct node));
    strcpy(newnode->token,token);
    strcpy(newnode->attr,attr);
    newnode->line_count=1;
    newnode->next=NULL;
    return newnode;
}

int hashIndex(char *token)
{
	int hi=0;
	int l,i;
	for(i=0;token[i]!='\0';i++)
	{
		hi = hi + (int)token[i];
	}
	hi = hi%eleCount;
	return hi;
}

void insertToHash(char *token, char *attr, int l)
{
	int flag=0;
	int hi;
	hi = hashIndex(token);
	struct node *newnode = createNode(token, attr, l);
	/* head of list for the bucket with index "hashIndex" */
	if (Htable[hi].head==NULL)
	{
		Htable[hi].head = newnode;
	        Htable[hi].hash_count = 1;
	        return;
	}
	struct node *myNode;
    	myNode = Htable[hi].head;
	while (myNode != NULL)
    	{
        	if (strcmp(myNode->token, token)==0)
        	{
            		flag = 1;
            		//myNode->line[(myNode->line_count)++] = l;
            		if(strcmp(myNode->attr, attr)!=0)
            		{
            			strcpy(myNode->attr, attr);
            		}
            		break;
        	}
        	myNode = myNode->next;
    	}
	if(!flag)
	{
		//adding new node to the list
		newnode->next = (Htable[hi].head);
		//update the head of the list and no of nodes in the current bucket
		Htable[hi].head = newnode;
		Htable[hi].hash_count++;
	}
	return;
}

void display()
{
    struct node *Node;
    int i,j,k=1;
    printf("Symbol Table\n");
    printf("Token \t\t Token Type\n");
    for(i=0;i<eleCount;i++)
    {
        if (Htable[i].hash_count == 0)
            		continue;
        Node = Htable[i].head;
        if (!Node)
            continue;
        while (Node != NULL)
        {
            		printf("%s\t\t", Node->token);
            		printf("%s", Node->attr);
            		printf("\n");
            		Node = Node->next;
        } 
    }
}

yywrap()
{
    return(1);
}
multi()
{
    char c, c1;
	while ((c = input()) != '*' && c != 0);
	c1=input();
	if(c=='*' && c1=='/')
	{
		c=0;
	}
	if (c != 0)
		putchar(c1);
}
single()
{
	char c;
	while(c=input()!='\n');
	if(c=='\n')
		c=0;
	if(c!=0)
		putchar(c);
}
