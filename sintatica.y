%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
    string label;
    string traducao;
    string tipo;
}; 

typedef struct
{
    string nomeVariavel;
    string tipoVariavel;
} TIPO_SIMBOLO; 

vector<TIPO_SIMBOLO> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string geraLabel();
void imprimirTabelaDeSimbolos();;

%}

%token TK_NUM TK_REAL
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S           : TK_TIPO_INT TK_MAIN '(' ')' BLOCO
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
            |
            {
                $$.traducao = "";
            }
            ;

COMANDO     : E ';'
            | TK_TIPO_INT TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = $2.label;
                valor.tipoVariavel = "int"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_FLOAT TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = $2.label;
                valor.tipoVariavel = "float"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            ;

E           : E '+' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " + " + $3.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $3.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '-' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " - " + $3.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $3.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '*' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " * " + $3.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $3.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '/' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " - " + $3.label + ";\n";

                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "float"; // Sempre usamos "float" para operações de divisão
                tabelaSimbolos.push_back(temp);
            }
            | E '>' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " > " + $3.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $3.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '<' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                    " = " + $1.label + " < " + $3.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $3.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '>''=' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $4.traducao + "\t" + $$.label + 
                    " = " + $1.label + " >= " + $4.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $4.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '<''=' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $4.traducao + "\t" + $$.label + 
                    " = " + $1.label + " <= " + $4.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $4.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '=''=' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $4.traducao + "\t" + $$.label + 
                    " = " + $1.label + " == " + $4.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $4.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | E '!''=' E
            {
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $4.traducao + "\t" + $$.label + 
                    " = " + $1.label + " != " + $4.label + ";\n";

                // Atualizar tipo da temporária com base nos tipos dos operandos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                // Se os tipos dos operandos são iguais, usamos esse tipo, caso contrário, usamos "float"
                temp.tipoVariavel = ($1.tipo == $4.tipo) ? $1.tipo: "float";
                tabelaSimbolos.push_back(temp);
            }
            | TK_ID
            {
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 
                for (int i = 0; i < tabelaSimbolos.size(); i++){
                    if(tabelaSimbolos[i].nomeVariavel == $1.label){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                    }
                }
                if(!encontrei){
                    yyerror("Variavel não declarada!");
                }

                $$.tipo = variavel.tipoVariavel; 
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = variavel.tipoVariavel;
                tabelaSimbolos.push_back(temp);
            }
            | TK_ID '=' E
            {
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 
                for (int i = 0; i < tabelaSimbolos.size(); i++){
                    if(tabelaSimbolos[i].nomeVariavel == $1.label){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                    }
                }
                if(!encontrei){
                    yyerror("Variavel não declarada!");
                }
                
                $$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";

                $$.tipo = $1.tipo; // Usar o tipo da variável original
                $$.label = geraLabel();
                $$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";

                // Atualizar tipo da temporária com base no tipo da variável original   
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $1.label;
                temp.tipoVariavel = $1.tipo; // Usar o tipo da variável original
                tabelaSimbolos.push_back(temp);
            }
            | TK_NUM
            {
                $$.tipo = "int";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "int";
                tabelaSimbolos.push_back(temp);
            }
            | TK_REAL
            {
                $$.tipo = "float";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "float";
                tabelaSimbolos.push_back(temp);
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

void atribuirTiposTemporarios()
{
    for (auto& temp : tabelaSimbolos) {
        if (temp.nomeVariavel[0] == 'T') {
            string nomeOriginal = temp.nomeVariavel.substr(1);
            for (const auto& original : tabelaSimbolos) {
                if (original.nomeVariavel == nomeOriginal) {
                    temp.tipoVariavel = original.tipoVariavel;
                    break;
                }
            }
        }
    }
}

void imprimirTabelaDeSimbolos()
{
    atribuirTiposTemporarios();

    for (const auto& simbolo : tabelaSimbolos) {
        if (!simbolo.tipoVariavel.empty() && simbolo.nomeVariavel[0] == 'T') {
            cout << "\t" << simbolo.tipoVariavel << " " << simbolo.nomeVariavel << ";" << endl;
        }
    }

    for (const auto& simbolo : tabelaSimbolos) {
        if (!simbolo.tipoVariavel.empty() && simbolo.nomeVariavel[0] != 'T') {
            cout << "\t" << simbolo.tipoVariavel << " " << simbolo.nomeVariavel << ";" << endl;
        }
    }
}
