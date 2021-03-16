#include "totvs.ch"
#INCLUDE "rwmake.ch"
#include 'topconn.ch'
#include 'colors.ch'
/*
Funcao      : Tmfat007()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Relatório de Pedidos e Orcamentos
Autor       : João Silva
Revisão		:
Data/Hora   : 16/10/2014
Módulo      : Faturamento
Cliente     : Victaulic
*/
*-------------------------*
User Function Tmfat007()
*-------------------------*  
//Variaveis Locais
Local cPerg 		:= "Tmfat007_p"
Local aPergs		:= {}
Local aDados		:= {}
Local aCabec		:= {}
Local aImpostos		:= {}
Local iIt			:= 1
Local iCodigo		:= 2
Local iDescricao	:= 3
Local iTES			:= 4
Local iCF			:= 5
Local iUM			:= 6
Local iQuantidade	:= 7
Local iUnitario		:= 8
Local iTotal		:= 9
Local iAliq_IPI		:= 10
Local iVlr_IPI		:= 11
Local iAliq_ICMS	:= 12
Local iVlr_ICMS		:= 13
Local iAliq_ISS		:= 14
Local iVlr_ISS		:= 15
Local iAliq_PIS		:= 16
Local iVlr_PIS		:= 17
Local iAliq_Confins	:= 18
Local iVlr_Cofins	:= 19
Local iNCM			:= 20  

Local nTotVal		:= 0
Local nTotIpi		:= 0
Local nTotIcms		:= 0
Local nTotIss		:= 0
Local nTotPis		:= 0
Local nTotCofins  	:= 0 
Local nTotIcmsST 	:= 0 

//Variaceis Privadas
Private cQry		:="" 
Private cQry1		:=""
Private cHtml		:=""

//Verifica se é a empresa Victaulic
If cEmpAnt <> "TM"
	Alert("Esta rotina foi desenvolvida apenas para empresa Victaulic.")
	Return()
EndIf

//Definicao das perguntas.
Aadd(aPergs,{"Numero: ","","","mv_ch1","C",9,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Tipo:      ","","","mv_ch2","N",1,0,0,"C","","MV_PAR02","Pedido","","","","","Orçamento","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("Tmfat007_p",aPergs)
                                          
If !Pergunte (cPerg,.T.)
	Return Nil
EndIf 

If MV_PAR02==1
//Qry para alimentar os dados do cabeçalho caso seja pedido
 	cQry :=" SELECT	"+CRLF 
	cQry +=" C5_NUM  	AS NUMERO,"+CRLF
	cQry +=" C5_EMISSAO AS EMISSAO, "+CRLF
	cQry +=" C5_TRANSP  AS TRANSPORTADORA, "+CRLF
	cQry +=" C5_VEND1   AS VENDEDOR,"+CRLF
	cQry +=" C5_CONDPAG AS CONDICAO_DE_PAGAMENTO,"+CRLF
	cQry +=" A1_COD		AS CODIGO,"+CRLF
	cQry +=" A1_NOME	AS NOME,"+CRLF              
	
	cQry +=" A1_TEL		AS TELEFONE,"+CRLF
	cQry +=" A1_MUN		AS MUNICIPIO,"+CRLF
	cQry +=" A1_EST		AS ESTADO,"+CRLF
	cQry +=" A1_CEP		AS CEP,"+CRLF
	cQry +=" A1_CGC		AS CGC,"+CRLF
	cQry +=" A1_INSCR	AS IE,"+CRLF 
	cQry +=" E4_DESCRI  AS DESCR_COND_PAG"+CRLF  
	
	cQry +=" FROM  SC5TM0"+CRLF 
	cQry +=" AS SC5"+CRLF
	
	cQry +=" INNER JOIN SA1TM0"+CRLF 
	cQry +=" AS SA1"+CRLF 
	cQry +=" ON C5_CLIENTE = A1_COD"+CRLF   
	
	cQry +=" INNER JOIN SE4TM0"+CRLF 
	cQry +=" AS SE4"+CRLF 
	cQry +=" ON C5_CONDPAG  = E4_CODIGO"+CRLF  
	
	cQry +=" WHERE SC5.C5_FILIAL='"+xFilial("SC5")+"' AND SC5.D_E_L_E_T_=''"+CRLF 
	cQry +=" AND SC5.D_E_L_E_T_=''"+CRLF
	cQry +=" AND SC5.C5_NUM = '"+MV_PAR01+"'"//" AND SC5.C5_NUM = '000003'"+CRLF 
		  
Else
//Qry para alimentar os dados do cabeçalho caso seja pedido
 	cQry :=" SELECT	"+CRLF 
	cQry +=" CJ_NUM  	AS NUMERO,"+CRLF
	cQry +=" CJ_EMISSAO AS EMISSAO, "+CRLF
	cQry +=" CJ_P_TRANS AS TRANSPORTADORA, "+CRLF
	cQry +=" CJ_P_SALES AS VENDEDOR,"+CRLF
	cQry +=" CJ_CONDPAG AS CONDICAO_DE_PAGAMENTO,"+CRLF
	cQry +=" A1_COD		AS CODIGO,"+CRLF
	cQry +=" A1_NOME	AS NOME,"+CRLF
	cQry +=" A1_TEL		AS TELEFONE,"+CRLF
	cQry +=" A1_MUN		AS MUNICIPIO,"+CRLF
	cQry +=" A1_EST		AS ESTADO,"+CRLF
	cQry +=" A1_CEP		AS CEP,"+CRLF
	cQry +=" A1_CGC		AS CGC,"+CRLF
	cQry +=" A1_INSCR	AS IE,"+CRLF   
	cQry +=" E4_DESCRI  AS DESCR_COND_PAG"+CRLF  
	
	cQry +=" FROM  SCJTM0"+CRLF 
	cQry +=" AS SCJ"+CRLF            
	
	cQry +=" INNER JOIN SA1TM0"+CRLF 
	cQry +=" AS SA1"+CRLF 
	cQry +=" ON CJ_CLIENTE  = A1_COD"+CRLF  
	
	cQry +=" INNER JOIN SE4TM0"+CRLF 
	cQry +=" AS SE4"+CRLF 
	cQry +=" ON CJ_CONDPAG  = E4_CODIGO"+CRLF 
	
	cQry +=" WHERE SCJ.CJ_FILIAL='"+xFilial("SCJ")+"' AND SCJ.D_E_L_E_T_=''"+CRLF 
	cQry +=" AND SCJ.D_E_L_E_T_=''"+CRLF
	cQry +=" AND SCJ.CJ_NUM = '"+MV_PAR01+"'"//" AND SCJ.CJ_NUM = '000003'"+CRLF 
		
EndIf   

If (TCSQLExec(cQry) >= 0)
	//Fechando tabela temporaria CABEC se estiver aberta e abrindo novamente para inserir dados
	If Select ('CABEC')>0
		CABEC->(DbCloseArea('CABEC'))
	EndIf
	DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQry),'CABEC',.F.,.T.)
	CABEC->(DbSetOrder(0))
	CABEC->(DbGoTop())
	
	If !CABEC->(eof()) 
		While CABEC->(!EOF())  // Aqui
			aAdd(aCabec, {;
					CABEC->NUMERO,;	 				//[1] 
					CABEC->EMISSAO,;				//[2] 
					CABEC->TRANSPORTADORA,;         //[3] 	
					CABEC->VENDEDOR,;              	//[4] 
					CABEC->CONDICAO_DE_PAGAMENTO,;	//[5] 
					CABEC->CODIGO,;					//[6]
					CABEC->NOME,;		 			//[7]
					CABEC->TELEFONE,;				//[8] 
					CABEC->MUNICIPIO,;				//[9] 
					CABEC->ESTADO,;					//[10] 
					CABEC->CEP,;					//[11] 
					CABEC->CGC,;					//[12] 
					CABEC->IE,;						//[13] 
					CABEC->DESCR_COND_PAG})			//[14]
			CABEC->(DbSkip())
		EndDo  
	Else 
		Alert("Nenhum registro encontrado")
		Return() 
	EndIf 
			
EndIF   

If MV_PAR02==1
	
	//Estrutura da Query Pedido
	cQry1 :=" SELECT
	cQry1 +=" C6_ITEM		AS IT, "+CRLF
	cQry1 +=" C6_PRODUTO	AS Codigo, "+CRLF
	cQry1 +=" B1_DESC		AS Descricao_Material, "+CRLF
	cQry1 +=" C6_TES		AS TES,"+CRLF
	cQry1 +=" C6_CF			AS CF,"+CRLF
	cQry1 +=" C6_UM			AS UM,"+CRLF
	cQry1 +=" C6_QTDVEN		AS Quantidade,"+CRLF
	cQry1 +=" C6_PRCVEN		AS Unitario,"+CRLF
	cQry1 +=" C6_VALOR		AS Total,"+CRLF
	cQry1 +=" B1_IPI		AS Aliq_IPI,"+CRLF
	cQry1 +=" B1_IPI		AS Vlr_IPI,"+CRLF
	cQry1 +=" B1_PICM		AS Aliq_ICMS,"+CRLF
	cQry1 +=" B1_PICM		AS Vlr_ICMS,"+CRLF
	cQry1 +=" B1_ALIQISS	AS Aliq_ISS,"+CRLF
	cQry1 +=" B1_ALIQISS	AS Vlr_ISS,"+CRLF
	cQry1 +=" B1_PPIS		AS Aliq_PIS,"+CRLF
	cQry1 +=" B1_PPIS		AS Vlr_PIS,"+CRLF
	cQry1 +=" B1_PCOFINS	AS Aliq_Confins,"+CRLF
	cQry1 +=" B1_PCOFINS	AS Vlr_Cofins, "+CRLF 
	cQry1 +=" B1_POSIPI		AS NCM "+CRLF    
	
	cQry1 +=" FROM "+RETSQLNAME("SC6")+" AS SC6"+CRLF
	cQry1 +=" INNER JOIN "+RETSQLNAME("SB1")+CRLF
	cQry1 +=" ON C6_PRODUTO = B1_COD "+CRLF  
	
	cQry1 +=" WHERE C6_FILIAL='"+xFilial("SC6")+"' AND SC6.D_E_L_E_T_=''"
	cQry1 +=" AND C6_NUM = '"+MV_PAR01+"'"
	cQry1 +=" ORDER BY C6_ITEM "     
	
Else
	//Estrutura da Query Orçamentos
	cQry1 :=" SELECT
	cQry1 +=" CK_ITEM		AS IT, "+CRLF
	cQry1 +=" CK_PRODUTO	AS Codigo, "+CRLF
	cQry1 +=" B1_DESC		AS Descricao_Material, "+CRLF
	cQry1 +=" CK_TES		AS TES,"+CRLF
	cQry1 +=" F4_CF			AS CF,"+CRLF
	cQry1 +=" CK_UM			AS UM,"+CRLF
	cQry1 +=" CK_QTDVEN		AS Quantidade,"+CRLF
	cQry1 +=" CK_PRCVEN		AS Unitario,"+CRLF
	cQry1 +=" CK_VALOR		AS Total,"+CRLF
	cQry1 +=" B1_IPI		AS Aliq_IPI,"+CRLF
	cQry1 +=" B1_IPI		AS Vlr_IPI,"+CRLF
	cQry1 +=" B1_PICM		AS Aliq_ICMS,"+CRLF
	cQry1 +=" B1_PICM		AS Vlr_ICMS,"+CRLF
	cQry1 +=" B1_ALIQISS	AS Aliq_ISS,"+CRLF
	cQry1 +=" B1_ALIQISS	AS Vlr_ISS,"+CRLF
	cQry1 +=" B1_PPIS		AS Aliq_PIS,"+CRLF
	cQry1 +=" B1_PPIS		AS Vlr_PIS,"+CRLF
	cQry1 +=" B1_PCOFINS	AS Aliq_Confins,"+CRLF
	cQry1 +=" B1_PCOFINS	AS Vlr_Cofins, "+CRLF
	cQry1 +=" B1_POSIPI		AS NCM "+CRLF   
	
	cQry1 +=" FROM "+RETSQLNAME("SCK")+" AS SCK"+CRLF
	cQry1 +=" INNER JOIN "+RETSQLNAME("SB1")+CRLF
	cQry1 +=" ON CK_PRODUTO = B1_COD "+CRLF     
	
	cQry1 +=" INNER JOIN SF4YY0 "+CRLF
	cQry1 +=" ON CK_TES = F4_CODIGO "+CRLF  
	
	cQry1 +=" WHERE CK_FILIAL='"+xFilial("SCK")+"' AND SCK.D_E_L_E_T_=''"
	cQry1 +=" AND CK_NUM = '"+MV_PAR01+"'"
	cQry1 +=" ORDER BY CK_ITEM "
EndIf

If (TCSQLExec(cQry1) >= 0)
	//Fechando tabela temporaria TEMP se estiver aberta e abrindo novamente para inserir dados
	If Select ('TEMP')>0
		TEMP->(DbCloseArea('TEMP'))
	EndIf
	DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQry1),'TEMP',.F.,.T.)
	TEMP->(DbSetOrder(0))
	TEMP->(DbGoTop())
	
	While TEMP->(!EOF())  // Aqui
		aAdd(aDados, {TEMP->It,TEMP->Codigo,TEMP->Descricao_Material,TEMP->TES,TEMP->CF,TEMP->UM,TEMP->Quantidade,TEMP->Unitario,;
		TEMP->Total,TEMP->Aliq_IPI,TEMP->Vlr_IPI,TEMP->Aliq_ICMS,TEMP->Vlr_ICMS,TEMP->Aliq_ISS,TEMP->Vlr_ISS,TEMP->Aliq_PIS,;
		TEMP->Vlr_PIS,TEMP->Aliq_Confins,TEMP->Vlr_Cofins,TEMP->NCM})
		TEMP->(DbSkip())
	EndDo
EndIF

//Cria estrutura HTML
cHtml+=" <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cHtml+=" <html xmlns='http://www.w3.org/1999/xhtml'>"
cHtml+=" <head>"
cHtml+=" <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
cHtml+=" <title>Propostas</title>"

cHtml+=" <style type='text/css'>"
cHtml+=" .corLinHead {"
cHtml+=" 	background-color: #D8CFE3;" 
cHtml+="	font-weight:bold;"
cHtml+="	font-size:16px;"
cHtml+="	text-align:center;"
cHtml+=" }"

cHtml+=" .corLinBody {"
cHtml+=" 	background-color:#C2C2DC;"
cHtml+=" }"       

cHtml+=" .colorBord {"
cHtml+=" border-width: medium;"
cHtml+=" border-style: solid;"
cHtml+=" border-color: #00f;"
cHtml+="    }

cHtml+=" </style>"
cHtml+=" </head>"

cHtml+=" <body>"       
          
cHtml+="<table>" 
//Pula Linha
cHtml+=" <tr> "
cHtml+=" 	<td>"
cHtml+=" 	<br>"
cHtml+=" 	</td>"  
cHtml+=" </tr> "
//- Dados da empresa  
cHtml+="<tr><td></td>"
cHtml+="   <td colspan='5'> <strong> <font face='Arial'size='3'> VICTAULIC DO BRASIL </font> </strong> <br>"
cHtml+="        <font face='Arial'size='2'> Av. Marquesde Sao Vicente,446  <br>"
cHtml+="        					  (11)3886-4800 </font>"
cHtml+="   </td>"
If MV_PAR02 == 1
	//- Dados do Pedido
	cHtml+="   <td colspan='5'> <strong> <font face='Arial'size='2'> Pedido: "+ aCabec[1][1]+" <br>"
	cHtml+="        Emissao: "+SUBSTR(aCabec[1][2],7,2)+"/"+SUBSTR(aCabec[1][2],5,2)+"/"+SUBSTR(aCabec[1][2],1,4)+" </font> </strong>"    //cHtml+="        Emissao: Data da emissao: "+ aCabec[1][2]+" </font> </strong>" 
	cHtml+="   </td>"
	cHtml+="</tr>"   
Else
 	//- Dados do Orçamento  
	cHtml+="   <td colspan='5'><strong> <font face='Arial'size='2'> Orcamento: "+ aCabec[1][1]+" 	<br>"
	cHtml+="        Emissao: "+SUBSTR(aCabec[1][2],7,2)+"/"+SUBSTR(aCabec[1][2],5,2)+"/"+SUBSTR(aCabec[1][2],1,4)+" </font> </strong>" //cHtml+="        Emissao: Data da emissao: "+ aCabec[1][2]+" </font> </strong>"
	cHtml+="   </td>"	
	cHtml+="</tr>"   
EndIf

//Pula Linha
cHtml+=" <tr> "
cHtml+=" 	<td>"
cHtml+=" 	<br>"
cHtml+=" 	</td>"  
cHtml+=" </tr> "           

//- Dados do Cliente
cHtml+=" <tr><td></td> "
cHtml+=" 	<td colspan='5'> <font face='Arial'size='2'>"
cHtml+=" 		Cliente: "+aCabec[1][6]+" - "+aCabec[1][7]+"  <br>"
cHtml+=" 		Telefone: "+aCabec[1][8]+" "+aCabec[1][9]+" "+aCabec[1][10]+" Cep: "+aCabec[1][11]+"<br>"
cHtml+=" 		C.G.B.: "+aCabec[1][12]+" IE: "+aCabec[1][13]+" "
cHtml+=" 	</font> </td>"

//- Dados da Transportadora
cHtml+="	<td colspan='5'> <font face='Arial'size='2'>"
cHtml+="		Transportadora : "+aCabec[1][3]+" <br>"
cHtml+="		Vendedor : "+aCabec[1][4]+" <br>"     
cHtml+="		Condicao de pagamento  : "+aCabec[1][5]+" - "+aCabec[1][14]+" <br>"
cHtml+="   </font> </td>"
cHtml+=" </tr>"
cHtml+="</table>"  

//Pula Linha
cHtml+=" <tr> "
cHtml+=" 	<td>"
cHtml+=" 	<br>"
cHtml+=" 	</td>"  
cHtml+=" </tr> "     

//Colunas do excel
cHtml+=" <table border = 1 "   
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> It			</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Codigo		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Descricao_Material</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> TES			</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> CF			</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> UM 			</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Quantidade	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Unitario		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Total		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Aliq. IPI	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr. IPI		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Aliq. ICMS	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr. ICMS	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Aliq. ISS	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr ISS		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Aliq. PIS	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr PIS		</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Aliq. Confins</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr Cofins	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> NCM			</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Base ICMS ST	</font></td>"
cHtml+=" 	<td class='corLinHead'><font face='Arial'size='2'> Vlr ICMS ST	</font></td>"
cHtml+=" </tr>" 


DbSelectArea ("SA1")
SA1->(DbGotop())
SA1->(DbSetOrder(1))    
//FILIAL + A1_CODIGO + A1_LOJA
SA1->(DbSeek (xFilial("SA1")+aCabec[1][6], .T.))


For nI := 1 To Len (aDados) 
		
	DbSelectArea ("SB1")
	SB1->(DbGotop())
	SB1->(DbSetOrder(1))
	//FILIAL + B1_COD
	SB1->(DbSeek (xFilial("SB1")+aDados[nI][iCodigo], .T.))

	DbSelectArea ("SF4")
	SF4->(DbGotop())
	SF4->(DbSetOrder(1))
	// F4_FILIAL + F4_CODIGO
	SF4->(DbSeek (xFilial("SF4")+aDados[nI][iTES], .T.))
	
	DbSelectArea ("SC6")
	SC6->(DbGotop())
	SC6->(DbSetOrder(1))    
	//FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	SC6->(DbSeek (xFilial("SC6")+aCabec[1][1]+aDados[nI][iIt]+aDados[nI][iCodigo], .T.)) 
	                                                                                             
	//Calcular os impostos do orçamento
	aImpostos := {U_GTFAT008(aDados[nI][iTotal],aDados[nI][iQuantidade],aDados[nI][iUnitario])}
	//aImpostos := {U_GTFAT008(SCK->CK_VALOR,SCK->CK_QTDVEN,SCK->CK_PRCVEN)}
	cHtml +="<tr class='nome'>"                                                                  
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iIt]					+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iCodigo] 			+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iDescricao] 			+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iTES] 				+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iCF] 				+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ aDados[nI][iUM] 				+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ STR(aDados[nI][iQuantidade])	+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ STR(aDados[nI][iUnitario]) 		+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ STR(aDados[nI][iTotal]) 		+ "</font></td>"
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][2]),"@E 999,999,999.99")			+ "</font></td>"//Aliquota de calculo IPI
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][3]),"@E 999,999,999.99") 			+ "</font></td>"//Valor de IPI
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][5]),"@E 999,999,999.99") 			+ "</font></td>"//Aliquotade calculo ICMS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][6]),"@E 999,999,999.99")	 		+ "</font></td>"//Valor de ICMS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][14]),"@E 999,999,999.99")	 		+ "</font></td>"//Aliquota de ISS do item
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][16]),"@E 999,999,999.99")			+ "</font></td>"//Valor do ISS do item
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][12]),"@E 999,999,999.99") 			+ "</font></td>"//Aliquota de calculo do PIS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][13]),"@E 999,999,999.99")	 		+ "</font></td>"//Valor do PIS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][9]),"@E 999,999,999.99")		 	+ "</font></td>"//Aliquota de calculo do COFINS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][10]),"@E 999,999,999.99")		 	+ "</font></td>"//Valor do COFINS
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aDados[nI][iNCM]),"@E 99999999999")				+ "</font></td>"	
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][17]),"@E 999,999,999.99")		 	+ "</font></td>"//Base do ICMS ST 
	cHtml += "<td><font face='Arial'size='2'>"+ Transform((aImpostos[1][7]),"@E 999,999,999.99")		 	+ "</font></td>"//Valor do ICMS ST
	cHtml +="</tr>" 
	
	nTotVal		+= aDados[nI][iTotal]
	nTotIpi		+= aImpostos[1][3]
	nTotIcms	+= aImpostos[1][6]
	nTotIss		+= aImpostos[1][16]
	nTotPis		+= aImpostos[1][13]
	nTotCofins  += aImpostos[1][10]   
	nTotIcmsST  += aImpostos[1][7]      


Next nI  

cHtml+=" </table>"  
cHtml+=" <table>"

//Pula Linha
cHtml+=" <tr> "
cHtml+=" 	<td>"
cHtml+=" 	<br>"
cHtml+=" 	</td>"  
cHtml+=" </tr> "   

//Totalizadores     
cHtml+="<tr>" 
cHtml+="	<td></td>"
cHtml+="	<td></td>"
cHtml+="	<td></td>" 
cHtml+="	<td></td>"
cHtml+="	<td></td>"                
cHtml+="	<td colspan='3'><strong> <font face='Arial'size='2'> "
cHtml+="	Total: "
cHtml+="	<td>"+Transform((nTotVal),"@E 999,999,999.99")+"</td>"		//Valor Total      
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotIpi),"@E 999,999,999.99")+"</td>"		//Valor Total IPI 
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotIcms),"@E 999,999,999.99")+"</td>"	//Valor Total ICMS 
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotIss),"@E 999,999,999.99")+"</td>"		//Valor Total ISS 
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotPis),"@E 999,999,999.99")+"</td>"		//Valor Total PIS 
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotCofins),"@E 999,999,999.99")+"</td>"	//Valor Total COFINS    
cHtml+="	<td></td>"             
cHtml+="	<td></td>"
cHtml+="	<td>"+ Transform((nTotIcmsST),"@E 999,999,999.99")+"</td>"	//Valor Total ICMS ST  
cHtml+="	</font></td>"
cHtml+=" </tr>"    

cHtml+=" </table>" 
cHtml+=" </body>"
cHtml+=" </html>"

//Gera EXCEL
cDest :=  GetTempPath()
  
If MV_PAR02 == 1
	cArq := 'Relatorio de Pedidos '+MV_PAR01+'.xls'
Else
	cArq := 'Relatorio de Orçamentos '+MV_PAR01+'.xls'
EndIf		

If File (cDest+cArq)
	Ferase (cDest+cArq)
EndIf

nHdl 	:= Fcreate(cDest+cArq,0 )
nBytesSalvo := Fwrite(nHdl, cHtml)

If nBytesSalvo <= 0
	MsgStop('Erro de gravacao do Destino. Error = ' + Str(Ferror(), 4) + ' Erro')
Else
	Fclose(nHdl)
	cExt := '.xls'
	ShellExecute('open', (cDest+cArq), '', '', 5)
EndIf

Return .F.

/*
Funcao      : AjustaSx1()
Parametros  : cPerg, aPergs
Retorno     : Nil
Objetivos   : Verifica/cria SX1 a partir de matriz para verificacao
Autor       : João Silva
Revisão		:
Data/Hora   : 16/10/2014
Módulo      : Faturamento
Cliente     : Victaulic
*/
*----------------------------------------*
Static Function AjustaSX1(cPerg, aPergs)
*----------------------------------------*

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local cKey		:= ""
Local nJ		:= 0
Local nCondicao

cPerg := Padr(cPerg,10)

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		U_PUTHelp(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next
Return
