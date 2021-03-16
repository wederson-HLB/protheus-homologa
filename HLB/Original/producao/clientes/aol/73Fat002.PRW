#Include "topconn.ch"                           
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#include "fileio.ch"  
#include "protheus.ch"
#include "intpryor.ch"
#INCLUDE "Average.ch"           

 
/*                                                                                                          
Funcao      : 73Fat002
Objetivos   : Integração de arquivos 
Autor       : Leandro Brito
Obs.        :  ** Adaptado através do fonte IntPryor.Prw para executar somente a integração de pedidos customizado pro cliente AOL  **
Data        : 19/02/2016
*/       
*--------------------------*
User Function 73Fat002() 
*--------------------------*                             
Local cText,aSays,aBto 

Local nMaxOpc := 13
Local nCbx    := 0  

Private OdlgPrin
Private oMain, oCbx,  oBtn 
Private aButtons :={} 

Private aItensP  :={STR001,STR002,STR003,STR004,"NF de entrada (.CSV)",;
					STR006,STR060,STR062,STR065,STR066,STR067,STR068,;
					"Pedido / Nota Fiscal de Saída ? (S/ Incl. Cliente)",;
					"Complemento de Produto",;
					STR069,;
					"Contas a Receber",;
					"Ativos",;
					"Purchase Order (SI automatica.)",;
					"Pre NF de entrada (.CSV)",;
					"Saldo Inicial",;
					"Contas a Pagar",;
					"Medicoes/Entregas"}
      /*  //NAO ALTERAR A ORDEM DOS ITENS NO ARRAY, POIS ALGUNS TRATAMENTOS NO FONTE
      		ESTA COM A POSIÇÂO TRAVADA.
      Conteúdo MV_P_INT_P / aItensP    
      1 - Produto
	  2 - Cliente
	  3 - Fornecedor
	  4 - Pedido de Compra
	  5 - NF de entrada (.CSV)         Antiga:5 - Pre/Nota (NFE)
	  6 - Pedido (NFS)
 	  7 - Contabil
      8 - XML de Pre NF de entrada
      9 - Funcionário   
      A - SI Importação
	  B - XML de Pre NF de frete (CTR)
      C - Estrutura de Produtos
      D - Pedido/NF de Saída, S/ incl. CLiente?
      E - Complemento de Produto
      F - Produto X Fornecedor
      G - Contas a Receber
      H - Ativos     
      I - Purchase Order (SI automatica.)
	  J - Pre NF de entrada (.CSV)
	  K - Saldo Inicial
	  L - Contas a Pagar
	  M - Medicoes/Entregas
      */
Private cArq     := ""
Private cAux     := ""
Private cTipo    := "" 
Private cArquivo := "C:\"+Space(50)    
Private cMarca   := GetMark()  
Private lClient  := .F.
Private lProdut  := .F.
Private lNfentr  := .F.
Private lPedido  := .F.
Private lAut     := .F.
Private lRet     := .T.
Private nSelec 
Private cContParam:=""
Private lOpen:=.F.
Private lDiscovery:= .F. 
Private xPreSel
                                                            
If ( cEmpAnt <> '73' )
	MsgStop( 'Empresa nao autorizada.' )
	Return
EndIf

aSays :={}
aBto  :={}

aadd(aButtons,{STR007,{|| Ordena()}  ,STR008,STR008,{|| .T.}})
aadd(aButtons,{STR009,{|| MarcaTds()},STR010,STR010,{|| .T.}})

nSelec := 6

nLin1:=010
DEFINE MSDIALOG OdlgPrin TITLE 'Integração de Pedidos ( AOL )' From 1,7 To 14,70 OF oMain

	nLin2:=133

	nCol1:=040
	nCol2:=220

	nLin:=020
	nCol:=045
	nLin2 := nLin1+31

	nLin1 := 15
	@ nLin1,040 TO nLin2,220  LABEL STR013 OF OdlgPrin PIXEL  // Caixa do meio
	nLin1 += 11
	@ nLin1,045 Get cArquivo Size 145,10 OF OdlgPrin PIXEL
	nLin1 += 1
	@ nLin1,192 BmpButton Type 14 Action LoadArq()

	nLin1 += 22
	nLin2 := nLin1+24
	@ nLin1,040 TO nLin2,220  LABEL "" OF OdlgPrin PIXEL  // Caixa do botao
	nLin1 += 5

	@ nLin1,066 BUTTON STR014 size 40,15 ACTION Processa({|| OdlgPrin:End()}) of OdlgPrin Pixel
	@ nLin1,110 BUTTON STR015 size 40,15 ACTION Processa({|| lRet:=ExistArq(),;
															If(lRet,lRet:=ProcTxt(),),;
															If(lRet,OdlgPrin:End(),"")}) of OdlgPrin Pixel
															
	@ nLin1,154 BUTTON oBtn PROMPT STR064 size 40,15 ACTION Processa({|| GModelo() }) of OdlgPrin Pixel
   	 															
		
ACTIVATE DIALOG OdlgPrin CENTERED ON INIT(OdlgPrin:Refresh())         


Return .F.

/*
Funcao      : LoadArq
Objetivos   : Carregar o arquivo
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*------------------------------*
Static Function LoadArq()
*-----------------------------*
Local nPos


If nSelec == 8 .or.  nSelec == 11 //Arquivo XML
	cType    := "Arq.XML  | *.XML" 
	
ElseIf nSelec == 7 .and.; // Contabil Chamado 021438 - TLM 2014/09/24
						(lDiscovery)//Discovery - RRP - 12/12/2014 - Alteração da forma de validação. Chamado 023152. 
	cType    := "Arq.  | *.TXT"

Else 
	cType    := "Arq.  | *.CSV"

EndIf

cArquivo := cGetFile(cType,STR018+Subs(cType,1,6),1,'C:\',.T.,( GETF_LOCALHARD + GETF_LOCALFLOPPY ) ,.T.)
cArquivo := Upper(AllTrim(cArquivo))
                            
nPos:=At("\",Alltrim(cArquivo))   
cArq:=cArquivo   

While 0 < nPos                          
   cArq:=SubStr(cArq,nPos+1,Len(alltrim(cArq)))
   nPos:=At("\",Alltrim(cArq))   
EndDo 

Return           

/*
Funcao      : ExistArq()
Objetivos   : Verificar se o arquivo existe 
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*------------------------------*
Static Function ExistArq()
*-----------------------------*        
If nSelec == 0
	MsgInfo("Nenhuma opção de integração foi selecionada.",STR061)
	Return .F.
EndIf
  
If Len(Alltrim(cArquivo)) <= 3 
   MsgAlert(STR016,STR017)
   lRet:=.F.
Else
   lRet:=.T.     
EndIf

Return lRet  

/*
Funcao      : ProcTxt
Objetivos   : Processa o arquivo integrado
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*--------------------------*
Static Function ProcTxt()
*--------------------------*  
Private nItemCont  :=0
                                
Private cMoeda     := ""
Private cComp      := ""
Private cPedido    := ""  
Private cPed 	   := ""
Private cAuto      := ""      
Private cImg1      := "D:\Protheus10\Rdmake\GT\LogoGT.bmp"  

Private oMarkPrd , cAliasSX3
Private Indice1,Indice2,cLog 

Private aCpos      := {}      
Private aStruSC5   := {} 
Private aStruSC6   := {}
Private aStruSF1   := {} 
Private aStruSD1   := {}
Private aStruCT2   := {}   
Private aSa1	   := {}
Private aSa2       := {}

Private aMoeda     := {"","01","04","Ambas"} 

Private lInverte  := .F.
Private lIncDoc   := .F.
Private lInt      := .T.   

   If nSelec==6  // Pedido Faturament/Saida  
   		//ExecSC5(cArquivo)  
        If !GeraArqSC5(cArquivo)
        	Return .F.
        Endif
   EndIf		


Return .T.

/*
Funcao      : GetTitle()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tratamento para Retirada de caracteres invalidos dos titulos.
Autor       : Jean Victor Rocha
Data/Hora   : 17/12/2013
*/
*-------------------------------------*
Static Function GetTitle(cTxt,aDadTemp)
*-------------------------------------*
Local nPos := 0
Local aCar := {".",",","-","/","\",";","?","!","@","#","$","%","&","*","(",")","+","=","|","[","]","{","}","ª","º"," "}

cTxt:=NoAcento(cTxt)

For i:=1 to len(aCar)
	cTxt:=strtran(cTxt,aCar[i])
Next i

If aScan(aDadTemp, { |x| alltrim(x[1]) == cTxt} ) > 0
	cTxt := substr(cTxt,1,9)+"_"
Endif

Return cTxt
          



/*
Funcao      : MarcaTds
Objetivos   : Selecionar todos os itens na tela
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*------------------------*
Static Function MarcaTds()
*------------------------* 
Local lExist:=.F.
   
   If nSelec==5 // Entrada
      DbSelectArea("Int_SF1")   
      Int_SF1->(DbGoTop())  
      While Int_SF1->(!EOF())
         RecLock("Int_SF1",.F.)     
         If Alltrim(Int_SF1->SF1Status) == Alltrim(STR020) //Aceito
            If Int_SF1->cINTEGRA == cMarca    
               Int_SF1->cINTEGRA:=Space(02)   
            Else
               Int_SF1->cINTEGRA:= cMarca
            EndIf 
            lExist:=.T.               
         EndIf
         Int_SF1->(MsUnlock())
         Int_SF1->(DbSkip())
      EndDo      
      Int_SF1->(DbGoTop())      
      If !(lExist) 
         MsgInfo(STR030)  //"Não existe registros aceitos para integrar"	 
      EndIf             
     
   EndIf    
   
   If nSelec==6 // Saida
      DbSelectArea("Int_SC5")   
      Int_SC5->(DbGoTop())   
      While Int_SC5->(!EOF())
         RecLock("Int_SC5",.F.)
         If Alltrim(Int_SC5->SC5Status) == Alltrim(STR020)  //Aceito  
            If Int_SC5->cINTEGRA == cMarca    
               Int_SC5->cINTEGRA:=Space(02)   
            Else
               Int_SC5->cINTEGRA:= cMarca
            EndIf
            lExist:=.T.              
         EndIf
         Int_SC5->(MsUnlock())
         Int_SC5->(DbSkip())
      EndDo     
      Int_SC5->(DbGoTop())           
      If !(lExist)
         MsgInfo(STR030)  //"Não existe registros aceitos para integrar"	 
      EndIf     
  
   EndIf  
   
   If nSelec==7 // Contabilidade
      DbSelectArea("Int_CT2")   
      Int_CT2->(DbGoTop())   
      While Int_CT2->(!EOF())
         RecLock("Int_CT2",.F.)     
         //Todos os registros devem ser integrados, não pode escolher apenas alguns.
         //If Alltrim(Int_CT2->CT2Status) == Alltrim(STR020)  //Aceito   
            If Int_CT2->cINTEGRA == cMarca    
               Int_CT2->cINTEGRA :=Space(02)   
            Else
               Int_CT2->cINTEGRA:= cMarca
            EndIf
            lExist:=.T.              
         //EndIf
         Int_CT2->(MsUnlock())
         Int_CT2->(DbSkip())
      EndDo     
      Int_CT2->(DbGoTop())           
      If !(lExist)
         MsgInfo(STR030)  //"Não existe registros aceitos para integrar"	 
      EndIf     

   EndIf  
    
Return            
      
/*
Funcao      : Orderna
Objetivos   : Alterar a ordem dos dados na tela 
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/
*----------------------*
Static Function Ordena()
*----------------------*  
Local nOrd:=IndexOrd()
   If nSelec==5 // Entrada     
      If nOrd == 1 
         DbSelectArea("Int_SF1")   
         Int_SF1->(DbSetOrder(2))
         Int_SF1->(DbGoTop())           
      Else 
         DbSelectArea("Int_SF1")   
         Int_SF1->(DbSetOrder(1))
         Int_SF1->(DbGoTop())       
      EndIf           
   EndIf    
   
   If nSelec==6 // Saida
      If nOrd == 1   
         DbSelectArea("Int_SC5")   
         Int_SC5->(DbSetOrder(2))
         Int_SC5->(DbGoTop()) 
      Else
         DbSelectArea("Int_SC5")   
         Int_SC5->(DbSetOrder(1))
         Int_SC5->(DbGoTop())       
      EndIf 
   EndIf  
   
   If nSelec==7 // Contabil
      If nOrd == 1   
         DbSelectArea("Int_CT2")   
         Int_CT2->(DbSetOrder(2))
         Int_CT2->(DbGoTop()) 
      Else
         DbSelectArea("Int_CT2")   
         Int_CT2->(DbSetOrder(1))
         Int_CT2->(DbGoTop())       
      EndIf 
   EndIf                           
 
Return            
      
*------------------------*
Static Function Finaliza()
*------------------------*  
Local lRet:=.F.
 
If MSGYESNO(STR059,STR017) //"Deseja sair ?","Atenção"    
   oDlg:End()
EndIf

Return lRet

//Valida Cliente 
*------------------------------------*
Static Function Valida_CLI(cCli,cLoja)
*------------------------------------*

If Select("SQL") > 0
   SQL->(dbCloseArea())
EndIf                         

cQuery := "SELECT A1_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
cQuery += " WHERE A1_COD = '"+Alltrim(cCli)+"'"+Chr(10)      
cQuery += " AND A1_LOJA = '"+Alltrim(cLoja)+"'"+Chr(10)    
cQuery += " AND D_E_L_E_T_ <> '*' and A1_FILIAL='"+xFilial("SA1")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->A1_COD       
                 
//Valida Fornecedor                                                                                                                 
*--------------------------------------*
Static Function Valida_FORN(cForn,cLoja)
*--------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                         

cQuery := "SELECT A2_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SA2")+Chr(10)
cQuery += " WHERE A2_COD = '"+Alltrim(cForn)+"'"+Chr(10)      
cQuery += " AND A2_LOJA = '"+Alltrim(cLoja)+"'"+Chr(10)    
cQuery += " AND D_E_L_E_T_ <> '*' and A2_FILIAL='"+xFilial("SA2")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->A2_COD    
                 
//Valida Produto
*--------------------------------------*
Static Function Valida_Produto(cProduto)    
*--------------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT B1_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SB1")+Chr(10)
cQuery += " WHERE B1_COD = '"+cProduto+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return Alltrim(SQL->B1_COD)  





/*
Funcao      : RetCharInv()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Trata caracteres invalidos na integração.
Autor       : Jean Victor Rocha/Renato Rezende
Data/Hora   : 27/02/2014
*/                                 
*--------------------------------*
Static Function RetCharInv(cTexto)
*--------------------------------*
Local aCar := {"CHR(141)"}

For i:=1 to Len(aCar)
	If AT(IIF(LEFT(aCar[i],3) == "CHR",&(aCar[i]),aCar[i]),cTexto)>0
		If LEFT(aCar[i],3) == "CHR"
			cTexto:= STRTRAN(cTexto,&(aCar[i]),"")
		Else 
			cTexto:= STRTRAN(cTexto,aCar[i],"")
		EndIf
	EndIf
Next i

Return cTexto


/*
Funcao      : GeraArqSC5()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico pedido de venda.
Autor       : Matheus Massaroto
Data/Hora   : 11/07/2012 18:15
*/
*-----------------------------------*
Static Function GeraArqSC5(cArqTxt)   
*-----------------------------------*
ProcRegua(0)

Private cCampo        :=""   
Private cTemDup       :="" 
Private cArqTrab      :=""  
Private cCpoFaltantes :=""
Private lCrt          :=.F.
Private lCpoFal       :=.F.
Private lTemDup       :=.F.   
Private aCampos       :={} 
Private aCabExcel     :={}
Private aDadExcel     :={}
Private aCampos1      :={}
Private aCamposCob      :={}
Private aCpoObrigat   :={"C5_NUM","C5_TIPO","C5_TIPOCLI","C5_CONDPAG","C5_EMISSAO","C5_MENNOTA","C6_ITEM","C6_PRODUTO","C6_DESCRI","C6_QTDVEN","C6_PRCVEN","C6_VALOR","C6_TES","A1_CGC","A1_NOME","A1_PESSOA","A1_NREDUZ","A1_END","A1_EST","A1_COD_MUN","A1_MUN","A1_BAIRRO","A1_CEP"} //Campos obrigatórios que devem estar no arquivo
Private nPos          :=0
Private nCnt          :=0
Private c_M_Chave	:=""
Private lMsgC		:=.F.
Private cMsgCampo	:=""
Private lCmpNExt	:=.F.
Private cCmpNExt	:=""

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()        // Le a linha
	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	If "C5_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		for cont:=1 to len(aCpoObrigat)
			if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			endif
		next
	
		if !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		endif
		//Fim da verificação dos campos obrigatórios
		
		If "C5_" $ aLinha[1] 
		    For i:=1 to len(aLinha)
				If "C5_" $ aLinha[i] .OR. "C6_" $ aLinha[i]  .OR. "A1_" $ aLinha[i]
			 		cCampo:=Alltrim(aLinha[i])

			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					
					lFieldCob := .F. 
					If "A1_" $ aLinha[i] .And.  "(COB)" $ aLinha[i]
						cCampo := Left( aLinha[i] , At( "(" , aLinha[i] ) - 1 )
						lFieldCob := .T.  
					EndIf   
					
					If "A1_" $ aLinha[i] .And.  "(VEN)" $ aLinha[i]
						cCampo := Left( aLinha[i] , At( "(" , aLinha[i] ) - 1 )
					EndIf					
					
					If Dbseek(cCampo)
						
						If lFieldCob
							cCampo := StrTran( cCampo , "A1_" , "CB_" )
						EndIf
						
						if aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup:=.T.
							cTemDup+=cCampo+","
						endif
						
						AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    else
				    	lCmpNExt:=.T.
				    	cCmpNExt+=cCampo+","
				    EndIf 

				    //SX3->(DbCloseArea())
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
				
			Next
		Else
			FT_FSkip() // Proxima linha
		EndIf	
	 
		If lCrt
		   	FT_FSkip() // Proxima linha
			nPos:=FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() // Proxima linha
    Endif
Enddo

If empty(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de pedido de venda!")
	FT_FUse()
	Return	
Endif

If lTemDup
	alert("Exitem campos iguais no arquivo: "+cTemDup)
	FT_FUse()
	Return
Endif

If lCpoFal
	FT_FUse()
	Return
EndIf

//Retirando o ultimo caracter pois é uma virgula.
cCmpNExt	:=SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+"Por favor abra um chamado para a equipe de sistemas ou retire o campo da sua planilha!")
	FT_FUse()
	Return
endif

//-------Posição dos campos-------//
Private nPosC5_1_CHA:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_NUM"} )
Private nPosC5_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TIPOCLI"} )
Private nPosC5_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_CONDPAG"} )
Private nPosC5_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_EMISSAO"} )
Private nPosC5_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_MENNOTA"} )
Private nPosC5_6_CHA:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_P_REF"} )
Private nPosC5_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TIPO"} )

Private nPosC6_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_ITEM"} )
Private nPosC6_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_PRODUTO"} )
Private nPosC6_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_DESCRI"} )
Private nPosC6_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_QTDVEN"} )
Private nPosC6_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_PRCVEN"} )
Private nPosC6_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_VALOR"} )
Private nPosC6_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_TES"} )

Private nPosA1_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_CGC"} )
Private nPosA1_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_NOME"} )
Private nPosA1_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_PESSOA"} )
Private nPosA1_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_NREDUZ"} )
Private nPosA1_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_END"} )
Private nPosA1_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_EST"} )
Private nPosA1_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_COD_MUN"} )
Private nPosA1_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_MUN"} )
Private nPosA1_9	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_BAIRRO"} )
Private nPosA1_A	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_CEP"} ) 


Private nPosCob_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_CGC"} )
Private nPosCob_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_NOME"} )
Private nPosCob_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_PESSOA"} )
Private nPosCob_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_NREDUZ"} )
Private nPosCob_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_END"} )
Private nPosCob_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_EST"} )
Private nPosCob_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_COD_MUN"} )
Private nPosCob_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_MUN"} )
Private nPosCob_9	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_BAIRRO"} )
Private nPosCob_A	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_CEP"} )


//-------FIM Posição dos campos-------//

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
If nPosC5_1_CHA==0
	cMsgCampo+="C5_NUM"+CRLF
	lMsgC:=.T.
EndIf
If nPosC5_2==0
	cMsgCampo+="C5_TIPOCLI"+CRLF
	lMsgC:=.T.
EndIf
If nPosC5_3==0
	cMsgCampo+="C5_CONDPAG"+CRLF
	lMsgC:=.T.	
EndIf
If nPosC5_4==0
	cMsgCampo+="C5_EMISSAO"+CRLF
	lMsgC:=.T.	
EndIf
If nPosC5_5==0
	cMsgCampo+="C5_MENNOTA"+CRLF
	lMsgC:=.T.
EndIf
If nPosC5_7==0
	cMsgCampo+="C5_TIPO"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_1==0
	cMsgCampo+="C6_ITEM"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_2==0
	cMsgCampo+="C6_PRODUTO"+CRLF 
	lMsgC:=.T.
EndIf
If nPosC6_3==0
	cMsgCampo+="C6_DESCRI"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_4==0
	cMsgCampo+="C6_QTDVEN"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_5==0
	cMsgCampo+="C6_PRCVEN"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_6==0
	cMsgCampo+="C6_VALOR"+CRLF
	lMsgC:=.T.
EndIf
If nPosC6_7==0
	cMsgCampo+="C6_TES"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_1==0
	cMsgCampo+="A1_CGC"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_2==0
	cMsgCampo+="A1_NOME"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_3==0
	cMsgCampo+="A1_PESSOA"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_4==0
	cMsgCampo+="A1_NREDUZ"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_5==0
	cMsgCampo+="A1_END"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_6==0
	cMsgCampo+="A1_EST"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_7==0
	cMsgCampo+="A1_COD_MUN"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_8==0
	cMsgCampo+="A1_MUN"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_9==0
	cMsgCampo+="A1_BAIRRO"+CRLF
	lMsgC:=.T.
EndIf
If nPosA1_A==0
	cMsgCampo+="A1_CEP"+CRLF
	lMsgC:=.T.
EndIf
//-----FIM Verifica se os campos existem, para exibir a mensagem no arquivo-----//

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "+CRLF+cMsgCampo)
	FT_FUse()
	Return
EndIf	

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)

if nPosC5_6_CHA<>0
	c_M_Chave:=aCampos1[nPosC5_6_CHA][1]+"+"+aCampos1[nPosC5_1_CHA][1]
else
	c_M_Chave:=aCampos1[nPosC5_1_CHA][1]
endif                                   

IndRegua("XXX", cArqTemp, (c_M_Chave),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    
	if empty(aLinha[nPosC5_1_CHA]) .AND. empty(aLinha[nPosC5_2]) .AND. empty(aLinha[nPosC5_3]) .AND. empty(aLinha[nPosC5_4]) .AND. empty(aLinha[nPosC5_5]) .AND. empty(aLinha[nPosC5_7])
		FT_FSkip() // Proxima linha
		loop
	endif    
	
	Begin Transaction	
		Reclock("XXX",.T.) 
	    	for nK:=1 to len(aCampos1)
	    		if !empty(aCampos1[nK][1])
	    			
	    			if aCampos1[nK][2]=="N"   
	    				XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val( STRTRAN(STRTRAN(aLinha[nK],"."), "," , ".") ))
	    		    elseif aCampos1[nK][2]=="D"
	    		    
	    			//<--RRP-28/08/2012-Tratamento para o campo C5_EMISSAO-->//
						dEmissaoSC5 := CTOD("")               
                    	If empty(aLinha[nK])
	               			dEmissaoSC5 :=dDataBase
                   		ElseIf AT("/",aLinha[nK]) > 0                           
                   	 		dEmissaoSC5 := CTOD(aLinha[nK])
                   		Else
                   			dEmissaoSC5 := STOD(aLinha[nK]) 
                   		EndIf
                   		XXX->&(aCampos1[nK][1]):= dEmissaoSC5 
                    //<--FIM do tratamento para o campo C5_EMISSAO-->//	    		    
	    		    
	    		    //XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
	    		    else
	    		    	//RSB - 27/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.
	    		    	If "EMAIL" $ aCampos1[nK][1] 
	    		       		XXX->&(aCampos1[nK][1]):= STRTRAN(aLinha[nK],",",";")
	    		       	Else	  
	    		       		XXX->&(aCampos1[nK][1]):= aLinha[nK]
	    		       	Endif	
	    		    endif
	     		endif	
	        next
	        
	    XXX->(MsUnlock())	      
	        
	    Confirmsx8()    
	End Transaction
	
	if nPosC5_6_CHA<>0
		IncProc("Lendo registro: "+alltrim(XXX->C5_P_REF+XXX->C5_NUM))
	else 
		IncProc("Lendo registro: "+alltrim(XXX->C5_NUM))
	endif
	   
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutSC5()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutSC5()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico produto.
Autor       : Matheus Massaroto
Data/Hora   : 11/07/12 18:15
*/                          
*-------------------------*
 Static Function ExecAutSC5  
*-------------------------*

Local aDados 		:= {}
Local aItem	   		:= {}
Local aItens   		:= {}
Local aErros		:= {}
Local aGravado		:= {}
Local aCpos	   		:= {}
Local aCabecSA1		:= {}
Local cTipoSA1		:= {}
Local cNatureza		:= {}
Local cConta		:= {}
Local cPaisSA1		:= {}


Local lErro	   		:= .F.
Local lOk	   		:= .F.

Local c_M_Cliente	:= ""
Local c_M_LojaCLi	:= ""

// Incio Tabela temporária para armaznar os erros

AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

if select("WWW")>0
	WWW->(DbCloseArea())
endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)
 
// Fim tabela temporária para armaznar os erros


DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 

	if nPosC5_6_CHA<>0
		IncProc("Processando registro: "+alltrim(XXX->C5_P_REF+XXX->C5_NUM))
	else 
		IncProc("Processando registro: "+alltrim(XXX->C5_NUM))
	endif

	lUsouGetC5:=.F.
	if empty(XXX->C5_NUM) .AND. nPosC5_6_CHA==0
	    

	    lErro:=.T.
		Reclock("WWW",.T.)
	    WWW->SITUACAO:="Erro"
	    WWW->CODIGO:=""
	    WWW->CODREF:=""
	    WWW->CGC:=alltrim(XXX->A1_CGC)
	    WWW->DESCRICAO:="Quando o campo C5_NUM estiver em branco, o campo C5_P_REF deve ser informado!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop 
	EndIf			
	
	if nPosC5_6_CHA>0
		if empty(XXX->C5_P_REF)
		    lErro:=.T.
			Reclock("WWW",.T.)
		    WWW->SITUACAO:="Erro"
		    WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
		    WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    WWW->CGC:=alltrim(XXX->A1_CGC)
		    WWW->DESCRICAO:="O campo C5_P_REF deve ser preenchido!"
		    WWW->(MsUnlock())
			XXX->(DbSkip())
			Loop				
        /*
		Else
			c_M_Qry:=" SELECT C5_NUM FROM "+RETSQLNAME("SC5")+CRLF
			c_M_Qry+=" WHERE D_E_L_E_T_='' AND C5_P_REF='"+XXX->C5_P_REF+"'"
			
			if select("M_TRB")>0
				M_TRB->(DbCloseArea())
			endif
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,c_M_Qry),"M_TRB",.T.,.T.)
	
			COUNT TO nRecCount
			
			if nRecCount>0
			    M_TRB->(DbCloseArea())
			    lErro:=.T.
				Reclock("WWW",.T.)
		    	WWW->SITUACAO:="Erro"
		    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
		    	WWW->CODREF:=alltrim(XXX->C5_P_REF)
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:="Já existe registro para a referencia C5_P_REF!"
			    WWW->(MsUnlock())
				XXX->(DbSkip())
				Loop				
			endif
			M_TRB->(DbCloseArea())
		*/
		EndIf	
	endif	

	aDados	:={}
	aItens	:={}
	aItem	:={}
	
	
	c_M_Cliente	:=""
	c_M_LojaCLi	:=""
	lDeuErroSA1	:=.F.
	c_M_CGC		:=STRTRAN(STRTRAN(STRTRAN(XXX->&(aCampos1[nPosA1_1][1]),"."),"-"),"/")

    //verifica se o CNPJ está em branco
	if empty(c_M_CGC) .And. ( Empty( XXX->A1_COD ) .Or. Empty( XXX->A1_LOJA )  )
	    lErro:=.T.	

		Reclock("WWW",.T.)
    	WWW->SITUACAO:="Erro"
    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
    	WWW->CGC:=alltrim(XXX->A1_CGC)
    	WWW->DESCRICAO:="CNPJ ou Codigo\Loja do cliente em branco!"	    
	    WWW->(MsUnlock())
        
		XXX->(DbSkip())
		Loop
	endif
	

	DbSelectArea("SA1")	
	If !Empty( XXX->A1_COD ) .And. !Empty( XXX->A1_LOJA )  
		DbSetOrder( 1 )
		lIncSA1 := !DbSeek(xFilial("SA1")+XXX->A1_COD + XXX->A1_LOJA)			
		If lIncSA1
			Reclock("WWW",.T.)
	    	WWW->SITUACAO:="Erro"
	    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
	    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
	    	WWW->CGC:=alltrim(XXX->A1_CGC)
	    	WWW->DESCRICAO:="Codigo e Loja do cliente nao cadastrados para cliente 'EX'!"	    
	    	WWW->(MsUnlock())
			XXX->(DbSkip())
			Loop	    
		EndIf	    
	Else

		DbSetOrder(3) //A1_FILIAL+A1_CGC
		lIncSA1 := !DbSeek(xFilial("SA1")+XXX->A1_CGC)
	EndIf          
	
	
	/*
		 ** Se o cliente existir e os campos abaixo estiver vazio na planilha, nao efetua a alteração do cliente, mantem os dados da base
	*/
	
	lExecAutoSA1 := .T.
	If !lIncSA1
		For nK := 1 To Len( aCampos1 )
			If ( "A1_" $ aCampos1[ nK ][ 1 ] ) .And.  !AllTrim( aCampos1[ nK ][ 1 ] ) $ "A1_CGC" .And. Empty( XXX->&( aCampos1[ nK ][ 1 ] ) )
				lExecAutoSA1 := .F.		
		    	Exit
			EndIf	
		Next
	EndIf
	
	If !lIncSA1
		c_M_Cliente := SA1->A1_COD
		c_M_LojaCLi := SA1->A1_LOJA
		//RSB - 27/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.		
		SA1->(Reclock("SA1",.F.))
	    SA1->A1_EMAIL := XXX->A1_EMAIL
    	SA1->(MsUnlock())
	EndIf
	
	aCabecSA1	:={}		
	If lExecAutoSA1
		If lIncSA1
			//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
			cTipoSA1	:= IF(EMPTY(XXX->C5_TIPOCLI),"F",XXX->C5_TIPOCLI)
			cNatureza	:= XXX->A1_NATUREZ //"1004"
			//cConta	:= "112110001"  chamado 012684
			cConta		:= XXX->A1_CONTA //"11211001"
			cPaisSA1	:= XXX->A1_CODPAIS//"01058"
			
			//RRP - 29/08/2012 - Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência
			ChkIn("A1_COD")
			
			c_M_Cliente	:=GETSXENUM("SA1","A1_COD")
			c_M_LojaCLi	:="01"
			
			AADD(aCabecSA1,{"A1_COD"	,c_M_Cliente	,	nil})
			AADD(aCabecSA1,{"A1_LOJA"	,c_M_LojaCLi	,	nil})
			AADD(aCabecSA1,{"A1_TIPO"	,cTipoSA1,	nil})
			
			//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
			AADD(aCabecSA1,{"A1_NATUREZ",cNatureza,	nil})
			AADD(aCabecSA1,{"A1_CONTA"	,cConta,	nil})
			AADD(aCabecSA1,{"A1_CODPAIS",cPaisSA1,	nil})
			
			
		Else
			c_M_Cliente := SA1->A1_COD
			c_M_LojaCLi := SA1->A1_LOJA
			AADD(aCabecSA1,{"A1_COD"	,c_M_Cliente	,	nil})
			AADD(aCabecSA1,{"A1_LOJA"	,c_M_LojaCLi	,	nil})
			
		EndIf
		
		
		
		for nK:=1 to len(aCampos1)
			if !empty(aCampos1[nK][1])
				if alltrim(aCampos1[nK][1]) $ "A1_TIPO,A1_COD_,A1_LOJA,A1_CODPAIS"
					//não faz nada
				elseif "A1_" $ aCampos1[nK][1] .And. !Empty( XXX->&(aCampos1[nK][1]) )
					AADD(aCabecSA1,{aCampos1[nK][1],	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
				endif
			endif
		next
		
		//--Execução do MSExecAuto do SA1--//
		Private lMsErroAuto:= .F.
		Private lMSHelpAuto := .F.
		Private lAutoErrNoFile := .T.
		
		BEGIN Transaction
		
		lMsErroAuto := .F.
		MsExecAuto({|x,y| MATA030(x,y)}, aCabecSA1, If(lIncsA1 , 3 , 4 ))
		
		If lMsErroAuto
			lDeuErroSA1:=.T.
			cErroCon:=""
			aAutoErro := GETAUTOGRLOG()
			cErroCon:=XLOG(aAutoErro)
			//msginfo(cErroCon)
			if !("A1_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
				cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )
				nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
				if nPoTit<>0
					cErroCon+=" "+ aCampos[nPoTit][1]
				endif
			endif
			
			//	AADD(aErros,{alltrim(XXX->A1_CGC),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
			lErro:=.T.
			DisarmTransaction()
			
			Reclock("WWW",.T.)
			WWW->SITUACAO:="Erro"
			WWW->CODIGO:=alltrim(XXX->C5_NUM)
			WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
			WWW->CGC:=alltrim(XXX->A1_CGC)
			WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))
			WWW->MEMO:=XLOGMEMO(aAutoErro)
			WWW->(MsUnlock())
			
			If lIncSA1
				ROLLBACKSXE()
			EndIf
		Else
			If lIncSA1
				Confirmsx8()
			EndIf
			lOk:=.T.
			//	AADD(aGravado,{alltrim(XXX->A1_CGC),"OK","Cliente Inserido"})
			
			Reclock("WWW",.T.)
			WWW->SITUACAO:="OK"
			WWW->CODIGO:=alltrim(XXX->C5_NUM)
			WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
			WWW->CGC:=alltrim(XXX->A1_CGC)
			WWW->DESCRICAO:=If( lIncSA1 , "Inserido" , "Alterado" )
			WWW->(MsUnlock())
		EndIf
		
		
		END Transaction
		
		//--FIM Execução do MSExecAuto do SA1--//
		if lDeuErroSA1
			XXX->(DbSkip())
			Loop
		endif

    EndIf
	
	/*
		** Tratamento cliente de cobrança
	*/                                   
		
	If ( !Empty( XXX->CB_CGC ) .And. AllTrim( XXX->CB_CGC ) <> AllTrim( XXX->A1_CGC )  ) .Or. ;
		( !Empty( XXX->CB_COD ) .And. !Empty(  XXX->CB_LOJA ) .And. ;
		   ( XXX->CB_COD + XXX->CB_LOJA ) <> ( XXX->A1_COD + XXX->A1_LOJA ) )
		
		aCabecSA1	:={}
		DbSelectArea("SA1")	
		If !Empty( XXX->CB_COD ) .And. !Empty( XXX->CB_LOJA )
			DbSetOrder( 1 )
			lIncSA1 := !DbSeek(xFilial("SA1")+XXX->CB_COD + XXX->CB_LOJA)			
			If lIncSA1
				Reclock("WWW",.T.)
		    	WWW->SITUACAO:="Erro"
		    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
		    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:="Codigo e Loja do cliente nao cadastrados ."	    
		    	WWW->(MsUnlock())
				XXX->(DbSkip())
				Loop	    
			EndIf	    
		Else
	
			DbSetOrder(3) //A1_FILIAL+A1_CGC
			lIncSA1 := !DbSeek(xFilial("SA1")+XXX->CB_CGC)
		EndIf          
		
		
		/*
			 ** Se o cliente existir e os campos abaixo estiver vazio na planilha, nao efetua a alteração do cliente, mantem os dados da base
		*/
		
		lExecAutoSA1 := .T.
		If !lIncSA1
			For nK := 1 To Len( aCampos1 )
				If ( "CB_" $ aCampos1[ nK ][ 1 ] ) .And.  !AllTrim( aCampos1[ nK ][ 1 ] ) $ "CB_CGC" .And. Empty( XXX->&( aCampos1[ nK ][ 1 ] ) ) 
					lExecAutoSA1 := .F.		
			    	Exit
				EndIf	
			Next
		EndIf
		
		/*
			 ** Se o cliente existir e os campos abaixo estiver vazio na planilha, nao efetua a alteração do cliente, mantem os dados da base
		*/
		If !lIncSA1
			c_M_Cli_Cob	:=SA1->A1_COD
			c_M_Loja_Cob	:= SA1->A1_LOJA	
			//RSB - 27/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.
			SA1->(Reclock("SA1",.F.))
		    SA1->A1_EMAIL := XXX->A1_EMAIL
	    	SA1->(MsUnlock())			
		EndIf  
				
		If lExecAutoSA1
			If lIncSA1
				//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
				cTipoSA1	:= IF(EMPTY(XXX->C5_TIPOCLI),"F",XXX->C5_TIPOCLI)
				cNatureza	:= XXX->CB_NATUREZ //"1004"
				cConta		:= XXX->CB_CONTA //"11211001"
				cPaisSA1	:= XXX->CB_CODPAIS//"01058"				
			
				//RRP - 29/08/2012 - Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência
				ChkIn("A1_COD")
			
				c_M_Cli_Cob	:=GETSXENUM("SA1","A1_COD")
				c_M_Loja_Cob	:="01"
			    
				AADD(aCabecSA1,{"A1_COD"	,c_M_Cli_Cob	,	nil})
				AADD(aCabecSA1,{"A1_LOJA"	,c_M_Loja_Cob	,	nil})
				AADD(aCabecSA1,{"A1_TIPO"	,cTipoSA1,	nil})
			
				//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
				AADD(aCabecSA1,{"A1_NATUREZ",cNatureza,	nil})
				AADD(aCabecSA1,{"A1_CONTA"	,cConta,	nil})
				AADD(aCabecSA1,{"A1_CODPAIS",cPaisSA1,	nil})
			
			
			Else
				c_M_Cli_Cob	:=SA1->A1_COD
				c_M_Loja_Cob	:= SA1->A1_LOJA
				AADD(aCabecSA1,{"A1_COD"	,c_M_Cli_Cob	,	nil})
				AADD(aCabecSA1,{"A1_LOJA"	,c_M_Loja_Cob	,	nil})		
	
			EndIf
			
			
			for nK:=1 to len(aCampos1)
				if !empty(aCampos1[nK][1])
					if alltrim(aCampos1[nK][1]) $ "CB_TIPO,CB_COD_,CB_LOJA,CB_CODPAIS" 
						//não faz nada
					elseif "CB_" $ aCampos1[nK][1] .And. !Empty( XXX->&(aCampos1[nK][1]) ) 
						AADD(aCabecSA1,{StrTran( aCampos1[nK][1] , "CB_" , "A1_" ) ,	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
					endif
				endif
			next
			
			//--Execução do MSExecAuto do SA1--//
			Private lMsErroAuto:= .F.
			Private lMSHelpAuto := .F.
			Private lAutoErrNoFile := .T.
			
			BEGIN Transaction
			
			lMsErroAuto := .F.
			MsExecAuto({|x,y| MATA030(x,y)}, aCabecSA1, If(lIncsA1 , 3 , 4 ))
			
			If lMsErroAuto
				lDeuErroSA1:=.T.
				cErroCon:=""
				aAutoErro := GETAUTOGRLOG()
				cErroCon:=XLOG(aAutoErro)
				//msginfo(cErroCon)
				if !("A1_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
					cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )
					nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
					if nPoTit<>0
						cErroCon+=" "+ aCampos[nPoTit][1]
					endif
				endif
				
				//		    	AADD(aErros,{alltrim(XXX->A1_CGC),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
				lErro:=.T.
				DisarmTransaction()
				
				Reclock("WWW",.T.)
				WWW->SITUACAO:="Erro"
				WWW->CODIGO:=alltrim(XXX->C5_NUM)
				WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
				WWW->CGC:=alltrim(XXX->CB_CGC)
				WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))
				WWW->MEMO:=XLOGMEMO(aAutoErro)
				WWW->(MsUnlock())
					
				If lIncSA1
					ROLLBACKSXE()
				EndIf
			Else
				If lIncSA1
					Confirmsx8()
				EndIf
				lOk:=.T.
				//				AADD(aGravado,{alltrim(XXX->A1_CGC),"OK","Cliente Inserido"})
			
				Reclock("WWW",.T.)
				WWW->SITUACAO:="OK"
				WWW->CODIGO:=alltrim(XXX->C5_NUM)
				WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
				WWW->CGC:=alltrim(XXX->CB_CGC)
				WWW->DESCRICAO:=If( lIncSA1 , "Inserido" , "Alterado" )
				WWW->(MsUnlock())
			EndIf
			
			
			END Transaction
			
				//--FIM Execução do MSExecAuto do SA1--//
			if lDeuErroSA1
				XXX->(DbSkip())
				Loop
			endif		
        EndIf
        
	Else
		c_M_Cli_Cob 	:=c_M_Cliente
		c_M_Loja_Cob 	:=c_M_LojaCLi

	EndIf					
	

//<FIM Tratamento para cliente - SA1>//
	
    //--Tratamento para o número sequencial do pedido de venda--//

	if nPosC5_6_CHA<>0
		if !empty(XXX->&(aCampos1[nPosC5_6_CHA][1])) .AND. empty(XXX->&(aCampos1[nPosC5_1_CHA][1]))
		
			//RRP - 29/08/2012 - Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência 
			ChkIn("C5_NUM")
			
			cSeqNumC5:=GETSXENUM("SC5","C5_NUM")
			lUsouGetC5:=.T.
		else
			cSeqNumC5:=XXX->&(aCampos1[nPosC5_1_CHA][1])
		endif
	else
		cSeqNumC5:=XXX->&(aCampos1[nPosC5_1_CHA][1])
	endif

    //--FIM Tratamento para o número sequencial do pedido de venda--//
    
//<Tratamento para capa do pedido - SC5>//
	aDados := {}
	for nK:=1 to len(aCampos1)
		if !empty(aCampos1[nK][1])
	        
			if aCampos1[nPosC5_2][1]==aCampos1[nK][1] //C5_TIPOCLI
				AADD(aDados,{"C5_CLIENT",c_M_Cli_Cob	,	nil})
				AADD(aDados,{"C5_LOJAENT",c_M_Loja_Cob	,	nil}) 
				AADD(aDados,{"C5_CLIENTE",c_M_Cliente	,	nil})
				AADD(aDados,{"C5_LOJACLI",c_M_LojaCLi	,	nil})
								
			elseif "C5_NUM"	== ALLTRIM(aCampos1[nK][1])
				AADD(aDados,{"C5_NUM",cSeqNumC5,	nil})
			elseif "C5_" $ aCampos1[nK][1]
				AADD(aDados,{aCampos1[nK][1],	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
			endif
	
		endif
	next


//<FIM Tratamento para capa do pedido - SC5>//

//<Tratamento para itens do pedido - SC6>//
	Private cRenXXX		:= XXX->(Recno())
	Private cNumPedAnt	:= iif(nPosC5_6_CHA<>0 .AND. empty(alltrim(XXX->C5_NUM)),alltrim(XXX->C5_P_REF),alltrim(XXX->C5_NUM))
	Private c_M_Key		:= iif(nPosC5_6_CHA<>0 .AND. empty(alltrim(XXX->C5_NUM)),"alltrim(XXX->C5_P_REF)","alltrim(XXX->C5_NUM)")
	Private cNumCGC		:= XXX->A1_CGC
	Private cAntItem	:= XXX->C6_ITEM
		
	Private cItem
	Private cRecUlt		:=""
	Private lErroInter	:=.F.
	
	cItem		:="00"
	
	 If nPosC5_6_CHA == 0 .OR. !EMPTY(XXX->C5_NUM)
		 cPedido := XXX->C5_NUM
		 bWhile := { || C5_NUM == cPedido }   		
	 Else
		 cPedido := XXX->C5_P_REF  
		 bWhile := { || C5_P_REF  == cPedido }   				 
	 EndIf

	 
	 aItens := {}
	 While XXX->( !Eof() .And. Eval( bWhile ) ) 
	 	aItem := {}	//XXX->(DbSkip())
	
		//cItem:=XXX->C6_ITEM
		//If Empty( cItem )
		cItem:=(SOMA1(cItem))
		//EndIf		
	    for nK:=1 to len(aCampos1) 
	    
	    	If "C6_VALOR" $ aCampos1[nK][1]
	    		Loop
	    	EndIf	
			if !empty(aCampos1[nK][1])
				if "C6_ITEM" $ aCampos1[nK][1]
					AADD(aItem,{"C6_ITEM",cItem,	nil})
				elseif "C6_" $ aCampos1[nK][1]
					AADD(aItem,{aCampos1[nK][1],	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
				endif
			endif
		next
		AADD(aItem,{"C6_NUM",alltrim(cSeqNumC5),	nil})
		AADD(aItens,aItem)
		XXX->( DbSkip() )
	EndDo


//--Execução do MSExecAuto do SC5/SC6--//
	Private lMsErroAuto:= .F.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	
	BEGIN Transaction
		MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aDados, aItens, 3)
	   
		If lMsErroAuto
		  	if lUsouGetC5
				ROLLBACKSXE()		  		
		  	endif
		  	cErroCon	:=""
			aAutoErro 	:=GETAUTOGRLOG()
		    cErroCon	:=XLOG(aAutoErro) 
	
		   	if !("C5_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) ) .OR. !("C6_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
		   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
	       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
	       		if nPoTit<>0
	       			cErroCon+=" "+ aCampos[nPoTit][1]
	       		endif
	    	endif    
	    	
		    lErro:=.T.
		    DisarmTransaction()
		    

    		Reclock("WWW",.T.)
		    	WWW->SITUACAO:="Erro"
		    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
		    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))
		    	WWW->MEMO:=XLOGMEMO(aAutoErro) 
		    WWW->(MsUnlock())
		  
		Else
		  	if lUsouGetC5
			    Confirmsx8()    
		  	endif
	
			lOk:=.T.
	    		Reclock("WWW",.T.)
			    	WWW->SITUACAO:="Ok"
			    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
			    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
			    	WWW->CGC:=alltrim(XXX->A1_CGC)
			    	WWW->DESCRICAO:="Inserido"
			    WWW->(MsUnlock())
		EndIF
	      
	END Transaction
	
	If !lMsErroAuto
//		SC5->( DbSetOrder( 1 ) )
//		If SC5->( DbSeek( xFilial() + SC5->C5_NUM ) )
			SC5->( RecLock( 'SC5' , .F. ) )
			SC5->C5_CLIENT := c_M_Cli_Cob
			SC5->C5_LOJAENT := c_M_Loja_Cob
			SC5->( MSUnlock() )       
//		EndIf
	EndIf
	//XXX->(DbSkip())
enddo

If lErro
	
	Situacao2()	

Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf


fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())


Return( iif(lErro,.F.,.T.) )  

      
/*
Funcao      : Situacao()
Parametros  : aErros,aGravado
Retorno     : Nenhum
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK. Para todos .
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*---------------------------------------*
Static Function Situacao(aErros,aGravado)
*---------------------------------------*
Private _oDlg,oListBox
Private aListBox:={}
Private cNick    
/*    1 - Produto
	  2 - Cliente
	  3 - Fornecedor
	  4 - Pedido de Compra
	  5 - Pre/Nota (NFE)
	  6 - Pedido (NFS)
 	  7 - Contabil
      8 - XML de Pre NF de entrada
      9 - Funcionario 
     10 - Solicitação de importação
     12 - Estrutura de produto
     15 - Produto X Fornecedor*/

If nSelec==1
	cNick:="PRODUTOS"
ElseIf nSelec==2
	cNick:="CLIENTES"
ElseIf nSelec==3
	cNick:="FORNECEDOR"
ElseIf nSelec==6
	cNick:="PEDIDO_VENDA"	
ElseIf nSelec==7
	cNick:="CONTABIL"	
ElseIf nSelec==9
	cNick:="FUNCIONARIO"
ElseIf nSelec==10
	cNick:="SW1"
ElseIf nSelec==12
	cNick:="ESTRUTURA_PRODUTO"
Else
	cNick:=""
	alert("1 - Não implementado para a modalidade selecionada!")
	Return
EndIf

DEFINE MSDIALOG _oDlg TITLE cNick FROM C(178),C(180) TO C(565),C(966) PIXEL
	@ C(009),C(009) ListBox oListBox Fields HEADER "CODIGO", "SITUAÇÃO","DESCRIÇÃO" Size C(378),C(156) Of _oDlg Pixel
	@ C(180),C(300) Button "&Imprimir" Size C(037),C(012) PIXEL OF _oDlg action(Imprime(cNick,"1"))
	@ C(180),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())
	For i:=1 to len(aErros)
		Aadd(aListBox,{aErros[i][1],aErros[i][2],aErros[i][3]})
	Next
	For i:=1 to len(aGravado)
		Aadd(aListBox,{aGravado[i][1],aGravado[i][2],aGravado[i][3]})
	Next
    oListBox:SetArray(aListBox)
	oListBox:bLine := {|| {aListBox[oListBox:nAt,1],aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3]}}

ACTIVATE MSDIALOG _oDlg CENTERED 

Return  

/*
Funcao      : SituaProd()
Parametros  : aErros,aGravado
Retorno     : Nenhum
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK. Para todos .
Autor       : Matheus Massaroto
Data/Hora   : 07/08/12 14:39*/
*------------------------------------------------*
Static Function SituaProd(aErros,aGravado,aAltNcm)
*------------------------------------------------*
Private _oDlg,oListBox
Private aListBox:={}
Private cNick    

Default aAltNcm:={}

If nSelec==1
	cNick:="PRODUTOS"
Else
	cNick:=""
	alert("2 - Não implementado para a modalidade selecionada!")
	Return
EndIf

DEFINE MSDIALOG _oDlg TITLE cNick FROM C(178),C(180) TO C(665),C(966) PIXEL
	@ C(019),C(009) ListBox oListBox Fields HEADER "CODIGO", "SITUAÇÃO","DESCRIÇÃO" Size C(378),C(206) Of _oDlg Pixel
	@ C(230),C(300) Button "&Imprimir" Size C(037),C(012) PIXEL OF _oDlg action(Imprime(cNick,"1"))
	@ C(230),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())
	For i:=1 to len(aErros)
		Aadd(aListBox,{aErros[i][1],aErros[i][2],aErros[i][3]})
	Next
	For i:=1 to len(aGravado)
		Aadd(aListBox,{aGravado[i][1],aGravado[i][2],aGravado[i][3]})
	Next
    oListBox:SetArray(aListBox)
	oListBox:bLine := {|| {aListBox[oListBox:nAt,1],aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3]}}
   
ACTIVATE MSDIALOG _oDlg CENTERED ON INIT(VerNCMSB1(aAltNcm))

Return

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Matheus Massarotto
Data/Hora   : 07/08/2012
*/
*-----------------------------*
Static Function MudaStatus()
*-----------------------------*
Local cArqConte:=aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]

if oOk==cArqConte
	cArqConte:=oNo
else 
	cArqConte:=oOk
endif

Return(cArqConte)

/*
Funcao      : marcatudo
Parametros  : 
Retorno     : 
Objetivos   : Função para mudar a imagem do primeiro campo, para tudo marcado ou tudo desmarcado
Autor       : Matheus Massarotto
Data/Hora   : 07/08/2012
*/
*-----------------------------*
Static Function marcatudo
*-----------------------------*
for nSeq:=1 to len(aCols)
	aCols[nSeq][1]:=iif(lCheckBox1,oOk,oNo)
next
	
Return



/*
Funcao      : CriaLog
Parametros  : cMsgLog
Retorno     : 
Objetivos   : Função criar o arquivo log no servidor
Autor       : Matheus Massarotto
Data/Hora   : 08/08/2012
*/
*-------------------------------*
Static Function CriaLog(cMsgLog)
*-------------------------------*
Local cArqLog:="intpryor.log"
Local nHandle:=0

//verifica a existencia do arquivo
if !FILE("\"+curdir()+cArqLog)
	//cria o arquivo
	nHandle:=FCREATE("\"+curdir()+cArqLog)
	if nHandle==-1
		Conout(FERROR())
		Return
	endif
else
	nHandle:=FOPEN("\"+curdir()+cArqLog,FO_WRITE) //Abre o arquivo
	if nHandle==-1
		Conout(FERROR())
		Return
	endif
endif

FSEEK(nHandle,0,FS_END)//Posiciona no final do arquivo

	FWRITE(nHandle , CRLF)
	FWRITE(nHandle , "*-------------------------------------------------------------------------------------------------------------------------------------------------------*"+CRLF)
	FWRITE(nHandle , "***********************************************************************************"+CRLF)
	FWRITE(nHandle , "Empresa:"+cEmpAnt+",Filial"+cFilAnt+" ---- Cod User: "+__cUserId+", Nome: "+cUserName+" - "+DTOC(date())+" - "+Time()+CRLF)
	FWRITE(nHandle , "***********************************************************************************"+CRLF)
	FWRITE(nHandle , cMsgLog+CRLF)
	FWRITE(nHandle , "*-------------------------------------------------------------------------------------------------------------------------------------------------------*"+CRLF)

// Fecha o arquivo
FCLOSE(nHandle)

Return

/*
Funcao      : C()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função Para resolução da tela, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/

*----------------------*
Static Function C(nTam) 
*----------------------*
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)

/*
Funcao      : Imprime()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para impressão, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/  
*--------------------------------------*
 Static Function Imprime(cNick,c_M_Tipo)  
*--------------------------------------*
Local cDesc2         := ""
Local cDesc3         := ""
Local Cabec1         := ""
Local Cabec2         := ""
Local cPict          := ""                                                                                                                

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local titulo         := "Relação de erros" //- DATA DE "+mv_par01+" ATE "+mv_par02+" / RESPONSAVEL "+mv_par03+" Ate "+mv_par04+""

Local nLin           := 80
Local imprime        := .T.  

Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.

Private cPerg        := ""  
Private CbTxt        := ""
Private tamanho      := "G"
Private nomeprog     := cNick // Coloque aqui o nome do programa para impressao no cabecalho
Private wnrel        := cNick // Coloque aqui o nome do arquivo usado para impressao em disco

Private nLastKey     := 0

Private nTipo        := 18 
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01 
Private limite       := 220

Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private cbtxt        := Space(10)

Default c_M_Tipo:="1"              

//tratamento da tabela para cString
if cNick=="PRODUTOS" 
	Private cString:="SB1"
elseif cNick=="CLIENTES"
	Private cString:="SA1"
elseif cNick=="FORNECEDOR"
	Private cString:="SA2"
elseif cNick=="FUNCIONARIO"
	Private cString:="SRA"	
elseif cNick=="CONTABIL"
	Private cString:="CT2"
elseif cNick=="ESTRUTURA_PRODUTO"
	Private cString:="SG1"
elseif cNick=="PEDIDO_VENDA"
	Private cString:="SC5"
else
	Private cString:=""
endif

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	  
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)

	/*
			//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       
			//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678					
			//   XXXXXXXXXX  XXXXXXXXXX
	*/
if c_M_Tipo=="1"
	Cabec1 := 	"Codigo      Situacao    Descricao"
else
	Cabec1 := 	"Situacao     Codigo       Codigo Ref   Cpf/Cnpj         Descricao"
endif

DbSelectArea("WWW")
WWW->(DbGotop())
	while WWW->(!EOF())
	   If lAbortPrint
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio. . .                            ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif                              
	
	   if c_M_Tipo=="1"	
		   @nLin,01  PSAY WWW->CODIGO
		   @nLin,13  PSAY WWW->SITUACAO
		   @nLin,25  PSAY WWW->DESCRICAO
	   elseif c_M_Tipo=="2"	
   		   @nLin,01  PSAY WWW->SITUACAO
		   @nLin,13  PSAY WWW->CODIGO
		   @nLin,26  PSAY WWW->CODREF
  		   @nLin,39  PSAY WWW->CGC
   		   @nLin,57  PSAY WWW->DESCRICAO
	   endif	
	
	   nLin++
	   
	   WWW->(DbSkip())
	enddo
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return   

/*
Funcao      : GModelo()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para gerar modelo em excel, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/                             
*-----------------------*
Static Function GModelo()   
*-----------------------*  
Local aDePara 	:= {"SB1","SA1","SA2" ,"","SF1","SC5","CT2",""   ,"SRA","SW1",;
					""	 ,"SG1","SC52","","SA5","SE1","SN1","SW2","SF1","SB9",;
					"SE2","CND"} 

//If !ApOleClient("MsExcel")
//     MsgStop("Microsoft Excel nao instalado.")
//     Return
//EndIf
Private cA1C5		:= "CNPJ Cliente"
Private cTab		:= ""
Private aDadTemp	:= {}
Private aDadTemp1	:= {}
Private aDadTemp2	:= {}
Private aDadTemp3	:= {}
Private aDadTemp4	:= {}
Private aDadTemp5	:= {}
Private aDadTemp6	:= {}
Private nIdioma		:= QualIdioma() //Função que retorna o idioma seleciona: 1-Portugês / 2-Inglês
Private nAdiciObri	:= 2

Private nTamC5:=0
Private nTamC6:=0
Private nTamA1:=0

If nSelec > Len(aDePara) .or. EMPTY(aDePara[nSelec])
	Alert("3 - Não implementado para a modalidade selecionada!")
	Return .F.
EndIf
cTab := aDePara[nSelec]
        
If Alltrim(cTab)=="SC5"
	
	//TLM 15/08/2014
	//nAdiciObri	:= AdicioObrig() //Função que retorna se adiciona obrigatório 1-Sim / 2-Não, específico para Pedido de venda
	
	//Se for português
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if nIdioma==1
		//AADD(aDadTemp,{ cTit ,"C",65,0})
		//-----------------SC5----------------------//
		AADD(aDadTemp,{ "Numero"       ,"C",65,0})
		AADD(aDadTemp,{ "TipoPedido"   ,"C",65,0})
		AADD(aDadTemp,{ "TipoClient"   ,"C",65,0})
		AADD(aDadTemp,{ "CondPgto"     ,"C",65,0})
		AADD(aDadTemp,{ "DtEmissao"    ,"C",65,0})
		AADD(aDadTemp,{ "MsgNota"      ,"C",65,0})
		nTamC5:=len(aDadTemp)
		 
		
		if SX3->(DbSeek("C5_P_REF"))
			AADD(aDadTemp,{ "Num_Refere"     ,"C",65,0})//RRP - 20/03/2015 - Retirando o espaço do Titulo do campo, porque estava gerando Erro.
			nTamC5+=1
		endif
		
		if SX3->(DbSeek("C5_P_NREMP"))
			AADD(aDadTemp,{ "Nr_Empresa"    ,"C",65 ,0}) ;nTamC5+=1
		endif
		if SX3->(DbSeek("C5_P_NRAGE"))
			AADD(aDadTemp,{ "Nr_Agencia"   ,"C",65 ,0})      ;nTamC5+=1
		endif
		if SX3->(DbSeek("C5_P_CAMP"))
			AADD(aDadTemp,{ "Campanha"    ,"C",65 ,0}) ;nTamC5+=1
		endif
		
		if SX3->(DbSeek("C5_NATUREZ"))
			AADD(aDadTemp,{ "Natureza"   ,"C",65 ,0}) ;nTamC5+=1
		endif 
		
		if SX3->(DbSeek("C5_P_IMPB"))
			AADD(aDadTemp,{ "Bol.NomeDe"   ,"C",65 ,0}) ;nTamC5+=1
		endif
		//VYB - 03/08/2016 - Icnlusão do campo da Data do Pedido no layout modelo
		If SX3->(DbSeek("C5_P_DATA"))
			AADD(aDadTemp,{ "Data_Pedido"   ,"C",65 ,0}) ;nTamC5+=1
		Endif		
		//FIM		
		//-----------------SC6----------------------//
		AADD(aDadTemp1,{ "Item"         ,"C",65,0})
		AADD(aDadTemp1,{ "Produto"      ,"C",65,0})
		AADD(aDadTemp1,{ "Descricao"    ,"C",65,0})
		AADD(aDadTemp1,{ "Quantidade"   ,"C",65,0})
		AADD(aDadTemp1,{ "PrcUnit"      ,"C",65,0})
		AADD(aDadTemp1,{ "Valor"        ,"C",65,0})
		AADD(aDadTemp1,{ "Perc.Desconto"          ,"C",65,0})		
		AADD(aDadTemp1,{ "TES"          ,"C",65,0})
		nTamC6:=len(aDadTemp1)
		//-----------------SA1----------------------//
		AADD(aDadTemp3,{ "CPF_CNPJ"     ,"C",65,0})
		AADD(aDadTemp3,{ "Cod_Cli"     ,"C",65,0})
		AADD(aDadTemp3,{ "Loja Cli"     ,"C",65,0})		
		AADD(aDadTemp3,{ "Nome"         ,"C",65,0})
		AADD(aDadTemp3,{ "Fisic_Juri"   ,"C",65,0})
		AADD(aDadTemp3,{ "NFantasia"    ,"C",65,0})
		AADD(aDadTemp3,{ "Endereco"     ,"C",65,0})
		AADD(aDadTemp3,{ "Estado"       ,"C",65,0})
		AADD(aDadTemp3,{ "CodCidade"    ,"C",65,0})
		AADD(aDadTemp3,{ "Cidade"       ,"C",65,0})
		AADD(aDadTemp3,{ "Bairro"       ,"C",65,0})
		AADD(aDadTemp3,{ "CEP"          ,"C",65,0})
		nTamA1:=len(aDadTemp)
		
		//Se for inglês
	else
		//AADD(aDadTemp,{ cTit ,"C",65,0})
		//-----------------SC5----------------------//
		AADD(aDadTemp,{ "Order"	       ,"C",65,0})
		AADD(aDadTemp,{ "OrderType"	   ,"C",65,0})
		AADD(aDadTemp,{ "CustoType"    ,"C",65,0})
		AADD(aDadTemp,{ "PayTerm"      ,"C",65,0})
		AADD(aDadTemp,{ "IssueDate"    ,"C",65,0})
		AADD(aDadTemp,{ "NFMessage"    ,"C",65,0})
		nTamC5:=len(aDadTemp)
		
		if SX3->(DbSeek("C5_P_REF"))
			AADD(aDadTemp,{ "OrderRefer"     ,"C",65,0})
			nTamC5+=1
		endif
		
		if SX3->(DbSeek("C5_P_NREMP"))
			AADD(aDadTemp,{ "Nr_Empresa"    ,"C",65 ,0}) ;nTamC5+=1
		endif
		if SX3->(DbSeek("C5_P_NRAGE"))
			AADD(aDadTemp,{ "Nr_Agencia"   ,"C",65 ,0})      ;nTamC5+=1
		endif
		if SX3->(DbSeek("C5_P_CAMP"))
			AADD(aDadTemp,{ "Campanha"    ,"C",65 ,0}) ;nTamC5+=1
		endif
		
		if SX3->(DbSeek("C5_NATUREZ"))
			AADD(aDadTemp,{ "Natureza"   ,"C",65 ,0}) ;nTamC5+=1
		endif 
		
		if SX3->(DbSeek("C5_P_IMPB"))
			AADD(aDadTemp,{ "Bol.NomeDe"   ,"C",65 ,0}) ;nTamC5+=1
		endif
		//VYB - 03/08/2016 - Icnlusão do campo da Data do Pedido no layout modelo
		If SX3->(DbSeek("C5_P_DATA"))
			AADD(aDadTemp,{ "Data_Pedido"   ,"C",65 ,0}) ;nTamC5+=1
		Endif		
		//FIM
		
		//-----------------SC6----------------------//
		AADD(aDadTemp1,{ "Item"         ,"C",65,0})
		AADD(aDadTemp1,{ "Product"      ,"C",65,0})
		AADD(aDadTemp1,{ "Descriptio"   ,"C",65,0})
		AADD(aDadTemp1,{ "Quantity" 	   ,"C",65,0})
		AADD(aDadTemp1,{ "UnitPrice"    ,"C",65,0})
		AADD(aDadTemp1,{ "GrandTotal"   ,"C",65,0})
		AADD(aDadTemp1,{ "Discount(%)"          ,"C",65,0})		
		AADD(aDadTemp1,{ "OutFlowTyp"   ,"C",65,0})
		nTamC6:=len(aDadTemp1)
		//-----------------SA1----------------------//
		AADD(aDadTemp3,{ "CPF_CNPJ"     ,"C",65,0})
		AADD(aDadTemp3,{ "Cod_Cli"     ,"C",65,0})
		AADD(aDadTemp3,{ "Loja Cli"     ,"C",65,0})		
		AADD(aDadTemp3,{ "CPF_CNPJ"     ,"C",65,0})		
		AADD(aDadTemp3,{ "Name"         ,"C",65,0})
		AADD(aDadTemp3,{ "Type"         ,"C",65,0})
		AADD(aDadTemp3,{ "TradeName"    ,"C",65,0})
		AADD(aDadTemp3,{ "Address"      ,"C",65,0})
		AADD(aDadTemp3,{ "State"    	   ,"C",65,0})
		AADD(aDadTemp3,{ "CodCity"      ,"C",65,0})
		AADD(aDadTemp3,{ "City"         ,"C",65,0})
		AADD(aDadTemp3,{ "NeighborHo"   ,"C",65,0})
		AADD(aDadTemp3,{ "ZipCode"      ,"C",65,0})
		nTamA1:=len(aDadTemp3)
	endif
	//AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	//-----------------SC5----------------------//
	AADD(aDadTemp2,{ "C5_NUM" 		,"C",6 	,0})
	AADD(aDadTemp2,{ "C5_TIPO"  	,"C",1 	,0})
	AADD(aDadTemp2,{ "C5_TIPOCLI"	,"C",1 	,0})
	AADD(aDadTemp2,{ "C5_CONDPAG"  	,"C",3 	,0})
	AADD(aDadTemp2,{ "C5_EMISSAO" 	,"D",8	,0})
	AADD(aDadTemp2,{ "C5_MENNOTA"  	,"C",200,0})
	
	if SX3->(DbSeek("C5_P_REF"))
		AADD(aDadTemp2,{ "C5_P_REF"    ,"C",20 ,0})
	endif
	
	if SX3->(DbSeek("C5_P_NREMP"))
		AADD(aDadTemp2,{ "C5_P_NREMP"    ,"C",20 ,0})
	endif
	if SX3->(DbSeek("C5_P_NRAGE"))
		AADD(aDadTemp2,{ "C5_P_NRAGE"    ,"C",20 ,0})
	endif
	if SX3->(DbSeek("C5_P_CAMP"))
		AADD(aDadTemp2,{ "C5_P_CAMP"    ,"C",120 ,0})
	endif
	if SX3->(DbSeek("C5_NATUREZ"))
		AADD(aDadTemp2,{ "C5_NATUREZ"    ,"C",10 ,0})
	endif 
	
	if SX3->(DbSeek("C5_P_IMPB"))
		AADD(aDadTemp2,{ "C5_P_IMPB"    ,"C",05 ,0})
	endif
	//VYB - 03/08/2016 - Icnlusão do campo da Data do Pedido no layout modelo
	If SX3->(DbSeek("C5_P_DATA"))
		AADD(aDadTemp2,{ "C5_P_DATA"   ,"D",8 ,0})
	Endif		
	//FIM
	
		
	//-----------------SC6----------------------//
	AADD(aDadTemp5,{ "C6_ITEM" 		,"C",2 	,0})
	AADD(aDadTemp5,{ "C6_PRODUTO"  	,"C",15	,0})
	AADD(aDadTemp5,{ "C6_DESCRI"	,"C",60	,0})
	AADD(aDadTemp5,{ "C6_QTDVEN"  	,"N",9 	,2})
	AADD(aDadTemp5,{ "C6_PRCVEN" 	,"N",14	,2})
	AADD(aDadTemp5,{ "C6_VALOR"  	,"N",14	,2})
	AADD(aDadTemp5,{ "C6_DESCONT"  	,"N",5	,2})	
	AADD(aDadTemp5,{ "C6_TES"  		,"C",3	,0})
	
	
	if SX3->(DbSeek("C6_P_VAL01"))
		AADD(aDadTemp5,{ "C6_P_VAL01"  		,"N",SX3->X3_TAMANHO	,SX3->X3_DECIMAL})
		AADD(aDadTemp1,{ "Impressoes" ,"C",65,0})
	EndIf

	if SX3->(DbSeek("C6_P_UMIMP"))
		AADD(aDadTemp5,{ "C6_P_UMIMP"  		,"C",02	,0})
		AADD(aDadTemp1,{ "Unid.Med.Impr." ,"C",65,0})
	EndIf  
		
	if SX3->(DbSeek("C6_P_DTINI"))
		AADD(aDadTemp5,{ "C6_P_DTINI"  		,"D",8	,0})
		AADD(aDadTemp1,{ "Dt_Inicio" ,"C",65,0})
	EndIf
	
	if SX3->(DbSeek("C6_P_DTFIM"))
		AADD(aDadTemp5,{ "C6_P_DTFIM"  		,"D",8	,0})
		AADD(aDadTemp1,{ "Dt_Fim" ,"C",65,0})
	EndIf   
	

	
	if SX3->(DbSeek("C6_P_MOEDA"))
		AADD(aDadTemp5,{ "C6_P_MOEDA"  		,"C",3	,0})
		AADD(aDadTemp1,{ "Moeda AOL" ,"C",65,0})
	EndIf  
			
	AADD(aDadTemp5,{ "C6_LOCAL"  		,"C",2	,0})
	AADD(aDadTemp1,{ "Local" ,"C",65,0})
			
	//-----------------SA1----------------------//
	AADD(aDadTemp6,{ "A1_CGC" 		,"C",14	,0}) 
	AADD(aDadTemp6,{ "A1_COD" 		,"C",06,0})
	AADD(aDadTemp6,{ "A1_LOJA" 		,"C",02	,0})		
	AADD(aDadTemp6,{ "A1_NOME"  	,"C",40	,0})
	AADD(aDadTemp6,{ "A1_PESSOA"	,"C",1	,0})
	AADD(aDadTemp6,{ "A1_NREDUZ"  	,"C",20 ,0})
	AADD(aDadTemp6,{ "A1_END" 		,"C",40	,0})
	AADD(aDadTemp6,{ "A1_EST"  		,"C",40	,0})
	AADD(aDadTemp6,{ "A1_COD_MUN"  	,"C",5	,0})
	AADD(aDadTemp6,{ "A1_MUN"  		,"C",30	,0})
	AADD(aDadTemp6,{ "A1_BAIRRO"  	,"C",30	,0})
	AADD(aDadTemp6,{ "A1_CEP"  		,"C",8	,0})

	AADD(aDadTemp6,{ "A1_EMAIL"  		,"C",8	,0})	
	AADD(aDadTemp3,{ "EMAIL" ,"C",65,0})	 
	
	AADD(aDadTemp6,{ "A1_TIPO"  		,"C",8	,0})	
	AADD(aDadTemp3,{ "TIPO" ,"C",65,0})	
	
	AADD(aDadTemp6,{ "A1_NATUREZ"  		,"C",8	,0})	
	AADD(aDadTemp3,{ "NATUREZA" ,"C",65,0})	
	
	AADD(aDadTemp6,{ "A1_CONTA"  		,"C",8	,0})	
	AADD(aDadTemp3,{ "CONTA" ,"C",65,0})				
	
	if SX3->(DbSeek("A1_P_ID"))
		AADD(aDadTemp6,{ "A1_P_ID"  		,"C",20	,0})
		AADD(aDadTemp3,{ "ID_Cliente" ,"C",65,0})
	EndIf
	//Deve ser adicionado campos obrigatorios do SX3? SIM
	//If nAdiciObri==1   TLM Necessário adicionar todos os campos obrigatórios
	//Adiciona campos obrigatórios faltantes do SC5
	DbSelectArea("SX3")
	Dbsetorder(1)
	If Dbseek("SC5")
		while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SC5")
			if x3Obrigat(SX3->X3_CAMPO) .AND. ( Ascan( aDadTemp2 , { |x| x[ 1 ] == AllTrim(SX3->X3_CAMPO) } ) == 0 ) .And. ;
				 !AllTrim(SX3->X3_CAMPO) $ 'C5_CLIENTE,C5_LOJACLI' 
			    
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
				
				If SX3->X3_CAMPO=="C5_LOJACLI"  //Lojacli tem titulo de loja, necessário ajuste
					AADD(aDadTemp,{ "LOJACLI" ,"C",65,0})
				Else
					AADD(aDadTemp,{ cTit ,"C",65,0})
				EndIf
				AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
				
			endif
			SX3->(DbSkip())
		enddo
	Endif
	
	//Adiciona campos obrigatórios faltantes do SC6
	DbSelectArea("SX3")
	Dbsetorder(1)
	If Dbseek("SC6")
		while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SC6")
			if x3Obrigat(SX3->X3_CAMPO) .AND. ( Ascan( aDadTemp5 , { |x| x[ 1 ] == AllTrim(SX3->X3_CAMPO) } ) == 0 )  .And. ;
			!AllTrim( SX3->X3_CAMPO ) $  "C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C6_TES,C6_CF,C6_TURNO,C6_CHASSI,C6_UM,C6_NUM,C6_PRUNIT,C6_CLASFIS"
				
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp1)
				
				AADD(aDadTemp1,{ cTit ,"C",65,0})
				AADD(aDadTemp5,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
				
				
			endif
			SX3->(DbSkip())
		enddo
	Endif
	
	//Adiciona campos obrigatórios faltantes do SA1
	DbSelectArea("SX3")
	Dbsetorder(1)
	If Dbseek("SA1")
		while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SA1")
			if x3Obrigat(SX3->X3_CAMPO) .AND. ( Ascan( aDadTemp6 , { |x| x[ 1 ] ==  AllTrim(SX3->X3_CAMPO) } ) == 0 )   .And. ;
						 !AllTrim( SX3->X3_CAMPO ) $"A1_COD,A1_LOJA,A1_CGC,A1_NOME,A1_PESSOA,A1_NREDUZ,A1_END,A1_EST,A1_COD_MUN,A1_MUN,A1_BAIRRO,A1_CEP,A1_CBAIRRE"			
			
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp3)
				
				AADD(aDadTemp3,{ cTit ,"C",65,0})
				AADD(aDadTemp6,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
				
			endif
			SX3->(DbSkip())
		enddo
	Endif
	
	For i=1 to len(aDadTemp1)
		AADD(aDadTemp,{aDadTemp1[i][1],aDadTemp1[i][2],aDadTemp1[i][3],aDadTemp1[i][4]})
	Next i
	
	For j := 1 To 2 
		For i=1 to len(aDadTemp3)
			AADD(aDadTemp,{aDadTemp3[i][1]+If( j == 1 , "(VEN)","(COB)"),aDadTemp3[i][2],aDadTemp3[i][3],aDadTemp3[i][4]})
		Next
	Next i
	
	
	For i=1 to len(aDadTemp5)
		AADD(aDadTemp2,{aDadTemp5[i][1],aDadTemp5[i][2],aDadTemp5[i][3],aDadTemp5[i][4]})
	Next i
	
	For j := 1 To 2 
		For i=1 to len(aDadTemp6)
			AADD(aDadTemp2,{aDadTemp6[i][1]+If( j == 1 , "(VEN)","(COB)"),aDadTemp6[i][2],aDadTemp6[i][3],aDadTemp6[i][4]})
		Next
	Next i
	
	
else
	alert("Problemas para encontrar tabela modelo!")
	return
EndIf    

/*
If select("DADXLS")>0
	DADXLS->(DbCloseArea())
Endif

cNome := CriaTrab(aDadTemp,.t.)
dbUseArea(.T.,,cNome,"DADXLS",.F.,.F.)

cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADXLS",cIndex,aDadTemp[1][1],,,"Selecionando Registro...")

DbSelectArea("DADXLS")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)    
//Armazena tipo,tamanho,formato
Begin Transaction
	Reclock("DADXLS",.T.)
*/
cFile := GetTempPath() + CriaTrab(,.F.) + '.csv'

If File( cFile )
	FErase( cFile )
	If FError() <> 0
		MsgStop( 'Erro arquivo ' + cFile + ' em uso.' )
		Return
	EndIf
EndIf

nFile := FCreate( cFile )

If FError() <> 0
	MsgStop( 'Erro na criação do arquivo. ' )
	Return
EndIf

For i := 1 To 3
	cBuffer := ''
	For nS:=1 to len(aDadTemp)
		
		If ( i == 1 )
			cBuffer += AllTrim( aDadTemp[ nS ][ 1 ] ) + ";"	
			
		ElseIf ( i == 2 )
			if alltrim(aDadTemp2[nS][2])=="N"
				cModTip:=IIF(nIdioma==1,"Numerico","Numerical")
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"Sem formato","Unbodied")
			elseif alltrim(aDadTemp2[nS][2])=="D"
				cModTip:=IIF(nIdioma==1,"Data","Date")
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"DD/MM/YYYY","DD/MM/YYYY")
			elseif alltrim(aDadTemp2[nS][2])=="C"
				cModTip:=IIF(nIdioma==1,"AlfaNumerico","Alphanumeric")
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"Sem formato","Unbodied")
			else
				cModTip:=alltrim(aDadTemp2[nS][2])
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"Sem formato","Unbodied")
			endif    
			
			if nIdioma==1
				cBuffer += "Tipo: "+cModTip+" ,Tamanho: "+cModTam+" ,Formato: "+cModForm + ";"
			else
				cBuffer += "Type: "+cModTip+" ,Size: "+cModTam+" ,Format: "+cModForm + ";
			endif
		
		ElseIf ( i == 3 )
				cBuffer += aDadTemp2[nS][1] + ";
			
		EndIf

	next       
	cBuffer += Chr( 13 ) + Chr( 10 )
	FWrite( nFile , cBuffer , Len( cBuffer ) )	
Next


//	DADXLS->(MsUnlock())
//End Transaction



//Armazena linha com o nome dos campos no excel
/*
Begin Transaction
	Reclock("DADXLS",.T.)
		for nS:=1 to len(aDadTemp)
        	DADXLS->&(aDadTemp[nS][1]):=aDadTemp2[nS][1]
		next	
	DADXLS->(MsUnlock())
End Transaction
  
DADXLS->(DbCloseArea())
 
	cArqOrig := "\"+curdir()+cNome+".DBF"
	cPath     := AllTrim(GetTempPath())                                                   
	CpyS2T( cArqOrig , cPath, .T. )
      
    oExcelApp:=MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
    oExcelApp:SetVisible(.T.)   
      
sleep(10)

fErase(cNome+OrdBagExt())
fErase(cIndex+OrdBagExt())

Erase &cNome+".DBF"
*/   

FClose( nFile )

oExcel:=MsExcel():New()
oExcel:WorkBooks:Open( cFile )
oExcel:SetVisible( .T. )

Return

             
/*
Funcao      : OPCMVINT  
Parametros  : 
Retorno     : 
Objetivos   : Função para gerar tela com o conteúdo dos parâmetros para seleção
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
*/
*-----------------------*
Static Function OPCMVINT(lOpen)
*-----------------------*
//somente se for do grupo de administradores
if PswAdmin(,,__cUserID)<>0
	Alert("Somente para administradores!")
	return
endif

Private oOk := LoadBitmap( GetResources(), "LBOK")
Private oNo := LoadBitmap( GetResources(), "LBNO")
Private oChkQual,lQual,oQual,cVarQ,oDlg2
Private cCounteudo:=alltrim(GETMV("MV_P_INT_P"))
Private aParam:=OQUEPARA()
Private aListBox1:={}

for i:=1 to len(aParam)
	AADD(aListBox1,{.F.,aParam[i][1]+" - "+aParam[i][2],aParam[i][1]})	
next 

for j:=1 to len(cCounteudo)
	nAc:=aScan( aParam, { |x| alltrim(x[1]) == SUBSTR(cCounteudo,j,1)} )
	if nAc>0
		aListBox1[nAc][1]:=.T.
	endif
next

DEFINE MSDIALOG oDlg2 TITLE "Conteúdo Parametro" FROM C(212),C(242) TO C(548),C(583) PIXEL

	@ C(001),C(12) CHECKBOX oChkQual VAR lQual PROMPT "Inverte Seleção" SIZE 50, 10;
	OF oDlg2 PIXEL;
	ON CLICK (AEval(aListBox1, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),;
	oQual:Refresh(.F.))
 
	
	@ C(010),C(012) LISTBOX oQual VAR cVarQ Fields HEADER "","Opção" SIZE;
    C(145),C(145) ON DBLCLICK (aListBox1:=Troca(oQual:nAt,aListBox1),oQual:Refresh()) NoScroll OF oDlg2 PIXEL

	oQual:SetArray(aListBox1)

	oQual:bLine := { || {If(aListBox1[oQual:nAt,1],oOk,oNo),aListBox1[oQual:nAt,2]}}
			
	// Cria Componentes Padroes do Sistema
	@ C(158),C(023) Button "Salvar" Size C(037),C(012) action(ATUMV(Arraytrue(aListBox1)),lOpen:=.T.,oDlg2:end(),oQual:end(),oChkQual:end(),OdlgPrin:end()) PIXEL OF oDlg2
	@ C(158),C(106) Button "Sair" Size C(037),C(012) action(oDlg2:end()) PIXEL OF oDlg2

ACTIVATE MSDIALOG oDlg2 CENTERED 

Return

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray     

/*
Funcao      : MarcaOk()  
Parametros  : aArray
Retorno     : lRet
Objetivos   : Verifica Se existe algum CheckBox, marcado;Se não tiver nenhum marcado exibe uma msg!
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
*/
*-----------------------------*
Static Function MarcaOk(aArray)
*-----------------------------*
Local lRet:=.F.
Local nx:=0

// Checa marcações efetuadas
For nx:=1 To Len(aArray)
	If aArray[nx,1]
		lRet:=.T.
	EndIf
Next nx

// Checa se existe algum item marcado na confirmação
If !lRet
	HELP("SELFILE",1,"HELP","Atenção","Não existem itens marcados",1,0)
EndIf
Return lRet  

/*
Funcao      : Arraytrue()  
Parametros  : aArray
Retorno     : aArray
Objetivos   : Função gera e retorna um array, só com os itens marcados.
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
*/
*--------------------------------*
Static Function Arraytrue(aArray)
*--------------------------------*
Private aArray2:={}

For i:=1 to len(aArray)
	If aArray[i][1]
		AADD(aArray2,aArray[i])
	Endif 
Next

return aArray2

/*
Funcao      : OQUEPARA()  
Parametros  : nItem 
Retorno     : cRet
Objetivos   : Retornar o significado de cada item do parametro
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
Revisão		: Alterado para tratamento dinamico.
Autor		: Jean Victor Rocha
Data		: 25/10/2012
*/
*------------------------*
Static Function OQUEPARA()
*------------------------*
Local aRet:={}
    
For i:=1 to Len(aItensP)
	If i >= 10
		AADD(aRet,{CHR(55+i),aItensP[i]})
	Else
		AADD(aRet,{ALLTRIM(STR(i)),aItensP[i]})
	EndIf
Next i

Return(aRet)

/*
Funcao      : ATUMV()  
Parametros  : aArray 
Retorno     : cRet
Objetivos   : Atualiza conteúdo do parametro
Autor       : Matheus Massarotto
Data/Hora   : 20/04/2012
*/
*---------------------------*
Static Function ATUMV(aArray)
*---------------------------*
Local cConteudo:=""

For i:=1 to len(aArray)
	cConteudo+=aArray[i][3]
Next

PUTMV("MV_P_INT_P",cConteudo)

Return

/*
Funcao      : QualIdioma()  
Parametros  : 
Retorno     : nIdioma
Objetivos   : Tela para seleção de qual idioma será gerado o modelo
Autor       : Matheus Massarotto
Data/Hora   : 10/07/2012
*/
*--------------------------*
Static Function QualIdioma()
*--------------------------*
// Variaveis Locais da Funcao
Local nIdioma		:= 1 
Local oIdioma
Local oDlgIdi	// Dialog Principal
Local oCliente
Local cTitulo		:= ""
Local aCliente		:= {}

aCliente:={"CNPJ Cliente","Cliente / Loja PROTHEUS"}

If nSelec==13
	cTitulo:="Parâmetros"
Else
	cTitulo:="Selecione o idioma"
EndIf

DEFINE MSDIALOG oDlgIdi TITLE cTitulo FROM C(255),C(412) TO C(374),C(575) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(000),C(003) TO C(044),C(080) LABEL "Idioma" PIXEL OF oDlgIdi
	@ C(006),C(006) Radio oIdioma Var nIdioma Items "Português","Inglês" 3D Size C(050),C(010) PIXEL OF oDlgIdi 
	//RRP - 05/12/2014 - Opção para gerar o A1_CGC ou C5_CLIENTE+C5_LOJACLI
	If nSelec==13 
		@ 30,08 SAY oSay1 VAR "Modelo Cliente:" OF oDlgIdi PIXEL
		@ 40,08 MSCOMBOBOX oCliente VAR cA1C5 ITEMS aCliente OF oDlgIdi PIXEL SIZE 80,09
	EndIf
	@ C(046),C(022) Button "Ok" Size C(037),C(012) action(oDlgIdi:end()) PIXEL OF oDlgIdi

	// Cria ExecBlocks dos Componentes Padroes do Sistema

ACTIVATE MSDIALOG oDlgIdi CENTERED 

Return(nIdioma)

/*
Funcao      : QualIdioma()  
Parametros  : 
Retorno     : nIdioma
Objetivos   : Tela para seleção de qual idioma será gerado o modelo
Autor       : Matheus Massarotto
Data/Hora   : 11/07/2012
*/
*---------------------------*
Static Function AdicioObrig()
*---------------------------*
Local nObri	 := 2
Local oObri
Local oDlgIdi	// Dialog Principal

DEFINE MSDIALOG oDlgIdi TITLE "Selecione se adiciona campos Obrigatórios" FROM C(255),C(412) TO C(374),C(575) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(000),C(003) TO C(044),C(080) LABEL "Adiciona campos obrigatórios" PIXEL OF oDlgIdi
	@ C(010),C(006) Radio oObri Var nObri Items "SIM","NAO" 3D Size C(050),C(010) PIXEL OF oDlgIdi
	@ C(046),C(022) Button "Ok" Size C(037),C(012) action(oDlgIdi:end()) PIXEL OF oDlgIdi
	// Cria ExecBlocks dos Componentes Padroes do Sistema

ACTIVATE MSDIALOG oDlgIdi CENTERED 

Return(nObri)

/*
Funcao      : Situacao2()
Parametros  : aErros,aGravado
Retorno     : Nenhum
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK. Para todos Versão 2.
Autor       : Matheus Massaroto
Data/Hora   : 12/07/2012 18:15
*/
*------------------------------------------*
Static Function Situacao2()
*------------------------------------------*
Private _oDlg,oListBox
Private aListBox:={}
Private cNick    
Private aHeader	:={}
Private aAlter	:={"M_MEMO"}
Private	nUsado	:=0
Private aCols	:={}
Private cTipo   := "2"

Private aRotina := {{"Pesquisar"	, "AxPesqui", 0, 1},;
					{"Visualizar"	, "AxVisual", 0, 2},;
					{"Incluir"		, "AxInclui", 0, 3},;
					{"Alterar"		, "AxAltera", 0, 4},;
					{"Excluir"		, "AxDeleta", 0, 5}}

If nSelec==6 .or. nSelec==13
	cNick:="PEDIDO_VENDA"
ElseIf nSelec==15 //RRP - 03/12/2013 - Inclusão do Produto x Fornecedor. 
	cNick:="PRODUTO_FORNECEDOR"
ElseIf nSelec==5 .or. nSelec>=16
	cNick:=ALLTRIM(aItensP[nSelec])
ElseIf nSelec==14
	cNick:="COMPLEMENTO_PRODUTO" //RRP - 08/08/2014 - Tratamento de log Complemento de produto. 
ElseIf nSelec==7
	cNick:="CONTABILIDADE"
	cTipo:="1"
Else
	cNick:=""
	alert("4 - Não implementado para a modalidade selecionada!")
	Return
EndIf

//--Montagem do aHeader com os campos que serão apresentados--//
			AADD(aHeader,{ TRIM("Situacao"),;
								 "M_SITU",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Codigo"),;
								 "M_COD",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			
			if nSelec<>7 //Não adicionar na tela de log se for contabilidade
				AADD(aHeader,{ TRIM("Codigo_Refer"),;
									 "M_CODREF",;
									 "@X  ",;
									 10,;
				 					 0,;
				 					 "ALLWAYSTRUE()",;
				 					 "€€€€€€€€€€€€€€ ",;
				 					 "C",;
				 					 "",;
				 					 "" } )			 					 
				nUsado:=nUsado+1
				AADD(aHeader,{ TRIM("CPF_CNPJ"),;
									 "M_CGC",;
									 "@X  ",;
									 14,;
				 					 0,;
				 					 "ALLWAYSTRUE()",;
				 					 "€€€€€€€€€€€€€€ ",;
				 					 "C",;
				 					 "",;
				 					 "" } )			 					 
				nUsado:=nUsado+1
			endif
			
			AADD(aHeader,{ TRIM("Descricao"),;
								 "M_DESC",;
								 "@X  ",;
								 100,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Detalhes_Dois_Cliques"),;
								 "M_MEMO",;
								 "@X  ",;
								 0,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "M",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
//--Fim Montagem do aHeader com os campos que serão apresentados--//

DbSelectArea("WWW")
WWW->(DbGoTop())

While WWW->(!EOF())
	AADD(aCols,Array(nUsado+1))
		for nI:=1 to nUsado
			if ALLTRIM(aHeader[nI,2]) =="M_SITU"
				aCols[Len(aCols)][nI]:=WWW->SITUACAO
			elseif ALLTRIM(aHeader[nI,2]) =="M_COD"
				aCols[Len(aCols)][nI]:=WWW->CODIGO
			elseif ALLTRIM(aHeader[nI,2]) =="M_CODREF"
				aCols[Len(aCols)][nI]:=WWW->CODREF
			elseif ALLTRIM(aHeader[nI,2]) =="M_CGC"
				aCols[Len(aCols)][nI]:=IF(nSelec==6,WWW->CGC,"")
			elseif ALLTRIM(aHeader[nI,2]) =="M_DESC"
				aCols[Len(aCols)][nI]:=WWW->DESCRICAO
			elseif ALLTRIM(aHeader[nI,2]) =="M_MEMO"
				aCols[Len(aCols)][nI]:=WWW->MEMO
			endif
		next
	aCols[Len(aCols)][nUsado+1] := .F.
	WWW->(DbSkip())
Enddo

DEFINE MSDIALOG _oDlg TITLE cNick FROM C(178),C(180) TO C(565),C(966) PIXEL

	@ C(180),C(300) Button "&Imprimir" Size C(037),C(012) PIXEL OF _oDlg action(Imprime(cNick,cTipo))
	@ C(180),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())

  	oGetDados := MsGetDados():New(15, 05, 210, 500, 2, "AllwaysTrue()", "AllwaysTrue()",;
	"", .T., aAlter, , .F., 999, "AllwaysTrue()", "AllwaysTrue()",,;
	"AllwaysTrue()", _oDlg)
   
ACTIVATE MSDIALOG _oDlg CENTERED 

Return

/*
Funcao      : XlogMEMO()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro para campo memo, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 12/07/212 18:15
*/
*----------------------------------*
Static Function XLOGMEMO(aAutoErro)  
*----------------------------------*     
LOCAL cRet := ""
LOCAL nX := 1

FOR nX := 1 to Len(aAutoErro)
	cRet+=aAutoErro[nX]+CRLF
NEXT nX                        

RETURN cRet

/*
Funcao      : ChkIn()
Parametros  : cCampo
Retorno     : Nenhum
Objetivos   : Verificando tratamento no Inicializador Padrão do A1_COD e C5_NUM.
Autor       : Renato Rezende
Data/Hora   : 29/08/212 10:35
*/
*----------------------------------*
 Static Function ChkIn(cCampo)  
*----------------------------------*
If cCampo=="C5_NUM"
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	If Dbseek("C5_NUM")
		If ALLTRIM(SX3->X3_RELACAO)<>'IIF(ALLTRIM(FUNNAME())=="MATA410",GETSXENUM("SC5","C5_NUM"),"")'
			RECLOCK("SX3",.F.)
	   		SX3->X3_RELACAO:='IIF(ALLTRIM(FUNNAME())=="MATA410",GETSXENUM("SC5","C5_NUM"),"")'
	   		SX3->(MSUNLOCK())
		EndIf
	EndIf
ElseIf cCampo=="A1_COD"
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	If Dbseek("A1_COD")
		If ALLTRIM(SX3->X3_RELACAO)<>'IIF(ALLTRIM(FUNNAME())=="MATA030",GETSXENUM("SA1","A1_COD"),"")'
			RECLOCK("SX3",.F.)
	   		SX3->X3_RELACAO:='IIF(ALLTRIM(FUNNAME())=="MATA030",GETSXENUM("SA1","A1_COD"),"")'
			SX3->(MSUNLOCK())
		EndIf
	EndIf
EndIf
Return

/*
Funcao      : Xlog()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*-------------------------------*
 Static Function XLOG(aAutoErro)  
*-------------------------------*     
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=alltrim(substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; ")
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet 
