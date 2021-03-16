#include "Topconn.ch"
#include "Protheus.ch"

/*
Funcao      : M460NOTA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada chamado ap�s a grava��o dos dados da NFS
Autor       : Leandro Brito
Data        : 29/04/2016   
Obs         : 
TDN         : Este P.E. � chamado apos a Gravacao da NF de Saida, e fora da transa��o.
Revis�o     :                      
Obs         :                                                                                            
M�dulo      : Faturamento.
Cliente     : AOL
*/

*---------------------------------------*
User Function M460NOTA
*---------------------------------------*
Local aRecSE1   
Local aVetor                               
Local i  
Local aVetor
Local cFilBak

Private lMsErroAuto


If ( cEmpAnt == '73' ) 
	aRecSE1 := u_GetRecTit() //**  Fun��o criada em M460FIM.PRW
	If ValType( aRecSE1 ) == 'A'
		For i := 1 To Len( aRecSE1 )
			
			SE1->( DbGoTo( aRecSE1[ i ][ 1 ] ) )
			SF2->( DbGoTo( aRecSE1[ i ][ 2 ] ) )			
			aVetor :={ {"E6_FILDEB"	,SE1->E1_FILIAL,Nil},;
			{"E6_CLIENTE"	,SF2->F2_CLIENT,Nil},;
			{"E6_LOJA"	,SF2->F2_LOJENT,Nil},;
			{"AUTHISTDEB"	,'Transferencia Titulo ' + SF2->F2_DOC ,Nil}}
			
			lMsErroAuto := .F.
			Begin Transaction
			
			/*
			* O tratamento abaixo serve para manter as mesma configura��es de reten��o do cliente de origem
			* na gera��o do titulo de transferencia .
			*/
			
			MSExecAuto({|x,y| Fina620(x,y)},aVetor,3) //Inclusao de Solicita��o de transferencia
			
			if !lMsErroAuto
				aVetor :={{"E6_NUMSOL"	,SE1->E1_NUMSOL,Nil}}
				cFilBak := cFilAnt
				cFilAnt := SE6->E6_FILDEB
				MSExecAuto({|x,y| Fina630(x,y)},aVetor,3) //Aprova��o Automatica da transferencia
				cFilAnt := cFilBak
			endif
			
			End Transaction
			
			If lMsErroAuto
				Alert("Ocorreram erros ao transferir o titulo da NF " + SF2->F2_DOC + " para o cliente de cobran�a!Contatar a TI." )
				MostraErro()
			Endif
			
			
		Next
		u_GetRecTit( .T. )	
	EndIf
	 
EndIf

Return
