#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS010   º Autor ³ William Souza      º Data ³  04/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ User function para fazer a liberação de estoque do pedido  º±±
±±º          ³ de venda                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------*
User Function N6WS010(aParam)
*---------------------------*
Local cAreaSC5     := ""
Local cSql         := ""
Local cLogErro     := "" 
Local lJob	       := Type( 'oMainWnd' ) != 'O'
Local cEmp         := "" 
Local cFil		   := "" 
Local aPvlNfs 	   := {}
Local aBloqueio    := {}
Local aRet         := {}
Local cData        := ""
Local chora        := ""
Local cfil         := ""

//rotina para deixar a função para ser chamada via menu.
If lJob 
	If ( Valtype( aParam ) != 'A' )
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[ 01 ]
		cFil := aParam[ 02 ]	
	EndIf

	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
EndIf     

//Verifica se tem pedidos que tiveram problema de estoque e faz verificação 
cAreaSC5:= "SC5N6WS010"//GetNextAlias()
cData	:= dtoc(ddatabase)
chora	:= Time() 
                             
If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf

cSql := "SELECT C5_NUM,C5_P_CHAVE 
cSql += " FROM "+retsqlname("SC5")
cSql += " WHERE C5_P_STFED = '' AND C5_P_DTFED = '' AND C5_P_CHAVE <> '' AND C5_FILIAL = '"+cFil+"' AND D_E_L_E_T_ = ''
cSql += " ORDER BY R_E_C_N_O_ DESC" 
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cSql)), cAreaSC5, .F., .T.) 

While !(cAreaSC5)->(Eof())
	cLogErro	:= "" 
	aBloqueio	:={}
	aPvlNfs		:={}

	DbSelectArea("SC5")
	DbSetorder(1)
	SC5->(DbSeek(xFilial("SC5") + (cAreaSC5)->C5_NUM))
	aRet := u_retSB2(SC5->C5_NUM,cfil,"2") 

	If len(aRet) == 0  
		// Liberacao de pedido
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)

		// Checa itens liberados			
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)    

		//Verificação de Saldo em Estoque (Rotina Padrão) 
		If Empty(aBloqueio) .And. !Empty(aPvlNfs) 
		    If cfil == "02"	
		  		//Envio do Picking list para a Fedex
	  			u_N6WS004((cAreaSC5)->C5_P_CHAVE) 
		  	Else
		   		TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='03',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE='"+(cAreaSC5)->C5_P_CHAVE+"' AND D_E_L_E_T_='' AND C5_FILIAL='"+cFil+"'") 
		  	EndIF				
		/*Comentado a pedido da equipe do Estoque.
		Else 
			//Caso não tenha saldo de estoque, concateno os itens sem estoque para envio de email ao usuário
			For nR := 1 To Len( aBloqueio )
				cLogErro += "Pedido " + alltrim(aBloqueio[ nR ][ 1 ]) + " - Produto " + Alltrim(aBloqueio[ nR ][ 4 ]) + " bloqueado por falta de estoque. <br>"
			Next nR
						
			if !empty(cLogErro)
				sendMail(cData,cHora,(cAreaSC5)->C5_NUM,(cAreaSC5)->C5_P_CHAVE,cLogErro,cfil)
			EndIf*/
		Endif 
	/*Comentado a pedido da equipe do Estoque.
	Else
		//Caso não tenha saldo de estoque, concateno os itens sem estoque para envio de email ao usuário
		For nR := 1 To Len( aRet )
			 cLogErro += "Pedido " + SC5->C5_NUM + " - Produto " + Alltrim(aRet[nR]) + " bloqueado por falta de estoque. <br>"
		Next nR 
					
		sendMail(cData,cHora,(cAreaSC5)->C5_NUM,(cAreaSC5)->C5_P_CHAVE,cLogErro,cfil)*/
	EndIf 

	SC5->(DBCloseArea())
	(cAreaSC5)->(dbSkip())
Enddo
(cAreaSC5)->(DBCloseArea()) 	 	  

Return .T. 

/*-----------------------------------------------------  
  Static function para preparar o corpo do email 
  para envio
-------------------------------------------------------*/
*-------------------------------------------------------------*
Static Function sendMail(cData,cHora,cPV,cChave,cMensagem,cFil)
*-------------------------------------------------------------*
Local cEmail   := "" 

//Corpo do email
cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
cEmail+="<p><B>Origem:</b> "+iif(cFil == "01","Venda Presencial","E-Commerce (Datatrax)")+"<br><b>Pedido de Venda Totvs:</b> "+cPV+"<br /><b>Pedido de venda(DataTrax):</b> "+cChave+" <br> <b>Hora:</b> "+cHora+"<br /><b>Data:</b> "+cData+"</p>"
cEmail+="<p>Liberação de Saldo de Estoque para pedido de venda</p></font>"

cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1' align='center'><tr>"
cEmail+="<td width='231' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Mensagem de Erro</font></td></tr>"

cEmail+="<tr><td  bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+cMensagem+"</font></td></tr>" 
cEmail+="</table><br><br><br>"					

u_N6GEN001(cEmail,"Liberação de saldo de estoque para pedido de venda - "+cChave,,alltrim(GETMV("MV_P_00114")))

Return