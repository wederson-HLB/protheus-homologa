#INCLUDE "Protheus.ch"

/*
Funcao      : USX3036
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ajuste na ordem dos campos do Dicionario de Dados.
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 17/03/2014
*/
*---------------------*
User Function USX3036()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                            "Atenção")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) ,oMainWnd:End()/*, Final("Atualização efetuada.")*/),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
Local aChamados := {	{04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )
	lCheck := .F.    
	aAux := {}
	If !Tela()
		Return .T.
	EndIf

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If lCheck
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		Else
			If Ascan(aAux,{ |x| LEFT(x,2)  == M0_CODIGO}) <> 0 .and.;
				Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
				Ascan(aRecnoSM0,{ |x| x[2]  == M0_CODIGO}) == 0 
				
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		EndIf
		dbSkip()
	EndDo
    
	RpcClearEnv()

	  If lOpen := MyOpenSm0Ex()
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next

			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				 EndIf
				 X31UpdTable(aArqUpd[nx])
				 If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+;
					      aArqUpd[nx] +;
					      ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2) 

					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				 EndIf
			 Next nX
			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex() )
				Exit 
			 EndIf 
		 Next nI 

		 If lOpen

			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center
		 EndIf
	  EndIf
   EndIf
End Sequence

Return(.T.)

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX3
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SX3.
*/
*-----------------------*
Static Function ATUSX3()
*-----------------------*
Local cTexto  := ''
Local cAlias  := '' 

Local aTabs := {"SD3"}

Local aUpd	:= {}
Local aCpos	:= {}
Local aUpdPadrao := {}
Local aSemPad := {}

For i:=1 to len(aTabs)
	SX3->(DbSetOrder(1))
	If SX3->(DbSeek(aTabs[i]))
		While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == aTabs[i]
			aAdd(aCpos,{SX3->X3_ORDEM,SX3->X3_CAMPO})
			SX3->(DbSkip())
		EndDo
	EndIf 
	aAdd(aUpd,		{aTabs[i],aCpos})
	aAdd(aUpdPadrao,{aTabs[i],GetPadrao(aTabs[i])})
Next i	

SX3->(DbSetOrder(2))
For i:=1 to Len(aUpd)
	aSemPad := {}
	cMaior := ""
	For j:=1 to Len(aUpd[i][2])
		If SX3->(DbSeek(aUpd[i][2][j][2]))
			If (npos:=aScan(aUpdPadrao[aScan(aUpdPadrao,{|x| x[1]==aUpd[i][1]})][2],{|x| ALLTRIM(x[2])==ALLTRIM(aUpd[i][2][j][2])}) ) <> 0
				SX3->(Reclock("SX3",.F.))
				SX3->X3_ORDEM := aUpdPadrao[aScan(aUpdPadrao,{|x| x[1]==aUpd[i][1]})][2][npos][1]
				SX3->(MsUnlock())
				If cMaior < SX3->X3_ORDEM
					cMaior := SX3->X3_ORDEM
				EndIf
			Else
				aAdd(aSemPad,aUpd[i][2][j][2])
			EndIf
		EndIf	
	Next j
	For j:=1 to len(aSemPad)
		If SX3->(DbSeek(aSemPad[j]))
			cMaior := Soma1(cMaior)
			SX3->(Reclock("SX3",.F.))
			SX3->X3_ORDEM := cMaior
			SX3->(MsUnlock())
		EndIf
	Next j

	cTexto += "- SX3 Atualizado com sucesso. '"+aUpd[i][1]+"'"+ CHR(10) + CHR(13)
	If !(aUpd[i][1]$cAlias)
		cAlias += aUpd[i][1]+"/"
		aAdd(aArqUpd,aUpd[i][1])
	EndIf
Next i

Return cTexto

/*
Funcao      : getPadrao
Autor  		: Jean Victor Rocha
Data     	: 17/03/2014
Objetivos   : Retorna conteudo ordem/campo extraido de dicionario padrão.
*/
*-------------------------*
Static Function GetPadrao(cTab)
*-------------------------*
Local aRet := {} 

Do Case    
	Case cTab == "SD3"
		aAdd(aRet,{ '01' ,'D3_FILIAL'})
		aAdd(aRet,{ '02' ,'D3_TM'})
		aAdd(aRet,{ '03' ,'D3_COD'})
		aAdd(aRet,{ '04' ,'D3_UM'})
		aAdd(aRet,{ '05' ,'D3_QUANT'})
		aAdd(aRet,{ '06' ,'D3_CF'})
		aAdd(aRet,{ '07' ,'D3_CONTA'})
		aAdd(aRet,{ '08' ,'D3_OP'})
		aAdd(aRet,{ '09' ,'D3_LOCAL'})
		aAdd(aRet,{ '10' ,'D3_DOC'})
		aAdd(aRet,{ '11' ,'D3_EMISSAO'})
		aAdd(aRet,{ '12' ,'D3_GRUPO'})
		aAdd(aRet,{ '13' ,'D3_CUSTO1'})
		aAdd(aRet,{ '14' ,'D3_CUSTO2'})
		aAdd(aRet,{ '15' ,'D3_CUSTO3'})
		aAdd(aRet,{ '16' ,'D3_CUSTO4'})
		aAdd(aRet,{ '17' ,'D3_CUSTO5'})
		aAdd(aRet,{ '18' ,'D3_CC'})
		aAdd(aRet,{ '19' ,'D3_PARCTOT'})
		aAdd(aRet,{ '20' ,'D3_ESTORNO'})
		aAdd(aRet,{ '21' ,'D3_NUMSEQ'})
		aAdd(aRet,{ '22' ,'D3_SEGUM'})
		aAdd(aRet,{ '23' ,'D3_QTSEGUM'})
		aAdd(aRet,{ '24' ,'D3_TIPO'})
		aAdd(aRet,{ '25' ,'D3_NIVEL'})
		aAdd(aRet,{ '26' ,'D3_USUARIO'})
		aAdd(aRet,{ '27' ,'D3_DESCRI'})
		aAdd(aRet,{ '29' ,'D3_PERDA'})
		aAdd(aRet,{ '30' ,'D3_DTLANC'})
		aAdd(aRet,{ '31' ,'D3_TRT'})
		aAdd(aRet,{ '32' ,'D3_CHAVE'})
		aAdd(aRet,{ '33' ,'D3_IDENT'})
		aAdd(aRet,{ '34' ,'D3_SEQCALC'})
		aAdd(aRet,{ '35' ,'D3_RATEIO'})
		aAdd(aRet,{ '36' ,'D3_LOTECTL'})
		aAdd(aRet,{ '37' ,'D3_NUMLOTE'})
		aAdd(aRet,{ '38' ,'D3_DTVALID'})
		aAdd(aRet,{ '39' ,'D3_LOCALIZ'})
		aAdd(aRet,{ '40' ,'D3_NUMSERI'})
		aAdd(aRet,{ '41' ,'D3_CUSFF1'})
		aAdd(aRet,{ '42' ,'D3_CUSFF2'})
		aAdd(aRet,{ '43' ,'D3_CUSFF3'})
		aAdd(aRet,{ '44' ,'D3_CUSFF4'})
		aAdd(aRet,{ '45' ,'D3_CUSFF5'})
		aAdd(aRet,{ '46' ,'D3_ITEM'})
		aAdd(aRet,{ '47' ,'D3_OK'})
		aAdd(aRet,{ '48' ,'D3_ITEMCTA'})
		aAdd(aRet,{ '49' ,'D3_CLVL'})
		aAdd(aRet,{ '50' ,'D3_PROJPMS'})
		aAdd(aRet,{ '51' ,'D3_TASKPMS'})
		aAdd(aRet,{ '52' ,'D3_ORDEM'})
		aAdd(aRet,{ '53' ,'D3_CODGRP'})
		aAdd(aRet,{ '54' ,'D3_CODITE'})
		aAdd(aRet,{ '55' ,'D3_SERVIC'})
		aAdd(aRet,{ '56' ,'D3_STSERV'})
		aAdd(aRet,{ '57' ,'D3_OSTEC'})
		aAdd(aRet,{ '58' ,'D3_POTENCI'})
		aAdd(aRet,{ '59' ,'D3_TPESTR'})
		aAdd(aRet,{ '60' ,'D3_REGATEN'})
		aAdd(aRet,{ '61' ,'D3_ITEMSWN'})
		aAdd(aRet,{ '62' ,'D3_DOCSWN'})
		aAdd(aRet,{ '63' ,'D3_ITEMGRD'})
		aAdd(aRet,{ '64' ,'D3_STATUS'})
		aAdd(aRet,{ '65' ,'D3_CUSRP1'})
		aAdd(aRet,{ '66' ,'D3_CUSRP2'})
		aAdd(aRet,{ '67' ,'D3_CUSRP3'})
		aAdd(aRet,{ '68' ,'D3_CUSRP4'})
		aAdd(aRet,{ '69' ,'D3_CUSRP5'})
		aAdd(aRet,{ '70' ,'D3_CMRP'})
		aAdd(aRet,{ '71' ,'D3_MOEDRP'})
		aAdd(aRet,{ '72' ,'D3_MOEDA'})
		aAdd(aRet,{ '73' ,'D3_EMPOP'})
		aAdd(aRet,{ '74' ,'D3_DIACTB'})
		aAdd(aRet,{ '75' ,'D3_GARANTI'})
		aAdd(aRet,{ '76' ,'D3_PMICNUT'})
		aAdd(aRet,{ '77' ,'D3_CMFIXO'})
		aAdd(aRet,{ '78' ,'D3_NODIA'})
		aAdd(aRet,{ '79' ,'D3_PMACNUT'})
		aAdd(aRet,{ '80' ,'D3_NRBPIMS'})
		aAdd(aRet,{ '81' ,'D3_CODLAN'})
		aAdd(aRet,{ '82' ,'D3_OKISS'})
		aAdd(aRet,{ '83' ,'D3_PERIMP'})
		aAdd(aRet,{ '84' ,'D3_USERLGI'})
		aAdd(aRet,{ '84' ,'D3_VLRVI'})
		aAdd(aRet,{ '87' ,'D3_P_HISTO'})
		
	Case cTab == "SD3_PADRAO"
		aAdd(aRet,{ '01' ,'D3_FILIAL'})
		aAdd(aRet,{ '02' ,'D3_TM'})
		aAdd(aRet,{ '03' ,'D3_COD'})
		aAdd(aRet,{ '04' ,'D3_UM'})
		aAdd(aRet,{ '05' ,'D3_QUANT'})
		aAdd(aRet,{ '06' ,'D3_CF'})
		aAdd(aRet,{ '07' ,'D3_CONTA'})
		aAdd(aRet,{ '08' ,'D3_OP'})
		aAdd(aRet,{ '09' ,'D3_LOCAL'})
		aAdd(aRet,{ '10' ,'D3_DOC'})
		aAdd(aRet,{ '11' ,'D3_EMISSAO'})
		aAdd(aRet,{ '12' ,'D3_GRUPO'})
		aAdd(aRet,{ '13' ,'D3_CUSTO1'})
		aAdd(aRet,{ '14' ,'D3_CUSTO2'})
		aAdd(aRet,{ '15' ,'D3_CUSTO3'})
		aAdd(aRet,{ '16' ,'D3_CUSTO4'})
		aAdd(aRet,{ '17' ,'D3_CUSTO5'})
		aAdd(aRet,{ '18' ,'D3_CC'})
		aAdd(aRet,{ '19' ,'D3_PARCTOT'})
		aAdd(aRet,{ '20' ,'D3_ESTORNO'})
		aAdd(aRet,{ '21' ,'D3_NUMSEQ'})
		aAdd(aRet,{ '22' ,'D3_SEGUM'})
		aAdd(aRet,{ '23' ,'D3_QTSEGUM'})
		aAdd(aRet,{ '24' ,'D3_TIPO'})
		aAdd(aRet,{ '25' ,'D3_NIVEL'})
		aAdd(aRet,{ '26' ,'D3_USUARIO'})
		aAdd(aRet,{ '27' ,'D3_DESCRI'})
		aAdd(aRet,{ '29' ,'D3_PERDA'})
		aAdd(aRet,{ '30' ,'D3_DTLANC'})
		aAdd(aRet,{ '31' ,'D3_TRT'})
		aAdd(aRet,{ '32' ,'D3_CHAVE'})
		aAdd(aRet,{ '33' ,'D3_IDENT'})
		aAdd(aRet,{ '34' ,'D3_SEQCALC'})
		aAdd(aRet,{ '35' ,'D3_RATEIO'})
		aAdd(aRet,{ '36' ,'D3_LOTECTL'})
		aAdd(aRet,{ '37' ,'D3_NUMLOTE'})
		aAdd(aRet,{ '38' ,'D3_DTVALID'})
		aAdd(aRet,{ '39' ,'D3_LOCALIZ'})
		aAdd(aRet,{ '40' ,'D3_NUMSERI'})
		aAdd(aRet,{ '41' ,'D3_CUSFF1'})
		aAdd(aRet,{ '42' ,'D3_CUSFF2'})
		aAdd(aRet,{ '43' ,'D3_CUSFF3'})
		aAdd(aRet,{ '44' ,'D3_CUSFF4'})
		aAdd(aRet,{ '45' ,'D3_CUSFF5'})
		aAdd(aRet,{ '46' ,'D3_ITEM'})
		aAdd(aRet,{ '47' ,'D3_OK'})
		aAdd(aRet,{ '48' ,'D3_ITEMCTA'})
		aAdd(aRet,{ '49' ,'D3_CLVL'})
		aAdd(aRet,{ '50' ,'D3_PROJPMS'})
		aAdd(aRet,{ '51' ,'D3_TASKPMS'})
		aAdd(aRet,{ '52' ,'D3_ORDEM'})
		aAdd(aRet,{ '53' ,'D3_CODGRP'})
		aAdd(aRet,{ '54' ,'D3_CODITE'})
		aAdd(aRet,{ '55' ,'D3_SERVIC'})
		aAdd(aRet,{ '56' ,'D3_STSERV'})
		aAdd(aRet,{ '57' ,'D3_OSTEC'})
		aAdd(aRet,{ '58' ,'D3_POTENCI'})
		aAdd(aRet,{ '59' ,'D3_TPESTR'})
		aAdd(aRet,{ '60' ,'D3_REGATEN'})
		aAdd(aRet,{ '61' ,'D3_ITEMSWN'})
		aAdd(aRet,{ '62' ,'D3_DOCSWN'})
		aAdd(aRet,{ '63' ,'D3_ITEMGRD'})
		aAdd(aRet,{ '64' ,'D3_STATUS'})
		aAdd(aRet,{ '65' ,'D3_CUSRP1'})
		aAdd(aRet,{ '66' ,'D3_CUSRP2'})
		aAdd(aRet,{ '67' ,'D3_CUSRP3'})
		aAdd(aRet,{ '68' ,'D3_CUSRP4'})
		aAdd(aRet,{ '69' ,'D3_CUSRP5'})
		aAdd(aRet,{ '70' ,'D3_CMRP'})
		aAdd(aRet,{ '71' ,'D3_MOEDRP'})
		aAdd(aRet,{ '72' ,'D3_MOEDA'})
		aAdd(aRet,{ '73' ,'D3_EMPOP'})
		aAdd(aRet,{ '74' ,'D3_DIACTB'})
		aAdd(aRet,{ '75' ,'D3_GARANTI'})
		aAdd(aRet,{ '76' ,'D3_PMICNUT'})
		aAdd(aRet,{ '77' ,'D3_CMFIXO'})
		aAdd(aRet,{ '78' ,'D3_NODIA'})
		aAdd(aRet,{ '79' ,'D3_PMACNUT'})
		aAdd(aRet,{ '80' ,'D3_NRBPIMS'})
		aAdd(aRet,{ '81' ,'D3_CODLAN'})
		aAdd(aRet,{ '82' ,'D3_OKISS'})
		aAdd(aRet,{ '83' ,'D3_PERIMP'})
		aAdd(aRet,{ '84' ,'D3_VLRVI'})
EndCase		        


Return aRet


//------------- INTERFACE ---------------------------------------------------
*--------------------*
Static Function Tela()
*--------------------*
Local lRet := .F.
Private cAliasWork := "Work"
private aCpos :=  {	{"MARCA"	,,""} ,;
						{"M0_CODIGO",,"Cod.Empresa"	},;
						{"M0_CODFIL",,"Filial" 		},;
		   				{"M0_NOME"	,,"Nome Empresa"}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"M0_CODIGO","C",2 ,0},;
						{"M0_CODFIL","C",2 ,0},;
		   				{"M0_NOME"	,"C",30,0}}

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf     

dbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSetOrder(1))
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cAux:= ""
While SM0->(!EOF())
	If cAux <> SM0->M0_CODIGO
		(cAliasWork)->(RecLock(cAliasWork,.T.))           
		(cAliasWork)->MARCA		:= ""
		(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
		(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
		(cAliasWork)->M0_NOME	:= SM0->M0_NOME
		(cAliasWork)->(MsUnlock())
		cAux := SM0->M0_CODIGO
	EndIf
	SM0->(DbSkip())
EndDo

(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 091,232,401,612,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as empresas a serem atualizadas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{016,004,124,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oCBox1     := TCheckBox():New( 128,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSBtn1     := SButton():New( 132,116,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 132,152,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

// Seta Eventos do primeiro Check
oCBox1:bSetGet := {|| lCheck }
oCBox1:bLClicked := {|| lCheck:=!lCheck }
oCBox1:bWhen := {|| .T. }

oDlg1:Activate(,,,.T.)

Return lRet

*-----------------------*
Static Function cMark()
*-----------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
if lDesmarca
   (cAliasWork)->MARCA := "  "
else
   (cAliasWork)->MARCA := cMarca
endif

(cAliasWork)->(MsUnlock())

return 

*-----------------------*
Static Function Dados()
*-----------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .t.