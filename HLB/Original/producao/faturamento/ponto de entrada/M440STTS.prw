
#Include "rwmake.ch"
#include "PROTHEUS.CH"

/*
Funcao      : M440STTS
Objetivos   : PE após liberação de pedido de venda
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 16/12/2010
*/

*--------------------------*
  User Function M440STTS 
*--------------------------*
Local i     
Local aItens:={}  
Local cEMail:=""   
Local nPos
Local cNum:="" 
Local cFile
Local cModEntrega:=""     

//Objetivos   : Vincular o pedido liberado aos numeros de serie - EUROSILICONE.          
If cEmpAnt $ ("3U") //EUROSILICONE
   
   If MsgYesNo("Dejesa enviar e-mail para o almoxarifado","EUROSILICONE")
               
      aItens :=  aCols 
           
      cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
      cEmail += '<title>Nova pagina 1</title></head><body>'
      cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
      cEmail += 'PEDIDO DE VENDA EUROSILICONE</b></u></font></p>'   
      cEmail += '<p><font face="Courier New" size="2">Pedido de Venda: '+M->C5_NUM
      cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>' 
      cEmail += 'Cliente&nbsp;&nbsp;&nbsp;&nbsp; : '+M->C5_CLIENT       
      SA1->(DbSetOrder(1))
      If SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENT))
         cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(SA1->A1_NOME)+'<br>'   
      EndIf  
      cEmail += 'Medico&nbsp;&nbsp;&nbsp;&nbsp; : '+M->C5_P_MEDIC      
      ZX5->(DbSetOrder(1))
      If ZX5->(DbSeek(xFilial("ZX5")+M->C5_P_MEDIC))
         cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(ZX5->ZX5_NOME)+'<br><p>'   
      Else
         cEmail +=+'<br>'   
      EndIf
      cEmail += 'Usuário&nbsp;&nbsp;&nbsp;&nbsp; : '+alltrim(cUserName)+'<br>'     
      cEmail += 'Data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Dtoc(date())+'<br>'
      cEmail += 'Data Entrega do pedido&nbsp;&nbsp;&nbsp;    : '+Dtoc(M->C5_P_DTENT)+'<br>' 
      
      If M->C5_P_MODE == "E"
         cModEntrega:="Entrega"
      ElseIf M->C5_P_MODE == "R"
         cModEntrega:="Retirada"
      ElseIf M->C5_P_MODE == "T"
         cModEntrega:="Transportadora"
      ElseIf M->C5_P_MODE == "S"
         cModEntrega:="Sedex"
      EndIf
      
      cEmail += 'Modalidade de entrega do pedido&nbsp;&nbsp;&nbsp;    : '+cModEntrega+'<br>'
      cEmail += 'Horario&nbsp;&nbsp;&nbsp;&nbsp; : '+Time()+'<br>'
      cEmail += '<p><p>ESTRUTURA<p>'
      cEmail += '<table border="1" width="1200" style="padding: 0"><tr>'
      cEmail += '<td width="40"><font face="Courier New" size="2">Item</font></td>'
      cEmail += '<td width="113"><font face="Courier New" size="2">Produto</font></td>'
      cEmail += '<td width="113"><font face="Courier New" size="2">Quantidade</font></td>'
      cEmail += '<td width="300"><font face="Courier New" size="2">Descrição</font></td>'     
      cEmail += '<td width="300"><font face="Courier New" size="2">Serie</font></td>'
   
      For i:=1 to Len(aItens)
   
         cEmail += '	<tr>'   
         nPos   :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_ITEM' }) 
         cEmail += '		<td width="40"><font face="Courier New" size="2">'+aItens[i][nPos]+'</font></td>' 
         nPos   :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO' }) 
         cEmail += '		<td width="113"><font face="Courier New" size="2">'+aItens[i][nPos]+'</font></td>'
         nPos   :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN' }) 
         cEmail += '		<td width="113"><font face="Courier New" size="2">'+Alltrim(Str(aItens[i][nPos]))+'</font></td>'   
         nPos   :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO' })           
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial("SB1")+aItens[i][nPos]))      
           cEmail += '		<td width="378"><font face="Courier New" size="2">'+AllTrim(SB1->B1_DESC)+'</font></td>'
         EndIf     
         cEmail += '		<td width="378"><font face="Courier New" size="2"><center>INCLUIR</center></font></td>'
         cEmail += '		<td width="111" align="right">'
	     cEmail += '	</tr>'    

      Next     
   		 
      cEmail += '</table>'
      cEmail += '<br>'
      cEmail += '<br>'
      cEmail += '<br>'
      cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
      cEmail += '<p align="center">www.grantthornton.com.br</p>'
      cEmail += '</body></html>'

      cFile := "\SYSTEM\"+cNum+".html"
      nHdl := FCreate( cFile )
      FWrite( nHdl,  cEmail, Len( cEmail ) )
      FClose( nHdl )      
         
      oEmail           :=  DEmail():New()
      oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
      oEmail:cTo		:=  AllTrim(GetMv("MV_P_EMAIL"))   // Ex: "tiago.mendonca@pryor.com.br"
      oEmail:cSubject	:=	"Pedido de Venda liberado: " + cNum
      oEmail:cBody   	:= 	cEmail
      oEmail:cAnexos   :=  cFile
      oEmail:Envia()
      
      cText:="Geração de Pedido"     
      //MsgInfo("Pedido "+Alltrim(cNum)+" gerado com sucesso, enviado e-mail para o almoxerifado.","EUROsilicone")     
      FErase(cFile) 		 
   
   EndIf	  

//ER - Tratamento de integração da Chemtool com o armazem (Logimaster)
ElseIf cEmpAnt $ "G6" 

	lBlEst := .F.
    /*
	//Verifica se existe bloqueio de estoque.
	SC9->(DbSetOrder(1))
	If SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))
    	While SC9->(!EOF()) .and. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+SC5->C5_NUM
			
			If AllTrim(SC9->C9_BLEST) == "02"
				lBlEst := .T.				
			EndIf	

			SC9->(DbSkip())
		EndDo
	EndIf
    */

    If !lBlEst
		Processa({|| IntLogimaster() })
	Else
		MsgInfo("O arquivo para Logimaster não foi gerado porque esse pedido apresenta bloqueio de estoque.","Atenção")
	EndIf
		 	 				   
//JSS -Inicio 
//Criado Workflow na alteraçãodos pedisos para Empresa: 'Victaulic' Cod.: 'TM' 
ElseIf cEmpAnt $ "TM/9Y"    
                             
	
	SendWorkFlow()  
	
	 

EndIF  

Return .T.

/*
Funcao      : IntLogimaster()
Objetivos   : Gerar arquivo de integração da Chemtool com o armazem (Logimaster).
Autor       : Eduardo C. Romanini
Data/Hora   : 09/03/2012 
*/   
*-----------------------------*
Static Function IntLogimaster()
*-----------------------------*
Local oInt

oInt := Logimaster():New()
oInt:GeraArq("NF","S") //Gera o arquivo de nota fiscal do tipo saída.
oInt:GeraArq("PROD")   //Gera o arquivo do cadastro de produtos.

Return Nil
 
  
/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 30/06/2014
*/
*----------------------------*
Static Function SendWorkFlow()
*----------------------------* 


Local cEmail	:= Email()
  

	oEmail          := DEmail():New()
	oEmail:cFrom   	:= "totvs@hlb.com.br"
	oEmail:cTo		:= PADR(ALLTRIM(GetMv("MV_P_EMAI1",,"")),400)
	
	If Alltrim(M->C5_P_PARC) == 'S'	  
	    If Substr(GetEnvServer(),1,6)=="P11_16" 
	    	oEmail:cSubject	:= 'Pedido :  '+ M->C5_NUM  +' liberado para impressão de picklist. Tipo: Parcial'
	    Else
			oEmail:cSubject	:= 'LIBERACAO PEDIDO:  '+ M->C5_NUM  +' / PARCIAL'
		Endif
	Else     
		If Substr(GetEnvServer(),1,6)=="P11_16" 
			oEmail:cSubject	:= 'Pedido :  '+ M->C5_NUM  +' liberado para impressão de picklist. Tipo: Total'
		Else
			oEmail:cSubject	:= 'LIBERACAO PEDIDO:  '+ M->C5_NUM  +' / TOTAL'
		EndIf
	EndIf		
	
	oEmail:cBody   	:= cEmail
	oEmail:Envia() 
	



Return .T.  

/*
Função  : Email
Objetivo: Monta o email a ser enviado no workflow.
Autor   : Tiago Luiz Mendonça
Data    : 30/06/2014
*/
*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*  

Local cAux := ""
Local cHtml := ""

SA1->(DbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)) 

cHtml+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
cHtml+='xmlns:o="urn:schemas-microsoft-com:office:office"'
cHtml+='xmlns:w="urn:schemas-microsoft-com:office:word" '
cHtml+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
cHtml+='xmlns="http://www.w3.org/TR/REC-html40">'

cHtml+='<head>
cHtml+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
cHtml+='	<meta name=ProgId content=Word.Document> '
cHtml+='	<meta name=Generator content="Microsoft Word 12"> '
cHtml+='	<meta name=Originator content="Microsoft Word 12">'
cHtml+='</head>
cHtml+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
cHtml+='<div class=WordSection1>'
cHtml+="	<p class=MsoNormal  align=center style='text-align:center'> "
cHtml+='		<a href="http://www.grantthornton.com.br/">'
cHtml+="			<span style='text-decoration:none; text-underline:none'>"
//cHtml+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
cHtml+="			</span>"
cHtml+="		</a>"  
cHtml+="    </p>"
cHtml+="</div>"
cHtml+="<h1>"
cHtml+="<div align=center>"
cHtml+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
cHtml+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="				<div align=center>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
cHtml+="								<p class=MsoNormal align=center style='text-align:center'><b> "
cHtml+= TipoString(10.0,2)
cHtml+="										Pedido "+ALLTRIM(M->C5_NUM)+" liberado para gerar picklist."
cHtml+="									</span></b>"
cHtml+="								</p>"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+="					</table>"
cHtml+="				</div>"
cHtml+="				<div align=center>"
cHtml+="					<Br>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+='						<tr bgcolor="#FCFCFC">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Numero:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(M->C5_NUM)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Colaborador:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(cUserName)
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Cliente:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(SA1->A1_COD)+" - "+ALLTRIM(SA1->A1_NOME)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"



cHtml+="					</table>" 
cHtml+="				</Div>"
cHtml+="			</td>"  
cHtml+="		</tr>"						
cHtml+="   	</table>"
cHtml+="</div>"	
cHtml+="<tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>"
cHtml+="	<H1>"
cHtml+="	<td style='padding:0cm 0cm 0cm 0cm'>"
cHtml+="		<div align=center>"
cHtml+="			<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=679 style='width:509.25pt;mso-cellspacing:0cm;border:outset #CCCCCC 1.0pt;"
cHtml+="			mso-border-alt:outset #CCCCCC .75pt;mso-yfti-tbllook:1184;mso-padding-alt:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="				<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="					<td width='4%' style='width:4.0%;order:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Produto<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Descrição<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Solicitada<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Disponivel<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"

cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Unitário<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Total<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="								Status<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"


SC9->(DbSetOrder(1)) 
SC6->(DbSetOrder(2))
If SC9->(DbSeek(xFilial("SC9")+M->C5_NUM)) 

	While SC9->C9_PEDIDO == M->C5_NUM
	
		If Empty(SC9->C9_NFISCAL)        


			cHtml+="					<tr style='mso-yfti-irow:1'>"
			cHtml+="						<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
			cHtml+="							<p class=MsoNormal>"
			cHtml+= TipoString(8.5,1)                                             
			cHtml+="					"+ALLTRIM(SC9->C9_PRODUTO)+"<o:p></o:p>"	
			cHtml+="								</span>"
			cHtml+="							</p>"
			cHtml+="						</td>"
			cHtml+="						<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
			cHtml+="							<p class=MsoNormal>"
			cHtml+= TipoString(8.5,1)      
			 
			
			If SC6->(DbSeek(xFilial("SC6")+SC9->C9_PRODUTO+M->C5_NUM+SC9->C9_ITEM))   
				cHtml+="				"+ALLTRIM(SC6->C6_DESCRI)+"<o:p></o:p>"
				cHtml+="							</span>"
				cHtml+="						</p>"
				cHtml+="					</td>"
				cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
				cHtml+="						<p class=MsoNormal>"
				cHtml+= TipoString(8.5,1)
				cHtml+="					"+ALLTRIM(cValToChar(SC9->C9_QTDLIB))+"<o:p></o:p>"
				cHtml+="							</span>"
				cHtml+="						</p>"
				cHtml+="					</td>"
				cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
				cHtml+="						<p class=MsoNormal>"
				cHtml+= TipoString(8.5,1)    
				If SC9->C9_BLEST=="02"
					cHtml+="					"+ALLTRIM(cValToChar(0))+"<o:p></o:p>"
				Else
					cHtml+="					"+ALLTRIM(cValToChar(SC9->C9_QTDLIB))+"<o:p></o:p>"				
				EndIf
				cHtml+="							</span>"
				cHtml+="						</p>"
				cHtml+="					</td>"
				cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
				cHtml+="						<p class=MsoNormal>"
				cHtml+= TipoString(8.5,1)
				cHtml+="					"+ALLTRIM(Transform(SC6->C6_PRCVEN,"@E 99,999,999.99"))+"<o:p></o:p>"
				cHtml+="							</span>"
				cHtml+="						</p>"
				cHtml+="					</td>"
				cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
				cHtml+="						<p class=MsoNormal>"
				cHtml+= TipoString(8.5,1)
				cHtml+="					"+ALLTRIM(Transform(SC6->C6_PRCVEN*SC9->C9_QTDLIB,"@E 99,999,999.99"))+"<o:p></o:p>"
				cHtml+="							</span>"
				cHtml+="						</p>"
				cHtml+="					</td>"
				cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt';color:red>"
				cHtml+="						<p class=MsoNormal>"
	                         	
				If SC9->C9_BLEST == "02"
					cHtml+= TipoString(8.5,3)
					cHtml+="Bloqueado: estoque<o:p></o:p>"	
	            ElseIf SC9->C9_BLEST == "01" 
	            	cHtml+= TipoString(8.5,3)  
					cHtml+="Bloqueado: credito<o:p></o:p>"	
	            ElseIf SC9->C9_BLEST =="  "      
	            	cHtml+= TipoString(8.5,4) 
	            	cHtml+="Liberado<o:p></o:p>"	
	            EndIf 
	              
	        EndIf    
			
			cHtml+="								</span>"
			cHtml+="							</p>"
			cHtml+="						</td>"
			cHtml+="					</tr>"
	   
	    EndIf 
	    
		SC9->(DbSkip())
	
	EndDo
	    
	    
EndIf

cHtml+="			</table>"
cHtml+="		</div>"
cHtml+="		<p class=MsoNormal>&nbsp;</p>"
cHtml+="    </td>" 
cHtml+="</tr>"	
cHtml+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="		<p class=MsoNormal align=center style='text-align:center'>"
cHtml+="			<span class=tituloatencao1>"
cHtml+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
cHtml+='				"Times New Roman"'
cHtml+="				;color:red'>"
cHtml+="						HLB BRASIL - Mensagem automática, favor não responder este e-mail."
cHtml+="				</span>"
cHtml+="			</span>"
cHtml+="		</p>"
cHtml+="    </td>"
cHtml+="</tr>"
cHtml+="</body>"
cHtml+="</html>"                       

Return cHtml

/*
Funcao      : TipoString
Objetivos   : 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 30/06/2014
*/            
*----------------------------------------*
 Static Function TipoString(nTam,nColor)
*-----------------------------------------*
                               
Local cAux:=""
      			     			
cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"
If nColor==1
	cAux+=";color:Black'>"
ElseIf  nColor==2
	cAux+=";color:White'>"
ElseIf  nColor==3
	cAux+=";color:Red'>"  
ElseIf  nColor==4
	cAux+=";color:Green'>"  
EndIf		 
          
               
Return cAux

