#include "totvs.ch"
#Include "topconn.ch"
#include "fileio.ch"  
#include "protheus.ch"
#INCLUDE "tbiconn.ch"  
#DEFINE ENTER CHR(13)+CHR(10)

/*
Funcao      : GTFAT022()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importação de cupom fiscal via XML SAT
Autor       : Anderson Arrais
Data/Hora   : 04/10/2018
*/    
*-----------------------*
User Function GTFAT022() 
*-----------------------*     
Local lOk 			:= .F.
Local cPerg 		:= "GTFAT022"                                              	

Private cDirArq		:= ""
Private cNatur		:= ""
Private cCCClie		:= ""
Private cCCProd		:= ""
Private cTesCup		:= ""
Private nIncProd	:= 0
Private nCalcImp    := 0

//MV_P_00129
SX6->(DbSetOrder(1))
If !SX6->(DbSeek(cFilAnt + "MV_P_00129"))
   	aSays := {}
	aBto  := {}
   	cText := "Integração SAT Grant Thornton"     
   	Aadd(aSays,"Essa rotina é personalizada.") 
   	Aadd(aSays,"Essa empresa não tem o parametro MV_P_00129")
   	Aadd(aSays,"Configurado." )   
   	Aadd(aSays,"Entre em contato com a equipe de Suporte." )                                 
   	Aadd(aBto, { 2,.T.,{|o| o:oWnd:End() }} )
   	FormBatch( cText, aSays, aBto,,200,360  )
   	Return .F.
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cDirArq		:= Alltrim(mv_par01)
	cNatur		:= Alltrim(mv_par02)
	cCCClie		:= Alltrim(mv_par03)
	cCCProd		:= Alltrim(mv_par04)
	//cTesCup		:= Alltrim(mv_par05)
    //nIncProd	:= mv_par06
    nCalcImp    := mv_par05
    
	If EMPTY(cDirArq)
		MsgInfo("O Diretorio deve ser informado!")
		Return (.F.)
	ElseIf !ExistDir(cDirArq)
		MsgInfo("Diretorio informado não encontrado!")
		Return (.F.)
	EndIf
	If EMPTY(cNatur) .OR. EMPTY(cCCClie) .OR. EMPTY(cCCProd) //.OR. EMPTY(cTesCup)
		MsgInfo("Todos os campos devem ser preenchidos.")
		Return (.F.)
	EndIf
	//Verifica se possir arquivos no diretorio.
	If Len(Directory ( cDirArq+"*.XML")) == 0
		MsgInfo("Não foi encontrado nenhum arquivo no diretorio informado!")
		Return (.F.)
	EndIf 

	//importa arquivo xml
	Processa({|| lOk := IntXml(cDirArq,cNatur,cCCClie,cCCProd,cTesCup,nIncProd)},"Importando o xml...")
    
	ProcCupom()
	
EndIf

Return Nil  

/*
Função  : IntXml
Objetivo: Integra XML de cupom fiscal
Autor   : Anderson Arrais
Data    : 05/10/2018
*/
*---------------------------------------------------------------------*
 Static Function IntXml(cDirArq,cNatur,cCCClie,cCCProd,cTesCup,nIncProd)
*---------------------------------------------------------------------*
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {} 
Local aCpos		:= {} 
Local aProd		:= {}
Local aTes      := {}


Local lErro		:= .F.
Local lRet		:= .F.
Local lProcessa := .F.
Local lRetB1	:= .F.

Local oXml
Local nX

Local cNum		:= ""
Local cError	:= "" 
Local cWarning	:= ""
Local cFilBak  	:= cFilAnt 
Local cDir	 	:= "\FTP\" + cEmpAnt + "\GTFAT022\" 

Local cEmiCGC,cIDCF,cDTEmi,cErro,cSerSat,cCFE,cCGC := ""
Local cEmiCGCc,cIDCFc,cDTEmic,cErroc,cSerSatc,cCFEc := ""

Local cText,aSays,aBto,lAchou 

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
Private lMsHelpAuto	   := .T. 

//Validação de no minimo um arquivo na pasta
aArquivos := Directory ( cDirArq+"*.XML" )

For i:=1 to Len(aArquivos)  
	cArqAtu := cDirArq+aArquivos[i][1]
	cError	:= ""
	cNum	:= ""
	
	If !LisDir( cDir )
		MakeDir( "\FTP" )
		MakeDir( "\FTP\" + cEmpAnt )	
		MakeDir( "\FTP\" + cEmpAnt + "\GTFAT022\" )		
	EndIf	
	
	CpyT2S(cArqAtu,cDir)
	       	
	cArquivo := cDir+aArquivos[i][1]

	oXml := XmlParserFile( cArquivo, "_", @cError, @cWarning )
    
    //Cupom de cancelamento
	If  XmlChildEx(oXml,'_CFECANC') <> NIL
		cEmiCGCc	:= Alltrim(oXml:_CFeCanc:_INFCFE:_EMIT:_CNPJ:TEXT)
		cIDCFc		:= Alltrim(oXml:_CFeCanc:_INFCFE:_ID:TEXT)     
		cDTEmic 	:= Alltrim(oXml:_CFeCanc:_INFCFE:_IDE:_DEMI:TEXT)
		cSerSatc	:= Alltrim(oXml:_CFeCanc:_INFCFE:_IDE:_NSERIESAT:TEXT)
		cCFEc 		:= Alltrim(oXml:_CFeCanc:_INFCFE:_IDE:_NCFE:TEXT)  
		If SatCanc(Alltrim(oXml:_CFeCanc:_INFCFE:_CHCANC:TEXT),cCFEc)
			//Achou e cancelou doc
			GravLog(cIDCFc,cSerSatc,cCFEc,"",cDTEmic,cEmiCGCc,"Cupom cancelado, chave: "+Alltrim(oXml:_CFeCanc:_INFCFE:_CHCANC:TEXT))
			MsgStop( "Cupom cancelado, chave: "+Alltrim(oXml:_CFeCanc:_INFCFE:_CHCANC:TEXT) )
			Loop
		Else
			//Não achou doc, não houve cancelamento
			GravLog(cIDCFc,cSerSatc,cCFEc,"",cDTEmic,cEmiCGCc,"Erro no cancelamento, chave: "+Alltrim(oXml:_CFeCanc:_INFCFE:_CHCANC:TEXT))
			MsgStop( "Erro no cancelamento, chave: "+Alltrim(oXml:_CFeCanc:_INFCFE:_CHCANC:TEXT) )
			Loop
		EndIf
	EndIf
		
	If !XmlChildEx(oXml,"_CFE") <> NIL
		//XML invalido
		MsgStop( "XML Invalido: "+aArquivos[i][1] )
		Loop
	EndIf
	
	cEmiCGC	:= Alltrim(oXml:_CFE:_INFCFE:_EMIT:_CNPJ:TEXT)
	cIDCF	:= Alltrim(oXml:_CFE:_INFCFE:_ID:TEXT)     
	cDTEmi 	:= Alltrim(oXml:_CFE:_INFCFE:_IDE:_DEMI:TEXT)
	cSerSat	:= Alltrim(oXml:_CFE:_INFCFE:_IDE:_NSERIESAT:TEXT)
	cCFE 	:= Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)   
	If XmlChildEx(oXml:_CFE:_INFCFE:_DEST,"_CPF") <> NIL
		cCGC	:=	Alltrim(oXml:_CFE:_INFCFE:_DEST:_CPF:TEXT)
	Else
		cCGC	:=	Alltrim(oXml:_CFE:_INFCFE:_DEST:_CNPJ:TEXT)
	EndIf
		
	//Valida se CNPJ percente ao grupo de empresa
	If Select("TEMPSM")>0
		("TEMPSM")->(DbCloseArea())
	EndIf
	
	cSQL := " SELECT M0_CGC, M0_CODIGO, M0_CODFIL 
	cSQL += " FROM SIGAMAT
	cSQL += " WHERE M0_CGC = '"+oXml:_CFE:_INFCFE:_EMIT:_CNPJ:TEXT+"'
	cSQL += " AND M0_CODIGO = '"+cEmpAnt+"'
	cSQL += " AND D_E_L_E_T_ = ''" 
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), "TEMPSM", .F., .T.)
	
	Count to nTotArq
	
	If !nTotArq > 0
		//CNPJ não encontrado para essa empresa
		MsgStop( "CNPJ da empresa não encontrado: "+aArquivos[i][1] )	
		FErase(cDir+aArquivos[i][1])
		Loop 
	EndIf                    
	
	TEMPSM->(DbGotop())
	cFilAnt	:= TEMPSM->M0_CODFIL
	
	//Valida Cliente
	DbSelectArea("SA1") 
	If EMPTY(cCGC)
		//CGC do XML em branco, pega cliente padrão
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+GETMV("MV_P_00129")+"01"))
	
	Else
	SA1->(DbSetOrder(3))
		If !SA1->(DbSeek(xFilial("SA1")+cCGC))
			//Tem informção de CGC porém não encontrou
	
			If CadClient(oXml,cNatur,cCCClie)
				//Erro no cadastro, continua com outro arquivo ou sai da rotina?
				cErro := "Erro no cadastro do cliente."
				If MsgYesNo( "Erro no cadastro do cliente, processa demais arquivos?", "Grant Thornton" )
					GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
					Loop
				Else 
					GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
					Return
				EndIf
			EndIf
			
		EndIf
	EndIf
    
	//PDV
	If Select("TMPSLG")>0
		("TMPSLG")->(DbCloseArea())
	EndIf
	
	cSQL := " SELECT LG_CODIGO,LG_SERIE,LG_SERSAT,LG_SERPDV,LG_PDV
	cSQL += " FROM "+retsqlname("SLG")
	cSQL += " WHERE  LG_SERSAT = '"+oXml:_CFE:_INFCFE:_IDE:_NSERIESAT:TEXT+"'
	cSQL += " AND LG_FILIAL = '"+cFilAnt+"'
	cSQL += " AND D_E_L_E_T_ = ''" 
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), "TMPSLG", .F., .T.)
	
	Count to nTotArq
	
	If !nTotArq > 0
		//SAT não encontrado no cadastro de PDV
		MsgStop( "SAT não encontrado no cadastro de PDV.")
		cErro := "SAT não encontrado no cadastro de PDV."
		GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)	
		Loop 
	EndIf                    
	TMPSLG->(DbGotop())
	
	//Vendedor
	DbSelectArea("SA3") 
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(xFilial("SA3")))                                            
		cVend	:= SA3->A3_COD
	Else
		cVend 	:= "000001"
	EndIf
	   
    //valida capa do cupom
    DbSelectArea("SL1")

    cNum := ProxCupom()
   
    SL1->(DbSetOrder(2))
    If SL1->(DbSeek(xFilial("SL1")+PADR(TMPSLG->LG_SERIE,TamSX3("L1_SERIE")[1],'')+PADR(Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT),TamSX3("L1_DOC")[1],'')+TMPSLG->LG_PDV))            
    	//se localizar cupom já cadadtrado salta
   		MsgStop( "XML já integrado, cupom: "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT) )
   		cErro:= "XML já integrado, cupom: "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
    	GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
    	FErase(cDir+aArquivos[i][1])
    	Loop	
    EndIf  
	
	If Valtype(oXml:_CFe:_infCFe:_det) == "A"	
	   nQtdItem := Len(oXml:_CFe:_infCFe:_det)	
	   If Len(oXml:_CFe:_infCFe:_det) > 1 
		  nCont := 0
		  For nY := 1 To nQtdItem	
			  SB1->(DbSetOrder(1))
			  SB1->(DbGotop()) 
			  If SB1->(!DbSeek(xFilial("SB1")+PADR(oXml:_CFe:_infCFe:_det[nY]:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1],'')))
			     nCont++ 
			     AAdd(aProd,PADR(oXml:_CFe:_infCFe:_det[nY]:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1],'') )
			  EndIf  
		  Next nY
	   EndIf
	EndIf
			
	If Len(aProd) > 0			
	   For nK := 1 To Len(aProd) 
	       cNum  := ''
	       cCupom := "Cupom : "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
	       cErro := "Produto não cadastrado: "+aProd[nK]
	       MsgStop(cCupom+' '+cErro)
	       GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
	   Next nK 
	   FErase(cDir+aArquivos[i][1]) 
	   frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_REJ_"+DTOS(Date())+".PRC" )
	   Return
	EndIf
	
	If Valtype(oXml:_CFe:_infCFe:_det) == "A"
	   aTES	:= {}
	   nQtdTES := Len(oXml:_CFe:_infCFe:_det)	
	   If Len(oXml:_CFe:_infCFe:_det) > 1 
		  nConTes := 0
		  DbSelectarea("SB1")
		  SB1->(DbSetOrder(1))
		  SB1->(DbGotop()) 
		  For nQ := 1 To nQtdTES
			  If SB1->(DbSeek(xFilial("SB1")+PADR(oXml:_CFe:_infCFe:_det[nQ]:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1],'')))
			     SF4->(DbSetOrder(1))
			     If SF4->(!DbSeek(xFilial("SF4")+SB1->B1_P_CFTES))
				    nConTes++ 
				    AAdd(aTES,SB1->B1_P_CFTES)         
				 EndIf 
			  EndIf	  
		  Next nQ
	   EndIf
	Else
	  DbSelectarea("SB1")
	  SB1->(DbSetOrder(1))
	  If SB1->(DbSeek(xFilial("SB1")+PADR(oXml:_CFe:_infCFe:_det:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1]) ) )
	     SF4->(DbSetOrder(1))
	     If SF4->(!DbSeek(xFilial("SF4")+SB1->B1_P_CFTES)  )
	        cNum  := ''
	        cCupom := "Cupom : "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
	        cErro := "TES não cadastrada: "+SB1->B1_P_CFTES
	        MsgStop(cCupom+' '+cErro)
	        GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)	
	        FErase(cDir+aArquivos[i][1]) 
	     	frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_REJ_"+DTOS(Date())+".PRC" )
	     	Return
	     EndIf
	  EndIf   	   		      
	EndIf
	
	If Len(aTES) > 0			
	   For nZ := 1 To Len(aTES) 
	       cNum  := ''
	       cCupom := "Cupom : "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
	       cErro := "TES não cadastrada: "+aTES[nZ]
	       MsgStop(cCupom+' '+cErro)
	       GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
	   Next nZ 
	   FErase(cDir+aArquivos[i][1]) 
	   frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_REJ_"+DTOS(Date())+".PRC" )
	   Return
	EndIf	
	//Inclusão de itens
	DbSelectArea("SL2") 
 	If Valtype(oXml:_CFe:_infCFe:_det) == "A"  	
		For nX := 1 To len(oXml:_CFe:_infCFe:_det) 	
	    	//posiciona produto para pegar TES  
	    	lnAchou := .F.
			SB1->(DbSetOrder(1))
			SB1->(DbGotop()) 
			If SB1->(DbSeek(xFilial("SB1")+PADR(oXml:_CFe:_infCFe:_det[nX]:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1],'')))    
			   
		       SL2->(DbSetOrder(1))  
			   SL2->(RecLock("SL2", .T.))	
			   SL2->L2_FILIAL		:= xFilial("SL2")
			   SL2->L2_NUM			:= cNum
			   SL2->L2_PRODUTO    	:= Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_CPROD:TEXT)
			   SL2->L2_SERPDV     	:= TMPSLG->LG_SERPDV
			   SL2->L2_SITUA      	:= "RX"
			   SL2->L2_ITEM       	:= PADL(nX,2,"0")
			   SL2->L2_DESCRI     	:= Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_XPROD:TEXT)
			   SL2->L2_QUANT      	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_QCOM:TEXT))
			   SL2->L2_VRUNIT     	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VUNCOM:TEXT))
			   SL2->L2_VLRITEM    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VUNCOM:TEXT)) * VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_QCOM:TEXT)) - VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VDESC:TEXT)) 
			   SL2->L2_LOCAL      	:= "01"
			   SL2->L2_UM         	:= Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_UCOM:TEXT)
			   SL2->L2_TES        	:= If(nCalcImp == 2,"568",SB1->B1_P_CFTES) //cTesCup
			   SL2->L2_CF         	:= If(nCalcImp == 1,POSICIONE("SF4",1, xFilial("SF4") + SL2->L2_TES,"F4_CF"),Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_CFOP:TEXT))
			   SL2->L2_VENDIDO    	:= "S"
			   SL2->L2_VALDESC    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VDESC:TEXT))
			   SL2->L2_PRCTAB     	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VUNCOM:TEXT))  
			   SL2->L2_BASEICM    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_PROD:_VPROD:TEXT))
			   If nCalcImp == 2
				  If XmlChildEx(oXml:_CFe:_infCFe:_det[nX]:_IMPOSTO:_ICMS,"_ICMS00") <> NIL
				     SL2->L2_VALICM  := VAL(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT))
					 SL2->L2_SITTRIB := Iif(val(StrTran(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT),".",""))>0,"T"+StrTran(Alltrim(OXML:_CFE:_INFCFE:_DET[NX]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT),".",""),"")			      
				  EndIf	
				Else 
				  SL2->L2_VALICM  := 0
			      SL2->L2_SITTRIB := ""
				EndIf	
				SL2->L2_DOC       := Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)  
				SL2->L2_SERIE     := TMPSLG->LG_SERIE 
				SL2->L2_PDV       := TMPSLG->LG_PDV 
			    SL2->(MsUnLock())			 	
			Else
				cNum   := '' 
				cCupom := "Cupom : "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
				cErro  := "Produto não cadastrado: "+OXML:_CFE:_INFCFE:_DET:_PROD:_CPROD:TEXT  
				MsgStop(cCupom+' '+cErro)
				GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
				FErase(cDir+aArquivos[i][1]) 
				frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_REJ_"+DTOS(Date())+".PRC" )
				Return
			EndIf
			
		Next nX    
	Else
	    lnAchou := .F.
		//posiciona produto para pegar TES 
		SB1->(DbSetOrder(1))
		SB1->(DbGotop())
		
		If SB1->(DbSeek(xFilial("SB1")+PADR(oXml:_CFe:_infCFe:_det:_PROD:_CPROD:TEXT,TamSX3("B1_COD")[1],'')))
		    
		    SL2->(DbSetOrder(1))  
		    SL2->(RecLock("SL2", .T.))	
			SL2->L2_FILIAL		:= xFilial("SL2")
			SL2->L2_NUM			:= cNum
			SL2->L2_PRODUTO    	:= Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_CPROD:TEXT)
			SL2->L2_SERPDV     	:= TMPSLG->LG_SERPDV
			SL2->L2_SITUA      	:= "RX"
			SL2->L2_ITEM       	:= PADL(nX,2,"0")
			SL2->L2_DESCRI     	:= Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_XPROD:TEXT)
			SL2->L2_QUANT      	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_QCOM:TEXT))
			SL2->L2_VRUNIT     	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VUNCOM:TEXT))
			SL2->L2_VLRITEM    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VUNCOM:TEXT)) * VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_QCOM:TEXT)) - VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VDESC:TEXT)) 
			SL2->L2_LOCAL      	:= "01"
			SL2->L2_UM         	:= Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_UCOM:TEXT)
			SL2->L2_TES        	:= If(nCalcImp == 2,"568",SB1->B1_P_CFTES) //cTesCup
			SL2->L2_CF         	:= If(nCalcImp == 1,POSICIONE("SF4", 1, xFilial("SF4") + SL2->L2_TES,"F4_CF"),Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_CFOP:TEXT) )
			SL2->L2_VENDIDO    	:= "S"
			SL2->L2_VALDESC    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VDESC:TEXT))
			SL2->L2_PRCTAB     	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VUNCOM:TEXT)) 
	     	SL2->L2_BASEICM    	:= VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_PROD:_VPROD:TEXT))
			If nCalcImp = 2	 //OPCAO XML		
			   If XmlChildEx(oXml:_CFe:_infCFe:_det:_IMPOSTO:_ICMS,"_ICMS00") <> NIL                   
				  SL2->L2_VALICM  := VAL(Alltrim(OXML:_CFE:_INFCFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT))
				  SL2->L2_SITTRIB := Iif(val(StrTran(Alltrim(OXML:_CFE:_INFCFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT),".",""))>0,"T"+StrTran(Alltrim(OXML:_CFE:_INFCFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT),".",""),"")			     		   
			   EndIf               	   	   
			Else 
	           SL2->L2_VALICM  := 0
			   SL2->L2_SITTRIB := ""
			EndIf
						
			SL2->L2_DOC        	:= Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)  
			SL2->L2_SERIE      	:= TMPSLG->LG_SERIE 
			SL2->L2_PDV        	:= TMPSLG->LG_PDV 
		    SL2->(MsUnLock())
		Else 
			//optou por não incluir e não existe
			cNum   := '' 
			cCupom := "Cupom : "+Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)
			cErro  := "Produto não cadastrado: "+OXML:_CFE:_INFCFE:_DET:_PROD:_CPROD:TEXT  
			MsgStop(cCupom+' '+cErro)
			GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
			FErase(cDir+aArquivos[i][1]) 
			frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_REJ_"+DTOS(Date())+".PRC" )
			Return		    
		EndIf
		
    EndIf 
    
    //If lnAchou 
    //   MsgStop(cNum)
    //   Loop
    //EndIf

	//Inclusão forma de pagamento
	DbSelectArea("SL4")
	SL4->(DbSetOrder(1))  
	SL4->(RecLock("SL4", .T.))	
	SL4->L4_FILIAL 	 := xFilial("SL4")
	SL4->L4_NUM      := cNum
	SL4->L4_SERPDV   := TMPSLG->LG_SERPDV 
	SL4->L4_DATA     := STOD(Alltrim(oXml:_CFE:_INFCFE:_IDE:_DEMI:TEXT))
	SL4->L4_SITUA    := "RX"
	SL4->L4_VALOR    := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_VCFE:TEXT))
	SL4->L4_FORMA    := "CC"
	SL4->L4_ADMINIS  := "002 - CREDITO"
	SL4->L4_CGC      := cCGC
	SL4->(MsUnLock())
	    
	//Inclui a capa por ultimo
	SL1->(RecLock("SL1", .T.))	
	SL1->L1_FILIAL	:= xFilial("SL1")	 
	SL1->L1_NUM     := cNum
	SL1->L1_CLIENTE := SA1->A1_COD
	SL1->L1_LOJA    := SA1->A1_LOJA 
	SL1->L1_CGCCLI  := SA1->A1_CGC 
	SL1->L1_EMISSAO := STOD(Alltrim(oXml:_CFE:_INFCFE:_IDE:_DEMI:TEXT)) 
	SL1->L1_DTLIM   := STOD(Alltrim(oXml:_CFE:_INFCFE:_IDE:_DEMI:TEXT)) 
	SL1->L1_ENTRADA := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)) 
	SL1->L1_SITUA   := "RX" 
	SL1->L1_VALMERC := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_ICMSTOT:_VPROD:TEXT))  
	SL1->L1_VALBRUT := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)) 
	SL1->L1_VLRTOT  := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_VCFE:TEXT))   
	SL1->L1_VLRLIQ  := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_VCFE:TEXT))
	SL1->L1_TIPO    := "V" 
	SL1->L1_TIPOCLI := SA1->A1_TIPO
	SL1->L1_CONDPG  := "001" 
	SL1->L1_IMPRIME := "1S" 
	SL1->L1_ESTACAO := Alltrim(oXml:_CFE:_INFCFE:_IDE:_NUMEROCAIXA:TEXT)   
	SL1->L1_VEND    := cVend 
	SL1->L1_DOC     := Alltrim(oXml:_CFE:_INFCFE:_IDE:_NCFE:TEXT)  
	SL1->L1_EMISNF  := STOD(Alltrim(oXml:_CFE:_INFCFE:_IDE:_DEMI:TEXT))
	SL1->L1_DESCONT := VAL(Alltrim(oXml:_CFE:_INFCFE:_TOTAL:_ICMSTOT:_VDESC:TEXT))
	SL1->L1_PDV     := TMPSLG->LG_PDV
	SL1->L1_SERIE   := TMPSLG->LG_SERIE 
	SL1->L1_SERPDV  := TMPSLG->LG_SERPDV 
	SL1->L1_SERSAT  := TMPSLG->LG_SERSAT
	SL1->L1_ESTACAO := TMPSLG->LG_CODIGO
	SL1->L1_KEYNFCE := SubStr(Alltrim(oXml:_CFE:_INFCFE:_ID:TEXT),4)
	SL1->L1_TPORC	:= "E" 
	SL1->L1_ESPECIE	:= "SATCE" 
	SL1->(MsUnLock())
	
	//GRAVAR O LOG            
	cErro	:= "Cupom gravado com sucesso."
	GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
	//Após terminar o processamento do arquivo, deleta do servidor
	FErase(cDir+aArquivos[i][1])
	nStatus1 := frename(cArqAtu , SUBSTR(cArqAtu,1,LEN(cArqAtu)-4)+"_INT_"+DTOS(Date())+".PRC" )
	IF nStatus1 == -1
	   MsgStop('Falha na operação 1 : Error '+str(ferror(),4))
	Endif
	SA1->(DbCloseArea())
	SB1->(DbCloseArea())
	SA3->(DbCloseArea())
	SL1->(DbCloseArea())
	SL2->(DbCloseArea())
	SL4->(DbCloseArea())
	   
	If ( cFilAnt <> cFilBak )
		cFilAnt	:= cFilBak
	EndIf	
	
Next i

Return lRet 

/*
Funcao      : GravLog 
Parametros  : cAlias,cChave,lInclui,cContInt,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX1 arquivo de log
*/
*--------------------------------------------------------------------*
 Static Function GravLog(cIDCF,cSerSat,cCFE,cNum,cDTEmi,cEmiCGC,cErro)
*--------------------------------------------------------------------*
Local cIncAlt	:= ""

//Cria Tabela de Log caso não exista
ChkFile("ZX1")

DbSelectArea("ZX1")
RecLock("ZX1",.T.)
	ZX1->ZX1_FILIAL		:= xFilial("ZX1")
	ZX1->ZX1_CFEID      := cIDCF
	ZX1->ZX1_SERSAT     := cSerSat
	ZX1->ZX1_NCFE       := cCFE
	ZX1->ZX1_NUMSL1     := cNum
	ZX1->ZX1_DTEMI      := StoD(cDTEmi)
	ZX1->ZX1_CGCEMI     := cEmiCGC
	ZX1->ZX1_DATA		:= Date()
	ZX1->ZX1_HORA		:= Time()  
	ZX1->ZX1_ERRO       := cErro
ZX1->(MsUnlock())

Return .T.

/*Cadastro de cliente*/                
*---------------------------------------------*
Static Function CadClient(oXml,cNatur,cCCClie)
*---------------------------------------------*
Local cRet		:= .F.
Local cLogErro	:= ""
Local cEst		:= ""
Local cCodMun	:= ""

Local aCliente	:= {}

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
Private lMsHelpAuto	   := .T. 

dbSelectArea("SA1")
SA1->(dbSetOrder(3))
                                                                                                                               
dbSelectArea("CC2")
CC2->(dbSetOrder(2))

If CC2->(DbSeek(xFilial("CC2")+PADR(alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_XMUN:TEXT),TamSX3("CC2_MUN")[1],'')))           
	cEst	:= CC2->CC2_EST
	cCodMun	:= CC2->CC2_CODMUN
EndIf    

If XmlChildEx(oXml:_CFE:_INFCFE:_DEST,"_CPF") <> NIL
	cCGC	:=	Alltrim(oXml:_CFE:_INFCFE:_DEST:_CPF:TEXT)
Else
	cCGC	:=	Alltrim(oXml:_CFE:_INFCFE:_DEST:_CNPJ:TEXT)
EndIf 

CC2->(DbCloseArea())   

aadd(aCliente,{"A1_COD"		,GETSXENUM("SA1", "A1_COD")				    	  			  														,NIL}) 
aadd(aCliente,{"A1_LOJA"	,"01"									    	  			  														,NIL}) 
aadd(aCliente,{"A1_CGC"		,cCGC									    	  			  														,NIL}) 
aadd(aCliente,{"A1_NATUREZ"	,cNatur                                              							  									,NIL})
aadd(aCliente,{"A1_CONTA"	,cCCClie                                        					  												,NIL})
aadd(aCliente,{"A1_CODPAIS"	,"01058"                                             					  								 			,NIL})
aadd(aCliente,{"A1_TIPO"	,"F"																	  											,NIL}) 
aadd(aCliente,{"A1_CONTRIB" ,"2"																	  					  			  			,NIL})
aadd(aCliente,{"A1_PESSOA"	,Iif(Len(alltrim(cCGC))=11,"F","J")  														  						,NIL})
aadd(aCliente,{"A1_NOME"	,alltrim(oXml:_CFE:_INFCFE:_DEST:_XNOME:TEXT)   							  					  					,NIL})
aadd(aCliente,{"A1_NREDUZ"	,alltrim(oXml:_CFE:_INFCFE:_DEST:_XNOME:TEXT)  							  					  					  	,NIL})
aadd(aCliente,{"A1_END"		,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_XLGR:TEXT)+", "+alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_NRO:TEXT)	,NIL})  				
aadd(aCliente,{"A1_EST"		,alltrim(cEst)            							  					  				  							,NIL})
aadd(aCliente,{"A1_COD_MUN"	,alltrim(cCodMun)  							  					  				 									,NIL})
aadd(aCliente,{"A1_BAIRRO"	,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)      				  			  					  	,NIL}) 
aadd(aCliente,{"A1_CEP"		,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_CEP:TEXT) 										  					    ,NIL})
aadd(aCliente,{"A1_ENDCOB"	,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_XLGR:TEXT)+", "+alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_NRO:TEXT)	,NIL}) 
aadd(aCliente,{"A1_ESTC"	,alltrim(cEst)        																								,NIL}) 
aadd(aCliente,{"A1_MUNC"	,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_XMUN:TEXT)					  					  					  	,NIL})
aadd(aCliente,{"A1_CEPC"	,alltrim(oXml:_CFE:_INFCFE:_EMIT:_ENDEREMIT:_CEP:TEXT)							  					  			  	,NIL})

//Execauto
MSExecAuto({|x,y| Mata030(x,y)},aCliente,3) //3=Inclusão

IF lMsErroAuto
	cLogErro  := MostraErro()
	RollBackSX8()                                
	cRet 	:= .T.
	Conout("Houve um problema na Inclusão do cadastro do cliente: "+cLogErro)
Else
	ConfirmSX8()
EndIf

lMsErroAuto    := .F. 
lAutoErrNoFile := .F.
lMsHelpAuto	   := .T.

Return cRet
 
 /*
Funcao      : SatCanc 
Parametros  : cIDCanc,cNFCanc
Retorno     : lRet
Objetivos   : Cancela cupom fiscal SAT
*/
*----------------------------------------*
 Static Function SatCanc(cIDCanc,cNFCanc)
*----------------------------------------*
Local cQry	:= ""
Local lRet	:= .T. 
            
If Select("TMPF2")>0
	("TMPF2")->(DbCloseArea())
EndIf

cQry	:= "SELECT F2_FILIAL,F2_CHVNFE,F2_PDV,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA FROM "+RetSqlName("SF2") "
cQry	+= " WHERE D_E_L_E_T_ <> '*' AND F2_CHVNFE = '"+SubStr(Alltrim(cIDCanc),4)+"'"

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "TMPF2", .F., .T.)

Count to nTotArq

If !nTotArq > 0
	//Não foi localizado documeto para cancelamento.
	MsgStop( "Não foi localizado documeto para cancelamento.")
	lRet	:= .F.
	Return  
EndIf              
      
TMPF2->(DbGotop())


//UPDATE SL1, MANTEM SL2 E SL4
cQry	:= "UPDATE "+RetSqlName("SL1")+" SET L1_SITUA = 'C', L1_STORC = 'C' "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND L1_FILIAL = '"+xFilial("SL1")+"' AND L1_KEYNFCE = '"+SubStr(Alltrim(cIDCanc),4)+"'"
TCSQLExec(cQry)

//SF2 E SD2 FICA DELETADO
cQry	:= "UPDATE "+RetSqlName("SF2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_CHVNFE = '"+SubStr(Alltrim(cIDCanc),4)+"'"
TCSQLExec(cQry)

cQry	:= "UPDATE "+RetSqlName("SD2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_DOC='"+TMPF2->F2_DOC+"' AND D2_SERIE='"+TMPF2->F2_SERIE+"' "
cQry	+= "AND D2_PDV='"+TMPF2->F2_PDV+"' "
TCSQLExec(cQry)

//SE1 E SE5(CASO TENHA) FICA DELETADO
cQry	:= "UPDATE "+RetSqlName("SE1")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND E1_FILORIG = '"+TMPF2->F2_FILIAL+"' AND E1_NUMNOTA='"+TMPF2->F2_DOC+"' AND E1_PREFIXO='"+TMPF2->F2_SERIE+"' "
cQry	+= "E1_ORIGEM='LOJA010' "
TCSQLExec(cQry)
 
cQry	:= "UPDATE "+RetSqlName("SE5")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND E5_FILORIG = '"+TMPF2->F2_FILIAL+"' AND E5_NUMERO='"+TMPF2->F2_DOC+"' AND E5_PREFIXO='"+TMPF2->F2_SERIE+"' "
TCSQLExec(cQry) 

//UPDATE SF3 E SFT
cQry	:= "UPDATE "+RetSqlName("SF3")+" SET F3_NFISCAN = '"+cNFCanc+"',F3_DTCANC='"+DTOS(ddatabase)+"', F3_OBSERV='CF-e-SAT cancelado' "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND F3_FILIAL = '"+xFilial("SF3")+"' AND F3_CHVNFE = '"+SubStr(Alltrim(cIDCanc),4)+"'"
TCSQLExec(cQry) 

cQry	:= "UPDATE "+RetSqlName("SFT")+" SET FT_NFISCAN = '"+cNFCanc+"',FT_DTCANC='"+DTOS(ddatabase)+"', FT_OBSERV='CF-e-SAT cancelado' "
cQry	+= "WHERE D_E_L_E_T_ <> '*' AND FT_FILIAL = '"+xFilial("SFT")+"' AND FT_CHVNFE = '"+SubStr(Alltrim(cIDCanc),4)+"'"
TCSQLExec(cQry) 

Return lRet

/*
Funcao      : ProcCupom
Objetivos   : função respontavel por Iniciar os Jobs de processamentos para as Filiais que possuem L1_SITUA = RX 
*/
*--------------------------*
Static Function ProcCupom()
*--------------------------*
Local cQryJOB := ""

cQryJOB += "Select L1_FILIAL"
cQryJOB += " From "+RetSQLName("SL1")
cQryJOB += " Where D_E_L_E_T_ <> '*'
cQryJOB += "		AND L1_SITUA = 'RX'
cQryJOB += " Group By L1_FILIAL

If Select("JOB") > 0
	JOB->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryJOB),"JOB",.F.,.T.)

JOB->(DbGoTop())
While JOB->(!EOF())
	StartJob("LJGRVBATCH()",GetEnvServer(),.F.,cEmpAnt,JOB->L1_FILIAL)//Não aguarda o Final
	JOB->(DbSkip())
EndDo

Return .T.

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Anderson Arrais
Data    : 23/10/2017
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {{"01","Diretorio do Arquivo?"},;
								  {"02","Natureza Clie.?"      },;
								  {"03","C. Contabil Clie.?"   },;
								  {"04","C. Contabil Prod.?"   },;
								  {"05","Valores"              }}
								 
  					  
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio dos arquivos de origem ")
	Aadd( aHlpPor,"Para ser integrado.")
	
	U_PutSx1(cPerg,"01","Diretorio do Arquivo?","Diretorio do Arquivo ?","Diretorio do Arquivo ?","mv_ch1","C",60,0,0,"G","","","","S","mv_par01","","","","C:\","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
		
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a natureza desejada para")
	Aadd( aHlpPor, "o cadastro dos clientes.")      
	
	U_PUTSX1(cPerg,"02","Natureza Clie.?","Natureza Clie.?","Natureza Clie.?","mv_ch2","C",10,0,0,"G","","SED","","S","mv_par02","","","","1001","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a conta contabil desejada para")
	Aadd( aHlpPor, "o cadastro dos clientes.")      
	
	U_PUTSX1(cPerg,"03","C. Contabil Clie.?","C. Contabil Clie.?","C. Contabil Clie.?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","11211001","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a conta contabil desejada para")
	Aadd( aHlpPor, "o cadastro de produto.")      
	
	U_PUTSX1(cPerg,"04","C. Contabil Prod.?","C. Contabil Prod.?","C. Contabil Prod.?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","11211001","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	/*
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a TES para classificar")
	Aadd( aHlpPor, "o cupom fiscal.")      
	
	U_PUTSX1(cPerg,"05","TES Cupom Prod.?","TES Cupom Prod.?","TES Cupom Prod.?","mv_ch5","C",03,0,0,"G","","SF4","","S","mv_par05","","","","1NQ","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Inclui produto caso não exista?")
	Aadd( aHlpPor, "")      
	
	U_PUTSX1(cPerg,"06","Inclui Prod.?","Inclui Prod.?","Inclui Prod.?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
    */
	aHlpPor := {}
	Aadd( aHlpPor, "Selecione que valor considerar na integração")
	Aadd( aHlpPor, "do cupom fiscal.")      

    U_PUTSX1(cPerg,"05","Valores ","Valores ","Valores ","mv_ch5","N",01,0,1,"C","","","","","mv_par05","TES","TES","TES","","XML","XML","XML","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
			
EndIf
	
Return Nil



*--------------------------*
Static Function ProxCupom()
*--------------------------*
Local cQryCxp := ""

cQryCxp += "Select MAX(L1_NUM) AS MAIOR"
cQryCxp += " From "+RetSQLName("SL1")
cQryCxp += " Where D_E_L_E_T_ <> '*'

If Select("QRY") > 0
   QRY->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryCxp),"QRY",.F.,.T.) 

Return Strzero(Val(MAIOR)+1,6)
