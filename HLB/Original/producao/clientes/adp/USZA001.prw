#INCLUDE 'TOTVS.CH'
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"

/*
Funcao      : USZA001
Objetivos   : Update para criação da tabela SZA - Integração de arquivos com a ADP (Connectivity)
Autor       : Eduardo C. Romanini
Data/Hora   : 09/09/2015 11:00
Módulo      : 07 - SigaGPE - Gestão de Pessoal
*/
*---------------------*
User Function USZA001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {}
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
                                         .F.) , Final("Atualização efetuada.")),;
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

Local aAtuDic := { {07, {|| AtuSIX()}},;
				   {07, {|| AtuSX2()}},;
                   {07, {|| AtuSX3()}}}
                 
Local aAtuTab := {}

Private NL := CHR(13) + CHR(10)
   
If MsgYesNo("Deseja executar as atualizações de Implantação?")
	aAtuTab := { {07, {|| AtuSZA()}}}
EndIf

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof()
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf
		 dbSkip()
	  EndDo

	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aAtuDic para cada 
	  		    módulo. */
	  		 For i := 1 To Len(aAtuDic)
  	  		    nModulo := aAtuDic[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aAtuDic[i,2] )
			 Next

             /* Neste ponto o sistema atualizará a 
                estrutura das tabelas informadas no
                array aArqUpd. */
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
				 
				 If !TCCanOpen(aArqUpd[nx])
				 	CHKFILE(aArqUpd[nx]) //Crio a tabela caso ela n exista
				 Endif
			 Next nX
			 
			 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aAtuTab para cada 
	  		    módulo. */
	  		 For i := 1 To Len(aAtuTab)
  	  		    nModulo := aAtuTab[i,1]
  	  		    ProcRegua(1)
			    IncProc("Atualizado dados das tabelas...")
			    cTexto += EVAL( aAtuTab[i,2] )
			 Next

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
Objetivos   : Efetua a abertura do SM0 exclusivo
Obs.        :
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
Funcao      : AtuSIX
Objetivos   : Atualizar o dicionário de dados SIX - Índices
Autor       : Eduardo C. Romanini
Data/Hora   : 09/09/2015 11:00
Obs         :
*/
*----------------------*
Static Function AtuSIX()
*----------------------*
Local cTexto := ""

Local nI := 0
Local nJ := 0

Local lSIX := .F.

Local aEstrut := {}
Local aSIX    := {}

aEstrut:= {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}

aAdd(aSIX,{"SZA",;                 				//INDICE
           "1",;                    			//ORDEM
           "ZA_FILIAL+ZA_CPOEXCE+ZA_CPOSX3",;	//CHAVE
           "Filial + CpoExcel + CpoSX3" ,;  	//DESCRICAO
           "Filial + CpoExcel + CpoSX3" ,;  	//DESCSPA
           "Filial + CpoExcel + CpoSX3" ,;  	//DESCENG
           "S",;                    			//PROPRI
           "",;   	                			//F3
           "",;   	                			//NICKNAME
           "S"})                    			//SHOWPESQ


aAdd(aSIX,{"SZA",;                 				//INDICE
           "2",;                    			//ORDEM
           "ZA_FILIAL+ZA_CPOSX3+ZA_CPOEXCE",;	//CHAVE
           "Filial + CpoSX3 + CpoExcel" ,;  	//DESCRICAO
           "Filial + CpoSX3 + CpoExcel" ,;  	//DESCSPA
           "Filial + CpoSX3 + CpoExcel" ,;  	//DESCENG
           "S",;                    			//PROPRI
           "",;   	                			//F3
           "",;   	                			//NICKNAME
           "S"})                    			//SHOWPESQ

dbSelectArea("SIX")
ProcRegua(Len(aSIX))
SIX->(DbSetOrder(1))
For nI:= 1 To Len(aSIX)
	If !Empty(aSIX[nI][1])
		lSIX := !DbSeek(aSIX[nI,1]+aSIX[nI,2])
		SIX->(RecLock("SIX",lSIX))
		For nJ:=1 To Len(aSIX[nI])
			If FieldPos(aEstrut[nJ])>0 .And. aSIX[nI,nJ] != Nil
				FieldPut(FieldPos(aEstrut[nJ]),aSIX[nI,nJ])
			EndIf
		Next
		cTexto += "- SIX Atualizado com sucesso. '"+aSIX[nI,1]+"-"+aSIX[nI,2]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Índices...")
	EndIf
Next

Return cTexto


/*
Funcao      : AtuSX2
Objetivos   : Atualizar o dicionário de dados SX2 - Tabelas
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSX2()
*----------------------*
Local cTexto := ""

Local nI := 0
Local nJ := 0

Local lSX2 := .F.

Local aEstrut := {}
Local aSX2    := {}


aEstrut:= { "X2_CHAVE"  ,"X2_PATH" ,"X2_ARQUIVO","X2_NOME" ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO" ,"X2_MODOUN" ,;
			"X2_MODOEMP","X2_DELET","X2_TTS"    ,"X2_UNICO","X2_PYME"   ,"X2_MODULO" ,"X2_DISPLAY"}


aAdd(aSX2,{"SZA",; 						//X2_CHAVE
           "\SYSTEM\",;         	    //X2_PATH
           "SZAYY0",;					//X2_ARQUIVO
           "Integração arquivos ADP",;	//X2_NOME
           "Integração arquivos ADP",;	//X2_NOMESPA
           "Integração arquivos ADP",;	//X2_NOMEENG
           "",;							//X2_ROTINA
           "C",;						//X2_MODO
           "C",;						//X2_MODOUN
           "C",;						//X2_MODOEMP
           0,;							//X2_DELET
           "",;							//X2_TTS
           "",;					   		//X2_UNICO
           "N",;						//X2_PYME
           7,;							//X2_MODULO
           ""})							//X2_DISPLAY           

dbSelectArea("SX2")
ProcRegua(Len(aSX2))
SX2->(DbSetOrder(1))
For nI:= 1 To Len(aSX2)
	If !Empty(aSX2[nI][1])
		lSX2 := !DbSeek(aSX2[nI,1])
		SX2->(RecLock("SX2",lSX2))
		For nJ:=1 To Len(aSX2[nI])
			If FieldPos(aEstrut[nJ])>0 .And. aSX2[nI,nJ] != Nil
				FieldPut(FieldPos(aEstrut[nJ]),aSX2[nI,nJ])
			EndIf
		Next
		cTexto += "- SX2 Atualizado com sucesso. '"+aSX2[nI,1]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Tabelas...") //
	EndIf
Next

Return cTexto   

/*
Funcao      : AtuSX3
Objetivos   : Atualizar o dicionário de dados SIX - Campos
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSX3()
*----------------------*
Local cTexto := ""
Local cAlias := ""

Local nI := 0
Local nJ := 0

Local lSX3 := .F.

Local aEstrut := {}
Local aSX3    := {}

X3_RESERV     := "þÀ"
X3_RE_FILIAL  := "€€"
X3_OBRIGAT    := "€"
X3_USADO      := "€€€€€€€€€€€€€€ "
X3_NAOUSADO   := "€€€€€€€€€€€€€€€"

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

aAdd(aSX3,{"SZA",;            			//X3_ARQUIVO
           "01",;						//X3_ORDEM
           "ZA_FILIAL",; 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           2,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Filial",;                   //X3_TITULO
           "Sucursal",;                 //X3_TITSPA
           "Branch",;                   //X3_TITENG
           "Filial",;                   //X3_DESCRIC
           "Sucursal",;                 //X3_DESCSPA
           "Branch",;                   //X3_DESCENG
           "",;                         //X3_PICTURE
           "",;                         //X3_VALID
           X3_NAOUSADO,; 		        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RE_FILIAL,;               //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           "",;	                        //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "033",;                      //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SZA",;            			//X3_ARQUIVO
           "02",;						//X3_ORDEM
           "ZA_ALIAS",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           3,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Alias",;                    //X3_TITULO
           "Alias",;	                //X3_TITSPA
           "Alias",;                    //X3_TITENG
           "Alias da Tabela",;          //X3_DESCRIC
           "Alias da Tabela",;          //X3_DESCSPA
           "Alias da Tabela",;	        //X3_DESCENG
           "@!",;                       //X3_PICTURE
           "",;                         //X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "V",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           X3_OBRIGAT,;                 //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "",;                         //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SZA",;            			//X3_ARQUIVO
           "03",;						//X3_ORDEM
           "ZA_CPOEXCE",;	            //X3_CAMPO
           "C",;                        //X3_TIPO
           80,;                         //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Cpo.Excel",;                //X3_TITULO
           "Cpo.Excel",;                //X3_TITSPA
           "Cpo.Excel",;                //X3_TITENG
           "Coluna no Excel",;          //X3_DESCRIC
           "Coluna no Excel",;          //X3_DESCSPA
           "Coluna no Excel",;          //X3_DESCENG
           "@!",;                       //X3_PICTURE
           "",;                         //X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "V",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           X3_OBRIGAT,;                 //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "",;                         //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SZA",;            			//X3_ARQUIVO
           "04",;						//X3_ORDEM
           "ZA_CPOSX3",;	            //X3_CAMPO
           "C",;                        //X3_TIPO
           10,;                         //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Cpo.SX3",;                	//X3_TITULO
           "Cpo.SX3",;                	//X3_TITSPA
           "Cpo.SX3",;                	//X3_TITENG
           "Campo no SX3",;          	//X3_DESCRIC
           "Campo no SX3",;          	//X3_DESCSPA
           "Campo no SX3",;          	//X3_DESCENG
           "@!",;                       //X3_PICTURE
           "ExistChav('SX3')",;         //X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "",;                         //X3_RELACAO
           "SX3",;                      //X3_F3
           1,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "V",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           X3_OBRIGAT,;                 //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "",;                         //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

dbSelectArea("SX3")
ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))
For nI:= 1 To Len(aSX3)
	If !Empty(aSX3[nI][1])
		lSX3:= !DbSeek(AllTrim(aSX3[nI,3]))
		If !(lSX3 .and. aSX3[nI,2] == Nil)
			If !(aSX3[nI,1]$cAlias)
				cAlias += aSX3[nI,1]+"/"
				aAdd(aArqUpd,aSX3[nI,1])
			EndIf
			RecLock("SX3",lSX3)
			For nJ:=1 To Len(aSX3[nI])
				If FieldPos(aEstrut[nJ])>0 .And. aSX3[nI,nJ] != Nil
					FieldPut(FieldPos(aEstrut[nJ]),aSX3[nI,nJ])
				EndIf
			Next
			DbCommit()
			MsUnlock()
			IncProc("Atualizando Dicionario de Campos...")
		EndIf
	EndIf
Next

If !Empty(cAlias)
	cTexto += "- SX3 Atualizado com sucesso. '"+cAlias+"'"+ CHR(10) + CHR(13)
EndIf

Return cTexto 


/*
Funcao      : AtuSZA
Objetivos   : Atualizar a tabela SZA
Autor       : Eduardo C. Romanini
Data/Hora   : 09/09/2015 11:30
Obs         :
*/
*----------------------*
Static Function AtuSZA()
*----------------------*
Local cTexto := ""

Local nI := 0

Local aSZA   := {{"ADDRESSES.ADDRESS_LINE1","RA_ENDEREC"},;
                 {"ADDRESSES.ADDRESS_TYPE","RA_TIPENDE"},;
                 {"ADDRESSES.CITY","RA_MUNICIP"},;
                 {"ADDRESSES.COUNTRY_CODE","RA_PAISEXT"},;
                 {"ADDRESSES.DISTRICT","RA_BAIRRO"},;
                 {"ADDRESSES.HOUSE_NUMBER","RA_NUMENDE"},;
                 {"ADDRESSES.IDENTIFICATION_OF_AN_APARTMENT_IN_A_BUILDING","RA_COMPLEM"},;
                 {"ADDRESSES.POSTAL_CODE","RA_CEP"},;
                 {"ADDRESSES.REGION","RA_ESTADO"},;
                 {"ADDRESSES.STREET_TYPE","RA_LOGRTP"},;
                 {"BASIC_PAY_SALARY.PAYMENT_FREQUENCY","RA_TIPOPGT"},;
                 {"BASIC_PAY_SALARY.SALARY","RA_SALARIO"},;
                 {"BASIC_PAY_SALARY_BR.EFFECTIVE_DATE","RA_DATAALT"},;
                 {"BASIC_PAY_SALARY_BR.TYPE_OF_SALARY_INCREASE","RA_TIPOALT"},;
                 {"COMMUNICATION.BUSSINESS_EMAIL_ADDRESS","RA_EMAIL"},;
                 {"COMMUNICATION.HOME_EMAIL_ADDRESS","RA_EMAIL2"},;
                 {"COMMUNICATION.HOME_FIX_PHONE_NUMBER","RA_TELEFON"},;
                 {"COMMUNICATION.HOME_MOBILE_PHONE_NUMBER","RA_NUMCELU"},;
                 {"CONTRACT.CONTRACT_END_DATE","RA_DTFIMCT"},;
                 {"CONTRACT.EMPLOYMENT_RATE","RA_HOPARC"},;
                 {"CONTRACT.MONTHLY_WORKING_HOURS","RA_HRSMES"},;
                 {"CONTRACT.PROBATION_END_DATE","RA_VCTOEXP"},;
                 {"CONTRACT.TYPE_OF_CONTRACT","RA_TPCONTR"},;
                 {"CONTRACT.WEEKLY_WORKING_HOURS","RA_HRSEMAN"},;
                 {"CONTRACT_BR.PROBATIONARY_SECOND_PERIOD","RA_VCTEXP2"},;
                 {"CONTRACT_BR.WORK_SCHEDULE_GROUP","RA_TNOTRAB"},;
                 {"HIRE.HIRE_DATE","RA_ADMISSA"},;
                 {"HIRE.HIRE_TYPE","RA_TIPOADM"},;
                 {"HIRE.REASON_FOR_HIRE","RA_TPREINT"},;
                 {"JOB_POSITION.JOB_CODE","RA_CODFUNC"},;
                 {"KEY_DATA.EMPLOYEE_ID","RA_CRACHA"},;
                 {"KEY_DATA.KEY_DATA.PAYROLL_AREA_OR_PAY_GROUP","RA_FILIAL"},;
                 {"KEY_DATA.PAYROLL_PAYEE_ID","RA_MAT"},;
                 {"ORGANIZATION_ASSIGNEMENT.EMPLOYEE_STATUS","RA_SITFOLH"},;
                 {"ORGANIZATION_ASSIGNMENT.EMPLOYMENT_RELATIONSHIP","RA_CATFUNC"},;
                 {"ORG_ASSIGNMENT_COST_CENTER.COST_CENTER_FIX","RA_CC"},;
                 {"PERSONAL_DATA.BIRTH_COUNTRY_CODE","RA_CPAISOR"},;
                 {"PERSONAL_DATA.BIRTH_DISTRICT","RA_NATURAL"},;
                 {"PERSONAL_DATA.DATE_OF_BIRTH","RA_NASC"},;
                 {"PERSONAL_DATA.EDUCATION_LEVEL","RA_GRINRAI"},;
                 {"PERSONAL_DATA.NATIONALITY","RA_NACIONA"},;
                 {"PERSONAL_DATA.PLACE_OF_BIRTH","RA_MUNNASC"},;
                 {"PERSONAL_DATA_BR.CHILDREN_WITH_BRAZILIAN","RA_FILHOBR"},;
                 {"PERSONAL_DATA_BR.ETHNIC_GROUP","RA_RACACOR"},;
                 {"PERSONAL_DATA_BR.MARRIED_TO_BRAZILIAN","RA_CASADBR"},;
                 {"PERSONAL_DATA_BR.NATURALIZATION_DATE","RA_DATNATU"},;
                 {"PERSONAL_DATA_BR.TYPE_OF_DISABILITY","RA_TPDEFFI"},;
                 {"PERSONAL_DATA_EFF_DATE.GENDER_KEY","RA_SEXO"},;
                 {"PERSONAL_DATA_EFF_DATE.MARITAL_STATUS","RA_ESTCIVI"},;
                 {"PERSONAL_DATA_IDENTIFICATION_BR.DOCUMENT_SERIES","RA_SERCP"},;
                 {"PERSONAL_DATA_IDENTIFICATION_BR.VOTE_LOCATION","RA_ZONASEC"},;
                 {"PERSONAL_DATA_NAME.FULL_NAME","RA_NOME"},;
                 {"PERSONAL_DATA_NAME.KNOW_AS_PREFERD_NAME","RA_APELIDO"},;
                 {"SOCIAL_INSURANCE.NI_CODE","RA_TPPREVI"},;
                 {"TERMINATION.TERMINATION_DATE","RA_DEMISSA"},;
                 {"TERMINATION.TERMINATION_REASON","RA_RESCRAI"},;
                 {"UNION_BR.UNION_FEE_STATUS","RA_PGCTSIN"},;
                 {"BANKING.BANK_KEY","RA_BCDEPSA"},;
                 {"BANKING.BANK_ACCOUNT_NUMBER","RA_CTDEPSA"}}

For nI:=1 To Len(aSZA)
	
	IncProc("Atualizando Tabela SZA...")

	SZA->(DbSetOrder(1))
	If SZA->(DbSeek(xFilial("SZA")+aSZA[nI][1]))
		SZA->(RecLock("SZA",.F.))
		SZA->ZA_CPOSX3 := AllTrim(aSZA[nI][2])
		SZA->(MsUnlock())
	Else
		SZA->(RecLock("SZA",.T.))
		SZA->ZA_FILIAL := xFilial("SZA")
		SZA->ZA_ALIAS  := "SRA" 
		SZA->ZA_CPOEXCE:= AllTrim(aSZA[nI][1])		
		SZA->ZA_CPOSX3 := AllTrim(aSZA[nI][2])
		SZA->(MsUnlock())
	EndIf
Next

cTexto += "- SZA Atualizado com sucesso."+ CHR(10) + CHR(13)

Return cTexto