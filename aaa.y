%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "comp_utility.c"
    int yyparse();
    int yylex();
    int yyerror();
    int ifdone[1000];
    int ifptr=0;
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

%token INT DOUBLE WHILE FOR CHAR VOID MAIN  DOT PB PE BB BE VARD VARC SM CM ASGN PRINT PRINTLN MINUS MULT DIV LT GT LE GE IF ELSE ELSEIF COL FUNCTION EQU NEQU 
%nonassoc IFX
%nonassoc ELSE
%left SH

%%
starhere    : function program function { 
                printf("\n Compilation Successful\n");
            }
            ;

program     : INT MAIN PB PE BB statement BE
            ;

statement   : /* empty */
            | statement declaration
            | statement print
            | statement ifelse
            | statement mathexpr
            | statement assign
            | statement whilestmt
            | statement forloopstmt
            ;


mathexpr : expression SM { }

declaration : type variables SM {
                //printf("came hear declaration\n");
            }
            ;
type        : INT | DOUBLE | CHAR {
                //printf("got type\n");
            }
            ;
variables   : variable CM variables {
                //printf("variable , variables\n");
            }
            | variable {
                //printf("variable\n");
            }
            ;
variable    :ID
                {
                  //  printf("ok2 %s\n",$1);
                    int res = addNewVal(&root,&last,$1,"");
                    if(!res)
                    {
                        printf("Compilation Error ::  Varribale %s is already declared\n",$1);
                        exit(-1);
                    }
                }
            |ID ASGN expression 
                {
                    //printf("ok1 %s %d\n",$1,$3);
                    int n = log10($3) + 1;
                    char *numberArray = calloc(n, sizeof(char));
                    sprintf(numberArray,"%ld",$3);
                    int res = addNewVal(&root,&last,$1,numberArray);
                    if(!res) 
                    {
                        printf("Compilation Error ::  Varribale %s is already declared\n",$1);
                        exit(-1);
                    }
                } 
            ;

assign    : ID ASGN expression CM assign {
                //printf("came assign\n");
            }
            | ID ASGN expression SM
            {
                //printf("Came here\n");
                struct ll_identifier* decl = isDeclared(&root,$1);
                if(decl==NULL)
                {
                    printf("Compilation Error ::  Varribale %s is not declared\n",$1);
                    exit(-1);
                }
                else 
                {
                    int n = log10($3) + 1;
                    char *numberArray = calloc(n, sizeof(char));
                    sprintf(numberArray,"%ld",$3);
                    setVal(&root,&last,$1,numberArray);
                }
            }
        ;
print   :PRINT PB expression PE SM
            {
                printf("Value of expression :: %f\n",$3);
            }
            |PRINT PB ID PE SM
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
        | PRINT PB STR PE SM
            {
                printf("Print String :: %s\n",$3);
            }
        | PRINTLN PB PE SM
            {
                printf("\n");
            }
        ;

expression  :NUM {$$=$1;}
            | ID 
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
            | expression PLUS expression
                {
                    $$ = $1+$3;
                }
            | expression MINUS expression 
                {
                    $$ = $1-$3;
                }
            | expression MULT expression 
                {
                    $$ = $1*$3;
                }
            | expression DIV expression 
                {
                    if($3==0)
                    {
                        printf("Compilation Error :: Divide by Zero Occured\n");
                        exit(-1);
                    }
                    $$ = $1/$3;
                }
            | expression LT expression 
                {
                    $$ = ($1<$3);
                }
            | expression GT expression 
                {
                    $$ = ($1>$3);
                }
            | expression LE expression 
                {
                    $$ = ($1<=$3);
                    
                }
            | expression GE expression 
                {
                    $$ = ($1>=$3);
                }
            | expression EQU expression 
                {
                    $$ = ($1==$3);
                }
            | expression NEQU expression 
                {
                    $$ = ($1!=$3);
                }
            | PB expression PE 
                {
                    $$ = $2;
                }
            ;

ifelse      : IF PB expression PE BB statement BE  {
                    ifptr++;
                    if($3>0){
                        printf("IF Executed\n");
                        ifdone[ifptr]=1;
                    }
                } elseif {
                    ifptr--;
                }
            ;
elseif : /* empty */
        | ELSEIF PB expression PE BB statement BE
            {
                if(ifdone[ifptr]==0 && $3>0){
                    ifdone[ifptr]=1;
                    printf("ELSE IF executed\n");
                }
            } elseif
        | elseif ELSE BB statement BE 
            {
                if(ifdone[ifptr]==0)
                    printf("ELSE Executed\n");
            }
        ;

function    : /* empty */
            | function func
            ;
func        : type FUNCTION PB fparameter PE BB statement BE 
                {
                    printf("\nfunction declared\n");
                }
            ;
fparameter  : /* empty */
            | type ID fsparameter
            ;
fsparameter : /* empty */
            | fsparameter CM type ID 
            ;

whilestmt   : WHILE PB expression PE BB statement BE{
                printf("while condition executed for %d\n",$3);
            }
            ;
forloopstmt : FOR PB forassign SM expression SM forassign PE BB statement BE{
                printf("for loop executed\n");
            }
            ;

forassign   :ID ASGN expression CM ID ASGN expression
            | ID ASGN expression
%%

extern char yytext[];
extern int column;
int yyerror(char *s){
    fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}%