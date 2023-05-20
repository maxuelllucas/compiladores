%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

struct Simbolo {
    string nome;
    string tipo;
};

//Criando a lista(vetor) da tabela de símbolos
vector<Simbolo> tabelaDeSimbolos;

struct atributos {
    string label;
    string id;
    string traducao;
    string tipo;
};

string geraLabel();
string gera_ID();
void insereSimbolo(string nome, string tipo);
bool verificaSimbolo(string nome);
string obterTipoSimbolo(string nome);

int yylex(void);
void yyerror(string);
vector<string> variaveis; // Vetor para armazenar as variáveis encontradas

%}

//Tokens Pro Léxico
%token TK_NUM
%token TK_TIPO_FLOAT
%token TK_REAL
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

//Ordem de precedência 
%left '+' '-'
%left '*' '/'

%%


S           : TK_TIPO_INT TK_MAIN '(' ')' BLOCO
            {
				/*/ Imprime as variáveis encontradas antes de imprimir o código gerado
                for (const string& variavel : variaveis) {
                    cout << variavel << endl;
                }*/
                cout << "\n\nXxx---COMPILADOR J.M.B---xxX\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl;
            }
            ;

BLOCO       : '{' COMANDOS '}'
            {
                string label = geraLabel();
                $$.traducao = $2.traducao;
                $$.label= label;
            }
            ;

COMANDOS    : COMANDO COMANDOS
            |
            ;

COMANDO     : E ';'
            ;

E           : E '+' E
            {
                string label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + label + " = " + $1.label + " + " + $3.label + "\n";
                $$.label= label;

				// Inserir o símbolo na tabela de símbolo
				insereSimbolo(label,$$.tipo);

            }
            |
            E '-' E
            {
                string label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + label + " = "  + $1.label + " - " + $3.label + "\n";
                $$.label= label;

				// Inserir o símbolo na tabela de símbolo
				insereSimbolo(label,$$.tipo);
            }
            |
            E '*' E
            {
                string label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + label + " = "  + $1.label + " * " + $3.label + "\n";
                $$.label= label;

				// Inserir o símbolo na tabela de símbolo
				insereSimbolo(label,$$.tipo);
            }
            |
            E '/' E
            {
                string label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + label + " = "  + $1.label + " / " + $3.label + "\n";
                $$.label= label;

				// Inserir o símbolo na tabela de símbolo
				insereSimbolo(label,$$.tipo);
            }
            |
            TK_NUM
            {
                $$.tipo= "int";
                string label = geraLabel();
                $$.traducao = "\t" + $$.tipo + " " + label + ";\n \t" + label + " = "  + $1.traducao + ";\n";
                $$.label= label;

                // Inserir o símbolo na tabela de símbolos
                insereSimbolo(label, $$.tipo);
            }
            |
            TK_REAL
            {
                $$.tipo= "float";
                string label = geraLabel();
                $$.traducao = "\t" + $$.tipo + " " + label + ";\n\t" + label + " = "  + $1.traducao + ";\n";
                $$.label= label;

                // Inserir o símbolo na tabela de símbolos
                insereSimbolo(label, $$.tipo);
            }
            |
            TK_ID
            {
                string label = geraLabel();

				// Inserir o símbolo na tabela de símbolos
                insereSimbolo(label, $$.tipo);
                string tipo = obterTipoSimbolo($1.label); // Obtém o tipo do símbolo da tabela de símbolos

                $$.traducao = "\t" + $$.tipo + " " + label + " = "  + $1.label + ";\n";
                $$.label = label;

            }
            |
            TK_ID '=' E
            {
				$1.tipo=$3.tipo;
				insereSimbolo($1.label,$1.tipo);
				string tipo=obterTipoSimbolo($1.label);
                $$.traducao ='\t' + $1.tipo + " " +$1.label + ";\n"+ '\t'+ $3.tipo + " " + $3.label + ";\n" + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";

		    }
            ;

%%


#include "lex.yy.c"

int yyparse();

int main(int argc, char* argv[])
{
    yyparse();

	//Mostrando a tabela de símbolos
	for (const Simbolo& simbolo : tabelaDeSimbolos) {
        cout<<simbolo.tipo + " " + simbolo.nome<<endl;
    }
    return 0;
}

void yyerror(string MSG)
{
    cout << MSG << endl;
    exit(0);
}


string geraLabel()
{
    static int i = 1;

    stringstream ss;
    ss << "T" << i++;

    return ss.str();
}

void insereSimbolo(string nome, string tipo)
{
    Simbolo simbolo;
    simbolo.nome = nome;
    simbolo.tipo = tipo;

    tabelaDeSimbolos.push_back(simbolo);
}

//verificar se  o símbolo está na tabela de símbolos
bool verificaSimbolo(string nome)
{
    for (const Simbolo& simbolo : tabelaDeSimbolos) {
        if (simbolo.nome == nome) {
            return true;
        }
    }

    return false;
}

//retornar tipo do símbolo
string obterTipoSimbolo(string nome)
{
	//varre a tabela de símbolos comparando com o nome fornecido
    for (const Simbolo& simbolo : tabelaDeSimbolos) {
        if (simbolo.nome == nome) {
            return simbolo.tipo;
        }
    }
	
	//se não encontrar simbolo na tabela de símbolos retorna uma string vazia
    return "";
}
