%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

typedef struct 
{
    string label;
    string traducao;
    string tipo;
} atributos; 

typedef struct
{
    string nomeVariavel;
    string tipoVariavel;
    string nomeOriginal;

} TIPO_SIMBOLO; 

vector<TIPO_SIMBOLO> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string geraLabel();
void imprimirTabelaDeSimbolos();
atributos converteTipo(atributos a, atributos b, atributos c, string caracter);
void insereTabelaDeSimbolos(atributos a,  string tipo);
void insereID(atributos a,  string tipo);



%}

%token TK_NUM TK_REAL TK_CHAR TK_CAST_INT TK_CAST_FLOAT TK_MA TK_ME TK_DF TK_IG TK_OU TK_NO TK_E 
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_IF TK_ELSE TK_ELSE_IF
%token TK_FIM TK_ERROR

%start S

//Ordem de precedência 
%left TK_E TK_OU TK_NO 
%left '>' '<'  TK_MA TK_ME TK_IG TK_DF 
%left '+' '-' 
%left '*' '/' 


%%

S           : TK_TIPO_INT TK_MAIN '('')' BLOCO
            {
                cout << "\n\nXxx---COMPILADOR J.M.B---xxX\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n";
                imprimirTabelaDeSimbolos();
                cout << $5.traducao << "\treturn 0;\n}" << endl;
            }
            ;

BLOCO       : '{' COMANDOS '}'
            {
                $$.traducao = $2.traducao;
            }
            ;

COMANDOS    : COMANDO COMANDOS
            {
                $$.traducao = $1.traducao + $2.traducao;
            }
            |//BLOCOS
             '{' COMANDOS '}' COMANDOS
            {
                
                $$.traducao = $2.traducao + $4.traducao;
            }
            |
            {
                $$.traducao = "";
            }
            ;
            //IF
CONDICAO    :TK_IF '(' E ')''{' COMANDOS '}'
            {
                $$.label = geraLabel();
                $$.tipo = $1.tipo;
                insereTabelaDeSimbolos($$,"bool");
                $$.traducao =$3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tIF(" + $$.label + ") GoTo FIM_IF;\n" + $6.traducao + "\tFIM_IF:\n\n";
            }
            |TK_ELSE_IF '(' E ')''{' COMANDOS '}' 
            {
                $$.label = geraLabel();
                $$.tipo = $1.tipo;
                insereTabelaDeSimbolos($$,"bool");
                $$.traducao = $3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tIF("+ $$.label + ") GoTo FIM_ELSE_IF;\n" + $6.traducao + "\tFIM_ELSE_IF:\n\n";
            } 
            ;
            //ELSE
CONDICAO2   :
            CONDICAO TK_ELSE '{' COMANDOS '}'
            {
                $$.traducao= $1.traducao + "\tIF(!" + $1.label + ") GoTo FIM_ELSE;\n" + $4.traducao + "\tFIM_ELSE:\n\n";
            }
            ;
COMANDO     : E ';'
            |
            CONDICAO
            |
            CONDICAO2
            | TK_TIPO_INT TK_ID ';'
            {
                insereID($2,"int");

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_FLOAT TK_ID ';'
            {
                insereID($2,"float");

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_BOOL TK_ID ';'
            {
                insereID($2,"int");

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_CHAR TK_ID ';'
            {
                insereID($2,"char");

                $$.traducao = "";
                $$.label = ""; 
            }
            ;

E           : E '+' E
            {
                $$ = converteTipo($1, $3,$$,"+");
            }
            | E '-' E
            {
                $$ = converteTipo($1, $3,$$,"-");
            }
            | E '*' E
            {
                $$ = converteTipo($1, $3,$$,"*");
            }
            | E '/' E
            {
                $$ = converteTipo($1, $3,$$,"/");
            }
            | E '>' E
            {
               $$ = converteTipo($1, $3,$$,">");
               //Convertendo o tipo para Bool nos relacionais para poder fazer comparação com os lógicos
               $$.tipo = "bool";
            }
            | E '<' E
            {
                $$ = converteTipo($1, $3,$$,"<");
                $$.tipo = "bool";
            }
            | E TK_MA E
            {
                $$ = converteTipo($1, $3,$$,">=");
                $$.tipo = "bool";
            }
            | E TK_ME E
            {
               $$ = converteTipo($1, $3,$$,"<=");
               $$.tipo = "bool";
            }
            | E TK_IG E
            {
                $$ = converteTipo($1, $3,$$,"==");
                $$.tipo = "bool";
            }
            | E TK_DF E
            {
                $$ = converteTipo($1, $3,$$," != ");
                $$.tipo = "bool";
            }
            | E TK_OU E
            {
                if ($1.tipo != "bool" || $3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }

                $$ = converteTipo($1, $3,$$," || ");
            }
            | E TK_E E
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                $$ = converteTipo($1, $3,$$," && ");
            }
            | E TK_NO E
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                $$ = converteTipo($1, $3,$$," ! ");
            }
            | TK_CHAR
            {
                $$.tipo = "char";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                insereTabelaDeSimbolos($$,"char");
            }
            | TK_TIPO_BOOL
            {
                $$.tipo = "bool";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                insereTabelaDeSimbolos($$,"int");
            }
            | TK_ID
            {
                if($1.label == "true" || $1.label == "false"){
                    $$.label = geraLabel();
                    insereTabelaDeSimbolos($$,"int");
                    $$.tipo = "bool";
                    $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
                }
                else{
                    bool encontrei = false; 
                    TIPO_SIMBOLO variavel; 
                    for (int i = 0; i < tabelaSimbolos.size(); i++){
                        if(tabelaSimbolos[i].nomeOriginal == $1.label){
                            variavel = tabelaSimbolos[i];
                            encontrei = true;
                        }
                    }
                    if(!encontrei){
                        if($1.label == "true" || $1.label == "false"){
                            $$.tipo = "bool";
                        } 
                    else{
                        yyerror("Variavel não declarada!");}
                    }

                    $$.tipo = variavel.tipoVariavel; 
                    $$.label = geraLabel();
                    $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

                    // Adicionar variável temporária na tabela de símbolos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.nomeOriginal = $1.label;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | TK_ID '=' E
            {
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 
                for (int i = 0; i < tabelaSimbolos.size(); i++){
                    if(tabelaSimbolos[i].nomeOriginal == $1.label){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                    }
                }
                if(!encontrei){
                    yyerror("Variavel não declarada!");
                }
                
                $$.tipo = $1.tipo; // Usar o tipo da variável original
                $$.label = geraLabel();
                $$.traducao = $3.traducao + "\t" + variavel.nomeVariavel + " = " + $3.label + ";\n";

            }
            | TK_CAST_INT E
            {
                if($2.tipo == "float")
                {
                    $2.label = "(int)" + $2.label;
                    $2.tipo = "int";
                }
                $$.label = geraLabel();
                $$.tipo = "int";
                $$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + ";\n";

                insereTabelaDeSimbolos($$,"int");
            }
            | TK_CAST_FLOAT E
            {
                if($2.tipo == "int")
                {
                    $2.label = "(float)" + $2.label;
                    $2.tipo = "float";
                }
                $$.label = geraLabel();
                $$.tipo = "float";
                $$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label+ ";\n";

                insereTabelaDeSimbolos($$,"float");
            }
            | TK_NUM 
            {
                $$.tipo = "int";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                insereTabelaDeSimbolos($$,"int");
            }
            | TK_REAL
            {
                $$.tipo = "float";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                insereTabelaDeSimbolos($$,"float");
            }
            |
            {
                $$.label = geraLabel();
                $$.traducao ="\t" + $$.label + " = " + "true;\n";
                insereTabelaDeSimbolos($$,"int");
            }
            ;

%%

#include "lex.yy.c"

int yyparse();

string geraLabel()
{
    static int i = 1;

    stringstream ss;
    ss << "T" << i++;

    return ss.str();
}

int main(int argc, char* argv[])
{

    yyparse();

    return 0;
}

void yyerror(string MSG)
{
    cout << MSG << endl;
    exit (0);
}               

void insereTabelaDeSimbolos(atributos a,string tipo){
    TIPO_SIMBOLO temp;
    temp.nomeVariavel = a.label;
    temp.tipoVariavel = tipo;
    tabelaSimbolos.push_back(temp);  
};

//Inserindo os tokens de ID na tabela de símbolos
void insereID(atributos a,string tipo){
    TIPO_SIMBOLO valor;
    valor.nomeVariavel = geraLabel();
    valor.nomeOriginal = a.label;
    valor.tipoVariavel = tipo; 
    
    for(int i = 0; i < tabelaSimbolos.size(); i++)
	{
		if(tabelaSimbolos[i].nomeOriginal == valor.nomeOriginal)
		{
			yyerror("Variavel já declarada!");
		}
	}
    tabelaSimbolos.push_back(valor);
};

atributos converteTipo(atributos a, atributos b,atributos c, string caracter){
     //Condições para converter de Int para Float
                if (a.tipo == "char" || b.tipo == "char") {
                    yyerror("Erro. Operação inválida!");
                }
                if (a.tipo == "int" && b.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    c.label = geraLabel();
                    c.tipo = "float";

                    c.traducao = a.traducao +  b.traducao + "\t" + tempVar + " = (float)" + a.label + ";\n";
                    c.traducao += "\t" + c.label + " = " + b.label + caracter + tempVar + ";\n";
                    

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int" + " " + c.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else if (a.tipo == "float" && b.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    c.label = geraLabel();
                    c.tipo = "float";

                    c.traducao =a.traducao +  b.traducao + "\t" + tempVar + " = (float)" + b.label + ";\n";
                    c.traducao += "\t" + c.label + " = " + a.label + caracter + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int" + " " + c.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    
                    c.label = geraLabel();
                    c.tipo = a.tipo;
                    c.traducao = a.traducao + b.traducao + "\t" + c.label + 
                        " = " + a.label + caracter + b.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = c.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
    return c;
}

void imprimirTabelaDeSimbolos()
{
    for(TIPO_SIMBOLO simbolo: tabelaSimbolos){
        cout<<"\t"+simbolo.tipoVariavel+" "+simbolo.nomeVariavel + ";" <<endl;
    }

}