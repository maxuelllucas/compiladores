%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*
OPERADOR("+"|"-"|"*"|"*")
EXPRESSAO({ID}{NUM})({OPERADOR}({ID}{NUM}))+
ATRIBUICAO {ID} (=) {EXPRESSAO}

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}

"float"		{return TK_TIPO_FLOAT;}



[(){}[\];,]	{ return *yytext; }

[+\-*/=]	{ return *yytext; }


{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL;}
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
