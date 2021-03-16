#INCLUDE 'HBUTTON.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
//#INCLUDE 'TRYEXCEPTION.CH'   
 
#DEFINE ENTER CHR(13) + CHR(10)

STATIC CCADASTRO := "Monitor arquivos processados"

/*
===============================================================================================
===============================================================================================
||   Arquivo:	MONITIMP.prw
===============================================================================================
||   Funcao: 	MONITIMP
===============================================================================================
||		Monitor XML onde será apresentado os LOGs dos processamentos.
||                                                                                                                   	
===============================================================================================
===============================================================================================
||   Autor:	Edson Hornberger
||   Manut: Sandro Silva/Marcio Martins Pereira
||   Data:	13/12/2017
===============================================================================================
===============================================================================================
*/
USER FUNCTION MONITIMP()

	LOCAL OEXCEPTION
	LOCAL CMSGERROR	   := ""

	PRIVATE APERG	   := {}
	PRIVATE ARESP	   := {}
	PRIVATE DDTADE	   := DDATABASE
	PRIVATE DDTATE	   := DDATABASE
	PRIVATE CARQUIV    := SPACE(200)

	PRIVATE ASIZE 	   := {}
	PRIVATE AOBJECTS   := {}
	PRIVATE AINFO 	   := {}
	PRIVATE APOSOBJ    := {}
	PRIVATE APOSGET    := {}

	PRIVATE CFILTER	   := ""
	PRIVATE CFILAUX	   := ""
	PRIVATE CDETOCOR   := ""   
	
	PRIVATE DDATALANC  := CTOD("")	 
	PRIVATE CLOTE      := ''   
	PRIVATE CSUBLOTE   := ''   
	PRIVATE CDOC       := ''
	PRIVATE CCADASTRO  := ''        
	PRIVATE cArquivo   := ''
                                            
    PRIVATE cIntInvoic := GetNewPar('EZ_INTINV','')  //Usuario(s) autorizado(s) a acesar a opcao Integração de Notas  
    PRIVATE cEnvInvRej := GetNewPar('EZ_OUTIREJ','')  //Usuario(s) autorizado(s) a acesar a opcao Envio de Rejeição de Notas      
    PRIVATE cEnvTaxLin := GetNewPar('EZ_OUTTAX','')  //Usuario(s) autorizado(s) a acesar a opcao Envio de Tax line
 
    PRIVATE cIntJourna := GetNewPar('EZ_INTJOUR','') //Usuario(s) autorizado(s) a acesar a opcao Integração de Journal 
    PRIVATE cEnvJouRej := GetNewPar('EZ_OUTJREJ','') //Usuario(s) autorizado(s) a acesar a opcao Envio de Rejeição de Journal   
	/*
	|---------------------------------------------------------------------------------
	|	Tela de parâmetros para Iniciar a Tela do Monitor
	|---------------------------------------------------------------------------------
	*/
	AADD(APERG,{9,"Dados para apresentar tela do Monitor!",140,20,.T.})
	AADD(APERG,{1,"Data Ocorrência de: "	,DDTADE	,"@D"	,"DATAVALIDA(MV_PAR02)",,".T.",050,.T.})
	AADD(APERG,{1,"Data Ocorrência até: "	,DDTATE	,"@D"	,"DATAVALIDA(MV_PAR03)",,".T.",050,.T.}) 

	IF !PARAMBOX(APERG,CCADASTRO,@ARESP,,,.T.,,,,,.T.,.T.)

		AVISO(CCADASTRO,"Operação Cancelada pelo Usuário!",{"Ok"},2,"ATENÇÃO")
		RETURN

	ENDIF

	CFILTER := "DTOS(Z0G_DATA) >= '" + DTOS(ARESP[02]) + "' .AND. DTOS(Z0G_DATA) <= '" + DTOS(ARESP[03]) + "'"
	CFILAUX	:= CFILTER
	FWMSGRUN(,{|| MONTAMONIT()},CCADASTRO,"Buscando dados para apresentação...")


RETURN

/*
===============================================================================================
===============================================================================================
||   Arquivo:	MONITIMP.prw
===============================================================================================
||   Funcao: 	MONTAMONIT
===============================================================================================
||		Tela do Monitor.admin	
||
===============================================================================================
===============================================================================================
||   Autor:	Edson Hornberger  
||   Manut: Sandro Silva/Marcio Martins Pereira
||   Data:	13/12/2017
===============================================================================================
===============================================================================================
*/

STATIC FUNCTION MONTAMONIT()

	//LOCAL OEXCEPTION
	//LOCAL CMSGERROR	:= ""
	LOCAL NI		:= 0
	LOCAL ACAMPOS	:= {}
	LOCAL AFILTER	:= {}   
			
	PRIVATE cNome     := cUserName 
    PRIVATE cUserID   :=__cUserID 
    
	PRIVATE OFWLAYER
	PRIVATE OWIN1
	PRIVATE OWIN2
	PRIVATE OWIN3
	PRIVATE OWIN4

	PRIVATE OBTN1								// Executar a integração
	PRIVATE OBTN2								// Botão para Visualizar Pedido Gerado
	PRIVATE OBTN3								// Botão para Filtrar Tela
	PRIVATE OBTN4								// Botão para Limpar Filtro
	PRIVATE OBTN5								// Botão para Fechar a Tela
 	PRIVATE OBTN7								// Botão para Enviar as taxas aprovadas para o SFTP Temasek
		
	PRIVATE OBTN25								// Botão para Visualizar o XML
	PRIVATE OBTN27								// Botão para Visualizar o LOG da execAuto
	PRIVATE OMEMO								// Campo onde será apresentado o Detalhe da Ocorrencia

	PRIVATE OCOLUMN
	PRIVATE OBRWXML

	PRIVATE OFONTLEG	:= TFONT():NEW("VERDANA",,014,,.F.,,,,,.F.,.F.)

	ASIZE	:= MSADVSIZE( .F. )
	AINFO 	:= { ASIZE[ 1 ], ASIZE[ 2 ], ASIZE[ 3 ], ASIZE[ 4 ], 3, 3 }

	AADD( AOBJECTS, { 100	, 050	, .T., .F. })
	AADD( AOBJECTS, { 100	, 100	, .T., .T. })

	APOSOBJ	:= MSOBJSIZE(AINFO,AOBJECTS)
	APOSGET	:= MSOBJGETPOS((ASIZE[3]-ASIZE[1]),315,{{004,024,240,270}} )

	DEFINE MSDIALOG ODLG TITLE CCADASTRO FROM ASIZE[7],ASIZE[1] TO ASIZE[6],ASIZE[5] OF OMAINWND STYLE NOR( WS_VISIBLE,WS_POPUP ) PIXEL

	ODLG:LESCCLOSE := .F.

	OFWLAYER := FWLAYER():NEW()
	OFWLAYER:INIT(ODLG,.F.)

	OFWLAYER:ADDCOLLUMN("COL01",10,.T.)
	OFWLAYER:ADDCOLLUMN("COL02",90,.T.)

	OFWLAYER:ADDWINDOW("COL01","WIN01"	,"Ações"					,070,.F.,.F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)
	OFWLAYER:ADDWINDOW("COL01","WIN02"	,"Legendas"					,030,.F.,.F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)
	OFWLAYER:ADDWINDOW("COL02","WIN03"	,CCADASTRO					,080,.T.,.F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)
	OFWLAYER:ADDWINDOW("COL02","WIN04"	,"Detalhe da Ocorrência"	,020,.T.,.F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)

	OWIN1 := OFWLAYER:GETWINPANEL('COL01','WIN01')
	OWIN2 := OFWLAYER:GETWINPANEL('COL01','WIN02')
	OWIN3 := OFWLAYER:GETWINPANEL('COL02','WIN03')
	OWIN4 := OFWLAYER:GETWINPANEL('COL02','WIN04')

	//Browse
	DEFINE FWBROWSE OBRWXML DATA TABLE ALIAS "Z0G" OF OWIN3

	//Adiciona Legenda no Browse
	ADD LEGEND DATA 'Z0G_STATUS == "0"'		COLOR "BR_VERMELHO"	OF OBRWXML
	ADD LEGEND DATA 'Z0G_STATUS == "1"'		COLOR "BR_AZUL"  	OF OBRWXML
	ADD LEGEND DATA 'Z0G_STATUS == "3"'		COLOR "BR_AMARELO"	OF OBRWXML
    ADD LEGEND DATA 'Z0G_STATUS == "4"'		COLOR "BR_CINZA"	OF OBRWXML

	//Colunas
	ADD COLUMN OCOLUMN DATA { || Z0G_DATA  			}	TITLE "Data"     		SIZE  07 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_HORA  			}	TITLE "Hora"  			SIZE  05 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_ARQUIV  		}	TITLE "Arquivo CSV"    	SIZE  20 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_TABELA  		}	TITLE "Tabela"	    	SIZE  03 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_CHAVE  		}	TITLE "Chave"    		SIZE  15 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_PROCES	    	}	TITLE "Processo" 		SIZE  10 OF OBRWXML	
	ADD COLUMN OCOLUMN DATA { || Z0G_USER  			}	TITLE "Usuário"    		SIZE  10 OF OBRWXML
	ADD COLUMN OCOLUMN DATA { || Z0G_MENSAG  		}	TITLE "Mensagem"   		SIZE  40 OF OBRWXML

	//Filtro inicial
	OBRWXML:SETFILTERDEFAULT( CFILTER )
	OBRWXML:BONMOVE := {|OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW| CLICKBRW(OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW,OBRWXML)}

	ACAMPOS := Z0G->(DBSTRUCT())

	FOR NI := 1 TO LEN(ACAMPOS)

		AADD(AFILTER, {ACAMPOS[NI,1], POSICIONE("SX3",2,ACAMPOS[NI,1],"X3_TITULO"), ACAMPOS[NI,2], ACAMPOS[NI,3], ACAMPOS[NI,4], POSICIONE("SX3",2,ACAMPOS[NI,1],"X3_PICTURE")})

	NEXT NI

	OBRWXML:SETFIELDFILTER(AFILTER)

	//Ativa o Browse
	ACTIVATE FWBROWSE OBRWXML

	@ 000, 000 GET OMEMO VAR CDETOCOR MEMO SIZE OWIN4:NWIDTH - 15, OWIN4:NHEIGHT - 60 PIXEL OF OWIN4 COLORS 0, 16777215 FONT OFONTLEG READONLY
	OMEMO:ALIGN 	:= CONTROL_ALIGN_ALLCLIENT
	OMEMO:CREADVAR 	:= "CDETOCOR"             
  		                                                	
    If cUserID $ cIntInvoic
  	   @ 000, 000 BTNBMP OBTN1 	RESNAME "ENGRENAGEM" 	SIZE 010, 050 OF OWIN1 MESSAGE "Executa integração" 	 ACTION( U_Q6EST001(), Z0G->(DBGOBOTTOM()) , OBRWXML:REFRESH(.T.) )
	   OBTN1:CCAPTION	:= "Importa Notas         "
       OBTN1:ALIGN		:= CONTROL_ALIGN_TOP  
	EndIf	

    If cUserID $ cIntJourna
		@ 000, 000 BTNBMP OBTN2 RESNAME "ENGRENAGEM" 	SIZE 010, 050 OF OWIN1 MESSAGE "Executa integração"	     ACTION( U_EZCAPTURE() , Z0G->(DBGOBOTTOM()) , OBRWXML:REFRESH(.T.) )
		OBTN2:CCAPTION	:= "Importa Contábil      "
		OBTN2:ALIGN		:= CONTROL_ALIGN_TOP
	EndIf
	
	@ 000, 000 BTNBMP OBTN3 	RESNAME "LUPA " 	    SIZE 010, 050 OF OWIN1 MESSAGE "Consulta Documento"      ACTION( LTCONTABIL() ) 
	OBTN3:CCAPTION	:= "Consulta/Visualiza   "
	OBTN3:ALIGN		:= CONTROL_ALIGN_TOP

	@ 000, 000 BTNBMP OBTN4 	RESNAME "BMPTRG" 	    SIZE 010, 050 OF OWIN1 MESSAGE "Filtrar LOG"	         ACTION( FILEXP() )
	OBTN4:CCAPTION	:= "Filtrar               "
	OBTN4:ALIGN	:= CONTROL_ALIGN_TOP

	@ 000, 000 BTNBMP OBTN5 	RESNAME "TK_REFRESH"    SIZE 010, 050 OF OWIN1 MESSAGE "Refresh"		         ACTION( Z0G->(DBGOTOP()), OBRWXML:REFRESH(.T.) )
	OBTN5:CCAPTION	:= "Refresh               "
	OBTN5:ALIGN		:= CONTROL_ALIGN_TOP
    
    If cUserID $ cEnvTaxLin
	    @ 000, 000 BTNBMP OBTN7 	RESNAME "RECALC"	SIZE 010, 050 OF OWIN1 MESSAGE "Enviar Tx.Line"          ACTION(EnviaSFTP(),Z0G->(DBGOBOTTOM()) , OBRWXML:REFRESH(.T.) )
		OBTN7:CCAPTION	:= "Enviar Tax Line      "
		OBTN7:ALIGN		:= CONTROL_ALIGN_TOP   
	EndIf	
    
    If cUserID $ cEnvJouRej
	    @ 000, 000 BTNBMP OBTN25 	RESNAME "DESTINOS"  SIZE 010, 050 OF OWIN1 MESSAGE "Enviar Rejeicao Journal" ACTION(LgJournal(),Z0G->(DBGOBOTTOM()) , OBRWXML:REFRESH(.T.) )
		OBTN25:CCAPTION	:= "Rej.Journal           "
		OBTN25:ALIGN	:= CONTROL_ALIGN_TOP
	EndIf	                                       
    
    If cUserID $ cEnvInvRej
	    @ 000, 000 BTNBMP OBTN8 	RESNAME "S4WB014B"  SIZE 010, 050 OF OWIN1 MESSAGE "Enviar Rejeicao Invoice" ACTION(LgInvoice(),Z0G->(DBGOBOTTOM()) , OBRWXML:REFRESH(.T.) )
		OBTN8:CCAPTION	:= "Rej.Invoice           "
		OBTN8:ALIGN		:= CONTROL_ALIGN_TOP  
	EndIf
	
	@ 000, 000 BTNBMP OBTN6 	RESNAME "FINAL"  	    SIZE 010, 050 OF OWIN1 MESSAGE "Sair"			         ACTION( ODLG:END() )
	OBTN6:CCAPTION	:= "Sair                  "
	OBTN6:ALIGN		:= CONTROL_ALIGN_TOP
    
	//Legendas/Imagens
	@ 010,005 BITMAP OBMP RESNAME "BR_VERMELHO" SIZE 16,16 NOBORDER OF OWIN2 PIXEL  
	@ 030,005 BITMAP OBMP RESNAME "BR_AZUL"		SIZE 16,16 NOBORDER OF OWIN2 PIXEL
	@ 050,005 BITMAP OBMP RESNAME "BR_AMARELO"	SIZE 16,16 NOBORDER OF OWIN2 PIXEL    
	@ 070,005 BITMAP OBMP RESNAME "BR_CINZA"    SIZE 16,16 NOBORDER OF OWIN2 PIXEL   
    
	//Descricao
	@ 010,015 SAY "Rejeitado"   OF OWIN2 PIXEL FONT OFONTLEG
	@ 030,015 SAY "Sucesso"     OF OWIN2 PIXEL FONT OFONTLEG
	@ 050,015 SAY "Atenção"	    OF OWIN2 PIXEL FONT OFONTLEG
   	@ 070,015 SAY "Aguardando"  OF OWIN2 PIXEL FONT OFONTLEG   

	EVAL({|OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW| CLICKBRW(OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW,OBRWXML)})

	ACTIVATE MSDIALOG oDlg CENTERED

RETURN

/*
===============================================================================================
===============================================================================================
||   Arquivo:	MONITIMP.prw
===============================================================================================
||   Funcao: 	VERDOCTO
===============================================================================================
||		Visualização de Pedido de Venda (Padrão do Sistema)
||
===============================================================================================
===============================================================================================
||   Autor:	Marcio Martins Pereira 
||   Manut: Sandro Silva
||   Data:	19/07/2019
===============================================================================================
===============================================================================================
*/
STATIC FUNCTION LTCONTABIL()  
      
   	Local OEXCEPTION     
   	Local AAREAAT	   := GETAREA()
    Local CMSGERROR	   := ""
	Local CCHAVE	   := ""  
	Private AROTINA    := {} 		

	If Z0G->Z0G_STATUS = "3" .Or. Z0G->Z0G_STATUS = "0"
       MsgInfo("Consulta válida somente para documento com Status 'Sucesso ou Aguardando Aprovação' ")   
       Return
    EndIf
	
	IF Z0G->Z0G_TABELA $ "SF1/SFT" .AND. Z0G->Z0G_STATUS $ "1/4"    

		AROTINA 	:= {	{"PESQUISAR" , "AXPESQUI" , 0, 1},;
							{"VISUALIZAR", "AXVISUAL" , 0, 2}}
	
        cCNPJ := SUBSTRING(Z0G_CHAVE,13,14)
	    CCHAVE := SUBSTR(Z0G->Z0G_CHAVE,1,TAMSX3("F1_DOC")[1]+TAMSX3("F1_SERIE")[1])
		DbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		If SA2->(dbSeek(xFilial('SA2')+cCNPJ))
	       cCodLoja := SA2->(A2_COD+A2_LOJA)
		EndIf		
		L103AUTO := .F.
		DBSELECTAREA("SF1")
		SF1->(DBSETORDER(1))
		IF SF1->(DBSEEK(XFILIAL("SF1") + CCHAVE+cCodLoja))		
			SF1->(A103NFiscal("SF1", SF1->(RECNO()) ,2, {}))				
		ENDIF	
		
	ELSEIF Z0G->Z0G_TABELA == "CT2" .AND. Z0G->Z0G_STATUS == "1" 
	
		AROTINA 	:= {	{"PESQUISAR" , "AXPESQUI" , 0, 1},;
							{"VISUALIZAR", "AXVISUAL" , 0, 2}}
	
		DDATALANC := CTOD("")	 
		CLOTE     := ''   
		CSUBLOTE  := ''   
		CDOC      := ''
		CCADASTRO := ''
		
		CCHAVE    := ALLTRIM(Z0G->Z0G_CHAVE)    //SUBSTR(Z0G->Z0G_CHAVE,TAMSX3("CT2_DATA")[1]+TAMSX3("CT2_LOTE")[1]+TAMSX3("CT2_SBLOTE")[1]+TAMSX3("CT2_DOC")[1])
				
		DBSELECTAREA("CT2")
		CT2->(DBSETORDER(1))
		IF CT2->(DBSEEK(XFILIAL("CT2") + CCHAVE ))
		
			CT2->(Ctba102Cal("CT2", CT2->(RECNO()) ,2, {}))
				
		ENDIF
	ENDIF
	
	RESTAREA(AAREAAT)

RETURN NIL

/*
===============================================================================================
===============================================================================================
||   Arquivo:	MONITIMP.prw
===============================================================================================
||   Funcao: 	FILEXP
===============================================================================================
||		Filtro dos pedidos da tela (Expressao)
||
===============================================================================================
===============================================================================================
||   Autor:	Edson Hornberger
||   Manut: Sandro Silva/Marcio Martins Pereira
||   Data:	13/12/2017
===============================================================================================
===============================================================================================
*/
STATIC FUNCTION FILEXP()

	LOCAL CFILTRATMP	:= ""
	LOCAL CFILTRO   	:= ""
	LOCAL OEXCEPTION
	LOCAL CMSGERROR		:= ""

	GPFLTBLDEXP( "Z0G" , GETWNDDEFAULT() , @CFILTRATMP , @CFILTRO )

	IF EMPTY( CFILTRATMP )
		CFILTER	:= CFILAUX
	ELSE
		CFILTER	:= STRTRAN(STRTRAN(CFILTRATMP,'"',"'"),"Z0G->","")
	ENDIF

	OBRWXML:SETFILTERDEFAULT(CFILTER)
	OBRWXML:REFRESH(.T.)

RETURN NIL

/*
===============================================================================================
===============================================================================================
||   Arquivo:	MONITIMP.prw
===============================================================================================
||   Funcao: 	CLICKBRW
===============================================================================================
||
||
||
||
||
||
===============================================================================================
===============================================================================================
||   Autor:	Edson Hornberger
||   Manut: Sandro Silva/Marcio Martins Pereira
||   Data:	13/12/2017
===============================================================================================
===============================================================================================
*/
STATIC FUNCTION CLICKBRW(OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW,OBRWXML)

	LOCAL OEXCEPTION
	LOCAL CMSGERROR	:= ""

	If ValType(NCURSORPOS) != "U" .And. ValType(NMOVETYPE) != "U"
	   OBRWXML:ONMOVE(OBRWXML:OBROWSE,NMOVETYPE,NCURSORPOS,NQTDLINHA,NVISBLEROW)
	EndIf
	
	CDETOCOR := "Detalhe do LOG: " + ALLTRIM(Z0G->Z0G_MENSAG)
	OMEMO:CMSG := CDETOCOR

	IF TYPE("OMEMO") <> "U"
		OMEMO:REFRESH()
	ENDIF


RETURN 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraIMP
Geração de CSV com os impostos

@author    
@version   
@since     25/06/2019
/*/
//------------------------------------------------------------------------------------------
Static function GeraIMP()

Local nX
Local nHandle := 0
Local cWord   := "WORKDAY_AP_INVOICES_"
Local cText   := "Microsiga_AP_Invoices_with_Tax_lines_"
Local nPsText := AT(cWord,UPPER(cArquivo))
Local cHora   := Alltrim(SubStr(cArquivo,nPsText+Len(cWord),100))	// Retorno data e hora do arquivo original 
Local cNomLog := cLocRetaTx+cText+cHora  

If File(cNomLog)    //se houver arquivo processado excluir para criar arquivo atualizado.
   fErase(cNomLog)
EndIf

nHandle := If(TMPIMP->(Reccount()) > 0,FCreate(cNomLog,,,.F.),0)

If nHandle > 0
         
   // Grava o cabecalho do arquivo
   aEval(aCposImp, {|e, nX| fWrite(nHandle, e[1] + ";" )})
   fWrite(nHandle, ENTER ) // Pula linha
      
   TMPIMP->(dbgotop())
   while TMPIMP->(!Eof())
	
	For nX := 1 to Len(aCposImp)	      
		IF aCposImp[nX][2] == "C"
		   _uValor := Alltrim(TMPIMP->&(aCposImp[nX][1]))
		ELSE
			_uValor := Alltrim(Transform(TMPIMP->&(aCposImp[nX][1]),"9999999.99"))
		ENDIF				
        
        If nX <= len(aCposImp)
        	If nX == len(aCposImp)
        		fWrite(nHandle, _uValor )
        	Else
           		fWrite(nHandle, _uValor + ";" )
         	Endif
        EndIf
	Next nX
	               
    fWrite(nHandle,ENTER )
               
    TMPIMP->(dbskip())
               
   EndDo
   
   Conout("6QEST001 -> Schedule -> Gerado Arquivo de Tax Line: "+cNomLog)  
   
EndIf          
fClose(nHandle)             

//=========================  
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnviaSFTP.
Envia o arquivo de TAX LINE para SFTP para ser integrado pela TEMASEK(Workday)
@author    
@version   
@since     07/02/2020
/*/
//-------------------------------------------------------------------------------------------------------------    
Static Function EnviaSFTP()   
Local cSQL		   := '' 
Local cSQLUpd	   := '' 
Local nTx		   := 0 
Local nW		   := 0 
Local nE           := 0 
Local nUP          := 0  
Local nM           := 0
Local aImpostos    := { "D1_VALIRR" , "FT_VRETPIS" , "FT_VRETCOF" , "FT_VRETCSL" , "D1_VALISS" , "D1_VALINS"	}
Local aDescImp     := { "IRRF" 	 , "PIS" 		, "COFINS" 		, "CSSL" 	  , "ISS" 		, "INSS"}
Local aClassVal    := { "SC1923" 	 , "SC1927"		, "SC1911" 		, "SC1914" 	  , "SC1924"	, "SC1922"}	
Local cAliasZG0    := GetNextAlias() 
Local aGeraArq     := {} 	                           
Local lImposto     := .F.
Local cAliasSFT    
Private cArquivo   := ''
Private aCposImp   := {}                       
Private cRootPath  := GetSrvProfString("RootPath", "\undefined")    //retorna o caminho do rootpath         
Private cINT084    := GetNewPar('EZ_6Q084','/pwldbms/PRD/WD/INT084/')  
Private cLocRetaTx := '\6qsimport\retornos\taxlines\'   
Private cLocLogs   := '\6qsimport\logs\'         
Private cLocLgEr   := '\6qsimport\logs\erro\' 

If Z0G->Z0G_TABELA <> "SFT" .AND. Z0G->Z0G_STATUS <> "4"  
   MsgInfo("Opção válida para Documento com Status Aguardando Aprovação'. ")   
   Return
EndIf

cArquivo := Z0G->Z0G_ARQUIV   

cSQLUpd := " SELECT SUBSTRING(Z0G_CHAVE,1,9) as NOTA,SUBSTRING(Z0G_CHAVE,10,3) as SERIE,SUBSTRING(Z0G_CHAVE,13,14) as CNPJ,Z0G_ARQUIV as ARQUIVO FROM " + RETSQLNAME("Z0G") +" WHERE D_E_L_E_T_ = '' AND Z0G_TABELA = 'SFT' AND Z0G_STATUS = '4' AND Z0G_ARQUIV = '" +cArquivo +"'"
DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQLUpd), (cAliasZG0), .F., .T.)  
		
(cAliasZG0)->( dBgotop())
While (cAliasZG0)->(!Eof())
      AAdd(aGeraArq,{NOTA,SERIE,CNPJ,ARQUIVO})  //carrega o array com as notas e impostos por arquivo
      (cAliasZG0)->(DbSkip()) 
EndDo 				
	
CriaWork()
	
For nTx := 1 To Len(aGeraArq)
	
	cCNPJ       := aGeraArq[nTx][3]
	cDoc        := aGeraArq[nTx][1]
	cSerie      := aGeraArq[nTx][2]
	cArquivo    := aGeraArq[nTx][4]					
	cAliasSFT   := GetNextAlias()
		
	cSQL := " SELECT FT_EMISSAO, FT_NFISCAL, FT_SERIE, FT_ESPECIE, A2_CGC,A2_NREDUZ,FT_PRODUTO, B1_DESC, FT_ITEM, D1_CC, D1_CONTA, D1_ITEMCTA, D1_CLVL, " + CRLF 
	cSQL += " D1_VALIRR, FT_VRETPIS, FT_VRETCOF, FT_VRETCSL, D1_VALISS, D1_VALINS " + CRLF
	cSQL += " FROM " + RETSQLNAME("SFT") + " SFT (NOLOCK) " + CRLF
	cSQL += " INNER JOIN " + RETSQLNAME("SD1") + " SD1 (NOLOCK) ON	SD1.D1_FILIAL	= SFT.FT_FILIAL " + CRLF
	cSQL += " 								AND SD1.D1_FORNECE	= SFT.FT_CLIEFOR AND SD1.D1_LOJA	= SFT.FT_LOJA  " + CRLF
	cSQL += " 								AND SD1.D1_DOC		= SFT.FT_NFISCAL AND SD1.D1_SERIE	= SFT.FT_SERIE " + CRLF 
	cSQL += " 								AND SD1.D1_ITEM		= SFT.FT_ITEM  " + CRLF  
	cSQL += " INNER JOIN " + RETSQLNAME("SA2") + " SA2 (NOLOCK) ON " + CRLF
	cSQL += " SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA " + CRLF
	cSQL += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 (NOLOCK) ON " + CRLF
	cSQL += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SFT.FT_PRODUTO " + CRLF
	cSQL += " WHERE	SFT.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = '' AND " + CRLF
	cSQL += " SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND " + CRLF
	cSQL += " SA2.A2_CGC = '" + cCNPJ + "' AND SFT.FT_NFISCAL = '" + cDoc + "' AND SFT.FT_SERIE = '" + cSerie + "' " + CRLF
	
	DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasSFT), .F., .T.)

	While (cAliasSFT)->(!Eof())
		For nM := 1 to Len(aImpostos) 
			//If (cAliasSFT)->&(aImpostos[nM]) > 0 
				Reclock("TMPIMP",.T.)
				TMPIMP->DTEMISSAO 	:= (cAliasSFT)->FT_EMISSAO
				TMPIMP->NUMERO	 	:= (cAliasSFT)->FT_NFISCAL
				TMPIMP->SERIE		:= (cAliasSFT)->FT_SERIE
				TMPIMP->ESPECDOCU 	:= (cAliasSFT)->FT_ESPECIE
				TMPIMP->FORNECEDOR 	:= (cAliasSFT)->A2_CGC
				TMPIMP->PRODUTO 	:= (cAliasSFT)->FT_PRODUTO
				TMPIMP->LINEMEMO 	:= aDescImp[nM]+' '+(cAliasSFT)->FT_NFISCAL+' '+(cAliasSFT)->A2_NREDUZ
				TMPIMP->ITEMNF	 	:= StrZero(nM,4) 
				TMPIMP->CENTROCU 	:= (cAliasSFT)->D1_CC
				TMPIMP->ITEMCONT 	:= (cAliasSFT)->D1_ITEMCTA
				TMPIMP->CLASSEVL 	:= aClassVal[nM]
				TMPIMP->VALIRR 		:= (cAliasSFT)->&(aImpostos[nM])*-1   			  
				TMPIMP->(MsUnlock())                                  
				//lImposto := .T. 
			//Endif
		Next nM
		(cAliasSFT)->(dbSkip())
	Enddo
	
Next nTX
	
(cAliasSFT)->(dbCloseArea())

GeraIMP() // Gera arquivo de tax lines

If ExistBlock("HLBGEN01")
 
   aFileDel := {}
   aDir(cLocRetaTx+"*.csv",aFileDel,,,,,.F.)   //carrega os arquivos para serem encriptados
   For nW := 1 To Len(aFileDel)
	 Conout("6QEST001 ->Schedule -> Encriptado arquivo de taxas na pasta: "+cLocRetaTx)
 	 If nW = 1
        U_HLBGEN01("E","16B173771B75044C",cRootPath+cLocRetaTx,"*.csv")	  //Encripta o arquivo de taxas na pasta retorno	'\6QSIMPORT\RETORNOS\TAXLINES\'	
     EndIf			
     fRename(cLocRetaTx+aFileDel[nW],cLocRetaTx+Substr(aFileDel[nW],1,Rat(".csv",aFileDel[nW]))+'ecp',,.F.) //Renomear o arquivo da pasta entrada para integrado.   
     Conout("6QEST001 -> Schedule -> Renomeado Arquivos de taxas: "+aFileDel[nW]+" pasta: "+cLocRetaTx)				    
   Next nW  
        
   aFileTax := {}
   aDir(cLocRetaTx+"*.gpg",aFileTax,,,,,.F.) //carrega o arquivo criptografado da pasta upload
   cArq := ''
   For nE := 1 To Len(aFileTax)
       fRename(cLocRetaTx+aFileTax[nE],cLocRetaTx+substr(aFileTax[nE],1,rat(".gpg",aFileTax[nE]))+'pgp',,.F.)  //Renomear o arquivo .gpg para .pgp na pasta retorno
       cArq := substr(aFileTax[nE],1,rat(".gpg",aFileTax[nE]))+'pgp'  
       Conout("6QEST001 -> Schedule -> Renomeado Arquivos de Taxas "+cArq+" pasta "+cLocRetaTx+ "para Upload")     
       U_GerSFTP('PUT',cArq,cLocRetaTx,cINT084,cLocLogs,cLocLgEr)//Upload do arquivo de Taxa criptografado no SFTP.   
       Conout("6QEST001 -> Schedule -> UpLoad do Arquivo de Taxas encriptado: "+cArq+" para pasta "+cINT084+" do SFTP")	    
       fRename(cLocRetaTx+cArq,cLocRetaTx+substr(cArq,1,Rat(".pgp",cArq))+'out',,.F.) //Renomear o arquivo criptografado da pasta retorno após envio ao SFTP.
       Conout("6QEST001 -> Schedule -> Renomeado Arquivos de Taxas "+cArq+" pasta "+cLocRetaTx+ " apos Upload")	 
   Next nE
   *
   For nUP = 1 To Len(aGeraArq)	 //atualiza status das notas no monitor																
       cSQLUpd	:= "UPDATE "+RetSqlName("Z0G")+" SET Z0G_STATUS = '1',Z0G_TABELA = 'SF1',Z0G_MENSAG = 'Arquivo processado com sucesso' "			   
	   cSQLUpd	+= " WHERE Z0G_STATUS = '4' AND Z0G_TABELA = 'SFT' AND Z0G_CHAVE = '"+aGeraArq[nUP][1]+aGeraArq[nUP][2]+aGeraArq[nUP][3]+ "' AND Z0G_ARQUIV = '" + aGeraArq[nUP][4] + "' "
       TCSQLEXEC(cSQLUpd)
   Next nUP
   *    	 		
   OBRWXML:REFRESH(.T.)
           
EndIf

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaWork.
Cria tabela temporaria para a geração das retenções
@author    
@version   
@since     07/02/2020
/*/
//-------------------------------------------------------------------------------------------------------------   
Static Function CriaWork()

aCposImp   := {}

aAdd(aCposImp,{"DTEMISSAO" 	,"C",  8,0})
aAdd(aCposImp,{"NUMERO" 	,"C",  9,0})
aAdd(aCposImp,{"SERIE"		,"C",  3,0})
aAdd(aCposImp,{"ESPECDOCU" 	,"C",  5,0})   
aAdd(aCposImp,{"FORNECEDOR" ,"C", 14,0})
aAdd(aCposImp,{"PRODUTO" 	,"C", 15,0})
aAdd(aCposImp,{"LINEMEMO" 	,"C",200,0})
aAdd(aCposImp,{"ITEMNF" 	,"C",  4,0})
aAdd(aCposImp,{"CENTROCU" 	,"C",  9,0})
aAdd(aCposImp,{"ITEMCONT" 	,"C",  9,0})
aAdd(aCposImp,{"CLASSEVL" 	,"C",  9,0})
aAdd(aCposImp,{"VALIRR" 	,"N", 16,2})

If Select("TMPIMP") > 0
   TMPIMP->(DbCloseArea())
EndIf

cTMPIMP := CriaTrab(aCposImp,.T.)   
dbUseArea(.T.,,cTMPIMP,"TMPIMP",.F.,.F.)      

Return


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LgJournal.
Encripta o error log da Invoice e envia para SFTP para ser analisado pela TEMASEK
@author    
@version   
@since     07/02/2020
/*/
//-------------------------------------------------------------------------------------------------------------                                                         
Static Function LgInvoice()   
Local cSQL	     := '' 
Local cSQLUpd	 := '' 
Local nD		 := 0 
Local nU         := 0 
Local nUP        := 0    
Local nX         := 0 
Local cAliasZG0  := GetNextAlias()
Local cINT083In  := GetNewPar('EZ_6Q083IN','/pwldbms/PRD/WD/INT083/IN/')     
Local cRootPath  := GetSrvProfString("RootPath", "\undefined")    //retorna o caminho do rootpath         
Local cLocArq 	  := '\6qsimport\entradas\'
Local cLocRetErr  := '\6qsimport\retornos\errorlog\'
Local cLocLogs    := '\6qsimport\logs\'      
Local cLocLgEr    := '\6qsimport\logs\erro\'  
Local aGeraArq    := {}   
Local aFiles      := {}

If Z0G->Z0G_TABELA <> "SF1" 
   MsgInfo("Opção válida para Documento com Invoice Rejeitada.")         
   Return
Else   
   If Z0G->Z0G_STATUS <> "0"                 
      MsgInfo("Opção válida para Documento com Status Invoice Rejeitada.")         
      Return
   EndIf    
EndIf

cArquivo := Z0G->Z0G_ARQUIV  
																																																															   
cSQLUpd := " SELECT DISTINCT SUBSTRING(Z0G_CHAVE,1,9) as NOTA,SUBSTRING(Z0G_CHAVE,10,3) as SERIE,SUBSTRING(Z0G_CHAVE,13,14) as CNPJ,Z0G_ARQUIV as ARQUIVO FROM " + RETSQLNAME("Z0G") +" WHERE D_E_L_E_T_ = '' AND Z0G_TABELA = 'SF1' AND Z0G_STATUS = '0' AND Z0G_ARQUIV = '" +cArquivo +"'"
DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQLUpd), (cAliasZG0), .F., .T.)                                                                                                                                                                                  
		
(cAliasZG0)->( dBgotop())
While (cAliasZG0)->(!Eof())
      AAdd(aGeraArq,{NOTA,SERIE,CNPJ,ARQUIVO})  //carrega o array com as notas e impostos por arquivo
      (cAliasZG0)->(DbSkip()) 
EndDo 				

fRename(cArquivo,Substr(cArquivo,1,Rat(".csv",cArquivo))+'int',,.F.) //Renomear arquivo na pasta de entrada, pois não haverá reprocessamento.			

If ExistBlock("HLBGEN01")
		   	    
   aFileDel := {}		        
   aDir(cLocRetErr+"*.csv",aFileDel,,,,,.F.) // carrega todos os arquivos para encriptar e renomear na pasta \6QSIMPORT\RETORNOS\ERRORLOG\
   For nD := 1 To Len(aFileDel)				
       Conout("6QEST001 ->Schedule -> Encriptado arquivo de ErrorLOG na pasta: "+cLocRetErr) 
       If nD = 1	 	 		
		   U_HLBGEN01("E","16B173771B75044C",cRootPath+cLocRetErr,"*.csv")   //Encripta o arquivo de errorlog na pasta retorno '\6QSIMPORT\RETORNOS\ERRORLOG\
	   EndIf
	   Conout("6QEST001 -> Schedule -> Renomeado Arquivos Log de Inconsistencia: "+aFileDel[nD]+" pasta: "+cLocRetErr)
	   fRename(cLocRetErr+aFileDel[nD],cLocRetErr+substr(aFileDel[nD],1,Rat(".csv",aFileDel[nD]))+'ecp',,.F.) //Renomeia o arquivo csv da pasta retorno após encriptar.	    	    
   Next nD	
     		        
   aFileLog := {}
   aDir(cLocRetErr+"*.gpg",aFileLog,,,,,.F.) //carrega o arquivo criptografado da pasta retorno
   cArq := ''             
   For nU := 1 To Len(aFileLog)
       fRename(cLocRetErr+aFileLog[nU],cLocRetErr+substr(aFileLog[nU],1,rat(".gpg",aFileLog[nU]))+'pgp',,.F.)  //Renomear o arquivo .gpg para .pgp
       cArq := substr(aFileLog[nU],1,rat(".gpg",aFileLog[nU]))+'pgp'     
       Conout("6QEST001 -> Schedule -> Renomeado Arquivos de Erro encriptado: "+cArq+" na pasta "+cLocRetErr+" para Upload")	   
       U_GerSFTP('PUT',cArq,cLocRetErr,cINT083In,cLocLogs,cLocLgEr)                 //Upload do arquivo error log criptografado no SFTP
       Conout("6QEST001 -> Schedule -> UpLoad do Arquivo de Erro encriptado: "+cArq+" para pasta "+cINT083In+" do SFTP")
       fRename(cLocRetErr+cArq,cLocRetErr+substr(cArq,1,Rat(".pgp",cArq))+'out',,.F.) //Renomear o arquivo criptografado da pasta retorno após envio ao SFTP.
       Conout("6QEST001 -> Schedule -> Renomeado Arquivos de Erro: "+cArq+" na pasta: "+ cLocRetErr+" apos Upload")	    
   Next nU    

   For nUP = 1 To Len(aGeraArq)  //atualiza o status no monitor das notas no monitor																		
	   cSQLUpd	:= "UPDATE "+RetSqlName("Z0G")+" SET Z0G_STATUS = '1',Z0G_TABELA = 'SF1',Z0G_MENSAG = 'Arquivo rejeicao enviado com sucesso' "			   
	   cSQLUpd	+= " WHERE Z0G_STATUS = '0' AND Z0G_TABELA = 'SF1' AND Z0G_CHAVE = '"+aGeraArq[nUP][1]+aGeraArq[nUP][2]+aGeraArq[nUP][3]+ "' AND Z0G_ARQUIV  = '" + aGeraArq[nUP][4] + "' "
	   TCSQLEXEC(cSQLUpd)
   Next nUP  
   OBRWXML:REFRESH(.T.)     
   
EndIf 


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LgJournal.
Encripta o error log do journal e envia o error log da contabilização para SFTP para ser analisado pela TEMASEK
@author    
@version   
@since     07/02/2020
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function LgJournal() 
Local cArquivo  
Local cAliasZG0 := GetNextAlias()
Local cRootPath := GetSrvProfString("RootPath", "\undefined")   											   
Local cINT085In := GetNewPar('EZ_6Q085IN','/pwldbms/PRD/WD/INT085/IN/')
Local cLocArq   := '\Journals_6Q\entradas\'
Local cLocRet   := '\Journals_6Q\retornos\'                                                                          
Local cLocLogs  := '\Journals_6Q\logs\'
Local cLocLgEr  := '\Journals_6Q\logs\erro\'
Local cArqDel   := ''
Local aGeraArq  := {}     
Local aFiles    := {}
Local nU        := 0 
Local nD        := 0   
Local nR        := 0  
Local nUP       := 0   
Local nX        := 0

If Z0G->Z0G_TABELA <> "CT2" 
   MsgInfo("Opção válida para Documento com Status Journal Rejeitado.")         
   Return
Else   
   If Z0G->Z0G_STATUS <> "0"                 
      MsgInfo("Opção válida para Documento com Status Journal Rejeitado.")         
      Return
   EndIf    
EndIf

cArquivo := Z0G->Z0G_ARQUIV  
																																																															   
cSQLUpd := " SELECT DISTINCT SUBSTRING(Z0G_CHAVE,1,8) as LANCA,SUBSTRING(Z0G_CHAVE,09,6) as LOTE,SUBSTRING(Z0G_CHAVE,15,03) as SUBLOTE,SUBSTRING(Z0G_CHAVE,18,6) AS DOCTO,Z0G_ARQUIV as ARQUIVO FROM " + RETSQLNAME("Z0G") +" WHERE D_E_L_E_T_ = '' AND Z0G_TABELA = 'CT2' AND Z0G_STATUS = '0' AND Z0G_ARQUIV = '" +cArquivo +"'"
DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQLUpd), (cAliasZG0), .F., .T.)                                                                                                                                                                                  
		
(cAliasZG0)->( dBgotop())
While (cAliasZG0)->(!Eof())
      AAdd(aGeraArq,{LANCA,LOTE,SUBLOTE,DOCTO,ARQUIVO})  //carrega o array com o lancamento,lote,sublote,documento e arquivo selecionado no monitor.
      (cAliasZG0)->(DbSkip()) 
EndDo 				

fRename(cArquivo,Substr(cArquivo,1,Rat(".csv",cArquivo))+'int',,.F.)  //Renomear arquivo na pasta de entrada, pois não haverá reprocessamento.

If ExistBlock("HLBGEN01")
    aFileDel := {}
	aDir(cLocRet+"*.csv",aFileDel,,,,,.F.) //Carrega todos os arquivos csv para renomear e encriptar.	     
	For nD := 1 To Len(aFileDel) 	        
		Conout("Schedule -> Encriptado arquivos pasta: "+cLocRet)	    
	    If nD = 1	         
	       U_HLBGEN01("E","16B173771B75044C",cRootPath+cLocRet,"*.csv")   //Encripta o arquivo na pasta de retorno.    	       
	    EndIf
	    Conout("Schedule -> Renomeado arquivo: "+aFileDel[nD]+" pasta: "+ cLocRet)  
	    fRename(cLocRet+aFileDel[nD],cLocRet+substr(aFileDel[nD],1,Rat(".csv",aFileDel[nD]))+'ecp',,.F.) //Renomeia o arquivo csv da pasta retorno após encriptar.	    
	Next nD			       
	aFileRet := {}
	aDir(cLocRet+"*.gpg",aFileRet,,,,,.F.) //Carrega os arquivos encriptados na pasta retorno 
	cArq := ''
	For nR := 1 To Len(aFileRet)  
	    fRename(cLocRet+aFileRet[nR],cLocRet+substr(aFileRet[nR],1,Rat(".gpg",aFileRet[nR]))+'pgp',,.F.) //Renomeia o arquivo criptografado da pasta retorno.
	    cArq := substr(aFileRet[nR],1,Rat(".gpg",aFileRet[nR]))+'pgp' 	        	        
	    Conout("Schedule -> Upload arquivo "+ cArq+" Pasta: "+cLocRet+" para Upload")  
	    U_GerSFTP('PUT',cArq,cLocRet,cINT085In,cLocLogs,cLocLgEr)                    //Envia os arquivos para a pasta no SFTP. 
	    fRename(cLocRet+cArq,cLocRet+substr(cArq,1,Rat(".pgp",cArq))+'out',,.F.)     //Renomeia o arquivo criptografado da pasta retorno após envio ao SFTP. 
	    Conout("Schedule -> Renomeado arquivo: "+cArq+" Pasta: "+ cLocRet+ " apos Upload")           	                  
	Next nR	        
	
	For nUP = 1 To Len(aGeraArq) //atualiza o status no monitor dos documentos no monitor																	
	    cSQLUpd	:= "UPDATE "+RetSqlName("Z0G")+" SET Z0G_STATUS = '1',Z0G_TABELA = 'CT2',Z0G_MENSAG = 'Arquivo rejeicao enviado com sucesso' "			   
	    cSQLUpd	+= " WHERE Z0G_STATUS = '0' AND Z0G_TABELA = 'CT2' AND Z0G_CHAVE = '"+aGeraArq[nUP][1]+aGeraArq[nUP][2]+aGeraArq[nUP][3]+aGeraArq[nUP][4]+ "' AND Z0G_ARQUIV  = '" + aGeraArq[nUP][5] + "' "
	    TCSQLEXEC(cSQLUpd)
	Next nUP 
	OBRWXML:REFRESH(.T.)
	
EndIf
