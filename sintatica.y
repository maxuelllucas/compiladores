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
    string nomeOriginal;

} TIPO_SIMBOLO; 

vector<TIPO_SIMBOLO> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string geraLabel();
void imprimirTabelaDeSimbolos();;

%}

%token TK_NUM TK_REAL TK_CHAR TK_CAST_INT TK_CAST_FLOAT TK_MA TK_ME TK_DF TK_IG TK_OU TK_NO TK_E
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR
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
            |
            {
                $$.traducao = "";
            }
            ;

COMANDO     : E ';'
            | TK_TIPO_INT TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = geraLabel();
                valor.nomeOriginal= $2.label;
                valor.tipoVariavel = "int"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_FLOAT TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = geraLabel();
                valor.nomeOriginal= $2.label;
                valor.tipoVariavel = "float"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_BOOL TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = geraLabel();
                valor.nomeOriginal = $2.label;
                valor.tipoVariavel = "int"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_CHAR TK_ID ';'
            {
                TIPO_SIMBOLO valor;
                valor.nomeVariavel = geraLabel();
                valor.nomeOriginal = $2.label;
                valor.tipoVariavel = "char"; 

                tabelaSimbolos.push_back(valor);

                $$.traducao = "";
                $$.label = ""; 
            }
            ;

E           : E '+' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "char" || $3.tipo == "char") {
                    yyerror("Erro. Operação inválida!");
                }

                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " + " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " + " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " + " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                }
            

            }
            | E '-' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " - " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " - " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " - " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E '*' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " * " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " * " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " * " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E '/' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " / " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    
                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " / " + tempVar + ";\n";
                    $$.tipo = "float";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ $$.tipo + " " + $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " / " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = $$.tipo;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E '>' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " > " + tempVar + ";\n";
                    

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int" + " " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $$.label + " > " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int" + " " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " > " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E '<' E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " < " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t" + "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " < " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t" + "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo="bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " < " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_MA E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " >= " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + ">=" + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + ">=" + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_ME E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " <= " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + "<=" + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + "<=" + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_IG E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " == " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + "==" + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + "==" + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_DF E
            {
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " != " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    
                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + "!=" + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + "!=" + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_OU E
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }

                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " || " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " || " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " || " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_E E
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " && " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " && " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " && " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | E TK_NO E
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                //Condições para converter de Int para Float
                if ($1.tipo == "int" && $3.tipo == "float") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao = $1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $1.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $3.label + " ! " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel ="float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                
                else if ($1.tipo == "float" && $3.tipo == "int") {
                    string tempVar = geraLabel(); // Variável temporária para armazenar a conversão
                    $$.label = geraLabel();
                    $$.tipo = "bool";

                    $$.traducao =$1.traducao +  $3.traducao + "\t" + tempVar + " = (float)" + $3.label + ";\n";
                    $$.traducao += "\t" + $$.label + " = " + $1.label + " ! " + tempVar + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar + ";\n\t"+ "int " + $$.label;
                    temp.tipoVariavel = "float";
                    tabelaSimbolos.push_back(temp);
                } 
                
                else {
                    $$.label = geraLabel();
                    $$.tipo = "bool";
                    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
                        " = " + $1.label + " ! " + $3.label + ";\n";

                    // Atualizar tipo da temporária com base nos tipos dos operandos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.tipoVariavel = "int";
                    tabelaSimbolos.push_back(temp);
                }
            }
            | TK_CHAR
            {
                $$.tipo = "char";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "char";
                tabelaSimbolos.push_back(temp);
            }
            | TK_TIPO_BOOL
            {
                $$.tipo = "bool";
                $$.label = geraLabel();
                $$.traducao = "\t" + $$.label + " = "  + $1.traducao + ";\n";

                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "int";
                tabelaSimbolos.push_back(temp);
            }
            | TK_ID
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

                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "int";
                tabelaSimbolos.push_back(temp);
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

                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.tipoVariavel = "float";
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
    for(TIPO_SIMBOLO simbolo: tabelaSimbolos){
        cout<<"\t"+simbolo.tipoVariavel+" "+simbolo.nomeVariavel + ";" <<endl;
    }

}
