#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#include "fileio.ch"  
#include "protheus.ch"
#include "intpryor.ch"
//#INCLUDE "Average.ch"
/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTPRYOR  ºAutor  Tiago Luiz Mendonça  º Data ³  07/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de integração de arquivos                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*                                                                                                          
Funcao      : INTPRYOR
Objetivos   : Integração de arquivos 
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*----------------------*
User Function INTPRYOR() 
*----------------------*                             
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
                                                            
aSays :={}
aBto  :={}

aadd(aButtons,{STR007,{|| Ordena()}  ,STR008,STR008,{|| .T.}})
aadd(aButtons,{STR009,{|| MarcaTds()},STR010,STR010,{|| .T.}})

SX6->(DbSetOrder(1))
If !SX6->(DbSeek(xFilial()+"MV_P_INT_P"))
   cText:="Integração Padrão Grant Thornton"     
   Aadd(aSays,"Essa rotina é personalizada.") 
   Aadd(aSays,"Essa empresa não está preparada para integração.")
   Aadd(aSays," " )   
   Aadd(aSays,"Entre em contato com a equipe de Suporte." )                                 
   Aadd(aBto, { 2,.T.,{|o| o:oWnd:End() }} )
   FormBatch( cText, aSays, aBto,,200,360  )
   Return .F.    
Else
   cTipo:=Alltrim(GetMv("MV_P_INT_P"))
   
	//Tratamento para Habilitar todas as integrações disponiveis - executa uma unica vez.
	If ALLTRIM(SX6->X6_DESC1) <> "padrao GT."
		cTipo := ""
		For i:=1 to Len(aItensP)
	   		If i <= 9
		   		cTipo += CHR(48+i)
		   	Else 
		   		cTipo += CHR(55+i)
		   	EndIf
		Next i
		SX6->(RecLock("SX6",.F.))	
		SX6->X6_DESC1	:= "padrao GT."
   		SX6->X6_CONTEUD	:= cTipo
		SX6->(MsUnlock())	
	EndIf

   If Empty(cTipo)
      MsgStop("Necessário checar o pârametro MV_P_INT_P",STR061)
   	  Return .F.
   EndIf
	
EndIf

   nSelec := 0

   DEFINE MSDIALOG OdlgPrin TITLE STR011 From 1,7 To 30,70 OF oMain  

      nLin1:=010  
      nLin2:=133  
      
      nCol1:=040
      nCol2:=220      

      oSBox1 := TScrollBox():New( OdlgPrin,nLin1-4,nCol1,nLin2-4,nCol2-40,.T.,.T.,.T. )

      nLin:=020  
      nCol:=045  
      
	  @ 004,004 Say STR012  PIXEL SIZE 110,6 OF oSBox1  
	  aComboItens := {}
	  nTamanho := 20*len(Alltrim(cTipo))
	  For i:=1 to len(Alltrim(cTipo))
		 &("nSec"+ALLTRIM(STR(i))) := 0
	 	 aAdd(aComboItens,&("aItensP[nSec"+ALLTRIM(STR(i))+":=Val(CheckOp(SubStr(cTipo,"+ALLTRIM(STR(i))+",1)))]"))
	  Next i
	  oCbx := TRadMenu():New(014,004,aComboItens,,oSBox1,,,CLR_HBLUE,CLR_WHITE,,,,140,nTamanho,,,,.T.)

      oCbx:bChange := {|| If(nCbx > 0,nSelec:=&("nSec"+AllTrim(Str(nCbx))),nSelec := 0)}
      oCbx:bSetGet := {|u| If(PCount()==0,nCbx,nCbx:=u)}
            
      //Habilita o primeiro item
      oCbx:SetOption(1) 
      nSec1  := Val(CheckOp(SubStr(cTipo,1,1)))
      nSelec := nSec1

      nLin1 := nLin2 + 3
      nLin2 := nLin1+31
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
   	  nLin1 += 15
	
      //MSM - 20/04/2012 - Criação da barra no rodapé da tela para informar a opção Parametro
	  oFont:= TFont():New('Courier New',,-14,.T.)// Cria font para uso
      //Montagem da barra inferior informando a opção F12
      oTMsgBar := TMsgBar():New(OdlgPrin,"",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
      oTMsgItem1 := TMsgItem():New( oTMsgBar,"Parametro", 100,,,,.T., {||OPCMVINT(@lOpen)})

   ACTIVATE DIALOG OdlgPrin CENTERED ON INIT(OdlgPrin:Refresh())         
  
	if lOpen//MSM - 23/04/2012 - Para chamar a rotina novamente caso tenha atualizado o parametro
		U_INTPRYOR()
	endif

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

If nSelec == 0
	MsgInfo("Nenhuma opção de integração foi selecionada.",STR061)
	Return .F.
EndIf

If nSelec == 8 .or.  nSelec == 11 //Arquivo XML
	cType    := "Arq.XML  | *.XML" 
	
ElseIf nSelec == 7 .and.; // Contabil
	cEmpAnt $ '48/49/50'	//Discovery 
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

//nSelec:=&("nSec"+Alltrim(Str(nSelec))) 
   If nSelec==1  // Produto        
		if !GeraArqB1(cArquivo)
			Return .F.
		endif        
   EndIf

   If nSelec==2  // Cliente
   		if !GeraArqA1(cArquivo)
        	Return .F.
        endif
   EndIf

   If nSelec==3  // Fornecedor
   		If !GeraArqA2(cArquivo)
        	Return .F.
        Endif
   EndIf   

   If nSelec==4  // Pedido de compra
      	MsgAlert("Rotina de PC em desenvolvimento",STR061)   
   		If !GeraArqC7(cArquivo)
        	Return .F.
        Endif
   EndIf   

   	If nSelec==5	//5 - NF de entrada (.CSV)
		If !GeraArq5(cArquivo)
			Return .F.
		Endif
	EndIf             

   If nSelec==6  // Pedido Faturament/Saida  
   		//ExecSC5(cArquivo)  
        If !GeraArqSC5(cArquivo)
        	Return .F.
        Endif
   EndIf		

   If nSelec==7  // Contabilidade             
      // Novo tratamento para integração contabil, todas empresas com excessão discovery.
      If !(cEmpAnt $  ("48/49/50")) 
      	If !GeraArqCT2(cArquivo)
   			Return .F.
        Endif
      Else
      	ExecCT2(cArquivo) 
      EndIf
   EndIf
   
   If nSelec==8  //XML de pre Nf de entrada
      //Verifica se o arquivo existe.
      If File(cArquivo)  
      	//Integração do arquivo XML 
      	If !IntXmlPNF(cArquivo)
	    	Return .F.
	    EndIf
      Else
         MsgInfo("O arquivo XML não foi encontrado.",STR061)
         Return .F.

      EndIf 	
   EndIf
   
   if nSelec==9 //Funcionários
        If !GeraArqRa(cArquivo)
        	Return .F.
        Endif
   Endif
   
   If nSelec==10  //Solicitação importação
   		If !GeraArqW1(cArquivo)
        	Return .F.
        Endif
   EndIf
   
   If nSelec==11  //XML de pre Nf de frete (CTR)
      //Verifica se o arquivo existe.
      If File(cArquivo)  
      	//Integração do arquivo XML 
      	If !IntXmlFRE(cArquivo)
	    	Return .F.
	    EndIf
      Else
         MsgInfo("O arquivo XML não foi encontrado.",STR061)
         Return .F.
      EndIf 	
   EndIf
   
   //MSM - 23/04/2012 - Adicionado função de processamento do Cadastro de Estruturas
   If nSelec==12  // Estrutura de Produto
   		If !GeraArqSG1(cArquivo)
        	Return .F.
        Endif
   EndIf

	If nSelec==13  //D - Pedido/NF de Saída, S/ incl. CLiente?
		If !GeraArqD(cArquivo)
			Return .F.
		Endif
	EndIf

	If nSelec==14  //E - Complemento de Produto
		If !GeraArqE(cArquivo)
			Return .F.
		Endif
	EndIf
	//RRP - 03/12/2013 - Adicionado função para integrar o Produto X Fornecedor (SA5).
	If nSelec==15  //F - Produto X Fornecedor
		If !GeraArqF(cArquivo)
			Return .F.
		Endif
	EndIf

	If nSelec==16  //G - Contas a Receber
		If !GeraArqG(cArquivo)
			Return .F.
		Endif
	EndIf

	If nSelec==17  //H - Ativos
		If !GeraArqH(cArquivo)
			Return .F.
		Endif
	EndIf

	If nSelec==18  //I - Purchase Order (SI automatica).
		If !GeraArqI(cArquivo)
			Return .F.
		Endif
	EndIf            
	
	If nSelec==19  //J - Pre NF de entrada (.CSV)
		If !GeraArqJ(cArquivo)
			Return .F.
		Endif
	EndIf            
	
	If nSelec==20  //K - Saldo Inicial
		If !GeraArqK(cArquivo)
			Return .F.
		Endif
	EndIf	 
	If nSelec==21  //L - Contas a Pagar 
		If !GeraArqL(cArquivo)
			Return .F.
		Endif
	EndIf	 
	If nSelec==22  //M - Medicoes/Entregas
		If !GeraArqM(cArquivo)
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
Funcao      : Validacoes()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para validar dados da integração
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/02/11 18:15
*/
*------------------------------------------*
Static Function Validacoes(cTipo,aDados)
*------------------------------------------*
Local  cLog := "" 
Local  cObrItemD :=""
Local  cObrClassD:="" 
Local  cObrItemC :=""
Local  cObrClassC:=""

Local nX := 0  
   If cTipo == "SF1" 
      If alltrim(Int_SF1->F1_DOC) <> "" 
         If Valida_NFE(Alltrim(Int_SF1->F1_DOC),Alltrim(Int_SF1->F1_SERIE)) <> ""
	       cLog := STR035 //"NOTA + SERIE JA EXISTE / "
           lInt:=.F.
         EndIf
      Else
         If Int_SF1->F1_FORMUL =='S'
            cLog := STR036 //"NUMERO DA NOTA NÃO PREENCHIDO / "
            lInt:=.F.
         EndIf
      EndIf

	  If !Int_SF1->F1_TIPO $ "NDIPBC"
	     cLog := cLog + STR037 // "TIPO DE NOTA INCORRETO / "
	     lInt:=.F.
	  EndIf 

	  If Alltrim(Int_SF1->F1_FORNECE) <> "" .Or. Alltrim(Int_SF1->F1_LOJA) <> ""	
	     If Alltrim(cIncAtuFor) == "S"  // Se for inclusão automatica de fornecedor/cliente
	        If !(Alltrim(Int_SF1->F1_TIPO) $ "B/D")  
	           If Alltrim(Valida_FORN(Int_SF1->F1_FORNECE,Int_SF1->F1_LOJA)) <> ""   // Aviso - Não impede a gravação  lInt:=.T.
	              cLog:=cLog + STR038 //"FORNECEDOR JA CADASTRADO / "  
	           EndIf
	        Else  
	           If Alltrim(Valida_CLI(Int_SF1->F1_FORNECE,Int_SF1->F1_LOJA)) <> ""   // Aviso - Não impede a gravação  lInt:=.T.
	              cLog := cLog + STR039 //"CLIENTE JA CADASTRADO / "   
	           EndIf
	        EndIf
	     Else
	        If !(Alltrim(Int_SF1->F1_TIPO) $ "B/D")  
	           If Alltrim(Valida_FORN(Int_SF1->F1_FORNECE,Int_SF1->F1_LOJA)) == ""  // Impede a gravação pois o fornecedor não eixste.  lInt:=.F.
	              cLog:=cLog + STR040  //"FORNECEDOR NAO CADASTRADO / "
	              lInt:=.F.    
	           EndIf
	        Else  
	           If Alltrim(Valida_CLI(Int_SF1->F1_FORNECE,Int_SF1->F1_LOJA)) == ""   // Impede a gravação pois o cliente não eixste.  lInt:=.F.
	              cLog := cLog + STR041  //"CLIENTE NAO CADASTRADO / "  
	              lInt:=.F. 
	           EndIf
	        EndIf    
	     EndIf    
	  Else 
	     cLog := cLog + STR042   //"CLIENTE/FORNECEDOR OU LOJA NAO CADASTRADO / " 
	     lInt:=.F.
	  EndIf 
    	  
   EndIf	   

   If cTipo=="SD1" 
      If Valida_Produto(Int_SD1->D1_COD) == ""
	     cLog := cLog + STR043 + AllTrim(Int_SD1->D1_COD) + STR044  // " PRODUTO ","NAO CADASTRADO / "
	     lInt:=.F.
	  EndIf 

	  If AllTrim(Int_SD1->D1_LOCAL) == ""
	     cLog := cLog + STR045  //"LOCAL NAO PREENCHIDO / "
	     lInt:=.F.
      EndIf

      If Valida_Local(Int_SD1->D1_COD,Int_SD1->D1_LOCAL) == ""  
         cLog := cLog + STR046  //"LOCAL INVALIDO / "   
	     lInt:=.F.  
	  EndIf   

	  If AllTrim(Int_SD1->D1_UM) == ""
	     cLog := cLog + STR047  //"UNIDADE NAO PREENCHIDO / "
	     lInt:=.F.
      EndIf

      If !(Int_SD1->D1_QUANT > 0 )
	     cLog := cLog + STR048  //"QUANTIDADE NAO PREENCHIDO / "
	     lInt:=.F.
      EndIf 

      If !(Int_SD1->D1_VUNIT > 0)  
	     cLog := cLog + STR049  //"VALOR UNITARIO NAO PREENCHIDO / "  
	     lInt:=.F.
      EndIf  
      
      If !(Int_SD1->D1_TOTAL > 0)
	     cLog := cLog + STR050  //"VALOR TOTAL NAO PREENCHIDO / " 
	     lInt:=.F.
      EndIf             
   
   EndIf

   If cTipo=="SC5"
      If !Int_SC5->C5_TIPO $ "N/C/I/P/X"
	     cLog := STR051  //"TIPO DE PEDIDO INCORRETO/"
	     lInt:=.F.
	  EndIf

	  If !Int_SC5->C5_TIPOCLI $ "F/L/R/S/X"
	     cLog := cLog + STR052 //"TIPO DE CLIENTE INCORRETO/"
	     lInt:=.F.
	  EndIf 

	  If Valida_Cliente(Int_SC5->C5_CLIENTE) == ""
	     cLog := cLog + STR041 // "CLIENTE NAO CADASTRADO/"
	     lInt:=.F.
	  EndIf 

 	  If Valida_Pedido(Int_SC5->C5_NUM) <> ""
	     cLog := cLog + STR053 // "PEDIDO JA CONSTA NO SISTEMA/"
	     lInt:=.F.
	  EndIf 

	  If Alltrim(Int_SC5->C5_LOJACLI) == ""
	     cLog := cLog + STR054 // "LOJA CLIENTE INVALIDA/"
	     lInt:=.F.
	  EndIf                                             

      /*If SM0->M0_CODIGO=="48"	       
	     If Valida_Agencia(Int_SC5->C5_P_AGC) == ""
            cLog := cLog + "AGENCIA INVALIDA/"
         EndIf 
	    EndIf */
   EndIf

   If cTipo=="SC6"
      If Valida_Produto(Int_SC6->C6_PRODUTO) == ""
	     cLog := cLog + STR043 + AllTrim(Int_SC6->C6_PRODUTO) + STR044  // " PRODUTO ","NAO CADASTRADO / "
	     lInt:=.F.
	  EndIf 

	  If AllTrim(Int_SC6->C6_LOCAL) == ""
	     cLog := cLog + STR045 //"LOCAL NAO PREENCHIDO /"  
	     lInt:=.F.
	  EndIf

	  SA1->(DbSetOrder (1))
	  SA1->(DbSeek (xFilial("SA1")+Int_SC5->C5_CLIENTE+Int_SC5->C5_LOJACLI))
	  If (SA1->A1_EST <> SM0->M0_ESTENT) .And. (AllTrim(SA1->A1_EST) <> "")
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+Int_SC6->C6_TES))
         If SubStr(Int_SC6->C6_CF, 1, 1) <> "6" .OR. Substr(SF4->F4_CF,2,3) <> Substr(Int_SC6->C6_CF,2,3)
            cLog := cLog + STR056 + AllTrim(Int_SC6->C6_PRODUTO) + STR057   // "CFOP DO ITEM "," INCORRETO /" 
            lInt:=.F.
         EndIf 
	  EndIf
	  If (Int_SC6->C6_QTDVEN * Int_SC6->C6_PRCVEN) <> Int_SC6->C6_VALOR
	     cLog := cLog + STR058 +  AllTrim(Int_SC6->C6_PRODUTO) + " /"   //"DIVERGENCIA NOS VALORES DO PRODUTO "
	     lInt:=.F.
	  EndIf
   EndIf

   If cTipo=="CT2"
      If Valida_CT2(Int_CT2->CT2_DATA,Int_CT2->CT2_LOTE,Int_CT2->CT2_SBLOTE,Int_CT2->CT2_DOC,Int_CT2->CT2_LINHA) <> ""
	     cLog += cLog + "LACTO JA CONSTA NO SISTEMA / "
	     lInt:=.F.
	  EndIf  
	   	  	  
	  If Empty(Int_CT2->CT2_DC) .Or. !(Int_CT2->CT2_DC $ "1/2/3") 
	     If !(cLog $ "LACTO JA CONSTA NO SISTEMA / ")
	        cLog +="TIPO LANCAMENTO INVALIDO / "   
	     EndIf   
	     lInt:=.F.	  
	  EndIf  
	  
	  If Valida_CONTA(Int_CT2->CT2_DEBITO,Int_CT2->CT2_CREDITO) == ""
	     If !(cLog $ "CONTA INVALIDA / ")
	        cLog +="CONTA INVALIDA / "  
	     EndIf   
	     lInt:=.F.
	  EndIf  

	  //DEBITO	  	            	 	  
	  If Int_CT2->CT2_DC=="1" 
	     	     
	     If Empty(Int_CT2->CT2_DEBITO)  
	        cLog +="CONTA DEBITO NAO PREENCHIDA /"
	        lInt:=.F.  	           
	     ElseIf !Empty(Int_CT2->CT2_CREDITO)  
	        cLog +="CONTA CREDITO NAO PODE SER PREENCHIDA PARA TIPO 1 /"
	        lInt:=.F.	     
	     EndIf 
	     
	     If !Empty(Int_CT2->CT2_CCC) //Valida o Credito  
	        cLog +="CENTRO DE CUSTO INFORMADO NO CREDITO /"
	        lInt:=.F.	     
	     EndIf 
	  
	  EndIf
	  
	  //CREDITO
	  If Int_CT2->CT2_DC=="2"
	  
	     If Empty(Int_CT2->CT2_CREDITO)  
	        cLog +="CONTA CREDITO NAO PREENCHIDA/"
	        lInt:=.F.	           
	     ElseIf !Empty(Int_CT2->CT2_DEBITO)  
	        cLog +="CONTA DEBITO NAO PODE SER PREENCHIDA PARA TIPO 2/"
	        lInt:=.F.	     
	     EndIf 
	     
	     If !Empty(Int_CT2->CT2_CCD) //Valida o debito 
	        cLog +="CENTRO DE CUSTO INFORMADO NO DEBITO /"
	        lInt:=.F.	     
	     EndIf 

	  EndIf
	  
	  //PARTIDA DOBRADA
	  If Int_CT2->CT2_DC=="3"
	  
	     If Empty(Int_CT2->CT2_CREDITO)  
	        cLog +="CONTA CREDITO NAO PREENCHIDA/"
	        lInt:=.F.	           
	     ElseIf Empty(Int_CT2->CT2_DEBITO)  
	        cLog +="CONTA DEBITO NAO PREENCHIDA/"
	        lInt:=.F.	     
	     EndIf
	  EndIf     
	     
	  If !Empty(Int_CT2->CT2_CCD)  // Nao é necessario validar CREDITO ou DEBITO
	     If Valida_CentroC(Int_CT2->CT2_CCD,"1") == ""  
	        cLog +="CENTRO CUSTO NAO EXISTE /"
	        lInt:=.F.
	     EndIf           
	  Else
         If !Empty(Int_CT2->CT2_CCC) // Nao é necessario validar CREDITO ou DEBITO
	        If Valida_CentroC(Int_CT2->CT2_CCC,"2") == ""  
	           cLog +="CENTRO CUSTO NAO EXISTE /"
	           lInt:=.F.
	        EndIf 
	     EndIf                
	  EndIf
	     
	  //Regras Discovery 
	  If cEmpAnt $  ("48/49/50")  
	     If Empty(Int_CT2->CT2_P_CODE) 
	        cLog += cLog + "COMPANY CODE INVALIDO / "
	        lInt:=.F.	  
	     EndIf
	  
         //DEBITO 
	     If Int_CT2->CT2_DC=="1"
	     
	        If !Empty(Int_CT2->CT2_CCD)
	     
	           CTT->(DbSetOrder(1))
	           
	           If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCD))
	              cObrgItemC  :=CTT->CTT_ITOBRG      
	              cObrClassC  :=CTT->CTT_CLOBRG 	     
	           EndIf  
	        Else   
	           //Se não encontrar o Debito, procura o credito  /
	           CTT->(DbSetOrder(1))
	           If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCC))
	              cObrgItemD  :=CTT->CTT_ITOBRG      
	              cObrClassD  :=CTT->CTT_CLOBRG 	     
	           EndIf 
	        EndIf 
	     
	     
	        If cObrItemD=="1"
	           If Empty(Int_CT2->CT2_ITEMD)
	              cLog +="CANAL-ITEM CONTABIL OBRIGATORIO, CC: "+Alltrim(Int_CT2->CT2_CCD)+" "+Alltrim(Int_CT2->CT2_CCC)+" /" 
	              lInt:=.F.
	           Else 
	              If Valida_ItemC(Int_CT2->CT2_ITEMD,"1") ==""
	                 cLog +="CANAL-ITEM CONTABIL DEBITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_ITEMD)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        ElseIf !Empty(Int_CT2->CT2_ITEMC) // Valida o Credito 
	           cLog +="CANAL-ITEM CONTABIL PREENCHIDO NO CREDITO / "
	           lInt:=.F.
	        ElseIf !Empty(Int_CT2->CT2_ITEMD) // Valida o Debito caso não seja obrigatorio
	           If Valida_ItemC(Int_CT2->CT2_ITEMD,"1") == ""
	              cLog +="CANAL-ITEM CONTABIL DEBITO INVALIDO : "+Alltrim(Int_CT2->CT2_ITEMD)+" /" 
	              lInt:=.F.
	           EndIf   	     
	        EndIf   

	     
	        If cObrClassD=="1"
	           If Empty(Int_CT2->CT2_CLVLDB)
	              cLog +="PLATAFORMA-CLASSE VLR OBRIGATORIO, CC: "+Alltrim(Int_CT2->CT2_CCD)+" "+Alltrim(Int_CT2->CT2_CCC)+" /" 
	              lInt:=.F.
	           Else 
	              If Valida_ClassV(Int_CT2->CT2_CLVLDB,"1") ==""
	                 cLog +="PLATAFORMA-CLASSE VLR DEBITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_CLVLDB)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        ElseIf !Empty(Int_CT2->CT2_CLVLCR)  // Valida o Credito  
	           cLog +="PLATAFORMA-CLASSE VLR. PREENCHIDO NO CREDITO  /"   
	           lInt:=.F.	        
	        ElseIf !Empty(Int_CT2->CT2_CLVLDB)  // Valida o Debito
	           If Valida_ClassV(Int_CT2->CT2_CLVLDB,"1") == ""
	              cLog +="PLATAFORMA-CLASSE VLR. DEBITO INVALIDO : "+Alltrim(Int_CT2->CT2_CLVLDB)+" /"   
	              lInt:=.F. 
	           EndIf    
	        EndIf	     
	     
	     EndIf  
	  
	     // CREDITO 
	     If Int_CT2->CT2_DC=="2"
	     
	        CTT->(DbSetOrder(1))
	        If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCC))
	           cObrItemC  :=CTT->CTT_ITOBRG	       
	           cObrClassC :=CTT->CTT_CLOBRG     
	        EndIf 
	     
	        //Se não encontrar o Credito, procura o debito.
	        If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCD))
	           cObrgItemD  :=CTT->CTT_ITOBRG       
	           cObrClassD  :=CTT->CTT_CLOBRG	     
	        EndIf
	     
	        If cObrItemC=="1"
	           If Empty(Int_CT2->CT2_ITEMC)
	              cLog +="CANAL-ITEM CONTABIL OBRIGATORIO, CC: "+Alltrim(Int_CT2->CT2_CCD)+" "+Alltrim(Int_CT2->CT2_CCC)+" /" 
	              lInt:=.F.
	           Else 
	              If Valida_ItemC(Int_CT2->CT2_ITEMC,"2") ==""
	                 cLog +="CANAL-ITEM CONTABIL CREDITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_ITEMC)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        ElseIf !Empty(Int_CT2->CT2_ITEMD) // Valida o debito 
	           cLog +="CANAL-ITEM CONTABIL PREENCHIDO NO DEBITO / "
	           lInt:=.F.
	        ElseIf !Empty(Int_CT2->CT2_ITEMC) // Valida o credito caso não seja obrigatorio
	           If Valida_ItemC(Int_CT2->CT2_ITEMC,"1") == ""
	              cLog +="CANAL-ITEM CONTABIL DEBITO INVALIDO : "+Alltrim(Int_CT2->CT2_ITEMC)+" /" 
	              lInt:=.F.
	           EndIf   	     
	        EndIf    
	 	     
	     
	        If cObrClassC=="1"
	           If Empty(Int_CT2->CT2_CLVLCR)
	              cLog +="PLATAFORMA-CLASSE VLR OBRIGATORIO, CC: "+Alltrim(Int_CT2->CT2_CCD)+" "+Alltrim(Int_CT2->CT2_CCC)+" /" 
	              lInt:=.F.
	           Else 
	              If Valida_ClassV(Int_CT2->CT2_CLVLCR,"2") ==""
	                 cLog +="PLATAFORMA-CLASSE VLR CREDITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_CLVLCR)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        ElseIf !Empty(Int_CT2->CT2_CLVLDB)  // Valida o Debito  
	           cLog +="PLATAFORMA-CANAL/CLASSE VLR. PREENCHIDO NO CREDITO /"   
	           lInt:=.F.	        
	        ElseIf !Empty(Int_CT2->CT2_CLVLCR)  // Valida o Credito
	           If Valida_ClassV(Int_CT2->CT2_CLVLCR,"1") == ""
	              cLog +="PLATAFORMA-CANAL/CLASSE VLR. DEBITO INVALIDO : "+Alltrim(Int_CT2->CT2_CLVLCR)+" /"   
	              lInt:=.F. 
	           EndIf    
	        EndIf
	     
	     EndIf   
	  
	     //PARTIDA DOBRADA
	     If Int_CT2->CT2_DC=="3"
	      	           
	        CTT->(DbSetOrder(1))
	        If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCD))
	           cObrItemD  :=CTT->CTT_ITOBRG	       
	           cObrClassD :=CTT->CTT_CLOBRG  	     
	        EndIf 
	     
	        CTT->(DbSetOrder(1))
	        If CTT->(DbSeek(xFilial("CTT")+Int_CT2->CT2_CCC))
	           cObrItemC  :=CTT->CTT_ITOBRG	       
	           cObrClassC :=CTT->CTT_CLOBRG  	     
	        EndIf
	     
	        If cObrItemD=="1" .Or. cObrItemC=="1"
	           If Empty(Int_CT2->CT2_ITEMD) .Or. Empty(Int_CT2->CT2_ITEMC)
	              cLog +="CANAL-ITEM CONTABIL OBRIGATORIO, CD: "+Alltrim(Int_CT2->CT2_CCD)+", CC: "+Alltrim(Int_CT2->CT2_CCD)+" /"  
	              lInt:=.F.
	           Else  
	              If Valida_ItemC(Int_CT2->CT2_ITEMD,"1") ==""                                        
	                 cLog +="CANAL-ITEM CONTABIL DEBITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_ITEMD)+" /"
	                 lInt:=.F.
	              EndIf
	              If Valida_ItemC(Int_CT2->CT2_ITEMC,"2") ==""
	                 cLog +="CANAL-ITEM CONTABIL CREDITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_ITEMC)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        EndIF       
	     
	        If cObrClassD=="1" .Or. cObrClassC=="1"
	           If Empty(Int_CT2->CT2_CLVLDB) .Or. Empty(Int_CT2->CT2_CLVLCR)
	              cLog +="PLATAFORMA-CLASSE VLR OBRIGATORIO, CD: "+Alltrim(Int_CT2->CT2_CCD)+", CC: "+Alltrim(Int_CT2->CT2_CCD)+" /" 
	              lInt:=.F.
	           Else 
	              If Valida_ClassV(Int_CT2->CT2_CLVLDB,"1") ==""
	                 cLog +="PLATAFORMA-CLASSE VLR DEBITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_CLVLDB)+" /"
	                 lInt:=.F.
	              EndIf 
	              If Valida_ClassV(Int_CT2->CT2_CLVLCR,"2") ==""
	                 cLog +="PLATAFORMA-CLASSE VLR CREDITO NAO EXISTE : "+Alltrim(Int_CT2->CT2_CLVLCR)+" /"
	                 lInt:=.F.
	              EndIf
	           EndIf       
	        EndIF
	         
	     Endif 
	     
	  EndIf
	 	  
	  If Empty(Int_CT2->CT2_VALOR)
	     cLog +="VALOR INVALIDO/"
	  EndIf 
	  
	  If LEN(Int_CT2->CT2_LINHA) < 3
	     cLog +="TAMANHO DA SEQ. LANCTO INVALIDO/"
	  EndIf
   
   EndIf
   
   	If cTipo == "XML_PNF"
		If cTipoNF $ "B|D" //Devolução ou beneficiamento.
			//Verifica se o cliente está cadastrado na base de dados.
			SA1->(DbSetOrder(3))
			If !SA1->(DbSeek(xFilial("SA1")+AllTrim(cCNPJ)))
				cLog += "O cliente com o CNPJ "+AllTrim(cCNPJ)+" não está cadastrado."+CRLF
			EndIf
	
		Else	
			//Verifica se o fornecedor está cadastrado na base de dados.
			SA2->(DbSetOrder(3))
			If !SA2->(DbSeek(xFilial("SA2")+AllTrim(cCNPJ)))
				cLog += "O fornecedor com o CNPJ "+AllTrim(cCNPJ)+" não está cadastrado."+CRLF
			EndIf
		EndIf
    
		//Verifica se os produtos estão cadastrados na base.     
		
		SB1->(DbSetOrder(1))
		If nSelec == 11     

 			If !(SB1->(DbSeek(xFilial("SB1")+cProd))) 
 		   		cLog += "O produto "+ alltrim(cProd) +" não está cadastrado."+CRLF
 			EndIf
 		
		Else
			For nX := 1 To Len(aProd)
				If !SB1->(DbSeek(xFilial("SB1")+AllTrim(aProd[nX][1])))
	
					//Verifica se o produto está cadastrado com o código de referencia do cliente.
					SA5->(DbSetOrder(5))
					If SA5->(DbSeek(xFilial("SA5")+AllTrim(aProd[nX][1])))
		    	    	aProd[nX][1] := SA5->A5_PRODUTO
		        	Else	
			        	cLog += "O produto "+ AllTrim(aProd[nX][1]) +" do item " + AllTrim(Str(nX)) +" não está cadastrado."+CRLF
					EndIf
			
				EndIf
			Next  	   
	        
  		EndIf	
   EndIf
  
   If cTipo == "XML_PV"
   
      //Verifica se o cliente está cadastrado na base de dados.
      SA1->(DbSetOrder(3))
      If !SA1->(DbSeek(xFilial("SA1")+AllTrim(cCNPJ)))
         cLog += "O cliente com o CNPJ "+AllTrim(cCNPJ)+" não está cadastrado."+CRLF
      EndIf

      //Verifica se os produtos estão cadastrados na base.
      For nX := 1 To Len(aProd)
         SB1->(DbSetOrder(1))
         If !SB1->(DbSeek(xFilial("SB1")+AllTrim(aProd[nX][1])))
            cLog += "O produto "+ AllTrim(aProd[nX][1]) +" do item " + AllTrim(Str(nX)) +" não está cadastrado."+CRLF
         EndIf
      Next  	   

   EndIf 
   
   
Return AllTrim(cLog)            

/*
Funcao      : Grava_Pedido
Objetivos   : Grava os dados do arquivo
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*---------------------------------*
Static Function Grava_Pedido(cTipo)
*---------------------------------*
Local lOk:=.F.
Local lRet:=.F.
Local i := 0

If cTipo=="CT2"  
   DbSelectArea("CT2")
   CT2->(DbSetOrder(1))
   Int_CT2->(dbGotop()) 
   
   While Int_CT2->(!Eof())                         
      IF (AllTrim(Int_CT2->cINTEGRA) <> "") .And. (AllTrim(Int_CT2->CT2Status) $ Alltrim(STR021))
         MsgStop(STR034,STR017) // "Existe pedido(s) recusado(s) marcado(s), verifique a mensagem","Atenção" 
         Return .F.
      EndIf 
      
      If  AllTrim(Int_CT2->cINTEGRA) == ""  
         MsgStop("Existem itens desmarcados, todos devem estar marcados",STR061)       
         Return .F.
      EndIf          
      
      Int_CT2->(DbSkip())   
   EndDo     
     
   If Empty(cMoeda)
      MsgStop("Moeda deve ser preenchido",STR061) 
      Int_CT2->(dbGotop())
      Return .F.  
   EndIf 
              
   lRet:=SomaLanc()
         
   If !(lRet)
      MsgStop("Existe digergência entre credito e debito",STR061) 
      Return .F.      
   EndIf

   Int_CT2->(dbGotop()) 
   While !Int_CT2->(Eof())
      If (AllTrim(Int_CT2->cINTEGRA) <> "") .And. !(AllTrim(Int_CT2->CT2Status) $ Alltrim(STR021) )		  
         If !CT2->(DbSeek(xFilial("CT2")+DTOS(Int_CT2->CT2_DATA)+Int_CT2->CT2_LOTE+Int_CT2->CT2_SBLOTE+Int_CT2->CT2_DOC+Int_CT2->CT2_LINHA+;
                                        Int_CT2->CT2_TPSALD+Int_CT2->CT2_EMPORI+Int_CT2->CT2_FILORI+Int_CT2->CT2_MOEDLC)) 

		    If Alltrim(cMoeda) == "Ambas"                
		       // Moeda 01
		       RecLock("CT2",.T.)		    
			   CT2->CT2_FILIAL  := xFilial("CT2")
			   CT2->CT2_DATA    := Int_CT2->CT2_DATA      
			   CT2->CT2_LOTE    := Int_CT2->CT2_LOTE    
			   CT2->CT2_SBLOTE  := Int_CT2->CT2_SBLOTE  
			   CT2->CT2_DOC     := Int_CT2->CT2_DOC     
			   CT2->CT2_LINHA   := Int_CT2->CT2_LINHA
			   CT2->CT2_MOEDLC  := "01"  
			   CT2->CT2_DC      := Int_CT2->CT2_DC    
			   CT2->CT2_DEBITO  := Int_CT2->CT2_DEBITO 
			   CT2->CT2_CREDIT  := Int_CT2->CT2_CREDIT  
			   CT2->CT2_VALOR   := Int_CT2->CT2_VALOR   
			   CT2->CT2_HIST    := Int_CT2->CT2_HIST   
			   CT2->CT2_CCD     := Int_CT2->CT2_CCD     
			   CT2->CT2_CCC     := Int_CT2->CT2_CCC     
			   CT2->CT2_ITEMD   := Int_CT2->CT2_ITEMD 
			   CT2->CT2_ITEMC   := Int_CT2->CT2_ITEMC   
			   CT2->CT2_CLVLDB  := Int_CT2->CT2_CLVLDB 
			   CT2->CT2_CLVLCR  := Int_CT2->CT2_CLVLCR 
			   If cEmpAnt $  ("48/49/50")
			      CT2->CT2_P_PROJ  := Int_CT2->CT2_P_PROJ   
			      CT2->CT2_P_GEOG  := Int_CT2->CT2_P_GEOG  
			      CT2->CT2_P_CODE  := Int_CT2->CT2_P_CODE 
			   EndIf
			   CT2->CT2_AGLUT   :=Int_CT2->CT2_AGLUT  
			   CT2->CT2_DATATX  :=Int_CT2->CT2_DATATX 
			   CT2->CT2_TAXA    :=Int_CT2->CT2_TAXA   
			   CT2->CT2_ORIGEM  :="INTEGRACAO - "+Alltrim(cUserName)
			   CT2->CT2_ROTINA  :="INTPRYOR"  
			   CT2->CT2_SEQLAN  :=Int_CT2->CT2_LINHA   
			   CT2->CT2_EMPORI  :=Alltrim(cEmpAnt)
			   CT2->CT2_FILORI  :=CT2->CT2_FILIAL 
			   //CT2->CT2_P_ARQ   :=Int_CT2->CT2_P_ARQ
			   CT2->CT2_TPSALD  :="1"   
               CT2->CT2_AGLUT   :="2" 
               CT2->CT2_LP      :="INT"  
               CT2->CT2_SEQHIS  :="001"   
               CT2->CT2_CRCONV  :="1"
               Int_CT2->(MsUnlock())   
               
               //Moeda 04
		       RecLock("CT2",.T.)		    
			   CT2->CT2_FILIAL  := xFilial("CT2")
			   CT2->CT2_DATA    := Int_CT2->CT2_DATA      
			   CT2->CT2_LOTE    := Int_CT2->CT2_LOTE    
			   CT2->CT2_SBLOTE  := Int_CT2->CT2_SBLOTE  
			   CT2->CT2_DOC     := Int_CT2->CT2_DOC     
			   CT2->CT2_LINHA   := Int_CT2->CT2_LINHA 
			   CT2->CT2_MOEDLC  := "04"  
			   CT2->CT2_DC      := Int_CT2->CT2_DC    
			   CT2->CT2_DEBITO  := Int_CT2->CT2_DEBITO 
			   CT2->CT2_CREDIT  := Int_CT2->CT2_CREDIT  
			   CT2->CT2_VALOR   := Int_CT2->CT2_VALOR   
			   CT2->CT2_HIST    := Int_CT2->CT2_HIST   
			   CT2->CT2_CCD     := Int_CT2->CT2_CCD     
			   CT2->CT2_CCC     := Int_CT2->CT2_CCC     
			   CT2->CT2_ITEMD   := Int_CT2->CT2_ITEMD 
			   CT2->CT2_ITEMC   := Int_CT2->CT2_ITEMC   
			   CT2->CT2_CLVLDB  := Int_CT2->CT2_CLVLDB 
			   CT2->CT2_CLVLCR  := Int_CT2->CT2_CLVLCR 
			   If cEmpAnt $  ("48/49/50")
			      CT2->CT2_P_PROJ  := Int_CT2->CT2_P_PROJ   
			      CT2->CT2_P_GEOG  := Int_CT2->CT2_P_GEOG  
			      CT2->CT2_P_CODE  := Int_CT2->CT2_P_CODE 
			   EndIf
			   CT2->CT2_AGLUT   :=Int_CT2->CT2_AGLUT  
			   CT2->CT2_DATATX  :=Int_CT2->CT2_DATATX 
			   CT2->CT2_TAXA    :=Int_CT2->CT2_TAXA   
			   CT2->CT2_ORIGEM  :="INTEGRACAO - "+Alltrim(cUserName)
			   CT2->CT2_ROTINA  :="INTPRYOR"  
			   CT2->CT2_SEQLAN  :=Int_CT2->CT2_LINHA   
			   CT2->CT2_EMPORI  :=Alltrim(cEmpAnt)
			   CT2->CT2_FILORI  :=CT2->CT2_FILIAL
			   //CT2->CT2_P_ARQ   :=Int_CT2->CT2_P_ARQ
			   CT2->CT2_TPSALD  :="1"   
               CT2->CT2_AGLUT   :="2" 
               CT2->CT2_LP      :="INT"  
               CT2->CT2_SEQHIS  :="001" 
               CT2->CT2_CRCONV  :="1"
               Int_CT2->(MsUnlock())   
                  
               lOk:=.T.  
               SX6->(DbSetOrder(1))
               If SX6->(DbSeek(XFilial()+"MV_P_CT2DC")) 
                  RecLock("SX6",.F.)
                  SX6->X6_CONTEUD := StrZero(nDocSeq,6,0)  
                  SX6->(MsUnlock())
               EndIf
            
            ElseIf Alltrim(cMoeda) == "01"
		       // Moeda 01
		       RecLock("CT2",.T.)		    
			   CT2->CT2_FILIAL  := xFilial("CT2")
			   CT2->CT2_DATA    := Int_CT2->CT2_DATA      
			   CT2->CT2_LOTE    := Int_CT2->CT2_LOTE    
			   CT2->CT2_SBLOTE  := Int_CT2->CT2_SBLOTE  
			   CT2->CT2_DOC     := Int_CT2->CT2_DOC     
			   CT2->CT2_LINHA   := Int_CT2->CT2_LINHA
			   CT2->CT2_MOEDLC  := "01"  
			   CT2->CT2_DC      := Int_CT2->CT2_DC    
			   CT2->CT2_DEBITO  := Int_CT2->CT2_DEBITO 
			   CT2->CT2_CREDIT  := Int_CT2->CT2_CREDIT  
			   CT2->CT2_VALOR   := Int_CT2->CT2_VALOR   
			   CT2->CT2_HIST    := Int_CT2->CT2_HIST   
			   CT2->CT2_CCD     := Int_CT2->CT2_CCD     
			   CT2->CT2_CCC     := Int_CT2->CT2_CCC     
			   CT2->CT2_ITEMD   := Int_CT2->CT2_ITEMD 
			   CT2->CT2_ITEMC   := Int_CT2->CT2_ITEMC   
			   CT2->CT2_CLVLDB  := Int_CT2->CT2_CLVLDB 
			   CT2->CT2_CLVLCR  := Int_CT2->CT2_CLVLCR 
			   If cEmpAnt $  ("48/49/50")
			      CT2->CT2_P_PROJ  := Int_CT2->CT2_P_PROJ   
			      CT2->CT2_P_GEOG  := Int_CT2->CT2_P_GEOG  
			      CT2->CT2_P_CODE  := Int_CT2->CT2_P_CODE 
			   EndIf
			   CT2->CT2_AGLUT   :=Int_CT2->CT2_AGLUT  
			   CT2->CT2_DATATX  :=Int_CT2->CT2_DATATX 
			   CT2->CT2_TAXA    :=Int_CT2->CT2_TAXA   
			   CT2->CT2_ORIGEM  :="INTEGRACAO - "+Alltrim(cUserName)
			   CT2->CT2_ROTINA  :="INTPRYOR"  
			   CT2->CT2_SEQLAN  :=Int_CT2->CT2_LINHA   
			   CT2->CT2_EMPORI  :=Alltrim(cEmpAnt)
			   CT2->CT2_FILORI  :=CT2->CT2_FILIAL 
			   //CT2->CT2_P_ARQ   :=Int_CT2->CT2_P_ARQ
			   CT2->CT2_TPSALD  :="1"   
               CT2->CT2_AGLUT   :="2" 
               CT2->CT2_LP      :="INT"  
               CT2->CT2_SEQHIS  :="001"   
               CT2->CT2_CRCONV  :="1"
               Int_CT2->(MsUnlock())   
                                 
               lOk:=.T.  
               SX6->(DbSetOrder(1))
               If SX6->(DbSeek(XFilial()+"MV_P_CT2DC")) 
                  RecLock("SX6",.F.)
                  SX6->X6_CONTEUD := StrZero(nDocSeq,6,0)  
                  SX6->(MsUnlock())
               EndIf            
            
            ElseIf Alltrim(cMoeda) == "04"  
               // Moeda 01
		       RecLock("CT2",.T.)		    
			   CT2->CT2_FILIAL  := xFilial("CT2")
			   CT2->CT2_DATA    := Int_CT2->CT2_DATA      
			   CT2->CT2_LOTE    := Int_CT2->CT2_LOTE    
			   CT2->CT2_SBLOTE  := Int_CT2->CT2_SBLOTE  
			   CT2->CT2_DOC     := Int_CT2->CT2_DOC     
			   CT2->CT2_LINHA   := Int_CT2->CT2_LINHA
			   CT2->CT2_MOEDLC  := "01"  
			   CT2->CT2_DC      := Int_CT2->CT2_DC    
			   CT2->CT2_DEBITO  := Int_CT2->CT2_DEBITO 
			   CT2->CT2_CREDIT  := Int_CT2->CT2_CREDIT  
			   CT2->CT2_VALOR   := 0  
			   CT2->CT2_HIST    := Int_CT2->CT2_HIST   
			   CT2->CT2_CCD     := Int_CT2->CT2_CCD     
			   CT2->CT2_CCC     := Int_CT2->CT2_CCC     
			   CT2->CT2_ITEMD   := Int_CT2->CT2_ITEMD 
			   CT2->CT2_ITEMC   := Int_CT2->CT2_ITEMC   
			   CT2->CT2_CLVLDB  := Int_CT2->CT2_CLVLDB 
			   CT2->CT2_CLVLCR  := Int_CT2->CT2_CLVLCR 
			   If cEmpAnt $  ("48/49/50")
			      CT2->CT2_P_PROJ  := Int_CT2->CT2_P_PROJ   
			      CT2->CT2_P_GEOG  := Int_CT2->CT2_P_GEOG  
			      CT2->CT2_P_CODE  := Int_CT2->CT2_P_CODE 
			   EndIf
			   CT2->CT2_AGLUT   :=Int_CT2->CT2_AGLUT  
			   CT2->CT2_DATATX  :=Int_CT2->CT2_DATATX 
			   CT2->CT2_TAXA    :=Int_CT2->CT2_TAXA   
			   CT2->CT2_ORIGEM  :="INTEGRACAO - "+Alltrim(cUserName)
			   CT2->CT2_ROTINA  :="INTPRYOR"  
			   CT2->CT2_SEQLAN  :=Int_CT2->CT2_LINHA   
			   CT2->CT2_EMPORI  :=Alltrim(cEmpAnt)
			   CT2->CT2_FILORI  :=CT2->CT2_FILIAL 
			   //CT2->CT2_P_ARQ   :=Int_CT2->CT2_P_ARQ
			   CT2->CT2_TPSALD  :="1"   
               CT2->CT2_AGLUT   :="2" 
               CT2->CT2_LP      :="INT"  
               CT2->CT2_SEQHIS  :="001"   
               CT2->CT2_CRCONV  :="5"
               
               Int_CT2->(MsUnlock())   
               //Moeda 04
		       RecLock("CT2",.T.)		    
			   CT2->CT2_FILIAL  := xFilial("CT2")
			   CT2->CT2_DATA    := Int_CT2->CT2_DATA      
			   CT2->CT2_LOTE    := Int_CT2->CT2_LOTE    
			   CT2->CT2_SBLOTE  := Int_CT2->CT2_SBLOTE  
			   CT2->CT2_DOC     := Int_CT2->CT2_DOC     
			   CT2->CT2_LINHA   := Int_CT2->CT2_LINHA 
			   CT2->CT2_MOEDLC  := "04"  
			   CT2->CT2_DC      := Int_CT2->CT2_DC    
			   CT2->CT2_DEBITO  := Int_CT2->CT2_DEBITO 
			   CT2->CT2_CREDIT  := Int_CT2->CT2_CREDIT  
			   CT2->CT2_VALOR   := Int_CT2->CT2_VALOR   
			   CT2->CT2_HIST    := Int_CT2->CT2_HIST   
			   CT2->CT2_CCD     := Int_CT2->CT2_CCD     
			   CT2->CT2_CCC     := Int_CT2->CT2_CCC     
			   CT2->CT2_ITEMD   := Int_CT2->CT2_ITEMD 
			   CT2->CT2_ITEMC   := Int_CT2->CT2_ITEMC   
			   CT2->CT2_CLVLDB  := Int_CT2->CT2_CLVLDB 
			   CT2->CT2_CLVLCR  := Int_CT2->CT2_CLVLCR 
			   If cEmpAnt $  ("48/49/50")
			      CT2->CT2_P_PROJ  := Int_CT2->CT2_P_PROJ   
			      CT2->CT2_P_GEOG  := Int_CT2->CT2_P_GEOG  
			      CT2->CT2_P_CODE  := Int_CT2->CT2_P_CODE 
			   EndIf
			   CT2->CT2_AGLUT   :=Int_CT2->CT2_AGLUT  
			   CT2->CT2_DATATX  :=Int_CT2->CT2_DATATX 
			   CT2->CT2_TAXA    :=Int_CT2->CT2_TAXA   
			   CT2->CT2_ORIGEM  :="INTEGRACAO - "+Alltrim(cUserName)
			   CT2->CT2_ROTINA  :="INTPRYOR"  
			   CT2->CT2_SEQLAN  :=Int_CT2->CT2_LINHA   
			   CT2->CT2_EMPORI  :=Alltrim(cEmpAnt)
			   CT2->CT2_FILORI  :=CT2->CT2_FILIAL
			   //CT2->CT2_P_ARQ   :=Int_CT2->CT2_P_ARQ
			   CT2->CT2_TPSALD  :="1"   
               CT2->CT2_AGLUT   :="2" 
               CT2->CT2_LP      :="INT"  
               CT2->CT2_SEQHIS  :="001" 
               CT2->CT2_CRCONV  :="4"
               Int_CT2->(MsUnlock())   
                  
               lOk:=.T.  
               SX6->(DbSetOrder(1))
               If SX6->(DbSeek(XFilial()+"MV_P_CT2DC")) 
                  RecLock("SX6",.F.)
                  SX6->X6_CONTEUD := StrZero(nDocSeq,6,0)  
                  SX6->(MsUnlock())
               EndIf
            EndIf
         EndIf                
      EndIf         
      Int_CT2->(DbSkip())
   EndDo
EndIf               

If lOk
   MsgAlert(STR031,STR017) //"Importação Finalizada","Atenção"
   oDlg:End()      
Else
   MsgAlert(STR032,STR017)  //"Nenhum dado importado","Atenção"
   If cTipo=="CT2"
      Int_CT2->(DbGoTop())
      MsgAlert("Necessário reprocessar.",STR061)
   EndIf
EndIf

Return .F.    

/*
Funcao      : SomaLanc()
Objetivos   : Totaliza os lançamentos
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 07/12/2009
*/       
*------------------------*
Static Function SomaLanc()
*------------------------* 
Local nSomaCred:=nSomaDeb:=0  
Local oMain, oDlg  
Local lRet:=.T.
  
   DbSelectArea("Int_CT2")
   Int_CT2->(DbSetOrder(1))
   Int_CT2->(dbGotop()) 
   While Int_CT2->(!Eof())
      
      If Int_CT2->CT2_DC=='1'
         nSomaCred+=Int_CT2->CT2_VALOR
      ElseIf Int_CT2->CT2_DC=='2'
         nSomaDeb+=Int_CT2->CT2_VALOR  
      EndIf
      
     Int_CT2->(DbSkip())      
  EndDo      
   
  DEFINE MSDIALOG oDlg TITLE "Previa Debito x Credito " From 1,7 To 14,35 OF oMain  
  
     @ 010,010  TO 55,105 LABEL "" OF oDlg PIXEL   
     @ 020,015 Say "TOTAL DEBITO"  PIXEL SIZE 80,6 OF oDlg  
     @ 020,060 Say nSomaDeb        Picture "@E 9,999,999,999.99"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg 
     @ 035,015 Say "TOTAL CREDITO" PIXEL SIZE 80,6 OF oDlg 
     @ 035,060 Say nSomaCred       Picture "@E 9,999,999,999.99"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg 
     @ 065,010  TO 85, 105 LABEL "" OF oDlg PIXEL   
     @ 070,015 Say "DIFERENCA"     PIXEL SIZE 80,6 OF oDlg 
     @ 070,060 Say 	nSomaDeb-nSomaCred  Picture "@E 9,999,999,999.99"   COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg 
     
  ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())         
  
  Int_CT2->(DbGoTop())     
  
  If nSomaDeb-nSomaCred <> 0
     lRet:=.F.
  EndIf   
         

Return lRet

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

//Valida Local
*---------------------------------------*
Static Function Valida_Local(cCod,cLocal)    
*---------------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT B2_LOCAL "+Chr(10)
cQuery += " FROM "+RetSqlName("SB2")+Chr(10)
cQuery += " WHERE B2_LOCAL = '"+cLocal+"'"+Chr(10) 
cQuery += " AND B2_COD = '"+cCod+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' AND  B2_FILIAL='"+xFilial("SB2")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return Alltrim(SQL->B2_LOCAL)

// Valida Numero do nota
*-------------------------------------*
Static Function Valida_NFE(cNFE,cSerie)
*-------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT F1_DOC "+Chr(10)
cQuery += " FROM "+RetSqlName("SF1")+Chr(10)
cQuery += " WHERE F1_DOC = '"+Alltrim(cNFE)+"'"+Chr(10)
cQuery += " AND F1_SERIE = '"+Alltrim(cSerie)+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' and F1_FILIAL='"+xFilial("SF1")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->F1_DOC)

//Busca Numero do Pedido   
*----------------------------------------*
Static Function BuscaCodPed(cFILIAL)
*----------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := "SELECT max(C5_NUM)+ 1 AS PEDIDO"+Chr(10)
cQuery += " FROM "+RetSqlName("SC5")+Chr(10)
cQuery += " WHERE patindex( '%[^0-9]%' , SUBSTRING(C5_NUM,1,6))=0 and left(C5_NUM,1)<>'9' AND C5_FILIAL ="+cFILIAL+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->PEDIDO

// Valida Numero do Pedido
*------------------------------------------* 
Static Function Valida_Pedido(cPedido)
*------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT C5_NUM "+Chr(10)
cQuery += " FROM "+RetSqlName("SC5")+Chr(10)
cQuery += " WHERE C5_NUM = '"+cPedido+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->C5_NUM)    
 
// Valida chave do Lcto
*---------------------------------------------------------------* 
Static Function Valida_CT2(dData,cLote,cSubLote,cDoc,cLinha)
*---------------------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT CT2_LOTE "+Chr(10)
cQuery += " FROM "+RetSqlName("CT2")+Chr(10)
cQuery += " WHERE CT2_DATA  = '"+Dtos(dData)+"'"+Chr(10)
cQuery += " AND CT2_LOTE    = '"+cLote+"'"+Chr(10)  
cQuery += " AND CT2_SBLOTE = '"+cSubLote+"'"+Chr(10)
cQuery += " AND CT2_DOC     = '"+cDoc+"'"+Chr(10)
cQuery += " AND CT2_LINHA   = '"+cLinha+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->CT2_LOTE)   

// Valida Conta Contabil
*-------------------------------------------------* 
Static Function Valida_CONTA(cCtaDeb,cCtaCred)
*-------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT CT1_CONTA "+Chr(10)
cQuery += " FROM "+RetSqlName("CT1")+Chr(10)
cQuery += " WHERE CT1_CONTA  = '"+cCtaDeb+"'"+Chr(10)
cQuery += " OR CT1_CONTA    = '"+cCtaCred+"'"+Chr(10)  
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->CT1_CONTA)

// Valida Centro de Custo
*-------------------------------------------------* 
Static Function Valida_CentroC(cCentroC,cTipo)
*-------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT CTT_CUSTO "+Chr(10)
cQuery += " FROM "+RetSqlName("CTT")+Chr(10)
cQuery += " WHERE CTT_CUSTO = '"+cCentroC+"'"+Chr(10)
//cQuery += " AND CTT_NORMAL='"+cTipo+"'"+Chr(10)    Não é necessário validar CREDIT ou DEBIT
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->CTT_CUSTO)  


// Valida Item contabil
*-------------------------------------------------* 
Static Function Valida_ItemC(cItemC,cTipo)
*-------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT CTD_ITEM "+Chr(10)
cQuery += " FROM "+RetSqlName("CTD")+Chr(10)
cQuery += " WHERE CTD_ITEM = '"+Alltrim(cItemc)+"'"+Chr(10)
//cQuery += " AND CTD_NORMAL='"+cTipo+"'"+Chr(10) //Não será validade Credito ou Debito
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->CTD_ITEM)
  
// Valida Classe Valor  Contabil
*-------------------------------------------------* 
Static Function   Valida_ClassV(cClassC,cTipo)
*-------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT CTH_CLVL "+Chr(10)
cQuery += " FROM "+RetSqlName("CTH")+Chr(10)
cQuery += " WHERE CTH_CLVL = '"+Alltrim(cClassC)+"'"+Chr(10)
//cQuery += " AND CTH_NORMAL='"+cTipo+"'"+Chr(10) //Não será validade Credito ou Debito
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->CTH_CLVL)
     
//Busca Numero de nota  
*----------------------------------------*
Static Function BuscaDoc(cFILIAL)
*----------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT max(F1_DOC)+ 1 AS DOC"+Chr(10)
cQuery += " FROM "+RetSqlName("SF1")+Chr(10)
cQuery += " WHERE F1_FILIAL='"+cFILIAL+"'"
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->DOC

/*
Funcao      : IntXmlPNF()
Parametros  : cArquivo: Arquivo XML de integração
Retorno     : Nil
Objetivos   : Integração do arquivo XML, gerando a Pre Nota de Entrada.
Autor       : Eduardo C. Romanini
Data/Hora   : 10/01/11 15:30
*/
*---------------------------------*
Static Function IntXmlPNF(cArquivo)
*---------------------------------*
Local lXml  := .T.
Local lCopy := .F. 
Local lRet  := .F.

Local cProd    := ""
Local cUM      := ""
Local cMsg     := ""  
Local cErro    := ""
Local cAviso   := ""

Local nAt    := 0
Local nX     := 0
Local nQtd   := 0
Local nUM    := 0
Local nVlUn  := 0
Local nVlTot := 0

Local aCabec := {}
Local aLinha := {}
Local aItens := {}

Local oXml

Private lMSErroAuto := .F.

Private cDoc     := ""
Private cSerie   := ""
Private cCNPJ    := ""
Private cEmissao := ""
Private cTipoNf  := "N"
Private cCodNFE  := ""
Private cChvNfe  := ""

Private aProd  := {}

//Verifica se o arquivo não está na raiz do ambiente.
If Substr(cArquivo,2,1) == ":" .or. Left(cArquivo,2) == "//"
      	
	//Verifica o nome do arquivo.
    cFile := cArquivo
	nAT   := 1
	For nX := 1 To Len(cArquivo)
		cFile := Substr(cFile,If(nX==1,nAt,nAt+1),Len(cFile))
		nAt := At("\",cFile)
		If nAt == 0
			Exit
		Endif
	Next nX
      	     	
	//Copia o arquivo para o diretorio raiz.
	CpyT2S(cArquivo,"\BKP")
	       	
	cArquivo := "\BKP\"+cFile
	lCopy := .T.
	
EndIf
        	
lXml := .T.
      	
//Leitura do XML
oXml :=  XmlParserFile(cArquivo,"_",@cErro,@cAviso)

If ( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)
	
	bError := ErrorBlock({|| lXml := .F.})     
	
	//TLM 25/05/2011 - Validar se a nota é valida no SEFAZ
	Processa({|| Validar(oXml)},"Integração Grant Thorton","Validando nota no Sefaz,aguarde ...",.F. ) 
		
	// Código 100 - Nota ok- transmitida
	If cCodNFE<>"100"
		Return .F.
	EndIf	
					
	Begin Sequence 
   		cDoc     := oXml:_NFeProc:_NFe:_infNFe:_ide:_nNf:TEXT
		cSerie   := oXml:_NFeProc:_NFe:_infNFe:_ide:_serie:TEXT 
		cChvNfe  := oXml:_NFeProc:_protNFe:_infProt:_chNFe:TEXT
				
 		cEmissao := oXml:_NFeProc:_NFe:_infNFe:_ide:_dEmi:TEXT
 		cEmissao := Left(cEmissao,4)+Substr(cEmissao,6,2)+Right(cEmissao,2)

		cCNPJ    := oXml:_NFeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT
 		
 		If ValType(oXml:_NFeProc:_NFe:_infNFe:_det) == "A"
 				
	 		For nX := 1 To Len(oXml:_NFeProc:_NFe:_infNFe:_det)
 				cProd  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_cProd:TEXT
 				nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_qCom:TEXT)
 				cUM    := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_uCom:TEXT
	 			nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vUnCom:TEXT)
 				nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vProd:TEXT)
 				cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:TEXT
 				
	 			aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP})
 			Next
 		Else

			cProd  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_cProd:TEXT
			nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_qCom:TEXT)
			cUM    := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_uCom:TEXT
 			nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vUnCom:TEXT)
			nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vProd:TEXT)
			cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_CFOP:TEXT
 				
			aAdd(aProd,{cProd,nQtd,cUM,nVlUn,nVlTot,cCFOP})
		
 		EndIf
 		
	End Sequence
	ErrorBlock(bError)

	//Trata o tipo da NF pelo CFOP.
	If AllTrim(aProd[1,6]) $ "6906|6907"
		cTipoNF := "B" //Beneficiamento
	ElseIf AllTrim(aProd[1,6]) $ "1202|2202|1401|2401"
		cTipoNF := "D" //Devolução
	Else
		cTipoNF := "N" //Normal		
	EndIf
	
	//Validações antes da integração
	cMsg := Validacoes("XML_PNF")
	
	//Exibir a mensagem de erro.
	If Len(cMsg) > 0
		ExibeMsg(cMsg)	

	Else
		
		//Monta os campos da capa da Pre-Nota de Entrada.
		aAdd(aCabec,{"F1_TIPO"   ,cTipoNF})
		aAdd(aCabec,{"F1_FORMUL" ,"N"})
		aAdd(aCabec,{"F1_DOC"    ,cDoc})
		aAdd(aCabec,{"F1_SERIE"  ,cSerie})
		aAdd(aCabec,{"F1_EMISSAO",StoD(cEmissao)})  
		aAdd(aCabec,{"F1_CHVNFE" ,cChvNfe})  
	   
		If  cTipoNF $ "B/D"       
		
			aAdd(aCabec,{"F1_FORNECE",SA1->A1_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA1->A1_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA1->A1_EST})
			
		Else             
		
			aAdd(aCabec,{"F1_FORNECE",SA2->A2_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA2->A2_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA2->A2_EST}) 
			
	    EndIf    
	    
		//Monta os campos de itens da Pre-Nota de Entrada.
		For nX := 1 To Len(aProd)
			aLinha := {}
			aAdd(aLinha,{"D1_COD"  ,aProd[nX][1],Nil})
			aAdd(aLinha,{"D1_QUANT",aProd[nX][2],Nil})
			aAdd(aLinha,{"D1_VUNIT",aProd[nX][4],Nil})
			aAdd(aLinha,{"D1_TOTAL",aProd[nX][5],Nil})
			aAdd(aLinha,{"D1_OBS"  ,"REF.DOC:"+AllTrim(cDoc)+"-"+AllTrim(cSerie),Nil})
			aAdd(aItens,aLinha)
		Next nX
        
    	//Exibe a previa da Pre-Nota de Entrada.
    	If ExibePreNF(@aCabec,@aItens)    
    
			//Gera a pre-nota de entrada.
			MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
		    
      		If lMSErroAuto           
         		MostraErro()
         		Return .F.
      		Else
      			MsgInfo("A pre nota de entrada foi gerada.",STR061)
      		EndIf   
		
		EndIf

    EndIf

Else
	MsgInfo("Erro na leitura do arquivo XML: "+ AllTrim(cErro)+".",STR061)
	Return .F.

EndIf    

//Apaga o arquivo da raiz do ambiente
If lCopy
	If File(cArquivo)
		fErase(cArquivo)	
    EndIf
EndIf

Return 

/*
Funcao      : ExibeMsg()
Parametros  : cMsg: Mensagens de erro.
Retorno     : Nil
Objetivos   : Integração do arquivo XML, gerando a Pre Nota de Entrada.
Autor       : Eduardo C. Romanini
Data/Hora   : 11/01/11 13:30
*/
*----------------------------*
Static Function ExibeMsg(cMsg)
*----------------------------*
Local cTexto := ""
Local cMask := "Arquivos Texto (*.TXT) |*.txt|"

Local oFont
Local oDlg
Local oMemo

cTexto := "Foram encontradas divergencias na integração do arquivo." + CRLF + CRLF
cTexto += cMsg

Define FONT oFont NAME "Mono AS" Size 5,12
Define MsDialog oDlg Title "Log da Integração" From 3,0 to 340,417 Pixel

@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

Activate MsDialog oDlg Center

Return Nil       

/*
Funcao      : ExibePreNF()
Parametros  : aCabec : Campos da capa da pre nota 
	          aItens : Campos dos itens da pre nota
Retorno     : Nil
Objetivos   : Exibição da tela previa da integração. 
Autor       : Eduardo C. Romanini
Data/Hora   : 11/01/11 15:50
*/
*---------------------------------------*
Static Function ExibePreNF(aCabec,aItens)
*---------------------------------------*
Local lRet := .F.

Local cTitulo  := "Pre Nota de Entrada"
Local cOldDoc  := ""
Local cOldSer  := ""
Local cDesFor  := ""
Local cUf      := ""
Local cTpNota  := "" 

Local nPos  := 0
Local nX    := 0
Local nI    := 0

Local dEmissao

Local aAux     := {}
Local aButtons := {}
Local aHeader  := {}
Local aBrowse  := {}
Local aTiposNf := {}

Local bOK     := {|| If(VldPreNf(cDoc,cSerie,cForn,cLoja),(lRet := .T.,oDlg:End()),)}
Local bCancel := {|| lRet := .F.,oDlg:End()}

Local oDlg
Local oEnc
Local oBrw
Local oGtDoc
Local oGtSerie
Local oGtEmiss
Local oGtForn
Local oGtLoja
Local oGtDesFor
Local oLsTp

Private cDoc     := ""
Private cSerie   := ""
Private cForn    := ""
Private cLoja    := ""
Private cEspecie := Space(TamSx3("F1_ESPECIE")[1])

//Recupera os campos da capa da Pre Nota de Entrada.
nPos    := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_DOC"})
cDoc    := Strzero(Val(aCabec[nPos][2]),9)
cOldDoc := aCabec[nPos][2]
cDoc    := PadR(cDoc,TamSx3("F1_DOC")[1])

nPos    := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_SERIE"})
cSerie  := aCabec[nPos][2]
cOldSer := aCabec[nPos][2]
cSerie  := PadR(cSerie,TamSx3("F1_SERIE")[1])

nPos     := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_EMISSAO"})
dEmissao := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_FORNECE"})
cForn := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_LOJA"})
cLoja := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_EST"})
cUf   := aCabec[nPos][2]

nPos  := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_TIPO"})

aTiposNf := {"Normal","Devolucao","Beneficiamento"}

If aCabec[nPos][2] == "N"
	cTpNota := aTiposNf[1]
ElseIf aCabec[nPos][2] == "D"
	cTpNota := aTiposNf[2]
ElseIf aCabec[nPos][2] == "B"
	cTpNota := aTiposNf[3]
EndIf

SA2->(DbSetOrder(1))
If SA2->(DbSeek(xFilial("SA2")+AvKey(cForn,"A2_COD")+AvKey(cLoja,"A2_LOJA")))
	cDesFor := SA2->A2_NOME
EndIf

//Loop na primeira linha do array de itens para recuperar o nome dos campos dos itens.
For nX := 1 To Len(aItens[1])
	aAdd(aHeader,RetTitle(aItens[1][nX][1]))
Next

//Montagem do array com os itens.
For nX := 1 To Len(aItens)
	aAux := {}
	For nI := 1 To Len(aItens[nX])
		aAdd(aAux,aItens[nX][nI][2])
	Next
	aAdd(aBrowse,aAux)
Next                
 
If nSelec == 11
	cEspecie:="CTE"
Else
	cEspecie:="NF-E"
EndIf 

//Montagem da tela.
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 485,900 PIXEL
                   
	@ 017 , 006 TO 053,445 LABEL "" OF oDlg PIXEL                        	

	@ 021 , 010 SAY "Numero" PIXEL SIZE 60,09 OF oDlg
	@ 020 , 075 MSGET oGtDoc VAR cDoc PICTURE PesqPict("SF1","F1_DOC") OF oDlg PIXEL SIZE 34,09
	@ 021 , 119 SAY "Serie" PIXEL SIZE 23,09 OF oDlg
	@ 020 , 147 MSGET oGtSerie VAR cSerie PICTURE PesqPict("SF1","F1_SERIE") OF oDlg PIXEL SIZE 18,09
	@ 021 , 175 SAY "Emissao" PIXEL SIZE 30,09 OF oDlg
	@ 020 , 210 MSGET oGtEmiss VAR dEmissao PICTURE PesqPict("SF1","F1_EMISSAO") WHEN .F. OF oDlg PIXEL SIZE 45,09
	@ 021 , 265 SAY "Especie" PIXEL SIZE 63,09 OF oDlg
	@ 020 , 295 MSGET oGtEsp  VAR cEspecie  PICTURE PesqPict("SF1","F1_ESPECIE") VALID CheckSX3("F1_ESPECIE",cEspecie) F3 CpoRetF3("F1_ESPECIE") OF oDlg PIXEL SIZE 30,09
	@ 021 , 345 SAY "Tipo" PIXEL SIZE 30,09 OF oDlg
	@ 020 , 360 MSCOMBOBOX oLsTp VAR cTpNota ITEMS aTiposNf OF oDlg PIXEL SIZE 60,09

	@ 039 , 010 SAY "Forn./Cliente" PIXEL SIZE 43,09 OF oDlg
	@ 038 , 075 MSGET oGtForn VAR cForn   PICTURE PesqPict("SF1","F1_FORNECE") WHEN .F. OF oDlg PIXEL SIZE 041,09
	@ 038 , 121 MSGET oGtForn VAR cLoja   PICTURE PesqPict("SF1","F1_LOJA") WHEN .F. OF oDlg PIXEL SIZE 015,09
	@ 038 , 143 MSGET oGtForn VAR cDesFor PICTURE "@!" WHEN .F. OF oDlg PIXEL SIZE 150,09
	@ 039 , 303 SAY "UF.Origem" PIXEL SIZE 63,09 OF oDlg
	@ 038 , 336 MSGET oGtUF   VAR cUf     PICTURE PesqPict("SF1","F1_EST") WHEN .F. OF oDlg PIXEL SIZE 20,09

    oBrw := TWBrowse():New(057,006,440,175,,aHeader,,oDlg,,,,,,,,,,,,,,.T.)
	oBrw:SetArray(aBrowse)    
	oBrw:bLine := {|| aBrowse[oBrw:nAT]}

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) CENTERED

If lRet
	
	//Atualiza o número da pre nota com o valor informado
	If !(Upper(AllTrim(cDoc)) == Upper(AllTrim(cOldDoc))) //Utilizado o comando "!(==)" para diferenciar numeros parecidos.
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_DOC"})
		aCabec[nPos][2] := cDoc
	EndIf

	//Atualiza a serie da pre nota com o valor informado
	If !(Upper(AllTrim(cSerie)) == Upper(AllTrim(cOldSer))) //Utilizado o comando "!(==)" para diferenciar numeros parecidos.
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_SERIE"})
		aCabec[nPos][2] := cSerie
	EndIf
    
	//Atualiza a especie da pre nota com o valor informado
	If !Empty(cEspecie)
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_ESPECIE"})
		aCabec[nPos][2] := cEspecie
	EndIf
    
    //Atualiza o tipo da nota fiscal
	If !Empty(cTpNota)
		cTpNota := Upper(Left(cTpNota,1))
		nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "F1_TIPO"})
		aCabec[nPos][2] := cTpNota
	EndIf

EndIf

Return lRet
 
/*
Funcao      : VldPreNf()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Validação da tela previa da integração.
Autor       : Eduardo C. Romanini
Data/Hora   : 11/01/11 15:50
*/
*-------------------------*
Static Function VldPreNf(cDoc,cSerie,cForn,cLoja)
*-------------------------*

Local lRet := .T.

If Empty(cDoc)
	MsgInfo("O número da pre-nota deve ser informado.",STR061)	
	Return .F.
EndIf

SF1->(DbSetOrder(1))
If SF1->(DbSeek(xFilial("SF1")+AvKey(cDoc,"F1_DOC")+AvKey(cSerie,"F1_SERIE")+AvKey(cForn,"F1_FORNECE")+AvKey(cLoja,"F1_LOJA")))
	MsgInfo("O número e série informados já estão cadastrados em outra nota.",STR061)
	Return .F.
EndIf

If Empty(cEspecie) 
	MsgInfo("A especie deve ser informado.",STR061)	
	Return .F.
EndIf

If !MsgYesNo("Confirma a geração da pre-nota de entrada: " + AllTrim(cDoc) + If(!Empty(cSerie)," - " + AllTrim(cSerie),""),STR061)
	Return .F.	
EndIf

Return lRet    

/*
Funcao      : IntXmlPV()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Integração do xml para gerar pedido de venda.
Autor       : Eduardo C. Romanini
Data/Hora   : 08/02/11 09:40
*/
*------------------------*
Static Function IntXmlPV()
*------------------------*
Local lRet  := .T.
Local lCopy := .F.
Local lXml  := .F.

Local cFile    := ""
Local cErro    := ""
Local cAviso   := ""
Local cProd    := ""
Local cCFOP    := ""
Local cItemPV  := "00"
Local cCondPag := ""
Local cChave   := ""

Local nVlUn  := 0
Local nVlTot := 0
Local nAt    := 0
Local nX     := 0

Local aCabec := {}
Local aLinha := {}
Local aItens := {}

Local oXml  

Private lMSErroAuto := .F.

Private cCNPJ := ""

Private aProd := {}

//Verifica se o arquivo não está na raiz do ambiente.
If Substr(cArquivo,2,1) == ":" .or. Left(cArquivo,2) == "//"
      	
	//Verifica o nome do arquivo.
    cFile := cArquivo
	nAT   := 1
	For nX := 1 To Len(cArquivo)
		cFile := Substr(cFile,If(nX==1,nAt,nAt+1),Len(cFile))
		nAt := At("\",cFile)
		If nAt == 0
			Exit
		Endif
	Next nX
      	     	
	//Copia o arquivo para o diretorio raiz.
	CpyT2S(cArquivo,"\BKP")
	       	
	cArquivo := "\BKP\"+cFile
	lCopy := .T.
	
EndIf
        	
lXml := .T.
      	
//Leitura do XML
oXml :=  XmlParserFile(cArquivo,"_",@cErro,@cAviso)
If ( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)
	
	bError := ErrorBlock({|| lXml := .F.})
	Begin Sequence

		cCNPJ    := oXml:_NFeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT

 		If ValType(oXml:_NFeProc:_NFe:_infNFe:_det) == "A"
	 		For nX := 1 To Len(oXml:_NFeProc:_NFe:_infNFe:_det)
 				cProd  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_cProd:TEXT
 				nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_qCom:TEXT)
 				nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vUnCom:TEXT)
	 			nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_vProd:TEXT)
 				cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:TEXT

	   			If Right(cCFOP,3) == "910"
    				cTes := "70T"
    			ElseIf Right(cCFOP,3) == "106"
    				cTes := "98B"
		   		ElseIf Right(cCFOP,3) == "949"
    				cTes := "96Y"
	   			ElseIf Right(cCFOP,3) == "923"
    				cTes := "5CG"
		   		ElseIf Right(cCFOP,3) == "202"
    				cTes := "96Z"
	   			ElseIf Right(cCFOP,3) == "911"
    				cTes := "79T"
		 		EndIf
			
 				aAdd(aProd,{cProd,nQtd,nVlUn,nVlTot,cCFOP,cTes})
 			Next
		
		Else
			cProd  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_cProd:TEXT
 			nQtd   := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_qCom:TEXT)
 			nVlUn  := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vUnCom:TEXT)
			nVlTot := Val(oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_vProd:TEXT)
 			cCFOP  := oXml:_NFeProc:_NFe:_infNFe:_det:_prod:_CFOP:TEXT
 			 			 			
   			If Right(cCFOP,3) == "910"
    			cTes := "70T"
    		ElseIf Right(cCFOP,3) == "106"
    			cTes := "98B"
	   		ElseIf Right(cCFOP,3) == "949"
    			cTes := "96Y"
	   		ElseIf Right(cCFOP,3) == "923"
    			cTes := "5CG"
	   		ElseIf Right(cCFOP,3) == "202"
    			cTes := "96Z"
	   		ElseIf Right(cCFOP,3) == "911"
    			cTes := "79T"
	 		EndIf
 			
 			aAdd(aProd,{cProd,nQtd,nVlUn,nVlTot,cCFOP,cTes})
		EndIf

 		
	End Sequence
	ErrorBlock(bError)

	//Validações antes da integração
	cMsg := Validacoes("XML_PV")

	//Exibir a mensagem de erro.
	If Len(cMsg) > 0
		ExibeMsg(cMsg)	
	Else
		
		cCliente := SA1->A1_COD
		cLojaCli := SA1->A1_LOJA        

		//Monta os arrays com os campos do pedido de venda.
		aAdd( aCabec,{"C5_TIPO"   , "N"	   	 ,NIL})
		aAdd( aCabec,{"C5_CLIENTE", cCliente ,NIL})
		aAdd( aCabec,{"C5_LOJACLI", cLojaCli ,NIL})
		aAdd( aCabec,{"C5_CONDPAG", cCondPag ,NIL})    
        
		For nX:=1 To Len(aProd)

			cItemPV := Soma1( cItemPV )
			AAdd( aItens, {	{ "C6_ITEM"		, cItemPV	  , NIL },;
							{ "C6_PRODUTO"	, aProd[nX][1], NIL },;
							{ "C6_QTDVEN"	, aProd[nX][2], NIL },;
							{ "C6_QTDLIB"	, 0			  , NIL },;
							{ "C6_PRCVEN"	, aProd[nX][3], NIL },;
							{ "C6_VALOR"	, aProd[nX][4], NIL },;
							{ "C6_TES"		, aProd[nX][6], NIL },;
							{ "C6_CF"		, aProd[nX][5], NIL }} )
		Next

    	//Exibe a previa do Pedido de Venda.
    	If ExibePV(@aCabec,@aItens)    
    
			//Gera o pedido de venda.
			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
		    
      		If lMSErroAuto           
         		MostraErro()
         		Return .F.
      		Else
      			MsgInfo("O pedido de venda "+AllTrim(SC5->C5_NUM)+" foi gerado.",STR061)
      		EndIf   
		
		EndIf

	EndIf

Else
	MsgInfo("Erro na leitura do arquivo XML: "+ AllTrim(cErro)+".",STR061)
	Return .F.
EndIf    

//Apaga o arquivo da raiz do ambiente
If lCopy
	If File(cArquivo)
		fErase(cArquivo)	
    EndIf
EndIf

Return lRet

/*
Funcao      : ExibePV()
Parametros  : aCabec : Campos da capa do pedido de venda
	          aItens : Campos dos itens do pedido de venda
Retorno     : Nil
Objetivos   : Exibição da tela previa da integração. 
Autor       : Eduardo C. Romanini
Data/Hora   : 08/02/11 14:50
*/
*------------------------------------*
Static Function ExibePV(aCabec,aItens)
*------------------------------------*
Local lRet := .F.

Local cTitulo  := "Previa do pedido de venda"
Local cOldDoc  := ""
Local cOldSer  := ""
Local cCliente := ""
Local cLojaCli := ""
Local cDesCli  := ""
Local cUf      := ""
Local cTpPv    := "" 

Local nPos  := 0
Local nX    := 0
Local nI    := 0
Local nOpcG := 2//GD_UPDATE

Local aButtons := {}
Local aTiposNf := {}
Local aAlter   := {"C6_TES"}

Local bOK     := {|| If(VldPV(),(lRet := .T.,oDlg:End()),)}
Local bCancel := {|| lRet := .F.,oDlg:End()}

Local oDlg
Local oEnc
Local oBrw
Local oGtCond
Local oGtCli
Local oGtLoja
Local oGtDesCli
Local oLsTp

Private cCondPag := Space(TamSx3("C5_CONDPAG")[1])

//Declaração das variaveis utilizadas no MsGetDados().
Private nPosTes := {}

Private aHeader := {}
Private aCols   := {} 

aTiposPv   := {"Normal","Compl.Precos","Compl.ICMS","Compl.IPI","Dev.Compras","Utiliza Fornecedor"}
cTpPv      := aTiposPv[1]

//Recupera os campos da capa do pedido de venda
nPos     := aScan(aCabec,{|a| Alltrim(a[1]) == "C5_CLIENTE"})
cCliente := aCabec[nPos][2]

nPos     := aScan(aCabec,{|a| Alltrim(a[1]) == "C5_LOJACLI"})
cLojaCli := aCabec[nPos][2]

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+AvKey(cCliente,"A1_COD")+AvKey(cLojaCli,"A1_LOJA")))
	cDesCli := SA1->A1_NOME
EndIf

//Gera o a cabeçalho do browse.
For nX := 1 To Len(aItens[1])
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(aItens[1][nX][1]))
    	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			SX3->(aAdd(aHeader,{AllTrim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT}))
		EndIf
	Endif
Next

//Tratamento para o valid do campo Tes.
nPos := aScan(aHeader,{|a| AllTrim(a[2]) == "C6_TES"})
nPosTes := nPos
aHeader[nPos][6] := "Vazio() .or. (ExistCpo('SF4') .and. If(aCols[n][nPosTes]<= '500',(Help('',1,'A410NOTES'),.F.),.T.))"

//Montagem do array com os itens.
For nX := 1 To Len(aItens)
	aAdd(aCols, Array(Len(aHeader)+1))

	For nI := 1 To Len(aHeader)
		aCols[nX,nI] := aItens[nX][nI][2]
	Next 	
   
	aCols[nX,Len(aHeader)+1] := .F.
Next  

//Cria variaveis de memória.
DbSelectArea("SC6")
For nX := 1 To SC6->(FCount())
	M->&(FieldName(nX)) := CriaVar(FieldName(nX))	
Next

//Montagem da tela.
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 485,900 PIXEL
                   
	@ 017 , 006 TO 053,445 LABEL "" OF oDlg PIXEL                        	

	@ 021 , 010 SAY "Tipo Pedido" SIZE 60,09 OF oDlg PIXEL
	@ 020 , 075 MSCOMBOBOX oLsTp VAR cTpPv ITEMS aTiposPv SIZE 60,09 OF oDlg PIXEL
	@ 021 , 143 SAY "Cond.Pag." SIZE 23,09 OF oDlg PIXEL
	@ 020 , 171 MSGET oGtCond VAR cCondPag PICTURE PesqPict("SC5","C5_CONDPAG") F3 "SE4" VALID ExistCpo("SE4") OF oDlg PIXEL SIZE 18,09

	@ 039 , 010 SAY "Cliente" PIXEL SIZE 43,09 OF oDlg
	@ 038 , 075 MSGET oGtCli    VAR cCliente WHEN .F. OF oDlg PIXEL SIZE 041,09
	@ 038 , 121 MSGET oGtLoja   VAR cLojaCli WHEN .F. OF oDlg PIXEL SIZE 015,09
	@ 038 , 143 MSGET oGtDesCli VAR cDesCli  PICTURE "@!" WHEN .F. OF oDlg PIXEL SIZE 150,09

    oBrw := MsNewGetdados():New(057,006,240,445,nOpcG,"AllwaysTrue","AllwaysTrue","+C6_ITEM",aAlter,1,99,"AllwaysTrue","","",oDlg,aHeader,aCols)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) CENTERED

If lRet

	//Atualiza a condição de pagamento.
	nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "C5_CONDPAG"})
	aCabec[nPos][2] := cCondPag
	
	//Atualiza o tipo da nota fiscal
	cTpPv := Upper(Left(cTpPv,1))
	nPos := aScan(aCabec,{|a| Alltrim(a[1]) == "C5_TIPO"})
	aCabec[nPos][2] := cTpPv
	
	//Atualiza a TES dos itens.
	nPos := aScan(aHeader,{|a| AllTrim(a[2]) == "C6_TES"})
	For nI := 1 To Len(aCols)
		aItens[nI][nPos][2] := aCols[nI][nPos]
	Next

EndIf

Return lRet

/*
Funcao      : VldPV()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Validação da tela previa da integração.
Autor       : Eduardo C. Romanini
Data/Hora   : 09/02/11 18:15
*/
*-----------------------*
Static Function VldPV()
*-----------------------*
Local lRet := .T.
Local nI   := 0
Local nPos := 0

//Verifica se a condição de pagamento foi preenchida.
If Empty(cCondPag)
	MsgInfo("A condição de pagamento deve ser informada.",STR061)	
	Return .F.
EndIf

//Verifica os itens.
For nI:=1 To Len(aCols)
	If !aCols[nI][Len(aHeader)+1]
    	nPos := aScan(aHeader,{|a| AllTrim(a[2])=="C6_TES"})
		
		If Empty(aCols[nI][nPos])
			MsgInfo("O campo TES da linha "+AllTrim(Str(nI))+" não foi preenchido.",STR061)
			Return .F.
		EndIf
			
    EndIf
Next

If !MsgYesNo("Confirma a geração do pedido de venda?",STR061)
	Return .F.	
EndIf

Return lRet    

/*
Funcao      : GeraArqB1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico produto.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*-----------------------------------*
Static Function GeraArqB1(cArqTxt)   
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
Private aCpoObrigat   :={}
Private nPos          :=0
Private nCnt          :=0                   

//Busca do SX3 os campos Obrigatórios
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SB1")
	
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SB1"
	
    If X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)   
		//Campo obrigatorios - Padrao
		If (Alltrim(SX3->X3_CAMPO) == "B1_REQUIS") .Or. (Alltrim(SX3->X3_CAMPO) == "B1_CRDEST") .Or. (Alltrim(SX3->X3_CAMPO) == "B1_CODITE")
			SX3->(DbSkip())
			Loop
		Else 
			AADD(aCpoObrigat,SX3->X3_CAMPO)
	    EndIf
	Else
   		//Campo nao obrigatorios que deve ser usados
		If Alltrim(SX3->X3_CAMPO)=="B1_PICM" .Or. Alltrim(SX3->X3_CAMPO)=="B1_IPI"
			AADD(aCpoObrigat,SX3->X3_CAMPO)
	    EndIf
	Endif
	
	SX3->(DBSkip()) 
	
Enddo

//Fim Busca no SX3 de campos Obrigatórios

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If "B1_" $ UPPER(aLinha[1])
	
	//Verifica se os campos obrigatórios estão no arquivo
	for cont:=1 to len(aCpoObrigat)
		if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
			cCpoFaltantes+=aCpoObrigat[cont]+","
		endif
	next
	
	if !Empty(cCpoFaltantes)
		Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
	    lCpoFal:=.T.
	    exit
	endif
	//Fim da verificação dos campos obrigatórios
	
	    For i:=1 to len(aLinha)
			If "B1_" $ UPPER(aLinha[i])
		 		
		 		cCampo:=Alltrim(aLinha[i])
		 		
		 		DBSELECTAREA("SX3")
				dbsetorder(2)
				If Dbseek(cCampo)
					if aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
						lTemDup:=.T.
						cTemDup+=cCampo+","
					endif
					
					AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
			    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
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
	
Enddo

If empty(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de produtos!")
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

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	
	Begin Transaction	
		Reclock("XXX",.T.) 
	    	for nK:=1 to len(aCampos1)
	    		if !empty(aCampos1[nK][1])
	    			
	    			if aCampos1[nK][2]=="N"
	    				XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val(aLinha[nK]))
	    		    elseif aCampos1[nK][2]=="D"
				    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])   		    	
	    		    else
	    		        Do Case
	    		        	Case aCampos[nK][1] == "B1_DESC"
	    		        		XXX->&(aCampos1[nK][1]):= RetCharInv(aLinha[nK])
	    		        	OtherWise 
	    		    			XXX->&(aCampos1[nK][1]):= aLinha[nK]
	    		    	EndCase
	    		    endif
	    		endif	
	        next
	    XXX->(MsUnlock())           
		//Confirmsx8()
	End Transaction

	IncProc("Lendo item B1_COD: "+alltrim(XXX->B1_COD))

	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutB1()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutB1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico produto.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/                          
*-------------------------*
Static Function ExecAutB1  
*-------------------------*
Local xAutoCab := {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}
Local aAltNcm:={}
 
// Incio Tabela temporária para armaznar os erros
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

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
	xAutoCab := {}
	/*
	AADD(xAutoCab,{"B1_COD"   	,"TESTE"	,nil})
	AADD(xAutoCab,{"B1_DESC"   	,"TESTE"	,nil})
	AADD(xAutoCab,{"B1_TIPO"   	,"PA"		,nil})
	AADD(xAutoCab,{"B1_UM"   	,"UN"		,nil})
	AADD(xAutoCab,{"B1_GRUPO"   ,"ZZ"		,nil})
	AADD(xAutoCab,{"B1_LOCPAD"  ,"01"		,nil})
	AADD(xAutoCab,{"B1_PICM"   	,0			,nil})
	AADD(xAutoCab,{"B1_IPI"   	,0			,nil})
	AADD(xAutoCab,{"B1_POSIPI" 	,"00000000"	,nil})
	AADD(xAutoCab,{"B1_CONTRAT"	,"N"		,nil})
	AADD(xAutoCab,{"B1_LOCALIZ"	,"N"		,nil})
	AADD(xAutoCab,{"B1_ORIGEM"	,"0"		,nil})
	AADD(xAutoCab,{"B1_P_TIP"  	,"1"		,nil})
	*/       
	/*
		Tratamento para alteração de NCM, quando na planilha já haver o cadastro do produto
	*/
	//Verificação se já existe cadastro do produto
	Private nPosNCM:=0
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	if DbSeek(xFilial("SB1")+XXX->B1_COD)
		nPosNCM:=aScan( aCampos, { |x| alltrim(x[1]) == "B1_POSIPI"} )
		if nPosNCM>0
			if UPPER(alltrim(XXX->&(aCampos[nPosNCM][1]))) <> UPPER(alltrim(SB1->B1_POSIPI))
				AADD(aAltNcm,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_POSIPI,XXX->&(aCampos[nPosNCM][1])})
			endif
		endif
	endif
	
	for nl:=1 to len(aCampos)
		AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next
	
	Private lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	BEGIN Transaction
		MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,3) //Inclusao
	
		If lMsErroAuto
			cErroCon:=""
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
			//msginfo(cErroCon) 
		   	if !("B1_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
		   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
	       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
	       		if nPoTit<>0
	       			cErroCon+=" "+ aCampos[nPoTit][1]
	       		endif
	    	endif    
	    	
	    	AADD(aErros,{alltrim(XXX->B1_COD),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
		    lErro:=.T.
		    DisarmTransaction()
		    
			Reclock("WWW",.T.)
		    	WWW->CODIGO:=alltrim(XXX->B1_COD)
		    	WWW->SITUACAO:="Erro"
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
		    WWW->(MsUnlock())
		Else
			lOk:=.T.
			AADD(aGravado,{alltrim(XXX->B1_COD),"OK","Inserido"})
			
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->B1_COD)
		    		WWW->SITUACAO:="Ok"
		    		WWW->DESCRICAO:="Inserido"	    
		    	WWW->(MsUnlock())
			
		EndIF            
		END Transaction
	XXX->(DbSkip())
enddo

If lErro
	//Situacao(aErros,aGravado)	
	//MSM - 10/08/2012 - Caso a Flau queira retirar a alteração de NCM, descomente a linha acima e comente a linha abaixo. (chamado: 005546)
	SituaProd(aErros,aGravado,aAltNcm)
	//cMemo+="Existem dados que não foram incluidos, clique no botão (Erros), para verificar!!"
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )  


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
Funcao      : GeraArqA1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico cliente.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/                                 
*----------------------------------*
Static Function GeraArqA1(cArqTxt) 
*----------------------------------* 
ProcRegua(0)

Private cCampo:=""
Private lCrt:=.F.
Private aCampos:={}
Private nPos:=0
Private nCnt:=0                   
Private aCabExcel:={}
Private aDadExcel:={}
Private aCampos1:={}
//variaveis que controlam campos Obrigatórios
Private aCpoObrigat:={}
Private cCpoFaltantes:=""
Private lCpoFal:=.F.
Private lTemDup:=.F.
Private cTemDup:="" 
//Busca do SX3 os campos Obrigatórios
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SA1")
	
	while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SA1"
	
		if X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)
			AADD(aCpoObrigat,SX3->X3_CAMPO)
		endif
	
	SX3->(DBSkip())
	enddo        
	                                   
	//Especifico para tratamento do campo CPF/CNPJ
	if aScan( aCpoObrigat, { |x| alltrim(x) == "A1_CGC"} ) == 0	
		AADD(aCpoObrigat,"A1_CGC")
	endif
//Fim Busca no SX3 de campos Obrigatórios

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If "A1_" $ UPPER(aLinha[1])
	
	//Verifica se os campos obrigatórios estão no arquivo
	for cont:=1 to len(aCpoObrigat)
		if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
			cCpoFaltantes+=aCpoObrigat[cont]+","
		endif
	next
	
	if !Empty(cCpoFaltantes)
		Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
	    lCpoFal:=.T.
	    exit
	endif
	//Fim da verificação dos campos obrigatórios
	
	    For i:=1 to len(aLinha)
			If "A1_" $ UPPER(aLinha[i])
		 		
		 		cCampo:=Alltrim(aLinha[i])
		 		
		 		DBSELECTAREA("SX3")
				dbsetorder(2)
				If Dbseek(cCampo)
					if aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
						lTemDup:=.T.
						cTemDup+=cCampo+","
					endif
					
					AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
			    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
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
Enddo

if empty(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de clientes!")
	FT_FUse()
	Return	
endif

if lTemDup
	alert("Exitem campos iguais no arquivo: "+cTemDup)
	FT_FUse()
	Return
endif

If lCpoFal
	FT_FUse()
	Return
EndIf	

Private cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	Begin Transaction	
		Reclock("XXX",.T.) 
	    	for nK:=1 to len(aCampos1)
	    		if !empty(aCampos1[nK][1])
	    			
	    			if aCampos1[nK][2]=="N"
	    				XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val(aLinha[nK]))
	    		    elseif aCampos1[nK][2]=="D"
	    		    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
	    		    else
	    		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	    		    endif
	    		endif	
	        next
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction
	IncProc("Lendo item A1_COD : "+alltrim(XXX->A1_COD))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutA1()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutA1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico cliente.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*--------------------------*
Static Function ExecAutA1
*--------------------------*
Local xAutoCab := {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}

//INICIO Tabela temporária para armaznar os erros
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

if select("WWW")>0
	WWW->(DbCloseArea())
endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)
//FIM Tabela temporária para armaznar os erros

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 

	xAutoCab := {}  
	/*
	AADD(xAutoCab,{"A1_FILIAL"	, xFilial("SA1") , Nil})
	AADD(xAutoCab,{"A1_COD"		, "TESTE" , Nil})
	AADD(xAutoCab,{"A1_LOJA" 	, "01" , Nil})
	AADD(xAutoCab,{"A1_NOME" 	, "TESTE-000001" , Nil})
	AADD(xAutoCab,{"A1_NREDUZ" 	, "TESTE-000001" , Nil})
	AADD(xAutoCab,{"A1_TIPO" 	, "F" , Nil})
	AADD(xAutoCab,{"A1_END" 	, "TESTE" , Nil})
	AADD(xAutoCab,{"A1_EST" 	, "SP" , Nil})
	AADD(xAutoCab,{"A1_COD_MUN"	, "00105" , Nil})
	AADD(xAutoCab,{"A1_BAIRRO" 	, "TESTE" , Nil})
	AADD(xAutoCab,{"A1_CEP" 	, "07034911" , Nil})
	AADD(xAutoCab,{"A1_CGC" 	, "26307344806" , Nil})
	AADD(xAutoCab,{"A1_INSCR" 	, "ISENTO" , Nil})
	  */
	for nl:=1 to len(aCampos)
		AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next
	
	Private lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	BEGIN Transaction
		MsExecAuto({|x,y| MATA030(x,y)}, xAutoCab, 3)
		If lMsErroAuto
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
	    	
	    	AADD(aErros,{alltrim(XXX->A1_COD),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
		    lErro:=.T.
		    DisarmTransaction()
			    
		    Reclock("WWW",.T.)
		    	WWW->CODIGO:=alltrim(XXX->A1_COD)
		    	WWW->SITUACAO:="Erro"
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
		    WWW->(MsUnlock())
		
		Else
			if empty(XXX->A1_CGC)
				AADD(aErros,{alltrim(XXX->A1_COD),"Erro","A1_CGC em branco!"})    	
				lErro:=.T.
				
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->A1_COD)
		    		WWW->SITUACAO:="Erro"
		    		WWW->DESCRICAO:="A1_CGC em branco!"	    
		    	WWW->(MsUnlock())
			else
					
			lOk:=.T.
			AADD(aGravado,{alltrim(XXX->A1_COD),"OK","Inserido"})
	
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->A1_COD)
		    		WWW->SITUACAO:="Ok"
		    		WWW->DESCRICAO:="Inserido"	    
		    	WWW->(MsUnlock())		
			endif
		EndIf            
		END Transaction
	XXX->(DbSkip())
enddo

If lErro
	Situacao(aErros,aGravado)	
	//cMemo+="Existem dados que não foram incluidos, clique no botão (Erros), para verificar!!"
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )  

/*
Funcao      : GeraArqA2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico fornecedor.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/                   
*-----------------------------------*
Static Function GeraArqA2(cArqTxt)
*-----------------------------------*
ProcRegua(0)

Private cCampo:=""
Private lCrt:=.F.
Private aCampos:={}
Private nPos:=0
Private nCnt:=0                   
Private aCabExcel:={}
Private aDadExcel:={}
Private aCampos1:={}
//variaveis que controlam campos Obrigatórios
Private aCpoObrigat:={}
Private cCpoFaltantes:=""
Private lCpoFal:=.F.
Private lTemDup:=.F.
Private cTemDup:="" 

//Busca do SX3 os campos Obrigatórios
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SA2")
	
	while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SA2"
		if X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)
			AADD(aCpoObrigat,SX3->X3_CAMPO)
		endif
	
	SX3->(DBSkip())
	enddo        
	                                   
	//Especifico para tratamento do campo CPF/CNPJ
	if aScan( aCpoObrigat, { |x| alltrim(x) == "A2_CGC"} ) == 0	
		AADD(aCpoObrigat,"A2_CGC")
	endif
//Fim Busca no SX3 de campos Obrigatórios


FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

If "A2_" $ UPPER(aLinha[1])

//Verifica se os campos obrigatórios estão no arquivo
for cont:=1 to len(aCpoObrigat)
	if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
		cCpoFaltantes+=aCpoObrigat[cont]+","
	endif
next

if !Empty(cCpoFaltantes)
	Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
    lCpoFal:=.T.
    exit
endif
//Fim da verificação dos campos obrigatórios

    For i:=1 to len(aLinha)
		If "A2_" $ UPPER(aLinha[i])
	 		
	 		cCampo:=Alltrim(aLinha[i])
	 		
	 		DBSELECTAREA("SX3")
			dbsetorder(2)
			If Dbseek(cCampo)
				if aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
					lTemDup:=.T.
					cTemDup+=cCampo+","
				endif
				
				AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
		    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
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

Enddo

if empty(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de fornecedores!")
	FT_FUse()
	Return	
endif

if lTemDup
	alert("Exitem campos iguais no arquivo: "+cTemDup)
	FT_FUse()
	Return
endif

If lCpoFal
	FT_FUse()
	Return
EndIf	

Private cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	Begin Transaction	
		Reclock("XXX",.T.) 
	    	for nK:=1 to len(aCampos1)
	    		if !empty(aCampos1[nK][1])
	    			
	    			if aCampos1[nK][2]=="N"
	    				XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val(aLinha[nK]))
	    		    elseif aCampos1[nK][2]=="D"
	    		    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
	    		    else
	    		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	    		    endif
	    		endif	
	        next
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction
	
	IncProc("Lendo item A2_COD : "+alltrim(XXX->A2_COD))
	   
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutA2()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet) 

/*
Funcao      : ExecAutA2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico fornecedor.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*-------------------------*
Static Function ExecAutA2
*-------------------------* 
Local xAutoCab := {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}

//INICIO Tabela temporária para armaznar os erros
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

if select("WWW")>0
	WWW->(DbCloseArea())
endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)
//FIM Tabela temporária para armaznar os erros

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 

	xAutoCab := {}
	
	/*
	*****************************************************************
	Local xAutoCab := {}
	
	AADD(xAutoCab,{"A2_COD"    	,"TESTE"		,nil})
	AADD(xAutoCab,{"A2_LOJA"   	,"01" 			,nil})
	AADD(xAutoCab,{"A2_NOME"   	,"Fornecedor Teste" ,nil})
	AADD(xAutoCab,{"A2_NREDUZ" 	,"Teste F" 	,nil})
	AADD(xAutoCab,{"A2_END"    	,"Rua teste" 	,nil})
	AADD(xAutoCab,{"A2_MUN"    	,"SAO PAULO" 		,nil})
	AADD(xAutoCab,{"A2_EST"    	,"SP" 			,nil})
	AADD(xAutoCab,{"A2_COD_MUN"	,"00105" 			,nil})
	AADD(xAutoCab,{"A2_TIPO"	,"J" 			,nil})
	AADD(xAutoCab,{"A2_CGC"		,"62829510000123" 			,nil})
	*/
	
	for nl:=1 to len(aCampos)
		AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next
	
	Private lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	
	BEGIN Transaction
		MSExecAuto({|x,y| Mata020(x,y)},xAutoCab,3) //Inclusao
		If lMsErroAuto
			cErroCon:=""
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
			//msginfo(cErroCon)
	    	if !("A2_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
		   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
	       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
	       		if nPoTit<>0
	       			cErroCon+=" "+ aCampos[nPoTit][1]
	       		endif
	    	endif
	    	
	    	AADD(aErros,{alltrim(XXX->A2_COD),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
		    lErro:=.T.
		    DisarmTransaction()
			    
		    Reclock("WWW",.T.)
		    	WWW->CODIGO:=alltrim(XXX->A2_COD)
		    	WWW->SITUACAO:="Erro"
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
		    WWW->(MsUnlock())
		
		Else
			if empty(XXX->A2_CGC)
				AADD(aErros,{alltrim(XXX->A2_COD),"Erro","A2_CGC em branco!"})    	
				lErro:=.T.
				
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->A2_COD)
		    		WWW->SITUACAO:="Erro"
		    		WWW->DESCRICAO:="A2_CGC em branco!"	    
		    	WWW->(MsUnlock())
			else
					
			lOk:=.T.
			AADD(aGravado,{alltrim(XXX->A2_COD),"OK","Inserido"})
	
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->A2_COD)
		    		WWW->SITUACAO:="Ok"
		    		WWW->DESCRICAO:="Inserido"	    
		    	WWW->(MsUnlock())		
	
			
			endif
			
		EndIf            
		
		
		END Transaction
	XXX->(DbSkip())
enddo

If lErro
	
	Situacao(aErros,aGravado)	
	//cMemo+="Existem dados que não foram incluidos, clique no botão (Erros), para verificar!!"
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqC7()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico pedido de compra.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/09/11 19:00
*/
*-----------------------------------*
Static Function GeraArqC7(cArqTxt)  
*-----------------------------------*       
Return  

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
					If Dbseek(cCampo)
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
    
/*    Do Case
    	Case nPosC5_1_CHA<>0 .AND. nPosC5_6_CHA<>0
			if empty(aLinha[nPosC5_1_CHA]) .AND. empty(aLinha[nPosC5_6_CHA])
				FT_FSkip() // Proxima linha
			endif
		Case nPosC5_6_CHA<>0
	    	if empty(aLinha[nPosC5_6_CHA])
				FT_FSkip() // Proxima linha
			endif
    	Case nPosC5_1_CHA<>0
    		if empty(aLinha[nPosC5_1_CHA])
				FT_FSkip() // Proxima linha
				loop
			endif
    EndCase
*/
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
	    		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	    		    endif
	     		endif	
	        next
	        
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
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
XXX->(DbSetOrder(0))
XXX->(DbGotop())

while XXX->(!EOF()) 


	XXX->C5_NUM := GETSXENUM("SC5","C5_NUM")
	Confirmsx8()

	if nPosC5_6_CHA<>0
		IncProc("Processando registro: "+alltrim(XXX->C5_P_REF+XXX->C5_NUM))
	else 
		IncProc("Processando registro: "+alltrim(XXX->C5_NUM))
	endif
/*
	if empty(XXX->C5_NUM) .AND. nPosC5_6_CHA==0
	    lErro:=.T.
		Reclock("WWW",.T.)
	    	WWW->SITUACAO:="Erro"
	    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
	    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
	    	WWW->CGC:=alltrim(XXX->A1_CGC)
	    	WWW->DESCRICAO:="Quando o campo C5_NUM estiver em branco, o campo C5_P_REF deve ser informado!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop		
	elseif nPosC5_6_CHA>0
		if empty(XXX->C5_NUM) .AND. empty(XXX->C5_P_REF)
		    lErro:=.T.
			Reclock("WWW",.T.)
		    	WWW->SITUACAO:="Erro"
		    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
		    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:="O campo C5_NUM ou o campo C5_P_REF deve ser preenchido!"
		    WWW->(MsUnlock())
			XXX->(DbSkip())
			Loop	
*/			
		//Chega se já existe referencia inserida | retirado para poder inserir mesma referencia existente na planilha
/*		elseif !empty(XXX->C5_P_REF)
			
			c_M_Qry:=" SELECT C5_NUM FROM "+RETSQLNAME("SC5")+CRLF
			c_M_Qry+=" WHERE D_E_L_E_T_='' AND C5_P_REF='"+XXX->C5_P_REF+"'
			
			if select("M_TRB")>0
				M_TRB->(DbCloseArea())
			endif
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,c_M_Qry),"M_TRB",.T.,.T.)
	
			COUNT TO nRecCount
			
			if nRecCount>0
			    lErro:=.T.
				Reclock("WWW",.T.)
			    	WWW->SITUACAO:="Erro"
			    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
			    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
			    	WWW->CGC:=alltrim(XXX->A1_CGC)
			    	WWW->DESCRICAO:="Já existe registro para a referencia C5_P_REF!"
			    WWW->(MsUnlock())
				XXX->(DbSkip())
				Loop				
			endif
*/
//		endif	
	//endif
	
	aDados	:={}
	aItens	:={}
	aItem	:={}
	
	aCabecSA1	:={}
	c_M_Cliente	:=""
	c_M_LojaCLi	:=""
	lDeuErroSA1	:=.F.
	c_M_CGC		:=STRTRAN(STRTRAN(STRTRAN(XXX->&(aCampos1[nPosA1_1][1]),"."),"-"),"/")

//<Tratamento para cliente - SA1>//

    //verifica se o CNPJ está em branco
	if empty(c_M_CGC)
//    	AADD(aErros,{iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM)),"Erro","CNPJ do cliente em branco!"})
	    lErro:=.T.	

		Reclock("WWW",.T.)
	    	WWW->SITUACAO:="Erro"
	    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
	    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
	    	WWW->CGC:=alltrim(XXX->A1_CGC)
	    	WWW->DESCRICAO:="CNPJ do cliente em branco!"	    
	    WWW->(MsUnlock())
        
		XXX->(DbSkip())
		Loop
	endif
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
	if !DbSeek(xFilial("SA1")+c_M_CGC)
		
		//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
		cTipoSA1	:= IF(EMPTY(XXX->C5_TIPOCLI),"F",XXX->C5_TIPOCLI)
		cNatureza	:= "1004"
		//cConta	:= "112110001"  chamado 012684
		cConta		:= "11211001"  
		cPaisSA1	:= "01058"
		
		//RRP - 29/08/2012 - Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência 
		ChkIn("A1_COD")
	   
		c_M_Cliente	:=GETSXENUM("SA1","A1_COD")
		Confirmsx8()
		c_M_LojaCLi	:="01"
				
		AADD(aCabecSA1,{"A1_COD"	,c_M_Cliente	,	nil})
		AADD(aCabecSA1,{"A1_LOJA"	,c_M_LojaCLi	,	nil})
		AADD(aCabecSA1,{"A1_TIPO"	,cTipoSA1,	nil})
		
		//RRP - 23/08/12 - Fixando o valor dos campos A1_TIPO, A1_NATUREZ, A1_CONTA, A1_CODPAIS
		AADD(aCabecSA1,{"A1_NATUREZ",cNatureza,	nil})
		AADD(aCabecSA1,{"A1_CONTA"	,cConta,	nil})
		AADD(aCabecSA1,{"A1_CODPAIS",cPaisSA1,	nil})
		
		for nK:=1 to len(aCampos1)
			if !empty(aCampos1[nK][1])
				if "A1_TIPO" == alltrim(aCampos1[nK][1])
				//não faz nada
				elseif "A1_" $ aCampos1[nK][1]
					AADD(aCabecSA1,{aCampos1[nK][1],	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
				endif
			endif
		next 

        //--Execução do MSExecAuto do SA1--//
		Private lMsErroAuto:= .F.
		Private lMSHelpAuto := .F.
		Private lAutoErrNoFile := .T.
		
		BEGIN Transaction
	
			MsExecAuto({|x,y| MATA030(x,y)}, aCabecSA1, 3)
		
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
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))
		    	WWW->MEMO:=XLOGMEMO(aAutoErro)
			    WWW->(MsUnlock())
				//ROLLBACKSXE()
			Else
				//Confirmsx8()		
				lOk:=.T.
//				AADD(aGravado,{alltrim(XXX->A1_CGC),"OK","Cliente Inserido"})
    			Reclock("WWW",.T.)
		    	WWW->SITUACAO:="OK"
		    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
		    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:="Inserido"
			    WWW->(MsUnlock())
			EndIf
		END Transaction
        //--FIM Execução do MSExecAuto do SA1--//		
	
	else
		c_M_Cliente	:=SA1->A1_COD
		c_M_LojaCLi	:=SA1->A1_LOJA		
	endif
	if lDeuErroSA1	
		XXX->(DbSkip())
		Loop
	endif

//<FIM Tratamento para cliente - SA1>//
	
    //--Tratamento para o número sequencial do pedido de venda--//
	lUsouGetC5:=.F.
	if nPosC5_6_CHA<>0
		if !empty(XXX->&(aCampos1[nPosC5_6_CHA][1])) .AND. empty(XXX->&(aCampos1[nPosC5_1_CHA][1]))
			//RRP - 29/08/2012 - Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência 
			ChkIn("C5_NUM")
			cSeqNumC5 := GETSXENUM("SC5","C5_NUM")
			Confirmsx8()
			lUsouGetC5:=.T.
		else
			cSeqNumC5:=XXX->&(aCampos1[nPosC5_1_CHA][1])
		endif
	else
		cSeqNumC5:=XXX->&(aCampos1[nPosC5_1_CHA][1])
	endif
    //--FIM Tratamento para o número sequencial do pedido de venda--//
    
	//<Tratamento para capa do pedido - SC5>//
	for nK:=1 to len(aCampos1)
		if !empty(aCampos1[nK][1])
			if aCampos1[nPosC5_2][1]==aCampos1[nK][1] //C5_TIPOCLI
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
		
	Private cItem		:="00"
	Private cRecUlt		:=""
	Private lErroInter	:=.F.
	
	XXX->(DbSkip())
	// MSM - Alterado para validar como mesmo pedido quando o número de referência, o cnpj forem iguais e o item for sequêncial
	If &(c_M_Key)==cNumPedAnt .AND. cNumCGC==XXX->A1_CGC .AND. XXX->C6_ITEM>cAntItem
		
		XXX->(Dbgoto(cRenXXX))
	    //while alltrim(XXX->C5_NUM)==cNumPedAnt
		while alltrim(&(c_M_Key))==cNumPedAnt 
		    //cItem:=(SOMA1(cItem))
		    cItem:=XXX->C6_ITEM
		    
		    for nK:=1 to len(aCampos1)
				if !empty(aCampos1[nK][1])
					
					if "C6_ITEM" $ aCampos1[nK][1]
						AADD(aItem,{"C6_ITEM",cItem,	nil})
					elseif "C6_" $ aCampos1[nK][1]
						AADD(aItem,{aCampos1[nK][1],	iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
					endif
				endif
			next
			AADD(aItem,{"C6_NUM",alltrim(cSeqNumC5),	nil})
		    
			cNumPedAnt:=alltrim(&(c_M_Key))
			cRecUlt:=XXX->(Recno())
			XXX->(DbSkip())
		
			AADD(aItens,aItem)
			aItem:={}
		enddo	
		XXX->(Dbgoto(cRecUlt))   
	Else
	    //cItem:=(SOMA1(cItem))
		cItem:=XXX->C6_ITEM
		XXX->(Dbgoto(cRenXXX))
		    for nK:=1 to len(aCampos1)
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
		aItem:={}
	EndIf
//<FIM Tratamento para itens do pedido - SC6>//
cPParar:=""

//--Execução do MSExecAuto do SC5/SC6--//
	Private lMsErroAuto:= .F.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	
	BEGIN Transaction
		MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aDados, aItens, 3)
	   
		If lMsErroAuto
		  	//if lUsouGetC5
				//ROLLBACKSXE()		  		
		  	//endif
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
	    	
//	    	AADD(aErros,{iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM)),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
		    lErro:=.T.
		    DisarmTransaction()
		    
//			Reclock("WWW",.T.)
//		    	WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
//		    	WWW->SITUACAO:="Erro"
//		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
//		    WWW->(MsUnlock())

    		Reclock("WWW",.T.)
		    	WWW->SITUACAO:="Erro"
		    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
		    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC:=alltrim(XXX->A1_CGC)
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))
		    	WWW->MEMO:=XLOGMEMO(aAutoErro) 
		    WWW->(MsUnlock())
		  
		Else
		  	//if lUsouGetC5
			    //Confirmsx8()    
		  	//endif
			lOk:=.T.
//			AADD(aGravado,{iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM)),"OK","Inserido"})
//				Reclock("WWW",.T.)
//	    		WWW->CODIGO:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
//	    		WWW->SITUACAO:="Ok"
//	    		WWW->DESCRICAO:="Inserido"	    
//		    	WWW->(MsUnlock())
	    		Reclock("WWW",.T.)
			    	WWW->SITUACAO:="Ok"
			    	WWW->CODIGO:=alltrim(XXX->C5_NUM)
			    	WWW->CODREF:=iif(nPosC5_6_CHA<>0,alltrim(XXX->C5_P_REF),"")
			    	WWW->CGC:=alltrim(XXX->A1_CGC)
			    	WWW->DESCRICAO:="Inserido"
			    WWW->(MsUnlock())
		EndIF
	      
	END Transaction
//--FIM Execução do MSExecAuto do SC5/SC6--//
/*
for nl:=1 to len(aCampos)
	AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
next        

Private lMsErroAuto:= .f.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

BEGIN Transaction

	MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,3) //Inclusao

	If lMsErroAuto
		cErroCon:=""
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 
		//msginfo(cErroCon) 
	   	if !("B1_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
	   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
       		if nPoTit<>0
       			cErroCon+=" "+ aCampos[nPoTit][1]
       		endif
    	endif    
    	
    	AADD(aErros,{alltrim(XXX->B1_COD),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
	    lErro:=.T.
	    DisarmTransaction()
	    
		Reclock("WWW",.T.)
	    	WWW->CODIGO:=alltrim(XXX->B1_COD)
	    	WWW->SITUACAO:="Erro"
	    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
	    WWW->(MsUnlock())
	
	
	Else
		lOk:=.T.
		AADD(aGravado,{alltrim(XXX->B1_COD),"OK","Inserido"})
		
			Reclock("WWW",.T.)
	    		WWW->CODIGO:=alltrim(XXX->B1_COD)
	    		WWW->SITUACAO:="Ok"
	    		WWW->DESCRICAO:="Inserido"	    
	    	WWW->(MsUnlock())
		
	EndIF            
	
		
	END Transaction
*/	
XXX->(DbSkip())
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
Funcao      : ExecCT2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico pedido de compra.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 07/12/2009
*/
*--------------------------------*
Static Function ExecCT2(cArqTxt)  
*--------------------------------*
Local nCountAc   := 0
Local nCountCapa := 0 
Local nIncDoc    := 0
Local nRecno     := 1
Local nCountItens:= 1       

Private nDocSeq   

      // Tratamento antigo Discovery.
      aadd(aButtons,{"LINE",{|| SomaLanc()},"Previa","Previa",{|| .T.}})  
      
      If !(SX6->(DbSeek(XFilial()+"MV_P_CT2DC")))
         MsgStop("Paramentro de controle de documento não encontrado",STR061)
         Return .F.
      EndIf     

      nDocSeq:=Val(GetMV("MV_P_CT2DC"))           
                 
      If Select("INT_CT2") > 0
         INT_CT2->(DBCLoseArea())
      EndIf
      
      cAliasSX3 := "CT2"
      DbSelectArea("SX3")
      DbSetOrder(1)   
      
      If __LANGUAGE="PORTUGUESE"
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"CT2Status"  ,"","Status"      ,}) 
         Aadd(aCpos, {"CT2_DATA"   ,"","Dt Lcto"     ,}) 
         Aadd(aCpos, {"CT2_LOTE"   ,"","Nr. Lote"    ,})                               
         Aadd(aCpos, {"CT2_SBLOTE" ,"","Sub. Lote"   ,})
         Aadd(aCpos, {"CT2_DOC"    ,"","Documento"   ,})	
         Aadd(aCpos, {"CT2_LINHA"  ,"","Seq. Lcto"   ,})
         Aadd(aCpos, {"CT2_DC"     ,"","Tipo Lcto"   ,})
         Aadd(aCpos, {"CT2_DEBITO" ,"","Cta Debito"  ,})		
         Aadd(aCpos, {"CT2_CREDIT" ,"","Cta Credito" ,}) 
         Aadd(aCpos, {"CT2_VALOR"  ,"","Valor"       ,})				
         Aadd(aCpos, {"CT2_HIST"   ,"","Historico"   ,})
         Aadd(aCpos, {"CT2_CCD"    ,"","C Custo Deb.",})		
         Aadd(aCpos, {"CT2_CCC"    ,"","C Custo Cred.",}) 
         Aadd(aCpos, {"CT2_ITEMD"  ,"","Canal Deb."  ,})				
         Aadd(aCpos, {"CT2_ITEMC"  ,"","Canal Cred." ,}) 
         Aadd(aCpos, {"CT2_CLVLDB" ,"","Plataf. Deb.",})		
         Aadd(aCpos, {"CT2_CLVLCR" ,"","Plataf. Cred.",}) 
         Aadd(aCpos, {"CT2_P_GEOG" ,"","Regiao"      ,})				
         Aadd(aCpos, {"CT2_P_PROJ" ,"","Projeto"     ,}) 
         Aadd(aCpos, {"CT2_P_CODE" ,"","Company"     ,})		
         Aadd(aCpos, {"CT2_AGLUT"  ,"","Aglutinado"  ,}) 
         Aadd(aCpos, {"CT2_DATATX" ,"","Data Conv."  ,})  
         Aadd(aCpos, {"CT2_TAXA"   ,"","Taxa Conv."  ,})         
         Aadd(aCpos, {"CT2_TPSALD" ,"","Tipo do Sld" ,})		
         Aadd(aCpos, {"CT2_EMPORI" ,"","Empresa Orig",}) 
         Aadd(aCpos, {"CT2_FILORI" ,"","Filial Orig" ,})  
         Aadd(aCpos, {"CT2_MOEDLC" ,"","Moeda Lancto",})  
         Aadd(aCpos, {"CT2_P_ARQ" ,"","Arquivo"      ,})                  
         Aadd(aCpos, {"Log_Int"    ,"","Problema"    ,})  
         Aadd(aCpos, {"Log_Aviso" ,"","Aviso"        ,})
      Else
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"CT2Status"  ,"","Status"      ,}) 
         Aadd(aCpos, {"CT2_DATA"   ,"","Dt Lcto"     ,}) 
         Aadd(aCpos, {"CT2_LOTE"   ,"","Nr. Lote"    ,})
         Aadd(aCpos, {"CT2_SBLOTE" ,"","Sub. Lote"   ,})
         Aadd(aCpos, {"CT2_DOC"    ,"","Documento"   ,})	
         Aadd(aCpos, {"CT2_LINHA"  ,"","Seq. Lcto"   ,})
         Aadd(aCpos, {"CT2_DC"     ,"","Tipo Lcto"   ,})
         Aadd(aCpos, {"CT2_DEBITO" ,"","Cta Debito"  ,})		
         Aadd(aCpos, {"CT2_CREDIT" ,"","Cta Credito" ,}) 
         Aadd(aCpos, {"CT2_VALOR"  ,"","Valor"       ,})				
         Aadd(aCpos, {"CT2_HIST"   ,"","Historico"   ,})
         Aadd(aCpos, {"CT2_CCD"    ,"","C Custo Deb.",})		
         Aadd(aCpos, {"CT2_CCC"    ,"","C Custo Cred.",}) 
         Aadd(aCpos, {"CT2_ITEMD"  ,"","Canal Deb."  ,})				
         Aadd(aCpos, {"CT2_ITEMC"  ,"","Canal Cred." ,}) 
         Aadd(aCpos, {"CT2_CLVLDB" ,"","Plataf. Deb.",})		
         Aadd(aCpos, {"CT2_CLVLCR" ,"","Plataf. Cred.",}) 
         Aadd(aCpos, {"CT2_P_GEOG" ,"","Regiao"      ,})				
         Aadd(aCpos, {"CT2_P_PROJ" ,"","Projeto"     ,}) 
         Aadd(aCpos, {"CT2_P_CODE" ,"","Company"     ,})		
         Aadd(aCpos, {"CT2_AGLUT"  ,"","Aglutinado"  ,}) 
         Aadd(aCpos, {"CT2_DATATX" ,"","Data Conv."  ,})  
         Aadd(aCpos, {"CT2_TAXA"   ,"","Taxa Conv."  ,})         
         Aadd(aCpos, {"CT2_TPSALD" ,"","Tipo do Sld" ,})		
         Aadd(aCpos, {"CT2_EMPORI" ,"","Empresa Orig",}) 
         Aadd(aCpos, {"CT2_FILORI" ,"","Filial Orig" ,})  
         Aadd(aCpos, {"CT2_MOEDLC" ,"","Moeda Lancto",}) 
         Aadd(aCpos, {"CT2_P_ARQ" ,"","Arquivo"      ,})                   
         Aadd(aCpos, {"Log_Int"    ,"","Problema"    ,})
         Aadd(aCpos, {"Log_Aviso" ,"","Aviso"        ,}) 
      EndIf  
                                                   
      Aadd(aStruCT2, {"cINTEGRA"  ,"C",2   ,0})
      Aadd(aStruCT2, {"CT2Status" ,"C",8   ,0})        
      Aadd(aStruCT2, {"CT2_DATA"  ,"D",8   ,0}) 
      Aadd(aStruCT2, {"CT2_LOTE"  ,"C",6   ,0})
      Aadd(aStruCT2, {"CT2_SBLOTE","C",3   ,0})   
      Aadd(aStruCT2, {"CT2_DOC"   ,"C",6   ,0}) 
      Aadd(aStruCT2, {"CT2_LINHA" ,"C",3   ,0})
      Aadd(aStruCT2, {"CT2_DC"    ,"C",1   ,0})   
      Aadd(aStruCT2, {"CT2_DEBITO","C",20  ,0}) 
      Aadd(aStruCT2, {"CT2_CREDIT","C",20  ,0})
      Aadd(aStruCT2, {"CT2_VALOR" ,"N",17  ,2})   
      Aadd(aStruCT2, {"CT2_HIST"  ,"C",40  ,0}) 
      Aadd(aStruCT2, {"CT2_CCD"   ,"C",9   ,0})
      Aadd(aStruCT2, {"CT2_CCC"   ,"C",9   ,0})   
      Aadd(aStruCT2, {"CT2_ITEMD" ,"C",9   ,0}) 
      Aadd(aStruCT2, {"CT2_ITEMC" ,"C",9   ,0})
      Aadd(aStruCT2, {"CT2_CLVLDB","C",9   ,0})   
      Aadd(aStruCT2, {"CT2_CLVLCR","C",9   ,0})
      Aadd(aStruCT2, {"CT2_P_GEOG","C",2   ,0}) 
      Aadd(aStruCT2, {"CT2_P_PROJ","N",8   ,0})
      Aadd(aStruCT2, {"CT2_P_CODE","C",3   ,0})   
      Aadd(aStruCT2, {"CT2_AGLUT" ,"C",1   ,0})  
      Aadd(aStruCT2, {"CT2_DATATX","D",8   ,0})
      Aadd(aStruCT2, {"CT2_TAXA"  ,"N",8   ,4})
      Aadd(aStruCT2, {"CT2_TPSALD","C",1   ,0})   
      Aadd(aStruCT2, {"CT2_EMPORI","C",2   ,0})
      Aadd(aStruCT2, {"CT2_FILORI","C",2   ,0})  
      Aadd(aStruCT2, {"CT2_MOEDLC","C",2   ,0})
      Aadd(aStruCT2, {"CT2_P_ARQ" ,"C",40  ,0})           
      Aadd(aStruCT2, {"Log_Int"   ,"C",300 ,0})
      Aadd(aStruCT2, {"Log_Aviso" ,"C",300 ,0})
      Aadd(aStruCT2, {"nRecno"    ,"N",3   ,0}) 	   
      
      cNome := CriaTrab(aStruCT2, .T.)                   
      DbUseArea(.T.,"DBFCDX",cNome,'Int_CT2',.F.,.F.) 
      
      Indice1:=E_Create(,.F.)
      IndRegua("Int_CT2",Indice1+OrdBagExt(),"nRecno")
      
      Indice2:=E_Create(,.F.)
      IndRegua("Int_CT2",Indice2+OrdBagExt(),"CT2Status")   
      
      SET INDEX TO (Indice1+OrdBagExt()),(Indice2+OrdBagExt()) 
       
      If File(cArquivo)
	     FT_FUse(cArquivo)
	     FT_FGOTOP()
	     
	     Linha := FT_FReadLn()
	     
	     //Valida o arquivo
         If SubStr(Linha,01,03) == "CTB"  
            cCodEmp   := SubStr(Linha,04,02)		    		       
         Else
            MsgAlert(STR019,STR017) //"Arquivo de integração inválido, verifique o arquivo","Atenção" 
		    Return .F.          
         EndIf       
         
	     While !FT_FEof()
            Linha := FT_FReadLn() 
	        //Capa do Lançamento Contábil
		    If SubStr(Linha,01,03) == "LAN"
		       RecLock("Int_CT2",.T.)		    		
			   Int_CT2->CT2_DATA    := CtoD(SubStr(Linha,04,10))  
				 //Int_CT2->CT2_LOTE    := SubStr(Linha,14,06)  
			   Int_CT2->CT2_LOTE    := "200000"
			 //Int_CT2->CT2_SBLOTE  := SubStr(Linha,20,03)
			   Int_CT2->CT2_SBLOTE  := "001" 
			   Int_CT2->CT2_DOC     := StrZero(nDocSeq,6,0)
			   Int_CT2->CT2_LINHA   := StrZero(nCountItens,3,0) //SubStr(Linha,29,03)
			   Int_CT2->CT2_DC      := SubStr(Linha,32,01)
			   Int_CT2->CT2_DEBITO  := SubStr(Linha,33,20)
			   Int_CT2->CT2_CREDIT  := SubStr(Linha,53,20)     			   			 			   
			   Int_CT2->CT2_VALOR   := Val(SubStr(Linha,73,17))
			   Int_CT2->CT2_HIST    := SubStr(Linha,90,40)
			   Int_CT2->CT2_CCD     := SubStr(Linha,130,09)
			   Int_CT2->CT2_CCC     := SubStr(Linha,139,09)
			   Int_CT2->CT2_ITEMD   := SubStr(Linha,148,09)
			   Int_CT2->CT2_ITEMC   := SubStr(Linha,157,09) 
			   Int_CT2->CT2_CLVLDB  := SubStr(Linha,166,09)
			   Int_CT2->CT2_CLVLCR  := SubStr(Linha,175,09)
			   Int_CT2->CT2_P_PROJ  := Val(SubStr(Linha,184,8))
			   Int_CT2->CT2_P_ARQ   := Alltrim(cArq)   
			   Int_CT2->CT2_P_CODE  := SubStr(Linha,194,03)   
			   Int_CT2->CT2_P_GEOG  := SubStr(Linha,192,02)
			   cLog                 :="Arquivo com divergência de regra : "
			   Int_CT2->nRecno      := nRecno
			    
			   // Regras Discovery
			   If cEmpAnt $  ("48/49/50") 
			      //LANCAMENTO DEBITO
			      If Int_CT2->CT2_DC=="1" 
			         If SubStr(Int_CT2->CT2_DEBITO,1,1) $ "12"
                        If Int_CT2->CT2_ITEMD <>  "9910"
                           cLog+=" BRAND C/ "+Int_CT2->CT2_ITEMD+" , Acertado P/ : '9910'  |  "
                           Int_CT2->CT2_ITEMD:="9910"
                        EndIf   
                        If Int_CT2->CT2_CLVLDB <> "120"         
                           cLog+=" PLATAFORMA C/ "+Int_CT2->CT2_CLVLDB+" , Acertado com '120'  |  " 
                           Int_CT2->CT2_CLVLDB :="120"
                        EndIf         
                     EndIf

                     If cEmpAnt $  ("49")   // DISCOVERY COMUNICACAO DEBITO
                        // Testa Centro de Custo DEBITO
			            If Alltrim(Int_CT2->CT2_CCD) == "63031001" 
			               If Int_CT2->CT2_P_GEOG <> "US"			               
			                  cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'US'  |  " 
			                  Int_CT2->CT2_P_GEOG := "US" 
			               EndIf   
			               If alltrim(Int_CT2->CT2_CLVLDB) <> "210"         
                              cLog+=" PLATAFORMA C/ "+Int_CT2->CT2_CLVLDB+" , Acertado com '210'  |  " 
                              Int_CT2->CT2_CLVLDB :="210"
                           EndIf    
			            Else
			               If Alltrim(Int_CT2->CT2_P_GEOG) <> "BR" 
			                  cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'BR'  |  " 
			                  Int_CT2->CT2_P_GEOG := "BR" 
			               EndIf
			            EndIf   
                     
                        If Alltrim(Int_CT2->CT2_ITEMD)=="4100" 
                           If Int_CT2->CT2_P_CODE<>"313"  
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '313'  |  "               
                              Int_CT2->CT2_P_CODE:="313"
                           EndIf 
                        ElseIf Alltrim(Int_CT2->CT2_ITEMD)=="1000" 
                           If Int_CT2->CT2_P_CODE<>"323" 
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '323'  |  "                  
                              Int_CT2->CT2_P_CODE:="323"
                           EndIf               
                        Else
                           If Int_CT2->CT2_P_CODE<>"307"
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '307'  |  "                   
                              Int_CT2->CT2_P_CODE:="307"
                           EndIf                              
                        EndIf   

                     Else //PUBLICIDADE DEBITO
                        If Alltrim(Int_CT2->CT2_P_GEOG) <> "BR" 
			               cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'BR'  |  " 
			               Int_CT2->CT2_P_GEOG := "BR" 
			            EndIf   
			         
			            If Alltrim(Int_CT2->CT2_ITEMD)=="4100" 
                           If Alltrim(Int_CT2->CT2_P_CODE)<>"314"
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '314'  |  "               
                              Int_CT2->CT2_P_CODE:="314"
                           EndIf 
                        ElseIf  Alltrim(Int_CT2->CT2_ITEMD)=="1000" 
                           If Alltrim(Int_CT2->CT2_P_CODE)<>"324"   
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '324'  |  "             
                              Int_CT2->CT2_P_CODE:="324"
                           EndIf               
                        Else
                           If Alltrim(Int_CT2->CT2_P_CODE)<>"306" 
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '306'  |  "               
                              Int_CT2->CT2_P_CODE:="306"
                           EndIf                              
                        EndIf 
                     EndIf    
			      EndIf               
			   
			      //LANCAMENTO CREDITO			   
			      If Int_CT2->CT2_DC=="2" 
			         If SubStr(Int_CT2->CT2_CREDIT,1,1) $ "12"
                        If Alltrim(Int_CT2->CT2_ITEMC) <>  "9910"
                           cLog+=" BRAND C/ "+Int_CT2->CT2_ITEMC+" , Acertado P/ : 9910  |  "
                           Int_CT2->CT2_ITEMC:="9910"
                        EndIf   
                        If Alltrim(Int_CT2->CT2_CLVLCR) <> "120"         
                           cLog+=" PLATAFORMA C/ "+Int_CT2->CT2_CLVLCR+" , Acertado com 120  |  "
                           Int_CT2->CT2_CLVLCR :="120"
                        EndIf         
                     EndIf
                  
                     If cEmpAnt $  ("49")   //DISCOVERY COMUNICACAO CREDITO
                        // Testa Centro de Custo CREDITO
			            If Alltrim(Int_CT2->CT2_CCC) == "63031001" 
			               If alltrim(Int_CT2->CT2_P_GEOG) <> "US"			               
			                  cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'US'  |  " 
			                  Int_CT2->CT2_P_GEOG := "US" 
			               EndIf
			               If Alltrim(Int_CT2->CT2_CLVLCR) <> "210"         
                              cLog+=" PLATAFORMA C/ "+Int_CT2->CT2_CLVLCR+" , Acertado com 210  |  "
                              Int_CT2->CT2_CLVLCR :="210" 
                           EndIf    			              
			            Else
			               If Alltrim(Int_CT2->CT2_P_GEOG) <> "BR" 
			                  cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'BR'  |  " 
			                  Int_CT2->CT2_P_GEOG := "BR" 
			               EndIf
			            EndIf   
			         
			            If Alltrim(Int_CT2->CT2_ITEMC)=="4100" 
                           If Int_CT2->CT2_P_CODE<>"313"  
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '313'  |  "                  
                              Int_CT2->CT2_P_CODE:="313"                                       
                           EndIf 
                        ElseIf  Alltrim(Int_CT2->CT2_ITEMC)=="1000" 
                           If Int_CT2->CT2_P_CODE<>"323" 
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '323'  |  "             
                              Int_CT2->CT2_P_CODE:="323"
                           EndIf               
                        Else
                           If Empty(Int_CT2->CT2_P_CODE) .Or. (Int_CT2->CT2_P_CODE=="306")
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '307'  |  "                 
                              Int_CT2->CT2_P_CODE:="307"
                           EndIf                              
                        EndIf   
                     
                     Else //  DISCOVERY PUPLICIDADE CREDITO
                        If Alltrim(Int_CT2->CT2_P_GEOG) <> "BR" 
			               cLog+=" REGIAO C/ "+Int_CT2->CT2_P_GEOG+" , Acertado com 'BR'  |  " 
			               Int_CT2->CT2_P_GEOG := "BR" 
			            EndIf           
			         
			            If Alltrim(Int_CT2->CT2_ITEMC)=="4100" 
                           If Int_CT2->CT2_P_CODE<>"314"  
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '314'  |  "            
                              Int_CT2->CT2_P_CODE:="314"
                           EndIf 
                        ElseIf  Alltrim(Int_CT2->CT2_ITEMC)=="1000" 
                           If Int_CT2->CT2_P_CODE<>"324" 
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '324'  |  "                
                              Int_CT2->CT2_P_CODE:="324"
                           EndIf               
                        Else
                           If Empty(Int_CT2->CT2_P_CODE) .Or. (Int_CT2->CT2_P_CODE=="307")
                              cLog+=" COMPANY C/ "+Int_CT2->CT2_P_CODE+" , Acertado com '306'  |  "             
                              Int_CT2->CT2_P_CODE:="306"
                           EndIf                              
                        EndIf 
                     EndIf   
			      EndIf		 
			   EndIf
			                   
			   Int_CT2->LOG_Aviso   :=cLog
			   //Intercompany
			   Int_CT2->CT2_AGLUT   := SubStr(Linha,198,01)
			   Int_CT2->CT2_DATATX  := CtoD(SubStr(Linha,199,10)) 
			   Int_CT2->CT2_TAXA    := Val(SubStr(Linha,209,8))  
			   	            
			   lInt:=.T.  // Necessário inicializar com .T. a cada validação 
			  
			   Int_CT2->LOG_INT     := Validacoes("CT2") // Validacoes dos campos, retorna Log e seta variavel lInt com .F. caso recusado.
			   	     
               If lInt   
                  Int_CT2->CT2Status:=STR020 
               Else    
                  Int_CT2->CT2Status:=STR021                     
               EndIf 
               
			   nCountCapa++                    
			   nCountItens++
			   nRecno++
			   
     		   Int_CT2->(MsUnlock())
		    EndIf 
	        FT_FSkip()	                      
	     EndDo              
	     nDocSeq++ 
	    
	     Int_CT2->(DBGoTop())
	     //Contador de aceitos
	     While Int_CT2->(!EOF())      
	        If Alltrim(Int_CT2->CT2Status) $ Alltrim(STR020)   
	           nCountAc++
	        EndIf   
	        Int_CT2->(DbSkip())
	     EndDo   

	     If select("Int_CT2") > 0
	        Int_CT2->(DBGoTop())                                         //Altura/Comprimento
            DEFINE MSDIALOG oDlg TITLE "Lançamento Contábil" FROM 000,000 TO 545,1100 PIXEL  
                oTOleContainer := TOleContainer():New( 021,640,052,20,oDlg,.T.,cImg1)   
                        
                @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL     
                @ 021 , 010 Say  STR022     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 057 Say  Alltrim(cArq)          COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,6 OF oDlg  
                @ 033 , 010 Say  STR023     PIXEL SIZE 60,6 OF oDlg 
                @ 033 , 057 Say  Alltrim(Str(nCountCapa))    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
                @ 021 , 250 Say  STR024     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 280 Say  Alltrim(cUserName)         COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
                @ 033 , 250 Say  STR025     PIXEL SIZE 60,6 OF oDlg
                @ 033 , 280 Say  Date()                     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
                @ 021 , 350 Say  STR026     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 390 Say  Alltrim(Str(nCountAc))     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
                @ 021 , 460 Say  "MOEDA"   COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 485 COMBOBOX cMoeda ITEMS aMoeda  PIXEL SIZE 40,6 OF oDlg 
                //@ 033 , 230 Say  STR027             PIXEL SIZE 60,6 OF oDlg         
                oTHButton := THButton():New(28,340,STR027,oDlg,{||Alert(STR028)},40,20,,STR029)
                @ 033 , 390 Say  Alltrim(Str(nCountCapa-nCountAc)) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg     
                oFont := TFont():New('Courier new',,-14,.T.)
                oTMsgBar := TMsgBar():New(oDlg,STR061,.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
                oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
                oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})                  
                                                                                               
     	        oMarkPrd:= MsSelect():New("Int_CT2","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545})   
            ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||Grava_Pedido("CT2")},{|| Finaliza()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
         EndIf
         FT_FUse() 
      EndIf 
      Int_CT2->(DBCLoseArea())   
Return

/*
Funcao      : GeraArqRa()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico funcionário.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/ 
*-----------------------------------*
Static Function GeraArqRa(cArqTxt)
*-----------------------------------*
ProcRegua(0)

Private cCampo:=""
Private lCrt:=.F.
Private aCampos:={}
Private nPos:=0
Private nCnt:=0                   
Private aCabExcel:={}
Private aDadExcel:={}
Private aCampos1:={}

//variaveis que controlam campos Obrigatórios
Private aCpoObrigat:={}
Private cCpoFaltantes:=""
Private lCpoFal:=.F.

Private lTemDup:=.F.
Private cTemDup:="" 

//Busca do SX3 os campos Obrigatórios
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SRA")
	
	while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SRA"
		if X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)
			AADD(aCpoObrigat,SX3->X3_CAMPO)
		endif
	
	SX3->(DBSkip())
	enddo
//Fim Busca no SX3 de campos Obrigatórios

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If "RA_" $ UPPER(aLinha[1])
		//Verifica se os campos obrigatórios estão no arquivo
		for cont:=1 to len(aCpoObrigat)
			if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			endif
		next
		
		if !Empty(cCpoFaltantes)
			Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		endif
		//Fim da verificação dos campos obrigatórios
	
	    For i:=1 to len(aLinha)
			If "RA_" $ UPPER(aLinha[i])
		 		cCampo:=Alltrim(aLinha[i])
		 		
		 		DBSELECTAREA("SX3")
				dbsetorder(2)
				If Dbseek(cCampo)
					if aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
						lTemDup:=.T.
						cTemDup+=cCampo+","
					endif
					
					AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
			    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
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
Enddo

if empty(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de produtos!")
	FT_FUse()
	Return	
endif

if lTemDup
	alert("Exitem campos iguais no arquivo: "+cTemDup)
	FT_FUse()
	Return
endif

If lCpoFal
	FT_FUse()
	Return
EndIf	

Private cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     
FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	
	Begin Transaction	
		Reclock("XXX",.T.) 
    	for nK:=1 to len(aCampos1)
    		if !empty(aCampos1[nK][1])
    			if aCampos1[nK][2]=="N"
    				XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val(aLinha[nK]))
    		    elseif aCampos1[nK][2]=="D"
    		    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
    		    else
    		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
    		    endif
    		endif	
        next
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction

	IncProc("Lendo item RA_MAT: "+alltrim(XXX->RA_MAT))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutRa()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutRa()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico funcionário.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*---------------------------*
Static Function ExecAutRa   
*---------------------------*
Local xAutoCab := {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}

/* INICIO Tabela temporária para armaznar os erros*/
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

if select("WWW")>0
	WWW->(DbCloseArea())
endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)
/* FIM Tabela temporária para armaznar os erros*/

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 
	xAutoCab := {}
	for nl:=1 to len(aCampos)
		AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next
	
	Private lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	
	BEGIN Transaction
		MSExecAuto({|x,y,z,w| GPEA010(x,y,z,w)},,,xAutoCab,3) 
	
		If lMsErroAuto
			cErroCon:=""
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
			//msginfo(cErroCon) 
		   	if !("RA_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
		   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
	       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
	       		if nPoTit<>0
	       			cErroCon+=" "+ aCampos[nPoTit][1]
	       		endif
	    	endif    
	    	
	    	AADD(aErros,{alltrim(XXX->RA_MAT),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
		    lErro:=.T.
		    DisarmTransaction()
		    
			Reclock("WWW",.T.)
		    	WWW->CODIGO:=alltrim(XXX->RA_MAT)
		    	WWW->SITUACAO:="Erro"
		    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
		    WWW->(MsUnlock())
		Else
			lOk:=.T.
			AADD(aGravado,{alltrim(XXX->RA_MAT),"OK","Inserido"})
				Reclock("WWW",.T.)
		    		WWW->CODIGO:=alltrim(XXX->RA_MAT)
		    		WWW->SITUACAO:="Ok"
		    		WWW->DESCRICAO:="Inserido"	    
		    	WWW->(MsUnlock())
		EndIF            
	
		END Transaction
	XXX->(DbSkip())
enddo

If lErro
	Situacao(aErros,aGravado)	
	//cMemo+="Existem dados que não foram incluidos, clique no botão (Erros), para verificar!!"
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return(iif(lErro,.F.,.T.))

/*
Funcao      : GeraArqW1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico solicitação importação.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/09/11 18:15
*/ 
*-----------------------------------*
Static Function GeraArqW1(cArqTxt)
*-----------------------------------*
Local cLinha     := ""
Local cNomeSW1   := "" 
Local cProd      := ""  
Local cFabr      := ""
Local cForn      := ""
Local cLjFabr    := ""
Local cLjForn    := ""    
Local cMsgSB1    := ""  
Local cMoeda     := ""        
Local cUnidade   := ""  
Local cComprador := ""
Local cLocal     := ""
Local cNum       := GetSxENum("SW0","W0__NUM")
Local n          := 1
Local nReg       := 1  
Local aLinha     := {} 
Local aStruSW1   := {}

Confirmsx8()

	If Select("Int_SW1")>0
		Int_SW1->(DBCLoseArea())  	
	EndIf

	aStruSW1 := SW1->(dbStruct())
	cNomeSW1 := CriaTrab(aStruSW1, .T.)                   
	DbUseArea(.T.,,cNomeSW1,'Int_SW1',.F.,.F.)       

	For nSW1:= 1 To Len(aStruSW1)
 		If aStruSW1[nSW1][2] <> "C" .and.  FieldPos(aStruSW1[nSW1][1]) > 0
   			TcSetField("Int_SW1",aStruSW1[nSW1][1],aStruSW1[nSW1][2],aStruSW1[nSW1][3],aStruSW1[nSW1][4])
     	EndIf
 	Next

	FT_FUse(cArqTxt) // Abre o arquivo
	FT_FGOTOP()      // Posiciona no inicio do arquivo

	//1.Produto / 2.Fabricante / 3.Loja Fabricante / 4.Fornecedor / 5.Loja Fornecedor / 6.Quantidade / 7.Moeda / 8.Preco / 9.Unidade / 10.Comprador /11.Local /12.Adicao /13.Sequencia da Adição /14.Lote /15.Data Lote /16.SEQT                          
	While !FT_FEof()
   		cLinha := FT_FReadln()        // Le a linha
 		aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
                                   
		If Alltrim(aLinha[1]) $ "PRODUTO/TIPO: ALFANUMERICO ,TAMANHO: 15 ,FORMATO: SEM FORMATO/W1_COD_I"
			FT_FSkip()
			Loop
		EndIf

	    //Testa se é mesmo produto para o registro nReg
        If alltrim(cProd)<>Alltrim(aLinha[1])
        	nReg:=1
        	cProd:=aLinha[1]
        Else
        	nReg++
        EndIf                
      
        If len(aLinha[1]) < 15 // Valida o tamanho do código do produto
        	cProd := aLinha[1]+space(15-Len(aLinha[1]))
        EndIf
                                                         
        If len(aLinha[2]) < 6 // Valida o tamanho do código do fabricante
        	cFabr := Replicate("0",6-Len(aLinha[2]))+aLinha[2]
        EndIf 
                                            
        If len(aLinha[3]) < 2 // Valida o tamanho do código da loja do fabricante
        	cLjFabr := Replicate("0",2-Len(aLinha[3]))+aLinha[3]
        EndIf

        If len(aLinha[4]) < 6 // Valida o tamanho do código do fornecedor
        	cForn := Replicate("0",6-Len(aLinha[4]))+aLinha[4]
        EndIf 

        If len(aLinha[5]) < 2 // Valida o tamanho do código da loja do fornecedor
        	cLjForn := Replicate("0",2-Len(aLinha[5]))+aLinha[5]
        EndIf

        If (Alltrim(aLinha[7]) $ "EUR/US$" )  // Valida moeda
        	cMoeda := alltrim(aLinha[7])  
        Else	
        	MsgStop("Moeda "+Alltrim(cMoeda)+" invalida, preencher com US$ ou EUR , necessario gerar o arquivo novamente.","Grant Thornton" ) 
        	Return .F.	
        EndIf

        SY3->(DbSetOrder(1))  // Valida a unidade requisitante
        If !(SY3->(DbSeek(xFilial("SY3")+aLinha[9]+space(5-Len(aLinha[9])))))
        	MsgStop("Unidade requisitante "+Alltrim(aLinha[9])+" não encontrada no cadastro, necessario gerar o arquivo novamente.","Grant Thornton" ) 
        	Return .F.		        
        Else
        	cUnidade:=Alltrim(aLinha[9])+space(5-Len(aLinha[9]))
        EndIF         

        SY1->(DbSetOrder(1))  // Valida o comprador
        If !(SY1->(DbSeek(xFilial("SY1")+aLinha[10]+space(2-Len(aLinha[10])))))
        	MsgStop("Comprador "+Alltrim(aLinha[10])+" não encontrado no cadastro, necessario gerar o arquivo novamente.","Grant Thornton" ) 
        	Return .F.
        Else
        	cComprador:=Alltrim(aLinha[10])			        
        EndIF    
        
        SY2->(DbSetOrder(1))  // Valida o local de entrega
        If !(SY2->(DbSeek(xFilial("SY2")+aLinha[11]+space(3-Len(aLinha[11])))))
        	MsgStop("Local"+Alltrim(aLinha[11])+" não encontrada no cadastro, necessario gerar o arquivo novamente.","Grant Thornton" ) 
        	Return .F. 
        Else
        	cLocal :=Alltrim(aLinha[11])  	     			        
        EndIF            

	    //Valida se o item existe.
	    SB1->(DbSetOrder(1))
	    If SB1->(DbSeek(xFilial("SB1")+cProd ))
			//Valida se o cadastro Produto x Fornecedor existe. 
		 	SA5->(DbSetOrder(3))
		  	If SA5->(DbSeek(xFilial("SA5")+cProd+cFabr+cForn)) 	
		   		RecLock("Int_SW1",.T.)
		    	Int_SW1->W1_FILIAL   := xFilial("SW1")   
		    	Int_SW1->W1_COD_I    := cProd
				Int_SW1->W1_FABR     := cFabr
				Int_SW1->W1_FORN	 := cForn	
				//Produto deve ter quantidade
				If val(aLinha[6]) < 0.01
					MsgStop("Produto "+Alltrim(cProd)+" não possui quantidade, necessario gerar o arquivo novamente.","Grant Thornton" ) 
					Int_SW1->(DbCloseArea())  
					Return .F. 								
				Else
					Int_SW1->W1_QTDE     :=  Val(aLinha[6])
				EndIf     
							
				Int_SW1->W1_SALDO_Q  := Val(aLinha[6])
				Int_SW1->W1_PRECO    := Val(aLinha[8])   
				Int_SW1->W1_CLASS    := "1"
				Int_SW1->W1_SEQ      := 0	 
				Int_SW1->W1_REG      := nReg
				//RRP - 22/08/2013 - Inclusão da Loja do Fabricando e Fornecedor na Integração. Chamado 013639.
				Int_SW1->W1_FABLOJ	 := cLjFabr
                Int_SW1->W1_FORLOJ	 := cLjForn
                
				//RRP - 20/08/12 - Validação para empresa que possui customização de adição
				If	SW1->(FieldPos("W1_P_ADI" )) > 0 .and. SW1->(FieldPos("W1_P_SEQAD" )) > 0
					Int_SW1->W1_P_ADI    := aLinha[12]
					Int_SW1->W1_P_SEQAD  := aLinha[13]
				EndIf
                //RRP - 03/07/12 - Validação para empresa que possui customização de lote 
				If	SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0
					Int_SW1->W1_P_LOTE   := aLinha[14]
					Int_SW1->W1_P_DTLOT  := STOD(aLinha[15])
					Int_SW1->W1_P_SEQT   := aLinha[16] 
				EndIf		
				Int_SW1->(MsUnlock())
 			Else    
 				SA2->(DbSetOrder(1))
 				If !(SA2->(DbSeek(xFilial("SA2")+cForn+cLjForn)))
 					MsgStop("Fornecedor :"+Alltrim(cForn)+" "+Alltrim(cLjForn)+" não possui cadastro.","Grant Thornton" ) 
					Int_SW1->(DbCloseArea())  
					Return .F. 				
 				EndIf
 				SA2->(DbSetOrder(1))
 				If !(SA2->(DbSeek(xFilial("SA2")+cFabr)))
 					MsgStop("Fabricante :"+Alltrim(cFabr)+" "+Alltrim(cLjFabr)+" não possui cadastro.","Grant Thornton" )  
					Int_SW1->(DbCloseArea())  
					Return .F. 				
 				EndIf
 				//Inclui vinculo do SA5
     			RecLock("SA5",.T.)		    
			  	SA5->A5_FILIAL   := xFilial("SA5")   
			    SA5->A5_FORNECE  := cForn
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+cForn+cLjForn))
					SA5->A5_NOMEFOR  := SA2->A2_NOME 
				EndIf
				SA5->A5_PRODUTO  := cProd
				SA5->A5_NOMPROD  := SB1->B1_DESC
				SA5->A5_FABR     := cFabr 
				SA5->A5_FALOJA   := cLjFabr 
    			SA5->(MsUnlock()) 
       			//Inclui dados da SI
       			RecLock("Int_SW1",.T.)		    
			   	Int_SW1->W1_FILIAL   := xFilial("SW1")   
			   	Int_SW1->W1_COD_I    := cProd
				Int_SW1->W1_FABR     := cFabr
				Int_SW1->W1_FORN	 := cForn	
				Int_SW1->W1_QTDE     := Val(aLinha[6])    //RRP - 10/08/2012 - Transformar caracter em numérico
				Int_SW1->W1_SALDO_Q  := Val(aLinha[6])    //RRP - 10/08/2012 - Transformar caracter em numérico
				Int_SW1->W1_PRECO    := Val(aLinha[8])    //RRP - 10/08/2012 - Transformar caracter em numérico
				Int_SW1->W1_CLASS    := "1"
				Int_SW1->W1_SEQ      := 0	 
				Int_SW1->W1_REG      := nReg
				Int_SW1->W1_CC       := "001"
				//RRP - 22/08/2013 - Inclusão da Loja do Fabricando e Fornecedor na Integração. Chamado 013639.
				Int_SW1->W1_FABLOJ	 := cLjFabr
                Int_SW1->W1_FORLOJ	 := cLjForn   

    			//RRP - 20/08/12 - Validação para empresa que possui customização de adição
    			If SW1->(FieldPos("W1_P_ADI")) > 0 .and. SW1->(FieldPos("W1_P_SEQAD")) > 0
    				Int_SW1->W1_P_ADI    := aLinha[12]
    				Int_SW1->W1_P_SEQAD  := aLinha[13]
    			EndIf

				//RRP - 03/07/12 - Validação para empresa que possui customização de lote
				If	SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0
					Int_SW1->W1_P_LOTE   := aLinha[14]
					Int_SW1->W1_P_DTLOT  := STOD(aLinha[15])
					Int_SW1->W1_P_SEQT   := aLinha[16] 
    			EndIf					    
				Int_SW1->(MsUnlock())                
			EndIf
		Else 
			If Len(cMsgSB1) <  400
				cMsgSB1+=Alltrim(aLinha[1])+" / "  
			EndIf						
		Endif
		FT_FSkip()
	EndDo

	If !Empty(cMsgSB1)
		MsgStop(cMsgSB1,"PRODUTO(S) NAO CADASTRADO(S)")
		Return .F.
	EndIf
	    
	//Grava a S.I.   
	SW0->(DbSetOrder(1))
	If !(SW0->(DbSeek(xFilial("SW0")+cUnidade+cNum)))
		SW1->(DbSetOrder(1))
		If !(SW1->(DbSeek(xFilial("SW1")+cUnidade+cNum)))
			RecLock("SW0",.T.) 
	  		SW0->W0_FILIAL := xFilial("SW0")
		    SW0->W0__CC    := cUnidade  
			SW0->W0__NUM   := cNum
		 	SW0->W0__DT    := dDataBase
		 	SW0->W0__POLE  := cLocal
			SW0->W0_COMPRA := cComprador
			SW0->W0_MOEDA  := cMoeda 
			SW0->W0_SOLIC  := "INTEGRADO POR ARQUIVO"
    		SW0->(MsUnlock())
	       	Int_SW1->(DbGoTop())
           	While Int_SW1->(!EOF())
    			RecLock("SW1",.T.)
    			SW1->W1_FILIAL  := Int_SW1->W1_FILIAL   
				SW1->W1_COD_I   := Int_SW1->W1_COD_I 
				SW1->W1_FORN    := Int_SW1->W1_FORN 
				SW1->W1_FABR    := Int_SW1->W1_FABR
				SW1->W1_QTDE    := Int_SW1->W1_QTDE   
				SW1->W1_SALDO_Q := Int_SW1->W1_SALDO_Q  
				SW1->W1_PRECO   := Int_SW1->W1_PRECO    
				SW1->W1_CLASS   := Int_SW1->W1_CLASS   
				SW1->W1_SEQ     := Int_SW1->W1_SEQ      	 
				SW1->W1_REG     := Int_SW1->W1_REG      
			 	SW1->W1_CC      := cUnidade                    
				SW1->W1_SI_NUM  := cNum
				SW1->W1_DT_EMB  := Date()
				SW1->W1_DTENTR_ := Date()+1
				//RRP - 22/08/2013 - Inclusão da Loja do Fabricando e Fornecedor na Integração. Chamado 013639.
				SW1->W1_FABLOJ	:= Int_SW1->W1_FABLOJ
                SW1->W1_FORLOJ	:= Int_SW1->W1_FORLOJ
                
                //RRP - 20/08/12 - Validação para empresa que possui customização de adição
                If SW1->(FieldPos("W1_P_ADI")) > 0 .and. SW1->(FieldPos("W1_P_SEQAD")) > 0
					SW1->W1_P_ADI   := Int_SW1->W1_P_ADI
					SW1->W1_P_SEQAD := Int_SW1->W1_P_SEQAD
				EndIf

                //RRP - 03/07/12 - Validação para empresa que possui customização de lote
                If	SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0 
					SW1->W1_P_LOTE  := Int_SW1->W1_P_LOTE
					SW1->W1_P_DTLOT := Int_SW1->W1_P_DTLOT
					SW1->W1_P_SEQT  := Int_SW1->W1_P_SEQT 
					SW1->(MsUnlock())
                EndIf
				SW1->(MsUnlock())
       			Int_SW1->(DbSkip())
    		EndDo
    		MsgInfo("S.I. : "+Alltrim(cNum)+" incluida com sucesso.")	
			Int_SW1->(DbCloseArea())  
			//Confirmsx8()
		Else
			MsgStop("Número da S.I. invalido, entrar em contato com suporte","Promega")
		EndIf
	Else
		MsgStop("Número da S.I. invalido, entrar em contato com suporte","Promega")
	EndIf

	Erase &cNomeSW1+".DBF"
	
Return lRet				         

/*
Funcao      : GeraArqCT2()
Parametros  : cArqTxt
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico lançamento contabil.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 19/10/2011 17:15
*/                   
*-----------------------------------*
Static Function GeraArqCT2(cArqTxt)
*-----------------------------------*
ProcRegua(0)

Private nPos :=0
Private nCnt :=0                   
Private aCabExcel  :={}
Private aDadExcel  :={}
Private aCampos1   :={}
Private aCampos    :={}
Private aCpoObrigat:={}

//variaveis que controlam campos Obrigatórios
Private lCrt    :=.F.
Private lCpoFal :=.F.
Private lTemDup :=.F.
Private cCampo       := ""
Private cTemDup      := "" 
Private cArqTrab     := ""
Private cCpoFaltantes:= ""

	//Busca do SX3 os campos Obrigatórios
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("CT2")
	
	AADD(aCpoObrigat,"CT2_DATA")
	AADD(aCpoObrigat,"CT2_LOTE")
	AADD(aCpoObrigat,"CT2_SBLOTE")
	AADD(aCpoObrigat,"CT2_DOC")	
	
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="CT2"
		if SX3->X3_CAMPO $ "CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC"
			SX3->(DBSkip())
			loop
		endif
		If X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)
			AADD(aCpoObrigat,SX3->X3_CAMPO)
		Endif
	
	SX3->(DBSkip())
	Enddo        
	                                   
	FT_FUse(cArqTxt) // Abre o arquivo
	FT_FGOTOP()      // Posiciona no inicio do arquivo

	While !FT_FEof()
   		cLinha := FT_FReadln()        // Le a linha
 		aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
		If "CT2" $ UPPER(aLinha[1])
			//Verifica se os campos obrigatórios estão no arquivo
			For cont:=1 to len(aCpoObrigat)
				If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
					cCpoFaltantes+=aCpoObrigat[cont]+","
				Endif
			Next

			If !Empty(cCpoFaltantes)
				Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
    			lCpoFal:=.T.
    			Exit
			Endif

			//Fim da verificação dos campos obrigatórios
    		For i:=1 to len(aLinha)
				If "CT2" $ UPPER(aLinha[i])
	 				cCampo:=Alltrim(aLinha[i])
	 				DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup:=.T.
							cTemDup+=cCampo+","
						Endif
						//if cCampo $ "CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC"
						//	loop
						//endif
						AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
		   		 		AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
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

	Enddo

	If Empty(aCampos) .AND. !lCpoFal
		Alert("Arquivo selecionado não possui campos para importação de fornecedores!")
		FT_FUse()
		Return	
	EndIf

	If lTemDup
		alert("Exitem campos iguais no arquivo: "+cTemDup)
		FT_FUse()
		Return
	EndIf

	If lCpoFal
		FT_FUse()
		Return
	EndIf	

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, ("DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC"),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     


FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    
	if empty(alltrim(STRTRAN(cLinha,";")))
		FT_FSkip() // Proxima linha
		loop
	endif
	Begin Transaction	
		Reclock("XXX",.T.) 
	   	For nK:=1 to Len(aCampos1)
	   		If !Empty(aCampos1[nK][1])
	   			If aCampos1[nK][2]=="N"
	   				XXX->&(aCampos1[nK][1]):= IIf(Empty(aLinha[nK]),0,Val(aLinha[nK]))
	   		    ElseIf aCampos1[nK][2]=="D"
	   		    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
	   		    Else
	   		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	   		    EndIf
	   		EndIf	
		Next
	    XXX->(MsUnlock())           
	    //Confirmsx8()
	End Transaction
	
	IncProc("Lendo : "+alltrim(DTOS(XXX->CT2_DATA)+","+XXX->CT2_LOTE+","+XXX->CT2_SBLOTE+","+XXX->CT2_DOC))
	FT_FSkip() // Proxima linha
Enddo

FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutCT2()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet) 

/*
Funcao      : ExecAutCT2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico contabil.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/02/11 18:15
*/
*----------------------------*
 Static Function ExecAutCT2()
*----------------------------* 
Local aItem := {}
Local aItens:= {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}
Local cRecUlt:=""
 
// Incio Tabela temporária para armaznar os erros

AADD(aCpos,{"CODIGO","C",20,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

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

Private aCab := { {'DDATALANC' ,XXX->CT2_DATA ,NIL},;
                 {'CLOTE' ,XXX->CT2_LOTE ,NIL},;
                 {'CSUBLOTE' ,XXX->CT2_SBLOTE ,NIL},;
                 {'CDOC' , XXX->CT2_DOC ,NIL},;
                 {'CPADRAO' ,'' ,NIL},;
                 {'NTOTINF' ,0 ,NIL},;
                 {'NTOTINFLOT' ,0 ,NIL} }

Private cRenXXX:=XXX->(Recno())
Private cNumAnt:=alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)       

XXX->(DbSkip())
If alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)==cNumAnt 
	XXX->(Dbgoto(cRenXXX))
	cSeqLinha:="000"
    while alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)==cNumAnt 
		aItem:={}    
		for nl:=1 to len(aCampos)
		if aCampos[nl][1] $ "CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC"
			loop
		endif
		
		if aCampos[nl][1]=='CT2_LINHA'
			//if Ascan( aItens, {|d| d[1][2] == Upper(XXX->&(aCampos[nl][1])) } )>0 .OR. empty(XXX->&(aCampos[nl][1]))
				cSeqLinha:=SOMA1(cSeqLinha)
				RecLock("XXX",.F.)
					XXX->&(aCampos[nl][1]):=cSeqLinha
					//XXX->&(aCampos[nl][1]):=SOMA1(XXX->&(aCampos[nl][1]))
				XXX->(MsUnlock())
			//endif
		endif

			AADD(aItem,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
		next
	
		AADD(aItens,aItem)

	cNumAnt:=alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)
	cRecUlt:=XXX->(Recno())
	XXX->(DbSkip())
	
	enddo	
	XXX->(Dbgoto(cRecUlt))    
else
XXX->(Dbgoto(cRenXXX))
	aItem:={}
	for nl:=1 to len(aCampos)
		if aCampos[nl][1] $ "CT2_DATA/CT2_LOTE/CT2_SBLOTE/CT2_DOC"
			loop
		endif
		AADD(aItem,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next

	AADD(aItens,aItem)
endif

Private lMsErroAuto:= .f.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

BEGIN Transaction
	MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3) //Inclusao

	If lMsErroAuto
		cErroCon:=""
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 
		//msginfo(cErroCon) 
	   	if !("CT2_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
	   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
       		if nPoTit<>0
       			cErroCon+=" "+ aCampos[nPoTit][1]
       		endif
    	endif    
    	AADD(aErros,{alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
	    lErro:=.T.
	    DisarmTransaction()

		Reclock("WWW",.T.)
    	WWW->CODIGO:=alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)
    	WWW->SITUACAO:="Erro"
    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
	    WWW->(MsUnlock())

	Else
		lOk:=.T.
		AADD(aGravado,{alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC),"OK","Inserido"})
		
			Reclock("WWW",.T.)
	    		WWW->CODIGO:=alltrim(DTOS(XXX->CT2_DATA)+XXX->CT2_LOTE+XXX->CT2_SBLOTE+XXX->CT2_DOC)
	    		WWW->SITUACAO:="Ok"
	    		WWW->DESCRICAO:="Inserido"	    
	    	WWW->(MsUnlock())
	EndIF            

	END Transaction

aItens:={}

XXX->(DbSkip())
enddo

If lErro
	Situacao(aErros,aGravado)	
	//cMemo+="Existem dados que não foram incluidos, clique no botão (Erros), para verificar!!"
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqSG1()
Parametros  : cArqTxt
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico para cadastro de Estrutura de Produtos.
Autor       : Matheus Massarotto
Data/Hora   : 23/04/2012 17:49
*/                   
*-----------------------------------*
Static Function GeraArqSG1(cArqTxt)
*-----------------------------------*
ProcRegua(0)

Private nPos :=0
Private nCnt :=0                   

Private aCabExcel  :={}
Private aDadExcel  :={}
Private aCampos1   :={}
Private aCampos    :={}
Private aCpoObrigat:={}

//variaveis que controlam campos Obrigatórios
Private lCrt    :=.F.
Private lCpoFal :=.F.
Private lTemDup :=.F.

Private cCampo       := ""
Private cTemDup      := "" 
Private cArqTrab     := ""
Private cCpoFaltantes:= ""

	//Busca do SX3 os campos Obrigatórios
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SG1")
	
	AADD(aCpoObrigat,"G1_COD")
	AADD(aCpoObrigat,"G1_INI")
	AADD(aCpoObrigat,"G1_TRT")
	
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SG1"
	
		if SX3->X3_CAMPO $ "G1_COD/G1_INI/G1_TRT"
			SX3->(DBSkip())
			loop
		endif
		If X3OBRIGAT(SX3->X3_CAMPO) .AND. X3USO(SX3->X3_USADO)
			AADD(aCpoObrigat,SX3->X3_CAMPO)
		Endif
	
	SX3->(DBSkip())
	Enddo        
	                                   
	FT_FUse(cArqTxt) // Abre o arquivo
	FT_FGOTOP()      // Posiciona no inicio do arquivo

	While !FT_FEof()
   		cLinha := FT_FReadln()        // Le a linha
 		aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

		If "G1" $ UPPER(aLinha[1])

			//Verifica se os campos obrigatórios estão no arquivo
			For cont:=1 to len(aCpoObrigat)
				If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
					cCpoFaltantes+=aCpoObrigat[cont]+","
				Endif
			Next

			If !Empty(cCpoFaltantes)
				Alert("Os campos obrigatórios não estão no arquivo: "+cCpoFaltantes)
    			lCpoFal:=.T.
    			Exit
			Endif

			//Fim da verificação dos campos obrigatórios
    		For i:=1 to len(aLinha)
				If "G1" $ UPPER(aLinha[i])
	 				cCampo:=Alltrim(aLinha[i])
	 				DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan( aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup:=.T.
							cTemDup+=cCampo+","
						Endif

						AADD(aCampos,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
		   		 		AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
		  			EndIf 
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
	Enddo

	If Empty(aCampos) .AND. !lCpoFal
		Alert("Arquivo selecionado não possui campos para importação de estrutura de produtos!")
		FT_FUse()
		Return	
	EndIf

	If lTemDup
		alert("Exitem campos iguais no arquivo: "+cTemDup)
		FT_FUse()
		Return
	EndIf

	If lCpoFal
		FT_FUse()
		Return
	EndIf	

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, ("G1_COD+G1_COMP+G1_TRT"),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() // Fecha o arquivo                     

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTO(nPos)      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
    
	if empty(alltrim(STRTRAN(cLinha,";")))
		FT_FSkip() // Proxima linha
		loop
	endif
	Begin Transaction	
		Reclock("XXX",.T.) 
	   	For nK:=1 to Len(aCampos1)
	   		If !Empty(aCampos1[nK][1])
	   			If aCampos1[nK][2]=="N"
	   				XXX->&(aCampos1[nK][1]):= IIf(Empty(aLinha[nK]),0,Val(aLinha[nK]))
	   		    ElseIf aCampos1[nK][2]=="D"
	   		    	XXX->&(aCampos1[nK][1]):= STOD(aLinha[nK])    		    	
	   		    Else
	   		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	   		    EndIf
	   		EndIf	
		Next
	    XXX->(MsUnlock())           
	    //Confirmsx8()
	End Transaction
	
	IncProc("Lendo : "+alltrim(XXX->G1_COD+","+XXX->G1_COMP+","+XXX->G1_TRT))
	FT_FSkip() // Proxima linha
Enddo

FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutSG1()//Chamada da função de processamento.
 
fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet) 

/*
Funcao      : ExecAutSG1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, Estrutura de produtos.
Autor       : Matheus Massarotto
Data/Hora   : 23/04/2012 17:47
*/
*----------------------------*
 Static Function ExecAutSG1()
*----------------------------* 
Local aItem := {}
Local aItens:= {}
Local aErros:={}
Local aGravado:={}
Local lErro:=.F.
Local lOk:=.F.
Local aCpos:={}
Local cRecUlt:=""
 
// Incio Tabela temporária para armaznar os erros

AADD(aCpos,{"CODIGO","C",20,0})
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",200,0})

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


Private aCab := { {'G1_COD' ,XXX->G1_COD ,NIL},;
                  {'G1_QUANT' ,1 ,NIL},;
                  {'NIVALT' ,"S",NIL}}			// A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura

Private cRenXXX:=XXX->(Recno())
Private cNumAnt:=alltrim(XXX->G1_COD)       

XXX->(DbSkip())
If alltrim(XXX->G1_COD)==cNumAnt 
	XXX->(Dbgoto(cRenXXX))
    while alltrim(XXX->G1_COD)==cNumAnt 
		aItem:={}    
		for nl:=1 to len(aCampos)
			AADD(aItem,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
		next
	
		AADD(aItens,aItem)
	
	cNumAnt:=alltrim(XXX->G1_COD)
	cRecUlt:=XXX->(Recno())
	XXX->(DbSkip())
	
	enddo	
	XXX->(Dbgoto(cRecUlt))    
else
XXX->(Dbgoto(cRenXXX))
	aItem:={}
	for nl:=1 to len(aCampos)
		if aCampos[nl][1] $ "G1_COD"
			loop
		endif
		AADD(aItem,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	next
	
	AADD(aItens,aItem)
endif

Private lMsErroAuto:= .f.
Private lMSHelpAuto := .t.
Private lAutoErrNoFile := .T.

BEGIN Transaction

	MSExecAuto( {|X,Y,Z| MATA200(X,Y,Z)} ,aCab ,aItens, 3) //Inclusao

	If lMsErroAuto
		cErroCon:=""
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 
		//msginfo(cErroCon) 
	   	if !("G1_" $ STRTRAN(cErroCon,CHR(13)+CHR(10)) )
	   		cTit:= STRTRAN( STRTRAN(alltrim(substr(cErroCon,rat("."+CHR(13)+CHR(10),cErroCon)+1,len(cErroCon)) ),";"),CHR(13)+CHR(10) )		
       		nPoTit:=aScan( aCampos, { |x| alltrim(x[5]) == cTit} )
       		if nPoTit<>0
       			cErroCon+=" "+ aCampos[nPoTit][1]
       		endif
    	endif    
    	
    	AADD(aErros,{alltrim(XXX->G1_COD+XXX->G1_COMP+XXX->G1_TRT),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
	    lErro:=.T.
	    DisarmTransaction()
	    
		Reclock("WWW",.T.)
	    	WWW->CODIGO:=alltrim(XXX->G1_COD+XXX->G1_COMP+XXX->G1_TRT)
	    	WWW->SITUACAO:="Erro"
	    	WWW->DESCRICAO:=STRTRAN(cErroCon,CHR(13)+CHR(10))	    
	    WWW->(MsUnlock())
	Else
		lOk:=.T.
		AADD(aGravado,{alltrim(XXX->G1_COD+XXX->G1_COMP+XXX->G1_TRT),"OK","Inserido"})
		
			Reclock("WWW",.T.)
	    		WWW->CODIGO:=alltrim(XXX->G1_COD+XXX->G1_COMP+XXX->G1_TRT)
	    		WWW->SITUACAO:="Ok"
	    		WWW->DESCRICAO:="Inserido"	    
	    	WWW->(MsUnlock())
		
	EndIF            
		
	END Transaction

aItens:={}

XXX->(DbSkip())
enddo

If lErro
	Situacao(aErros,aGravado)	
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

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
Funcao      : VerNCMSB1()
Parametros  : aAltNcm
Retorno     : cArqConte
Objetivos   : Função que gera a tela com os produtos e a ncm cadastrada e a da planilha, para o usuário selecionar qual ele irá alterar
Autor       : Matheus Massarotto
Data/Hora   : 07/08/2012
*/
*--------------------------------*
Static Function VerNCMSB1(aAltNcm)
*--------------------------------*
Local 	cMensagem	:=""

Local cCabec	:="Atenção"
Local nOpc		:=4
Local nRet:=0
		cMensagem	:="Existe(m) produto(s) já cadastrado(s) com NCM diferente(s)!"+CRLF
		cMensagem	+="Deseja realmente alterar a NCM cadastrada?"+CRLF+CRLF
		cMensagem	+="Obs: Caso atualize será gravado um log de alteração!"

Private _oDlg3,oListBox
Private aListBox	:={}
Private cNick 		:="Selecione os produtos que serão alterados"
Private aHeader		:={}
Private aAlter		:={"M_OK"}
Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
Private nUsado		:=0

Private aCols:={}

Private lCheckBox1	:=.F.
Private oCheckBox1
		
/* Opções do MessageBox
MB_OK                 0
MB_OKCANCEL           1
MB_YESNO              4
MB_ICONHAND           16
MB_ICONQUESTION       32
MB_ICONEXCLAMATION    48
MB_ICONASTERISK       64

// Retornos possíveis do MessageBox
IDOK                  1
IDCANCEL              2
IDYES                 6
IDNO                  7
*/ 

If !Empty(aAltNcm)
	nRet:=MessageBox ( cMensagem, cCabec, nOpc )
Endif

if nRet==6
	
Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}
					
			AADD(aHeader,{ TRIM(""),;
								 "M_OK",;
								 "@BMP",;
								 2,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Cod Produto"),;
								 "M_COD",;
								 "@X  ",;
								 15,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Descricao"),;
								 "M_DESC",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("NCM PRODUTO"),;
								 "M_NCMPRO",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("NCM PLANILHA"),;
								 "M_NCMPLA",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1

For nSeqNcm:=1 to len(aAltNcm)
	AADD(aCols,{})
	AADD(aCols[nSeqNcm],oNo)
	for nSeqNcm2:=1 to len(aAltNcm[nSeqNcm])
		AADD(aCols[nSeqNcm],aAltNcm[nSeqNcm][nSeqNcm2])
	next
	
	AADD(aCols[nSeqNcm],.F.)
Next

DEFINE MSDIALOG _oDlg3 TITLE cNick FROM C(178),C(180) TO C(665),C(966) PIXEL

  	// Cria as grupo no envia todos
  	@ C(16),C(003) TO C(25),C(50) LABEL "" PIXEL OF _oDlg3
	@ C(17),C(005) CheckBox oCheckBox1 Var lCheckBox1 Prompt "Marca Todos" Size C(048),C(009) PIXEL OF _oDlg3
	oCheckBox1:bLClicked := {|| marcatudo() }
	  
oGetDados := MsGetDados():New(35, 05, 270, 500, 4, "AllwaysTrue()", "AllwaysTrue()",;
"", .T., aAlter, , .F., 999, "AllwaysTrue()", "AllwaysTrue()",,;
"AllwaysTrue()", _oDlg3)

	@ C(230),C(300) Button "&Atualizar" Size C(037),C(012) PIXEL OF _oDlg3 action(AtualizaNCM())
	@ C(230),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg3 action(_oDlg3:end())
	
	oGetDados :AddAction ( "M_OK"		, {||MudaStatus()	})

	oGetDados :ForceRefresh()
ACTIVATE MSDIALOG _oDlg3 CENTERED 	
	
endif

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
Funcao      : AtualizaNCM
Parametros  : 
Retorno     : 
Objetivos   : Função para atualizar a NCM do produto
Autor       : Matheus Massarotto
Data/Hora   : 08/08/2012
*/
*-----------------------------*
Static Function AtualizaNCM
*-----------------------------*
Local cQry		:=""
Local cMsgErro	:=""
Local cMsgLog	:=""

	for nSeq:=1 to len(aCols)
		if aCols[nSeq][1]==oOk
			cQry:="	UPDATE "+RETSQLNAME("SB1")+" SET B1_POSIPI='"+aCols[nSeq][5]+"' WHERE D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD='"+aCols[nSeq][2]+"'"
			//cQry:="	UPDATE SB1ZB0 SET B1_POSIPI='"+aCols[nSeq][5]+"' WHERE D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD='"+aCols[nSeq][2]+"'"
			
			If TCSQLExec(cQry) < 0 
				cMsgErro+=aCols[nSeq][2]+","
				cMsgLog:="PRUDUTO: "+aCols[nSeq][2]+" - "+TCSQLError()
				CriaLog(cMsgLog)
			Else
				cMsgLog:="PRUDUTO: "+alltrim(aCols[nSeq][2])+" - Atualizado campo B1_POSIPI de:"+alltrim(aCols[nSeq][4])+", para:"+alltrim(aCols[nSeq][5])
				CriaLog(cMsgLog)
			Endif
			
		endif
	next
	
	if !empty(cMsgErro)
		cMsgErro:=SUBSTR(cMsgErro,1,len(cMsgErro)-1)
		Alert("Não foi possível atualizar o(s) produto(s):"+CRLF+cMsgErro)
		
	else
		MsgInfo("Finalizado atualização!")
		_oDlg3:end()
	endif

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
Local aDePara := {	"SB1","SA1","SA2","","SF1","SC5","CT2",""   ,"SRA","SW1",;
					   "","SG1",""   ,"","SA5","SE1","SN1","SW2","SF1","SB9",;
					"SE2","CND"}

If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")
     Return
EndIf

Private cTab		:= ""
Private aDadTemp	:= {}
Private aDadTemp2	:= {}
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
        
	If Alltrim(cTab)=="SW1"
		//AADD(aDadTemp,{ cTit ,"C",65,0})  
		AADD(aDadTemp,{ "Produto"      ,"C",65,0})
		AADD(aDadTemp,{ "Fabricante"   ,"C",65,0})
		AADD(aDadTemp,{ "LojaFabr"     ,"C",65,0}) 
		AADD(aDadTemp,{ "Fornecedor"   ,"C",65,0}) 
		AADD(aDadTemp,{ "LojaForn"     ,"C",65,0})
		AADD(aDadTemp,{ "Quantidade"   ,"C",65,0})		 
		AADD(aDadTemp,{ "Moeda"        ,"C",65,0})
		AADD(aDadTemp,{ "VlrUnit"      ,"C",65,0}) 
		AADD(aDadTemp,{ "Unidade"      ,"C",65,0}) 
		AADD(aDadTemp,{ "Comprador"    ,"C",65,0})
		AADD(aDadTemp,{ "Local"        ,"C",65,0})   
		//RRP - 20/08/12 - Validação para empresa que possui customização de adição
		If SW1->(FieldPos("W1_P_ADI" )) > 0 .and. SW1->(FieldPos("W1_P_SEQAD" )) > 0
			AADD(aDadTemp,{ "Adicao"      ,"C",65,0})
        	AADD(aDadTemp,{ "SeqAd"       ,"C",65,0})
        EndIf
		//RRP - 03/07/12 - Validação para empresa que possui customização de lote
		If SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0
           	AADD(aDadTemp,{ "Lote"        ,"C",65,0})
        	AADD(aDadTemp,{ "DtLote"      ,"C",65,0})
        	AADD(aDadTemp,{ "SeqT"        ,"C",65,0})
		EndIf
		//AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
		AADD(aDadTemp2,{ "W1_COD_I" ,"C",15,0})  
		AADD(aDadTemp2,{ "W1_FABR"  ,"C",6 ,0}) 
		AADD(aDadTemp2,{ "LOJAFBR"  ,"C",2 ,0})
		AADD(aDadTemp2,{ "W1_FORN"  ,"C",6 ,0}) 
		AADD(aDadTemp2,{ "LOJAFORN" ,"C",2 ,0})
		AADD(aDadTemp2,{ "W1_QTDE"  ,"N",13,3}) 
		AADD(aDadTemp2,{ "MOEDA"    ,"C",3 ,0})
		AADD(aDadTemp2,{ "W1_PRECO" ,"N",15,5}) 
		AADD(aDadTemp2,{ "W1_CC"    ,"C",5 ,0}) 
		AADD(aDadTemp2,{ "Comprador","C",3 ,0})
		AADD(aDadTemp2,{ "Local"    ,"C",2 ,0})                                                                    
 		//RRP - 20/08/12 - Validação para empresa que possui customização de adição
		If	SW1->(FieldPos("W1_P_ADI" )) > 0 .and. SW1->(FieldPos("W1_P_SEQAD" )) > 0
			AADD(aDadTemp2,{ "W1_P_ADI"    ,"C",3 ,0})
			AADD(aDadTemp2,{ "W1_P_SEQAD"  ,"C",3 ,0})
		EndIf 
		//RRP - 03/07/12 - Validação para empresa que possui customização de lote
		If	SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0		
			AADD(aDadTemp2,{ "W1_P_LOTE"   ,"C",10,0})
			AADD(aDadTemp2,{ "W1_P_DTLOT"  ,"C",8 ,0})
			AADD(aDadTemp2,{ "W1_P_SEQT"   ,"C",3 ,0})		
		EndIf                                               

	ElseIf Alltrim(cTab)=="SW2"
		AADD(aDadTemp,{ "Pedido"	,"C",65,0})
		AADD(aDadTemp,{ "DtPedido"	,"C",65,0})
		AADD(aDadTemp,{ "Forn" 		,"C",65,0})
		AADD(aDadTemp,{ "LjForn"	,"C",65,0})
		AADD(aDadTemp,{ "Despachan" ,"C",65,0})
		AADD(aDadTemp,{ "Import"	,"C",65,0})
		AADD(aDadTemp,{ "Agente"	,"C",65,0})
		AADD(aDadTemp,{ "ViaTrans"	,"C",65,0})
		AADD(aDadTemp,{ "Origem"	,"C",65,0})
		AADD(aDadTemp,{ "Detino"	,"C",65,0})
		AADD(aDadTemp,{ "Incoterm"	,"C",65,0})
		AADD(aDadTemp,{ "FreteCC"	,"C",65,0})
		AADD(aDadTemp,{ "CondPag"	,"C",65,0})
		AADD(aDadTemp,{ "Moeda"		,"C",65,0})
		AADD(aDadTemp,{ "DtPar"		,"C",65,0})
		AADD(aDadTemp,{ "Parid"		,"C",65,0})
		AADD(aDadTemp,{ "CodComprad","C",65,0})
		AADD(aDadTemp,{ "CartaCred"	,"C",65,0})
		AADD(aDadTemp,{ "CodProd" 	,"C",65,0})
        AADD(aDadTemp,{ "UnidRequis","C",65,0})
        AADD(aDadTemp,{ "Reg"  		,"C",65,0})
        AADD(aDadTemp,{ "Preco" 	,"C",65,0})
        AADD(aDadTemp,{ "Fabricante","C",65,0})
        AADD(aDadTemp,{ "LjFabr"	,"C",65,0})
        AADD(aDadTemp,{ "Qtde" 		,"C",65,0})
        AADD(aDadTemp,{ "DtEmb"		,"C",65,0})
        AADD(aDadTemp,{ "DtEntr"	,"C",65,0})
        AADD(aDadTemp,{ "SaldoQtde"	,"C",65,0})
		If SW1->(FieldPos("W1_P_ADI" )) > 0 .and. SW1->(FieldPos("W1_P_SEQAD" )) > 0
			AADD(aDadTemp,{ "Adicao"      ,"C",65,0})
        	AADD(aDadTemp,{ "SeqAd"       ,"C",65,0})
        EndIf
		If SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0
           	AADD(aDadTemp,{ "Lote"        ,"C",65,0})
        	AADD(aDadTemp,{ "DtLote"      ,"C",65,0})
        	AADD(aDadTemp,{ "SeqT"        ,"C",65,0})
		EndIf
		
		AADD(aDadTemp2,{ "W2_PO_NUM"	, AvSX3("W2_PO_NUM")[2]	, AvSX3("W2_PO_NUM")[3]	, AvSX3("W2_PO_NUM")[4]	})
		AADD(aDadTemp2,{ "W2_PO_DT"		, AvSX3("W2_PO_DT")[2]	, AvSX3("W2_PO_DT")[3]	, AvSX3("W2_PO_DT")[4]	})
		AADD(aDadTemp2,{ "W2_FORN"		, AvSX3("W2_FORN")[2]	, AvSX3("W2_FORN")[3]	, AvSX3("W2_FORN")[4]	})
		AADD(aDadTemp2,{ "W2_FORLOJ"	, AvSX3("W2_FORLOJ")[2]	, AvSX3("W2_FORLOJ")[3]	, AvSX3("W2_FORLOJ")[4]	})
		AADD(aDadTemp2,{ "W2_DESP"		, AvSX3("W2_DESP")[2]	, AvSX3("W2_DESP")[3]	, AvSX3("W2_DESP")[4]	})
		AADD(aDadTemp2,{ "W2_IMPORT"	, AvSX3("W2_IMPORT")[2]	, AvSX3("W2_IMPORT")[3]	, AvSX3("W2_IMPORT")[4]	})
		AADD(aDadTemp2,{ "W2_AGENTE"	, AvSX3("W2_AGENTE")[2]	, AvSX3("W2_AGENTE")[3]	, AvSX3("W2_AGENTE")[4]	})
		AADD(aDadTemp2,{ "W2_TIPO_EM"	, AvSX3("W2_TIPO_EM")[2], AvSX3("W2_TIPO_EM")[3], AvSX3("W2_TIPO_EM")[4]})
		AADD(aDadTemp2,{ "W2_ORIGEM"	, AvSX3("W2_ORIGEM")[2]	, AvSX3("W2_ORIGEM")[3]	, AvSX3("W2_ORIGEM")[4]	})
		AADD(aDadTemp2,{ "W2_DEST"		, AvSX3("W2_DEST")[2]	, AvSX3("W2_DEST")[3]	, AvSX3("W2_DEST")[4]	})
		AADD(aDadTemp2,{ "W2_INCOTER"	, AvSX3("W2_INCOTER")[2], AvSX3("W2_INCOTER")[3], AvSX3("W2_INCOTER")[4]})
		AADD(aDadTemp2,{ "W2_FREPPCC"	, AvSX3("W2_FREPPCC")[2], AvSX3("W2_FREPPCC")[3], AvSX3("W2_FREPPCC")[4]})
		AADD(aDadTemp2,{ "W2_COND_PA"	, AvSX3("W2_COND_PA")[2], AvSX3("W2_COND_PA")[3], AvSX3("W2_COND_PA")[4]})
		AADD(aDadTemp2,{ "W2_MOEDA"		, AvSX3("W2_MOEDA")[2]	, AvSX3("W2_MOEDA")[3]	, AvSX3("W2_MOEDA")[4]	})
		AADD(aDadTemp2,{ "W2_DT_PAR"	, AvSX3("W2_DT_PAR")[2]	, AvSX3("W2_DT_PAR")[3]	, AvSX3("W2_DT_PAR")[4]	})
		AADD(aDadTemp2,{ "W2_PARID_U"	, AvSX3("W2_PARID_U")[2], AvSX3("W2_PARID_U")[3], AvSX3("W2_PARID_U")[4]})
		AADD(aDadTemp2,{ "W2_COMPRA"	, AvSX3("W2_COMPRA")[2] , AvSX3("W2_COMPRA")[3] , AvSX3("W2_COMPRA")[4]})
		AADD(aDadTemp2,{ "W2_E_LC"		, AvSX3("W2_E_LC")[2]	, AvSX3("W2_E_LC")[3]	, AvSX3("W2_E_LC")[4]	})
		AADD(aDadTemp2,{ "W3_COD_I" 	, AvSX3("W3_COD_I")[2]	, AvSX3("W3_COD_I")[3]	, AvSX3("W3_COD_I")[4]	})
        AADD(aDadTemp2,{ "W3_CC"	  	, AvSX3("W3_CC")[2]		, AvSX3("W3_CC")[3]		, AvSX3("W3_CC")[4]		})
        AADD(aDadTemp2,{ "W3_REG"   	, AvSX3("W3_REG")[2]	, AvSX3("W3_REG")[3]	, AvSX3("W3_REG")[4]	})
        AADD(aDadTemp2,{ "W3_PRECO" 	, AvSX3("W3_PRECO")[2]	, AvSX3("W3_PRECO")[3]	, AvSX3("W3_PRECO")[4]	})
        AADD(aDadTemp2,{ "W3_FABR"  	, AvSX3("W3_FABR")[2]	, AvSX3("W3_FABR")[3]	, AvSX3("W3_FABR")[4]	})
        AADD(aDadTemp2,{ "W3_FABLOJ"  	, AvSX3("W3_FABLOJ")[2]	, AvSX3("W3_FABLOJ")[3]	, AvSX3("W3_FABLOJ")[4]	})
        AADD(aDadTemp2,{ "W3_QTDE"  	, AvSX3("W3_QTDE")[2]	, AvSX3("W3_QTDE")[3]	, AvSX3("W3_QTDE")[4]	})
        AADD(aDadTemp2,{ "W3_DT_EMB"	, AvSX3("W3_DT_EMB")[2]	, AvSX3("W3_DT_EMB")[3]	, AvSX3("W3_DT_EMB")[4]	})
        AADD(aDadTemp2,{ "W3_DT_ENTR"	, AvSX3("W3_DT_ENTR")[2], AvSX3("W3_DT_ENTR")[3], AvSX3("W3_DT_ENTR")[4]})
        AADD(aDadTemp2,{ "W3_SALDO_Q"	, AvSX3("W3_SALDO_Q")[2], AvSX3("W3_SALDO_Q")[3], AvSX3("W3_SALDO_Q")[4]})
		If	SW1->(FieldPos("W1_P_ADI" )) > 0 .and. SW1->(FieldPos("W1_P_SEQAD" )) > 0
			AADD(aDadTemp2,{ "W1_P_ADI"    ,"C",3 ,0})
			AADD(aDadTemp2,{ "W1_P_SEQAD"  ,"C",3 ,0})
		EndIf 
		If	SW1->(FieldPos("W1_P_LOTE")) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0		
			AADD(aDadTemp2,{ "W1_P_LOTE"   ,"C",10,0})
			AADD(aDadTemp2,{ "W1_P_DTLOT"  ,"C",8 ,0})
			AADD(aDadTemp2,{ "W1_P_SEQT"   ,"C",3 ,0})		
		EndIf
	ElseIf Alltrim(cTab)=="SB9"
		aCposMod := {"B9_COD","B9_LOCAL","B9_QINI"}

		DBSELECTAREA("SX3")
		dbsetorder(2)
		For b:=1 to Len(aCposMod)
			If Dbseek(aCposMod[b])
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
		   		AADD(aDadTemp,{ cTit ,"C",65,0})
				AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
			EndIf
		Next b 

	ElseIf Alltrim(cTab)=="SN1"
		aCposMod := 	{"N3_CCONTAB","N1_CBASE","N1_ITEM","N1_AQUISIC","N1_DESCRIC","N1_QUANTD",;
						"N3_HISTOR","N3_CCUSTO","N3_DINDEPR",;
						"N1_CHAPA"}

		DBSELECTAREA("SX3")
		dbsetorder(2)
		For b:=1 to Len(aCposMod)
			If Dbseek(aCposMod[b])
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
		   		AADD(aDadTemp,{ cTit ,"C",65,0})
				AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
			EndIf
		Next b 
		
		AADD(aDadTemp,{"CNPJFORN" ,"C",65,0})
		AADD(aDadTemp,{"NOMEFORN" ,"C",65,0})
		AADD(aDadTemp2,{"CNPJFORN","C",14,0}) 
		AADD(aDadTemp2,{"NOMEFORN","C",35,0})    

	ElseIf Alltrim(cTab)=="CND"
		aCposMod := 	{"CND_CONTRA","CND_COMPET","CND_MOEDA","CNE_PRODUT",;
						"CNE_QUANT","CNE_VLUNIT"}  
						
		DBSELECTAREA("SX3")
		dbsetorder(2)
		For b:=1 to Len(aCposMod)
			If Dbseek(aCposMod[b])
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
		   		AADD(aDadTemp,{ cTit ,"C",65,0})
				AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
			EndIf
		Next b 

	ElseIf Alltrim(cTab)=="SF1"
		If nSelec == 19
			aCposMod := {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_COND","F1_EMISSAO","F1_ESPECIE","F1_TIPO","F1_FORMUL",;
						"D1_COD","D1_ITEM","D1_QUANT","D1_VUNIT","D1_TOTAL"}
		ElseIf nSelec == 5
			aCposMod := {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_COND","F1_EMISSAO","F1_TIPO","F1_DTDIGIT","F1_EST",;
						"D1_ITEM","D1_COD","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL",;
						"D1_TES","D1_PEDIDO","D1_ITEMPC","D1_LOCAL","D1_TIPO","D1_CF","D1_RATEIO","D1_TP"}
		EndIf

		DBSELECTAREA("SX3")
		dbsetorder(2)
		For b:=1 to Len(aCposMod)
			If Dbseek(aCposMod[b])
				cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
		   		AADD(aDadTemp,{ cTit ,"C",65,0})
				AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
			EndIf
		Next b

	ElseIf Alltrim(cTab)=="SC5"
		nAdiciObri	:= AdicioObrig() //Função que retorna se adiciona obrigatório 1-Sim / 2-Não, específico para Pedido de venda
		//Se for português
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
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))
			if SX3->(DbSeek("C5_P_REF"))
				AADD(aDadTemp,{ "Num Refere"     ,"C",65,0}) 
				nTamC5+=1
			endif
			//-----------------SC6----------------------//
			AADD(aDadTemp,{ "Item"         ,"C",65,0})
			AADD(aDadTemp,{ "Produto"      ,"C",65,0})
			AADD(aDadTemp,{ "Descricao"    ,"C",65,0}) 
			AADD(aDadTemp,{ "Quantidade"   ,"C",65,0})
			AADD(aDadTemp,{ "PrcUnit"      ,"C",65,0})		 
			AADD(aDadTemp,{ "Valor"        ,"C",65,0})
			AADD(aDadTemp,{ "TES"          ,"C",65,0})
			nTamC6:=len(aDadTemp)
			//-----------------SA1----------------------//
			AADD(aDadTemp,{ "CPF_CNPJ"     ,"C",65,0})
			AADD(aDadTemp,{ "Nome"         ,"C",65,0})
			AADD(aDadTemp,{ "Fisic_Juri"   ,"C",65,0}) 
			AADD(aDadTemp,{ "NFantasia"    ,"C",65,0})
			AADD(aDadTemp,{ "Endereco"     ,"C",65,0})
			AADD(aDadTemp,{ "Estado"       ,"C",65,0})
			AADD(aDadTemp,{ "CodCidade"    ,"C",65,0})
			AADD(aDadTemp,{ "Cidade"       ,"C",65,0})
			AADD(aDadTemp,{ "Bairro"       ,"C",65,0})
			AADD(aDadTemp,{ "CEP"          ,"C",65,0})
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
			//-----------------SC6----------------------//
			AADD(aDadTemp,{ "Item"         ,"C",65,0})
			AADD(aDadTemp,{ "Product"      ,"C",65,0})
			AADD(aDadTemp,{ "Descriptio"   ,"C",65,0}) 
			AADD(aDadTemp,{ "Quantity" 	   ,"C",65,0})
			AADD(aDadTemp,{ "UnitPrice"    ,"C",65,0})		 
			AADD(aDadTemp,{ "GrandTotal"   ,"C",65,0})
			AADD(aDadTemp,{ "OutFlowTyp"   ,"C",65,0})
			nTamC6:=len(aDadTemp)
			//-----------------SA1----------------------//
			AADD(aDadTemp,{ "CPF_CNPJ"     ,"C",65,0})
			AADD(aDadTemp,{ "Name"         ,"C",65,0})
			AADD(aDadTemp,{ "Type"         ,"C",65,0}) 
			AADD(aDadTemp,{ "TradeName"    ,"C",65,0})
			AADD(aDadTemp,{ "Address"      ,"C",65,0})
			AADD(aDadTemp,{ "State"    	   ,"C",65,0})
			AADD(aDadTemp,{ "CodCity"      ,"C",65,0})
			AADD(aDadTemp,{ "City"         ,"C",65,0})
			AADD(aDadTemp,{ "NeighborHo"   ,"C",65,0})
			AADD(aDadTemp,{ "ZipCode"      ,"C",65,0})		
			nTamA1:=len(aDadTemp)
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
		//-----------------SC6----------------------//
		AADD(aDadTemp2,{ "C6_ITEM" 		,"C",2 	,0})  
		AADD(aDadTemp2,{ "C6_PRODUTO"  	,"C",15	,0}) 
		AADD(aDadTemp2,{ "C6_DESCRI"	,"C",60	,0})
		AADD(aDadTemp2,{ "C6_QTDVEN"  	,"N",9 	,2}) 
		AADD(aDadTemp2,{ "C6_PRCVEN" 	,"N",14	,2})
		AADD(aDadTemp2,{ "C6_VALOR"  	,"N",14	,2}) 
		AADD(aDadTemp2,{ "C6_TES"  		,"C",3	,0})        
		//-----------------SA1----------------------//
		AADD(aDadTemp2,{ "A1_CGC" 		,"C",14	,0})
		AADD(aDadTemp2,{ "A1_NOME"  	,"C",40	,0})
		AADD(aDadTemp2,{ "A1_PESSOA"	,"C",1	,0})
		AADD(aDadTemp2,{ "A1_NREDUZ"  	,"C",20 ,0})
		AADD(aDadTemp2,{ "A1_END" 		,"C",40	,0})
		AADD(aDadTemp2,{ "A1_EST"  		,"C",40	,0})
		AADD(aDadTemp2,{ "A1_COD_MUN"  	,"C",5	,0})	
		AADD(aDadTemp2,{ "A1_MUN"  		,"C",30	,0})
		AADD(aDadTemp2,{ "A1_BAIRRO"  	,"C",30	,0})
		AADD(aDadTemp2,{ "A1_CEP"  		,"C",8	,0})
        //Deve ser adicionado campos obrigatorios do SX3? SIM
		If nAdiciObri==1
			//Adiciona campos obrigatórios faltantes do SC5
			DbSelectArea("SX3")
			Dbsetorder(1)
			If Dbseek("SC5")
				while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SC5")
					if x3Obrigat(SX3->X3_CAMPO) .AND. SX3->X3_CAMPO<>"C5_NUM" ;
					.AND. SX3->X3_CAMPO<>"C5_TIPO" .AND. SX3->X3_CAMPO<>"C5_TIPOCLI" ;
					.AND. SX3->X3_CAMPO<>"C5_CONDPAG" .AND. SX3->X3_CAMPO<>"C5_EMISSAO" ;
					.AND. SX3->X3_CAMPO<>"C5_MENNOTA"
							cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
							
						    AINS(aDadTemp,nTamC5+1)
	  					    AINS(aDadTemp2,nTamC5+1)
	  					    
					   		aDadTemp[nTamC5+1] :={ cTit ,"C",65,0}
							aDadTemp2[nTamC5+1]:={X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL}
					 
							nTamC5+=1
							nTamC6+=1
							nTamA1+=1
					endif
			    	SX3->(DbSkip())
				enddo		
			Endif
	
			//Adiciona campos obrigatórios faltantes do SC6
			DbSelectArea("SX3")
			Dbsetorder(1)
			If Dbseek("SC6")
				while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SC6")
					if x3Obrigat(SX3->X3_CAMPO) .AND. SX3->X3_CAMPO<>"C6_ITEM" ;
					 .AND. SX3->X3_CAMPO<>"C6_PRODUTO" ;
					 .AND. SX3->X3_CAMPO<>"C6_DESCRI" .AND. SX3->X3_CAMPO<>"C6_QTDVEN" ;
					 .AND. SX3->X3_CAMPO<>"C6_PRCVEN" .AND. SX3->X3_CAMPO<>"C6_VALOR" ;
					 .AND. SX3->X3_CAMPO<>"C6_TES"
							cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
						    AINS(aDadTemp,nTamC6+1)
	  					    AINS(aDadTemp2,nTamC6+1)
					   		aDadTemp[nTamC6+1] :={ cTit ,"C",65,0}
							aDadTemp2[nTamC6+1]:={X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL}
							nTamC5+=1
							nTamC6+=1
							nTamA1+=1
					endif
			    	SX3->(DbSkip())		
				enddo		
			Endif
			//Adiciona campos obrigatórios faltantes do SC6
			DbSelectArea("SX3")
			Dbsetorder(1)
			If Dbseek("SA1")
				while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER("SA1")
					if x3Obrigat(SX3->X3_CAMPO) .AND. SX3->X3_CAMPO<>"A1_CGC" ;
						.AND. SX3->X3_CAMPO<>"A1_NOME" .AND. SX3->X3_CAMPO<>"A1_PESSOA" ;
						.AND. SX3->X3_CAMPO<>"A1_NREDUZ" .AND. SX3->X3_CAMPO<>"A1_END" ;
						.AND. SX3->X3_CAMPO<>"A1_EST" .AND. SX3->X3_CAMPO<>"A1_COD_MUN" ;
						.AND. SX3->X3_CAMPO<>"A1_MUN" .AND. SX3->X3_CAMPO<>"A1_BAIRRO" ;
						.AND. SX3->X3_CAMPO<>"A1_CEP"
							cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
							AADD(aDadTemp,{ cTit ,"C",65,0})
							AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
					endif
			    	SX3->(DbSkip())		
				enddo		
			Endif
        Endif

	Else 
		DBSELECTAREA("SX3")
		dbsetorder(1)
		If Dbseek(cTab)
			while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==UPPER(cTab)
				if x3Obrigat(SX3->X3_CAMPO)
					//RRP - 03/12/2013 - Inclusão do Produto x Fornecedor.
					If	(Alltrim(SX3->X3_CAMPO) == "B1_REQUIS") .Or. (Alltrim(SX3->X3_CAMPO) == "B1_CRDEST")  .Or.;
						(Alltrim(SX3->X3_CAMPO) == "B1_CODITE") .or. (Alltrim(SX3->X3_CAMPO) == "A5_SITU") .Or.;
						 (Alltrim(SX3->X3_CAMPO) == "A5_TEMPLIM")  .Or.  (Alltrim(SX3->X3_CAMPO) == "A5_FABREV")
						SX3->(DbSkip())
						Loop
					Else	
						cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)

				   		AADD(aDadTemp,{ cTit ,"C",65,0})
						AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})    
				 
					EndIf
				Else           
				    // RRP - 09/12/2013 - Inclusão dos campos A5_PRODUTO e A5_CODPRF no modelo Produto x Fornecedor.
					If	Alltrim(SX3->X3_CAMPO)=="B1_PICM" .Or. Alltrim(SX3->X3_CAMPO)=="B1_IPI" .Or.;
						Alltrim(SX3->X3_CAMPO)=="A5_PRODUTO" .Or. Alltrim(SX3->X3_CAMPO)=="A5_CODPRF" .Or.;
						Alltrim(SX3->X3_CAMPO)=="CT2_DEBITO" .Or. Alltrim(SX3->X3_CAMPO)=="CT2_CREDIT" .Or.;
						ALLTRIM(SX3->X3_CAMPO) == "G1_COD" .OR.  ALLTRIM(SX3->X3_CAMPO) == "G1_INI" .OR.;
						ALLTRIM(SX3->X3_CAMPO) == "G1_TRT"

						cTit := GetTitle(SUBSTR(IIF(nIdioma==1,X3_TITULO,X3_TITENG),1,10),aDadTemp)
				   		AADD(aDadTemp,{ cTit ,"C",65,0})
						AADD(aDadTemp2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})  
					EndIf
   				endif    
				SX3->(DbSkip())
		 	enddo
        else
        	alert("Problemas para encontrar tabela modelo!")
        	return
		endif
    EndIf
    
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
		for nS:=1 to len(aDadTemp)  
			if alltrim(aDadTemp2[nS][2])=="N"
				cModTip:=IIF(nIdioma==1,"Numerico","Numerical")
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"Sem formato","Unbodied")
			elseif alltrim(aDadTemp2[nS][2])=="D"
				cModTip:=IIF(nIdioma==1,"Data","Date")
				cModTam:=alltrim(cvaltochar(aDadTemp2[nS][3]))
				cModForm:=IIF(nIdioma==1,"aaaammdd","yyyymmdd")
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
	        	DADXLS->&(aDadTemp[nS][1]):="Tipo: "+cModTip+" ,Tamanho: "+cModTam+" ,Formato: "+cModForm
		    else
			    DADXLS->&(aDadTemp[nS][1]):="Type: "+cModTip+" ,Size: "+cModTam+" ,Format: "+cModForm
		    endif
		next	
	DADXLS->(MsUnlock())
End Transaction

//Armazena linha com o nome dos campos no excel
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

Return

/*
Funcao      : Validar()
Parametros  : XML da NFE
Retorno     : Nil
Objetivos   : Validar a NFE no Sefaz
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/08/11 10:00
*/ 
*------------------------------------*
Static Function Validar(oXml)
*------------------------------------*
Local cChaveNFe := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
Local cIdEnt 	:= GetIdEnt()

Local cURL      := PadR("http://10.0.30.22:5076",250)
Local cMensagem := ""
Local oWS    

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT    	 := "000001"//cIdEnt
ows:cCHVNFE		 := cChaveNFe
oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"              

If oWs:ConsultaChaveNFE() 
	cMensagem := ""   
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		cMensagem += "Versão NFE :"+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
	EndIf       
	cMensagem += "Ambiente: "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF 	
	cMensagem += "Codigo Retorno NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
	cMensagem += "Mensagem Retorno NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF 
	cCodNFE:=oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE 

	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		cMensagem += "Protocolo : "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF	
	EndIf  
	
	cMensagem +=+CRLF     
                 
	//Códigos usados disponiveis em http://www.sefaz.ma.gov.br/NFE/codigos_de_mensagens_de_autorizacao_nfe.htm	
	If Alltrim(cCodNFE) == "100"
		cMensagem += "Nota fiscal pode ser integrada "	
	Else
		cMensagem += "ATENÇÃO: Essa nota não pode ser integrada "
	EndIf 
	Aviso("Consulta Nota Fiscal Eletronica Grant Thorton",cMensagem,{"Ok"},,3)   
	
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3) 
EndIf

Return 

/*
Funcao      :  GetIdEnt()
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/08/11 10:00
*/
*---------------------------*
Static Function GetIdEnt()
*---------------------------*
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
	
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	EndIf

	RestArea(aArea)

Return (cIdEnt)

/*
Funcao      : CheckOp()
Parametros  : Conteúdo do paramentro MV_P_INT
Retorno     : Posição                        
Objetivos   : Validação letras nas opções de integrações.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 06/09/11 15:00
Revisão		: Alterado para tratamento dinamico.
Autor		: Jean Victor Rocha
Data		: 25/10/2012
*/
*---------------------------*
 Static Function CheckOp(cOp)
*---------------------------*    
If ASC(Alltrim(Upper(cOp))) >= 65
	cRet := ALLTRIM(STR(ASC(Upper(cOp))-55))
Else
	cRet := cOp
EndIf

Return cRet
      
/*
Funcao      : IntXmlFRE()
Parametros  : cArquivo: Arquivo XML de integração
Retorno     : Nil
Objetivos   : Integração do arquivo XML, gerando a Pre Nota de frete.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 24/11/11 17:18
*/
*---------------------------------*
Static Function IntXmlFRE(cArquivo)
*---------------------------------*
Local lXml  := .T.
Local lCopy := .F. 
Local lRet  := .F.

Local cUM      := ""
Local cMsg     := ""  
Local cErro    := ""
Local cAviso   := ""

Local nAt    := 0
Local nX     := 0
Local nQtd   := 0
Local nUM    := 0
Local nVlUn  := 0
Local nVlTot := 0

Local aCabec := {}
Local aLinha := {}
Local aItens := {}

Local oXml
Local oVal

Private lMSErroAuto := .F.
       
Private cChave   := ""
Private cDoc     := ""
Private cSerie   := ""
Private cCNPJ    := ""
Private cEmissao := ""
Private cTipoNf  := "N"
Private cCodNFE  := ""
Private cProd    := space(15)

//Verifica se o arquivo não está na raiz do ambiente.
If Substr(cArquivo,2,1) == ":" .or. Left(cArquivo,2) == "//"
      	
	//Verifica o nome do arquivo.
    cFile := cArquivo
	nAT   := 1
	For nX := 1 To Len(cArquivo)
		cFile := Substr(cFile,If(nX==1,nAt,nAt+1),Len(cFile))
		nAt := At("\",cFile)
		If nAt == 0
			Exit
		Endif
	Next nX
      	     	
	//Copia o arquivo para o diretorio raiz.
	CpyT2S(cArquivo,"\BKP")
	       	
	cArquivo := "\BKP\"+cFile
	lCopy := .T.
	
EndIf
        	
lXml := .T.
      	
//Leitura do XML
oXml :=  XmlParserFile(cArquivo,"_",@cErro,@cAviso)
If ( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)
	oVal := XmlChildEx(oXml ,  "_CTEPROC")

	If !(oVal <> NIL)
		MsgInfo("Essa nota não é um conhecimento de transporte",STR061)
		Return .F.
	EndIf
	
	bError := ErrorBlock({|| lXml := .F.})     
	Begin Sequence          
	
   		cDoc     := Strzero(Val(alltrim(oXml:_CteProc:_Cte:_InfCte:_Ide:_nct:TEXT)),9) 
   		//TLM 22/06/2012 -  Tratamento de serie 0, solicitado pela FSI : Nivaldo.
   		If cEmpAnt $ "EF"
	   		If "0" == Alltrim(oXml:_CteProc:_Cte:_InfCte:_Ide:_serie:TEXT)	
				cSerie   := "   "				
	 		Else
	 			cSerie := oXml:_CteProc:_Cte:_InfCte:_Ide:_serie:TEXT	
	 		EndIf     
	 	Else
	 		cSerie := oXml:_CteProc:_Cte:_InfCte:_Ide:_serie:TEXT
	 	EndIf	
	 	cChave   := oXml:_CteProc:_ProtCte:_InfProt:_ChCte:TEXT
 		cEmissao := oXml:_CteProc:_Cte:_InfCte:_Ide:_DHemi:TEXT
 		cEmissao := Left(cEmissao,4)+Substr(cEmissao,6,2)+Substr(cEmissao,9,2)
		cCNPJ    := oXml:_CteProc:_Cte:_InfCte:_Emit:_Cnpj:TEXT
 		cProd    := "DE000005" 		                                 		      
 		nQtd   	 := 1
 		cUM      := "UN"
	 	nVlUn 	 := Val(oXml:_CteProc:_Cte:_InfCte:_VPrest:_VRec:TEXT)
 		nVlTot   := Val(oXml:_CteProc:_Cte:_InfCte:_VPrest:_VRec:TEXT)
 		cCFOP  	 := oXml:_CteProc:_Cte:_InfCte:_Ide:_CFOP:TEXT
 		cTipoNF  := "N" 			
	End Sequence

	ErrorBlock(bError)

	//Validações antes da integração
	cMsg := Validacoes("XML_PNF")
	
	//Exibir a mensagem de erro.
	If Len(cMsg) > 0
		ExibeMsg(cMsg)	

	Else
		//Monta os campos da capa da Pre-Nota de Entrada.
		aAdd(aCabec,{"F1_TIPO"   ,cTipoNF})
		aAdd(aCabec,{"F1_FORMUL" ,"N"})
		aAdd(aCabec,{"F1_DOC"    ,cDoc})
		aAdd(aCabec,{"F1_SERIE"  ,cSerie})
		aAdd(aCabec,{"F1_EMISSAO",StoD(cEmissao)})  
	   
		If  cTipoNF $ "B/D"       
		
			aAdd(aCabec,{"F1_FORNECE",SA1->A1_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA1->A1_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA1->A1_EST})
			aAdd(aCabec,{"F1_CHVNFE",cChave})  
			
		Else             
		
			aAdd(aCabec,{"F1_FORNECE",SA2->A2_COD})
			aAdd(aCabec,{"F1_LOJA"   ,SA2->A2_LOJA})
			aAdd(aCabec,{"F1_ESPECIE",""})
			aAdd(aCabec,{"F1_EST"    ,SA2->A2_EST}) 
			aAdd(aCabec,{"F1_CHVNFE",cChave})  
			
	    EndIf    
	    
		aLinha := {}
		aAdd(aLinha,{"D1_COD"  ,cProd,Nil})
		aAdd(aLinha,{"D1_QUANT",nQtd ,Nil})
		aAdd(aLinha,{"D1_VUNIT",nVlUn,Nil})
		aAdd(aLinha,{"D1_TOTAL",nVlTot,Nil})
		aAdd(aLinha,{"D1_OBS"  ,"REF.DOC:"+AllTrim(cDoc)+"-"+AllTrim(cSerie),Nil})
		aAdd(aItens,aLinha)
		
    	//Exibe a previa da Pre-Nota de Entrada.
    	If ExibePreNF(@aCabec,@aItens)    
    
			//Gera a pre-nota de entrada.
			MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
		    
      		If lMSErroAuto           
         		MostraErro()
         		Return .F.
      		Else
      			MsgInfo("A pre nota de entrada foi gerada.",STR061)
      		EndIf   
		
		EndIf

    EndIf

Else
	MsgInfo("Erro na leitura do arquivo XML: "+ AllTrim(cErro)+".",STR061)
	Return .F.

EndIf    

//Apaga o arquivo da raiz do ambiente
If lCopy
	If File(cArquivo)
		fErase(cArquivo)	
    EndIf
EndIf

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
Local nIdioma	 := 1
Local oIdioma
Local oDlgIdi	// Dialog Principal

DEFINE MSDIALOG oDlgIdi TITLE "Selecione o idioma" FROM C(255),C(412) TO C(374),C(575) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(000),C(003) TO C(044),C(080) LABEL "Idioma" PIXEL OF oDlgIdi
	@ C(010),C(006) Radio oIdioma Var nIdioma Items "Português","Inglês" 3D Size C(050),C(010) PIXEL OF oDlgIdi
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
Private aCols:={}

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

	@ C(180),C(300) Button "&Imprimir" Size C(037),C(012) PIXEL OF _oDlg action(Imprime(cNick,"2"))
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
*---------------------------*
Static Function ChkIn(cCampo)  
*---------------------------*
If cCampo=="C5_NUM"
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	If Dbseek("C5_NUM")
		If ALLTRIM(SX3->X3_RELACAO)<>'IIF(ALLTRIM(FUNNAME())=="MATA410",(GETSXENUM("SC5","C5_NUM"),confirmSX8()),"")'
			RECLOCK("SX3",.F.)
	   		SX3->X3_RELACAO:='IIF(ALLTRIM(FUNNAME())=="MATA410",(GETSXENUM("SC5","C5_NUM"),confirmSX8()),"")'
	   		SX3->(MSUNLOCK())
		EndIf
	EndIf
ElseIf cCampo=="A1_COD"
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	If Dbseek("A1_COD")
		If ALLTRIM(SX3->X3_RELACAO)<>'IIF(ALLTRIM(FUNNAME())=="MATA030",(GETSXENUM("SA1","A1_COD"),confirmSX8()),"")'
			RECLOCK("SX3",.F.)
	   		SX3->X3_RELACAO:='IIF(ALLTRIM(FUNNAME())=="MATA030",(GETSXENUM("SA1","A1_COD"),confirmSX8()),"")'
			SX3->(MSUNLOCK())
		EndIf
	EndIf
EndIf
Return

/*
Funcao      : GeraArqD()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico pedido de venda s/ inclusão de cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 25/10/2012
*/
*-------------------------------*
Static Function GeraArqD(cArqTxt)   
*-------------------------------*
ProcRegua(0)

Private cCampo        :=""   
Private cTemDup       :="" 
Private cArqTrab      :=""  
Private cCpoFaltantes :=""
Private cCpoFaltantes2:=""

Private lCrt          :=.F.

Private lCpoFal       :=.F.

Private lTemDup       :=.F.   

Private aCampos       :={} 
Private aCabExcel     :={}
Private aDadExcel     :={}
Private aCampos1      :={}
//Campos obrigatórios que devem estar no arquivo
Private aCpoObrigat   := {}

Private nPos          :=0
Private nCnt          :=0

Private cChave	:=""
Private lMsgC		:=.F.
Private cMsgCampo	:=""

Private lCmpNExt	:=.F.
Private cCmpNExt	:=""

Private lC5CLi := .F.//Definição de utilização de campos com C5_CLIENTE ou A1_CGC
         
FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()        // Le a linha
	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	
	If "C5_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		lC5CLi := ("C5_CLIENTE" $ UPPER(cLinha))

		If Len(aCpoObrigat) == 0 
			//RRP - 29/07/2013 - Ajuste para incluir com o A1_CGC
			If lC5CLi
		   		aCpoObrigat := {"C5_NUM","C5_TIPO","C5_TIPOCLI","C5_CLIENTE","C5_LOJACLI","C5_CONDPAG","C5_EMISSAO","C5_MENNOTA",;
			   					 "C5_P_REF","C6_ITEM","C6_PRODUTO","C6_DESCRI","C6_QTDVEN","C6_PRCVEN","C6_VALOR","C6_TES"}
			Else                
				aCpoObrigat := {"C5_NUM","C5_TIPO","C5_TIPOCLI","A1_CGC","C5_CONDPAG","C5_EMISSAO","C5_MENNOTA","C5_P_REF",;
										 "C6_ITEM","C6_PRODUTO","C6_DESCRI","C6_QTDVEN","C6_PRCVEN","C6_VALOR","C6_TES"} 
			EndIf	

			If cEmpAnt $ "R7"
				aAdd(aCpoObrigat,"C5_CCUSTO")
				aAdd(aCpoObrigat,"C5_P_ITEMC") 
				aAdd(aCpoObrigat,"C5_VEND1")
				aAdd(aCpoObrigat,"C5_TPFRETE")
			EndIf
		EndIf


		for cont:=1 to len(aCpoObrigat)
			//RRP - 29/07/2013 - Ajuste para incluir com o A1_CGC
			If lC5Cli
           		if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
					cCpoFaltantes+=aCpoObrigat[cont]+","
				endif
			Else
           		if !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
					cCpoFaltantes+=aCpoObrigat[cont]+","
				endif			
			EndIf
		next
		
		if !Empty(cCpoFaltantes).AND.!Empty(cCpoFaltantes2)
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
					If Dbseek(cCampo)
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
Private nPosC5_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_NUM"		} )
Private nPosC5_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TIPO"	} )
Private nPosC5_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TIPOCLI"	} )
//RRP - 29/07/2013 - Ajuste para incluir com o A1_CGC
If !lC5Cli
	Private nPosC5_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A1_CGC"	} )
Else
	Private nPosC5_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_CLIENTE"	} )
	Private nPosC5_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_LOJACLI"	} ) 
EndIf
Private nPosC5_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_CONDPAG"	} )
Private nPosC5_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_EMISSAO"	} )
Private nPosC5_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_MENNOTA"	} )
Private nPosC5_9	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_P_REF"	} )
Private nPosC5_A	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TABELA"	} )
If cEmpAnt $ "R7"
	Private nPosC5_B	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_CCUSTO"	} ) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	Private nPosC5_C	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_P_ITEMC"	} ) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	Private nPosC5_D	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_VEND1"	} ) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	Private nPosC5_E	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C5_TPFRETE"	} ) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
EndIf

Private nPosC6_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_ITEM"	} )
Private nPosC6_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_PRODUTO"	} )
Private nPosC6_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_DESCRI"	} )
Private nPosC6_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_QTDVEN"	} )
Private nPosC6_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_PRCVEN"	} )
Private nPosC6_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_VALOR"	} )
Private nPosC6_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_TES"		} )
If cEmpAnt $ "R7"
	Private nPosC6_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "C6_NFORI"	} ) //RRP - 20121228 - Add Campos obrigatórios da Shiseido
EndIf

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosC5_1==0,(lMsgC:=.T.,cMsgCampo+="C5_NUM"		+CRLF),)
IF(nPosC5_2==0,(lMsgC:=.T.,cMsgCampo+="C5_TIPO"		+CRLF),)
IF(nPosC5_3==0,(lMsgC:=.T.,cMsgCampo+="C5_TIPOCLI"	+CRLF),)
//RRP - 29/07/2013 - Ajuste para incluir com o A1_CGC
If !lC5Cli
	IF(nPosC5_4==0,(lMsgC:=.T.,cMsgCampo+="A1_CGC"	+CRLF),)
Else
	IF(nPosC5_4==0,(lMsgC:=.T.,cMsgCampo+="C5_CLIENTE"	+CRLF),)
	IF(nPosC5_5==0,(lMsgC:=.T.,cMsgCampo+="C5_LOJACLI"	+CRLF),)
EndIf
IF(nPosC5_6==0,(lMsgC:=.T.,cMsgCampo+="C5_CONDPAG"	+CRLF),)
IF(nPosC5_7==0,(lMsgC:=.T.,cMsgCampo+="C5_EMISSAO"	+CRLF),)
IF(nPosC5_8==0,(lMsgC:=.T.,cMsgCampo+="C5_MENNOTA"	+CRLF),)
IF(nPosC5_9==0,(lMsgC:=.T.,cMsgCampo+="C5_P_REF"	+CRLF),)
If cEmpAnt $ "R7"
	IF(nPosC5_B==0,(lMsgC:=.T.,cMsgCampo+="C5_CCUSTO"	+CRLF),) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	IF(nPosC5_C==0,(lMsgC:=.T.,cMsgCampo+="C5_P_ITEMC"	+CRLF),) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	IF(nPosC5_D==0,(lMsgC:=.T.,cMsgCampo+="C5_VEND1"	+CRLF),) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
	IF(nPosC5_E==0,(lMsgC:=.T.,cMsgCampo+="C5_TPFRETE"	+CRLF),) //RRP - 20121106 - Add Campos obrigatórios da Shiseido
EndIf
IF(nPosC6_1==0,(lMsgC:=.T.,cMsgCampo+="C6_ITEM" 	+CRLF),)
IF(nPosC6_2==0,(lMsgC:=.T.,cMsgCampo+="C6_PRODUTO"	+CRLF),)
IF(nPosC6_3==0,(lMsgC:=.T.,cMsgCampo+="C6_DESCRI"	+CRLF),)
IF(nPosC6_4==0,(lMsgC:=.T.,cMsgCampo+="C6_QTDVEN"	+CRLF),)
IF(nPosC6_5==0,(lMsgC:=.T.,cMsgCampo+="C6_PRCVEN"	+CRLF),)
IF(nPosC6_6==0,(lMsgC:=.T.,cMsgCampo+="C6_VALOR"	+CRLF),)
IF(nPosC6_7==0,(lMsgC:=.T.,cMsgCampo+="C6_TES"  	+CRLF),)
If cEmpAnt $ "R7"
	IF(nPosC6_8==0,(lMsgC:=.T.,cMsgCampo+="C6_NFORI"  	+CRLF),) //RRP - 20121228 - Add Campos obrigatórios da Shiseido
EndIf

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "+CRLF+cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)

If nPosC5_9 <> 0
	cChave:=aCampos1[nPosC5_9][1]+"+"+aCampos1[nPosC5_1][1]
Else
	cChave:=aCampos1[nPosC5_1][1]
Endif                                   

IndRegua("XXX", cArqTemp, (cChave),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If	empty(aLinha[nPosC5_1]) .AND. empty(aLinha[nPosC5_2]) .AND. empty(aLinha[nPosC5_3]) .AND. ;
		empty(aLinha[nPosC5_4]) .AND. IIF(lC5Cli,empty(aLinha[nPosC5_5]),.T.) .AND.;
		empty(aLinha[nPosC5_6]) .AND. empty(aLinha[nPosC5_7]) .AND. empty(aLinha[nPosC5_8])
		FT_FSkip() // Proxima linha
		loop
	Endif    

	Begin Transaction	
		Reclock("XXX",.T.) 
		For nK:=1 to len(aCampos1)
	    	If !empty(aCampos1[nK][1])
    			If aCampos1[nK][2]=="N"
	    			XXX->&(aCampos1[nK][1]):= iif(empty(aLinha[nK]),0,val( STRTRAN(STRTRAN(aLinha[nK],"."), "," , ".") ))
	    		Elseif aCampos1[nK][2]=="D"
    			//campo C5_EMISSAO
					dEmissaoSC5 := CTOD("")               
                   	If empty(aLinha[nK])
						dEmissaoSC5 :=dDataBase
               		ElseIf AT("/",aLinha[nK]) > 0
               	 		dEmissaoSC5 := CTOD(aLinha[nK])
               		Else
               			dEmissaoSC5 := STOD(aLinha[nK]) 
               		EndIf
               		XXX->&(aCampos1[nK][1]):= dEmissaoSC5 
	   		    Else
	   		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	   		    Endif
	   		Endif	
		Next nK
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction

	If nPosC5_9<>0
		IncProc("Lendo registro: "+alltrim(XXX->C5_P_REF+XXX->C5_NUM))
	Else 
		IncProc("Lendo registro: "+alltrim(XXX->C5_NUM))
	Endif
	   
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutD()//Chamada da função de processamento.

fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutD()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico produto.
Autor       : Jean Victor Rocha
Data/Hora   : 25/10/2012
*/                          
*-------------------------*
Static Function ExecAutD  
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
Local cCliente		:= ""
Local cLojaCLi		:= ""

Local lTemTabP		:= .F.

//Incio Tabela temporária para armaznar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

DbSelectArea("XXX")
XXX->(DbGotop())
While XXX->(!EOF()) 
	If nPosC5_9 <> 0
		IncProc("Processando registro: "+alltrim(XXX->C5_P_REF+XXX->C5_NUM))
	Else 
		IncProc("Processando registro: "+alltrim(XXX->C5_NUM))
	Endif
	If empty(XXX->C5_NUM) .AND. nPosC5_9 == 0
	    lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
    	WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Quando o campo C5_NUM estiver em branco, o campo C5_P_REF deve ser informado!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop		
	Elseif nPosC5_9 > 0
		If Empty(XXX->C5_NUM) .AND. Empty(XXX->C5_P_REF)
		    lErro:=.T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:= "Erro"
	    	WWW->CODIGO		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
	    	WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "O campo C5_NUM ou o campo C5_P_REF deve ser preenchido!"
		    WWW->(MsUnlock())
			XXX->(DbSkip())
			Loop				
		// MSM - 29/10/2012 - Tratamento para verificar se referência já foi incluida anteriormente
		Else
            cQrC5Ref:=" SELECT C5_NUM FROM "+RETSQLNAME("SC5")+CRLF
            cQrC5Ref+=" WHERE D_E_L_E_T_='' AND C5_FILIAL='"+xFilial("SC5")+"' AND UPPER(C5_P_REF)=UPPER('"+alltrim(XXX->C5_P_REF)+"')"

				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
				
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
				
				Count to nRecCount
				        
				if nRecCount >0
					lErro:=.T.
		
					Reclock("WWW",.T.)
				    	WWW->SITUACAO	:= "Erro"
				    	WWW->CODIGO		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
				    	WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
				    	WWW->CGC		:= ""
				    	WWW->DESCRICAO	:= "Campo C5_P_REF: Já existe referência cadastrada ---> "+alltrim(XXX->C5_P_REF)+"!"
					    WWW->(MsUnlock())
					XXX->(DbSkip())
					Loop	
				endif
		Endif
	EndIf

	aDados	:={}
	aItens	:={}
	aItem	:={}

	aCabecSA1	:= {}
	//RRP - 29/07/2013 - Ajuste para incluir com o A1_CGC
	If lC5Cli	
		cCliente	:= XXX->&(aCampos1[nPosC5_4][1])
		cLojaCLi	:= XXX->&(aCampos1[nPosC5_5][1])
		cCGC := ""	
		SA1->(DbSetOrder(1))//A1_FILIAL, A1_COD, A1_LOJA
		If SA1->(DbSeek(xFilial("SA1")+cCliente+SPACE(6-LEN(cCliente))+cLojaCLi))
			cCGC := SA1->A1_CGC		
		EndIf
	Else
		cCGC := XXX->&(aCampos1[nPosC5_4][1])
		SA1->(DbSetOrder(3))//A1_FILIAL, A1_CGC
		If SA1->(DbSeek(xFilial("SA1")+cCGC))
			cCliente	:= SA1->A1_COD
			cLojaCLi	:= SA1->A1_LOJA
		EndIf	
	EndIf


	If empty(cCGC)
		lErro	:= .T.	
		Reclock("WWW",.T.)
		WWW->SITUACAO	:= "Erro"
		WWW->CODIGO		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF)+alltrim(XXX->C5_NUM),alltrim(XXX->C5_NUM))
		WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
		WWW->DESCRICAO	:= "CNPJ do cliente não encontrado!"
		WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop
	Endif

    //--Tratamento para o número sequencial do pedido de venda
	lUsouGetC5:=.F.
	if nPosC5_9 <> 0
		if !empty(XXX->&(aCampos1[nPosC5_9][1])) .AND. empty(XXX->&(aCampos1[nPosC5_1][1]))
			//Atualiza o SX3 Lançamento Padrão para tratar a numeração sequência 
			ChkIn("C5_NUM")
			cSeqNumC5	:= GETSXENUM("SC5","C5_NUM")
			Confirmsx8()
			lUsouGetC5	:= .T.
		else
			cSeqNumC5	:= XXX->&(aCampos1[nPosC5_1][1])
		endif
	else
		cSeqNumC5	:= XXX->&(aCampos1[nPosC5_1][1])
	endif

	//<Tratamento para capa do pedido - SC5>
	for nK:=1 to len(aCampos1)
		if !empty(aCampos1[nK][1])
			if aCampos1[nPosC5_3][1] == aCampos1[nK][1] //C5_TIPOCLI
				AADD(aDados,{"C5_CLIENTE",cCliente	,	nil})
				AADD(aDados,{"C5_LOJACLI",cLojaCLi	,	nil})
			elseif "C5_NUM"	== ALLTRIM(aCampos1[nK][1])
				AADD(aDados,{"C5_NUM",cSeqNumC5,	nil})
			elseif "C5_" $ aCampos1[nK][1]
				AADD(aDados,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
			endif
			
			//MSM - 29/10/2012 - verifica se tem tabela de preço
			if nPosC5_A<>0
				if !empty(XXX->&(aCampos1[nPosC5_A][1]))
					lTemTabP:=.T.
				else
					lTemTabP:=.F.
				endif
			else
				lTemTabP:=.F.
			endif
		endif                              
	next
                
	//<Tratamento para itens do pedido - SC6>
	Private cRenXXX		:= XXX->(Recno())
	Private cNumPedAnt	:= iif(nPosC5_9<>0 .AND. empty(alltrim(XXX->C5_NUM)),alltrim(XXX->C5_P_REF),alltrim(XXX->C5_NUM))
	Private cKey		:= iif(nPosC5_9<>0 .AND. empty(alltrim(XXX->C5_NUM)),"alltrim(XXX->C5_P_REF)","alltrim(XXX->C5_NUM)")
	Private cNumCGC		:= cCGC
	Private cAntItem	:= XXX->C6_ITEM

	Private cItem		:= "00"
	Private cRecUlt		:= ""
	Private lErroInter	:= .F.

	XXX->(DbSkip())
	//validar como mesmo pedido quando o número de referência e o item for sequêncial
	If &(cKey)==cNumPedAnt .AND. XXX->C6_ITEM>cAntItem
		XXX->(Dbgoto(cRenXXX))
	    //while alltrim(XXX->C5_NUM)==cNumPedAnt
		while alltrim(&(cKey))==cNumPedAnt 
		    //cItem:=(SOMA1(cItem))
		    cItem:=XXX->C6_ITEM

		    lJaAtuVa:=.F.

			for nK:=1 to len(aCampos1)
				if !empty(aCampos1[nK][1])
					if "C6_ITEM" $ aCampos1[nK][1]
						AADD(aItem,{"C6_ITEM",cItem,nil})
					//MSM - 29/10/2012 - Adicionado para tratar tabela de preço de venda
					elseif "C6_PRCVEN" $ aCampos1[nK][1]
						
						if lTemTabP
							
							if nPosC6_2<>0 .AND. nPosC5_A<>0
								cTabPrc:= alltrim(XXX->&(aCampos1[nPosC5_A][1]))
								cProdC6:= alltrim(XXX->&(aCampos1[nPosC6_2][1]))
								
								if !empty(cTabPrc) .AND. !empty(cProdC6)
								
									cQrDa1:=" SELECT DA1_PRCVEN FROM "+RETSQLNAME("DA1")+CRLF
									cQrDa1+=" WHERE D_E_L_E_T_='' AND DA1_FILIAL='"+xFilial("DA1")+"' AND DA1_CODTAB='"+cTabPrc+"' AND DA1_CODPRO='"+cProdC6+"'

										if select("QRYTEMP")>0
											QRYTEMP->(DbCloseArea())
										endif
										
										DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrDa1), "QRYTEMP", .F., .F. )
										
										Count to nRecCount
										        
										if nRecCount >0
											QRYTEMP->(DbGoTop())
											
											AADD(aItem,{"C6_PRCVEN",QRYTEMP->DA1_PRCVEN,nil})
											
											if nPosC6_4<>0
												nQtdVen:= XXX->&(aCampos1[nPosC6_4][1])
												nValVen:= QRYTEMP->DA1_PRCVEN*nQtdVen
												AADD(aItem,{"C6_VALOR",nValVen,nil})
												lJaAtuVa:=.T.
											endif
										
										else
											AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})									
										endif
							    else
									AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})						    
							    endif
							else
								AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})							
							endif
						else	
							AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})
						endif
					elseif "C6_VALOR" $ aCampos1[nK][1]
						if !lJaAtuVa
							AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})
						endif
					elseif "C6_" $ aCampos1[nK][1]
						AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})
					endif
				endif
			next
			AADD(aItem,{"C6_NUM",alltrim(cSeqNumC5),nil})

			cNumPedAnt:=alltrim(&(cKey))
			cRecUlt:=XXX->(Recno())
			XXX->(DbSkip())
		
			AADD(aItens,aItem)
			aItem:={}
		enddo	
		XXX->(Dbgoto(cRecUlt))   
	Else
		cItem:=XXX->C6_ITEM
		XXX->(Dbgoto(cRenXXX))
		    lJaAtuVa:=.F.
		    
		    for nK:=1 to len(aCampos1)
				if !empty(aCampos1[nK][1])
					if "C6_ITEM" $ aCampos1[nK][1]
						AADD(aItem,{"C6_ITEM",cItem,nil})
					//MSM - 29/10/2012 - Adicionado para tratar tabela de preço de venda
					elseif "C6_PRCVEN" $ aCampos1[nK][1]
						
						if lTemTabP
							
							if nPosC6_2<>0 .AND. nPosC5_A<>0
								cTabPrc:= alltrim(XXX->&(aCampos1[nPosC5_A][1]))
								cProdC6:= alltrim(XXX->&(aCampos1[nPosC6_2][1]))
								
								if !empty(cTabPrc) .AND. !empty(cProdC6)
								
									cQrDa1:=" SELECT DA1_PRCVEN FROM "+RETSQLNAME("DA1")+CRLF
									cQrDa1+=" WHERE D_E_L_E_T_='' AND DA1_FILIAL='"+xFilial("DA1")+"' AND DA1_CODTAB='"+cTabPrc+"' AND DA1_CODPRO='"+cProdC6+"'

										if select("QRYTEMP")>0
											QRYTEMP->(DbCloseArea())
										endif
										
										DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrDa1), "QRYTEMP", .F., .F. )
										
										Count to nRecCount
										        
										if nRecCount >0
											QRYTEMP->(DbGoTop())
											
											AADD(aItem,{"C6_PRCVEN",QRYTEMP->DA1_PRCVEN,nil})
											
											if nPosC6_4<>0
												nQtdVen:= XXX->&(aCampos1[nPosC6_4][1])
												nValVen:= QRYTEMP->DA1_PRCVEN*nQtdVen
												AADD(aItem,{"C6_VALOR",nValVen,nil})
												lJaAtuVa:=.T.
											endif
										
										else
											AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})									
										endif
							    else
									AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})						    
							    endif
							else
								AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})							
							endif
						else	
							AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})
						endif
					elseif "C6_VALOR" $ aCampos1[nK][1]
						if !lJaAtuVa
							AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),nil})
						endif						
					elseif "C6_" $ aCampos1[nK][1]
						AADD(aItem,{aCampos1[nK][1],iif(valtype( XXX->&(aCampos1[nK][1]) )=="C",alltrim(XXX->&(aCampos1[nK][1])),XXX->&(aCampos1[nK][1])),	nil})
					endif
				endif
			next
			AADD(aItem,{"C6_NUM",alltrim(cSeqNumC5),nil})
		AADD(aItens,aItem)
		aItem:={}
	EndIf
	cPParar:=""

	//--Execução do MSExecAuto do SC5/SC6
	Private lMsErroAuto:= .F.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	BEGIN Transaction
		MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aDados, aItens, 3)

		If lMsErroAuto
		  	//if lUsouGetC5
				//ROLLBACKSXE()		  		
		  	//endif
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
		    	WWW->SITUACAO	:= "Erro"
		    	WWW->CODIGO		:= alltrim(XXX->C5_NUM)
		    	WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
		    	WWW->CGC		:= cCGC
		    	WWW->DESCRICAO	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
		    	WWW->MEMO		:= XLOGMEMO(aAutoErro) 
		    WWW->(MsUnlock())
		Else
		  	//if lUsouGetC5
			    //Confirmsx8()    
		  	//endif
			lOk:=.T.
	    		Reclock("WWW",.T.)
			    	WWW->SITUACAO	:= "Ok"
			    	WWW->CODIGO		:= alltrim(XXX->C5_NUM)
			    	WWW->CODREF		:= iif(nPosC5_9<>0,alltrim(XXX->C5_P_REF),"")
			    	WWW->CGC		:= cCGC
			    	WWW->DESCRICAO	:= "Inserido"
			    WWW->(MsUnlock())
		EndIF
	END Transaction

XXX->(DbSkip())
Enddo

If lErro
	Situacao2()	
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqE()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Complemento de Produto.
Autor       : Jean Victor Rocha
Data/Hora   : 05/12/2012
*/
*-------------------------------*
Static Function GeraArqE(cArqTxt)   
*-------------------------------*
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
//Campos obrigatórios que devem estar no arquivo
Private aCpoObrigat   :={"B5_COD","B5_CEME"} 

Private nPos          :=0
Private nCnt          :=0

Private cChave	:=""
Private lMsgC		:=.F.
Private cMsgCampo	:=""

Private lCmpNExt	:=.F.
Private cCmpNExt	:=""

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()        // Le a linha
	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	
	If "B5_" $ UPPER(aLinha[1])
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
		
		If "B5_" $ aLinha[1] 
		    For i:=1 to len(aLinha)
				If "B5_" $ aLinha[i]
			 		cCampo:=Alltrim(aLinha[i])

			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
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
	Alert("Arquivo selecionado não possui campos para importação de Complemento de Produto!")
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
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

//-------Posição dos campos-------//
Private nPosB5_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "B5_COD"		} )
Private nPosB5_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "B5_CEME"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosB5_1==0,(lMsgC:=.T.,cMsgCampo+="B5_COD"		+CRLF),)
IF(nPosB5_2==0,(lMsgC:=.T.,cMsgCampo+="B5_CEME"		+CRLF),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "+CRLF+cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	

If nPosB5_1 <> 0
	cChave += aCampos1[nPosB5_1][1]
EndIf
If nPosB5_2 <> 0
	cChave += "+"+aCampos1[nPosB5_2][1]
Endif           

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)

IndRegua("XXX", cArqTemp, (cChave),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If	empty(aLinha[nPosB5_1]) .AND. empty(aLinha[nPosB5_2])
		FT_FSkip() // Proxima linha
		loop
	Endif    

	Begin Transaction	
		Reclock("XXX",.T.) 
		For nK:=1 to len(aCampos1)
	    	If !empty(aCampos1[nK][1])
   		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	   		Endif	
		Next nK
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction

	IncProc("Lendo registro: "+alltrim(XXX->B5_COD))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutE()//Chamada da função de processamento.

fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutE()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico complemento de produto.
Autor       : Jean Victor Rocha
Data/Hora   : 05/12/12
*/                          
*-------------------------*
Static Function ExecAutE()  
*-------------------------*
Local aCpos	   		:= {}
Local lErro	   		:= .F.
Local lOk	   		:= .F.

//Incio Tabela temporária para armaznar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

DbSelectArea("XXX")
XXX->(DbGotop())
While XXX->(!EOF()) 
	IncProc("Processando registro: "+alltrim(XXX->B5_COD))
	
	//Tratamento para as linhas de informação.
	If UPPER(ALLTRIM(XXX->B5_COD)) == UPPER("Tipo: AlfaNumer") .or. UPPER(ALLTRIM(XXX->B5_COD)) == UPPER("Produto")
		XXX->(DbSkip())
		Loop
	EndIf
	
	//Validação de preenchimento do campo
	If empty(XXX->B5_COD)
	    lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Campo B5_COD com conteudo em branco!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop		
	EndIf
	//Validação de preenchimento do campo
	If empty(XXX->B5_CEME)
	    lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= alltrim(XXX->B5_COD)
    	WWW->CODREF		:= alltrim(XXX->B5_COD)
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Campo B5_CEME com conteudo em branco!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop
	EndIf

	//Verifica se já não existe complemento cadastrado para o produto
	cQrC5Ref:=" SELECT B5_COD FROM "+RETSQLNAME("SB5")+CRLF
	cQrC5Ref+=" WHERE D_E_L_E_T_='' AND B5_FILIAL='"+xFilial("SB5")+"' AND UPPER(B5_COD)=UPPER('"+alltrim(XXX->B5_COD)+"')"
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	Endif
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	Count to nRecCount
	If nRecCount >0
		lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:= "Erro"
    	WWW->CODIGO		:= alltrim(XXX->B5_COD)
	   	WWW->CODREF		:= alltrim(XXX->B5_COD)
	   	WWW->CGC		:= ""
	   	WWW->DESCRICAO	:= "Ja existe complemento para o Produto '"+alltrim(XXX->B5_COD)+"'!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop	
	Endif

	//Verifica se o produto existe no cadastro de produtos	
	cQrC5Ref:=" SELECT B1_COD FROM "+RETSQLNAME("SB1")+CRLF
	cQrC5Ref+=" WHERE D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND UPPER(B1_COD)=UPPER('"+alltrim(XXX->B5_COD)+"')"
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	Endif
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	Count to nRecCount
	If nRecCount == 0
		lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:= "Erro"
    	WWW->CODIGO		:= alltrim(XXX->B5_COD)
	   	WWW->CODREF		:= alltrim(XXX->B5_COD)
	   	WWW->CGC		:= ""
	   	WWW->DESCRICAO	:= " Não foi encontrado cadastro de produto para este complemento!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop	
	Endif

	SB5->(RecLock("SB5", .T.))
	SB5->B5_COD	:=	XXX->B5_COD
	SB5->B5_CEME:=	XXX->B5_CEME
	SB5->(MsUnlock())
	lOk := .T.

	XXX->(DBSKIP())
EndDo	

If lErro
	Situacao2()	
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqF()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Produto X Fornecedor.
Autor       : Renato Rezende
Data/Hora   : 03/12/2013
*/
*-------------------------------*
Static Function GeraArqF(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private cCampo        	:=""   
Private cTemDup       	:="" 
Private cArqTrab      	:=""  
Private cCpoFaltantes	:=""

Private lCrt          	:=.F.

Private lCpoFal       	:=.F.

Private lTemDup       	:=.F.   

Private aCampos       	:={} 
Private aCabExcel     	:={}
Private aDadExcel     	:={}
Private aCampos1      	:={}
//Campos obrigatórios que devem estar no arquivo
Private aCpoObrigat   	:={"A5_FORNECE","A5_LOJA","A5_PRODUTO"} 

Private nPos          	:=0
Private nCnt          	:=0

Private cChave			:=""
Private lMsgC			:=.F.
Private cMsgCampo  		:=""

Private lCmpNExt		:=.F.
Private cCmpNExt		:=""

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()        // Le a linha
	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	
	If "A5_" $ UPPER(aLinha[1])
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
		
		If "A5_" $ aLinha[1] 
		    For i:=1 to len(aLinha)
				If "A5_" $ aLinha[i]
			 		cCampo:=Alltrim(aLinha[i])

			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
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
	Alert("Arquivo selecionado não possui campos para importação do Produto X Fornecedor!")
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
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

//-------Posição dos campos-------//
Private nPosA5_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A5_FORNECE"	} )
Private nPosA5_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A5_LOJA"	} )
Private nPosA5_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "A5_PRODUTO"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosA5_1==0,(lMsgC:=.T.,cMsgCampo+="A5_FORNECE"	+CRLF),)
IF(nPosA5_2==0,(lMsgC:=.T.,cMsgCampo+="A5_LOJA"		+CRLF),)
IF(nPosA5_3==0,(lMsgC:=.T.,cMsgCampo+="A5_PRODUTO"	+CRLF),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "+CRLF+cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	

If nPosA5_1 <> 0
	cChave += aCampos1[nPosA5_1][1]
EndIf
If nPosA5_2 <> 0
	cChave += "+"+aCampos1[nPosA5_2][1]
Endif
If nPosA5_3 <> 0
	cChave += "+"+aCampos1[nPosA5_3][1]
Endif        

cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)

IndRegua("XXX", cArqTemp, (cChave),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	If	empty(aLinha[nPosA5_1]) .AND. empty(aLinha[nPosA5_2])
		FT_FSkip() // Proxima linha
		loop
	Endif    

	Begin Transaction	
		Reclock("XXX",.T.) 
		For nK:=1 to len(aCampos1)
	    	If !empty(aCampos1[nK][1])
   		    	XXX->&(aCampos1[nK][1]):= aLinha[nK]
	   		Endif	
		Next nK
	    XXX->(MsUnlock())           
	    //Confirmsx8()    
	End Transaction

	IncProc("Lendo registro: "+alltrim(XXX->A5_FORNECE))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutF()//Chamada da função de processamento.

fErase(cArqTrab+OrdBagExt())
fErase(cArqTemp+OrdBagExt())

XXX->(DbCloseArea()) 

Return(lRet)

/*
Funcao      : ExecAutF()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Produto X Fornecedor.
Autor       : Renato Rezende
Data/Hora   : 03/12/2013
*/                          
*-------------------------*
 Static Function ExecAutF()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.

Local cDcProd       :=""
Local cDcForn		:=""

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

DbSelectArea("XXX")
XXX->(DbGotop())
While XXX->(!EOF()) 
	IncProc("Processando registro: "+alltrim(XXX->A5_FORNECE))
	
	//Validação de preenchimento do campo
	If empty(XXX->A5_FORNECE)
	    lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Campo A5_FORNECE com conteudo em branco!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop		
	EndIf
	//Validação de preenchimento do campo
	If empty(XXX->A5_LOJA)
	    lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= alltrim(XXX->A5_FORNECE)
    	WWW->CODREF		:= alltrim(XXX->A5_FORNECE)
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Campo A5_LOJA com conteudo em branco!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop
	EndIf

	//Verifica se já não existe produto para o fornecedor
	cQrC5Ref:=" SELECT A5_FORNECE,A5_LOJA,A5_PRODUTO FROM "+RETSQLNAME("SA5")+CRLF
	cQrC5Ref+=" WHERE D_E_L_E_T_='' AND A5_FILIAL='"+xFilial("SA5")+"' AND UPPER(A5_FORNECE)=UPPER('"+alltrim(XXX->A5_FORNECE)+"')"+CRLF
	cQrC5Ref+="	  AND UPPER(A5_LOJA)=UPPER('"+alltrim(XXX->A5_LOJA)+"')"+CRLF
	cQrC5Ref+="	  AND UPPER(A5_PRODUTO)=UPPER('"+alltrim(XXX->A5_PRODUTO)+"') 
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	Endif
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	Count to nRecCount
	If nRecCount >0
		lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:= "Erro"
    	WWW->CODIGO		:= alltrim(XXX->A5_FORNECE)
	   	WWW->CODREF		:= alltrim(XXX->A5_FORNECE)
	   	WWW->CGC		:= ""
	   	WWW->DESCRICAO	:= "Já existe um Produto para esse Fornecedor: '"+alltrim(XXX->A5_FORNECE)+"'!"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop	
	Endif

	//Verifica se o produto existe no cadastro de produtos	
	cQrC5Ref:=" SELECT B1_COD,B1_DESC FROM "+RETSQLNAME("SB1")+CRLF
	cQrC5Ref+=" WHERE D_E_L_E_T_='' AND B1_FILIAL='"+xFilial("SB1")+"' AND UPPER(B1_COD)=UPPER('"+alltrim(XXX->A5_PRODUTO)+"')"
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	Endif
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	If QRYTEMP->(!EOF())
    	cDcProd:= QRYTEMP->B1_DESC
	EndIf
	Count to nRecCount
	If nRecCount == 0
		lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:= "Erro"
    	WWW->CODIGO		:= alltrim(XXX->A5_PRODUTO)
	   	WWW->CODREF		:= alltrim(XXX->A5_PRODUTO)
	   	WWW->CGC		:= ""
	   	WWW->DESCRICAO	:= " Não existe esse código de Produto cadastrado no sistema !"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop	
	Endif
	
	//Verifica se o fornecedor existe no cadastro de fornecedores	
	cQrC5Ref:=" SELECT A2_COD,A2_NOME FROM "+RETSQLNAME("SA2")+CRLF
	cQrC5Ref+=" WHERE D_E_L_E_T_='' AND A2_FILIAL='"+xFilial("SA2")+"' AND UPPER(A2_COD)=UPPER('"+alltrim(XXX->A5_FORNECE)+"')"
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	Endif
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	If QRYTEMP->(!EOF())
    	cDcForn:=QRYTEMP->A2_NOME
	EndIf
	Count to nRecCount
	If nRecCount == 0
		lErro:=.T.
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:= "Erro"
    	WWW->CODIGO		:= alltrim(XXX->A5_FORNECE)
	   	WWW->CODREF		:= alltrim(XXX->A5_FORNECE)
	   	WWW->CGC		:= ""
	   	WWW->DESCRICAO	:= " Não existe esse código de Fornecedor cadastrado no sistema !"
	    WWW->(MsUnlock())
		XXX->(DbSkip())
		Loop	
	Endif
    //Gravando os conteúdos dos campos incluídos na Planilha csv
	SA5->(RecLock("SA5", .T.))
	For r:=1 to Len(aCampos1)
		SA5->&(aCampos[r][1]) := XXX->&(aCampos[r][1])
	Next r
	//Inclusão automática do nome do produto e fornecedor
	If Alltrim(cDcProd) <> ""
		SA5->A5_NOMEFOR := Alltrim(cDcForn)
	EndIf
	If Alltrim(cDcForn) <> ""
	    SA5->A5_NOMPROD := Alltrim(cDcProd)
	EndIf 
	SA5->(MsUnlock())
	lOk := .T.

	XXX->(DBSKIP())
EndDo	

If lErro
	Situacao2()	
Elseif lOk
	msginfo("PROCESSADO COM SUCESSO!")
EndIf

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) ) 

/*
Funcao      : GeraArqG()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Contas a Receber.
Autor       : Jean Victor Rocha
Data/Hora   : 13/12/2013
*/
*-------------------------------*
Static Function GeraArqG(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.

Private aSE1			:= {}

//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"E1_NUM","E1_TIPO","E1_NATUREZ","E1_CLIENTE","E1_LOJA","E1_EMISSAO","E1_VENCTO","E1_VENCREA","E1_VALOR","E1_VENCORI","E1_VLCRUZ"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "E1_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "E1_" $ aLinha[1] 
		    For i:=1 to len(aLinha)
				If "E1_" $ aLinha[i]
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

//-------Posição dos campos-------//
Private nPosE1_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_NUM"		} )
Private nPosE1_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_TIPO"	} )
Private nPosE1_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_NATUREZ"	} )
Private nPosE1_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_CLIENTE"	} )
Private nPosE1_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_LOJA"	} )
Private nPosE1_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_EMISSAO"	} )
Private nPosE1_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_VENCTO"	} )
Private nPosE1_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_VENCREA"	} )
Private nPosE1_9	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_VALOR"	} )
Private nPosE1_10	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_VENCORI"	} )
Private nPosE1_11	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E1_VLCRUZ"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosE1_1	==0,(lMsgC:=.T.,cMsgCampo+="E1_NUM" 	+","),)
IF(nPosE1_2	==0,(lMsgC:=.T.,cMsgCampo+="E1_TIPO"	+","),)
IF(nPosE1_3	==0,(lMsgC:=.T.,cMsgCampo+="E1_NATUREZ"	+","),)
IF(nPosE1_4	==0,(lMsgC:=.T.,cMsgCampo+="E1_CLIENTE"	+","),)
IF(nPosE1_5	==0,(lMsgC:=.T.,cMsgCampo+="E1_LOJA"	+","),)
IF(nPosE1_6	==0,(lMsgC:=.T.,cMsgCampo+="E1_EMISSAO"	+","),)
IF(nPosE1_7	==0,(lMsgC:=.T.,cMsgCampo+="E1_VENCTO"	+","),)
IF(nPosE1_8	==0,(lMsgC:=.T.,cMsgCampo+="E1_VENCREA"	+","),)
IF(nPosE1_9	==0,(lMsgC:=.T.,cMsgCampo+="E1_VALOR"	+","),)
IF(nPosE1_10==0,(lMsgC:=.T.,cMsgCampo+="E1_VENCORI"	+","),)
IF(nPosE1_11==0,(lMsgC:=.T.,cMsgCampo+="E1_VLCRUZ"	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	
      
FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "E1_PREFIXO" }) == 0
		aAdd(aAux, {"E1_PREFIXO","INT", NIL })
	EndIf
	For nK:=1 to len(aCampos1)
   		If aCampos1[nK][1] == "E1_CLIENTE"
			aAdd(aAux,{aCampos1[nK][1], ALLTRIM(aLinha[nK])+SPACE(TAMSX3("E1_CLIENTE")[1]-LEN(ALLTRIM(aLinha[nK])))    , Nil})
   		Else
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
		EndIf
	Next nK
	aAdd(aSE1,aAux)
	
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "E1_NUM" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutG()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutG()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Contas a Receber.
Autor       : Jean Victor Rocha
Data/Hora   : 13/12/2013
*/                          
*-------------------------*
Static Function ExecAutG()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

For i:=1 to Len(aSE1)
	lErroFor	:= .F.
	lMsErroAuto := .F.
	aExecAuto	:= {}
	IncProc("Processando registro: "+alltrim(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == "E1_NUM" })][2] )    )
	//Validação de preenchimento do campo
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	aExecAuto := aSE1[i]
	
	If !lErroFor
		SE1->(DbSetOrder(1))//E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SE1->(DbSeek(xFilial("SE1")+;
						alltrim(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == "E1_PREFIXO" })][2])+;
						alltrim(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == "E1_NUM" })][2] );
						))
	   		Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Titulo Duplicado: '"+alltrim(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == "E1_NUM" })][2] )+"'"
		    WWW->(MsUnlock())
		Else
			MsExecAuto( { |x,y| FINA040(x,y)} , aExecAuto, 3)
			If !lMsErroAuto
				Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Processado"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Titulo Incluido com sucesso: '"+alltrim(aSE1[i][aScan(aSE1[i], {|x| ALLTRIM(x[1]) == "E1_NUM" })][2] )+"'"
			    WWW->(MsUnlock())			
			Else
		    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
				nLinhas		:= MLCount(cErroTemp) 
				cBuffer		:= "" 
				cCampo		:= "" 
				nErrLin		:= 1 
				cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
				//Carrega o nome do campo 
				While (nErrLin <= nLinhas) 
					nErrLin++ 
					cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
					If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
						cCampo:=cBuffer 
						xTemp:=AT("-",cBuffer) 
						cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
						Exit 
					EndIf 
				EndDo   
				Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido!"
		    	WWW->MEMO		:= cErroTemp
			    WWW->(MsUnlock())
				FERASE(GetTempPath()+"\TEMP.log")
			EndIf		
		EndIf
	EndIf	
Next i

Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqH()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Ativos
Autor       : Jean Victor Rocha
Data/Hora   : 17/12/2013
*/
*-------------------------------*
Static Function GeraArqH(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.


//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"N3_CCONTAB","N1_CBASE","N1_ITEM","N1_AQUISIC","N1_DESCRIC","N1_QUANTD",;
					"N3_HISTOR","N3_DINDEPR"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "N1_" $ UPPER(aLinha[1]) .or. "N3_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "N1_" $ UPPER(aLinha[1]) .or. "N3_" $ UPPER(aLinha[1]) 
		    For i:=1 to len(aLinha)
				If "N1_" $ UPPER(aLinha[1]) .or. "N3_" $ UPPER(aLinha[1])
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	
				    ElseIf cCampo == "CNPJFORN"
				    	AADD(aCampos ,{cCampo,"C",14,0,cCampo})
						AADD(aCampos1,{cCampo,"C",14,0,cCampo})
						
				    ElseIf cCampo == "NOMEFORN"
						AADD(aCampos ,{cCampo,"C",35,0,cCampo})
						AADD(aCampos1,{cCampo,"C",35,0,cCampo})

				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

Private nPos_01 := aScan( aCampos1, { |x| alltrim(x[1]) == "N3_CCONTAB"	} )
Private nPos_02 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_CBASE"	} )
Private nPos_03 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_ITEM"	} )
Private nPos_04 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_AQUISIC"	} )
Private nPos_05 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_DESCRIC"	} )
Private nPos_06 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_QUANTD"	} )
Private nPos_09 := aScan( aCampos1, { |x| alltrim(x[1]) == "N3_HISTOR"	} )
Private nPos_11 := aScan( aCampos1, { |x| alltrim(x[1]) == "N3_DINDEPR"	} )
Private nPos_16 := aScan( aCampos1, { |x| alltrim(x[1]) == "N1_CHAPA"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPos_01 ==0,(lMsgC:=.T.,cMsgCampo+= "N3_CCONTAB" +","),)
IF(nPos_02 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_CBASE" 	+","),)
IF(nPos_03 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_ITEM" 	+","),)
IF(nPos_04 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_AQUISIC" +","),)
IF(nPos_05 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_DESCRIC" +","),)
IF(nPos_06 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_QUANTD" 	+","),)
IF(nPos_09 ==0,(lMsgC:=.T.,cMsgCampo+= "N3_HISTOR" 	+","),)
IF(nPos_11 ==0,(lMsgC:=.T.,cMsgCampo+= "N3_DINDEPR" +","),)
IF(nPos_16 ==0,(lMsgC:=.T.,cMsgCampo+= "N1_CHAPA" 	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf

Private aATIVO := {}

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo
While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	For nK:=1 to len(aCampos1)
		If ALLTRIM(aCampos1[nK][1]) == "CNPJFORN" .And. !EMPTY(aLinha[nK]) .And. aScan(aAux, {|x| ALLTRIM(x[1]) == "N1_FORNEC"}) == 0
   			If Select("QRY") <> 0
				QRY->(DbCloseArea())
			EndIf
		    cTab := "%"+RetSqlName("SA1") +"%"
		    cWhere := "% A1_CGC = '"+ALLTRIM(aLinha[nK])+"' %"
		    BeginSql Alias 'QRY'
				SELECT TOP 1 A1_COD,A1_LOJA
				FROM %exp:cTab%
				WHERE %notDel%
				  AND %exp:cWhere%
		    EndSql
		 	QRY->(DbGoTop())
			If QRY->(!BOF() .and. !EOF())	
		    	aAdd(aAux,{"N1_FORNEC",QRY->A1_COD, Nil})
	   			aAdd(aAux,{"N1_LOJA"  ,QRY->A1_LOJA, Nil})
			EndIf 

	   	ElseIf ALLTRIM(aCampos1[nK][1]) == "NOMEFORN" .And. !EMPTY(aLinha[nK]) .And. aScan(aAux, {|x| ALLTRIM(x[1]) == "N1_FORNEC"}) == 0
		   	If Select("QRY") <> 0
				QRY->(DbCloseArea())
			EndIf
		    cTab := "%"+RetSqlName("SA1")+"%"
		    cWhere := "% AND A1_NOME like '%"+ALLTRIM(aLinha[nK])+"%' %"
		    BeginSql Alias 'QRY'
				SELECT TOP 1 A1_COD,A1_LOJA
				FROM %exp:cTab%
				WHERE %notDel%
				  AND %exp:cWhere%
		    EndSql
		 	QRY->(DbGoTop())
			If QRY->(!BOF() .and. !EOF())	
		    	aAdd(aAux,{"N1_FORNEC",QRY->A1_COD, Nil})
	   			aAdd(aAux,{"N1_LOJA"  ,QRY->A1_LOJA, Nil})
			EndIf
	   	ElseIf ALLTRIM(aCampos1[nK][1]) == "N1_FILIAL"
			aAdd(aAux,{aCampos1[nK][1], STRZERO(VAL(aLinha[nK]), TamSX3("N1_FILIAL")[01]), Nil})			

	   	ElseIf ALLTRIM(aCampos1[nK][1]) == "N1_ITEM"
			aAdd(aAux,{aCampos1[nK][1], STRZERO(VAL(aLinha[nK]), TamSX3("N1_ITEM")[01]), Nil})

	   	ElseIf ALLTRIM(aCampos1[nK][1]) == "N1_CBASE"
			aAdd(aAux,{aCampos1[nK][1], ALLTRIM(aLinha[nK])+SPACE(TamSX3("N1_CBASE")[01]-Len(ALLTRIM(aLinha[nK]))), Nil})

		Else 
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
	   	EndIf
	Next nK

	If aScan(aAux, {|x| ALLTRIM(x[1]) == "N1_FILIAL"}) == 0
		aAdd(aAux,{"N1_FILIAL", xFilial("SN1"), Nil})
	EndIf	
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "N3_FILIAL"}) == 0
		aAdd(aAux,{"N3_FILIAL", aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "N1_FILIAL"})][2], Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "N3_TIPO"}) == 0
		aAdd(aAux,{"N3_TIPO", "01", Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "N3_ITEM"}) == 0
		aAdd(aAux,{"N3_ITEM", aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "N1_ITEM"})][2], Nil})
	EndIf                                            

	aAdd(aATIVO,aAux)
	
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "N1_CBASE" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutH()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutH()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Ativos.
Autor       : Jean Victor Rocha
Data/Hora   : 17/12/2013
*/                          
*-------------------------*
Static Function ExecAutH()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""
Private aCab := {}
Private aItens := {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

If Len(aATIVO) == 0
	Reclock("WWW",.T.)
   	WWW->SITUACAO	:="Erro"
   	WWW->CODIGO		:= ""
   	WWW->CODREF		:= ""
   	WWW->CGC		:= ""
   	WWW->DESCRICAO	:= "Conteudo em branco!"
    WWW->(MsUnlock())
    Return .F.
EndIf

aSort(aATIVO,,)
cChave := alltrim(aATIVO[1][aScan(aATIVO[1],{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+alltrim(aATIVO[1][aScan(aATIVO[1],{|x| ALLTRIM(x[1])=="N1_ITEM" })][2])
lErroFor	:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .f.                       

For i:=1 to Len(aATIVO)
	IncProc("Processando registro: "+alltrim(aATIVO[i][aScan(aATIVO[i], {|x| ALLTRIM(x[1]) == "N1_CBASE" })][2] )    )
	//Validação de preenchimento do campo                                                                                                                     ]
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aATIVO[i][aScan(aATIVO[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	If i == 1 .and. Len(aCab) == 0
	    For j:=1 to len(aATIVO[i])
			If Left(aATIVO[i][j][1],3) == "N1_"
				aAdd(aCab,aATIVO[i][j])
			EndIf
			If aScan(aCab,{|x| ALLTRIM(x[1])=="N1_FORNEC" }) <> 0 .And. EMPTY(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_FORNEC" })][2]) .or.;
		   		aScan(aCab,{|x| ALLTRIM(x[1])=="N1_LOJA" }) <> 0 .And. EMPTY(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_LOJA" })][2])
			    lErroFor := .T.
				Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Campo Fornecedor/Loja com conteudo invalido!"
			    WWW->(MsUnlock())
			EndIf	
		Next j
	EndIf
	If cChave <> alltrim(aATIVO[i][aScan(aATIVO[i],{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+alltrim(aATIVO[i][aScan(aATIVO[i],{|x| ALLTRIM(x[1])=="N1_ITEM" })][2])
		If !lErroFor
			SN1->(DbSetOrder(1))//N1_FILIAL, N1_CBASE, N1_ITEM
			If SN1->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_FILIAL" })][2])+;
										alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
											STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01]	))) 
		   		Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Ativo Duplicado:'"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
		    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
			    WWW->(MsUnlock())
			Else
				MSExecAuto({|X,Y,Z| ATFA010(X,Y,Z)},aCab,aItens,3) 
				If !lMsErroAuto
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Processado"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Ativo Incluido com sucesso: '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
						    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
				    WWW->(MsUnlock())			
				Else
			    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
					nLinhas		:= MLCount(cErroTemp) 
					cBuffer		:= "" 
					cCampo		:= "" 
					nErrLin		:= 1 
					cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
					//Carrega o nome do campo 
					While (nErrLin <= nLinhas) 
						nErrLin++ 
						cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
						If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
							cCampo:=cBuffer 
							xTemp:=AT("-",cBuffer) 
							cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
							Exit 
						EndIf 
					EndDo   
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Erro"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
						    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
					WWW->MEMO		:= cErroTemp
				    WWW->(MsUnlock())
					FERASE(GetTempPath()+"\TEMP.log")
				EndIf		
			EndIf
		EndIf
		cChave := alltrim(aATIVO[i][aScan(aATIVO[i],{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+alltrim(aATIVO[i][aScan(aATIVO[i],{|x| ALLTRIM(x[1])=="N1_ITEM" })][2])
		aCab := {}
   		aItens := {}     
		lErroFor	:= .F.
		lMsErroAuto := .F.
    EndIf
    If Len(aCab) == 0
	    For j:=1 to len(aATIVO[i])
			If Left(aATIVO[i][j][1],3) == "N1_"
				aAdd(aCab,aATIVO[i][j])
			EndIf	
		Next j
    EndIf
    aAux := {}
	For j:=1 to len(aATIVO[i])
		If Left(aATIVO[i][j][1],3) == "N3_"
	   		aAdd(aAux,aATIVO[i][j])
		EndIf	
	Next j
	If Len(aAux) <> 0
		aAdd(aItens,aAux)
	EndIf  
Next i       

If !lErroFor//Executa novamente para que considere a ultima linha do array.
	SN1->(DbSetOrder(1))//N1_FILIAL, N1_CBASE, N1_ITEM
	If SN1->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_FILIAL" })][2])+;
									alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
									STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])	))
   		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Ativo Duplicado:'"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
	    WWW->(MsUnlock())
	Else
		MSExecAuto( {|X,Y,Z| ATFA010(X,Y,Z)} ,aCab ,aItens, 3) 
		If !lMsErroAuto
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Processado"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Ativo Incluido com sucesso: '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
				    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
		    WWW->(MsUnlock())			
		Else
	    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
			nLinhas		:= MLCount(cErroTemp) 
			cBuffer		:= "" 
			cCampo		:= "" 
			nErrLin		:= 1 
			cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
			//Carrega o nome do campo 
			While (nErrLin <= nLinhas) 
				nErrLin++ 
				cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
				If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
					cCampo:=cBuffer 
					xTemp:=AT("-",cBuffer) 
					cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
					Exit 
				EndIf 
			EndDo   
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_CBASE" })][2])+;
								    											"-"+STRZERO(VAL(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="N1_ITEM" })][2]),TamSX3("N1_ITEM")[01])+"'"
			WWW->MEMO		:= cErroTemp
		    WWW->(MsUnlock())
			FERASE(GetTempPath()+"\TEMP.log")
		EndIf		
	EndIf
EndIf

Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqI()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Purchase Order
Autor       : Jean Victor Rocha
Data/Hora   : 13/01/2014
*/
*-------------------------------*
Static Function GeraArqI(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.


//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"W2_PO_NUM","W2_PO_DT","W2_FORN","W2_FORLOJ","W2_IMPORT","W2_AGENTE","W2_TIPO_EM","W2_ORIGEM","W2_DEST",;
					"W2_INCOTER","W2_FREPPCC","W2_COND_PA","W2_MOEDA","W2_DT_PAR","W2_PARID_U","W2_E_LC","W2_COMPRA",;
					"W3_COD_I","W3_CC","W3_REG","W3_PRECO","W3_FABR","W3_FABLOJ","W3_QTDE","W3_DT_EMB","W2_DESP",;
					"W3_DT_ENTR","W3_SALDO_Q"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "W2_" $ UPPER(aLinha[1]) .or. "W3_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "W2_" $ UPPER(aLinha[1]) .or. "W3_" $ UPPER(aLinha[1]) 
		    For i:=1 to len(aLinha)
				If "W2_" $ UPPER(aLinha[1]) .or. "W3_" $ UPPER(aLinha[1])
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

Private nPos_01 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_FORN"	} )
Private nPos_02 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_COMPRA"	} )
Private nPos_03 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_IMPORT"  } )
Private nPos_04 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_AGENTE"  } )
Private nPos_05 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_TIPO_EM" } )
Private nPos_06 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_ORIGEM"  } )
Private nPos_07 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_DEST"    } )
Private nPos_08 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_INCOTER" } )
Private nPos_09 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_FREPPCC" } )
Private nPos_10 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_COND_PA" } )
Private nPos_11 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_MOEDA"   } )
Private nPos_12 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_DT_PAR"  } )
Private nPos_13 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_PARID_U" } )
Private nPos_14 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_E_LC"   	} )
Private nPos_15 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_COD_I"  	} )
Private nPos_16 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_CC"     	} )
Private nPos_17 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_REG"    	} )
Private nPos_18 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_PRECO"  	} )
Private nPos_19 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_FABR"   	} )
Private nPos_21 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_QTDE"   	} )
Private nPos_22 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_DT_EMB" 	} )
Private nPos_23 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_DT_ENTR"	} )
Private nPos_24 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_SALDO_Q"	} )
Private nPos_25 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_PO_NUM"	} )
Private nPos_26 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_PO_DT"	} )
Private nPos_27 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_DESP"	} )
Private nPos_28 := aScan( aCampos1, { |x| alltrim(x[1]) == "W2_FORLOJ"	} )
Private nPos_29 := aScan( aCampos1, { |x| alltrim(x[1]) == "W3_FABLOJ"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPos_01==0,(lMsgC:=.T.,cMsgCampo+=  "W2_FORN"	+","),)
IF(nPos_02==0,(lMsgC:=.T.,cMsgCampo+=  "W2_COMPRA"  +","),)
IF(nPos_03==0,(lMsgC:=.T.,cMsgCampo+=  "W2_IMPORT"  +","),)
IF(nPos_04==0,(lMsgC:=.T.,cMsgCampo+=  "W2_AGENTE"  +","),)
IF(nPos_05==0,(lMsgC:=.T.,cMsgCampo+=  "W2_TIPO_EM" +","),)
IF(nPos_06==0,(lMsgC:=.T.,cMsgCampo+=  "W2_ORIGEM"  +","),)
IF(nPos_07==0,(lMsgC:=.T.,cMsgCampo+=  "W2_DEST"    +","),)
IF(nPos_08==0,(lMsgC:=.T.,cMsgCampo+=  "W2_INCOTER" +","),)
IF(nPos_09==0,(lMsgC:=.T.,cMsgCampo+=  "W2_FREPPCC" +","),)
IF(nPos_10==0,(lMsgC:=.T.,cMsgCampo+=  "W2_COND_PA" +","),)
IF(nPos_11==0,(lMsgC:=.T.,cMsgCampo+=  "W2_MOEDA"   +","),)
IF(nPos_12==0,(lMsgC:=.T.,cMsgCampo+=  "W2_DT_PAR"  +","),)
IF(nPos_13==0,(lMsgC:=.T.,cMsgCampo+=  "W2_PARID_U" +","),)
IF(nPos_14==0,(lMsgC:=.T.,cMsgCampo+=  "W2_E_LC"    +","),)
IF(nPos_15==0,(lMsgC:=.T.,cMsgCampo+=  "W3_COD_I"   +","),)
IF(nPos_16==0,(lMsgC:=.T.,cMsgCampo+=  "W3_CC"      +","),)
IF(nPos_17==0,(lMsgC:=.T.,cMsgCampo+=  "W3_REG"     +","),)
IF(nPos_18==0,(lMsgC:=.T.,cMsgCampo+=  "W3_PRECO"   +","),)
IF(nPos_19==0,(lMsgC:=.T.,cMsgCampo+=  "W3_FABR"    +","),)
IF(nPos_21==0,(lMsgC:=.T.,cMsgCampo+=  "W3_QTDE"    +","),)
IF(nPos_22==0,(lMsgC:=.T.,cMsgCampo+=  "W3_DT_EMB"  +","),)
IF(nPos_23==0,(lMsgC:=.T.,cMsgCampo+=  "W3_DT_ENTR" +","),)
IF(nPos_24==0,(lMsgC:=.T.,cMsgCampo+=  "W3_SALDO_Q" +","),)
IF(nPos_25==0,(lMsgC:=.T.,cMsgCampo+=  "W2_PO_NUM"	+","),)
IF(nPos_26==0,(lMsgC:=.T.,cMsgCampo+=  "W2_PO_DT"	+","),)
IF(nPos_27==0,(lMsgC:=.T.,cMsgCampo+=  "W2_DESP"	+","),)
IF(nPos_28==0,(lMsgC:=.T.,cMsgCampo+=  "W2_FORLOJ"	+","),)
IF(nPos_29==0,(lMsgC:=.T.,cMsgCampo+=  "W3_FABLOJ"	+","),)               

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf

Private aPO := {}

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo
While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	For nK:=1 to len(aCampos1)
		If ALLTRIM(aCampos1[nK][1]) == "W2_FILIAL"
			aAdd(aAux,{aCampos1[nK][1], STRZERO(VAL(aLinha[nK]), TamSX3("W2_FILIAL")[01])		, Nil})			
		
		ElseIf ALLTRIM(aCampos1[nK][1]) == "W2_COND_PA" .or. ALLTRIM(aCampos1[nK][1]) == "W3_COD_I"
			aAdd(aAux,{aCampos1[nK][1], AvKey(aLinha[nK],ALLTRIM(aCampos1[nK][1]))	, Nil})

		Else 
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
	   	EndIf
	Next nK

	If aScan(aAux, {|x| ALLTRIM(x[1]) == "W2_FILIAL"}) == 0
		aAdd(aAux,{"W2_FILIAL", xFilial("SW2"), Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "W2_PO_NUM"}) == 0
		aAdd(aAux,{"W2_PO_NUM", GetSxeNum("EW2", "W2_PO_NUM"), Nil})
		Confirmsx8()
	EndIf	
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "W3_FORN"}) == 0
		aAdd(aAux,{"W3_FORN", aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "W2_FORN"})][2], Nil})
	EndIf

	aAdd(aPO,aAux)
	
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "W2_PO_NUM" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutI()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutI()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Purchase Order.
Autor       : Jean Victor Rocha
Data/Hora   : 13/01/2014
*/                          
*-------------------------*
Static Function ExecAutI()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""
Private aCab := {}
Private aItens := {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

If Len(aPO) == 0
	Reclock("WWW",.T.)
   	WWW->SITUACAO	:="Erro"
   	WWW->CODIGO		:= ""
   	WWW->CODREF		:= ""
   	WWW->CGC		:= ""
   	WWW->DESCRICAO	:= "Conteudo em branco!"
    WWW->(MsUnlock())
    Return .F.
EndIf

aSort(aPO,,)
cChave := alltrim(aPO[1][aScan(aPO[1],{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])
lErroFor	:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .f.                       

For i:=1 to Len(aPO)
	IncProc("Processando registro: "+alltrim(aPO[i][aScan(aPO[i], {|x| ALLTRIM(x[1]) == "W2_PO_NUM" })][2] )    )
	//Validação de preenchimento do campo                                                                                                                     ]
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aPO[i][aScan(aPO[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	If i == 1 .and. Len(aCab) == 0
	    For j:=1 to len(aPO[i])
			If Left(aPO[i][j][1],3) == "W2_"
				aAdd(aCab,aPO[i][j])
			EndIf
		Next j
	EndIf
	If cChave <> alltrim(aPO[i][aScan(aPO[i],{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])
		If !lErroFor
			SW2->(DbSetOrder(1))//W2_FILIAL, W2_PO_NUM
			If SW2->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_FILIAL" })][2])+;
										alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])	))
		   		Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "P.O. Duplicado:'"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
			    WWW->(MsUnlock())
			Else
				MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aCab,aItens,3) 
				If !lMsErroAuto
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Processado"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "P.O. Incluido com sucesso: '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
				    WWW->(MsUnlock())			
				Else
			    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
					nLinhas		:= MLCount(cErroTemp) 
					cBuffer		:= "" 
					cCampo		:= "" 
					nErrLin		:= 1 
					cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
					//Carrega o nome do campo 
					While (nErrLin <= nLinhas) 
						nErrLin++ 
						cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
						If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
							cCampo:=cBuffer 
							xTemp:=AT("-",cBuffer) 
							cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
							Exit 
						EndIf 
					EndDo   
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Erro"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! - '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
			    	WWW->MEMO		:= cErroTemp
				    WWW->(MsUnlock())
					FERASE(GetTempPath()+"\TEMP.log")
				EndIf		
			EndIf
		EndIf
		cChave := alltrim(aPO[i][aScan(aPO[i],{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])
		aCab := {}
   		aItens := {}     
		lErroFor	:= .F.
		lMsErroAuto := .F.
    EndIf
    If Len(aCab) == 0
	    For j:=1 to len(aPO[i])
			If Left(aPO[i][j][1],3) == "W2_"
				aAdd(aCab,aPO[i][j])
			EndIf	
		Next j
    EndIf
    aAux := {}
	For j:=1 to len(aPO[i])
		If Left(aPO[i][j][1],3) == "W3_"
	   		aAdd(aAux,aPO[i][j])
		EndIf	
	Next j
	If Len(aAux) <> 0
		aAdd(aItens,aAux)
	EndIf  
Next i       

If !lErroFor//Executa novamente para que considere a ultima linha do array.
	SW2->(DbSetOrder(1))//W2_FILIAL, W2_PO_NUM
	If SW2->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_FILIAL" })][2])+;
								alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])	))
   		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "P.O. Duplicado:'"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
	    WWW->(MsUnlock())
	Else
		MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aCab,aItens,3) 
		If !lMsErroAuto
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Processado"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "P.O. Incluido com sucesso: '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
		    WWW->(MsUnlock())			
		Else
	    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
			nLinhas		:= MLCount(cErroTemp) 
			cBuffer		:= "" 
			cCampo		:= "" 
			nErrLin		:= 1 
			cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
			//Carrega o nome do campo 
			While (nErrLin <= nLinhas) 
				nErrLin++ 
				cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
				If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
					cCampo	:= cBuffer 
					xTemp	:= AT("-",cBuffer) 
					cCampo	:= AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
					Exit 
				EndIf 
			EndDo   
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! - '"	+alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="W2_PO_NUM" })][2])+"'"
	    	WWW->MEMO		:= cErroTemp
		    WWW->(MsUnlock())
			FERASE(GetTempPath()+"\TEMP.log")
		EndIf		
	EndIf
EndIf

Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArq5()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico NF de Entrada (.CSV)
Autor       : Jean Victor Rocha
Data/Hora   : 20/01/2014
*/
*-------------------------------*
Static Function GeraArq5(cArqTxt)
*-------------------------------*
ProcRegua(0)
Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.

//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_COND","F1_EMISSAO",;
					"F1_ESPECIE","F1_TIPO","F1_DTDIGIT","F1_EST",;
					"D1_ITEM","D1_COD","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_TES",;
					"D1_LOCAL",;
					"D1_TIPO","D1_CF","D1_RATEIO","D1_TP"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1]) 
		    For i:=1 to len(aLinha)
				If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1])
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

Private nPos_01 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_DOC"	} )
Private nPos_02 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_SERIE"	} )
Private nPos_03 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_FORNECE"	} )
Private nPos_04 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_LOJA"	} )
Private nPos_05 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_COND"	} )
Private nPos_06 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_EMISSAO"	} )
Private nPos_08 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_ESPECIE"	} )
Private nPos_09 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_TIPO" 	} )
Private nPos_10 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_DTDIGIT"	} )
Private nPos_11 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_EST"  	} )
Private nPos_12 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_ITEM" 	} )
Private nPos_13 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_COD"  	} )
Private nPos_14 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_UM"   	} )
Private nPos_15 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_QUANT"	} )
Private nPos_16 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_VUNIT"	} )
Private nPos_17 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_TOTAL"	} )
Private nPos_19 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_TES"  	} )
Private nPos_24 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_LOCAL"	} )
Private nPos_27 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_TIPO" 	} )
Private nPos_30 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_CF"   	} )
Private nPos_31 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_RATEIO"	} )
Private nPos_32 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_TP"		} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPos_01 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_DOC"		+","),)
IF(nPos_02 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_SERIE"	+","),)
IF(nPos_03 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_FORNECE"	+","),)
IF(nPos_04 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_LOJA"	+","),)
IF(nPos_05 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_COND"	+","),)
IF(nPos_06 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_EMISSAO"	+","),)
IF(nPos_08 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_ESPECIE"	+","),)
IF(nPos_09 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_TIPO" 	+","),)
IF(nPos_10 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_DTDIGIT"	+","),)
IF(nPos_11 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_EST"  	+","),)
IF(nPos_12 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_ITEM" 	+","),)
IF(nPos_13 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_COD"  	+","),)
IF(nPos_14 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_UM"		+","),)
IF(nPos_15 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_QUANT"	+","),)
IF(nPos_16 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_VUNIT"	+","),)
IF(nPos_17 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_TOTAL"	+","),)
IF(nPos_19 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_TES"		+","),)
IF(nPos_24 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_LOCAL"	+","),)
IF(nPos_27 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_TIPO"	+","),)
IF(nPos_30 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_CF"		+","),)
IF(nPos_31 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_RATEIO"	+","),)
IF(nPos_32 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_TP"		+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf

Private aNF := {}

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo
While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	For nK:=1 to len(aCampos1)
	   	If ALLTRIM(aCampos1[nK][1]) == "D1_ITEM"
			aAdd(aAux,{aCampos1[nK][1], STRZERO(VAL(aLinha[nK]), TamSX3("D1_ITEM")[01]), Nil})

		Else 
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
	   	EndIf
	Next nK

	If aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_FILIAL"}) == 0
		aAdd(aAux,{"F1_FILIAL", xFilial("SF1"), Nil})
	EndIf	
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_FILIAL"}) == 0
		aAdd(aAux,{"D1_FILIAL", aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_FILIAL"})][2], Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_DTDIGIT" }) == 0
		aAdd(aAux,{"D1_DTDIGIT" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_DTDIGIT"})][2], Nil})
	EndIf                                           
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_FORNECE" }) == 0
		aAdd(aAux,{"D1_FORNECE" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_FORNECE"})][2], Nil})
	EndIf                                           
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_LOJA" }) == 0
		aAdd(aAux,{"D1_LOJA" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_LOJA"})][2], Nil})
	EndIf                                           
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_EMISSAO" }) == 0
		aAdd(aAux,{"D1_EMISSAO" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_EMISSAO"})][2], Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_DOC" }) == 0
		aAdd(aAux,{"D1_DOC" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_DOC"})][2], Nil})
	EndIf
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_SERIE" }) == 0
		aAdd(aAux,{"D1_SERIE" , aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_SERIE"})][2], Nil})
	EndIf
	aAdd(aNF,aAux)
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/";
								+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - ";
								+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAut5()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAut5()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico NF de Entrada (.CSV)
Autor       : Jean Victor Rocha
Data/Hora   : 20/01/2014
*/                          
*------------------------*
Static Function ExecAut5()
*------------------------*  
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""
Private aCab := {}
Private aItens := {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

If Len(aNF) == 0
	Reclock("WWW",.T.)
   	WWW->SITUACAO	:="Erro"
   	WWW->CODIGO		:= ""
   	WWW->CODREF		:= ""
   	WWW->CGC		:= ""
   	WWW->DESCRICAO	:= "Conteudo em branco!"
    WWW->(MsUnlock())
    Return .F.
EndIf

aSort(aNF,,)

cChave := 	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" 		})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" 	})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" 	})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" 		})])
			
lErroFor	:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .f.                       

For i:=1 to Len(aNF)
	IncProc("Processando registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/";
									+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - ";
									+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })]))
	//Validação de preenchimento do campo                                                                                                                     ]
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aNF[i][aScan(aNF[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	If i == 1 .and. Len(aCab) == 0
	    For j:=1 to len(aNF[i])
			If Left(aNF[i][j][1],3) == "F1_"
				aAdd(aCab,aNF[i][j])
			EndIf
		Next j
	EndIf
	If cChave <> 	+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })])
		If !lErroFor
			SF1->(DbSetOrder(1))
			If SN1->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="F1_FILIAL" })][2])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })]) )) 
		   		Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "NF Duplicada:'"	+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
														alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
														alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
			    WWW->(MsUnlock())
			Else
				MSExecAuto({|X,Y| MATA103(X,Y)},aCab,aItens,3)
				If !lMsErroAuto
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Processado"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Nf Incluida com sucesso: '"+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
												  	  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
													  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
				    WWW->(MsUnlock())			
				Else
			    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
					nLinhas		:= MLCount(cErroTemp) 
					cBuffer		:= "" 
					cCampo		:= "" 
					nErrLin		:= 1 
					cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
					//Carrega o nome do campo 
					While (nErrLin <= nLinhas) 
						nErrLin++ 
						cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
						If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
							cCampo:=cBuffer 
							xTemp:=AT("-",cBuffer) 
							cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
							Exit 
						EndIf 
					EndDo   
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Erro"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
													 											alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
												   												alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
					WWW->MEMO		:= cErroTemp
				    WWW->(MsUnlock())
					FERASE(GetTempPath()+"\TEMP.log")
				EndIf		
			EndIf
		EndIf
		cChave :=	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })])
		aCab := {}
   		aItens := {}     
		lErroFor	:= .F.
		lMsErroAuto := .F.
    EndIf
    If Len(aCab) == 0
	    For j:=1 to len(aNF[i])
			If Left(aNF[i][j][1],3) == "F1_"
				aAdd(aCab,aNF[i][j])
			EndIf	
		Next j
    EndIf
    aAux := {}
	For j:=1 to len(aNF[i])
		If Left(aNF[i][j][1],3) == "D1_"
	   		aAdd(aAux,aNF[i][j])
		EndIf	
	Next j
	If Len(aAux) <> 0
		aAdd(aItens,aAux)
	EndIf  
Next i       

If !lErroFor//Executa novamente para que considere a ultima linha do array.
	MSExecAuto({|X,Y| MATA103(X,Y)},aCab,aItens,3)
	If !lMsErroAuto
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Processado"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Nf Incluida com sucesso: '"+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
									  	  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
										  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
	    WWW->(MsUnlock())			
	Else
    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
		nLinhas		:= MLCount(cErroTemp) 
		cBuffer		:= "" 
		cCampo		:= "" 
		nErrLin		:= 1 
		cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
		//Carrega o nome do campo 
		While (nErrLin <= nLinhas) 
			nErrLin++ 
			cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
			If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
				cCampo:=cBuffer 
				xTemp:=AT("-",cBuffer) 
				cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
				Exit 
			EndIf 
		EndDo   
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
										 											alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
									   												alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
		WWW->MEMO		:= cErroTemp
	    WWW->(MsUnlock())
		FERASE(GetTempPath()+"\TEMP.log")
	EndIf		
EndIf
Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqJ()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico NF de Entrada (.CSV)
Autor       : Jean Victor Rocha
Data/Hora   : 20/01/2014
*/
*-------------------------------*
Static Function GeraArqJ(cArqTxt)
*-------------------------------*
ProcRegua(0)
Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.
Private aNFPre := {}
//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_COND","F1_EMISSAO","F1_ESPECIE","F1_TIPO","F1_FORMUL",;
						"D1_COD","D1_ITEM","D1_QUANT","D1_VUNIT","D1_TOTAL"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1]) 
		    For i:=1 to len(aLinha)
				If "F1_" $ UPPER(aLinha[1]) .or. "D1_" $ UPPER(aLinha[1])
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

Private nPos_01 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_DOC"	} )
Private nPos_02 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_SERIE"	} )
Private nPos_03 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_FORNECE"	} )
Private nPos_04 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_LOJA"	} )
Private nPos_05 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_COND"	} )
Private nPos_06 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_EMISSAO"	} )
Private nPos_09 := aScan( aCampos1, { |x| alltrim(x[1]) == "F1_TIPO" 	} )
Private nPos_12 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_ITEM" 	} )
Private nPos_13 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_COD"  	} )
Private nPos_15 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_QUANT"	} )
Private nPos_16 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_VUNIT"	} )
Private nPos_17 := aScan( aCampos1, { |x| alltrim(x[1]) == "D1_TOTAL"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPos_01 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_DOC"		+","),)
IF(nPos_02 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_SERIE"	+","),)
IF(nPos_03 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_FORNECE"	+","),)
IF(nPos_04 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_LOJA"	+","),)
IF(nPos_05 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_COND"	+","),)
IF(nPos_06 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_EMISSAO"	+","),)
IF(nPos_09 ==0,(lMsgC:=.T.,cMsgCampo+= "F1_TIPO" 	+","),)
IF(nPos_12 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_ITEM" 	+","),)
IF(nPos_13 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_COD"  	+","),)
IF(nPos_15 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_QUANT"	+","),)
IF(nPos_16 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_VUNIT"	+","),)
IF(nPos_17 ==0,(lMsgC:=.T.,cMsgCampo+= "D1_TOTAL"	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf

aNFPre := {}

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo
While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	For nK:=1 to len(aCampos1)
	   	If ALLTRIM(aCampos1[nK][1]) == "D1_ITEM"
			aAdd(aAux,{aCampos1[nK][1], STRZERO(VAL(aLinha[nK]), TamSX3("D1_ITEM")[01]), Nil})

		Else 
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
	   	EndIf
	Next nK

	If aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_FILIAL"}) == 0
		aAdd(aAux,{"F1_FILIAL", xFilial("SF1"), Nil})
	EndIf	
	If aScan(aAux, {|x| ALLTRIM(x[1]) == "D1_FILIAL"}) == 0
		aAdd(aAux,{"D1_FILIAL", aAux[aScan(aAux, {|x| ALLTRIM(x[1]) == "F1_FILIAL"})][2], Nil})
	EndIf
	aAdd(aNFPre,aAux)
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/";
								+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - ";
								+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutJ()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutJ()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico NF de Entrada (.CSV)
Autor       : Jean Victor Rocha
Data/Hora   : 20/01/2014
*/                          
*------------------------*
Static Function ExecAutJ()
*------------------------*  
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""
Private aCab := {}
Private aItens := {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

If Len(aNFPre) == 0
	Reclock("WWW",.T.)
   	WWW->SITUACAO	:="Erro"
   	WWW->CODIGO		:= ""
   	WWW->CODREF		:= ""
   	WWW->CGC		:= ""
   	WWW->DESCRICAO	:= "Conteudo em branco!"
    WWW->(MsUnlock())
    Return .F.
EndIf

aSort(aNFPre,,)

cChave := 	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" 		})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" 	})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" 	})])+;
			alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" 		})])
			
lErroFor	:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .f.                       

For i:=1 to Len(aNFPre)
	IncProc("Processando registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/";
									+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - ";
									+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })]))
	//Validação de preenchimento do campo                                                                                                                     ]
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aNFPre[i][aScan(aNFPre[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	If i == 1 .and. Len(aCab) == 0
	    For j:=1 to len(aNFPre[i])
			If Left(aNFPre[i][j][1],3) == "F1_"
				aAdd(aCab,aNFPre[i][j])
			EndIf
		Next j
	EndIf
	If cChave <> 	+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })])
		If !lErroFor
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(alltrim(aCab[aScan(aCab,{|x| ALLTRIM(x[1])=="F1_FILIAL" })][2])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
							alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })]) )) 
		   		Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "NF Duplicada:'"	+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
														alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
														alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
			    WWW->(MsUnlock())
			Else
				MSExecAuto({|X,Y,Z| MATA140(X,Y,Z)},aCab,aItens,3)
				If !lMsErroAuto
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Processado"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Nf Incluida com sucesso: '"+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
												  	  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
													  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
				    WWW->(MsUnlock())			
				Else
			    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
					nLinhas		:= MLCount(cErroTemp) 
					cBuffer		:= "" 
					cCampo		:= "" 
					nErrLin		:= 1 
					cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
					//Carrega o nome do campo 
					While (nErrLin <= nLinhas) 
						nErrLin++ 
						cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
						If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
							cCampo:=cBuffer 
							xTemp:=AT("-",cBuffer) 
							cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
							Exit 
						EndIf 
					EndDo   
					Reclock("WWW",.T.)
			    	WWW->SITUACAO	:="Erro"
			    	WWW->CODIGO		:= ""
			    	WWW->CODREF		:= ""
			    	WWW->CGC		:= ""
			    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
													 											alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
												   												alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
					WWW->MEMO		:= cErroTemp
				    WWW->(MsUnlock())
					FERASE(GetTempPath()+"\TEMP.log")
				EndIf		
			EndIf
		EndIf
		cChave :=	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+;
					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_LOJA" })])
		aCab := {}
   		aItens := {}     
		lErroFor	:= .F.
		lMsErroAuto := .F.
    EndIf
    If Len(aCab) == 0
	    For j:=1 to len(aNFPre[i])
			If Left(aNFPre[i][j][1],3) == "F1_"
				aAdd(aCab,aNFPre[i][j])
			EndIf	
		Next j
    EndIf
    aAux := {}
	For j:=1 to len(aNFPre[i])
		If Left(aNFPre[i][j][1],3) == "D1_"
	   		aAdd(aAux,aNFPre[i][j])
		EndIf	
	Next j
	If Len(aAux) <> 0
		aAdd(aItens,aAux)
	EndIf  
Next i       

If !lErroFor//Executa novamente para que considere a ultima linha do array.
	MSExecAuto({|X,Y,Z| MATA140(X,Y,Z)},aCab,aItens,3)
	If !lMsErroAuto
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Processado"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Nf Incluida com sucesso: '"+	alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
									  	  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
										  					alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
	    WWW->(MsUnlock())			
	Else
    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
		nLinhas		:= MLCount(cErroTemp) 
		cBuffer		:= "" 
		cCampo		:= "" 
		nErrLin		:= 1 
		cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
		//Carrega o nome do campo 
		While (nErrLin <= nLinhas) 
			nErrLin++ 
			cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
			If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
				cCampo:=cBuffer 
				xTemp:=AT("-",cBuffer) 
				cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
				Exit 
			EndIf 
		EndDo   
		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_DOC" })])+"/"+;
										 											alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_SERIE" })])+" - "+;
									   												alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "F1_FORNECE" })])+"'"
		WWW->MEMO		:= cErroTemp
	    WWW->(MsUnlock())
		FERASE(GetTempPath()+"\TEMP.log")
	EndIf		
EndIf
Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqk()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Saldos Iniciais
Autor       : Jean Victor Rocha
Data/Hora   : 21/01/2014
*/
*-------------------------------*
Static Function GeraArqk(cArqTxt)
*-------------------------------*
ProcRegua(0)
Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.
Private aSB9 := {}
//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"B9_COD","B9_LOCAL","B9_QINI"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "B9_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "B9_" $ UPPER(aLinha[1])
		    For i:=1 to len(aLinha)
				If "B9_" $ UPPER(aLinha[1])
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

Private nPos_01 := aScan( aCampos1, { |x| alltrim(x[1]) == "B9_COD"		} )
Private nPos_02 := aScan( aCampos1, { |x| alltrim(x[1]) == "B9_LOCAL"	} )
Private nPos_03 := aScan( aCampos1, { |x| alltrim(x[1]) == "B9_QINI"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPos_01 ==0,(lMsgC:=.T.,cMsgCampo+= "B9_COD"		+","),)
IF(nPos_02 ==0,(lMsgC:=.T.,cMsgCampo+= "B9_LOCAL"	+","),)
IF(nPos_03 ==0,(lMsgC:=.T.,cMsgCampo+= "B9_QINI"	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf

aSB9 := {}

FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo
While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	For nK:=1 to len(aCampos1)
		If aCampos1[nK][1] == "B9_COD"
	 		aAdd(aAux,{aCampos1[nK][1], AVKEY(aLinha[nK],"B9_COD"), Nil})
		Else
	   		Do Case
	   			Case aCampos1[nK][2] == "C"
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   			Case aCampos1[nK][2] == "D"
			   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
		   		Case aCampos1[nK][2] == "N"
			   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
			   	OtherWise
			   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
	   		EndCase
	 EndIf
	Next nK

	aAdd(aSB9,aAux)
	IncProc("Lendo registro: "+aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "B9_COD" })])
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutk()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutk()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Saldos Iniciais
Autor       : Jean Victor Rocha
Data/Hora   : 20/01/2014
*/                          
*------------------------*
Static Function ExecAutk()
*------------------------*  
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""
Private aCab := {}
Private aItens := {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

If Len(aSB9) == 0
	Reclock("WWW",.T.)
   	WWW->SITUACAO	:="Erro"
   	WWW->CODIGO		:= ""
   	WWW->CODREF		:= ""
   	WWW->CGC		:= ""
   	WWW->DESCRICAO	:= "Conteudo em branco!"
    WWW->(MsUnlock())
    Return .F.
EndIf

aSort(aSB9,,)

lErroFor	:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .f.                       

For i:=1 to Len(aSB9)
	IncProc("Processando registro: "+aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_COD" })][2])
	lErroFor	:= .F.

	//Validação de preenchimento do campo                                                                                                                     ]
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j

	SB9->(DbSetOrder(1))//B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
	If SB9->(DbSeek(xFilial("SB9")+aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_COD" })][2]+;
									alltrim(aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_LOCAL" })][2]) )) 
	    lErroFor := .T.
   		Reclock("WWW",.T.)
    	WWW->SITUACAO	:="Erro"
    	WWW->CODIGO		:= ""
    	WWW->CODREF		:= ""
    	WWW->CGC		:= ""
    	WWW->DESCRICAO	:= "Item Duplicado:'"	+aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_COD" })][2]
	    WWW->(MsUnlock())
	EndIf
	
	aCab := {}
	If !lErroFor
	    For j:=1 to len(aSB9[i])
			If Left(aSB9[i][j][1],3) == "B9_"
				aAdd(aCab,aSB9[i][j])
			EndIf
		Next j
    EndIf                    
    If LEN(aCab) <> 0
		lMsErroAuto := .F.
		MSExecAuto({|X,Y| MATA220(X,Y)},aCab,3)
		If !lMsErroAuto
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Processado"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Item Incluido com sucesso: '"+aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_COD" })][2]
		    WWW->(MsUnlock())			
		Else
	    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
			nLinhas		:= MLCount(cErroTemp) 
			cBuffer		:= "" 
			cCampo		:= "" 
			nErrLin		:= 1 
			cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
			//Carrega o nome do campo 
			While (nErrLin <= nLinhas) 
				nErrLin++ 
				cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
				If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
					cCampo:=cBuffer 
					xTemp:=AT("-",cBuffer) 
					cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
					Exit 
				EndIf 
			EndDo   
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido! "+aSB9[i][aScan(aSB9[i], {|x| ALLTRIM(x[1]) == "B9_COD" })][2]
			WWW->MEMO		:= cErroTemp
		    WWW->(MsUnlock())
			FERASE(GetTempPath()+"\TEMP.log")
		EndIf		
	EndIf   
	
Next i       


Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())

Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqL()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Contas a Pagar.
Autor       : Jean Victor Rocha
Data/Hora   : 05/02/2014
*/
*-------------------------------*
Static Function GeraArqL(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.

Private aSE2			:= {}

//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"E2_NUM","E2_TIPO","E2_NATUREZ","E2_FORNECE","E2_LOJA","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_VALOR"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "E2_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "E2_" $ aLinha[1] 
		    For i:=1 to len(aLinha)
				If "E2_" $ aLinha[i]
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif

//-------Posição dos campos-------//
Private nPosE1_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_NUM"		} )
Private nPosE1_2	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_TIPO"	} )
Private nPosE1_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_NATUREZ"	} )
Private nPosE1_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_FORNECE"	} )
Private nPosE1_5	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_LOJA"	} )
Private nPosE1_6	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_EMISSAO"	} )
Private nPosE1_7	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_VENCTO"	} )
Private nPosE1_8	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_VENCREA"	} )
Private nPosE1_9	:= aScan( aCampos1, { |x| alltrim(x[1]) == "E2_VALOR"	} )

//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosE1_1	==0,(lMsgC:=.T.,cMsgCampo+="E2_NUM" 	+","),)
IF(nPosE1_2	==0,(lMsgC:=.T.,cMsgCampo+="E2_TIPO"	+","),)
IF(nPosE1_3	==0,(lMsgC:=.T.,cMsgCampo+="E2_NATUREZ"	+","),)
IF(nPosE1_4	==0,(lMsgC:=.T.,cMsgCampo+="E2_FORNECE"	+","),)
IF(nPosE1_5	==0,(lMsgC:=.T.,cMsgCampo+="E2_LOJA"	+","),)
IF(nPosE1_6	==0,(lMsgC:=.T.,cMsgCampo+="E2_EMISSAO"	+","),)
IF(nPosE1_7	==0,(lMsgC:=.T.,cMsgCampo+="E2_VENCTO"	+","),)
IF(nPosE1_8	==0,(lMsgC:=.T.,cMsgCampo+="E2_VENCREA"	+","),)
IF(nPosE1_9	==0,(lMsgC:=.T.,cMsgCampo+="E2_VALOR"	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	
      
FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "E2_PREFIXO" }) == 0
		aAdd(aAux, {"E2_PREFIXO","INT", NIL })
	EndIf
	For nK:=1 to len(aCampos1)
   		Do Case
   			Case aCampos1[nK][2] == "C"
		   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
   			Case aCampos1[nK][2] == "D"
		   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
	   		Case aCampos1[nK][2] == "N"
		   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
		   	OtherWise
		   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
   		EndCase
	Next nK
	aAdd(aSE2,aAux)
	
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "E2_NUM" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutL()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutL()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Contas a Pagar.
Autor       : Jean Victor Rocha
Data/Hora   : 05/02/2014
*/                          
*-------------------------*
Static Function ExecAutL()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.
Local cDcProd       :=""
Local cDcForn		:=""

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

For i:=1 to Len(aSE2)
	lErroFor	:= .F.
	lMsErroAuto := .F.
	aExecAuto	:= {}
	IncProc("Processando registro: "+alltrim(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == "E2_NUM" })][2] )    )
	//Validação de preenchimento do campo
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	aExecAuto := aSE2[i]
	
	If !lErroFor
		SE2->(DbSetOrder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SE2->(DbSeek(xFilial("SE2")+;
						alltrim(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == "E2_PREFIXO" })][2])+;
						alltrim(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == "E2_NUM" })][2] );
						))
	   		Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Titulo Duplicado: '"+alltrim(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == "E2_NUM" })][2] )+"'"
		    WWW->(MsUnlock())
		Else
			MsExecAuto( { |x,y| FINA050(x,y)} , aExecAuto, 3)
			If !lMsErroAuto
				Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Processado"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Titulo Incluido com sucesso: '"+alltrim(aSE2[i][aScan(aSE2[i], {|x| ALLTRIM(x[1]) == "E2_NUM" })][2] )+"'"
			    WWW->(MsUnlock())			
			Else
		    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
				nLinhas		:= MLCount(cErroTemp) 
				cBuffer		:= "" 
				cCampo		:= "" 
				nErrLin		:= 1 
				cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
				//Carrega o nome do campo 
				While (nErrLin <= nLinhas) 
					nErrLin++ 
					cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
					If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
						cCampo:=cBuffer 
						xTemp:=AT("-",cBuffer) 
						cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
						Exit 
					EndIf 
				EndDo   
				Reclock("WWW",.T.)
		    	WWW->SITUACAO	:="Erro"
		    	WWW->CODIGO		:= ""
		    	WWW->CODREF		:= ""
		    	WWW->CGC		:= ""
		    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido!"
		    	WWW->MEMO		:= cErroTemp
			    WWW->(MsUnlock())
				FERASE(GetTempPath()+"\TEMP.log")
			EndIf		
		EndIf
	EndIf	
Next i

Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) )

/*
Funcao      : GeraArqM()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Medições/Entregas
Autor       : Jean Victor Rocha
Data/Hora   : 12/03/2014
*/
*-------------------------------*
Static Function GeraArqM(cArqTxt)
*-------------------------------*
ProcRegua(0)

Private nCnt          	:= 0
Private nPos          	:= 0
Private cCpoFaltantes	:= ""
Private cCampo        	:= ""
Private cTemDup       	:= ""
Private cCmpNExt		:= ""
Private cMsgCampo  		:= ""
Private aCampos       	:= {} 
Private aCampos1      	:= {}
Private aCpoObrigat   	:= {}
Private lCpoFal       	:= .F.
Private lTemDup       	:= .F.
Private lCmpNExt		:= .F.
Private lCrt          	:= .F.
Private lMsgC			:= .F.

Private aCND			:= {}

//Campos obrigatórios que devem estar no arquivo
aCpoObrigat   	:= {"CND_CONTRA","CND_MOEDA","CNE_PRODUT","CNE_QUANT","CNE_VLUNIT"}

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
	cLinha := FT_FReadln()				//Le a linha
	aLinha := separa(UPPER(cLinha),";")	//Sepera para vetor 
	If "CND_" $ UPPER(aLinha[1]) .or. "CNE_" $ UPPER(aLinha[1])
		//Verifica se os campos base estão no arquivo
		For cont:=1 to len(aCpoObrigat)
			If !(alltrim(aCpoObrigat[cont]) $ UPPER(cLinha))
				cCpoFaltantes+=aCpoObrigat[cont]+","
			Endif
		Next cont

		If !Empty(cCpoFaltantes)
			Alert("Os campos base não estão no arquivo: "+cCpoFaltantes)
		    lCpoFal:=.T.
		    exit
		Endif

		If "CND_" $ aLinha[1]  .or. "CNE_" $ aLinha[i]
		    For i:=1 to len(aLinha)
				If "CND_" $ aLinha[i] .or. "CNE_" $ aLinha[i]
			 		cCampo := Alltrim(aLinha[i])
			 		DBSELECTAREA("SX3")
					Dbsetorder(2)
					If Dbseek(cCampo)
						If aScan(aCampos, { |x| alltrim(x[1]) == cCampo} ) > 0
							lTemDup := .T.
							cTemDup += cCampo+","
						Endif
						AADD(aCampos ,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    	AADD(aCampos1,{cCampo,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO})
				    Else
				    	lCmpNExt := .T.
				    	cCmpNExt += cCampo+","
				    EndIf 
					lCrt:=.T.
				Else
					AADD(aCampos1,{"","","","",""})
				EndIf
			Next
		Else
			FT_FSkip() //Proxima linha
		EndIf	

		If lCrt
		   	FT_FSkip() //Proxima linha
			nPos := FT_FRECNO()
			Exit
		EndIf 
    Else
	    FT_FSkip() //Proxima linha
    Endif
Enddo

If EMPTY(aCampos) .AND. !lCpoFal
	Alert("Arquivo selecionado não possui campos para importação de "+ALLTRIM(aItensP[nSelec])+"!")
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
cCmpNExt := SUBSTR(cCmpNExt,1,len(cCmpNExt)-1)
if lCmpNExt
	Alert("O(s) campo(s): "+cCmpNExt+CRLF+"Não existe(m) no dicionário da empresa!"+CRLF+;
			" Favor verificar se foi digitado corretamente, caso persistir, abra um chamado para a equipe de sistemas!")
	FT_FUse()
	Return
endif


//-------Posição dos campos-------//
Private nPosCND_1	:= aScan( aCampos1, { |x| alltrim(x[1]) == "CND_CONTRA"	} )
Private nPosCND_3	:= aScan( aCampos1, { |x| alltrim(x[1]) == "CNE_QUANT"	} )
Private nPosCND_4	:= aScan( aCampos1, { |x| alltrim(x[1]) == "CNE_VLUNIT"	} )


//-----Verifica se os campos existem, para exibir a mensagem no arquivo-----//
IF(nPosCND_1	==0,(lMsgC:=.T.,cMsgCampo+="CND_CONTRA" +","),)
IF(nPosCND_3	==0,(lMsgC:=.T.,cMsgCampo+="CNE_QUANT"	+","),)
IF(nPosCND_4	==0,(lMsgC:=.T.,cMsgCampo+="CNE_VLUNIT"	+","),)

If lMsgC
	Alert("Campo(s) não consta(m) no arquivo: "	+CRLF	+	cMsgCampo)
	FT_FUse()
	Return .F.
EndIf	
      
FT_FUse() 			// Fecha o arquivo
FT_FUse(cArqTxt)	// Abre o arquivo
FT_FGOTO(nPos)		// Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	aAux := {}

	//Capa
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_NUMMED" }) == 0
		cDoc := CriaVar("CND_NUMMED")
		aAdd(aAux, {"CND_NUMMED",cDoc, NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_COMPET" }) == 0
		aAdd(aAux, {"CND_COMPET",STRZERO(MONTH(Date()),2)+"/"+STRZERO(YEAR(Date()),4), NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_NUMERO" }) == 0
		aAdd(aAux, {"CND_NUMERO","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_REVISA" }) == 0
		aAdd(aAux, {"CND_REVISA","", NIL })
	EndIf 
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_DTINIC" }) == 0
		aAdd(aAux, {"CND_DTINIC",ddatabase, NIL })
	EndIf 
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_DTVENC" }) == 0
		aAdd(aAux, {"CND_DTVENC",ddatabase, NIL })
	EndIf 
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_AUTFRN" }) == 0
		aAdd(aAux, {"CND_AUTFRN","1", NIL })
	EndIf	
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_SERVIC" }) == 0
		aAdd(aAux, {"CND_SERVIC","1", NIL })
	EndIf	
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_ZERO" }) == 0
		aAdd(aAux, {"CND_ZERO","2", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_CONDPG" }) == 0
		aAdd(aAux, {"CND_CONDPG","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_CLIENT" }) == 0
		aAdd(aAux, {"CND_CLIENT","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_LOJACL" }) == 0
		aAdd(aAux, {"CND_CONDPG","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_FORNEC" }) == 0
		aAdd(aAux, {"CND_FORNEC","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_LJFOR" }) == 0
		aAdd(aAux, {"CND_LJFOR","", NIL })
	EndIf
	If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
		If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_PARCEL" }) == 0
			aAdd(aAux, {"CND_PARCEL","", NIL })
		EndIf
	EndIf			

	//Itens
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_ITEM" }) == 0
		aAdd(aAux, {"CNE_ITEM","001", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_CONTRA" }) == 0
		aAdd(aAux, {"CNE_CONTRA","", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_DESCRI" }) == 0
		aAdd(aAux, {"CNE_DESCRI","", NIL })
	EndIf
	If !Empty(CNE->( FieldPos( "CNE_EXCEDE" ) ))
		If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_EXCEDE" }) == 0
			aAdd(aAux, {"CNE_EXCEDE","1", NIL })
		EndIf
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_FLGCMS" }) == 0
		aAdd(aAux, {"CNE_FLGCMS","1", NIL })
	EndIf
	If aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CNE_VLTOT" }) == 0
		aAdd(aAux, {"CNE_VLTOT",0, NIL })
	EndIf

	For nK:=1 to len(aCampos1)
   		Do Case
   			Case aCampos1[nK][2] == "C"
		   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
   			Case aCampos1[nK][2] == "D"
		   		aAdd(aAux,{aCampos1[nK][1], STOD(aLinha[nK]), Nil})
	   		Case aCampos1[nK][2] == "N"
		   		aAdd(aAux,{aCampos1[nK][1], VAL(aLinha[nK]), Nil})
		   	OtherWise
		   		aAdd(aAux,{aCampos1[nK][1], aLinha[nK], Nil})
   		EndCase
	Next nK
	aAdd(aCND,aAux)
	
	IncProc("Lendo registro: "+alltrim(aLinha[aScan(aCampos1, {|x| ALLTRIM(x[1]) == "CND_CONTRA" })]))
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

lRet:=ExecAutM()//Chamada da função de processamento.

Return(lRet)

/*
Funcao      : ExecAutM()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar os campos e conteudo do arquivo csv, especifico Medições/Entregas
Autor       : Jean Victor Rocha
Data/Hora   : 12/03/2014
*/                          
*-------------------------*
Static Function ExecAutM()
*-------------------------*
Local aCpos	   		:={}
Local lErro	   		:=.F.
Local lOk	   		:=.F.

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"CODREF","C",10,0})
AADD(aCpos,{"CGC","C",14,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

For i:=1 to Len(aCND)
	lErroFor	:= .F.
	aExecCab	:= {}
	aExecIte	:= {}
	IncProc("Processando registro: "+alltrim(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2] )    )

	//Tratamentos especificos.
	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_NUMERO" })) <> 0 .and.;
		aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" }) <> 0 .and.;
		EMPTY(aCND[i][nPos][2])
		
		cQryTmp := "Select TOP 1 * 
		cQryTmp += " From "+RETSQLNAME("CNA")
		cQryTmp += " Where  CNA_CONTRA = '"+ALLTRIM(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2])+"'
		cQryTmp += "	AND CNA_REVISA = (Select MAX(CNA_REVISA) 
		cQryTmp += "						From "+RETSQLNAME("CNA")
		cQryTmp += "						Where CNA_CONTRA = '"+ALLTRIM(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2])+"')
		
		If select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		Endif
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQryTmp), "QRYTEMP", .F., .F. )
		
		If QRYTEMP->(!EOF())
	    	aCND[i][nPos][2] := QRYTEMP->CNA_NUMERO
		EndIf
	EndIf
	If 	aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" }) <> 0
		cQryTmp := "Select TOP 1 * 
		cQryTmp += " From "+RETSQLNAME("CN9")
		cQryTmp += " Where  CN9_NUMERO = '"+ALLTRIM(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2])+"'
		cQryTmp += "	AND CN9_SITUAC = '05'
		
		If select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		Endif
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQryTmp), "QRYTEMP", .F., .F. )
		
		If QRYTEMP->(!EOF())
	    	If QRYTEMP->CN9_TPCTO == "002"//Variavel
				If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_NUMERO" })) <> 0
					aCND[i][nPos][2] := "000001"
				EndIf
	    	EndIf 
			If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CLIENT" })) <> 0
		    	aCND[i][nPos][2] := QRYTEMP->CN9_CLIENT
	    	EndIf
	    	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_LOJACL" })) <> 0
		    	aCND[i][nPos][2] := QRYTEMP->CN9_LOJACL
	    	EndIf
			If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_REVISA" })) <> 0
		    	aCND[i][nPos][2] := QRYTEMP->CN9_REVISA
	    	EndIf
	    	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONDPG" })) <> 0
		    	aCND[i][nPos][2] := QRYTEMP->CN9_CONDPG
	    	EndIf
		EndIf	
	EndIf
	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_CONTRA" })) <> 0 .and.;
		aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" }) <> 0 .and.;
		EMPTY(aCND[i][nPos][2])
		aCND[i][nPos][2] := aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2]
	EndIf
	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_DESCRI" })) <> 0 .and.;
		aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_PRODUT" }) <> 0 .and.;
		EMPTY(aCND[i][nPos][2])
		cQryTmp := "Select TOP 1 * 
		cQryTmp += " From "+RETSQLNAME("SB1")
		cQryTmp += " Where  B1_COD = '"+ALLTRIM(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_PRODUT" })][2])+"'
		If select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		Endif
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQryTmp), "QRYTEMP", .F., .F. )
		If QRYTEMP->(!EOF())
	    	aCND[i][nPos][2] := QRYTEMP->B1_DESC
		EndIf
	EndIf
	If (nPos := aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_VLTOT" })) <> 0 .and.;
		aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_VLUNIT" }) <> 0 .and.;
		aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CNE_QUANT" }) <> 0 .and.;
		aCND[i][nPos][2] == 0
		aCND[i][nPos][2] := aCND[i][aScan(aCND[i],{|x| ALLTRIM(x[1])=="CNE_VLUNIT" })][2] * aCND[i][aScan(aCND[i],{|x| ALLTRIM(x[1])=="CNE_QUANT" })][2]
	EndIf	
	
	//Validação de preenchimento do campo
	For j:=1 to Len(aCpoObrigat)
		If EMPTY(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == aCpoObrigat[j] })][2] )
		    lErroFor := .T.
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Campo '"+aCpoObrigat[j]+"' com conteudo em branco!"
		    WWW->(MsUnlock())
		EndIf
	Next j
	
	For c:=1 to len(aCND[i])
		If LEFT(aCND[i][c][1],4) == "CND_"
			aAdd(aExecCab,aCND[i][c])
		ElseIf LEFT(aCND[i][c][1],4) == "CNE_"
			aAdd(aExecIte,aCND[i][c])
		EndIf
	Next c
	aAux := aExecIte
	aExecIte := {}
	aAdd(aExecIte,aAux)

	If !lErroFor
		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		CNTA120(aExecCab,aExecIte,3,.F.)

		If !lMsErroAuto
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Processado"
	    	WWW->CODIGO		:= alltrim(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_NUMMED" })][2] )
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Incluido com sucesso: '"+alltrim(aCND[i][aScan(aCND[i], {|x| ALLTRIM(x[1]) == "CND_CONTRA" })][2] )+"'"
		    WWW->(MsUnlock())			
		Else
	    	cErroTemp	:= Mostraerro(GetTempPath(), "TEMP.log") 
			nLinhas		:= MLCount(cErroTemp) 
			cBuffer		:= "" 
			cCampo		:= "" 
			nErrLin		:= 1 
			cBuffer		:= RTrim(MemoLine(cErroTemp,,nErrLin))                
			//Carrega o nome do campo 
			While (nErrLin <= nLinhas) 
				nErrLin++ 
				cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin)) 
				If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO") 
					cCampo:=cBuffer 
					xTemp:=AT("-",cBuffer) 
					cCampo:=AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2)) 
					Exit 
				EndIf 
			EndDo   
			Reclock("WWW",.T.)
	    	WWW->SITUACAO	:="Erro"
	    	WWW->CODIGO		:= ""
	    	WWW->CODREF		:= ""
	    	WWW->CGC		:= ""
	    	WWW->DESCRICAO	:= "Execauto retornou erro no Campo '"+cCampo+"' Invalido!"
	    	WWW->MEMO		:= cErroTemp
		    WWW->(MsUnlock())
			FERASE(GetTempPath()+"\TEMP.log")
		EndIf		
	EndIf	
Next i

Situacao2()	

fErase(cArqErro+OrdBagExt())
fErase(cArqTErro+OrdBagExt())
 
Return( iif(lErro,.F.,.T.) )
