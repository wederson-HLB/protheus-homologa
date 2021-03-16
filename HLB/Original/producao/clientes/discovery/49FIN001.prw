/*
Funcao      : 49FIN001
Parametros  : Nenhum
Retorno     : cReturno
Objetivos   : Cnab CitiBank gera informação de tipo de pagamento de acordo com o modelo do bordero.   
Autor     	: Joao.Silva
Data     	: 08/07/2015
Obs         : 
TDN         :
Módulo      : Financeiro.
*/
*-----------------------*
User Function 49FIN001()
*-----------------------*                     
Local cReturn
Local cModelo   
Pergunte ("AFI420",.F.)   

DbSelectArea("SEA")   
DbSetOrder(1)//EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
DbGoTop()   
If DbSeek(xFilial("SEA")+MV_PAR01)
	cModelo := AllTrim(SEA->EA_MODELO) 
Else
	MsgInfo('Bordero não localizado','HLB BRASIL')
	Return()	
EndIf 

If     cModelo $ "03"// DOC
	cReturn :="071"
ElseIf cModelo $ "01"// Tranferencia entre contas
	cReturn :="072"
ElseIf cModelo $ "02"// Cheque administrativo
	cReturn :="073"			
ElseIf cModelo $ "31"// Pagamento
	cReturn :="081"		  
ElseIf cModelo $ "41"// TED
	cReturn:="083"	                                     		
EndIf	
	
Return(cReturn)