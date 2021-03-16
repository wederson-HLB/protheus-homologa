#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "APWIZARD.CH" 
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTFAT005
Parametros  : 
Retorno     : 
Objetivos   : Manutenção NFTS
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/

//Para funcionar a rotina é necessário executar os updates: UZ59001 e USX3033
*----------------------*
User Function GTFAT005()
*----------------------*
Private cCadastro := "Manutenção de NFTS"
Private aLegenda := {	{"BR_VERDE"   ,"Arquivo Gerado"},;
		   		  		{"BR_VERMELHO","Falha na Geração."},;
				  		{"BR_AZUL"    ,"Arquivo Recebido"},;
				  		{"BR_LARANJA" ,"Falha no Recebimento"},;
				  		{"BR_BRANCO"  ,"Sem Informações."}} 
				  		
Private cMarca   := GetMark() 

//Chamo o wizard de processamento
InWizard()

//RegTipo6()

/*Local lOk := .F.
Local aCores    := {{"STATUSZ59 == '1'", "BR_VERDE"   	},;
					{"STATUSZ59 == '2'", "BR_VERMELHO"	},;
					{"STATUSZ59 == '3'", "BR_AZUL"		},;
					{"STATUSZ59 == '4'", "BR_LARANJA"	},;
					{"STATUSZ59 == '5'", "BR_BRANCO"	}} 
				    
Private aLegenda := {	{"BR_VERDE"   ,"Arquivo Gerado"},;
		   		  		{"BR_VERMELHO","Falha na Geração."},;
				  		{"BR_AZUL"    ,"Arquivo Recebido"},;
				  		{"BR_LARANJA" ,"Falha no Recebimento"},;
				  		{"BR_BRANCO"  ,"Sem Informações."}} 
        
Private cCadastro := "Manutenção de NFTS"
Private cAlias := "TMPNFTS"
Private aColunas   := 	{}  

//Tela de Filtros
cGet1 := Space(5)
cGet2 := CTOD("  /  /  ")
cGet3 := CTOD("  /  /  ")
cGet4 := Space(1)
cGet5 := "2"

oDlg1      := MSDialog():New( 183,540,548,860,"Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,160,156,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 016,008,{||"Tp. Documento"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay2      := TSay():New( 032,008,{||"Dt. Emissão De"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay3      := TSay():New( 048,008,{||"Dt. Emissão Ate"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay4      := TSay():New( 064,008,{||"Serie"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay5      := TSay():New( 080,008,{||"TES Atualiza Estoque"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oGet1      := TGet():New( 016,088,{|u|if(PCount()>0,cGet1:=u,cGet1)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2      := TGet():New( 032,088,{|u|if(PCount()>0,cGet2:=u,cGet2)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet3      := TGet():New( 048,088,{|u|if(PCount()>0,cGet3:=u,cGet3)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet4      := TGet():New( 064,088,{|u|if(PCount()>0,cGet4:=u,cGet4)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oCBox1     := TComboBox():New(080,088,{|u|if(PCount()>0,cGet5:=u,cGet5)},{"1=Sim","2=Não"},060,010,oGrp1,,,,,,.T.,,,,,,,,,"cGet5")
oSBtn1     := SButton():New( 164,092,1,{|| (lOk := .T.,oDlg1:end())},oDlg1,,"", )
oSBtn2     := SButton():New( 164,128,2,{|| (lOk := .F.,oDlg1:end())},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

If !lOk
	Return .T.
EndIf

BuscaDados() 

//Tela ----------------------------
//MarkBrowse
Private aCpos := {}
aAdd(aCpos,{"cINTEGRA","", })
			
SX3->(DbSetOrder(1))
SX3->(DbSeek("SF1")) 
While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SF1"
	If SX3->X3_BROWSE == "S"
		aAdd(aCpos,{SX3->X3_CAMPO,"",RetTitle(SX3->X3_CAMPO)})
	EndIf	
	SX3->(DbSkip())
EndDo

Private oFont14  := TFont():New('Courier new',,-14,.T.)
Private aButtons := {}
aadd(aButtons,{"SELECTALL"	,{|| MarcaTds(cAlias)	}	,"Marca "			,"Marca "	   		,{|| .T.}})
aadd(aButtons,{"PMSSETAUP" 	,{|| GeraRem()			}	,"Transmissao" 		,"Transmissao"		,{|| .T.}})
aadd(aButtons,{"PMSSETADOWN",{|| ProcRet()			}	,"Proc. Retorno"  	,"Proc. Retorno"	,{|| .T.}})
aadd(aButtons,{"HISTORIC"	,{|| FAT005H()			}	,"Historico"  		,"Historico"  		,{|| .T.}})
aadd(aButtons,{"BMPVISUAL"	,{|| FAT005A()			}	,"Gera Arq. Rem"	,"Gera Arq. Rem"	,{|| .T.}})
aadd(aButtons,{"BMPVISUAL"	,{|| FAT005V()			}	,"Visualiza Doc."	,"Visualiza Doc."	,{|| .T.}})
aadd(aButtons,{"PMSCOLOR"	,{|| FAT005L()			}	,"Legenda"	   		,"Legenda"	   		,{|| .T.}})

Private cMarca   := GetMark() 
                    
Private aStruSF1 := {}
Private aItens   := {} 

Private lInverte := .f.

(cAlias)->(DbGoTop())
If (cAlias)->(!BOF() .and. !EOF())
	aSize := MsAdvSize()
   	DEFINE MSDIALOG oDlg TITLE "Notas Fiscais" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
                        
    	oMark  := MsSelect():New(cAlias,"cINTEGRA",,aCpos,@lInverte,@cMarca,{aSize[7],0,(aSize[6]/2)-14,(aSize[5]/2)},,,oDlg,,aCores)   
     	   
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| ( oDlg:End())},,aButtons) CENTERED
Else
   	MsgInfo("Sem arquivos para Seleção!","Grant Thornton Brasil")
   	Return .F.   
EndIf
*/
Return .T.

/*
Funcao      : BuscaDados
Parametros  : 
Retorno     : 
Objetivos   : Busca Dados NFTS
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/
*--------------------------------------------------------*
Static Function BuscaDados(oMeter,oDlg1,oBrowse,oWizard)
*--------------------------------------------------------*
Local cQry 		:= "" 
Local cAliasQry := "TMPQRY"

//Local aStruQry := SF1->(dbStruct())

//aAdd(aStruQry,{"F4_ESTOQUE","C",1,0})


If Select(cAliasQry) > 0
	(cAliasQry)->(DbClosearea())
Endif
//If Select(cAlias) > 0
//	(cAlias)->(DbClosearea())
//Endif   

//Limpo a temporária com as marcações
if select(cAlias)>0
    DbSelectArea(cAlias)
    ZAP
endif


cQry += " Select *
cQry += " From (select SF1.*,D1_TES = (select top 1 D1_TES 
cQry += " 						from "+RetSqlName("SD1")+" SD1 
cQry += " 						where	D1_FILIAL	=F1_FILIAL and
cQry += " 								D1_DOC		=F1_DOC and
cQry += " 								D1_SERIE	=F1_SERIE and
cQry += " 								D1_FORNECE	=F1_FORNECE and
cQry += " 								D1_LOJA		=F1_LOJA and
cQry += " 								SD1.D_E_L_E_T_ <> '*')
cQry += "					,D1_CF = (select top 1 D1_CF 
cQry += " 						from "+RetSqlName("SD1")+" SD1 
cQry += " 						where	D1_FILIAL	=F1_FILIAL and
cQry += " 								D1_DOC		=F1_DOC and
cQry += " 								D1_SERIE	=F1_SERIE and
cQry += " 								D1_FORNECE	=F1_FORNECE and
cQry += " 								D1_LOJA		=F1_LOJA and
cQry += " 								SD1.D_E_L_E_T_ <> '*')
cQry += " 		from "+RetSqlName("SF1")+" SF1
cQry += " 		where SF1.D_E_L_E_T_ <> '*') SF1 Left outer Join (Select F4_ESTOQUE,F4_CODIGO
cQry += " 													  		From "+RetSqlName("SF4")+" 
cQry += " 													  		Where D_E_L_E_T_ <> '*') as SF4 on SF1.D1_TES = SF4.F4_CODIGO
cQry += " Where SF1.D_E_L_E_T_ <> '*'

/*If !Empty(cGet1)
	cQry += " AND SF1.F1_ESPECIE = '"+cGet1+"'
EndIf
If !Empty(cGet2)
	cQry += " AND SF1.F1_EMISSAO >= '"+DTOS(cGet2)+"'
EndIf
If !Empty(cGet3)
	cQry += " AND SF1.F1_EMISSAO <= '"+DTOS(cGet3)+"'
EndIf
If !Empty(cGet4)
	cQry += " AND SF1.F1_SERIE = '"+cGet4+"'
EndIf         
If cGet5 == "1"
	cQry += " AND SF4.F4_ESTOQUE = 'S'
Else
	cQry += " AND SF4.F4_ESTOQUE = 'N'
EndIf
*/      	

cQry += " AND SF1.F1_EMISSAO BETWEEN '"+DTOS(dGet2)+"' AND '"+DTOS(dGet3)+"'"

if !empty(cGet4)
	cQry += " AND SF1.F1_SERIE = '"+cGet4+"'
endif

if !empty(cGet5)
	//pego todos os CFOP's inseridos e os coloco em uma variável auxiliar para verificação no IN do sql
	aAuxArr:= StrToKarr(cGet5,";")
	cAuxArr:= ""
	
	for i:=1 to len(aAuxArr)
		if !empty(aAuxArr[i])
			cAuxArr+="'"+alltrim(aAuxArr[i])+"',"
		endif
	next
	
	if !empty(cAuxArr)
		cAuxArr:=Substr(cAuxArr,1,len(alltrim(cAuxArr))-1)
		cQry += " AND SF1.D1_CF IN ("+cAuxArr+")"
	endif
endif

if !empty(cGet6)
	//pego todos as espécies inseridas e as coloco em uma variável auxiliar para verificação no IN do sql
	aAuxArr:= StrToKarr(cGet6,";")
	cAuxArr:= ""
	
	for i:=1 to len(aAuxArr)
		if !empty(aAuxArr[i])
			cAuxArr+="'"+alltrim(aAuxArr[i])+"',"
		endif
	next
	
	if !empty(cAuxArr)
		cAuxArr:=Substr(cAuxArr,1,len(alltrim(cAuxArr))-1)
		cQry += " AND SF1.F1_ESPECIE IN ("+cAuxArr+")"
	endif
endif


dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),cAliasQry,.F.,.T.)              

Count to nRecCount

(cAliasQry)->(DbGoTop())
   
For nI := 1 To Len(aStruQry)
	If aStruQry[nI][2] <> "C" .and.  FieldPos(aStruQry[nI][1]) > 0
		TcSetField(cAliasQry,aStruQry[nI][1],aStruQry[nI][2],aStruQry[nI][3],aStruQry[nI][4])
	EndIf
Next nI  

/* 
aAdd(aStruQry,{})
aIns(aStruQry,1)
aStruQry[1] := {"CINTEGRA","C",2,0}

aAdd(aStruQry,{"F4_CODIGO"	,"C",3,0})

aAdd(aStruQry,{"STATUSZ59"	,"C",1,0})
aAdd(aStruQry,{"RECZ59"		,"N",6,0})

cArqTmp		:= CriaTrab(aStruQry,.T.)		

dbUseArea(.T.,__LocalDriver,cArqTmp,cAlias,.F.,.F.)
dbCreateInd(cArqTmp+OrdBagExt(),"F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA", {|| "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA"})
*/

DbSelectArea(cAlias)

nAumenta:= 100/((nRecCount)/100)

(cAliasQry)->(DbGoTop())
While !((cAliasQry)->(Eof()))
	RecLock(cAlias,.T.)
	For nX := 1 To (cAlias)->(FCount())
		If (cAlias)->(FieldName(nX)) <> "CINTEGRA" .and. (cAlias)->(FieldName(nX)) <> "STATUSZ59" .and. (cAlias)->(FieldName(nX)) <> "RECZ59"
   			Replace (cAlias)->&(FieldName(nX))	With (cAliasQry)->&((cAlias)->(FieldName(nX)))
	 	EndIf
	Next     
    
	// Busca Status da NF.
	If Select("TMP") > 0
		("TMP")->(DbClosearea())
	Endif
	cQryTmp := "Select * From "+RETSQLNAME("Z59")
	cQryTmp += " Where D_E_L_E_T_ <> '*'"
	cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
	cQryTmp += "       AND Z59_CHAVE = '"+(cAliasQry)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"

	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
                     
    TMP->(DbGoTop())
	If TMP->(EOF())
		(cAlias)->STATUSZ59 := "5"
	Else
		(cAlias)->STATUSZ59 := TMP->Z59_TIPO
		(cAlias)->RECZ59	:= TMP->R_E_C_N_O_
	EndIf
  	 	
	(cAlias)->(MsUnLock())
	(cAliasQry)->(DbSkip())
	
	//Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=nAumenta 	// atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua
	
Enddo

//Finaliza a barra
oDlg1:end()
oBrowse:Refresh(.T.)

Return .T.

/*
Funcao      : FAT005L
Parametros  : 
Retorno     : 
Objetivos   : Legenda.
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/
*----------------------*
Static Function FAT005L()
*----------------------*
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return .T.

*-----------------------------------*
Static Function MarcaTds(PAlias)
*-----------------------------------* 
DbSelectArea(PAlias)   
(PAlias)->(DbGoTop())  
While (PAlias)->(!EOF())
	RecLock(PAlias,.F.)     
    If (PAlias)->cINTEGRA == cMarca     		
		(PAlias)->cINTEGRA:=Space(02)         		
	Else
		(PAlias)->cINTEGRA:= cMarca       
	EndIf 
	(PAlias)->(MsUnlock())
	(PAlias)->(DbSkip())
EndDo      

(PAlias)->(DbGoTop())     

Return      

/*
Metodo      : GravaRem
Classe      : 
Descrição   : Geração do Arquivo de Remessa
Autor       : Jean Victor Rocha
Data        : 09/09/2013
*/ 
*-----------------------*
Static Function GeraRemMain()
*-----------------------*      
Local aAreaAnt 	:= GETAREA()
Local lMarcado 	:= .F.
Local lRemAceita:= .F.

Local lJaGerado	:= .F.

Private aArq 		:= {}
Private cLog 		:= ""
Private lReproc 	:= .F.
Private aChaveLog 	:= {}
Private aArray		:= {}
Private aLotes		:= {}
Private cLotes		:= ""
Private cChaves		:= ""

If !ChkFile("Z59")
	Alert("Geração de arquivo Falhou, tabela Z59 não encontrada!","Grant Thornton Brasil.")
	Return .F.
EndIf                            

aArq := Array(2)     
aArq[2] := GetArq()

cErroLog:= ""

(cAlias)->(DbGoTop())  
While (cAlias)->(!EOF())
    If (cAlias)->cINTEGRA == cMarca// .and. (cAlias)->STATUSZ59 <> "3"//Retorno Recebido.
		
		aArq[1] := cEmpAnt+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		
		lMarcado := .T.
		//If (cAlias)->STATUSZ59 == "5" .or. (cAlias)->STATUSZ59 == "2" .or. lReproc
			//aArq := GetArq()
			
			//GravaRem()
			
			//(cAlias)->STATUSZ59 := IIF(EMPTY(cLog),"1","2")//Remessa; Remessa Rejeitada
		//ElseIf MsgYesNo("NF: "+(cAlias)->F1_DOC+"-"+(cAlias)->F1_SERIE+" Forn: "+(cAlias)->F1_FORNECE+". Possui Status de Arquivo Gerado, deseja reprocessar?","Grant Thornton Brasil.")
			//aArq := GetArq()
		//	GravaRem()
		//	(cAlias)->STATUSZ59 := IIF(EMPTY(cLog),"1","2")//Remessa; Remessa Rejeitada
		//Else  
			
			//(cAlias)->cINTEGRA := Space(2)		
		
		//EndIf
        
        
        if select("QRYTRB")>0
        	QRYTRB->(DBCloseArea())
        endif
        
        //Busco arquivo gerado sem problema
       	cQry := "Select * From "+RETSQLNAME("Z59")
		cQry += " Where D_E_L_E_T_ <> '*'"
		cQry += "       AND Z59_ROTINA = 'GTFAT005'"
		cQry += "       AND Z59_CHAVE = '"+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"
		//cQry += "       AND Z59_TIPO = '1'"

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRYTRB",.F.,.T.)
        
        Count to nRecCount

       	QRYTRB->(DbGotop())        

        if nRecCount>0 .AND. QRYTRB->Z59_TIPO=='1'
	        lJaGerado:=.T.
	        exit
        endif             
        
        cTipoZ59:=aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][2]
		cErroLog+=aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][3]
		
		AADD(aArray,{"SF1",1, (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO),cTipoZ59})
        
        //Se não tiver o lote no array de lotes incluo ele
		if aScan(aLotes, {|x| x == QRYTRB->Z59_ID }) <= 0
        	AADD(aLotes,QRYTRB->Z59_ID)
        endif
        
		//If !lRemAceita
		//	lRemAceita := EMPTY(cLog)
		//EndIf
	EndIf 
	(cAlias)->(DbSkip())
EndDo

If lMarcado //.and. lRemAceita //.and. MsgYesNo("Processamento de Remessa Finalizado, Deseja Gerar Arquivo de Remessa Aceita?","Grant Thornton Brasil.")

	if !lJaGerado
	    
		// INICIO -- Deleto os lotes gerados com erro para gerar novo lote
			If Select("TMP") > 0
				("TMP")->(DbClosearea())
			Endif				                                
			
//			for nLot:=1 to len(aLotes)
//				cLotes+="'"+aLotes[nLot]+"',"
//			next
			//remove a ultima virgula
//			cLotes:=SUBSTR(cLotes,1,len(cLotes)-1)

			for nChav:=1 to len(aArray)
				cChaves+="'"+aArray[nChav][3]+"',"
			next
			//remove a ultima virgula
			cChaves:=SUBSTR(cChaves,1,len(cChaves)-1)			
			
			cQryTmp := "Select * From "+RETSQLNAME("Z59")
			cQryTmp += " Where D_E_L_E_T_ <> '*'"
			cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
			cQryTmp += "       AND Z59_CHAVE IN ("+cChaves+")"
			cQryTmp += "       AND Z59_TIPO = '2' "
//			cQryTmp += "       AND Z59_ID IN ("+cLotes+")"
			
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
			    
			TMP->(DbGoTop())
			While TMP->(!EOF())
				Z59->(DbGoTo(TMP->R_E_C_N_O_))
					Z59->(RecLock("Z59",.F.))
					Z59->(DbDelete())
				Z59->(MsUnlock())
				TMP->(DbSkip())	
			EndDo
		// FIM -- Deleto os lotes gerados com erro para gerar novo lote
	
		cNomeArq	:= "NFTS_"+cEmpAnt+"_"+DTOS(ddatabase)+"_"+STRTRAN(Time(),":","_")
		cRotina		:= "GTFAT005"
		cConteudo	:= aArq[2]
	
		if empty(cErroLog)
			cErroLog:="Ok"
		endif
		
		GravaLog(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
	
	endif
	
	FAT005A()
EndIf
        
//Tira a seleção de Todos os itens.
(cAlias)->(DbGoTop())  
While (cAlias)->(!EOF())
    If (cAlias)->cINTEGRA == cMarca     		
		(cAlias)->cINTEGRA := Space(2)
	EndIf 
	(cAlias)->(DbSkip())
EndDo
                  
If !lMarcado
	MsgInfo("Sem itens Selecionados para Processamento!","Grant Thornton Brasil.")
EndIf

RestArea(aAreaAnt)

Return .T.

/*
Metodo      : GetArq
Classe      : 
Descrição   : Geração do arquivo NFTS.
Autor       : Jean Victor Rocha
Data        : 
*/ 
*------------------------*
Static Function GetArq()
*------------------------*
//Local cNomeArq	:= cEmpAnt+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
Local cArq		:= ""
Local cTipoF	:= ""
Local cInscMF	:= ""
Local cAliqISS	:= ""
                          
cLog := ""
    
SF4->(DbSetOrder(1))
SF4->(xFilial("SF4")+(cAlias)->F4_CODIGO)

//Cabeçalho                     
cLin := Space(30)
cLin := Stuff(cLin,01,01, "1"	)//Tipo de Registro
cLin := Stuff(cLin,02,03, "001"	)//Versão do Arquivo
cLin := Stuff(cLin,05,08, STRZERO(VAL(SM0->M0_INSC),8))//Inscrição Municipal do Contribuinte (Tomador ou Intermediario)
cLin := Stuff(cLin,13,08, STRZERO(YEAR((cAlias)->F1_EMISSAO),4)+STRZERO(MONTH((cAlias)->F1_EMISSAO),2)+STRZERO(DAY((cAlias)->F1_EMISSAO),2) )//Dt Ini Per. Transf. no Arquivo
cLin := Stuff(cLin,21,08, STRZERO(YEAR((cAlias)->F1_EMISSAO),4)+STRZERO(MONTH((cAlias)->F1_EMISSAO),2)+STRZERO(DAY((cAlias)->F1_EMISSAO),2) )//Dt fim Per. Transf. no Arquivo
cLin := Stuff(cLin,29,02, CHR(13)+CHR(10) )//Caracter de Fim de linha
                
cArq += cLin
                  
nlinhas:=0
nValTot:=0
nValDed:=0
   
(cAlias)->(DbGoTop())  
While (cAlias)->(!EOF())   
	cLog := ""
    If (cAlias)->cINTEGRA == cMarca .and. (cAlias)->STATUSZ59 <> "3" //.and.;
    	//(lReproc .or. IIF((cAlias)->STATUSZ59=="5" .or. (cAlias)->STATUSZ59=="2",.T.,lReproc:=MsgYesNo("Exite(m) Nota(s) com Status de Arquivo Gerado, deseja reprocessar?","Grant Thornton Brasil.")))
		
		//Detalhe
		cLin := Space(440)//Não considera a Descrição, para que seja possivel apenas Concatenar
		cLin := Stuff(cLin,01,01, "4"	)//Tipo de Registro
		cLin := Stuff(cLin,02,02, ALLTRIM((cAlias)->F1_P_TPDOC)	)//Tipo de Documento
		cLin := Stuff(cLin,04,05, REPLICATE("0",15-LEN(ALLTRIM((cAlias)->F1_SERIE)))+ALLTRIM((cAlias)->F1_SERIE)	)//Serie do Documento
		cLin := Stuff(cLin,09,12, REPLICATE("0",12-LEN(ALLTRIM((cAlias)->F1_DOC)))+ALLTRIM((cAlias)->F1_DOC)	)//Numero do Documento
		cLin := Stuff(cLin,21,08, STRZERO(YEAR((cAlias)->F1_EMISSAO),4)+STRZERO(MONTH((cAlias)->F1_EMISSAO),2)+STRZERO(DAY((cAlias)->F1_EMISSAO),2))//Data de Prestação dos Serviços
		cLin := Stuff(cLin,29,01, "N"	)//Situação NFTS
		cLin := Stuff(cLin,30,01, ALLTRIM((cAlias)->F1_P_TRIBS)	)//Tributação do Serviço
		cLin := Stuff(cLin,31,15, STRZERO(VAL(STRTRAN(TRANSFORM((cAlias)->F1_VALBRUT,"@E 999999999999.99"),",","")),15)	)//Valor Dos Serviços 
		cLin := Stuff(cLin,46,15, STRZERO(VAL(STRTRAN(TRANSFORM((cAlias)->F1_P_VDED,"@E 999999999999.99"),",","")),15)	)//Valor das Deduções
		                   
		SF3->(DbSetOrder(5)) //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT 
		If SF3->(DbSeek(xFilial("SF3")+(cAlias)->F1_SERIE+(cAlias)->F1_DOC+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA))
			If VAL(SF3->F3_CODISS) > 9000
				cLog += "Código de Serviço Maior que 09000;"
			ElseIf EMPTY(SF3->F3_CODISS)
				cLog += "Código de Serviço em branco;"	
			EndIf
			
			//cLin := Stuff(cLin,61,05, STRZERO(VAL(SF3->F3_CODISS),5))//Código do Serviço Prestado	
			cLin := Stuff(cLin,61,05, SUBSTR(SF3->F3_CODISS,1,5) )//Código do Serviço Prestado	
			cLin := Stuff(cLin,66,04, STRZERO(VAL(SUBSTR(SF3->F3_CODISS,6,4)),5) )//Código do SubItem da lista
		Else 
			cLog += "Não foi possivel encontrar Código de Serviço;"
		EndIf 
		
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		if SA2->(DbSeek(xFilial("SA2")+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA))

	        //Tratamento para o indicador de CPF/CNPF
			if SA2->A2_TIPO=="F"
				cTipoF:="1"
			elseif SA2->A2_TIPO=="J"
				cTipoF:="2"
			elseif SA2->A2_TIPO=="X"
				cTipoF:="3"
			endif
	
			//Tratamento para inscrição municipal
			if alltrim(SA2->A2_EST)=="SP" .AND. alltrim(SA2->A2_COD_MUN)=="50308" //São paulo
				cInscMF:=alltrim(SA2->A2_INSCRM)
			endif
		
		endif
		
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		if SD1->(DbSeek((cAlias)->F1_FILIAL+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA))
			cAliqISS:=cvaltochar(SD1->D1_ALIQISS)
		endif
		
		cLin := Stuff(cLin,070,004, cAliqISS)//Alíquota
		cLin := Stuff(cLin,074,001, ALLTRIM((cAlias)->F1_P_ISSR))//ISS Retido
		cLin := Stuff(cLin,075,001, cTipoF)//Indicador de CPF/CNPJ do Prestador
		cLin := Stuff(cLin,076,014, alltrim(SA2->A2_CGC))//CPF ou CNPJ do Prestador
		cLin := Stuff(cLin,090,097, cInscMF)//Inscrição Municipal do Prestador
		cLin := Stuff(cLin,098,172, alltrim(SA2->A2_NOME))//Nome/ Razão Social do Prestador
		cLin := Stuff(cLin,173,003, "")//Tipo do Endereço do Prestador (Rua, Av, ...)
		cLin := Stuff(cLin,176,050, alltrim(SA2->A2_END))//Endereço do Prestador
		cLin := Stuff(cLin,226,010, "")//Número do Endereço do Prestador
		cLin := Stuff(cLin,236,030, alltrim(SA2->A2_ENDCOMP))//Complemento do Endereço do Prestador
		cLin := Stuff(cLin,266,030, alltrim(SA2->A2_BAIRRO))//Bairro do Prestador
		cLin := Stuff(cLin,296,050, alltrim(SA2->A2_MUN))//Cidade do Prestador
		cLin := Stuff(cLin,346,002, alltrim(SA2->A2_EST))//UF do Prestador
		cLin := Stuff(cLin,348,008, alltrim(SA2->A2_CEP))//CEP do Prestador
		cLin := Stuff(cLin,356,075, alltrim(SA2->A2_EMAIL))//Email do Prestador
		cLin := Stuff(cLin,431,001, ALLTRIM((cAlias)->F1_P_TPNFT))//Tipo de NFTS
		cLin := Stuff(cLin,432,001, ALLTRIM((cAlias)->F1_P_REGTB))//Regime de Tributação
		cLin := Stuff(cLin,433,008, "")//Data de Pagamento da Nota
		cLin += ""//Discriminação dos Serviços
		cLin += CHR(13)+CHR(10)//Caracter de Fim de linha
		
		     
		aAdd(aChaveLog, {(cAlias)->F1_FILIAL+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA,IIF(EMPTY(cLog),"1","2"),cLog})
        
		(cAlias)->STATUSZ59 := IIF(EMPTY(cLog),"1","2")
		
		//Se não deu erro na validação não inlcuo no arquivo
		if (cAlias)->STATUSZ59<>"2"
			cArq += cLin
		endif
		
		nlinhas++
		nValTot += (cAlias)->F1_VALBRUT
		nValDed += 0//(cAlias)->F1_P_VDED
	EndIf
    (cAlias)->(DbSkip())
EndDo

//Rodape         
cLin := Space(30)                                         
cLin := Stuff(cLin,01,01, "9")//Tipo de registro
cLin := Stuff(cLin,02,07, STRZERO(nlinhas,6))//Número de linhas de detalhe do arquivo
cLin := Stuff(cLin,09,15, STRZERO(VAL(STRTRAN(TRANSFORM(nValTot,"@E 999999999999.99"),",","")),15))//Valor total dos serviços contido no arquivo
cLin := Stuff(cLin,24,15, STRZERO(VAL(STRTRAN(TRANSFORM(nValDed,"@E 999999999999.99"),",","")),15))//Valor total das deduções contidas no arquivo
cLin := Stuff(cLin,39,40, CHR(13)+CHR(10))//Caractere de Fim de Linha

cArq += cLin

Return cArq//{cNomeArq,cArq}

/*
Metodo      : GravaRem
Classe      : 
Descrição   : Gravação do Arquivo de Remessa na Tabela de log
Autor       : Jean Victor Rocha
Data        : 09/09/2013
*/ 
*------------------------*
Static Function GravaRem()
*------------------------*   
If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif				                                
cQryTmp := "Select * From "+RETSQLNAME("Z59")
cQryTmp += " Where D_E_L_E_T_ <> '*'"
cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
cQryTmp += "       AND Z59_CHAVE = '"+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
    
TMP->(DbGoTop())
While TMP->(!EOF())
	Z59->(DbGoTo(TMP->R_E_C_N_O_))
	Z59->(RecLock("Z59",.F.))
	Z59->(DbDelete())
	Z59->(MsUnlock())
	TMP->(DbSkip())	
EndDo
                  
//Realiza a gravação
Z59->(RecLock("Z59",.T.))
Z59->Z59_FILIAL := xFilial("Z59")
Z59->Z59_ID     := GetSXeNum("Z59","Z59_ID")
Z59->Z59_DATA   := dDataBase
Z59->Z59_HORA   := Time()
Z59->Z59_USER   := cUserName
Z59->Z59_NOMARQ := aArq[1]
Z59->Z59_CONARQ := aArq[2]
Z59->Z59_ROTINA := "GTFAT005"
Z59->Z59_LOG    := aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][3]
Z59->Z59_SEQUEN := StrZero(1,3)
Z59->Z59_TABELA := "SF1"
Z59->Z59_ORDEM  := 1
Z59->Z59_CHAVE  := (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
Z59->Z59_TIPO   := aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][2]
Z59->(MsUnlock()) 

ConfirmSX8("Z59")

Return .T.

/*
Metodo      : ProcRet
Classe      : 
Descrição   : Processa retorno
Autor       : Jean Victor Rocha
Data        : 
*/ 
*------------------------*
Static Function ProcRet() 
*------------------------*
Local nPos := 0
Local aLinha := {}
Local cTitle:= "Selecione o diretório"
Local cFile := "Arquivos| *.txt|"
Local nDefaultMask := 0
Local nOptions:= GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

Private cArq := ""

cArq := cGetFile(cFile,cTitle,nDefaultMask,cArq,.T.,nOptions,.F.)+Space(200)

If !File(cArq)
	MsgInfo("Arquivo Invalido!","Grant Thornton Brasil")
	Return .F.
EndIf         

cTxt := cArq
While AT("\",cTxt) <> 0
	cTxt := SubStr(cTxt,AT("\",cTxt)+1,LEN(cTxt))
EndDo

FT_FUse(cArq) // Abre o arquivo
FT_FGOTO(nPos)    // Posiciona no inicio do arquivo
nLinDet := 0
nLinProc:= 0
While !FT_FEof() .AND. !EMPTY(FT_FReadln())
   	cLinha := FT_FReadLn()

	Do Case 
		Case SubStr(cLinha,1,1) == "1"//Cabeçalho
			//
		Case SubStr(cLinha,1,1) <> "1" .and. SubStr(cLinha,1,1) <> "9"//Detalhes
			LinDetRet(cLinha,cTxt)
			nLinDet ++
	EndCase
	FT_FSkip()//Proxima linha
Enddo
FT_FUse()//Fecha o arquivo

MsgInfo("Arquivo Processado com sucesso!"+CHR(13)+CHR(10)+"Linhas Lidas:"+ALLTRIM(STR(nLinDet))+" Gravadas:"+ALLTRIM(STR(nLinProc)),"Grant Thornton Brasil.")

Return .T.            

/*
Funcao      : LinDetRet
Parametros  : 
Retorno     : 
Objetivos   : Processa linha de retorno do Arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/
*------------------------------*
Static Function LinDetRet(cCont,cTxt)              
*------------------------------*
Local aAreaAnt := GETAREA()
Local cLog		:= ""
Local cDocNF 	:= SubStr(cCont,031,12)
Local cSerieNF	:= SubStr(cCont,026,05)
Local cEmissao	:= SubStr(cCont,043,08)
Local cValor	:= SubStr(cCont,437,15)

Local cCGCForn	:= SubStr(cCont,497,14)
              
//Busca e validação do Fornecedor
If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif				                                
cQryTmp := "Select * From "+RETSQLNAME("SA2")
cQryTmp += " Where D_E_L_E_T_ <> '*'"
cQryTmp += "      AND A2_CGC like '%"+AllTrim(cCGCForn)+"%'"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)

TMP->(DbGoTop()) 
If TMP->(!EOF())
	SA2->(DbSetOrder(1))
	SA2->(DbGoTo(TMP->R_E_C_N_O_))
Else
	RestArea(aAreaAnt)
	Return .T.
EndIf
//--------  

//Busca a NF
If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif				                                
cQryTmp := "Select * From "+RETSQLNAME("SF1")
cQryTmp += " Where D_E_L_E_T_ <> '*'"
cQryTmp += "       AND F1_FILIAL = '"+xFilial("SF1")+"'
cQryTmp += "       AND F1_DOC like '%"+ALLTRIM(STR(VAL(cDocNF)))+"%'
cQryTmp += "       AND F1_SERIE Like '%"+Right(cSerieNF,2)+"%'
cQryTmp += "       AND F1_FORNECE = '"+SA2->A2_COD+"'
cQryTmp += "       AND F1_LOJA = '"+SA2->A2_LOJA+"'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)

TMP->(DbGoTop()) 
If TMP->(!EOF())
	SF1->(DbSetOrder(1))
	SF1->(DbGoTo(TMP->R_E_C_N_O_))
Else              
	RestArea(aAreaAnt)
	Return .T.
EndIf
//--------


If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif				                                
cQryTmp := "Select * From "+RETSQLNAME("Z59")
cQryTmp += " Where D_E_L_E_T_ <> '*'"
cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
cQryTmp += "       AND Z59_CHAVE = '"+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
                
TMP->(DbGoTop())
While TMP->(!EOF())
	Z59->(DbGoTo(TMP->R_E_C_N_O_))
	Z59->(RecLock("Z59",.F.))
	Z59->(DbDelete())
	Z59->(MsUnlock())
	TMP->(DbSkip())	
EndDo

//Realiza a gravação
Z59->(RecLock("Z59",.T.))
Z59->Z59_FILIAL := xFilial("Z59")
Z59->Z59_ID     := GetSXeNum("Z59","Z59_ID")
Z59->Z59_DATA   := dDataBase
Z59->Z59_HORA   := Time()
Z59->Z59_USER   := cUserName
Z59->Z59_NOMARQ := cTxt
Z59->Z59_CONARQ := cCont
Z59->Z59_ROTINA := "GTFAT005"
Z59->Z59_LOG    := cLog
Z59->Z59_SEQUEN := StrZero(1,3)
Z59->Z59_TABELA := "SF1"
Z59->Z59_ORDEM  := 1
Z59->Z59_CHAVE  := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
Z59->Z59_TIPO   := IIF(EMPTY(cLog),"3","4")//Retorno; Retorno Rejeitado
Z59->(MsUnlock()) 
ConfirmSX8("Z59")
nLinProc++

RestArea(aAreaAnt)

//Atualiza a Tela Principal com a Cor do Status.
(cAlias)->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)))
(cAlias)->STATUSZ59 := "3"//Retorno Aceito.

Return .T.

/*
Funcao      : FAT005V
Parametros  : 
Retorno     : 
Objetivos   : Visualiza a NF.
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/
*-------------------------------------*
Static Function FAT005V(lAliasPadrao,oMeter2,oDlg2)
*-------------------------------------*
Local aAreaAnt := GETAREA()

Default lAliasPadrao := .T.

If lAliasPadrao
	cSeek := (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
	//Inicia a régua
	oMeter2:Set(0)
	oMeter2:Set(98) //posiciona no fim da regua
Else
	cSeek := aCoBrw1[oBrw1:oBrowse:NAT][1]+aCoBrw1[oBrw1:oBrowse:NAT][2]+aCoBrw1[oBrw1:oBrowse:NAT][3]+aCoBrw1[oBrw1:oBrowse:NAT][4]+aCoBrw1[oBrw1:oBrowse:NAT][5]
EndIf
 
Private aRotina := {}
aAdd(aRotina,{("Pesquisar"), "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
aAdd(aRotina,{("Visualizar"), "A103NFiscal", 0 , 2, 0, nil}) 		//"Visualizar"
    
SF1->(DbSetOrder(1))
SF1->(DbSeek(cSeek)) 

A103NFiscal("SF1",SF1->(RECNO()),2)

RestArea(aAreaAnt)
oDlg2:end()

Return .T.

/*
Metodo      : FAT005H
Classe      : 
Descrição   : Apresenta o Historico do Documento.
Autor       : Jean Victor Rocha
Data        : 
*/ 
*------------------------*
Static Function FAT005H() 
*------------------------*
Local aAreaAnt := GETAREA()
Local cQry := ""

Local aCoresHist:= {{"Z59_TIPO == '1'", "BR_VERDE"   	},;
					{"Z59_TIPO == '2'", "BR_VERMELHO"	},;
					{"Z59_TIPO == '3'", "BR_AZUL"		},;
					{"Z59_TIPO == '4'", "BR_LARANJA"	}} 
				    
Local aStruHist := {}        
	aAdd(aStruHist,{"CINTEGRA"	,"C",002,0})
	aAdd(aStruHist,{"ID"		,"N",003,0})
	aAdd(aStruHist,{"STATUSREG"	,"C",005,0})
	aAdd(aStruHist,{"Z59_DATA"	,"D",008,0})
	aAdd(aStruHist,{"Z59_HORA"	,"C",005,0})
	aAdd(aStruHist,{"Z59_USER"	,"C",040,0})
	aAdd(aStruHist,{"Z59_NOMARQ","C",060,0})
	aAdd(aStruHist,{"Z59_TIPO"	,"C",001,0})
	aAdd(aStruHist,{"Z59_CHAVE"	,"C",120,0})
	aAdd(aStruHist,{"Z59_LOG"	,"C",200,0})
	aAdd(aStruHist,{"R_E_C_N_O_","N",015,0})

Private aLegHist := {	{"BR_VERDE"   ,"Remessa Processada"	},;
		   		  		{"BR_VERMELHO","Falha na Remessa"	},;
				  		{"BR_AZUL"    ,"Retorno Processado"	},;
				  		{"BR_LARANJA" ,"Falha no Retorno"	}}

Private cMarcaHist   := GetMark() 

Private aCposHist := {}
	aAdd(aCposHist,{"cINTEGRA"	,"","[ ]"  		})
	aAdd(aCposHist,{"ID"		,"","Id"		})
	aAdd(aCposHist,{"STATUSREG"	,"","Status"	})
	aAdd(aCposHist,{"Z59_DATA"	,"","Data" 		})
	aAdd(aCposHist,{"Z59_HORA"	,"","Hora" 		})
	aAdd(aCposHist,{"Z59_USER"	,"","Usuario" 	})
	aAdd(aCposHist,{"Z59_NOMARQ","","Nome Arq." })
	aAdd(aCposHist,{"Z59_LOG"	,"","log" 		})

Private lInverte := .f.
	
If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif

cQry := "Select * From "+RETSQLNAME("Z59")
cQry += " Where Z59_ROTINA = 'GTFAT005'"
cQry += "       AND Z59_CHAVE = '"+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"
  
DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)              

TMP->(DbGoTop())     
If TMP->(EOF())
	MsgInfo("Sem historico para NF selecionada!","Grant Thornton Brasil")
	RestArea(aAreaAnt)
	Return .T.
EndIf

If Select("WRKTMP") > 0
	("WRKTMP")->(DbClosearea())
Endif

cArqTmp		:= CriaTrab(aStruHist,.T.)		
dbUseArea(.T.,__LocalDriver,cArqTmp,"WRKTMP",.F.,.F.)
dbCreateInd(cArqTmp+OrdBagExt(),"DTOS(Z59_DATA)+Z59_HORA", {|| "DTOS(Z59_DATA)+Z59_HORA"})
       
n:=1

While !(TMP->(Eof()))
	Z59->(DbGoTo(TMP->R_E_C_N_O_))
		
	RecLock("WRKTMP",.T.)                           
	WRKTMP->ID	:= n                    
	WRKTMP->STATUSREG	:= IIF(Z59->(Deleted()),"","ATIVO")
	WRKTMP->Z59_DATA	:= Z59->Z59_DATA
	WRKTMP->Z59_HORA	:= Z59->Z59_HORA
	WRKTMP->Z59_USER	:= Z59->Z59_USER
	WRKTMP->Z59_NOMARQ	:= Z59->Z59_NOMARQ
	WRKTMP->Z59_TIPO	:= Z59->Z59_TIPO
	WRKTMP->Z59_LOG		:= Z59->Z59_LOG
	WRKTMP->Z59_CHAVE	:= Z59->Z59_CHAVE
	WRKTMP->R_E_C_N_O_	:= TMP->R_E_C_N_O_
	WRKTMP->(MsUnLock())
	                
	n++
	
	TMP->(DbSkip())
Enddo

WRKTMP->(DbGoTop())
SetPrvt("oDlg1","oSay1","oBrw1","oSBtn1","oBtn1")
oDlg1      := MSDialog():New( 095,422,557,985,"Historico NFSe - Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"NF: "+(cAlias)->F1_DOC+"/"+(cAlias)->F1_SERIE+" FORN: "+(cAlias)->F1_FORNECE+"/"+(cAlias)->F1_LOJA},;
																										oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,224,008)
oBrw1      := MsSelect():New( "WRKTMP","cINTEGRA",,aCposHist,@lInverte,@cMarcaHist,{016,004,220,228},,, oDlg1,,aCoresHist)
oSBtn1     := SButton():New( 008,244,1,{|| oDlg1:End()},oDlg1,,"", )
oBtn1      := TButton():New( 032,232,"Gerar Arq. Rem",oDlg1,{|| FAT005A(.F.,"WRKTMP")},040,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 057,232,"Legenda",oDlg1,{|| BrwLegenda("Historico NFSe", "Legenda", aLegHist)},040,012,,,,.T.,,"",,,,.F. )
      
oDlg1:Activate(,,,.T.)
                  
RestArea(aAreaAnt)

Return .T.

/*
Metodo      : FAT005A
Classe      : 
Descrição   : Gera Arquivo fisico das seleções
Autor       : Jean Victor Rocha
Data        : 
*/ 
*------------------------*
Static Function FAT005A(lPadrao,cAliasH)
*------------------------*
Local aAreaAnt := GETAREA()
Local nHandle := 0
Local lGerado := .F.

Default lPadrao := .T.
Default cAliasH := cAlias

//GetDir() 

(cAliasH)->(DbGoTop())  
While (cAliasH)->(!EOF())
    If (cAliasH)->cINTEGRA <> Space(2)// cMarca     		
 		If Select("TMP") > 0
			("TMP")->(DbClosearea())
		Endif				                                
		cQryTmp := "Select * From "+RETSQLNAME("Z59")
		cQryTmp += " Where "
		If lPadrao         
			cQryTmp += "       D_E_L_E_T_ <> '*'"
			cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
			cQryTmp += "       AND Z59_CHAVE = '"+(cAliasH)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"
		Else
			cQryTmp += "       R_E_C_N_O_ = "+ALLTRIM(STR((cAliasH)->R_E_C_N_O_))
		EndIf
	
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
		
        TMP->(DbGoTop())
		If TMP->(!EOF()) .and. (!lPadrao .or. TMP->Z59_TIPO == "1")
			Z59->(DbGoTo(TMP->R_E_C_N_O_))
			
			If lPadrao  
				nHandle := MSFCREATE(cDir+alltrim(Z59->Z59_NOMARQ)+".TXT")
			Else 
				nHandle := MSFCREATE(cDir+ALLTRIM(STR((cAliasH)->ID))+"_"+alltrim(Z59->Z59_NOMARQ)+".TXT")
			EndIf
			
			If FERROR() # 0 .Or. nHandle < 0
				MsgAlert("Houve erro na criação do(s) arquivo(s), operação Abortada!","Grant Thornton Brasil")
				FClose(nHandle)
				RestArea(aAreaAnt)
				Return(.f.)
			EndIf		
			Fwrite(nHandle, Z59->Z59_CONARQ)
			FClose(nHandle)
			lGerado := .T.
			
			exit
		EndIf
		
		(cAliasH)->cINTEGRA := Space(2)
	EndIf 
	
	(cAliasH)->(DbSkip())
EndDo            
                       
If lPadrao
	If lGerado             
		MsgInfo("Geração de arquivo(s) de Remessa finalizada!","Grant Thornton Brasil")
	Else 
		MsgInfo("Não foi encontrada Remessas Aceitas para as NFs selecionadas!","Grant Thornton Brasil")
	EndIf
Else
	If lGerado             
		MsgInfo("Geração de arquivo(s) finalizada!","Grant Thornton Brasil")
	EndIf
EndIf
	
RestArea(aAreaAnt)

Return .T.                

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cDir
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDir := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

Return
                         
/*
Funcao      : GeraRem
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para Informações adicionais nos itens
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function GeraRem(oTela)
*-----------------------*
Local NOPCAO := 0
Local aAreaAnt := GETAREA()
Local nOpc 		:= GD_UPDATE//GD_INSERT+GD_DELETE+GD_UPDATE
Local aSize 	:= MsAdvSize()
Local aButtons := {}
Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0
                 
//Aadd(aHoBrw1,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"","" } )
Aadd(aHoBrw1,{"Filial"		,"F1_FILIAL"	,""	,2,0,"","","C","","" } )
Aadd(aHoBrw1,{"Doc. "		,"F1_DOC"		,""	,9,0,"","","C","","" } )
Aadd(aHoBrw1,{"Serie"		,"F1_SERIE"		,""	,3,0,"","","C","","" } )
Aadd(aHoBrw1,{"Forn."		,"F1_FORNECE"	,""	,6,0,"","","C","","" } )
Aadd(aHoBrw1,{"Loja"		,"F1_LOJA"		,""	,2,0,"","","C","","" } )
Aadd(aHoBrw1,{"Tp. Doc"		,"TPDOC"		,""	,2,0,"","","C","","","01=Dispensado Emissão Doc. Fiscal;02=Com Emissao Doc. Fiscal Autorizado Munic.;03=Sem Emissao Doc. Fiscal Embora Obrigatorio" } )
Aadd(aHoBrw1,{"Trib. Serv."	,"TRIBSERV"		,""	,1,0,"","","C","","","T=Operação Normal;I=Imune;J=Iss Suspenso por Decisão Judicial" } )
Aadd(aHoBrw1,{"Deduções"	,"VLRDEDU"		,"@E 999,999,999,999.99"	,15,2,"","","N","","" } )
Aadd(aHoBrw1,{"ISS Retido"	,"ISSRET"		,""	,1,0,"","","C","","","1=Iss Retido pelo Tomador;2=NFTS sem ISS retido;3=ISS retido pelo intermediario" } )
Aadd(aHoBrw1,{"Tp. NFTS"	,"TPNFTS"		,""	,1,0,"","","C","","","1=Nota Fiscal do Tomador;2=Nota Fiscal do Intermediario" } )
Aadd(aHoBrw1,{"Reg. Trib."	,"REGTRIB"		,""	,1,0,"","","C","","","0=Normal;4=Simples Nacional;5=Microempreendedor Individual - MEI" } )

if (cAlias)->STATUSZ59<>'1'      
	aAlter := {"TPDOC","TRIBSERV","VLRDEDU","ISSRET","TPNFTS","REGTRIB"}
else
	aAlter := {}
endif

noBrw1 := 5

SetPrvt("oDlgRem","oBrw1")
  
If !MCoBrw1() 
	//MsgInfo("Sem NFs selecionadas!","Grant Thornton Brasil")
	RestArea(aAreaAnt)
	Return .F.
EndIf

//aadd(aButtons,{"BMPVISUAL"	,{|| FAT005V(.F.)},"Visualiza Doc."	,"Visualiza Doc."	,{|| .T.}})

//DEFINE MSDIALOG oDlgRem TITLE "Informações complementares" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
                        
	//oBrw1 := MsNewGetDados():New(004,004,(aSize[6]/2)-15,aSize[5]/2,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlgRem,aHoBrw1,aCoBrw1 )
	oBrw1 := MsNewGetDados():New(004,004,(aSize[6]/2)-55,aSize[5]/2,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99,'AllwaysTrue()','','AllwaysTrue()',oTela,aHoBrw1,aCoBrw1 )

     
//ACTIVATE MSDIALOG oDlgRem ON INIT EnchoiceBar(oDlgRem,{||nOpcao:=1,oDlgRem:End()},{|| (nOpcao:=2,oDlgRem:End())},,aButtons) CENTERED
                  
//If nOpcao == 1
	For i := 1 to Len(aCoBrw1)
		cSeek := aCoBrw1[i][1]+aCoBrw1[i][2]+aCoBrw1[i][3]+aCoBrw1[i][4]+aCoBrw1[i][5]	
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(cSeek)) 
		//Gravar campos Customizados
		SF1->(RecLock("SF1",.F.))
		SF1->F1_P_TPDOC 	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TPDOC"} )]
		SF1->F1_P_TRIBS 	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TRIBSERV"} )]
		SF1->F1_P_VDED		:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "VLRDEDU"} )]
		SF1->F1_P_ISSR		:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "ISSRET"} )]
		SF1->F1_P_TPNFTS	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TPNFTS"} )]
		SF1->F1_P_REGTB		:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "REGTRIB"} )]
		SF1->(MsUnlock())
		         		
		//Atualizar os Campos da Work Principal
		RestArea(aAreaAnt)
		(cAlias)->(DbSeek(cSeek))
		/*(cAlias)->F1_P_TPDOC	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TPDOC"} )]
		(cAlias)->F1_P_TRIBS	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TRIBSERV"} )]
		(cAlias)->F1_P_VDED		:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "VLRDEDU"} )]
		(cAlias)->F1_P_ISSR		:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "ISSRET"} )]
		(cAlias)->F1_P_TPNFTS	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "TPNFTS"} )]
		(cAlias)->F1_P_REGTB	:= aCoBrw1[i][aScan(aHoBrw1, {|x| x[2] == "REGTRIB"} )]
*/
	Next i	        

//	GeraRemMain()
	
//EndIf

RestArea(aAreaAnt)

Return .T.

*-----------------------*
Static Function MCoBrw1()
*-----------------------*
Local lRet		:=.F.
Local aAux 		:= {}
Local lAprov	:=.F.
Local lRejei	:=.F.
                                  
(cAlias)->(DbGoTop())  
While (cAlias)->(!EOF())
    
    If (cAlias)->cINTEGRA == cMarca .and. (cAlias)->STATUSZ59 <> "3"//Retorno Recebido.
	    
	    Aadd(aCoBrw1,{	(cAlias)->F1_FILIAL,;
						(cAlias)->F1_DOC,;
						(cAlias)->F1_SERIE,;
						(cAlias)->F1_FORNECE,;
						(cAlias)->F1_LOJA,;
						"02",;
						"T",;
						0,;
						"2",;
						"1",;
						"0",;
	    				.F.})
	    lRet := .T.

	    if (cAlias)->STATUSZ59=="1"
			lAprov:=.T.
	    endif

	    if (cAlias)->STATUSZ59=="2"
			lRejei:=.T.
	    endif
	EndIf
    
    (cAlias)->(DbSkip())
EndDo

if !lRet
	MsgInfo("Sem NFs selecionadas!","Grant Thornton Brasil")
endif

if lAprov .AND. lRejei
	MsgInfo("Não é possível selecionar registros aprovados e rejeitados ao mesmo tempo!","Grant Thornton Brasil")
	lRet := .F.
endif

Return lRet

/*
Funcao      : InWizard()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial para o usuário informar os dados básicos para o processamento
Autor       : Matheus Massarotto
Data/Hora   : 24/10/2013
*/
Static function InWizard()
Local oWizard
Local lWiz	:= .F.
Local aSize     := {}
Local aObjects	:= {}

Local aCores    := {{"STATUSZ59 == '1'", "BR_VERDE"   	},;
					{"STATUSZ59 == '2'", "BR_VERMELHO"	},;
					{"STATUSZ59 == '3'", "BR_AZUL"		},;
					{"STATUSZ59 == '4'", "BR_LARANJA"	},;
					{"STATUSZ59 == '5'", "BR_BRANCO"	}}
					
Private cAlias := "TMPNFTS"

Private oBrowse
Private cDir 	:= ""

cGet1 := Space(5)
dGet2 := CTOD("  /  /  ")
dGet3 := CTOD("  /  /  ")
cGet4 := Space(3)
//cGet5 := "2"
cGet5:=space(30)
cGet6:=space(30)

cGet2_1:=space(200)
aItens1_1:={"São Paulo"}
cGet7:=aItens1_1[1]

cMemo1_1:=""

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()
AAdd( aObjects, { 100, 60, .T., .T. } )
AAdd( aObjects, { 100, 40, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

oLayer 	:= FWLayer():new()

//DEFINE WIZARD oWizard TITLE "NFTS" HEADER "Nota Fiscal Eletrônica do Tomador/Intermediário de Serviços" MESSAGE " ";		
//TEXT "Esta rotina tem como objetivo processar a(s) Nota(s) Fiscal(is) do Tomador/Intermediário - NFTS (emissão em lote) para a Prefeitura em arquivos no formato texto " PANEL;
//NEXT {|| .T.} FINISH {|| .T.}

chTitle	:= "NFTS"
chMsg	:= "Nota Fiscal Eletrônica do Tomador/Intermediário de Serviços"
cTitle	:= ""

cText:=CRLF
cText+="1. Introdução"+CRLF
cText+=+CRLF
cText+="A Nota Fiscal Eletrônica do Tomador/Intermediário de Serviços – NFTS foi instituída pela Lei Nº 15.406, "+CRLF
cText+="de 8 de julho de 2011, e se destina à declaração dos serviços tomados ou intermediados pelas pessoas "+CRLF
cText+="jurídicas e pelos condomínios edilícios residenciais ou comerciais por ocasião da contratação de "+CRLF
cText+="serviços. "+CRLF
cText+=+CRLF
cText+="A emissão da Nota Fiscal do Tomador/Intermediário - NFTS (emissão em lote) está integrada ao Sistema "+CRLF
cText+="da Nota Fiscal de Serviços Eletrônica – NFS-e, permitindo que sejam transferidas informações dos "+CRLF
cText+="contribuintes para a Prefeitura em arquivos no formato texto. Tais arquivos devem atender a um lay-out "+CRLF
cText+="pré-definido, apresentado neste documento. "+CRLF
cText+=+CRLF 
cText+="A NFTS poderá ser emitida: "+CRLF
cText+=+CRLF
cText+="a) Pelo tomador dos serviços, no caso de serviços tomados; "+CRLF
cText+=+CRLF
cText+="b) Pelo intermediário dos serviços, apenas nas situações previstas no art. 118 do Decreto nº 53.151, de "+CRLF
cText+="17 de maio de 2012 e na forma, prazo e condições estabelecidas pela Secretaria Municipal de Finanças. "
cText+=+CRLF+CRLF+CRLF+CRLF
cText+= "Esta rotina tem como objetivo processar a(s) Nota(s) Fiscal(is) do Tomador/Intermediário - NFTS (emissão em lote) para a Prefeitura em arquivos no formato texto "

bNext	:= {|| .T.}
bFinish	:= {|| .T.}
lPanel	:= .T.
cResHead	:="fw_totvs_logo_61x27.png"
bExecute 	:= {||.T.}
lNoFirst	:= .T. 
aCoord		:= {aSize[7],0,aSize[6],aSize[5]}

oWizard:=ApWizard():New (  chTitle  ,  chMsg  ,  cTitle  ,  cText  ,  bNext  ,  bFinish  ,  lPanel  ,  cResHead  ,  bExecute  ,  lNoFirst , aCoord   )

//CREATE PANEL oWizard HEADER "Parâmetros" MESSAGE "Selecione os parâmetros para auxílio ao processamento." PANEL;
//BACK {|| .T.} NEXT {|| } FINISH {|| (lWiz := .T., .T.) } EXEC {|| .T.}	
cTitle	:= "Parâmetros"
cMsg	:= "Selecione os parâmetros para auxílio ao processamento."
bBack 	:= {|| .T.}
bNext   := {|| iif(empty(cGet2_1),(MsgInfo("Preencha o local onde o arquivo será salvo!","Grant Thornton Brasil"),.F.) ,(Barpross(oBrowse,oWizard),.T.) )}

//bNext   := {|| .T.}
bFinish	:= {||}
lPanel	:= .T.
bExecute:= {|| .T.}

//Painel 2
oWizard:NewPanel ( cTitle , cMsg , bBack , bNext , bFinish , lPanel , bExecute )

nColIni1:=aPosObj[1][4]/4
nColIni2:=aPosObj[2][4]/4

oGrp1      := TGroup():New( aPosObj[1][1],nColIni1,aPosObj[1][3],aPosObj[1][4] - nColIni1 - 100 ,"",oWizard:oMPanel[2],CLR_BLACK,CLR_WHITE,.T.,.F. ) 


//oSay1      := TSay():New( 016,nColIni+008,{||"Tp. Documento"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay2      := TSay():New( 032,nColIni1+008,{||"Dt. Emissão De:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay3      := TSay():New( 048,nColIni1+008,{||"Dt. Emissão Ate:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay4      := TSay():New( 064,nColIni1+008,{||"Série:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
//oSay5      := TSay():New( 080,nColIni+008,{||"TES Atualiza Estoque"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay5      	:= TSay():New( 080,nColIni1+008,{||"CFOP:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay6      	:= TSay():New( 096,nColIni1+008,{||"Espécie:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay7     	:= TSay():New( 112,nColIni1+008,{||"Layout:"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
//oGet1      := TGet():New( 016,nColIni+088,{|u|if(PCount()>0,cGet1:=u,cGet1)},oWizard:oMPanel[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2      := TGet():New( 032,nColIni1+088,{|u|if(PCount()>0,dGet2:=u,dGet2)},oWizard:oMPanel[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet3      := TGet():New( 048,nColIni1+088,{|u|if(PCount()>0,dGet3:=u,dGet3)},oWizard:oMPanel[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet4      := TGet():New( 064,nColIni1+088,{|u|if(PCount()>0,cGet4:=u,cGet4)},oWizard:oMPanel[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//oCBox1     := TComboBox():New(080,nColIni+088,{|u|if(PCount()>0,cGet5:=u,cGet5)},{"1=Sim","2=Não"},060,010,oWizard:oMPanel[2],,,,,,.T.,,,,,,,,,"cGet5")
oGet5      := TGet():New( 080,nColIni1+088,{|u|if(PCount()>0,cGet5:=u,cGet5)},oWizard:oMPanel[2],100,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet6      := TGet():New( 096,nColIni1+088,{|u|if(PCount()>0,cGet6:=u,cGet6)},oWizard:oMPanel[2],100,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

//Indica o bloco de código que será executado quando o objeto ganha foco.
oGet2:bGotFocus:={||cMemo1_1:="Informe a data de emissão inicial."}
oGet3:bGotFocus:={||cMemo1_1:="Informe a data de emissão final."}
oGet4:bGotFocus:={||cMemo1_1:="Informe a série da nota fiscal."}
oGet5:bGotFocus:={||cMemo1_1:="Informe o(s) CFOP(s) para o filtro, separe com ;(ponto e vírgula)"}
oGet6:bGotFocus:={||cMemo1_1:="Informe a(s) espécie(s) para o filtro, separe com ;(ponto e vírgula)"}


oCBox1_1	:= TComboBox():New(112,nColIni1+088,{|u|if(PCount()>0,cGet7:=u,cGet7)},aItens1_1,100,010,oWizard:oMPanel[2],,,,,,.T.,,,,,,,,,"cGet7")

oGrp1_1      := TGroup():New( aPosObj[1][1],aPosObj[1][4] - nColIni1 - 99,aPosObj[1][3],aPosObj[1][4] - nColIni1 ,"",oWizard:oMPanel[2],CLR_BLACK,CLR_WHITE,.T.,.F. ) 

//oMemo1_1	:= tMultiget():New(128,nColIni1+008,{|u|if(Pcount()>0,cMemo1_1:=u,cMemo1_1)},oWizard:oMPanel[2],240,25,,,,,,.T.)

oMemo1_1	:= tMultiget():New( aPosObj[1][1]+5 , (aPosObj[1][4] - nColIni1 - 99)+005,{|u|if(Pcount()>0,cMemo1_1:=u,cMemo1_1)},oWizard:oMPanel[2],88,143,,,,,,.T.)

oMemo1_1:Disable()


oGrp2      := TGroup():New( aPosObj[2][1],nColIni2,aPosObj[2][3]-50,aPosObj[2][4]- nColIni2,"",oWizard:oMPanel[2],CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay2_1     := TSay():New( aPosObj[2][1]+17,nColIni2+008,{||"Salvar em?"},oWizard:oMPanel[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oGet2_1		:= TGet():New(aPosObj[2][1]+15,nColIni2+088,{|u| if(PCount()>0,cDir:=cGet2_1:=u,cDir:=cGet2_1)}, oWizard:oMPanel[2],150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2_1')

//oTButton2 	:= TButton():New( aPosObj[2][1]+15,nColIni2+248, "...",oWizard:oMPanel[2],{||AbreArq(@cGet2_1,oGet2_1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
oTButton3 := TBtnBmp2():New( aPosObj[2][3]+(aPosObj[2][1]/2)+3,nColIni2+248+400,25,25, 'FOLDER12' , , , , {||AbreArq(@cGet2_1,oGet2_1)}, oWizard:oMPanel[2], , ,.T.,.T.)//oTButton3 := TBtnBmp2():New( aPosObj[2][1]+190,nColIni2+248+390,25,25, 'FOLDER12' , , , , {||AbreArq(@cGet2_1,oGet2_1)}, oWizard:oMPanel[2], , ,.T.,.T.)
//oTButton2:nTop:=aPosObj[2][1]+15 	//Para ajustar a cordenada do botão
//oTButton2:nLeft:=nColIni2+248		//Para ajustar a cordenada do botão
	
oGet2_1:Disable()


cTitle	:= "Seleção de documento(s) a ser(em) processado(s)"
cMsg	:= ""
bBack 	:= {|| iif(MsgYesNo("Atenção, toda marcação será desfeita!"+CRLF+"Tem certeza que deseja voltar?"),.T.,.F.)}
bNext   := {||GeraRem(oWizard:oMPanel[4])}
bFinish	:= {||.T.}
lPanel	:= .T.
bExecute:= {|| .T.}

//Painel 3             
oWizard:NewPanel ( cTitle , cMsg , bBack , bNext , bFinish , lPanel , bExecute )


//Criação do temporário
aCpos := {}
aAdd(aCpos,{"cINTEGRA","", })
			
SX3->(DbSetOrder(1))
SX3->(DbSeek("SF1")) 
While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SF1"
	If SX3->X3_BROWSE == "S"
		aAdd(aCpos,{SX3->X3_CAMPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO)})
	EndIf	
	SX3->(DbSkip())
EndDo

aStruQry := SF1->(dbStruct())

aAdd(aStruQry,{"F4_ESTOQUE","C",1,0})

aAdd(aStruQry,{})
aIns(aStruQry,1)
aStruQry[1] := {"CINTEGRA","C",2,0}

aAdd(aStruQry,{"F4_CODIGO"	,"C",3,0})
aAdd(aStruQry,{"STATUSZ59"	,"C",1,0})
aAdd(aStruQry,{"RECZ59"		,"N",6,0})

cArqTmp		:= CriaTrab(aStruQry,.T.)		

if select(cAlias)>0
	(cAlias)->(DbCloseArea())
endif

dbUseArea(.T.,__LocalDriver,cArqTmp,cAlias,.F.,.F.)
dbCreateInd(cArqTmp+OrdBagExt(),"F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA", {|| "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA"})
	
	//Criação do browse
	Brow(oWizard:oMPanel[3],aCpos,@oBrowse)


cTitle	:= "Complemento de Nota"
cMsg	:= ""
bBack 	:= {|| .T.}
bNext   := {|| }
bFinish	:= {||(lWiz := .T., .T.)}
lPanel	:= .T.
bExecute:= {|| .T.}

//Painel 4             
oWizard:NewPanel ( cTitle , cMsg , bBack , bNext , bFinish , lPanel , bExecute )



//--
oWizard:oDlg:lEscClose := .F.
//oWizard:OMPANEL[1]:OWND:LMAXIMIZED:=.T.
//oWizard:OMPANEL[2]:OWND:LMAXIMIZED:=.T.

//ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. } 
lCenter	:=.T.
bValid	:= {|| .T.}
bInit	:= {|| .T.}
bWhen	:= {|| .T.} 

aCordAnt:={oWizard:ODLG:NLEFT,oWizard:ODLG:NTOP,oWizard:ODLG:NRIGHT,oWizard:ODLG:NHEIGHT}

oWizard:Activate ( lCenter , bValid , bInit , bWhen )


if lWiz

GeraRemMain()

endif

Return


/*
Funcao      : AbreArq()
Parametros  : 
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
Autor       : Matheus Massarotto
Data/Hora   : 24/10/2013	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet2,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY

//Exibe tela para gravar o arquivo.
cGet2 := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return


/*
Funcao      : Brow()
Parametros  : oMeter
Retorno     : 
Objetivos   : Função o browse
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*-------------------------------------------*
Static function Brow(oWin,aCpos,oBrowse)
*-------------------------------------------*
Local oTBtnBmp1,oTBar
//Local cMarca   := GetMark() 
// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS cAlias OF oWin			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || IIF(cINTEGRA==cMarca,'LBOK','LBNO') } DOUBLECLICK { |oBrowse| RecLock(cAlias,.F.), iif(empty(cINTEGRA),cINTEGRA:=cMarca,cINTEGRA:='') , (cAlias)->(MsUnlock())  /*Função que atualiza a regra*/ }  OF oBrowse

// Adiciona as colunas do Browse	   	
//ADD COLUMN oColumn DATA { || TIPO 		} TITLE "Tipo"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 20 OF oBrowse		

//Adiciona coluna para status
ADD STATUSCOLUMN oColumn DATA { || iif(STATUSZ59=='1','BR_VERDE',(iif(STATUSZ59=='2','BR_VERMELHO',iif(STATUSZ59=='3','BR_AZUL',iif(STATUSZ59=='4','BR_LARANJA',iif(STATUSZ59=='5','BR_BRANCO',) ) ) ) ) ) } DOUBLECLICK { |oBrowse| /* Função executada no duplo clique na coluna*/ } OF oBrowse

//for i:=2 to len(aCpos)
//	ADD COLUMN oColumn DATA { || aCpos[i][1] 		} TITLE aCpos[i][3]   			DOUBLECLICK  {||  }	ALIGN 1 SIZE aCpos[i][2] OF oBrowse		
//next

ADD COLUMN oColumn DATA { || F1_DOC   	} TITLE 'Numero'      DOUBLECLICK  {||  } ALIGN 1 SIZE 9 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_SERIE   } TITLE 'Serie'	      DOUBLECLICK  {||  } ALIGN 1 SIZE 3 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_FORNECE } TITLE 'Fornecedor'  DOUBLECLICK  {||  } ALIGN 1 SIZE 6 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_LOJA   	} TITLE 'Loja'	      DOUBLECLICK  {||  } ALIGN 1 SIZE 2 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_COND   	} TITLE 'Cond. Pagto' DOUBLECLICK  {||  } ALIGN 1 SIZE 3 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_HAWB   	} TITLE 'No. Conhec.' DOUBLECLICK  {||  } ALIGN 1 SIZE 17 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_USERLGA } TITLE 'Log de Alter'DOUBLECLICK  {||  } ALIGN 1 SIZE 17 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_USERLGI } TITLE 'Log de Inclu'DOUBLECLICK  {||  } ALIGN 1 SIZE 17 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_NUMRA   } TITLE 'Funcionário' DOUBLECLICK  {||  } ALIGN 1 SIZE 6 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_DOCFOL  } TITLE 'Doc.Folha'   DOUBLECLICK  {||  } ALIGN 1 SIZE 9 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_VERBAFO } TITLE 'Verba Folha' DOUBLECLICK  {||  } ALIGN 1 SIZE 9 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_BASEPS3 } TITLE 'Bs. Pis ST'  DOUBLECLICK  {||  } ALIGN 1 SIZE 14 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_VALPS3  } TITLE 'Vl. Pis ST'  DOUBLECLICK  {||  } ALIGN 1 SIZE 14 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_BASECF3 } TITLE 'Bs. Cof ST'  DOUBLECLICK  {||  } ALIGN 1 SIZE 14 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_VALCF3  } TITLE 'Vl. Cof ST'  DOUBLECLICK  {||  } ALIGN 1 SIZE 14 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_NFELETR } TITLE 'NF Eletr.'   DOUBLECLICK  {||  } ALIGN 1 SIZE 9 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_EMINFE  } TITLE 'Emissão NF-e'DOUBLECLICK  {||  } ALIGN 1 SIZE 8 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_CODNFE  } TITLE 'Cd.Ver. NF-e'DOUBLECLICK  {||  } ALIGN 1 SIZE 50 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_CREDNFE } TITLE 'Créd. Conced'DOUBLECLICK  {||  } ALIGN 1 SIZE 16 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_TPNFEXP } TITLE 'NF Exp.'     DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_TPFRETE } TITLE 'Tipo de fret'DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_RECOPI  } TITLE 'Flag RECOPI' DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_TPCTE   } TITLE 'Tipo de CT-e'DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  

ADD COLUMN oColumn DATA { || F1_P_TPDOC } TITLE 'Tp Documento'DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_TRIBS } TITLE 'Tributo serv'DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_VDED  } TITLE 'Vlr Deducoes'DOUBLECLICK  {||  } ALIGN 1 SIZE 14 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_ISSR  } TITLE 'ISS Retido'  DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_TPNFT } TITLE 'Tipo NFTS'   DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_TPNFT } TITLE 'Tipo NFTS'   DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse  
ADD COLUMN oColumn DATA { || F1_P_REGTB } TITLE 'Regime tribu'DOUBLECLICK  {||  } ALIGN 1 SIZE 1 OF oBrowse

//ADD COLUMN oColumn DATA { || F1_NUMAIDF } TITLE 'N. AIDF'     DOUBLECLICK  {||  } ALIGN 1 SIZE 7 OF oBrowse  
//ADD COLUMN oColumn DATA { || F1_ANOAIDF } TITLE 'Ano AIDF'    DOUBLECLICK  {||  } ALIGN 1 SIZE 4 OF oBrowse  


//Bara de botões do browse esquerdo
oTBar := TBar():New( oWin,45,32,.T.,,,,.F. )
oTBtnBmp1 := TBtnBmp() :NewBar('SVM',,,,'Legenda',{||FAT005L()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Legenda"  

oTBtnBmp2 := TBtnBmp() :NewBar('BMPVISUAL',,,,'Visualizar Doc.',{||WaitAxVi()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp2:cTooltip:="Visualizar Doc."  

oTBtnBmp3 := TBtnBmp() :NewBar('HISTORIC',,,,'Historico',{||VerLog()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp3:cTooltip:="Historico"  

//oTBtnBmp4 := TBtnBmp() :NewBar('SDURECALL',,,,'Transmitir',{||GeraRem()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp4:cTooltip:="Transmitir"  

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse


Return(.T.)

/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	15:14
*/
*----------------------------------------*
Static Function Barpross(oBrowse,oWizard)
*----------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.
Local oObjAux 	:= oWizard:GetPanel(2)
    
	//Desabilito a tela onde a barra de processamento esá sendo executada
	oObjAux:Disable()
	oObjAux:Refresh()

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=BuscaDados(oMeter,oDlg1,oBrowse,oWizard),oObjAux:Enable())
	  
	//***********************************************************

Return(lRet)


/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 11/11/2013	15:14
*/
*-------------------------------------------------*
Static Function WaitAxVi()
*-------------------------------------------------*
Local oDlg2
Local oMeter2
Local nMeter2	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg2 TITLE "Abrindo..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter2 := 0
	    oMeter2 := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},100,oDlg2,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=FAT005V(.T.,oMeter2,oDlg2))
	  
	//*************************************

Return(lRet)  

*-----------------------*
Static Function VerLog()
*-----------------------*
Local l103Inclui	:= .F.


PRIVATE l103Class   := .F.
PRIVATE aCols		:= {}
PRIVATE aHeader		:= {}
PRIVATE aBackSD1    := {}

//INCLUI := .F.

SF1->(DbSetOrder(1))
SF1->(DbSeek((cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)))

DbSelectArea("SD1")
DbSetOrder(1)
MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo		:= IIf(l103Inclui,CriaVar("F1_TIPO",.F.),SF1->F1_TIPO)
cFormul		:= IIf(l103Inclui,CriaVar("F1_FORMUL",.F.),SF1->F1_FORMUL)
cNFiscal	:= IIf(l103Inclui,CriaVar("F1_DOC"),SF1->F1_DOC)
cSerie		:= IIf(l103Inclui,CriaVar("F1_SERIE"),SF1->F1_SERIE)
dDEmissao	:= IIf(l103Inclui,CriaVar("F1_EMISSAO"),SF1->F1_EMISSAO)
cA100For	:= IIf(l103Inclui,CriaVar("F1_FORNECE",.F.),SF1->F1_FORNECE)
cLoja		:= IIf(l103Inclui,CriaVar("F1_LOJA",.F.),SF1->F1_LOJA)
cEspecie	:= IIf(l103Inclui,CriaVar("F1_ESPECIE"),SF1->F1_ESPECIE)
cCondicao	:= IIf(l103Inclui,CriaVar("F1_COND"),SF1->F1_COND)
cUfOrig		:= IIf(l103Inclui,CriaVar("F1_EST"),SF1->F1_EST)
cRecIss		:= IIf(l103Inclui,CriaVar("F1_RECISS"),SF1->F1_RECISS)	

aSizeAut	:= MsAdvSize(,.F.,400)
l103Visual := .T.
l103Class  := .F.
nPosGetLoja   := IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))

			aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{{8,35,75,100,144,170,210,226},;
				{8,35,75,100,nPosGetLoja,144,170,210,226},;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205},;
				{005,035,075,105,145,175,215,245},;
				{11,35,80,110,165,190}})

//{8,35,75,100,194,220,260,280}
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlgLog","oGrp1","oGrp2","oGrp3")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 139,353,539,1448,"Hitórico",,,.F.,,,,,,.T.,,,.T. )



//Grupo 1 - Cabeçalho da nota
oGrp1      := TGroup():New( 004,004,056,536,"Nota Fiscal",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

    //Rotina padrão para montagem do cabeçalho da nota
	//aPosGet[1] == colunas dos campos de cima
	//aPosGet[2] == colunas dos campos de baixo
	//terceiro array ==  linha inicial
	NfeCabDoc(oDlg1,{aPosGet[1],aPosGet[2],{10,0,0,0}},Nil,.T.)

//Grupo 2 - Itens da nota
oGrp2      := TGroup():New( 064,004,128,536,"Itens",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do aHeader                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nUsado:=0
			
			DbSelectArea("SX3")
			DbSetOrder(1)
			MsSeek("SD1")
			While ( !EOF() .And. SX3->X3_ARQUIVO == "SD1" )
				If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
					aadd(aHeader,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT })
					
						nUsado++
				EndIf
				DbSelectArea("SX3")
				dbSkip()
			EndDo
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem do aCols com os dados do SD1                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			aCols:={}
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			While SD1->(!eof()) .AND. SD1->D1_FILIAL== xFilial("SD1") .And. ;
						SD1->D1_DOC == SF1->F1_DOC .And. ;
						SD1->D1_SERIE == SF1->F1_SERIE .And. ;
						SD1->D1_FORNECE == SF1->F1_FORNECE .And. ;
						SD1->D1_LOJA == SF1->F1_LOJA 
			
				AADD(aCols,Array(nUsado+1))
					For nX:=1 to nUsado
						aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
					Next
				aCols[Len(aCols),nUsado+1]:=.F.
				SD1->(dbSkip())
			Enddo

	nOpcX:= 2

	oGetDados := MSGetDados():New(73,08,125,527,nOpcx,'A103LinOk','A103TudOk','+D1_ITEM',!l103Visual,,,,IIf(l103Class,Len(aCols),999),,,,IIf(l103Class,'AllwaysFalse()',"NfeDelItem"),oDlg1)

//Grupo 3 - LOG
oGrp3      := TGroup():New( 136,004,188,536,"Log",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

/*
Private oMemo , cMemo:= space(50)

	oMemo:= tMultiget():New(143,08,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oDlg1,5270,40,,,,,,.T.)
	oMemo:Disable()
*/

//BuscHist(oGrp3)

aStruHist := {}        
aAdd(aStruHist,{"Z59_DATA"	,"D",008,0})
aAdd(aStruHist,{"Z59_HORA"	,"C",005,0})
aAdd(aStruHist,{"Z59_USER"	,"C",040,0})
aAdd(aStruHist,{"Z59_NOMARQ","C",060,0})
aAdd(aStruHist,{"Z59_TIPO"	,"C",001,0})
aAdd(aStruHist,{"Z59_LOG"	,"C",200,0})
	
If Select("TRBLOG") > 0
	("TRBLOG")->(DbClosearea())
Endif

cArqTmp		:= CriaTrab(aStruHist,.T.)		
dbUseArea(.T.,,cArqTmp,"TRBLOG",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
IndRegua("TRBLOG",cIndex,"DTOS(Z59_DATA)+Z59_HORA",,,"Selecionando Registro...")  

lInverte := .f.
cMarcaHist   := GetMark() 

aCoresHist:= {{"Z59_TIPO == '1'", "BR_VERDE"   	},;
					{"Z59_TIPO == '2'", "BR_VERMELHO"	},;
					{"Z59_TIPO == '3'", "BR_AZUL"		},;
					{"Z59_TIPO == '4'", "BR_LARANJA"	}} 

aCposHist := {}
aAdd(aCposHist,{"Z59_DATA"	,"","Data" 		})
aAdd(aCposHist,{"Z59_HORA"	,"","Hora" 		})
aAdd(aCposHist,{"Z59_USER"	,"","Usuario" 	})
aAdd(aCposHist,{"Z59_NOMARQ","","Nome Arq." })
aAdd(aCposHist,{"Z59_LOG"	,"","log" 		})
						
oBrw1      := MsSelect():New( "TRBLOG","cINTEGRA",,aCposHist,@lInverte,@cMarcaHist,{143,008,185,527},,, oGrp3,,aCoresHist)

//No init carrego a função para preenher o temporário com os logs
oDlg1:Activate(,,,.T.,{||},,{||WaitLog(oBrw1,oGrp3)})

Return


/*
Funcao      : BuscHist()
Parametros  : 
Retorno     : 
Objetivos   : Carrega tela com exibição do histórico de movimentação da nota
Autor       : Matheus Massarotto
Data/Hora   : 13/11/2013	15:14
*/
*--------------------------------------------*
Static Function BuscHist(oGrp3,oDlg3,oMeter3)
*--------------------------------------------*
Local aAreaAnt := GETAREA()
Local cQry := ""

//Inicia a régua
oMeter3:Set(0)
oMeter3:Set(98) //posiciona no fim da regua

If Select("TMP2") > 0
	("TMP2")->(DbClosearea())
Endif

cQry := "Select * From "+RETSQLNAME("Z59")
cQry += " Where Z59_ROTINA = 'GTFAT005'"
cQry += "       AND Z59_CHAVE = '"+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"
  
DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP2",.F.,.T.)              

TMP2->(DbGoTop())     

DbSelectArea("TRBLOG")
TRBLOG->(DbSetORder(1))

While !(TMP2->(Eof()))
	Z59->(DbGoTo(TMP2->R_E_C_N_O_))
		
	RecLock("TRBLOG",.T.)                           

		TRBLOG->Z59_DATA	:= Z59->Z59_DATA
		TRBLOG->Z59_HORA	:= Z59->Z59_HORA
		TRBLOG->Z59_USER	:= Z59->Z59_USER
		TRBLOG->Z59_NOMARQ	:= Z59->Z59_NOMARQ
		TRBLOG->Z59_TIPO	:= Z59->Z59_TIPO
		TRBLOG->Z59_LOG		:= Z59->Z59_LOG

	TRBLOG->(MsUnLock())
	
	TMP2->(DbSkip())
Enddo

RestArea(aAreaAnt)

//Finalizo a barra
oDlg3:End()

Return


/*
Funcao      : WaitLog()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento no log
Autor       : Matheus Massarotto
Data/Hora   : 13/11/2013	15:14
*/
*-------------------------------------------------*
Static Function WaitLog(oBrw1,oGrp3)
*-------------------------------------------------*
Local oDlg3
Local oMeter3
Local nMeter3	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg3 TITLE "Buscando log's..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter3 := 0
	    oMeter3 := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter3:=u,nMeter3)},100,oDlg3,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg3 CENTERED ON INIT(lRet:=BuscHist(oGrp3,oDlg3,oMeter3),oBrw1:oBrowse:Refresh())
	  
	//*************************************

Return(lRet)  



/*
Funcao      : GravaLog()
Parametros  : 
Retorno     : 
Objetivos   : Grava o log na tabela Z59
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------------------*
Static function GravaLog(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
*------------------------------------------*
Local oLog

DEFAULT aArray	:= {}
DEFAULT cErroLog	:= ""
DEFAULT cRotina	:= ""

//AADD(aArray,{ERROTRB->TABELA,val(ERROTRB->ORDEM),ERROTRB->CHAVE,ERROTRB->TIPOLOG})

if !empty(aArray)
	oLog:=GtIntLog():New(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
endif

Return



/*
Funcao      : RegTipo6
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para dados do tomador, registro tipo 6
Autor       : Matheus Massarotto
Data/Hora   : 
*/
*-----------------------*
Static Function RegTipo6()
*-----------------------*
Local NOPCAO := 0
Local aAreaAnt 	:= GETAREA()
Local nOpc 		:= GD_UPDATE//GD_INSERT+GD_DELETE+GD_UPDATE
Local aSize 	:= MsAdvSize()
Local aButtons 	:= {}
Private aCoBrw2 := {}
Private aHoBrw2 := {}
Private noBrw1  := 0

Aadd(aHoBrw2,{"Indicador"	,"TINDCGC"		,""	,1,0,"","","C","","","1=CPF;2=CNPJ;3=Nao informado" } )
Aadd(aHoBrw2,{"Cpf/Cnpj"	,"TGCG"			,""	,14,0,"","","C","","" } )
Aadd(aHoBrw2,{"Nome"		,"TNOME"		,""	,75,2,"","","C","","" } )

    Aadd(aCoBrw2,{	"2",;
					space(14),;
					space(75),;
	   				.F.})

aAlter := {"INDCGC","GCG","NOME"}

noBrw1 := 5

SetPrvt("oDlgRem","oBrw1")
  
DEFINE MSDIALOG oDlgRem TITLE "Dados do Tomador" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
                        
	//oBrw1 := MsNewGetDados():New(004,004,(aSize[6]/2)-15,aSize[5]/2,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlgRem,aHoBrw2,aCoBrw2 )
	oBrw1 := MsNewGetDados():New(004,004,(aSize[6]/2)-55,aSize[5]/2,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlgRem,aHoBrw2,aCoBrw2 )

     
ACTIVATE MSDIALOG oDlgRem ON INIT EnchoiceBar(oDlgRem,{||nOpcao:=1,oDlgRem:End()},{|| (nOpcao:=2,oDlgRem:End())},,aButtons) CENTERED
                  
//If nOpcao == 1
/*
	For i := 1 to Len(aCoBrw2)
		cSeek := aCoBrw2[i][1]+aCoBrw2[i][2]+aCoBrw2[i][3]+aCoBrw2[i][4]+aCoBrw2[i][5]	
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(cSeek)) 
		//Gravar campos Customizados
		SF1->(RecLock("SF1",.F.))
		SF1->F1_P_TPDOC 	:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "TPDOC"} )]
		SF1->F1_P_TRIBS 	:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "TRIBSERV"} )]
		SF1->F1_P_VDED		:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "VLRDEDU"} )]
		SF1->F1_P_ISSR		:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "ISSRET"} )]
		SF1->F1_P_TPNFTS	:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "TPNFTS"} )]
		SF1->F1_P_REGTB		:= aCoBrw2[i][aScan(aHoBrw2, {|x| x[2] == "REGTRIB"} )]
		SF1->(MsUnlock())

	Next i	        
*/
//	GeraRemMain()
	
//EndIf

RestArea(aAreaAnt)

Return .T.