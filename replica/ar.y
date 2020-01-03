%{
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<string.h>
int yyparse();
int yylex();
int yyerror();
struct ll_identifier *root=NULL,*last=NULL;

%}

%union {
    char text[1000];
    int val;
    int lineval;
}

%token <text> ID
%token <val> NUM
%token <text> STR

%type <val> expression


%left LT GT LE GE 
%left PLUS MINUS
%left MULT DIV

%token INT DOUBLE  FOR CHAR MAIN  TB TE  PB PE SB SE VARD VARC SC CM TILL STP ASGN PRINT PRINTLN PLUS MINUS MULT DIV LT GT PP LOE GE IF ELSE ELSEIF COL FUNCTION 
%nonassoc IFX
%nonassoc ELSE
%left SH


%start program

%%

program  : MAIN TB TE SB statement SE
          ;

statement :  '.'
            |statement declaration
            | statement print
            | statement ifelse       
            | statement assign
            | statement forloopstmt
			|statement funtion
			| statement expression
            ;
			
			
			
declaration : type variable STP{  };
 
type : INT | DOUBLE | CHAR { };

variables : variable CM variable { }
          | variable { }
		  ;
variable : ID{}
          |ID ASGN expression {}
		  ;

assign : ID ASGN expression CM assign {}
		|ID ASGN expression STP{ }
		;
print: PRINT PB expression PE STP
       { printf("Value of expression = %f \n",$3);}
	   |PRINT PB ID PE STP
	   
	  {
                struct ll_identifier* decl = isDeclared(&root,$3);
                if(decl==NULL)
                {
                    printf("Compilation Error ::  Varribale %s is not declared\n",$3);
                    exit(-1);
                }
                else
                {
                    print(decl->data);
                    //printf("Value of %s :: %d\n",$3,decl->data.intval);
                }
            }
	|PRINT PB STR PE STP
            {
                printf("Print String :: %s\n",$3);
            }
			;
			

expression: NUM {$$=$1;}
			|ID 
                {
                    struct ll_identifier* res = isDeclared(&root,$1);
                    if(res==NULL)
                    {
                        printf("Compilation Error ::  Varribale %s is not declared\n",$1);
                        exit(-1);
                    }
                    else 
                    {
                        if(res->data.type==1)
                            $$ = res->data.intval;
                        else if(res->data.type==2)
                            $$ = res->data.doubleval;
                    }
                }
			|expression PLUS expression
				{
					$$=$1+$3;
				}
			|expression MINUS expression
				{
					$$=$1-$3;
				}
			|expression LT expression
				{
					$$=($1<$3);
				}
            |expression GT expression
				{
					$$=($1>$3);
				}
            |expression LOE expression
				{
					$$=($1<=$3);
				}
			|expression LT expression
				{
					$$=($1<$3);
				}
            |expression PP
				{
					$$=($1+$1);
				}
            |PB expression PE
				{
					$$=$2;
				}
			|ID ASGN FUNCTION{
					
			}
            ;
ifelse : IF PB expression PE statement {

					if($3>0)
					  {
						printf("%d \n",$3);
					  }
					else
					  {
						printf("error!\n");	
					  }
			
			
			}
			;
funtion : 
        |funtion func
		;
func:type FUNCTION PB fpara CM fpara PE TB statement TE { };

fpara: 
      |type ID fpara
	  ;
	  
finpara:
        |finpara CM type ID 
		;

forloopstmt: FOR PB forassign SC expression SC forassign PE SB statement SE {
                        
						
						int st = $3;
						int ed = $5;
						int dif = $7;
						int cnt = 0;
						int k = 0;
						for(k = st; k <= ed; k += dif){
							cnt++;
						}	
						printf("Loop executes %d times\n",cnt);
					
						}
						;
forassign : ID ASGN expression CM ID ASGN expression
          | ID ASGN expression
           ;

%%
int yyerror(char *s) /* called by yyparse on error */
{      printf("%s\n",s);
	return(0);
}
int main(void)
{      yyparse();
	exit(0);
}		   