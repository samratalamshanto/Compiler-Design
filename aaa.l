char [a-zA-Z]
digit [0-9]
special [$_@]
space " "
newline "\n"
Datatype "int"|"double"|"char"|"void"
Operator "="|"+"|"-"|"/"|"*"|"&"|"|"|"%"
Relational_Operator "<"|">"|"<="|">="|"&&"|"||"|"=="|"!="
Identifier ({char}|{digit}|{special})+

%{
    #include "comp_bison.tab.h"
    #include <string.h>
    int yyparse();
    int yylex();
    int yyerror();
    FILE *flexo;
    void count();
    int multicomm=0;
%}
%%
"/*" { multicomm=1;}
"#".* { 
    if(multicomm==0)
        fprintf(flexo,"comment %s\n",yytext);
    }
{newline} {
    if(multicomm==0){
        count();
        }
    }
{space} { 
    if(multicomm==0){
        count();
        }
    }
";" {
        if(multicomm==0){
            count();
            return SM;
        }
    }
"," {
        if(multicomm==0){
            count();
            return CM;
        }
    }
{digit}+ {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 1 :: %s\n",yytext);
        yylval.val = atoi(yytext);
        return NUM;
    }
}

"prg_main" { 
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 2:: %s\n",yytext);
        return MAIN;
        }
    }
"prg_println" { 
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 3:: %s\n",yytext);
        return PRINTLN;
        }
    }
"prg_print" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 4:: %s\n",yytext);
        return PRINT;
        }
    }
"prg_"({char}|{digit}|{special})+ {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 5:: %s\n",yytext);
        return FUNCTION;
        }
    }
"var_"({char}|{digit}|{special})+ {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 6:: %s\n",yytext);
        strcpy(yylval.text,yytext);
        return ID;
        }
    }

"int" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 7:: %s\n",yytext);
        return INT;
        }
    }
"double" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 8:: %s\n",yytext);
        return DOUBLE;
        }
    }
"char" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 9:: %s\n",yytext);
        return CHAR;
        }
    }

"for" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 10.1:: %s\n",yytext);
        return FOR;
        }
    }
"while" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 10.2:: %s\n",yytext);
        return WHILE;
        }
    }

"(" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 10:: %s\n",yytext);
        return PB;
    }
}
")" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 11:: %s\n",yytext);
            return PE;
        }
    }

"{" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 12:: %s\n",yytext);
            return BB;
            }
    }
"}" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 13:: %s\n",yytext);
            return BE;
        }
    }

"<=" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 14:: %s\n",yytext);
            return LE;
        }
    }
">=" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 15:: %s\n",yytext);
            return GE;
        }
    }
"==" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 16:: %s\n",yytext);
            return EQU;
        }
    }
"!=" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 17:: %s\n",yytext);
            return NEQU;
        }
    }
"=" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 18:: %s\n",yytext);
            return ASGN;
        }
    }
"+" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 19:: %s\n",yytext);
            return PLUS;
        }
    }
"-" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 20:: %s\n",yytext);
            return MINUS;
        }
    }
"*" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 21:: %s\n",yytext);
            return MULT;
        }
    }
"/" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 22:: %s\n",yytext);
            return DIV;
        }
    }
"<" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 23:: %s\n",yytext);
            return LT;
        }
    }
">" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 24:: %s\n",yytext);
            return GT;
            }
    }

"else if" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 25:: %s\n",yytext);
            return ELSEIF;
        }
    }
"if" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 27:: %s\n",yytext);
            return IF;
        }
    }
"else" {
        if(multicomm==0){
            count();
            fprintf(flexo,"lex 28:: %s\n",yytext);
            return ELSE;
        }
    }

"\""(.)*"\"" {
    if(multicomm==0){
        count();
        fprintf(flexo,"lex 30:: %s\n",yytext);
        strcpy(yylval.text,yytext+1);
        yylval.text[strlen(yylval.text)-1]='\n';
        return STR;
    }
}

%%

int yywrap()
{
	return 1;
}

int column  = 0;
void count()
{
    int i;
    for(int i=0;yytext[i]!='\0';i++)
    {
        if(yytext[i]=='\n')
            column=0;
        else if(yytext[i]=='\t')
            column+=(8-(column%8));
        else column++;
    }
    ECHO;
}
int main(){
    freopen("ain.txt","r",stdin);
	flexo = fopen("aout.txt","w");
    yyparse();
    fclose(flexo);
}