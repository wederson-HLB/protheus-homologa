#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#Include "Topconn.ch"

/*
Funcao      : 33GPE001
Parametros  : 
Retorno     : 
Objetivos   : Geracao de arquivo TXT com dados da CT2
Autor       : RASS CONSULTORIA WWW.RASSCONSULTORIA.COM.BR(HEVERTON M. DOS SANTOS)
Data/Hora   : 09/01/2012
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 23/05/2012
Módulo      : Gestão de Pessoal
*/
*----------------------*
User Function 33GPE001()
*----------------------*
Local aSays 	:= {}
Local aButtons	:= {}
Local dDataSalv := dDataBase
Local nOpca 	:= 0
Local cperg		:= "33GPE001"
Local aHelpP	:= {} 
Local cArq 		:= ""

Private cCadastro := OemToAnsi(OemtoAnsi("Dados da CT2"))

//MSM - 23/05/2012 Alterado para tratar de forma mais específica as informações a serem extraidas dos laçamentos contábeis 
aHelpP := {}
aAdd(aHelpP, "Informe a Filial")
U_PUTSX1(cPerg, '01', 'Filial De          ?', 'Filial De          ?', 'Filial De          ?', 'mv_ch1', 'C', 2, 0, 0, 'G','',''   ,'','', 'mv_par01',''            ,''            ,''            , ''          ,''                ,''                ,''                ,''               ,''               ,''               ,''            ,''            ,''            ,'','','', aHelpP,aHelpP,aHelpP)
U_PUTSX1(cPerg, '02', 'Filial Ate         ?', 'Filial Ate         ?', 'Filial Ate         ?', 'mv_ch2', 'C', 2, 0, 0, 'G','',''   ,'','', 'mv_par02',''            ,''            ,''            , ''          ,''                ,''                ,''                ,''               ,''               ,''               ,''            ,''            ,''            ,'','','', aHelpP,aHelpP,aHelpP)
//MSM - 23/05/2012 Alterado para tratar de forma mais específica as informações a serem extraidas dos laçamentos contábeis     
aHelpP := {}
aAdd(aHelpP, "Informe a Data")
U_PUTSX1(cPerg, '03', 'Data De            ?', 'Data De            ?', 'Data De            ?', 'mv_ch3', 'D', 8, 0, 0, 'G','',''   ,'','', 'mv_par03',''            ,''            ,''            , ''          ,''                ,''                ,''                ,''               ,''               ,''               ,''            ,''            ,''            ,'','','', aHelpP,aHelpP,aHelpP)
U_PUTSX1(cPerg, '04', 'Data Ate           ?', 'Data Ate           ?', 'Data Ate           ?', 'mv_ch4', 'D', 8, 0, 0, 'G','',''   ,'','', 'mv_par04',''            ,''            ,''            , ''          ,''                ,''                ,''                ,''               ,''               ,''               ,''            ,''            ,''            ,'','','', aHelpP,aHelpP,aHelpP)
//MSM - 23/05/2012 Alterado para tratar de forma mais específica as informações a serem extraidas dos laçamentos contábeis     
aHelpP := {}
aAdd(aHelpP, "Informe o tipo")
U_PUTSX1(cPerg, '05', 'Tipo               ?', 'Tipo               ?', 'Tipo               ?', 'mv_ch5', 'N', 1, 0, 0, 'C','',''   ,'','', 'mv_par05','1-Férias e 13º salário',''            ,''            , ''          ,'2-Folha e Encargos',''                ,''                ,'3-Ambos'               ,''               ,''               ,''            ,''            ,''            ,'','','', aHelpP,aHelpP,aHelpP)

Pergunte(CPERG,.f.)

AADD(aSays,OemToAnsi( "Esta rotina irá gerar TXT com dados da CT2" ) )

AADD(aButtons, {14,.T.,{|| cArq := cGetFile("Arquivos de Texto|*.TXT|Todos Arquivos|*.*","Arquivo Contabil",0,"C:\",.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.) } } )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPERG,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If(cArq != "", FechaBatch(), MsgAlert("Informe um arquivo") )}})
AADD(aButtons, { 2,.T.,{|| FechaBatch(),nOpca := 0 }} )

FormBatch( cCadastro, aSays, aButtons )
	
IF nOpca == 1
	Processa({|lEnd| PROCESS(cArq)})
Endif

dDataBase := dDataSalv

Return

/*
Funcao      : PROCESS
Parametros  : Nil
Retorno     : Nil
Objetivos   : Processamento
Autor       : Heverton M. dos Santos
Data/Hora   : 06/10/11
*/
*----------------------------*
Static Function PROCESS(cFile)
*----------------------------*
Local nH 
Local nCont := 0
Local nFile := 1
Local cMens := ""
Local cQry:=""

If  substr(cFile,len(cFile)-3,4) != ".txt"
	cFile := cFile+strzero(nFile,2)+".txt"
Else
	cFile := substr(cFile,1,len(cFile)-4)+strzero(nFile,2)+".txt"
EndIf
  

nH := fCreate(cFile) 
If nH == -1                  
   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
   Return 
Endif 

//MSM - 23/05/2012 Alterado para buscar informações através de Query, possibilitando um filtro mais específico
cQry+=" SELECT CT2_FILIAL,CT2_DATA,CT2_DEBITO,CT2_CREDIT,CT2_CCC,CT2_CCD,CT2_HIST,CT2_VALOR FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE D_E_L_E_T_='' AND CT2_ROTINA='GPEM110' AND CT2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR01+"'"+CRLF

if MV_PAR05==1
	cQry+=" AND CT2_LP IN (SELECT CT2_LP FROM "+RETSQLNAME("CT2")+CRLF
	cQry+=" WHERE UPPER(CT2_HIST) LIKE '%FERIAS%' OR CT2_HIST LIKE '%13%' AND CT2_ROTINA='GPEM110' AND D_E_L_E_T_=''"+CRLF
	cQry+=" GROUP BY CT2_LP)"
	
elseif MV_PAR05==2
	cQry+=" AND CT2_LP NOT IN (SELECT CT2_LP FROM "+RETSQLNAME("CT2")+CRLF
	cQry+=" WHERE UPPER(CT2_HIST) LIKE '%FERIAS%' OR CT2_HIST LIKE '%13%' AND CT2_ROTINA='GPEM110' AND D_E_L_E_T_=''"+CRLF
	cQry+=" GROUP BY CT2_LP)"
endif	

/*
dbSelectArea("CT2")
CT2->(dbSetOrder(1))
CT2->(dbGoTop())
CT2->(dbSeek(MV_PAR01+DTOS(MV_PAR02)))      
 */           
 
     
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
	        
		if nRecCount >0

			QRYTEMP->(DbGoTop())
	        While QRYTEMP->(!EOF())
			
		//While CT2->CT2_FILIAL == MV_PAR01 .AND. CT2->CT2_DATA == MV_PAR02 .AND. !CT2->(EOF())
				If nCont == 0
					fWrite(nH,;	 
						space(10)+;
						"180"+;
						space(4)+;
						substr(QRYTEMP->CT2_DATA,7,2)+;	
						","+;
						substr(QRYTEMP->CT2_DATA,5,2)+;
						","+;
						substr(QRYTEMP->CT2_DATA,1,4)+;
						space(12)+;
						"CONTABIL, FOLHA BRL"+;
						chr(13)+chr(10))
					nCont++	
				Else
					If !empty(QRYTEMP->CT2_DEBITO) .And. !empty(QRYTEMP->CT2_CREDITO)
						//Partida Dobrada
						
						//Parte Debito
						cTipo := "40"
						cRedu := substr(QRYTEMP->CT2_CCD,1,2)
						cCont := substr(QRYTEMP->CT2_DEBITO,1,8)
						If substr(cCont,1,1) > "5"
							cCent := substr(QRYTEMP->CT2_CCD,1,8)
						Else
							cCent := "        "
						EndIf
						cHist := ALLTRIM(QRYTEMP->CT2_HIST)+" FOLPAG "+SUBSTR(QRYTEMP->CT2_DATA,5,2)+"/"+SUBSTR(QRYTEMP->CT2_DATA,1,4) 
						nTam := LEN(cHist)			
						
						fWrite(nH,;
							space(3)+;
							cTipo+;
							cRedu+;
							cCont+;
							space(3)+;
							cCent+;
							space(2)+;
							transform(QRYTEMP->CT2_VALOR,"@e 9999999999999999.99")+;
							cHist+;
							space(50-nTam)+;
							chr(13)+chr(10))	
					    nCont++
						
						//Parte Credito
						cTipo := "50"
						cRedu := substr(QRYTEMP->CT2_CCC,1,2)
						cCont := substr(QRYTEMP->CT2_CREDITO,1,8)
						If substr(cCont,1,1) > "5"
							cCent := substr(QRYTEMP->CT2_CCC,1,8)
						Else
							cCent := "        "
						EndIf		    
					    
					    fWrite(nH,;
							space(3)+;
							cTipo+;
							cRedu+;
							cCont+;
							space(3)+;
							cCent+;
							space(2)+;
							transform(QRYTEMP->CT2_VALOR,"@e 9999999999999999.99")+;
							cHist+;
							space(50-nTam)+;
							chr(13)+chr(10))	
					    nCont++
						QRYTEMP->(dbSkip())		    
					Else
						If !empty(QRYTEMP->CT2_DEBITO)
							//Debito
							cTipo := "40"
							cRedu := substr(QRYTEMP->CT2_CCD,1,2)
							cCont := substr(QRYTEMP->CT2_DEBITO,1,8)
							If substr(cCont,1,1) > "5"
								cCent := substr(QRYTEMP->CT2_CCD,1,8)
							Else
								cCent := "        "
							EndIf
						Else
							//Credito
							cTipo := "50"
							cRedu := substr(QRYTEMP->CT2_CCC,1,2)
							cCont := substr(QRYTEMP->CT2_CREDITO,1,8)
							If substr(cCont,1,1) > "5"
								cCent := substr(QRYTEMP->CT2_CCC,1,8)
							Else
								cCent := "        "
							EndIf
						EndIf
						cHist := ALLTRIM(QRYTEMP->CT2_HIST)+" FOLPAG "+SUBSTR(QRYTEMP->CT2_DATA,5,2)+"/"+SUBSTR(QRYTEMP->CT2_DATA,1,4) 
						nTam := LEN(cHist)
						fWrite(nH,;
							space(3)+;
							cTipo+;
							cRedu+;
							cCont+;
							space(3)+;
							cCent+;
							space(2)+;
							transform(QRYTEMP->CT2_VALOR,"@e 9999999999999999.99")+;
							cHist+;
							space(50-nTam)+;
							chr(13)+chr(10)) 
						QRYTEMP->(dbSkip())
						nCont++
					EndIf
				EndIf
				If nCont == 999
					nCont := 0
					fClose(nH)
					cMens += cFile+", "
					nFile++
					cFile := substr(cFile,1,len(cFile)-6)+strzero(nFile,2)+".txt"
					nH := fCreate(cFile) 
					If nH == -1                  
			   			MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
			   			Return 
					Endif	
				EndIf
			EndDo 
		else
			fWrite(nH,"Não há dados para essa busca!") 
		endif
		
fClose(nH) 

Msginfo(str(nFile)+" arquivos criados: "+cMens) 

RETURN(NIL)
