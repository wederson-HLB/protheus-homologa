#Include "Rwmake.ch"  

/*
Funcao      : MT410INC 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. chamado após a gravação dos dados da NFS 
Autor       : José Augusto Pereira Alves
Data/Hora   : 14/03/2008     
Obs         : 
TDN         : Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). Está localizado na rotina de alteração do pedido, A410INCLUI(). É executado após a gravação das informações.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/02/2012
Obs         : Empresas do grupo GT foram tiradas do fonte assim como os não clientes - F2/Creata, etc.
Módulo      : Faturamento.
Cliente     : Haulotte / WDF / Victaulic   
*/

*-------------------------*
 User function MT410INC() 
*-------------------------*
 
Local nItem     := 0   
Local nValor    := 0   
Local nValor3RD := 0

Local cItem     := ''                      

If cEmpAnt $ "JN"  //Haulotte

   If MsgYesNo("Insere texto p\ emissao na NF ?","Haulotte")
      fInsereTxt()
   EndIf

ElseIf SM0->M0_CODIGO $ "S8/S9" //WDF
   
   If !Empty(M->C5_P_REFNB)
      DbSelectArea("CTD")
      CTD->(DbSetOrder(1))
      CTD->(DbGoTop())
      If !(CTD->(DbSeek(xFilial("CTD")+M->C5_P_REFNB)))
         RecLock("CTD",.T.)
         CTD->CTD_FILIAL  := xFilial("CTD") 
         CTD->CTD_ITEM    := M->C5_P_REFNB
         CTD->CTD_CLASSE  := "2" 
         CTD->CTD_NORMAL  := "1" 
         CTD->CTD_DESC01  := "REF NBR " + M->C5_P_REFNB
         CTD->CTD_BLOQ    := "2"
         CTD->CTD_DTEXIS  := CTOD('01/01/80')
         CTD->CTD_ITLP    := "0"
         CTD->CTD_CLOBRG  := "2"         
         CTD->CTD_ACCLVL  := "1"         
         CTD->(MsUnlock())
      EndIf
   EndIF

//JSS -Inicio 
//Criado Workflow inclusão de pedidos para Empresa: 'Victaulic' Cod.: 'TM'     

ElseIf cEmpAnt $ "9Y/TM"
         
	//TLM - 30/06/2014 - Retirado TM desse workflow, tratamento será no orçamento, fonte MT416FIM 	
	If Substr(GetEnvServer(),1,6)=="P11_16" //.And. cEmpAnt=="TM" //CAS - 06/12/2019 - Comentado parte para Adicionar TM nesse workflow.
		Return
	EndIf
	                             
	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
   
	cEmail  += 'Inclusao do pedido:  '+'<b>'+ M->C5_NUM+'</b>'+' pelo colaborador:   '+'<b>'+SUBS(CUSUARIO,7,15)+'</b>'                                                                   
	cEmail  += '<br><br>'   
	cEmail  += '<b>'+'Composto pelos itens :'+'</b>'   
	cEmail  += '<br><br>'
	
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+SC6->C6_NUM))
   			cEmail+='<table border= "0">' 
   			
		While SC6->C6_NUM == M->C5_NUM
	 		cEmail+='<tr>'
			cEmail+='<td><b>Produto:</b>'+alltrim(SC6->C6_PRODUTO)+'</td>'
			cEmail+='<td><b> Sequencia: </b></td><td>'+SC6->C6_ITEM+'</td>'
			cEmail+='<td><b>'+'QTD: '+'</b></td><td>'+cValToChar(SC6->C6_QTDVEN)+'</td>'
			cEmail+='<td><b>'+'Vlr. Unit: '+'</b></td><td>'+cValToChar(SC6->C6_PRCVEN)+'</td>'
			cEmail+='<td><b>'+'Vlr. Total: '+'</b></td><td>'+cValToChar(SC6->C6_VALOR)+'</td>'			
		    cEmail+='</tr>'
			SC6->(DbSkip())
	    
			nItem ++
		EndDo 
		cEmail+='<tr>'
		cEmail+='<td><br><br></td>' 
		cEmail+='</tr>'   
		
		cEmail+='<tr>'                  
		If Alltrim(M->C5_P_PARC) == 'S'	
			cEmail+='<td><b> Quantidade de itens: '+cValToChar(nItem)+'</b></td>'
   			cSubject:= 'INCLUSAO PEDIDO:  '+ M->C5_NUM + ' / PARCIAL '
		Else
			cEmail+='<td><b> Quantidade de itens: '+cValToChar(nItem)+'</b></td>' 
			cSubject:= 'INCLUSAO PEDIDO:  '+ M->C5_NUM + ' / TOTAL'		
		EndIf		
		cEmail+='</tr>'			

		cEmail+='</table>'
			
	EndIf
		
	cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e nao pode ser respondida.</p> '
    cEmail += '<p align="center">www.hlb.com.br</p>'
    cEmail += '</body></html>'


	oEmail          :=  DEmail():New()
	oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
	//oEmail:cTo		:=  "joao.silva@hlb.com.br"   
	oEmail:cTo	:=  AllTrim(GetMv("MV_P_EMAI0"))  
	oEmail:cSubject	:=	cSubject
	oEmail:cBody   	:= 	cEmail
	//oEmail:cAnexos:=  cFile
	oEmail:Envia()                                 


EndIF  
//JSS - Fim

Return

*----------------------------*
 Static Function fInsereTxt()           
*----------------------------*

_cLinha1:=Space(130)
_cLinha2:=Space(130)
_cLinha3:=Space(130)
_cLinha4:=Space(130)
_cLinha5:=Space(130)

@ 0,0 To 190,900 Dialog oDlg Title "Haulotte - Texto livre "
@ 002,002 To 075,450

@ 010,005 Get _cLinha1 Picture "@!" Size 440,250 
@ 023,005 Get _cLinha2 Picture "@!" Size 440,250 
@ 036,005 Get _cLinha3 Picture "@!" Size 440,250 
@ 049,005 Get _cLinha4 Picture "@!" Size 440,250 
@ 062,005 Get _cLinha5 Picture "@!" Size 440,250 

@ 080,410 BmpButton Type 01 Action fGrava()
@ 080,340 BmpButton Type 02 Action Close(oDlg)

Activate Dialog oDlg  Centered    

Return                                   

*------------------------*
 Static Function fGrava()
*------------------------*

Close(oDlg)
_cLinha:=_cLinha1+_cLinha2+_cLinha3+_cLinha4+_cLinha5

SZ1->(DbSetOrder(1))
If! DbSeek(xFilial("SZ1")+SC5->C5_NUM)
   Reclock("SZ1",.T.)
   Replace SZ1->Z1_FILIAL With xFilial("SZ1")
   Replace SZ1->Z1_PEDIDO With SC5->C5_NUM
   Replace SZ1->Z1_OBS    With _cLinha
   MsUnlock()
EndIf

Return