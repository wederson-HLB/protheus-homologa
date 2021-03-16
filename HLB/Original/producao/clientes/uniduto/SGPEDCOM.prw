#include "protheus.ch"
#include "colors.ch"
#Include "Font.ch"
#Include "TopConn.ch"
     
/*
Funcao      : SgPedCom
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão do pedido de compra Uniduto
Autor     	: Tiago Luiz Mendonça
Data     	: 24/01/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Compras.
*/ 

                      
*----------------------------*
  User Function SGPEDCOM()  
*----------------------------*  
 
Private lReg,lAuto		:= .F. 	// Verifica a existência de Registros
Private nLastKey		:= 0
Private titulo   		:= "Pedido de Compra"
Private cMens 			:= "Não há registros para os parametros informados !"
Private nCount			:= 0
Private cPerg			:= "P_SG_COM"
Private cNPc,cPedNum 	:= ""
Private cEmail,cObs  	:= ""
Private cEmissao		:= ""
Private nQtdPag			:= 0
Private oFont1 			:= TFont():New("Arial",09,14,		,.T.,,,,,.F.) //Parametros TFonte ("Tipo Fonte", ,Tamanho Fonte , , ,Italico (.T./.F.))
Private oFont2  		:= TFont():New("Arial",07,08,		,.F.,,,,,.F.) // Normal
Private oFont3  		:= TFont():New("Arial",09,10,.T.	,.T.,,,,,.F.) // Negrito
Private oFont4  		:= TFont():New("Arial",09,14,.T.	,.T.,,,,,.T.) // Negrito - Sublinhado
Private oFont5  		:= TFont():New("Arial",09,10,   	,.F.,,,,,.F.) // Negrito
Private oPrint                                                                      

If !(cEmpAnt $ "SG" .Or. cEmpAnt $ "99" )  
   MsgStop("Relatorio Especifico Uniduto","Atenção") 
   Return .F.
EndIf

//Faz a chamada do grupo de perguntas, caso a chamada seja feita a partir do menu
If !lAuto
	ValidPerg(cPerg)
	If !(Pergunte(cPerg,.T.))
		Return
	Endif
Endif

If lastKey() == 27 .or. nLastKey == 27 .or. nLastKey == 286
	return
Endif

//Instanciando do Objeto OPrint
oPrint := TMSPrinter():New()


   //MsDialog oDlg: exibi as opcoes para tratativa do relatorio.  
   Define MsDialog oDlg Title "Pedido de Compra" From 0, 0 To 090, 510 Pixel
   Define Font oBold Name "Arial" Size 0, -13 Bold
     
      @ 009, 005 Bitmap oBmp ResName "LOGOINTPRYOR" Of oDlg Size 53, 90 NoBorder When .F. Pixel
      @ 003, 070 Say Titulo Font oBold Pixel
      @ 014, 070 To 016, 400 Label '' Of oDlg  Pixel
      @ 020, 070 Button "Configurar" 	Size 40, 13 Pixel Of oDlg Action oPrint:Setup()
      @ 020, 113 Button "Imprimir"   	Size 40, 13 Pixel Of oDlg Action PrintRep(lAuto,cPedNum,1)
      @ 020, 154 Button "Visualizar" 	Size 40, 13 Pixel Of oDlg Action PrintRep(lAuto,cPedNum,2)
      @ 020, 196 Button "Sair"       	Size 40, 13 Pixel Of oDlg Action oDlg:End()
  
   Activate MsDialog oDlg Centered

Return

*-------------------------------------------------*
   Static Function PrintRep(lAuto,cPedNum,nOpc) 
*-------------------------------------------------*
   
Local cQuery := ""

If nOpc == 1 .OR. nOpc == 2
	oPrint := TMSPrinter():New()	
EndIf

//Query que retorna os dados do pedido de compra e os dados dos itens.
cQuery := "SELECT "
cQuery += 	 "C7_EMISSAO,C7_NUM,C7_DATPRF,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_IPI,C7_PRECO,C7_TOTAL,"
cQuery += 	 "C7_VALIPI,C7_VALFRE,C7_SEGURO,C7_VALICM,C7_DESPESA,C7_VLDESC,C7_TPFRETE,C7_CC,C7_OBS,C7_CONAPRO,C7_USER,C7_IPI,"
cQuery += 	 "C7_MSG,C7_DESC1,C7_DESC2,C7_DESC3,C7_COND,C7_VALFRE, C7_TES,C7_MOEDA,C7_P_OBS_I,"
cQuery += 	 "A2_COD, A2_HPAGE, A2_NOME,A2_END,A2_CEP,A2_DDD,A2_TEL,A2_FAX,A2_EMAIL,A2_CGC,A2_INSCR,A2_MUN, A2_CONTATO, A2_BAIRRO, "     
cQuery +=    "E4_DESCRI "
cQuery += "FROM "
cQuery +=    RetSqlName("SC7") + " AS SC7 " 
cQuery += "LEFT JOIN "
cQuery +=    RetSqlName("SE4") + " AS SE4 ON E4_FILIAL = '" + xFilial("SE4") + "' AND C7_COND = E4_CODIGO AND SE4.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN "
cQuery +=    RetSqlName("SA2") + " AS SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery +=    "C7_FILIAL = '" + xFilial("SC7") + "' "

If !lAuto
   cQuery +=    "AND C7_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
   If !Empty(mv_par03) .AND. !Empty(mv_par04)
      cQuery +=    "AND C7_EMISSAO BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
   EndIf
   //cQuery +=    "AND C7_PRODUTO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
Else
   cQuery +=    "AND C7_NUM = '" + cPedNum + "' "
Endif
cQuery +=    "AND SC7.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY C7_NUM, C7_ITEM "

TCQUERY cQuery NEW ALIAS "cAlias"

TCSETFIELD("cAlias", "C7_EMISSAO",	"D", 08, 00)
TCSETFIELD("cAlias", "C7_DATPRF" ,	"D", 08, 00)
TCSETFIELD("cAlias", "C7_P_OBS_I",	"C", 150, 00)

Count to nCount

cAlias->(dbgotop())

Do While cAlias->(!Eof())
   
   cNPc 		:= cAlias->C7_NUM
   cEmissao	:= cAlias->C7_EMISSAO
   lReg		:= .T.
	
   // Query que retorna a Quantidade Total de itens do Pedido de Compra
   cQuery := "SELECT COUNT(C7_ITEM) AS Total "
   cQuery += " FROM " + RetSqlName("SC7")
   cQuery += " WHERE C7_NUM = '" + cAlias->C7_NUM + "' AND D_E_L_E_T_ = ' '"
	
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "cCount", .T., .T. )
	
   // Atribui a Quantidade Total de itens na Variavel nCount
   nCount := cCount->Total
	
   // Controla a Quantidade de Paginas no Relatorio
   nQtdPag := STR((cCount->Total / 30)+ 1)
   nQtdPag := LEFT(nQtdPag, AT(".",nQtdPag)-1)
	
   cCount->(dbCloseArea())
	
   //Inicia uma Nova Pagina para Impressao
   oPrint:StartPage()
	
   //Define o modo de Impressao como Retrato
   oPrint:SetPortrait()  //SetLandscape -> Para definir como modo Paisagem
	   
   IMPCAB(cNPc, cEMISSAO)	//Funcao para impressao do Cabecalho
   IMPCLI()	//Funcao para impressao dos dados do Cliente
   IMPPRO(cNPc,nCount,nQtdPag)	//Funcao para impressao dos Detalhes do Produto
	
   cAlias->(dbSkip())
   
EndDo

cAlias->(dbCloseArea())

If lReg = .F.
	MsgSTOP(cMens)
Endif 


//Verifica a operacao a ser executada							     
Do Case 
	Case nOpc == 1 
		oPrint:Print()
	Case nOpc == 2
		oPrint:Preview()
End Case

Return

//Impressao do cabecalho do relatorio.	 
*---------------------------------------*
  Static Function IMPCAB(cNPc, cEMISSAO) 
*---------------------------------------*

Local nTopo			:= 0000  // Controle de Linhas
Local nInicio		:= 0000  // Indica a posição da primeira coluna
Local cEmail 		:= GetMV("MV_P_EMAIL")
Local cLogo			:= GetMV("MV_P_LOGO")


//Retorna o tamanho Horizontal e Vertical da pagina.                                          
nVertSize := oPrint:nVertSize()
nHorzSize := oPrint:nHorzSize()

// oPrint:SayBitmap(Coluna, Linha, Caminho, Largura, Altura)
oPrint:SayBitmap(nTopo + 0050, nInicio + 0040,cLogo,800, 200)


dbSelectArea("SM0")
SM0->(dbseek(cEmPant + cFilant))

// oPrint:Say(Coluna, Linha, Texto, Fonte, Num de Caracteres, , ,Alinhamento - 0=Left, 1=Right e 2=Center)
oPrint:Say(nTopo + 0050, nInicio + 2360,RTrim(SM0->M0_NOMECOM)												   		,oFont1,100,,,1)
oPrint:Say(nTopo + 0100, nInicio + 2360, AllTrim(SM0->M0_ENDENT) + " " + AllTrim(SM0->M0_CIDENT) + "/" + AllTrim(SM0->M0_ESTENT) + " " + LEFT(AllTrim(SM0->M0_CEPENT),5) + "-" + RIGHT(AllTrim(SM0->M0_CEPENT),3)		,oFont5,100,,,1)
oPrint:Say(nTopo + 0150, nInicio + 2360, "E-mail: " + Alltrim(cEmail)								   			,oFont3,100,,,1)//							   			,oFont3,100,,,1)
oPrint:Say(nTopo + 0200, nInicio + 2360, "Fone: " + AllTrim(SM0->M0_TEL) + " FAX: " + AllTrim(SM0->M0_FAX)	   		,oFont5,100,,,1)
oPrint:Say(nTopo + 0250, nInicio + 2360, "CNPJ: " + AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")) + " - IE: " +  AllTrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))	,oFont5,100,,,1)

// oPrint:Line(Coluna, Linha, Coluna, Linha)
oPrint:Line(nTopo + 0310, nInicio + 0040,nTopo + 0310, nInicio + 2360)
oPrint:Line(nTopo + 0313, nInicio + 0040,nTopo + 0313, nInicio + 2360)
oPrint:Line(nTopo + 0410, nInicio + 0040,nTopo + 0410, nInicio + 2360)
oPrint:Line(nTopo + 0413, nInicio + 0040,nTopo + 0413, nInicio + 2360)

oPrint:Say(nTopo + 0335	, nInicio + 0040, "Pedido de Compra Nº " + cNPc		,oFont1,100,,,0)
oPrint:Say(nTopo + 0335	, nInicio + 2360,"Data: " + DTOC(cEMISSAO)			,oFont1,100,,,1)

Return


//Impressao dos Dados do Cliente.			
*--------------------------*
  Static Function IMPCLI()   
*--------------------------*

Local nTopo			:= 0000		// Controle de Linhas
Local nInicio		:= 0000		// Indica a posicao da primeira coluna
Local cSiglaMoeda	:= ""		// Sigla da Moeda


//Impressão da Estrutura dos Dados do Cliente.                                               
oPrint:Say(nTopo + 0430	, nInicio + 0040, "Fornecedor" 	,oFont3,100,,,0)
oPrint:Say(nTopo + 0480	, nInicio + 0040, "E-mail"		,oFont3,100,,,0)
oPrint:Say(nTopo + 0530	, nInicio + 0040, "Endereço"		,oFont3,100,,,0)
oPrint:Say(nTopo + 0580	, nInicio + 0040, "Cidade"	  	,oFont3,100,,,0)
oPrint:Say(nTopo + 0630	, nInicio + 0040, "Fone"  		,oFont3,100,,,0)

If Len(AllTrim(cAlias->A2_CGC)) > 11
   oPrint:Say(nTopo + 0680	, nInicio + 0040, "CNPJ"  	,oFont3,100,,,0)
Else
   oPrint:Say(nTopo + 0680	, nInicio + 0040, "CPF"  	,oFont3,100,,,0)
EndIF

oPrint:Say(nTopo + 0730	, nInicio + 0040, "Site"  		,oFont3,100,,,0)

//Texto Centralizado
oPrint:Say(nTopo + 0480	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Contato" 			,oFont3,100,,,0)
oPrint:Say(nTopo + 0530	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Area"				,oFont3,100,,,0)
oPrint:Say(nTopo + 0580	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"CEP"       		,oFont3,100,,,0)
oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"FAX"				,oFont3,100,,,0)
oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"IE"				,oFont3,100,,,0)
oPrint:Say(nTopo + 0730	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Moeda"			,oFont3,100,,,0)

// Texto a Esquerda
oPrint:Say(nTopo + 0430	, nInicio + 0240, ": " + cAlias->A2_COD + " - " + cAlias->A2_NOME												,oFont5,100,,,0)
oPrint:Say(nTopo + 0480	, nInicio + 0240, ": " + cAlias->A2_EMAIL																		,oFont5,100,,,0)
oPrint:Say(nTopo + 0530	, nInicio + 0240, ": " + cAlias->A2_END																			,oFont5,100,,,0)
oPrint:Say(nTopo + 0580	, nInicio + 0240, ": " + cAlias->A2_MUN	   																		,oFont5,100,,,0)
oPrint:Say(nTopo + 0630	, nInicio + 0240, ": (" + cAlias->A2_DDD + ") " + LEFT(cAlias->A2_TEL,4) + "-" + SUBSTR(cAlias->A2_TEL,5,8)	 	,oFont5,100,,,0)

If Len(AllTrim(cAlias->A2_CGC)) > 11
   oPrint:Say(nTopo + 0680	, nInicio + 0240, ": " + AllTrim(Transform(cAlias->A2_CGC,"@R 99.999.999/9999-99")) 						,oFont5,100,,,0)
Else
   oPrint:Say(nTopo + 0680	, nInicio + 0240, ": " + AllTrim(Transform(cAlias->A2_CGC,"@R 999.999.999-99"))								,oFont5,100,,,0)
EndIf

oPrint:Say(nTopo + 0730	, nInicio + 0240, ": " + cAlias->A2_HPAGE ,oFont5,100,,,0)

//Texto Centralizado
oPrint:Say(nTopo + 0480	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + cAlias->A2_CONTATO																	,oFont5,100,,,0)
oPrint:Say(nTopo + 0530	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + cAlias->A2_BAIRRO																		,oFont5,100,,,0)
oPrint:Say(nTopo + 0580	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + LEFT(cAlias->A2_CEP,5) + "-" + RIGHT(cAlias->A2_CEP,3)								,oFont5,100,,,0)
oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": (" + cAlias->A2_DDD + ") " + LEFT(cAlias->A2_FAX,4) + "-" + SUBSTR(cAlias->A2_FAX,5,8)	,oFont5,100,,,0)

If Len(AllTrim(cAlias->A2_INSCR)) > 6
   oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150, ": " + AllTrim(Transform(cAlias->A2_INSCR,"@R 999.999.999.999")) 						,oFont5,100,,,0)
Else
   oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150, ": " + AllTrim(cAlias->A2_INSCR) 														,oFont5,100,,,0)
EndiF

// Pega o simbolo da moeda.
cSiglaMoeda	:= Posicione("CTO", 1, xFilial("CTO") + StrZero(cAlias->C7_MOEDA, 2), "CTO_SIMB")
oPrint:Say(nTopo + 0730	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150, ": " + AllTrim(cSiglaMoeda)		 															,oFont5,100,,,0)

Return


//Impressao dos Dados de Detalhes dos Produtos.
*------------------------------------------------*
   Static Function IMPPRO(cNPc, nCount, nQtdPag)
*------------------------------------------------*

Local nTopo		:= 0800  // Controle de Linhas
Local nInicio	:= 0000  // Indica a posição da primeira coluna
Local nTotal	:= 0000  // Controle do Valor Total do Pedido
Local nVTIpi	:= 0000  // Controle do Valor Total do Pedido com IPI
Local nPag		:= 1
Local nCont		:= 1
Local nContP	:= 0
Local nTotal2	:= 0
Local nDespesa  := 0
Local nFrete    := 0
Local nTamDes	:= 0
Local nTamStr	:=0

Private nTpag	:= 0

//Box, Linhas Verticais e Dados do Cabecalho de Pedido.                                        
oPrint:Box(nTopo, nInicio + 0040, nTopo + 0050, nInicio + 2360)

//Linhas Verticais
oPrint:Line(nTopo,nInicio + 0180,nTopo + 0050,nInicio + 0180)
oPrint:Line(nTopo,nInicio + 0480,nTopo + 0050,nInicio + 0480)
oPrint:Line(nTopo,nInicio + 1080,nTopo + 0050,nInicio + 1080)
oPrint:Line(nTopo,nInicio + 1180,nTopo + 0050,nInicio + 1180)
oPrint:Line(nTopo,nInicio + 1320,nTopo + 0050,nInicio + 1320)
oPrint:Line(nTopo,nInicio + 1620,nTopo + 0050,nInicio + 1620)
oPrint:Line(nTopo,nInicio + 1920,nTopo + 0050,nInicio + 1920)
oPrint:Line(nTopo,nInicio + 2050,nTopo + 0050,nInicio + 2050)

// Texto
oPrint:Say(nTopo + 0007,nInicio + 0060,"Seq."   				,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 0200,"Código Item"			,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 0500,"Descrição"				,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 1100,"UM"						,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 1200,"Qtd."					,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 1340,"Preço Unit."		    ,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 1640,"Preço Total"			,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 1940,"IPI"	  				,oFont3,100,,,0)
oPrint:Say(nTopo + 0007,nInicio + 2070,"Data de Entrega"		,oFont3,100,,,0)

Do While cAlias->(!Eof()) .AND. cAlias->C7_NUM == cNPc
                         
   If !(alltrim(cAlias->C7_P_OBS_I) $ cObs) .And. !Empty(alltrim(cAlias->C7_P_OBS_I))
      cObs:=Alltrim(cObs)+" / "+Alltrim(cAlias->C7_P_OBS_I)                           
    
   EndIf
   
   //Caso ultrapasse o limite gera uma Nova Pagina                              				
   If (nTopo + 0130) >= 2550
		
      //Encerra a Pagina Atual
      oPrint:EndPage() 	
		
      //Inicia uma Nova Pagina para Impressao
      oPrint:StartPage()
       
      //Define o modo de Impressão como Retrato
      oPrint:SetPortrait()   //SetLandscape -> Para definir como modo Paisagem
		
      //Funcao para impressao do Cabecalho
      IMPCAB(cNPc, cEMISSAO)

      //Incrementa o contador de Paginas
      nPag ++
		
      nTopo := 0450
		
      //Box, Linhas Verticais e Dados do Cabecalho de Pedido.                                       
      oPrint:Box(nTopo, nInicio + 0040, nTopo + 0050, nInicio + 2360)
		
      //Linhas Verticais
      oPrint:Line(nTopo,nInicio + 0180,nTopo + 0050,nInicio + 0180)
      oPrint:Line(nTopo,nInicio + 0480,nTopo + 0050,nInicio + 0480)
      oPrint:Line(nTopo,nInicio + 1080,nTopo + 0050,nInicio + 1080)
      oPrint:Line(nTopo,nInicio + 1180,nTopo + 0050,nInicio + 1180)
      oPrint:Line(nTopo,nInicio + 1320,nTopo + 0050,nInicio + 1320)
      oPrint:Line(nTopo,nInicio + 1620,nTopo + 0050,nInicio + 1620)
      oPrint:Line(nTopo,nInicio + 1920,nTopo + 0050,nInicio + 1920)
      oPrint:Line(nTopo,nInicio + 2050,nTopo + 0050,nInicio + 2050)
		
      //Texto
      oPrint:Say(nTopo + 0007,nInicio + 0060,"Seq."     				,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 0200,"Código Produto"		    ,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 0500,"Descrição"				,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 1100,"UM"						,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 1200,"Qtd."						,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 1340,"Preço Unit."				,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 1640,"Preço Total"				,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 1940,"IPI"	  					,oFont3,100,,,0)
      oPrint:Say(nTopo + 0007,nInicio + 2070,"Data de Entrega"		   	,oFont3,100,,,0)
      
   EndIF
	
   //Box, Linhas Verticais, Linhas Horizontais e Dados do Pedido.  
   nTamDes := LEN(ALLTRIM(cAlias->C7_DESCRI)) / 30

   If nTamDes > 2
   
      //Linhas Verticais - Divisao Colunas
      oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)
      oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
      oPrint:Line(nTopo + 0030,nInicio + 0180,nTopo + 0090,nInicio + 0180)
      oPrint:Line(nTopo + 0030,nInicio + 0480,nTopo + 0090,nInicio + 0480)
      oPrint:Line(nTopo + 0030,nInicio + 1080,nTopo + 0090,nInicio + 1080)
      oPrint:Line(nTopo + 0030,nInicio + 1180,nTopo + 0090,nInicio + 1180)
      oPrint:Line(nTopo + 0030,nInicio + 1320,nTopo + 0090,nInicio + 1320)
      oPrint:Line(nTopo + 0030,nInicio + 1620,nTopo + 0090,nInicio + 1620)
      oPrint:Line(nTopo + 0030,nInicio + 1920,nTopo + 0090,nInicio + 1920)
      oPrint:Line(nTopo + 0030,nInicio + 2050,nTopo + 0090,nInicio + 2050)
      
      //Impressao dos Campos dos Detalhes dos Produtos
      oPrint:Say(nTopo + 0057, nInicio + 0060, Ltrim(cAlias->C7_ITEM)													,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 0200, Ltrim(cAlias->C7_PRODUTO)												,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 0500, SubStr(Ltrim(cAlias->C7_DESCRI),1,30)									,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 1100, LTrim(cAlias->C7_UM)													,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 1300, Alltrim(STR(cAlias->C7_QUANT))  										,oFont2,100,,,1)
      oPrint:Say(nTopo + 0057, nInicio + 1600, Alltrim(Transform(cAlias->C7_PRECO, PesqPict('SC7', 'C7_PRECO')))		,oFont2,100,,,1)
      oPrint:Say(nTopo + 0057, nInicio + 1900, Alltrim(Transform(cAlias->C7_TOTAL, PesqPict('SC7', 'C7_TOTAL')))		,oFont2,100,,,1)
		
      dbSelectArea("SF4")
      dbSetOrder(1)
      dbSeek(xFilial("SF4") + cAlias->C7_TES)
      
      If SF4->F4_IPI == "S"
         oPrint:Say(nTopo + 0057, nInicio + 2030, Alltrim(STR(cAlias->C7_IPI,4,1))								,oFont2,100,,,1)
      Else
         oPrint:Say(nTopo + 0057, nInicio + 2030, "0.0"															,oFont2,100,,,1)
      EndIf
	  
      SF4->(dbCloseArea())
      oPrint:Say(nTopo + 0057, nInicio + 2070, DTOC(cAlias->C7_DATPRF)												,oFont2,100,,,0)
      nTamStr := 31
		
      For nCon := 2 to Int(nTamDes) + 1
         
         nTopo += 0050
		 //Caso ultrapasse o limite gera uma Nova Pagina                              					 
		 If (nTopo + 0130) >= 2550
		 
			nTopo := 0450
			
			//Encerra a Pagina Atual
            oPrint:EndPage()  
			
			//Inicia uma Nova Pagina para Impressao
			oPrint:StartPage()
				
			//Define o modo de Impressão como Retrato
			oPrint:SetPortrait()   //SetLandscape -> Para definir como modo Paisagem
			
			//Funcao para impressao do Cabecalho
			IMPCAB(cNPc, cEMISSAO)
			
			//Incrementa o contador de Paginas
		    nPag := nPag + 1
			
			
				
			//Box, Linhas Verticais e Dados do Cabecalho de Pedido.                          
			oPrint:Box(nTopo, nInicio + 0040, nTopo + 0050, nInicio + 2360)
				
			//Linhas Verticais
			oPrint:Line(nTopo,nInicio + 0180,nTopo + 0050,nInicio + 0180)
			oPrint:Line(nTopo,nInicio + 0480,nTopo + 0050,nInicio + 0480)
			oPrint:Line(nTopo,nInicio + 1080,nTopo + 0050,nInicio + 1080)
			oPrint:Line(nTopo,nInicio + 1180,nTopo + 0050,nInicio + 1180)
			oPrint:Line(nTopo,nInicio + 1320,nTopo + 0050,nInicio + 1320)
			oPrint:Line(nTopo,nInicio + 1620,nTopo + 0050,nInicio + 1620)
			oPrint:Line(nTopo,nInicio + 1920,nTopo + 0050,nInicio + 1920)
			oPrint:Line(nTopo,nInicio + 2050,nTopo + 0050,nInicio + 2050)
				
			//Texto
			oPrint:Say(nTopo + 0007,nInicio + 0060,"Seq."	    			   	,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 0200,"Código Produto"				,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 0500,"Descrição"			     	,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1100,"UM"							,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1200,"Qtd."						,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1340,"Preço Unit."				,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1640,"Preço Total"				,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1940,"IPI"	  					,oFont3,100,,,0)
		    oPrint:Say(nTopo + 0007,nInicio + 2070,"Data de Entrega"			,oFont3,100,,,0)
		 EndIF

         //Linhas Verticais - Divisao Colunas
         oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)
         oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
			
         oPrint:Line(nTopo + 0030,nInicio + 0180,nTopo + 0090,nInicio + 0180)
         oPrint:Line(nTopo + 0030,nInicio + 0480,nTopo + 0090,nInicio + 0480)
         oPrint:Line(nTopo + 0030,nInicio + 1080,nTopo + 0090,nInicio + 1080)
         oPrint:Line(nTopo + 0030,nInicio + 1180,nTopo + 0090,nInicio + 1180)
         oPrint:Line(nTopo + 0030,nInicio + 1320,nTopo + 0090,nInicio + 1320)
         oPrint:Line(nTopo + 0030,nInicio + 1620,nTopo + 0090,nInicio + 1620)
         oPrint:Line(nTopo + 0030,nInicio + 1920,nTopo + 0090,nInicio + 1920)
         oPrint:Line(nTopo + 0030,nInicio + 2050,nTopo + 0090,nInicio + 2050)
         oPrint:Say(nTopo + 0057, nInicio + 0500, Substr(Ltrim(cAlias->C7_DESCRI),nTamStr,30)		,oFont2,100,,,0)
			
         nTamStr := nTamStr + 30
      Next
   Else
      //Linhas Verticais - Divisao Colunas
      oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)
      oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
      oPrint:Line(nTopo + 0030,nInicio + 0180,nTopo + 0090,nInicio + 0180)
      oPrint:Line(nTopo + 0030,nInicio + 0480,nTopo + 0090,nInicio + 0480)
      oPrint:Line(nTopo + 0030,nInicio + 1080,nTopo + 0090,nInicio + 1080)
      oPrint:Line(nTopo + 0030,nInicio + 1180,nTopo + 0090,nInicio + 1180)
      oPrint:Line(nTopo + 0030,nInicio + 1320,nTopo + 0090,nInicio + 1320)
      oPrint:Line(nTopo + 0030,nInicio + 1620,nTopo + 0090,nInicio + 1620)
      oPrint:Line(nTopo + 0030,nInicio + 1920,nTopo + 0090,nInicio + 1920)
      oPrint:Line(nTopo + 0030,nInicio + 2050,nTopo + 0090,nInicio + 2050)
		
      //Impressao dos Campos dos Detalhes dos Produtos
      oPrint:Say(nTopo + 0057, nInicio + 0060, Ltrim(cAlias->C7_ITEM)											,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 0200, Ltrim(cAlias->C7_PRODUTO)										,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 0500, Ltrim(cAlias->C7_DESCRI)											,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 1100, LTrim(cAlias->C7_UM)												,oFont2,100,,,0)
      oPrint:Say(nTopo + 0057, nInicio + 1300, Alltrim(STR(cAlias->C7_QUANT))  									,oFont2,100,,,1)
      oPrint:Say(nTopo + 0057, nInicio + 1600, Alltrim(Transform(cAlias->C7_PRECO,PesqPict('SC7', 'C7_PRECO')))	,oFont2,100,,,1)
      oPrint:Say(nTopo + 0057, nInicio + 1900, Alltrim(Transform(cAlias->C7_TOTAL,PesqPict('SC7', 'C7_TOTAL')))	,oFont2,100,,,1)
   
      dbSelectArea("SF4")
      dbSetOrder(1)
      
      oPrint:Say(nTopo + 0057, nInicio + 2030, Alltrim(STR(cAlias->C7_IPI,4,1))								,oFont2,100,,,1)
      SF4->(dbCloseArea())
      oPrint:Say(nTopo + 0057, nInicio + 2070, DTOC(cAlias->C7_DATPRF)												,oFont2,100,,,0)
      	
   EndIf
	
   //Calculo do Valor Total do Pedido de Compra
   nTotal += cAlias->C7_TOTAL
   nFrete += cAlias->C7_VALFRE
   nDespesa += cAlias->C7_DESPESA
	
   nTopo += 0050
	
   //Incrementa Contador da Quantidade de Itens no Pedido de Compra
   nCont ++
	
   //Se o arquivo chegou ao fim, imprime rodape.
   If nCont > nCount
      
      nTotal2 := nTotal + nFrete + nDespesa
	  oPrint:Box(nTopo + 0060, nInicio + 0480, nTopo + 0110, nInicio + 1300)
	  oPrint:Line(nTopo + 0060, nInicio + 0970,nTopo + 0110,nInicio + 0970)
	  oPrint:Say(nTopo + 0067, nInicio + 0500, "Frete"		,oFont3,100,,,0)
	  oPrint:Say(nTopo + 0067, nInicio + 1280, Alltrim(Transform(nFrete,PesqPict('SC7', 'C7_VALFRE')))							,oFont3,100,,,1)
	  oPrint:Box(nTopo + 0110, nInicio + 0480, nTopo + 0160, nInicio + 1300)
	  oPrint:Line(nTopo + 0110, nInicio + 0970,nTopo + 0160,nInicio + 0970)
	  oPrint:Say(nTopo + 0117, nInicio + 0500, "Outras Despesas"		,oFont3,100,,,0)
	  oPrint:Say(nTopo + 0117, nInicio + 1280, Alltrim(Transform(nDespesa,PesqPict('SC7', 'C7_DESPESA')))							,oFont3,100,,,1)
		
	  //Box e Dados - Valor Total
	  oPrint:Box(nTopo + 0060, nInicio + 1320, nTopo + 0110, nInicio + 1920)
	  oPrint:Line(nTopo + 0060, nInicio + 1620,nTopo + 0110,nInicio + 1620)
	  oPrint:Say(nTopo + 0067, nInicio + 1340, "Sub Total"		,oFont3,100,,,0)
	  oPrint:Say(nTopo + 0067, nInicio + 1900, Alltrim(Transform(nTotal,PesqPict('SC7', 'C7_TOTAL')))								,oFont3,100,,,1)
	  oPrint:Box(nTopo + 0110, nInicio + 1320, nTopo + 0160, nInicio + 1920)
	  oPrint:Line(nTopo + 0110, nInicio + 1620,nTopo + 0160,nInicio + 1620)
	  oPrint:Say(nTopo + 0117, nInicio + 1340, "Pedido Total"		,oFont3,100,,,0)
	  oPrint:Say(nTopo + 0117, nInicio + 1900, Alltrim(Transform(nTotal2,PesqPict('SC7', 'C7_TOTAL')))							,oFont3,100,,,1)
	  oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
		
	  //Funcao de Impressao do Rodape. Parametro: Numero da linha atual   
  
      IMPROD(NPag, nTotal, nTopo)
      
   EndIf
   cAlias->(dbskip())

EndDo


Return

//Funcao para impressao do Rodape.		                                        
*----------------------------------------------*
  Static Function IMPROD(nPag, nTotal, nTopo)  
*----------------------------------------------*   

Local nInicio		:= 0000  // Indica a posicao da primeira coluna
Local cRemarks		:= ""

If nTopo <= (Mm2Pix(oPrint, oPrint:nVertSize()) - 1620)				// Valore das Linhas acrescidos de 1080 pixels)
   
   // Box Condicoes Gerais
   oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 1620, nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 800, nInicio + 2360 )//2360)    
   // Titulo Centralizado
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 1600, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Termos e condições gerais",oFont1,100,,,2)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, nInicio + 0060,"Condição de pagamento",oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, nInicio + 0435,": " + cAlias->C7_COND + " - " + cAlias->E4_DESCRI	,oFont5,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2, "Incoterms" 	,oFont3,100,,,0)
	
   If AllTrim(cAlias->C7_TPFRETE) = "C"
      oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0200,": CIF",oFont5,100,,,0)
   Else
      oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0200,": FOB"	,oFont5,100,,,0)
   EndIf
	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1450, nInicio + 0060,"Desconto " 	,oFont3,100,,,0) 
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1450, nInicio + 0400," : "+ Alltrim(Str(cAlias->C7_VLDESC)), oFont3,100,,,0)	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1400, nInicio + 0060,"Observação"	,oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1400, nInicio + 0400," : "+ SubStr(cObs,3,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1350, nInicio + 0400,SubStr(cObs,86,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1300, nInicio + 0400,SubStr(cObs,256,85), oFont3,100,,,0)  
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1250, nInicio + 0400,SubStr(cObs,341,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1200, nInicio + 0400,SubStr(cObs,426,85), oFont3,100,,,0) 	
 
   
  
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600, 270,"____________________",oFont1,100,,,2) 
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550, 280,"Comprador"	,oFont1,100,,,2)    
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600,880,"_____________________",oFont1,100,,,2)     
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550,890,"Gerência"		,oFont1,100,,,2)    
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600, 1500,"____________________"	,oFont1,100,,,2)   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550, 1510,"Diretoria"		,oFont1,100,,,2)   
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600,2100,"____________________"	,oFont1,100,,,2) 
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550,2110,"Diretoria"		,oFont1,100,,,2)  

   //Imprime o Numero de Paginas
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0180, nInicio + 2360,"Página: " + str(nPag) + " / " + AllTrim(nQtdPag)  						,oFont3,100,,,1)
   oPrint:EndPage()

Else
   
   //Encerra a Pagina Atual
   oPrint:EndPage()
	
   //Inicia uma Nova Pagina para Impressao
   oPrint:StartPage()
   
   //Define o modo de Impressão como Retrato
   oPrint:SetPortrait()  //SetLandscape -> Para definir como modo Paisagem
   
   //Funcao para impressao do Cabecalho
   IMPCAB(cNPc, cEMISSAO)
   nTopo := 0420
	
   NPag += 1
	
   // Box Condicoes Gerais
   oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 1620, nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 800, nInicio + 2360 )//2360)    
	
   // Titulo Centralizado
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 1600, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Termos e condições gerais"				,oFont1,100,,,2)
	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, nInicio + 0060,"Condição de pagamento"  						  								,oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, nInicio + 0435,": " + cAlias->C7_COND + " - " + cAlias->E4_DESCRI						,oFont5,100,,,0)
	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Incoterms"  									,oFont3,100,,,0)
  
   If AllTrim(cAlias->C7_TPFRETE) = "C"
      oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0200,": CIF"								,oFont5,100,,,0)
   Else
      oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1520, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0200,": FOB"								,oFont5,100,,,0)
   EndIf
	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1450, nInicio + 0060,"Desconto " 	,oFont3,100,,,0) 
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1450, nInicio + 0400," : "+ Alltrim(Str(cAlias->C7_VLDESC)), oFont3,100,,,0)	
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1400, nInicio + 0060,"Observação"	,oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1400, nInicio + 0400," : "+ SubStr(cObs,3,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1350, nInicio + 0400,SubStr(cObs,86,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1300, nInicio + 0400,SubStr(cObs,256,85), oFont3,100,,,0)  
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1250, nInicio + 0400,SubStr(cObs,341,85), oFont3,100,,,0)
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 1200, nInicio + 0400,SubStr(cObs,426,85), oFont3,100,,,0) 	
 
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600, 270,"____________________",oFont1,100,,,2) 
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550, 280,"Comprador"	,oFont1,100,,,2)    
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600,880,"_____________________",oFont1,100,,,2)     
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550,890,"Gerência"		,oFont1,100,,,2)    
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600, 1500,"____________________"	,oFont1,100,,,2)   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550, 1510,"Diretoria"		,oFont1,100,,,2)   
   
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 600,2100,"____________________"	,oFont1,100,,,2) 
   oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 550,2110,"Diretoria"		,oFont1,100,,,2)  
 		
   //Imprime o Numero de Paginas 
     
   oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0180, nInicio + 2360,"Página: " + str(nPag) + " / " + AllTrim(nQtdPag)   						,oFont3,100,,,1)
   oPrint:EndPage()
	
EndIf
      
Return .F.

//Retorna a Largura da Pagina em Pixel.	
*---------------------------------------*
  Static Function Mm2Pix(oPrint, nMm)    
*---------------------------------------*  

Local nValor := (nMm * 300) / 25.4

Return nValor

//Valida se existe um grupo de perguntas caso contrario 
*------------------------------------*
   Static Function ValidPerg(cPerg)   
*------------------------------------*

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/	Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs, {cPerg, "01", "Pedido de "        			,"" ,"" ,"mv_ch1", "C", 06, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SC7"})
aAdd(aRegs, {cPerg, "02", "Pedido até "        			,"" ,"" ,"mv_ch2", "C", 06, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SC7"})
aAdd(aRegs, {cPerg, "03", "Data de "        			,"" ,"" ,"mv_ch3", "D", 08, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
aAdd(aRegs, {cPerg, "04", "Data até "        			,"" ,"" ,"mv_ch4", "D", 08, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
//aAdd(aRegs, {cPerg, "05", "Produto de "     			,"" ,"" ,"mv_ch5", "C", 15, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1"})
//aAdd(aRegs, {cPerg, "06", "Produto até "     			,"" ,"" ,"mv_ch6", "C", 15, 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1"})
//aAdd(aRegs, {cPerg, "03", "Onde Criar?"  				,"" ,"" ,"mv_ch3", "C", 08, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

For i:=1 to Len(aRegs)
   If !dbSeek(cPerg+aRegs[i,2])
      RecLock("SX1",.T.)
      For j:=1 to FCount()
         If j <= Len(aRegs[i])
            FieldPut(j,aRegs[i,j])
         Endif
      Next
      MsUnlock()
   Endif
Next

dbSelectArea(_sAlias)

Return .T.

