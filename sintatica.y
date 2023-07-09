%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <stack>

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
    stack<int>escopo;

} TIPO_SIMBOLO; 

//GLOBAIS

vector<TIPO_SIMBOLO> tabelaSimbolos;
int numBloco;
stack<int>escopoAtual;
int yylex(void);
void yyerror(string);
string geraLabel();
string contaBloco();
void imprimirTabelaDeSimbolos();
atributos tipoID(atributos a, atributos b,atributos c, string tipo);
atributos converteTipo(atributos a, atributos b, atributos c, string caracter);
void insereTabelaDeSimbolos(atributos a,  string tipo);
void insereID(atributos a,  string tipo);

void printpilhasdeSimbolos()
{
    for(int i = 0; i < tabelaSimbolos.size(); i++)
    {
        cout << "\t" << tabelaSimbolos[i].escopo.top()<< " " <<tabelaSimbolos[i].nomeVariavel<<endl;
    }
} 


%}

%token TK_NUM TK_REAL TK_CHAR TK_CAST_INT TK_CAST_FLOAT TK_MA TK_ME TK_DF TK_IG TK_OU TK_NO TK_E 
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_IF TK_ELSE TK_ELSE_IF TK_WHILE TK_INCREMENTO TK_DECREMENTO TK_FOR
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
                cout << $5.traducao << "\treturn 0;\n\n}" << endl;
                printpilhasdeSimbolos();
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
                $$.label = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao =$3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tIF(" + $$.label + ") GOTO FIM_IF;\n" + $5.traducao + "\tFIM_IF;\n\n";
            }
            |TK_ELSE_IF '(' E ')' BLOCO
            {
                $$.label = geraLabel();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao = $3.traducao + "\t" + $$.label + " != " + $3.label + ";\n"; 
                $$.traducao+="\tIF("+ $$.label + ") GOTO FIM_ELSE_IF;\n" + $5.traducao + "\tFIM_ELSE_IF;\n\n";
            }
            //else
            |CONDICAO TK_ELSE BLOCO
            {
                $$.traducao= $1.traducao + "\tIF(!" + $1.label + ") GOTO FIM_ELSE;\n" + $3.traducao + "\tFIM_ELSE;\n\n";
            }
            |
            TK_WHILE '(' E ')' BLOCO
            {
                $$.label = geraLabel();
                string tempVar = geraLabel();
                string numWhile = contaBloco();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao ="INICIO_WHILE "+ numWhile +":\n"+ $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n\t" + tempVar + " = !" + $$.label + "\n"; 
                $$.traducao+="\tIF(" + tempVar + ") GOTO FIM_WHILE"+ numWhile +";\n" + $5.traducao + "\tGOTO INICIO_WHILE"+ numWhile +"\n" +"FIM_WHILE " + numWhile + ";\n\n";
            }
            |TK_FOR '('CALC ';' E ';' CALC')' BLOCO
            {
                $$.label = geraLabel();
                string tempVar = geraLabel();
                string numFor = contaBloco();
                insereTabelaDeSimbolos($$,"int");
                $$.traducao ="INICIO_FOR "+ numFor +":\n"+ $3.traducao + $5.traducao + "\t" + $$.label + " = " + $5.label + ";\n\t" + tempVar + " = !" + $$.label + "\n"; 
                $$.traducao+="\tIF(" + tempVar + ") GOTO FIM_FOR"+ numFor +";\n" + $9.traducao + $7.traducao +"\tGOTO INICIO_FOR"+ numFor +"\n" +"FIM_FOR " + numFor + ";\n\n";
            }
            ;
COMANDO     : E ';'         
            |
            BLOCO
            |
            CONDICAO
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

E           : 
            CALC '+' CALC
            {
                $$ = converteTipo($1, $3,$$,"+");
            }
            | CALC '-' CALC
            {
                $$ = converteTipo($1, $3,$$,"-");
            }
            | CALC '*' CALC
            {
                $$ = converteTipo($1, $3,$$,"*");
            }
            | CALC '/' CALC
            {
                $$ = converteTipo($1, $3,$$,"/");
            }
            | CALC '>' CALC
            {
               $$ = converteTipo($1, $3,$$,">");
               //Convertendo o tipo para Bool nos relacionais para poder fazer comparação com os lógicos
               $$.tipo = "bool";
            }
            | CALC '<' CALC
            {
                $$ = converteTipo($1, $3,$$,"<");
                $$.tipo = "bool";
            }
            | CALC TK_MA CALC
            {
                $$ = converteTipo($1, $3,$$,">=");
                $$.tipo = "bool";
            }
            | CALC TK_ME CALC
            {
               $$ = converteTipo($1, $3,$$,"<=");
               $$.tipo = "bool";
            }
            | CALC TK_IG CALC
            {
                $$ = converteTipo($1, $3,$$,"==");
                $$.tipo = "bool";
            }
            | CALC TK_DF CALC
            {
                $$ = converteTipo($1, $3,$$," != ");
                $$.tipo = "bool";
            }
            | CALC TK_OU CALC
            {
               

                $$ = converteTipo($1, $3,$$," || ");
            }
            | CALC TK_E CALC
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                $$ = converteTipo($1, $3,$$," && ");
            }
            | CALC TK_NO CALC
            {
                if ($1.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                if ($3.tipo != "bool"){
                    yyerror("ERRO! Operação inválida");
                }
                $$ = converteTipo($1, $3,$$," ! ");
            }
            ;
CALC        : TK_CAST_INT CALC
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
            | TK_CAST_FLOAT CALC
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
                $$.tipo = "bool";
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
                    for (int i =  tabelaSimbolos.size(); i >= 0; i--){
                        if(tabelaSimbolos[i].nomeOriginal == $1.label && tabelaSimbolos[i].escopo.size() <= escopoAtual.size() && tabelaSimbolos[i].escopo.top()<= escopoAtual.top()){
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
                    temp.escopo = escopoAtual;
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
                else{
                $$.label = geraLabel();
                $$.traducao = $3.traducao + "\t" + variavel.nomeVariavel + " = " + $3.label + ";\n";}

            }
            | TK_ID TK_INCREMENTO
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
                    $$.traducao = "\t" + $$.label + " = " + $1.label + "++;\n";

                    // Adicionar variável temporária na tabela de símbolos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.nomeOriginal = $1.label;
                    temp.escopo = escopoAtual;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
                }
            }
            | TK_ID TK_DECREMENTO
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
                        yyerror("Variável não declarada!");}
                    }

                    $$.tipo = variavel.tipoVariavel; 
                    $$.label = geraLabel();
                    $$.traducao = "\t" + $$.label + " = " + $1.label + "--;\n";

                    // Adicionar variável temporária na tabela de símbolos
                    TIPO_SIMBOLO temp;
                    temp.nomeVariavel = $$.label;
                    temp.nomeOriginal = $1.label;
                    temp.escopo = escopoAtual;
                    temp.tipoVariavel = variavel.tipoVariavel;
                    tabelaSimbolos.push_back(temp);
                }
            }
            |TK_TIPO_INT TK_ID '=' CALC
            {
                $$ = tipoID($2, $4,$$,"int");
            }
            |TK_TIPO_CHAR TK_ID '=' CALC
            {
                $$ = tipoID($2, $4,$$,"char");
            }
            |TK_TIPO_BOOL TK_ID '=' CALC
            {
                $$ = tipoID($2, $4,$$,"bool");
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

//Diferenciar os loops dentro de outros loops
string contaBloco()
{
    static int i = 1;
    stringstream ss;
    ss << "" << i++;
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
        temp.tipoVariavel = "int";
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