#include "Protheus.ch"
#include "Topconn.ch" 

/*
Funcao      : JKFAT012
Parametros  : nOpc
Retorno     : lLib
Objetivos   : Realiza liberação de Lote do Produto para Venda - RRP - 28/11/2013 - Solicitação Mabra. Chamado 015210
Autor       : Innovare Solucoes
Data        : 10/28/2013
Cliente     : Mabra
*/
*-----------------------------* 
 User Function JKFAT012(nOpc)
*-----------------------------*
Private lLib := .F.      
Private oSenha
Private oDlg
Private cSenhaAut:= Space(40)
Private oFont:= TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)   // 12  

// Monta Tela para Digitação de Senha de liberação de uso do produto. 

DEFINE MSDIALOG oDlg FROM 2  ,3 TO 200,300 TITLE 'Liberação de Lote' Pixel
						
@10,25 Say "Digite sua Senha de Liberação " Font oFont Pixel of oDlg
               
@40,25 get oSenha Var cSenhaAut Size 100,10 Password Pixel of oDlg

@70,40 BUTTON OemToAnsi('Confirma') SIZE 30,15 ACTION (JKFAT013(cSenhaAut)) OF oDlg PIXEL
@70,90 BUTTON OemToAnsi('Cancelar') SIZE 30,15 ACTION (oDlg:End()) OF oDlg PIXEL

Activate MsDialog oDlg Centered 

Return lLib

/*
Funcao      : JKFAT013
Parametros  : cValSenha
Retorno     : T
Objetivos   : Libera Utilização de lote
Autor       : Innovare Solucoes
Data        : 10/28/2013
Cliente     : Mabra
*/ 
*------------------------------------* 
 Static Function JKFAT013(cValSenha)
*------------------------------------* 

Local cPosLote :=  aScan(aHeader, {|x| Alltrim(x[2]) == "C6_P_PBLQL"})  

if Alltrim(cValSenha) == Alltrim(GetMv("MV_XPSWLOT"))

	aCols[n,cPosLote] := "N" 
    lLib:= .T.
    oDlg:End()//
Else
	MsgInfo("Senha Invalida !","Atenção")
	Return .F.
Endif

Return .T. 

/*
Funcao      : JKFAT014
Parametros  : Nenhum
Retorno     : T
Objetivos   : Apaga conteudo do campo Blq Lote sempre que lote for informado
Autor       : Innovare Solucoes
Data        : 10/28/2013
Cliente     : Mabra
*/ 
*-------------------------*     
 User Function JKFAT014()
*-------------------------*          

Local cPosLote :=  aScan(aHeader, {|x| Alltrim(x[2]) == "C6_P_PBLQL"})  
   
aCols[n,cPosLote] := "" 

Return .T.