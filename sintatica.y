%{
#include <iostream>
#include <sstream>
#include <vector>
#include <stack>
#include <set>
#include <cstring>
#include <cstdlib>
#include <string>
#include <string.h>

#define YYSTYPE atributos

using namespace std;

typedef struct 
{
    std::string label;
    std::string traducao;
    std::string tipo;
} atributos; 

typedef struct
{
    string nomeVariavel;
    string tipoVariavel;
    string nomeOriginal;
    stack<int>escopo;
    int valor;

} TIPO_SIMBOLO;

typedef struct
{
    std::string variavel;
} FREE;

//GLOBAIS

vector<TIPO_SIMBOLO> tabelaSimbolos;
std::vector<FREE> tipoFree;
static int cont = 0;
static int TamanhoString = 0;
static int SomaString = 0;
int numBloco;
stack<int>escopoAtual;
int yylex(void);
void yyerror(string);
string geraLabel();
void imprimirTabelaDeSimbolos();
void imprimirFree();
atributos tipoID(atributos a, atributos b,atributos c, string tipo);
atributos converteTipo(atributos a, atributos b, atributos c, string caracter);
void insereTabelaDeSimbolos(atributos a,  string tipo);
void insereTabelaDeSimbolosString(atributos a,int b,  string tipo);
void insereFree(string nome);
void insereID(atributos a,  string tipo);
void alocaMemoria(atributos &a, int tamanho);
void liberaMemoria(atributos &a);

/*void printpilhasdeSimbolos()
{
    for(int i = 0; i < tabelaSimbolos.size(); i++)
    {
        cout << "\t" << tabelaSimbolos[i].escopo.top()<< " " <<tabelaSimbolos[i].nomeVariavel<<endl;
    }
} */


%}

%token TK_NUM TK_REAL TK_CHAR TK_CAST_INT TK_CAST_FLOAT TK_MA TK_ME TK_DF TK_IG TK_OU TK_NO TK_E TK_CONTINUE TK_BREAK TK_TIPO_STRING TK_STRING
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_PRINTF TK_SWITCH TK_CASE
%token TK_FIM TK_ERROR TK_IF TK_ELSE TK_ELSE_IF TK_WHILE TK_INCREMENTO TK_DECREMENTO TK_FOR TK_DO

%start S

//Ordem de precedência 
%left TK_E TK_OU TK_NO 
%left '>' '<'  TK_MA TK_ME TK_IG TK_DF 
%left '+' '-' 
%left '*' '/' 


%%

S           : TK_TIPO_INT TK_MAIN '('')' BLOCO
            {
                cout << "\n\n//Xxx---COMPILADOR J.M.B---xxX\n" << "#include<stdlib.h>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n";
                imprimirTabelaDeSimbolos();
                cout << $5.traducao;
                imprimirFree();
                cout<<"\treturn 0;\n\n}" << endl;
                //printpilhasdeSimbolos();
            }
            ;

BLOCO       : '{'INICIO COMANDOS FIM'}'
            {
                $$.traducao = $3.traducao ;
                
            }
            ;
INICIO      : 
            {
                //Diferenciar o número dos blocos
                numBloco++;
                escopoAtual.push(numBloco);
                $$.traducao = "";
            }
            ;
FIM         :
            {
                escopoAtual.pop();
                $$.traducao = "";
    
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
            //IF
CONDICAO    :TK_IF '(' E ')' BLOCO
            {
                cont ++;
                $$.label = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao =$3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tif(" + $$.label + ") goto fim_if_Label" + to_string(cont) + ";\n" + $5.traducao + "\tfim_if_Label"+ to_string(cont) +":\n\n";
            }
            |TK_ELSE_IF '(' E ')' BLOCO
            {
                $$.label = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao = $3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tif("+ $$.label + ") goto fim_else_if_Label" + to_string(cont) + ";\n" + $5.traducao + "\tfim_else_if_Label" + to_string(cont) + ":\n\n";
            }
            //else
            |CONDICAO TK_ELSE BLOCO
            {
                $$.traducao= $1.traducao + "\tif(!" + $1.label + ") goto fim_else_Label" + to_string(cont) + ";\n" + $3.traducao + "\tfim_else_Label" + to_string(cont) + ";\n\n";
            }
            |TK_SWITCH '(' E ')' '{'INICIO COMANDOS BREAK1 FIM'}'
            {
                $$.label = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao = $3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tif("+ $$.label + ") goto fim_else_if_Label" + to_string(cont) + ";\n" + $5.traducao + "\tfim_else_if_Label" + to_string(cont) + ":\n\n";
            }
            ;

LOOP        : 
            TK_WHILE '(' E ')' '{'INICIO COMANDOS BREAK1 FIM'}'
            {
                
                $$.label = geraLabel();
                string tempVar = geraLabel();
                insereTabelaDeSimbolos($$,"int");

                //Adicionando na tabela de simbolos a temporária que verifica se while é verdadeiro.
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = tempVar;
                temp.tipoVariavel = "int";
                temp.escopo = escopoAtual;
                tabelaSimbolos.push_back(temp); 

                $$.traducao ="inicio_while"+ to_string(cont) +":\n"+ $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n\t" + tempVar + " = !" + $$.label + ";\n"; 
                $$.traducao+="\tif(" + tempVar + ") goto fim_Label"+ to_string(cont)  +";\n" + $7.traducao + $8.traducao + "\tgoto inicio_while"+ to_string(cont) +";\n" +"fim_Label" + to_string(cont) + ":\n";
            }
            |TK_FOR '('E ';' E ';' E')' '{'INICIO COMANDOS BREAK1 FIM'}'
            {
                $$.label = geraLabel();
                string tempVar = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao ="inicio_for"+ to_string(cont) +":\n"+ $3.traducao + $5.traducao + "\t" + $$.label + " = " + $5.label + ";\n\t" + tempVar + " = !" + $$.label + ";\n"; 
                $$.traducao+="\tif(" + tempVar + ") goto fim_Label"+ to_string(cont) +";\n" + $11.traducao + $12.traducao + $7.traducao +"\tgoto inicio_for"+ to_string(cont) +";\n" +"fim_Label" + to_string(cont) + ":\n\n";

                //Adicionando na tabela de simbolos a temporária que verifica se while é verdadeiro.
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = tempVar;
                temp.tipoVariavel = "int";
                temp.escopo = escopoAtual;
                tabelaSimbolos.push_back(temp);
            }
            |TK_DO '{'INICIO COMANDOS BREAK1 FIM '}' TK_WHILE '(' E ')' ';'
            {
                $$.label = geraLabel();
                string tempVar = geraLabel();
                insereTabelaDeSimbolos($$,"int");

                $$.traducao ="inicio_do_while"+ to_string(cont) +":\n"+ $4.traducao + $5.traducao; 
                $$.traducao+=$10.traducao + "\tif(" + $10.label + ") goto inicio_do_while"+ to_string(cont) + "\n";
            }
            ;

            //break e continue pro while
BREAK1       : TK_BREAK ';' COMANDOS BREAK1
            {
                
                $$.traducao = "\tgoto fim_Label" + to_string(cont) + ";\n" + $3.traducao + $4.traducao;
            }
            |
            TK_CONTINUE ';' COMANDOS BREAK1
            {
                $$.traducao = "\tgoto fim_Label" + to_string(cont) + ";\n" + $3.traducao + $4.traducao;
            }
            |
            {
                cont ++;
                $$.traducao = "";
            }
            ;

COMANDO     : E ';'         
            |
            BLOCO 
            |
            LOOP
            |
            TK_CASE
            |
            CONDICAO
            | TK_TIPO_INT TK_ID ';'
            {
                insereID($2,"int");

                $$.traducao = "";
                $$.label = ""; 
            }
            | TK_TIPO_STRING TK_ID ';'
            {
                insereID($2,"char*");

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
                insereID($2,"bool");

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
                // Verifica se os operandos são strings
                if ($1.tipo == "char*" || $3.tipo == "char*") {
                    TIPO_SIMBOLO variavel;

                    $$.tipo = "char*";
                    $$.label = geraLabel();
                    $$.traducao =  $1.traducao + $3.traducao +"\t" +  $$.label + " = strcat(" +$1.label + ","+ $3.label +");\n";

                    
                    // Adicionar variável temporária na tabela de símbolos
                    insereTabelaDeSimbolos($$,"char*");
                }
                else{
                $$ = converteTipo($1, $3,$$,"+");
                }
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
            | '(' E ')' 
            {
                $$.tipo = $2.tipo;
                $$.label = geraLabel();
                $$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + ";\n";

                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.escopo = escopoAtual;
                temp.tipoVariavel = $2.tipo;
                tabelaSimbolos.push_back(temp);
            }
            | TK_PRINTF '(' E ')' 
            {
                $$.tipo = $2.tipo;
                $$.label = geraLabel();
                $$.traducao = $3.traducao + "\t" + "cout <<" + $3.label + "<<endl;\n";

                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label;
                temp.escopo = escopoAtual;
                temp.tipoVariavel = $3.tipo;
                tabelaSimbolos.push_back(temp);
            }
            |TK_STRING
            {
                $$.tipo = "string";
                $$.label = geraLabel();
                TamanhoString = $1.traducao.size() - 1;
                $$.traducao = "\tstrcpy(" + $$.label + ", " + $1.traducao + ");\n";

                SomaString += $1.traducao.size() - 1;
                // Adicionar variável temporária na tabela de símbolos
                insereTabelaDeSimbolosString($$,TamanhoString,"char");
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
                        //Verificações pra ver se a variavel foi declarada ou não
                    for (int i = tabelaSimbolos.size();i>=0; i--){

                        //Condição para aceitar se a varíavel foi declarada no seu bloco
                        if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() == escopoAtual.size() && tabelaSimbolos[i].escopo.top()== escopoAtual.top())){
                            variavel = tabelaSimbolos[i];
                            encontrei = true;
                            goto NaoEncontrar1;
                        }
                        //Caso a variável não seja declarada no seu próprio Bloco, ela irá ser associada ao bloco mais próximo dela, seu pai estático;
                            int menorBloco = -1;
                            int indiceMenorBloco = -1;
                            for (int i = 0; i < tabelaSimbolos.size(); i++) {
                                if (tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() <= escopoAtual.size() && tabelaSimbolos[i].escopo.top() <= escopoAtual.top()) {
                                    if (tabelaSimbolos[i].escopo.size() < menorBloco) {
                                        menorBloco = tabelaSimbolos[i].valor;
                                        indiceMenorBloco = i;
                                    }
                                }
                            }
                            if (indiceMenorBloco != -1) {
                                variavel = tabelaSimbolos[indiceMenorBloco];
                                encontrei = true;
                            }
                    }
                    NaoEncontrar1:
                    if(!encontrei){
                        yyerror("Variavel não declarada!");
                    }

                 if(variavel.tipoVariavel=="char*" || $1.tipo =="string")
		        {
                    $$.tipo="char*";
                    string tempVar = geraLabel();
		        	$$.label = geraLabel();
                    $$.traducao = "\tstrcpy("+ $$.label +","+ variavel.nomeVariavel + ");\n";
		        }
                else{
                    $$.tipo = variavel.tipoVariavel; 
                    $$.label = geraLabel();
                    $$.traducao = "\t" + $$.label + " = " + variavel.nomeVariavel + ";\n";
                }
                    // Adicionar variável temporária na tabela de símbolos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.nomeOriginal = $1.label;
                    temp.escopo = escopoAtual;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | TK_ID '=' E 
            {
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 

                //Verificações pra ver se a variavel foi declarada ou não
                for (int i = tabelaSimbolos.size();i>=0; i--){

                    //Condição para aceitar se a varíavel foi declarada no seu bloco
                    if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() == escopoAtual.size() && tabelaSimbolos[i].escopo.top()== escopoAtual.top())){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                        goto NaoEncontrar;
                    }
                    //Caso a variável não seja declarada no seu próprio Bloco, ela irá ser associada ao bloco mais próximo dela, seu pai estático;
                        int menorBloco = -1;
                        int indiceMenorBloco = -1;
                        for (int i = 0; i < tabelaSimbolos.size(); i++) {
                            if (tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() <= escopoAtual.size() && tabelaSimbolos[i].escopo.top() <= escopoAtual.top()) {
                                if (tabelaSimbolos[i].escopo.size() < menorBloco) {
                                    menorBloco = tabelaSimbolos[i].valor;
                                    indiceMenorBloco = i;
                                }
                            }
                        }
                        if (indiceMenorBloco != -1) {
                            variavel = tabelaSimbolos[indiceMenorBloco];
                            encontrei = true;
                        }
                }
                NaoEncontrar:
                if(!encontrei){
                    yyerror("Variavel não declarada!");
                }

                //Retornar erro se tentar atribuir bool ou char com outro tipo
                if(variavel.tipoVariavel=="bool" && $3.tipo !="bool" || variavel.tipoVariavel=="char" && $3.tipo =="float" || variavel.tipoVariavel=="char" && $3.tipo =="int" || $3.tipo=="bool" && variavel.tipoVariavel !="bool" || $3.tipo=="char" && variavel.tipoVariavel !="char"){
                    yyerror("Atribuição inválida!!!");
                }
                if(variavel.tipoVariavel=="int" && $3.tipo =="float")
		        {
                    string tempVar = geraLabel();
		        	$$.label = geraLabel();
                    $$.traducao = $3.traducao + "\t" + tempVar + " = (int)"+ $3.label + ";\n\t" + variavel.nomeVariavel + " = " + tempVar + ";\n";

                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar;
                    temp.escopo = escopoAtual;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
		        }
                else if(variavel.tipoVariavel=="float" && $3.tipo =="int")
		        {
                    string tempVar = geraLabel();
		        	$$.label = geraLabel();
                    $$.traducao = $3.traducao + "\t" + tempVar + " = (float)"+$3.label + ";\n\t" + variavel.nomeVariavel + " = " + tempVar + ";\n";

                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = tempVar;
                    temp.escopo = escopoAtual;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
		        }
                else if(variavel.tipoVariavel=="char*" && $3.tipo =="string")
		        {
                    $$.tipo = "char*";
                    string tempVar = geraLabel();
		        	$$.label = geraLabel();
                    TamanhoString = TamanhoString + 0;
                    $$.traducao = $3.traducao + "\t" + variavel.nomeVariavel + " = (char*) malloc(" + to_string(TamanhoString) + ");\n\tstrcpy("+variavel.nomeVariavel+","+$3.label + ");\n";
                    
                    insereFree(variavel.nomeVariavel);
		        }
                else if(variavel.tipoVariavel=="char*" && $3.tipo =="char*")
		        {
                    $$.tipo = "char *";
                    string tempVar = geraLabel();
		        	$$.label = geraLabel();
                    $$.traducao = $3.traducao + "\t" + variavel.nomeVariavel + " = (char*) malloc(" + to_string(SomaString-1) + ");\n\tstrcpy("+variavel.nomeVariavel+","+$3.label + ");\n";
                    
                    
                    insereFree(variavel.nomeVariavel);
		        }
                else{
                $$.label = geraLabel();
                $$.traducao = $3.traducao + "\t" + variavel.nomeVariavel + " = " + $3.label + ";\n";}

            }
            | TK_ID TK_INCREMENTO
            {
            
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 
                for (int i = tabelaSimbolos.size();i>=0; i--){
                    if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() == escopoAtual.size() && tabelaSimbolos[i].escopo.top()== escopoAtual.top())){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                        break;
                    }
                    else if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() <= escopoAtual.size() && tabelaSimbolos[i].escopo.top()<= escopoAtual.top())){
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
                string um = geraLabel();
                $$.traducao = "\t"+ um + " = 1;\n\t" + $$.label + " = " + variavel.nomeVariavel + "+" + um+ ";\n";
                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label + ";\n\tint " + um;
                temp.nomeOriginal = $1.label;
                temp.escopo = escopoAtual;
                temp.tipoVariavel = variavel.tipoVariavel;
                tabelaSimbolos.push_back(temp);
                
            }
            | TK_ID TK_DECREMENTO
            {
                
                bool encontrei = false; 
                TIPO_SIMBOLO variavel; 
                for (int i = tabelaSimbolos.size();i>=0; i--){
                    if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() == escopoAtual.size() && tabelaSimbolos[i].escopo.top()== escopoAtual.top())){
                        variavel = tabelaSimbolos[i];
                        encontrei = true;
                        break;
                    }
                    else if((tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() <= escopoAtual.size() && tabelaSimbolos[i].escopo.top()<= escopoAtual.top())){
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
                string um = geraLabel();
                $$.traducao = "\t"+ um + " = 1;\n\t" + $$.label + " = " + variavel.nomeVariavel + "-" + um+ ";\n";
                // Adicionar variável temporária na tabela de símbolos
                TIPO_SIMBOLO temp;
                temp.nomeVariavel = $$.label + ";\n\tint " + um;
                temp.nomeOriginal = $1.label;
                temp.escopo = escopoAtual;
                temp.tipoVariavel = variavel.tipoVariavel;
                tabelaSimbolos.push_back(temp);
            }
            |TK_TIPO_INT TK_ID '=' E
            {
                $$ = tipoID($2, $4,$$,"int");
            }
            |TK_TIPO_CHAR TK_ID '=' E
            {
                $$ = tipoID($2, $4,$$,"char");
            }
            |TK_TIPO_BOOL TK_ID '=' E
            {
                $$ = tipoID($2, $4,$$,"bool");
            }
            |TK_TIPO_STRING TK_ID '=' E
            {
                $$ = tipoID($2, $4,$$,"char*");
            }
            |TK_TIPO_FLOAT TK_ID '=' E
            {
                $$ = tipoID($2, $4,$$,"float");
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
    numBloco = 0;
    escopoAtual.push(numBloco);
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
    temp.escopo = escopoAtual;
    tabelaSimbolos.push_back(temp);  
};

void insereTabelaDeSimbolosString(atributos a,int b, string tipo){
    TIPO_SIMBOLO temp;
    temp.nomeVariavel = a.label + '['+  to_string(b)  + ']';
    temp.tipoVariavel = tipo;
    temp.escopo = escopoAtual;
    tabelaSimbolos.push_back(temp);  
};

/*void alocaMemoria(atributos &a, int tamanho)
{
    a.traducao += "\t" + a.label + " = (" + a.tipo + "*)malloc(sizeof(" + a.tipo + ") * " + to_string(tamanho) + ");\n";
}*/

/*void liberaMemoria(atributos &a)
{
    a.traducao += "\tfree(" + a.label + ");\n";
} */

//Inserindo os tokens de ID na tabela de símbolos
void insereID(atributos a,string tipo){
    TIPO_SIMBOLO temp;
    temp.nomeVariavel = geraLabel();
    temp.escopo = escopoAtual;
    temp.nomeOriginal = a.label;
    temp.tipoVariavel = tipo; 
    
    for(int i = 0; i < tabelaSimbolos.size(); i++)
	{
		if(tabelaSimbolos[i].nomeOriginal == temp.nomeOriginal && tabelaSimbolos[i].escopo.top() == escopoAtual.top())
		{
			yyerror("Variavel já declarada!");
		}
	}
    tabelaSimbolos.push_back(temp);
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
        temp.escopo = escopoAtual;
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
        temp.escopo = escopoAtual;
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
        temp.escopo = escopoAtual;
        temp.tipoVariavel = c.tipo;
        tabelaSimbolos.push_back(temp);
    }
    return c;
}

atributos tipoID(atributos a, atributos b,atributos c, string tipo){
    // Adicionar variável temporária na tabela de símbolos
    TIPO_SIMBOLO temp;
    temp.nomeVariavel = geraLabel();
    temp.escopo = escopoAtual;
    temp.nomeOriginal = a.label;
    temp.tipoVariavel = tipo;
        
     for(int i = 0; i < tabelaSimbolos.size(); i++)
	{
		if(tabelaSimbolos[i].nomeOriginal == temp.nomeOriginal && tabelaSimbolos[i].escopo.top() == escopoAtual.top())
		{
			yyerror("Variavel já declarada!");
		}
	}
    tabelaSimbolos.push_back(temp);
    //Retornar erro se tentar atribuir bool ou char com outro tipo
    if(temp.tipoVariavel=="bool" && b.tipo !="bool" || temp.tipoVariavel=="char" && b.tipo !="char" || b.tipo=="bool" && temp.tipoVariavel !="bool" || b.tipo=="char" && temp.tipoVariavel !="char"){
        yyerror("Atribuição inválida!!!");
    }

    //Conversão int p Float 
    if(temp.tipoVariavel=="int" && b.tipo =="float")
	{
        string tempVar = geraLabel();
		c.label = geraLabel();
        c.traducao = b.traducao + "\t" + tempVar + " = (int)"+b.label + ";\n\t" + temp.nomeVariavel + " = " + tempVar + ";\n";
        TIPO_SIMBOLO temp;
        temp.nomeVariavel = tempVar;
        temp.escopo = escopoAtual;
        temp.tipoVariavel = "int";
        tabelaSimbolos.push_back(temp);
	}
    //Conversão de Float p Int
    else if(temp.tipoVariavel=="float" && b.tipo =="int")
	{
        string tempVar = geraLabel();
		c.label = geraLabel();
        c.traducao = b.traducao + "\t" + tempVar + " = (float)"+b.label + ";\n\t" + temp.nomeVariavel + " = " + tempVar + ";\n";
        TIPO_SIMBOLO temp;
        temp.nomeVariavel = tempVar;
        temp.escopo = escopoAtual;
        temp.tipoVariavel = "float";
        tabelaSimbolos.push_back(temp);
	}
    else{
        c.tipo = temp.tipoVariavel; // Usar o tipo da variável original
        a.label = temp.nomeOriginal;
        c.traducao = b.traducao + "\t" + temp.nomeVariavel + " = " + b.label + ";\n";
    }
    return c;

}

void imprimirTabelaDeSimbolos()
{
    for(TIPO_SIMBOLO simbolo: tabelaSimbolos){
        cout<<"\t"+simbolo.tipoVariavel+" "+simbolo.nomeVariavel + ";" <<endl;
    }
}

void imprimirFree() {
    std::set<std::string> variaveisImpressas; // Para rastrear as variáveis já impressas

    for (FREE temp : tipoFree) {
        // Verifica se a variável já foi impressa antes
        if (variaveisImpressas.find(temp.variavel) == variaveisImpressas.end()) {
            // Se a variável não estiver no conjunto, ela não foi impressa antes
            variaveisImpressas.insert(temp.variavel); // Adiciona a variável ao conjunto
            std::cout << "\tfree(" << temp.variavel << ");" << std::endl;
        }
    }
}

void insereFree(string nome){
    FREE temp;
    temp.variavel = nome;
    tipoFree.push_back(temp); 
};