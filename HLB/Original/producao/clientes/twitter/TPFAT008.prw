#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "topconn.ch"

/*
Funcao      : TPFAT008
Retorno     : .T.
Objetivos   : Impressao da Fatura para empresa Twitter.
Autor       : João Silva
			  07/05/2018 - Renato Rezende - Impressão apenas da Campanha.
Data		: 25/11/2014
Módulo      : Financeiro
*/
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
 USER FUNCTION TPFAT008(A1_NOME,A1_NREDUZ,A1_P_ID,A1_END,A1_ESTADO,A1_CEP,A1_CODPAIS,C5_NUM,C5_P_NUM,C5_EMISSAO,C5_P_PO,F2_DOC,F2_SERIE,F2_P_ENV,F2_P_NUM,F2_CLIENT,F2_LOJA,F2_VALBRUT,F2_EMISSAO,E4_DESCRI,E4_COND,cVer1,lSelAuto)
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Local aAreaAnt			:= GetArea()

DEFAULT lSelAuto		:=.F.

cString  := "SE1"

Processa({|lEnd|MontaRel1(A1_NOME,A1_NREDUZ,A1_P_ID,A1_END,A1_ESTADO,A1_CEP,A1_CODPAIS,C5_NUM,C5_P_NUM,C5_EMISSAO,C5_P_PO,F2_DOC,F2_SERIE,F2_P_ENV,F2_P_NUM,F2_CLIENT,F2_LOJA,F2_VALBRUT,F2_EMISSAO,E4_DESCRI,E4_COND,lSelAuto)})

RestArea(aAreaAnt)

Return Nil

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
STATIC FUNCTION MontaRel1(A1_NOME,A1_NREDUZ,A1_P_ID,A1_END,A1_ESTADO,A1_CEP,A1_CODPAIS,A1_CGC,C5_NUM,C5_P_NUM,C5_EMISSAO,C5_P_PO,F2_DOC,F2_SERIE,F2_P_ENV,F2_P_NUM,F2_CLIENT,F2_LOJA,F2_VALBRUT,F2_EMISSAO,E4_DESCRI,E4_COND,lSelAuto)
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Local cVencto	:= CTOD("//")//F2_EMISSAO+30
//VAL(SUBSTR(E4_COND,5,2)) 
Local nLinha 	:= 290
Local nTemp     := 0 

Private nPag 	:= 1

//Cor
Private oBrush  := TBrush():New("",RGB(190,	190,190)) //Cor Cinza
//Fontes
Private oFont8  := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont8n := TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont14n:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

Private cDirAnexo			:= ""
Private cLocal          	:= "C:\TPFAT008\"
Private cLogoEmp			:= "LOGOTP.bmp" 

//Cria o diretorio na maquina do usuário para enviar no e-mail
MakeDir(cLocal)

DbSelectArea("SF2")
SF2->(DbSetOrder(1))
if DbSeek(xFilial("SF2")+F2_DOC+F2_SERIE+F2_CLIENT+F2_LOJA)
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	if DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
		cVencto:=SE1->E1_VENCTO
	endif
endif
	
//Verifico se ja existe esta Query	
If Select("SC5QRY") > 0
	SC5QRY->(DbCloseArea())	               
EndIf      
  	
//Qyery para pegar a quantidade de paginas
cQuery := "SELECT COUNT "     
cQuery += "(ZX1_P_NUM) AS PAG "
cQuery += "	FROM "+RETSQLNAME("ZX1")+" ZX1 "
cQuery += "Where "
cQuery += "ZX1.ZX1_P_NUM = '"+ALLTRIM(C5_P_NUM)+"'"
cQuery += "AND ZX1.ZX1_EMISSA = '"+DtoS(C5_EMISSAO)+"'" //RRP - 06/07/2015 - Ajuste para o cálculo correto. 
cQuery += "AND ZX1.D_E_L_E_T_ <> '*' "

//MSM - 28/04/2015 - Tratamento para Agency Credit Line, Deve bater o número do referênce number da campanha 
if SC5->(FIELDPOS("C5_P_ATB01"))>0
	if SC5->C5_P_ATB01 == "A"
		cQuery += "AND ZX1.ZX1_P_REF = '"+Alltrim(SC6->C6_P_REF)+"'"
	endif
endif
		
TcQuery cQuery Alias "SC5QRY" New

SC5QRY->(DbGoTop())

If SC5QRY->PAG > 0
            
	//Primeira pagina
	If cVer1== 'N'
		oPrinter:= FWMSPrinter():New("Campanha"+ALLTRIM(F2_DOC),IMP_PDF,.F.,,.T.,.F.,,,,,,.F.,0)     
	Else 
		oPrinter:= FWMSPrinter():New("Campanha"+ALLTRIM(F2_DOC),IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)  
	EndIf

	oPrinter:cPathPDF := cLocal
	oPrinter:SetPortrait()	
	
	DbSelectArea ("SA1")
	SA1->(DbSetOrder(3))
	SA1->(DbSeek(xFilial("SA1")+A1_CGC,.T.))
	          
	DbSelectArea ("CCH")
	CCH->(DbGotop())
	CCH->(DbSetOrder(1))
	CCH->(DbSeek(xFilial("CCH")+A1_CODPAIS,.T.))//CCH_FILIAL+CCH_CODIGO 
	
	//JSS- Add para ajuta numero da pag.
	DbSelectArea ("ZX1")
	ZX1->(DbGotop())
	ZX1->(DbSetOrder(2))
	ZX1->(DbSeek(FwxFilial("ZX1")+DTOS(C5_EMISSAO)+C5_P_NUM,.T.))//ZX1_FILIAL+DTOS(ZX1_EMISSA)+ZX1_P_NUM+ZX1_P_REF   
		
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+C5_NUM))
		
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+"01"))
	
	oPrinter:StartPage()
	
	//Linhas coloridas em cinza
	oPrinter:FillRect({40, 277, 60, 555}, oBrush)
	oPrinter:FillRect({180, 40,200, 555}, oBrush)
	
	//Linhas do Cabecario
	oPrinter:Line(  40, 277,  40, 555)  //Linha 1
	oPrinter:Line(  60, 277,  60, 555)	//Linha 2
	oPrinter:Line(  80, 277,  80, 555)	//Linha 3
	oPrinter:Line( 100, 277, 100, 555)	//Linha 4
	oPrinter:Line( 120, 277, 120, 555)	//Linha 5
	oPrinter:Line( 160, 277, 160, 555)	//Linha 6
	
	//Colunas Cabecario.
	oPrinter:Line(  40, 277, 160, 277)	//Coluna 1
	oPrinter:Line(  60, 370, 120, 370)	//Coluna 2
	oPrinter:Line(  60, 463, 120, 463)	//Coluna 3
	oPrinter:Line(  40, 555, 160, 555)	//Coluna 4
	
	//Linhas Detalhes
	oPrinter:Line( 180,  40, 180, 555)  //Linha 1
	oPrinter:Line( 200,  40, 200, 555)	//Linha 2
	oPrinter:Line( 780,  40, 780, 555)  //Linha 3
	
	//Colunas Detalhes.
	oPrinter:Line( 180,  40, 780,  40)	//Coluna 1
	oPrinter:Line( 180,  80, 780,  80)	//Coluna 2
	oPrinter:Line( 180, 160, 780, 160)	//Coluna 3
	oPrinter:Line( 180, 358, 780, 358)	//Coluna 4
	oPrinter:Line( 180, 555, 780, 555)	//Coluna 5
	
	//Logo
	oPrinter:SayBitmap(40,40,"\system\logoTP.bmp",40,35)
	
	//Dados da Empresa
	oPrinter:Say( 90,40,AllTrim(SM0->M0_NOMECOM),oFont8n)
	oPrinter:Say(100,40,AllTrim(SM0->M0_ENDCOB),oFont8n)
	oPrinter:Say(110,40,AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB),oFont8n)
	oPrinter:Say(120,40,"CNPJ: "+SubStr(SM0->M0_CGC,1,2)+"."+SubStr(SM0->M0_CGC,3,3)+"."+SubStr(SM0->M0_CGC,6,3)+"/"+SubStr(SM0->M0_CGC,9,4)+"-"+SubStr(SM0->M0_CGC,13,2),oFont8n)
	oPrinter:Say(130,40,"Insc. Municipal: 4.613.515-4",oFont8n)
	
	//Titulos das colunas do cabeçalho.
	oPrinter:Say( 55,400,"Relatorio de Campanha",oFont14n)
	oPrinter:Say( 67,307,"NFS-e Nº",oFont8n)
	oPrinter:Say( 77,305,F2_DOC+" "+F2_SERIE,oFont8)	
	oPrinter:Say( 67,400,"Data NFS-e",oFont8n)    
	oPrinter:Say( 77,402,SubStr(DTOS(F2_EMISSAO),7,2)+"-"+SubStr(cMonth(F2_EMISSAO),1,3)+"-"+SubStr(DTOS(F2_EMISSAO),1,4),oFont8)
	oPrinter:Say( 67,493,"Pag.",oFont8n)
	oPrinter:Say( 77,493,AllTrim(STR(nPag)),oFont8) 
	oPrinter:Say( 87,305,"Mes Ref.",oFont8n)
	oPrinter:Say( 97,304,SubStr(cMonth(C5_EMISSAO),1,3)+"-"+SubStr(DTOS(C5_EMISSAO),1,4),oFont8)
	oPrinter:Say( 87,410,"Prazo",oFont8n)
	oPrinter:Say( 97,405,E4_DESCRI,oFont8)
	oPrinter:Say( 87,483,"Vencimento",oFont8n)
	oPrinter:Say( 97,485,SubStr(DTOS(cVencto),7,2)+"-"+SubStr(cMonth(cVencto),1,3)+"-"+SubStr(DTOS(cVencto),1,4),oFont8)
	oPrinter:Say(107,300,"Numero PO",oFont8n)  
	If((Len(AllTrim(C5_P_PO))) <= 6)
		oPrinter:Say(117,310,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)
	ElseIf((Len(AllTrim(C5_P_PO))) >= 6 .AND. (Len(AllTrim(C5_P_PO))) <= 12)
		oPrinter:Say(117,300,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)          
	ElseIf((Len(AllTrim(C5_P_PO))) >= 12 .AND. (Len(AllTrim(C5_P_PO))) <= 19)
		oPrinter:Say(117,285,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)	
	Else
		oPrinter:Say(113,280,SubStr(C5_P_PO,01,19),oFont8)	
		oPrinter:Say(119,280,SubStr(C5_P_PO,20,19),oFont8)
	EndIf  
	
	oPrinter:Say(107,400,"Numero IO",oFont8n)
	oPrinter:Say(117,407,C5_P_NUM,oFont8)
	
	//Titulo das colunas de detalhes.
	oPrinter:Say(189, 48,"Número ",oFont8n)  
	oPrinter:Say(196, 41.5,"Campanha ",oFont8n) 
	oPrinter:Say(189,104,"Usuario ",oFont8n)  
	oPrinter:Say(196, 98,"Promovido ",oFont8n)
	oPrinter:Say(189,210,"Nome da Campanha ",oFont8n)
	oPrinter:Say(189,440,"Produto ",oFont8n) 
	
	DbSelectArea ("ZX1")
	ZX1->(DbGotop())
	ZX1->(DbSetOrder(2))
	ZX1->(DbSeek("  "+DTOS(C5_EMISSAO)+C5_P_NUM,.T.))//ZX1_FILIAL+DTOS(ZX1_EMISSA)+ZX1_P_NUM+ZX1_P_REF   
	nLinha :=210 
	
		//Verifico se ja existe esta Query	
		If Select("SC5QRY") > 0
			SC5QRY->(DbCloseArea())	               
	  	EndIf      
	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+C5_NUM))
	
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+"01"))
	  	
	While  ZX1->ZX1_P_NUM == C5_P_NUM .AND.ZX1->ZX1_EMISSA == C5_EMISSAO 
		
		If AllTrim(ZX1->ZX1_PROD) = '3003'//JSS CODIGO 3003 não deve aparecer pois se trata de um seviço interno.
	    	ZX1->(DbSkip())
	    	Loop 		
		EndIf
		
		//MSM - 24/04/2015 - Tratamento para Agency Credit Line, Deve bater o número do referênce number da campanha 
		if SC5->(FIELDPOS("C5_P_ATB01"))>0
			if SC5->C5_P_ATB01 == "A"
				if SC6->C6_P_REF <> ZX1->ZX1_P_REF
					ZX1->(DbSkip()) 
		    		Loop 
				endif
			endif
		endif
			
		DbSelectArea ("SB1")
		SB1->(DbGotop())
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+ZX1->ZX1_PROD,.T.))//C6_FILIAL+C6_NUM+C6_ITEM
				 
		oPrinter:Say(nLinha, 45,AllTrim(ZX1->ZX1_ID),oFont8)//Número da Campanha  
		oPrinter:Say(nLinha, 85,AllTrim(ZX1->ZX1_NAME),oFont8)//Usuario Promovido 
	
		If Len(AllTrim(ZX1->ZX1_NAMEF))>40
			nTemp:= nLinha
			oPrinter:Say(nTemp,165,SubStr(ZX1->ZX1_NAMEF,1,39),oFont8)//Nome da Campanha 
			oPrinter:Say(nTemp+=10,165,SubStr(ZX1->ZX1_NAMEF,40,39),oFont8)//Nome da Campanha
			If Len(AllTrim(ZX1->ZX1_NAMEF))>88
				oPrinter:Say(nTemp+=10,165,SubStr(ZX1->ZX1_NAMEF,79,39),oFont8)//Nome da Campanha
			EndIf
		Else
			oPrinter:Say(nLinha,165,SubStr(ZX1->ZX1_NAMEF,1,40),oFont8)//Nome da Campanha
		EndIf	 				
		oPrinter:Say(nLinha,363,"Veiculacao de material publicitario na internet - "+SubStr(SB1->B1_DESC,1,9),oFont8)//DESCRIÇÃO ET - ",oFont8)//DESCRIÇÃO
		If Len(AllTrim(SB1->B1_DESC))>40
			oPrinter:Say(nLinha+=10,363,SubStr(SB1->B1_DESC,10,40),oFont8)//Produto 
			oPrinter:Say(nLinha+=10,363,SubStr(SB1->B1_DESC,51,40),oFont8)//Produto 
			
			If nTemp > nLinha
				oPrinter:Line(nTemp+2,  40, nTemp+2, 555)  //Linha de divisão dos itens
			Else
				oPrinter:Line(nLinha+2,  40, nLinha+2, 555)  //Linha de divisão dos itens
			EndIf		  			
		Else 
			oPrinter:Say(nLinha+=10,363,SubStr(SB1->B1_DESC,10,40),oFont8)//Produto	
			
			If nTemp > nLinha
				oPrinter:Line(nTemp+2, 40, nTemp+2, 555)  //Linha de divisão dos itens
			Else
				oPrinter:Line(nLinha+2, 40, nLinha+2, 555)  //Linha de divisão dos itens
			EndIf		
		EndIf
		
		If nTemp > nLinha
			nLinha:=nTemp+10
			nTemp := 0
		Else
			nLinha +=10
			nTemp  := 0
		EndIf	
			
		If nLinha > 760
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPag+= 1
			nLinha :=210
			//Linhas coloridas em cinza
			oPrinter:FillRect({40, 277, 60, 555}, oBrush)
			oPrinter:FillRect({180, 40,200, 555}, oBrush)
			
			//Linhas do Cabecario
			oPrinter:Line(  40, 277,  40, 555)  //Linha 1
			oPrinter:Line(  60, 277,  60, 555)	//Linha 2
			oPrinter:Line(  80, 277,  80, 555)	//Linha 3
			oPrinter:Line( 100, 277, 100, 555)	//Linha 4
			oPrinter:Line( 120, 277, 120, 555)	//Linha 5
			oPrinter:Line( 160, 277, 160, 555)	//Linha 6
			
			//Colunas Cabecario.
			oPrinter:Line(  40, 277, 160, 277)	//Coluna 1
			oPrinter:Line(  60, 370, 120, 370)	//Coluna 2
			oPrinter:Line(  60, 463, 120, 463)	//Coluna 3
			oPrinter:Line(  40, 555, 160, 555)	//Coluna 4
			
			//Linhas Detalhes
			oPrinter:Line( 180,  40, 180, 555)  //Linha 1
			oPrinter:Line( 200,  40, 200, 555)	//Linha 2
			oPrinter:Line( 780,  40, 780, 555)  //Linha 3
			
			//Colunas Detalhes.
			oPrinter:Line( 180,  40, 780,  40)	//Coluna 1
			oPrinter:Line( 180,  80, 780,  80)	//Coluna 2
			oPrinter:Line( 180, 160, 780, 160)	//Coluna 3
			oPrinter:Line( 180, 358, 780, 358)	//Coluna 4
			oPrinter:Line( 180, 555, 780, 555)	//Coluna 5
			
			//Logo
			oPrinter:SayBitmap(40,40,"\system\logoTP.bmp",40,35)
			
			//Dados da Empresa
			oPrinter:Say( 90,40,AllTrim(SM0->M0_NOMECOM),oFont8n)
			oPrinter:Say(100,40,AllTrim(SM0->M0_ENDCOB),oFont8n)
			oPrinter:Say(110,40,AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB),oFont8n)
			oPrinter:Say(120,40,"CNPJ: "+SubStr(SM0->M0_CGC,1,2)+"."+SubStr(SM0->M0_CGC,3,3)+"."+SubStr(SM0->M0_CGC,6,3)+"/"+SubStr(SM0->M0_CGC,9,4)+"-"+SubStr(SM0->M0_CGC,13,2),oFont8n)
			oPrinter:Say(130,40,"Insc. Municipal: 4.613.515-4",oFont8n)
			
			//Titulos das colunas do cabeçalho.
			oPrinter:Say( 55,400,"Relatorio de Campanha",oFont14n)
			oPrinter:Say( 67,307,"NFS-e Nº",oFont8n)
			oPrinter:Say( 77,305,F2_DOC+" "+F2_SERIE,oFont8)	
			oPrinter:Say( 67,400,"Data NFS-e",oFont8n)    
			oPrinter:Say( 77,402,SubStr(DTOS(F2_EMISSAO),7,2)+"-"+SubStr(cMonth(F2_EMISSAO),1,3)+"-"+SubStr(DTOS(F2_EMISSAO),1,4),oFont8)
			oPrinter:Say( 67,493,"Pag.",oFont8n)
			oPrinter:Say( 77,493,AllTrim(STR(nPag)),oFont8)
			oPrinter:Say( 87,305,"Mes Ref.",oFont8n)
			oPrinter:Say( 97,304,SubStr(cMonth(C5_EMISSAO),1,3)+"-"+SubStr(DTOS(C5_EMISSAO),1,4),oFont8)
			oPrinter:Say( 87,410,"Prazo",oFont8n)
			oPrinter:Say( 97,405,E4_DESCRI,oFont8)
			oPrinter:Say( 87,483,"Vencimento",oFont8n)
			oPrinter:Say( 97,485,SubStr(DTOS(cVencto),7,2)+"-"+SubStr(cMonth(cVencto),1,3)+"-"+SubStr(DTOS(cVencto),1,4),oFont8)
			oPrinter:Say(107,300,"Numero PO",oFont8n)
			
			If((Len(AllTrim(C5_P_PO))) <= 6)
				oPrinter:Say(117,310,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)
			ElseIf((Len(AllTrim(C5_P_PO))) >= 6 .AND. (Len(AllTrim(C5_P_PO))) <= 12)
				oPrinter:Say(117,300,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)          
			ElseIf((Len(AllTrim(C5_P_PO))) >= 12 .AND. (Len(AllTrim(C5_P_PO))) <= 19)
				oPrinter:Say(117,285,(AllTrim(SubStr(C5_P_PO,1,19))),oFont8)	
			Else
				oPrinter:Say(113,280,SubStr(C5_P_PO,01,19),oFont8)	
				oPrinter:Say(119,280,SubStr(C5_P_PO,20,19),oFont8)
			EndIf  
			  		
			oPrinter:Say(117,280,C5_P_PO,oFont8)
			oPrinter:Say(107,400,"Numero IO",oFont8n)
			oPrinter:Say(117,407,C5_P_NUM,oFont8)
			
			//Titulo das colunas de detalhes.
			oPrinter:Say(189, 48,"Número ",oFont8n)  
			oPrinter:Say(196, 41.5,"Campanha ",oFont8n) 
			oPrinter:Say(189,104,"Usuario ",oFont8n)  
			oPrinter:Say(196, 98,"Promovido ",oFont8n)
			oPrinter:Say(189,210,"Nome da Campanha ",oFont8n)
			oPrinter:Say(189,400,"Produto ",oFont8n)
			oPrinter:Say(189,400,"Produto ",oFont8n)
		
		EndIf		
		
	ZX1->(DbSkip())		
	EndDo
	
	cDirAnexo :=cLocal+"Campanha"+AllTrim(F2_DOC)+".pdf"
	FErase(cDirAnexo)	 
			
	oPrinter:EndPage() 
	MS_FLUSH()

	If cVer1 == 'S'	
		oPrinter:Preview()
	Else                         
		oPrinter:Print()
		//Copia arquivo para o servidor
		lCompacta := .T.
		CpyT2S(cLocal+"Campanha"+AllTrim(F2_DOC)+".pdf","\FTP\TP\TPFIN001\",lCompacta)
		For nI := 1 To 5
			If !File("\FTP\TP\TPFIN001\Campanha"+AllTrim(F2_DOC)+".pdf")
				Sleep( 5000 )//Para o processamento por 5 segundo	   		
		   	Else
		   		Exit
		   	EndIf
	   	Next nI
	   	FErase(cDirAnexo) 
	EndIf

EndIf

Return