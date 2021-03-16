#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : MA415LEG
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada para alterar cores da legenda 
Autor       : Tiago Luiz Mendonça
Data        : 16/09/2014
Revisão     :        
Data        : 
Módulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function MA415LEG()   
*----------------------* 

Local aCores := {	{ 'ENABLE'    , 'Orcamento em Aberto' },; //'Orcamento em Aberto'
					{ 'DISABLE'   , 'Orcamento Baixado'   },; //'Orcamento Baixado'
					{ 'BR_PRETO'  , 'Orcamento Cancelado' },; //'Orcamento Cancelado' 	
					{ 'BR_AMARELO', 'Orcamento nao Orcado'},; //'Orcamento nao Orcado'
					{ 'BR_MARROM' , 'Orcamento bloqueado' }}  //'Orcamento bloqueado'

If cEmpAnt == "TM"  
     aCores := {	{ 'ENABLE'    , 'Orcamento Revisado'  },; //'Orcamento em Aberto'
					{ 'DISABLE'   , 'Orcamento Baixado'   },; //'Orcamento Baixado'
					{ 'BR_PRETO'  , 'Orcamento Cancelado' },; //'Orcamento Cancelado' 	
					{ 'BR_AMARELO', 'Orcamento nao Orcado'},; //'Orcamento nao Orcado'
					{ 'BR_MARROM' , 'Orcamento bloqueado' },;  //'Orcamento bloqueado'     
					{ 'BR_AZUL'   , 'Orcamento Aberto'    }}  //'Orcamento bloqueado'     

EndIf 

Return aCores