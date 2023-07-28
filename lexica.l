%{
#include <string>
%}


ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
ASPAS2 \"

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})*\'
ID {LETRA}({LETRA}|{NUM})*
OPERADOR("+"|"-"|"*"|"*")
EXPRESSAO({ID}{NUM})({OPERADOR}({ID}{NUM}))+
ATRIBUICAO {ID} (=) {EXPRESSAO}
STRING ({ASPAS2}(({LETRA}|{NUM}|{ESPACO}|[(){}[\];,*]|[+\-/=@%$éêãáàèíìóòúùû&,.<>^~])+){ASPAS2})

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}

"++"        {return TK_INCREMENTO;}

"--"        {return TK_DECREMENTO;}

"if"        {return TK_IF;}

"do"        {return TK_DO;}

"switch"    {return TK_SWITCH;}

"case"      {return TK_CASE;}


"else"      {return TK_ELSE;}

"else if"   {return TK_ELSE_IF;}

"while"    {return TK_WHILE;}

"for"    {return TK_FOR;}

"break"    {return TK_BREAK;}

"continue"    {return TK_CONTINUE;}

"float"     {return TK_TIPO_FLOAT;}


"bool"      {return TK_TIPO_BOOL;}

"char"      {return TK_TIPO_CHAR;}

"string"    {return TK_TIPO_STRING;}

"cout"     {return TK_COUT;}

"cin"     {return TK_CIN;}

"return"    {return TK_RETURN;}

"(int)"     {return TK_CAST_INT;}

"(float)"   {return TK_CAST_FLOAT;}


">="        {return TK_MA;}
"<="        {return TK_ME;}
"!="        {return TK_DF;}
"=="        {return TK_IG;}
"||"        {return TK_OU;}
"!"         {return TK_NO;}
"&&"        {return TK_E;} 

[(){}[\];,]	       { return *yytext; }

[<>! >= <= == !=]  { return *yytext; }

[|| &&]            { return *yytext; }

[+\-*/=]	       { return *yytext; }


{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL;}
{ID}		{ yylval.label = yytext; return TK_ID;}
{CHAR}      { yylval.traducao = yytext; return TK_CHAR;}
{STRING}    { yylval.traducao = yytext; return TK_STRING; }

.			{ *yytext; }

%%