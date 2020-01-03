%{   
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "ar.tab.h"
	extern YYSTYPE yylval;
	int yyparse();
    int yylex();
    int yyerror();
   FILE *flexo;

    int comnt=0;
%}


char [a-zA-Z]
digit [0-9]
space " "
newline "\n"
Datatype "int"|"double"|"char"|"void"
Operator "equal"|"add"|"sub"|"div"|"mul"|"and"|"or"|"per"
Relational_Op "less"|">grt|"lessorequal"|"grtorequal"|"andand"|"oror"|"equalequal"|"notequal"
Identifier ({char}|{digit})+



%%
"!!*"        {cmnt=1;}

"~"           {if(cmnt=0) return TILL;}
","           {if(cmnt=0) return CM;}
"."           {if(cmnt=0) return STP;}
";"           {if(cmnt=0) return SC;}


{digit}+ 
{ 
if(cmnt=0)
yylval.val=atoi(yytext);
return NUM;
}

"main"           {if(cmnt=0) return MAIN ;}
"show"           {if(cmnt=0) return PRINT;}
"subfunc"({digit})+          {if(cmnt=0) return FUNCTION;}
"int"           {if(cmnt=0) return INT;}
"double"           {if(cmnt=0) return DOUBLE;}
"for"           {if(cmnt=0) return FOR;}
"("           {if(cmnt=0) return PB;}
")"           {if(cmnt=0) return PE;}

"{"           {if(cmnt=0) return SB;}
"}"           {if(cmnt=0) return SE;}

"["           {if(cmnt=0) return TB;}
"]"           {if(cmnt=0) return TE;}

"equal"           {if(cmnt=0) return ASGN;}
"add"           {if(cmnt=0) return PLUS;}
"sub"           {if(cmnt=0) return MINUS;}

"grt"           {if(cmnt=0) return GT;}
"lessorequal"   {if(cmnt=0) return LOE;}

"plusplus"      {if(cmnt=0) return PP;}

"if"             {if(cmnt=0) return IF;}
"else"           {if(cmnt=0) return ELSE;}

"!!"            {if(cmnt=0) return STR;}


%%

int yywrap()
{
	return 1;
}


int main(){
    freopen("inputr.txt","r",stdin);
flexo = fopen("outputr.txt","w");
    yyparse();
    fclose(flexo);
}


