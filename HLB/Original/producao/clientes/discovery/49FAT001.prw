#include "protheus.ch"

/*
Funcao      : 49FAT001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Importar pedidos de venda, seguindo um padrão de layout utilizado na importação dos pedidos que utilizava o access.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 17/02/2012    14:14
Módulo      : Faturamento
Revisão		:
Autor       : Jean Victor Rocha 
Data		: 07/01/2013
Objetivo	: Adequação ao novo layout.
*/
*----------------------*
User Function 49FAT001()
*----------------------*
if !cEmpAnt $ "49|50"  //Discovery Comun; Discovery Teste
	alert("Empresa não autorizada!")
	return
endif

Private cArqTxt := cGetFile("Arquivos| *.CSV|", "Selecione o diretório",,,,;
                 GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE,.F.) 

Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}


If Empty(cArqTxt)
	Alert("Cancelado!")
	Return	
EndIf               
     
Processa({||GeraArq(cArqTxt)}, "Processando...")

Return

/*
Funcao      : GeraArq()  
Parametros  : cArqTxt
Retorno     : Nil
Objetivos   : Processar o arquivo selecionado
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/
*------------------------------*
Static Function GeraArq(cArqTxt)
*------------------------------*
Local nI
Local nUsado := 0
Local aButtons :={}

AADD(aButtons,{"NOTE", {|| Render(aCols)}, "Atualizar Sequencia","Atualizar Sequencia"})

Private oDlg
Private oGetDados
Private lRefresh := .T.
Private aHeader := {}
Private aCols := {}
Private aAlter:={}
Private lCtrl:=.F.

ProcRegua(0)

/*++++++++Carrego SC5 no aHeader+++++++++*/

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SC5")
																																				//C5_MENNOTA - *MSM - 18/04/2012 - tratamento para a mensagem da nota que vier da planilha
While !Eof().And.(x3_arquivo=="SC5")
	If alltrim(SX3->X3_CAMPO) $ "C5_NUM/C5_TIPO/C5_LOJACLI/C5_CONDPAG/C5_EMISSAO/C5_P_PI/C5_P_MAPA/C5_P_VIANO/C5_P_AGC/C5_P_NMAGC/C5_VEND1/C5_P_VINCU/C5_MENNOTA" .or. alltrim(SX3->X3_CAMPO)=="C5_CLIENTE"
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(SX3->X3_TITULO),;
							 SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
		 					 SX3->X3_DECIMAL,;
		 					 "ALLWAYSTRUE()",;
		 					 SX3->X3_USADO,;
		 					 SX3->X3_TIPO,;
		 					 SX3->X3_ARQUIVO,;
		 					 SX3->X3_CONTEXT } )
        
        if SX3->X3_CAMPO=="C5_LOJACLI"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Cli Sistema"),;
								 "C5_TPM_D2",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("CNPJ/CPF"),;
								 "C5_TPM_D3",;
								 "@X  ",;
								 20,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Cli Planilha"),;
								 "C5_TPM_D1",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
        endif

        if alltrim(SX3->X3_CAMPO)=="C5_P_NMAGC"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Ag Planilha"),;
								 "C5_TPM_A1",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
        endif
        
        
        if alltrim(SX3->X3_CAMPO)=="C5_VEND1"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Vendedor Sistema"),;
								 "C5_TPM_V2",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Vendedor Planilha"),;
								 "C5_TPM_V1",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
        endif


	aadd(aAlter,SX3->X3_CAMPO)

	Endif
	dbSkip()
Enddo

/*++++++++Carrego SC6 no aHeader+++++++++*/

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC6")

While !Eof().And.(SX3->X3_ARQUIVO=="SC6")
	//If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
								//"C6_ITEM/C6_PRODUTO/C6_UM/C6_PRCVEN/C6_QTDVEN/C6_QTDLIB/C6_VALOR/C6_TES/C6_LOCAL/C6_CF/C6_DESCRI/C6_P_GEOG"
	If alltrim(SX3->X3_CAMPO) $ "C6_ITEM/C6_PRODUTO/C6_PRCVEN/C6_QTDVEN/C6_QTDLIB/C6_VALOR/C6_TES/C6_CF/C6_DESCONT/C6_P_GEOG/C6_P_CODE/C6_P_ITEMD/C6_P_ITEMC/C6_P_VLC_C/C6_CODISS"
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(SX3->X3_TITULO),;
							 SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
		 					 SX3->X3_DECIMAL,;
		 					 "ALLWAYSTRUE()",;
		 					 SX3->X3_USADO,;
		 					 SX3->X3_TIPO,;
		 					 SX3->X3_ARQUIVO,;
		 					 SX3->X3_CONTEXT } )

        if alltrim(SX3->X3_CAMPO)=="C6_DESCONT"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Canal"),;
								 "C6_TPM_C1",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		endif			 					 


	aadd(aAlter,SX3->X3_CAMPO)

	Endif
	dbSkip()
Enddo

/*++++++++ Montagem do aCols +++++++++*/

if MontaCols(nUsado,aHeader,@aCols,cArqTxt)
	Return
endif

/*++++++++ Definição da tela +++++++++*/

//oDlg := MSDIALOG():New(000,000,300,400, "Faturamento",,,,,,,,,.T.)
oDlg := MSDIALOG():New(000,000,500,1000, "Faturamento",,,,,,,,,.T.)
                               //500,800

//oGetDados := MsGetDados():New(05, 05, 145, 195, 3, "U_LINHAOK", "U_TUDOOK",;
//"+C5_NUM", .T., aAlter, , .F., 200, "U_FIELDOK49", "U_SUPERDEL",,;
//"U_DELOK", oDlg

                                    //250,400
oGetDados := MsGetDados():New(33, 05, 250, 500, 3, "AllwaysTrue()", "AllwaysTrue()",;
"+C5_NUM", .T., aAlter, , .F., 200, "U_FIELDOK49", "AllwaysTrue()",,;
"AllwaysTrue()", oDlg)


oGetDados:oBrowse:lUseDefaultColors := .F.
oGetDados:oBrowse:SetBlkBackColor({|| GETDCLR(aCols,n,aHeader,.F.)})

oDlg:bInit := {|| EnchoiceBar(oDlg, {|| iif(ValidaInfo(aCols,aHeader),Processa({||GravaDados(@aCols,aHeader,nUsado),"Processando..."}),"")    },{||oDlg:End()},,aButtons)}
oDlg:lCentered := .T.
oDlg:Activate()

Return 

/*
Funcao      : MontaCols()  
Parametros  : nUsado,aHeader,aCols
Retorno     : lSair
Objetivos   : Gerar o array acols, com as informações da tabela
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/
*-----------------------------------------------------*
Static Function MontaCols(nUsado,aHeader,aCols,cArqTxt)
*-----------------------------------------------------*
Local lControl	:=.T.
Local lSair		:=.F.
Local cEstCli	:=""
Local nTpALiq	:=0
Local cCFOP		:=""
Local dDtVenc
Local nDtDife
Local cMsg 		:= ""
Local r			:=0
Local aMeses := {"JANEIRO","FEVEREIRO","MARCO",; 
				 "ABRIL" ,"MAIO"     ,"JUNHO",; 
				 "JULHO" ,"AGOSTO"   ,"SETEMBRO",; 
				 "OUTUBRO","NOVEMBRO" ,"DEZEMBRO"} 

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo


While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

    if lControl
	    for j:=1 to 5
	    	if j==5
	    	   	cLinha := FT_FReadln()        // Le a linha
			 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor
			 	if !len(aLinha)==18//33 - JVR 07/01/13
			 		Alert("O Arquivo selecionado não está no padrão para importação!")
			 		lSair:=.T.
			 		Return(lSair)
			 		//33 = n;DATA ENVIO PRYOR;Mˆs veic.;Executivo;Cli Abrev;Ag Abrev;CANAL;PI;N§ MAPA RESERVA;NOTA FISCAL N§;Valor PI                  ;Valor bruto a ser faturado;Vlr L¡quido   ; PACOTE/PA    ; Parcela Pacote; Vencimento ; Prorroga‡Æo Fatura; Abatimento Fatura(L¡q);Observa‡äes Discovery;Mensagem NF;Valor l¡quido faturado;CLIENTE;AGÒNCIA;Cod_Vend;Cod_Agencia;Cod_Prod;Cod_Cliente;Cond_Pgto;Mˆs_Vinc;Ano_Vinc;Npedido;Data_Fat;Valida‡Æo	
			 		//18 = n;DATA ENVIO GT	 ;Mˆs veic.;Executivo;Cli Abrev;Ag Abrev;CANAL;PI;N§ MAPA RESERVA;Valor PI      ;Valor bruto a ser faturado;Vlr L¡quido               ;CNPJ:  Cliente; CNPJ: Agˆncia; Vencimento    ; Mensagem NF; PACOTE/PA         ; Observa‡äes Discovery
			 		//     1;     2          ;    3    ;    4    ;    5    ;   6    ;   7 ; 8;       9       ;    10        ;            11            ;        12                ;    13        ;    14        ;    15         ;    16      ;     17            ;        18             ;
			 	endif
	    	Else
   		    	FT_FSkip()
	    	endif
	    next
		lControl:=.F.
		loop
	endif    

	//nome cliente + PI + mapa  
	if empty(aLinha[5]) .and. empty(aLinha[8]) .and. empty(aLinha[9])
		exit
	endif
	//JVR - 12/07/2012
	//Valor PI - Melhoria chamado 006044
	if empty(aLinha[10]) .or. VAL(aLinha[10]) == 0//JVR - 07/01/13 - Novo Layout
		cMsg += "Numero: "+aLinha[1]+ " Valor PI invalido."+CHR(13)+CHR(10)
		exit
	endif
	
	//ECR - 30/07/2012 - Altera o codigo do canal.
	If AllTrim(aLinha[7]) == "TLC"
		aLinha[7] := "LT"
	ElseIf AllTrim(aLinha[7]) == "BHSP"
		aLinha[7] := "BH"
	EndIf		

		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if ALLTRIM(aHeader[nI,2]) =="C5_CONDPAG"
				dDtVenc:=CTOD(alltrim(aLinha[15]))//JVR - 07/01/13 - Novo Layout
				if !empty(dDtVenc)
					nDtDife:=dDtVenc-dDataBase
					if nDtDife>0 
						DbSelectArea("SE4")
						DbSetOrder(1)
						if DbSeek(xFilial("SE4")+strzero(nDtDife,3))
							aCols[Len(aCols)][nI] := SE4->E4_CODIGO
						else
							aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
						endif
					else
						aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
					endif
				
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_PI"
				if !empty(alltrim(aLinha[8]))
					aCols[Len(aCols),nI]:=alltrim(aLinha[8])
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_MAPA"
				if !empty(alltrim(aLinha[9]))
					aCols[Len(aCols),nI]:=alltrim(aLinha[9])
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
						
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_VIANO"						
				//RRP - 07/10/2013 - Caso a planilha venha com data DD/MM/AA irá carregar a varável nAno
				nAno:=Year(CTOD(alltrim(aLinha[3])))
				// Validando se está escrito o mês por extenso
				If nAno == 0
					nAno:=Year(Date())		
				EndIf
				
				if !empty(nAno)
					aCols[Len(aCols),nI]:=alltrim(STR(nAno))
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_VINCU"
				//RRP - 07/10/2013 - Caso a planilha venha com data DD/MM/AA irá carregar a varável nMes
				nMes:=Month(CTOD(alltrim(aLinha[3])))
				// Validando se está escrito o mês por extenso
				If nMes == 0
					For r:= 1 to Len(aMeses)
						If Alltrim(UPPER(aLinha[3])) == aMeses[r]     
							nMes := r
						EndIf
					Next
				EndIf
				
				if !empty(nMes)
					aCols[Len(aCols),nI]:=alltrim(STR(nMes))
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
						
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_AGC"
				if !empty(alltrim(aLinha[6]))
					cQry:=" SELECT TOP 1 ZA_AGENCIA,ZA_NOME FROM "+RETSQLNAME("SZA")+CRLF
					cQry+=" WHERE UPPER(ZA_NOME) LIKE UPPER('%"+alltrim(aLinha[6])+"%') AND D_E_L_E_T_='' AND ZA_FILIAL='"+xFilial("SZA")+"'
					
					if select("TRBAGE")>0
						TRBAGE->(DbCloseArea())
					endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBAGE",.T.,.T.)
		
					COUNT TO nRecCount
	            else
		            nRecCount:=0
	            endif

				If nRecCount == 0 .And. !empty(alltrim(aLinha[14]))//JVR - 07/01/13
					cAg := STRTRAN(STRTRAN(STRTRAN(aLinha[14],"-",""),"/",""),".","")
					cQry:=" SELECT TOP 1 ZA_AGENCIA,ZA_NOME FROM "+RETSQLNAME("SZA")+CRLF
					cQry+=" WHERE ZA_CGC = '"+ALLTRIM(UPPER(cAg))+"' AND D_E_L_E_T_='' AND ZA_FILIAL='"+xFilial("SZA")+"'
					If select("TRBAGE")>0
						TRBAGE->(DbCloseArea())
					Endif
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBAGE",.T.,.T.)
					COUNT TO nRecCount					
				EndIf

				if nRecCount>0
					TRBAGE->(DbGotop())
					aCols[Len(aCols),nI]:=TRBAGE->ZA_AGENCIA

					//*3  tratamento para preencher a descrição da agencia do sistema
					nPosAge:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_P_NMAGC"} )
					aCols[Len(aCols),nPosAge]:=substr(TRBAGE->ZA_NOME,1,30)
                    

					//*5  tratamento para preencher a desconto de 20% caso a agência esteja preenchida
					if upper(alltrim(TRBAGE->ZA_AGENCIA))=="DIRETO" //Para agencia "DIRETO" não tem desconto
						nPosDesc:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_DESCONT"} )
						aCols[Len(aCols),nPosDesc]:=CriaVar(aHeader[nPosDesc][2])
					else					
						nPosDesc:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_DESCONT"} )
						aCols[Len(aCols),nPosDesc]:=20
					endif
					
	            else
	            	aCols[Len(aCols),nI]:=CriaVar(aHeader[nI][2])
	            	
					nPosDesc:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_DESCONT"} )
					aCols[Len(aCols),nPosDesc]:=CriaVar(aHeader[nPosDesc][2])
					
					nPosAge:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_P_NMAGC"} )
					aCols[Len(aCols),nPosAge]:=space(30)					
	            endif				

			elseif ALLTRIM(aHeader[nI,2]) =="C5_VEND1"
				if !empty(alltrim(aLinha[4]))
					cQry:=" SELECT TOP 1 A3_COD,A3_NOME FROM "+RETSQLNAME("SA3")+CRLF
					cQry+=" WHERE UPPER(A3_NOME) LIKE UPPER('%"+alltrim(aLinha[4])+"%') AND D_E_L_E_T_='' AND A3_FILIAL='  '
					
					if select("TRBVEN")>0
						TRBVEN->(DbCloseArea())
					endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBVEN",.T.,.T.)
		
					COUNT TO nRecCount
	            else
	            	nRecCount:=0
	            endif
	            
				if nRecCount>0
					TRBVEN->(DbGotop())
					aCols[Len(aCols),nI]:=TRBVEN->A3_COD

					//*4  tratamento para preencher a descrição da agencia do sistema
					nPosVen:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_V2"} )
					aCols[Len(aCols),nPosVen]:=substr(TRBVEN->A3_NOME,1,30)
					
	            else
	            	aCols[Len(aCols),nI]:=CriaVar(aHeader[nI][2])
	            	
					nPosVen:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_V2"} )
					aCols[Len(aCols),nPosVen]:=space(30)	            	
	            endif				

			elseif ALLTRIM(aHeader[nI,2]) =="C5_TIPO"
				aCols[Len(aCols),nI]:="N"
			elseif ALLTRIM(aHeader[nI,2]) =="C5_LOJACLI"
                //não faz nada no lojacli pois ja foi tratado no campo cliente *1
			
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_D1"
				aCols[Len(aCols),nI]:=alltrim(aLinha[5])
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_D2"                
                //não faz nada no Cli Sistema pois ja foi tratado no campo cliente  *2
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_D3"                
                //não faz nada no CNPJ/CPF pois ja foi tratado no campo cliente  *12
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_A1"
				aCols[Len(aCols),nI]:=alltrim(aLinha[6])
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_NMAGC"                
                //não faz nada no Ag Sistema pois ja foi tratado no campo agencia  *3
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_V2"                
                //não faz nada no Vendedor Sistema pois ja foi tratado no campo C5_VEND1  *4                
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_V1"
				aCols[Len(aCols),nI]:=alltrim(aLinha[4])                
			//*MSM - 18/04/2012 - tratamento para a mensagem da nota que vier da planilha
			elseif ALLTRIM(aHeader[nI,2]) =="C5_MENNOTA" //JVR - 07/01/13 - Novo Layout
				if !empty(alltrim(aLinha[16]))
					aCols[Len(aCols),nI]:=alltrim(aLinha[16])
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
				
			//+++++++ tratamento para cliente +++++++++++//

			elseif ALLTRIM(aHeader[nI,2]) =="C5_CLIENTE"

                if !empty(alltrim(aLinha[5]))
					cQry:=" SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME,A1_CGC FROM "+RETSQLNAME("SA1")+CRLF
					cQry+=" WHERE UPPER(A1_NOME) LIKE UPPER('%"+alltrim(aLinha[5])+"%') AND D_E_L_E_T_='' AND A1_FILIAL='"+xFilial("SA1")+"'
					
					if select("TRBCLI")>0
						TRBCLI->(DbCloseArea())
					endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCLI",.T.,.T.)
		
					COUNT TO nRecCount
	            else
		            nRecCount:=0
	            endif
	            
				If nRecCount == 0 .And. !empty(alltrim(aLinha[13]))//JVR - 07/01/13
					cCgc := STRTRAN(STRTRAN(STRTRAN(aLinha[13],"-",""),"/",""),".","")
					cQry:=" SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME,A1_CGC FROM "+RETSQLNAME("SA1")+CRLF
					cQry+=" WHERE A1_CGC = '"+ALLTRIM(UPPER(cCgc))+"' AND D_E_L_E_T_='' AND A1_FILIAL='"+xFilial("SA1")+"'
					If select("TRBCLI")>0
						TRBCLI->(DbCloseArea())
					Endif
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCLI",.T.,.T.)
					COUNT TO nRecCount					
				EndIf

				if nRecCount>0
					TRBCLI->(DbGotop())
					aCols[Len(aCols),nI]:=TRBCLI->A1_COD

					//*1  tratamento para preencher a loja do cliente
					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJACLI"} )
					aCols[Len(aCols),nPosLoja]:=TRBCLI->A1_LOJA					
					//*2  tratamento para preencher a descrição do cliente no sistema
					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D2"} )
					aCols[Len(aCols),nPosNome]:=substr(TRBCLI->A1_NOME,1,30)
					//*12  tratamento para preencher a descrição do cliente no sistema
					nPosCgc:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D3"} )
					aCols[Len(aCols),nPosCgc]:=substr(TRBCLI->A1_CGC,1,20)
	            else
	            	aCols[Len(aCols),nI]:=CriaVar(aHeader[nI][2])

					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJACLI"} )
					aCols[Len(aCols),nPosLoja]:=CriaVar(aHeader[nPosLoja][2])

					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D2"} )
					aCols[Len(aCols),nPosNome]:=space(30)

					nPosCgc:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D3"} )
					aCols[Len(aCols),nPosCgc]:=space(20)

	            endif
			//+++++++ fim tratamento para cliente +++++++++++//

			//C6_ITEM/C6_PRODUTO/C6_UM/C6_PRCVEN/C6_QTDVEN/C6_VALOR/C6_TES/C6_LOCAL/C6_CF/C6_DESCRI/C6_P_GEOG
			elseif ALLTRIM(aHeader[nI,2]) =="C6_ITEM"
				aCols[Len(aCols),nI]:= "01"
			elseif ALLTRIM(aHeader[nI,2]) =="C6_PRCVEN"												
				aCols[Len(aCols),nI]:= val(strtran(strtran(aLinha[11],"."),",","."))//JVR - 07/01/13 - Novo Layout
			elseif ALLTRIM(aHeader[nI,2]) =="C6_QTDVEN"
				aCols[Len(aCols),nI]:=1
			elseif ALLTRIM(aHeader[nI,2]) =="C6_QTDLIB"
				aCols[Len(aCols),nI]:=0
			elseif ALLTRIM(aHeader[nI,2]) =="C6_VALOR"
				aCols[Len(aCols),nI]:=val(strtran(strtran(aLinha[11],"."),",","."))//JVR - 07/01/13 - Novo Layout
			
			//+++++++ tratamento para TES +++++++++++//			
			elseif ALLTRIM(aHeader[nI,2]) =="C6_TES"

				DbSelectArea("SB1") 
				DbSetOrder(1)
				if DbSeek(xFilial("SB1")+CANAL(alltrim(upper(aLinha[7])),2))
					aCols[Len(aCols),nI]:=SB1->B1_TS
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
			//+++++++ fim tratamento TES +++++++++++//
			
			elseif ALLTRIM(aHeader[nI,2]) =="C6_CF"
			
				nPosCli:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_CLIENTE"} )
				nPosLjCli:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJACLI"} )
                //Regra para buscar o cfop                       
				DbSelectArea("SA1")
				DbSetOrder(1)
				if DbSeek(xFilial("SA1")+aCols[Len(aCols),nPosCli]+aCols[Len(aCols),nPosLjCli])
                	cEstCli:=SA1->A1_EST
                	
                	if alltrim(cEstCli)=="EX
                		nTpALiq:=2
                	elseif alltrim(cEstCli)<>alltrim(GETMV("MV_ESTADO"))
                		nTpALiq:=1
                	endif
			    endif
				
				dbSelectArea("SB1") 
				DbSetOrder(1)
				if DbSeek(xFilial("SB1")+CANAL(alltrim(upper(aLinha[7])),2))
					dbSelectArea("SF4")
					DbSetOrder(1)
					if DbSeek(xFilial("SF4")+SB1->B1_TS)
						cCFOP:=SF4->F4_CF
					endif
				endif
				
				if !empty(cCFOP)
					//aCols[Len(aCols),nI]:= alltrim(cvaltochar( val(substr(cCFOP,1,1))+nTpALiq ))+substr(cCFOP,2,4)
					aCols[Len(aCols),nI]:= If( alltrim(cEstCli)==alltrim(GETMV("MV_ESTADO")),'5',If( alltrim(cEstCli)<>"EX",'6','7'))+;
																		substr(cCFOP,2,4)	    						
			    else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])				
				endif
			
			elseif ALLTRIM(aHeader[nI,2]) =="C6_DESCONT"
                //não faz nada no Desconto pois ja foi tratado no campo Agencia *5
			elseif ALLTRIM(aHeader[nI,2]) =="C6_PRODUTO"
                //não faz nada no Produto pois ja foi tratado no campo Canal *6
			elseif ALLTRIM(aHeader[nI,2]) =="C6_P_CODE"
                //não faz nada no Canal(P_CODE) pois ja foi tratado no campo Canal *7
			elseif ALLTRIM(aHeader[nI,2]) =="C6_P_ITEMC"
                //não faz nada no Brand pois ja foi tratado no campo Canal *8
			elseif ALLTRIM(aHeader[nI,2]) =="C6_P_ITEMD"
                //não faz nada no Plataforma pois ja foi tratado no campo Canal *9
			elseif ALLTRIM(aHeader[nI,2]) =="C6_P_GEOG"
                //não faz nada no Geographic pois ja foi tratado no campo Canal *10
			elseif ALLTRIM(aHeader[nI,2]) =="C6_P_VLC_C"
				//não faz nada no C6_P_VLC_C pois ja foi tratado no campo Canal *11

			//+++++++ tratamento para C6_P_GEOG/C6_P_CODE/C6_P_ITEMD/C6_P_ITEMC/C6_P_VLC_C +++++++++++//
			elseif ALLTRIM(aHeader[nI,2]) =="C6_TPM_C1"
				//C6_P_GEOG/C6_P_CODE/C6_P_ITEMD/C6_P_ITEMC/C6_P_VLC_C
				
				if !empty(alltrim(aLinha[7]))
					aCols[Len(aCols),nI]:=alltrim(aLinha[7])
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
				
			
				//*6  tratamento para preencher o produto
				nPos2:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_PRODUTO"} )
				aCols[Len(aCols),nPos2]:=PADR(CANAL(alltrim(upper(aLinha[7])),2),15)
			    			    
				//*7  tratamento para preencher o company code
				nPos3:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_P_CODE"} )
				aCols[Len(aCols),nPos3]:=CANAL(alltrim(upper(aLinha[7])),3)

				//*8  tratamento para preencher Brand
				nPos4:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_P_ITEMC"} )
				aCols[Len(aCols),nPos4]:=CANAL(alltrim(upper(aLinha[7])),4)
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				if DbSeek(xFilial("SB1")+CANAL(alltrim(upper(aLinha[7])),2))
					//*11  tratamento para preencher C6_p_VLC_C
					nPos7:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_P_VLC_C"} )
					aCols[Len(aCols),nPos7]:=SB1->B1_CLVL				
				endif
				
				//*9  tratamento para preencher Plataform
				nPos5:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_P_ITEMD"} )
				aCols[Len(aCols),nPos5]:=CANAL(alltrim(upper(aLinha[7])),5)
			                                                               
				//*10  tratamento para preencher Geographic
				nPos6:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_P_GEOG"} )
				aCols[Len(aCols),nPos6]:=IIF( ALLTRIM(CANAL(alltrim(upper(aLinha[7])),6)) =="BR","1","2")

			//+++++++ fim tratamento para C6_P_GEOG/C6_P_CODE/C6_P_ITEMD/C6_P_ITEMC/C6_P_VLC_C +++++++++++//
			elseif ALLTRIM(aHeader[nI,2]) =="C6_CODISS"	
				
				DbSelectArea("SB1") 
				DbSetOrder(1)
				if DbSeek(xFilial("SB1")+CANAL(alltrim(upper(aLinha[7])),2))

					aCols[Len(aCols),nI]:=SB1->B1_CODISS
                               
				else
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
				endif
				
			else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
	FT_FSkip() // Proxima linha
Enddo

If !EMPTY(cMsg)
	cMsg:= "Itens que não serão importados devido ao Valor PI:"+CHR(13)+CHR(10) + cMsg
	EECVIEW(cMsg)
EndIf

Return(lSair)

/*
Funcao      : GravaDados()  
Parametros  : aCols,aHeader
Retorno     : Nil
Objetivos   : Executar o Msexecauto da rotina MATA410
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/
*----------------------------------------------*
Static Function GravaDados(aCols,aHeader,nUsado)
*----------------------------------------------*
Local i
Local j
Local  nk

ProcRegua(0)

Private aDados:={}
Private aItem:={}
Private aItens:={}
Private aErros:={}
Private aGravado:={}
Private aAuxaCols:={}
Private lErro:=.F.

for j:=1 to len(aCols)
	if !aCols[j][len(aCols[j])]
		for i:=1 to len(aCols[j])-1
			if "C5_" $ aHeader[i][2]
				if !"C5_TPM" $ aHeader[i][2]
					AADD(aDados,{aHeader[i][2],	iif(valtype(aCols[j,i])=="C",alltrim(aCols[j,i]),aCols[j,i]),	nil})
			    endif
			else
				if !"C6_TPM" $ aHeader[i][2]
					AADD(aItem,	{aHeader[i][2],	iif(valtype(aCols[j,i])=="C",alltrim(aCols[j,i]),aCols[j,i]),	nil})
				endif
			endif
		next
	endif

	AADD(aItens,aItem)
	
	lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.

	MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aDados, aItens, 3) 	
	
	If lMsErroAuto         
		ROLLBACKSXE()
	    //MOSTRAERRO() // tela de erro do msexecauto mostra campo com o erro
	
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 

		//AADD(aErros,{alltrim(aDados[aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} )][2]),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
		if aScan( aDados, { |x| Left(alltrim(x[1]),3) == "C5_"} ) <> 0//JVR - 12/07/2012 - Alteração do tratamento - chamado 005476
	    	If (nPos := aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} ) ) <> 0
		    	AADD(aErros,{alltrim(aDados[nPos][2]),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
		 	Else
		 		AADD(aErros,{"INDEF."+" C5_","Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
		 	endif
		Else
			If (nPos := aScan( aDados, { |x| alltrim(x[1]) == "C6_PRODUTO"} ) ) <> 0
		    	AADD(aErros,{alltrim(aDados[nPos][2]),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
		 	Else
		 		AADD(aErros,{"INDEF."+" C6_","Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})
		 	endif
		EndIf
		
		AADD(aAuxaCols,Array(nUsado+1))
			
		for nk:=1 to nUsado+1
			aAuxaCols[len(aAuxaCols)][nK]:=aCols[j][nK]
		next
		
	    lErro:=.T.
	    DisarmTransaction()
	Else
		//AADD(aGravado,{alltrim(aDados[aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} )][2]),"OK","Inserido"})
		If aScan( aDados, { |x| Left(alltrim(x[1]),3) == "C5_"} ) <> 0 //JVR - 12/07/2012 - Alteração do tratamento - chamado 005476
	    	If (nPos := aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} ) ) <> 0
		    	AADD(aGravado,{alltrim(aDados[nPos][2]),"OK","Inserido"})
		 	endif
		Else
			If (nPos := aScan( aDados, { |x| alltrim(x[1]) == "C6_PRODUTO"} ) ) <> 0
		    	AADD(aGravado,{alltrim(aDados[nPos][2]),"OK","Inserido"})
		 	endif
		EndIf
		
		AADD(aGravado,{alltrim(aDados[aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} )][2]),"OK","Inserido"})
		ConfirmSx8()
	EndIF             
	
	aDados:={}
	aItem:={}
	aItens:={}
next

If lErro
	Situacao(aErros,aGravado)
	aCols:={}
	aCols:=aAuxaCols
	
Else
	msginfo("PROCESSADO COM SUCESSO!")
	oDlg:end()
EndIf

Return

/*
Funcao      : XLOG()  
Parametros  : aAutoErro
Retorno     : cRet
Objetivos   : Busca o erro gerado no msexecauto
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/
*-----------------------------*
Static Function XLOG(aAutoErro)
*-----------------------------*
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; "
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet

/*
Funcao      : FIELDOK49  
Parametros  : 
Retorno     : .T. or .F.
Objetivos   : Validar campos do aCols
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*-----------------------*
User Function FIELDOK49()
*-----------------------*
Local cEstCli1:=""
Local nTpAliq1:=0
Local cAliqCod:=""

if aHeader[oGetDados:oBrowse:ColPos][2]=="C5_CLIENTE"
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	if DbSeek(xFilial("SA1")+M->C5_CLIENTE+SA1->A1_LOJA)
		aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TPM_D2"})]:=substr(SA1->A1_NOME,1,30)
    	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_ITEM"})]:="01"
    	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TPM_D3"})]:=substr(SA1->A1_CGC,1,30)

       	cEstCli1:=SA1->A1_EST
                	
       	if alltrim(cEstCli1)=="EX
       		nTpALiq1:=2
       	elseif alltrim(cEstCli1)<>alltrim(GETMV("MV_ESTADO"))
       		nTpALiq1:=1
       	endif
       	
		dbSelectArea("SF4")
		DbSetOrder(1)
		if DbSeek(xFilial("SF4")+aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})])
			cAliqCod:=SF4->F4_CF
				       			
	    	//aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]:=alltrim(cvaltochar( val(substr(cAliqCod,1,1))+nTpALiq1 ))+substr(cAliqCod,2,4)
			aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]:= If( alltrim(cEstCli1)==alltrim(GETMV("MV_ESTADO")),'5',If( alltrim(cEstCli1)<>"EX",'6','7'))+;
																	substr(cAliqCod,2,4)	    	
		
		endif        

    endif

endif  

if alltrim(aHeader[oGetDados:oBrowse:ColPos][2])=="C5_VEND1"
	
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	if DbSeek(xFilial("SA3")+M->C5_VEND1)
		aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TPM_V2"})]:=substr(SA3->A3_NOME,1,30)
    endif

endif

if alltrim(aHeader[oGetDados:oBrowse:ColPos][2])=="C5_P_AGC"
	
	DbSelectArea("SZA")
	SZA->(DbSetOrder(1))
	if DbSeek(xFilial("SZA")+M->C5_P_AGC)
		aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_P_NMAGC"})]:=substr(SZA->ZA_NOME,1,30)
    endif

endif

Return(.T.)

/*
Funcao      : ValidaInfo  
Parametros  : aCols,aHeader
Retorno     : .T. or .F.
Objetivos   : Validar o botão Ok no MsGetDados
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*---------------------------------------*
Static Function ValidaInfo(aCols,aHeader)
*---------------------------------------*
Local lRet:=.T.
Local nSeq:=0
Local cMsgErro:=""
             
for nSeq:=1 to len(aCols)

if !aCols[nSeq][len(aCols[nSeq])]
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})])
		if !"Número," $ cMsgErro
			cMsgErro+="Número,"
	    endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TIPO"})])
		if !"Tipo," $ cMsgErro
			cMsgErro+="Tipo,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CLIENTE"})])
		if !"Cliente," $ cMsgErro
			cMsgErro+="Cliente,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_LOJACLI"})])
		if !"Loja," $ cMsgErro
			cMsgErro+="Loja,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CONDPAG"})])
		if !"Condição Pagamento," $ cMsgErro
			cMsgErro+="Condição Pagamento,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_P_PI"})])
		if !"PI," $ cMsgErro
			cMsgErro+="PI,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})])
		if !"Produto," $ cMsgErro
			cMsgErro+="Produto,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_ITEM"})])
		if !"Item," $ cMsgErro
			cMsgErro+="Item,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})])
		if !"Preco," $ cMsgErro
			cMsgErro+="Preco,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})])
		if !"Quantidade," $ cMsgErro
			cMsgErro+="Quantidade,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})])
		if !"Valor," $ cMsgErro
			cMsgErro+="Valor,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})])
		if !"TES," $ cMsgErro
			cMsgErro+="TES,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})])
		if !"CF," $ cMsgErro
		cMsgErro+="CF,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_P_AGC"})])
		if !"Agencia," $ cMsgErro
		cMsgErro+="Agencia,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CODISS"})])
		if !"Cod Servico," $ cMsgErro
		cMsgErro+="Cod Servico,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_VEND1"})])
		if !"Vendedor," $ cMsgErro
		cMsgErro+="Vendedor,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_CODE"})])
		if !"Company Code," $ cMsgErro
		cMsgErro+="Company Code,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_ITEMC"})])
		if !"Canal Cred," $ cMsgErro
		cMsgErro+="Canal Cred,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_ITEMD"})])
		if !"Canal Deb," $ cMsgErro
		cMsgErro+="Canal Deb,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_VLC_C"})])
		if !"Plataforma Cred," $ cMsgErro
		cMsgErro+="Plataforma Cred,"
		endif
	endif

	oGetDados:oBrowse:SetBlkBackColor({|| GETDCLR(aCols,n,aHeader,.T.)})	
endif

next

if !empty(cMsgErro)
	Alert("Existe(m) campo(s) obrigatório(s) não preenchido(s): "+substr(cMsgErro,1,RAT(",",cMsgErro)-1))
	lRet:=.F.
endif

Return(lRet)    

/*
Funcao      : GETDCLR()  
Parametros  : aLinha,nLinha,aHeader,lCtrl
Retorno     : Nil
Objetivos   : Função para tratamento das regras de cores para a grid da MsNewGetDados
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*--------------------------------------------------*
Static Function GETDCLR(aLinha,nLinha,aHeader,lCtrl)
*--------------------------------------------------*
Local nCor2 := RGB(192,192,192) //Cinza
Local nCor3 := 16777215 // Branco - RGB(255,255,255)
Local nCor4 := RGB(225,0,0)//RGB(255,083,083) //vermelho
Local nPosProd := aScan(aHeader,{|x| Alltrim(x[2]) == "C5_NUM"})
Local nUsado := Len(aHeader)+1
Local nRet := nCor3

	if lCtrl
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TIPO"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CLIENTE"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_LOJACLI"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CONDPAG"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_P_PI"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_ITEM"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_P_AGC"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CODISS"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_VEND1"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_CODE"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_ITEMC"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_ITEMD"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_P_VLC_C"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif

	endif

	If !Empty(aLinha[nLinha][nPosProd]) .AND. aLinha[nLinha][nUsado]
		nRet := nCor2
	ElseIf !Empty(aLinha[nLinha][nPosProd]) .AND. !aLinha[nLinha][nUsado] .AND. nRet<>nCor4
		nRet := nCor3
	Endif

Return nRet

/*
Funcao      : Situacao()  
Parametros  : aErros,aGravado
Retorno     : Nil
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*---------------------------------------*
Static Function Situacao(aErros,aGravado)           
*---------------------------------------*

Private _oDlg,oListBox
Private aListBox:={}

DEFINE MSDIALOG _oDlg TITLE "Pedidos" FROM C(178),C(180) TO C(665),C(966) PIXEL


	@ C(019),C(009) ListBox oListBox Fields HEADER "NUM PEDIDO", "SITUAÇÃO","DESCRIÇÃO" Size C(378),C(206) Of _oDlg Pixel
	@ C(230),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())
	
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
Funcao      : C  
Parametros  : nTam
Retorno     : Nil
Objetivos   : Função para tratar resolução da tela
Autor       : Matheus Massarotto
Data/Hora   : 14/02/2012
*/
*---------------------*
Static Function C(nTam)
*---------------------*
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
Funcao      : Render  
Parametros  : aCols
Retorno     : Nil
Objetivos   : Função que gera tela para inserir nova sequencia
Autor       : Matheus Massarotto
Data/Hora   : 15/02/2012
*/
*---------------------------*
Static Function Render(aCols)
*---------------------------*
// Variaveis Locais da Funcao
Local cEdit1	 := Space(6)
Local cEdit2	 := Space(1)
Local oEdit1
Local oEdit2
Local _oDlg1

DEFINE MSDIALOG _oDlg1 TITLE "Sequencia" FROM C(259),C(344) TO C(420),C(610) PIXEL

	// Cria as Groups do Sistema
	@ C(008),C(015) TO C(063),C(119) LABEL "Número sequencial" PIXEL OF _oDlg1

	// Cria Componentes Padroes do Sistema
	//RRP - 10/10/2013 - Ajuste para gerar a sequencia correta
	@ C(018),C(028) Say "Letra" COLOR CLR_BLACK PIXEL OF _oDlg1
	@ C(026),C(028) MsGet oEdit2 Var cEdit2 Picture "@X" COLOR CLR_BLACK PIXEL OF _oDlg1
	@ C(018),C(040) Say "Número" COLOR CLR_BLACK PIXEL OF _oDlg1
	@ C(026),C(040) MsGet oEdit1 Var cEdit1 Size C(060),C(009) Picture "999999" COLOR CLR_BLACK PIXEL OF _oDlg1
	@ C(043),C(051) Button "Gerar" action(processa({||PrecRender(@aCols,cEdit1,cEdit2),_oDlg1:end()})) Size C(037),C(012) PIXEL OF _oDlg1

ACTIVATE MSDIALOG _oDlg1 CENTERED 

Return

/*
Funcao      : PrecRender  
Parametros  : aCols,cNum, cNum2
Retorno     : Nil
Objetivos   : Função auxiliar a Render, para processar a sequencia informada na tela
Autor       : Matheus Massarotto
Data/Hora   : 15/02/2012
*/
*------------------------------------*
Static Function PrecRender(aCols,cNum,cNum2)
*------------------------------------*
Local u:=1

if MSGYESNO("Deseja realmente alterar a sequencia?")
	if !empty(Alltrim(cNum))
		
		//RRP - 10/10/2013 - Ajuste para gerar a sequencia correta	
		If Len(Alltrim(cNum)) < 6
			If Empty(Alltrim(cNum2))
				cNum:= StrZero(VAL(cNum),6)
			Else
				cNum:= StrZero(VAL(cNum),5)	
			EndIf
		EndIf

		for u:=1 to len(aCols) 
			ProcessMessages()
			aCols[u][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})]:=Alltrim(cNum2)+Alltrim(cNum)
			cNum:=SOMA1(cNum)
		next
	endif
endif

oGetDados:Refresh()
Return

/*
Funcao      : Canal  
Parametros  : cCodigo,nItem
Retorno     : cRet
Objetivos   : Função para retornar o Código Prod/Company Code/ Brand/ Platform/ Geographic/ G L Discovery de acordo com o canal passado
Autor       : Matheus Massarotto
Data/Hora   : 16/02/2012
*/
*----------------------------------*
Static Function Canal(cCodigo,nItem)  
*----------------------------------*
Local aStru:={}
Local cRet:=""
Local nLin:=0
/*
1-Canal
2-Código Prod
3-Company Code
4-Brand
5-Platform
6-Geographic
7-G L Discovery
*/

//Canal,Código Prod/Company Code/ Brand/ Platform/ Geographic/ G L Discovery
AADD(aStru,{"BL","DSC001","306","1700","120","BR","40310"})
AADD(aStru,{"KB","DSC002","306","2400","120","BR","40310"})
AADD(aStru,{"PB","DSC003","314","4100","120","BR","40310"})
AADD(aStru,{"AB","DSC004","324","1000","120","BR","40310"})
AADD(aStru,{"LT","DSC005","306","5000","120","BR","40310"})
AADD(aStru,{"BH","DSC006","306","3200","120","BR","40310"})   

AADD(aStru,{"PI-BL","DSC008","306","1700","210","BR","40050"})
AADD(aStru,{"PI-KB","DSC009","306","2400","210","BR","40050"})
AADD(aStru,{"PI-PB","DSC010","314","4100","210","BR","40050"})
AADD(aStru,{"PI-AB","DSC011","324","1000","210","BR","40050"})
AADD(aStru,{"PI-LT","DSC012","306","5000","210","BR","40050"})
AADD(aStru,{"PI-BH","DSC013","306","3200","210","BR","40050"})
AADD(aStru,{"LVB","DSC0015","314","4100","120","BR","40310"})
AADD(aStru,{"IDB","DSC016" ,"314","4100","120","BR","40310"})
AADD(aStru,{"BT","DSC017","307","5300","120","BR","40310"})
AADD(aStru,{"PI-BT","DSC018","307","5300","210","BR","40310"})//JSS - Add este canal para solucionar o caso 021903    

/*
	* Leandro Brito - 26/02/2018
	* Inclusao de novos canais
*/                            
AADD( aStru , { "EX-AB"  , "DSC023" , "307" , "1000" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-BH"  , "DSC021" , "307" , "3200" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-BL"  , "DSC020" , "307" , "1700" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-BT"  , "DSC025" , "307" , "5300" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-IDB" , "DSC026" , "307" , "3400" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-KB"  , "DSC022" , "307" , "2400" , "120" , "BR" , "40310" } )
AADD( aStru , { "EX-TLC" , "DSC024" , "307" , "4800" , "120" , "BR" , "40310" } )
AADD( aStru , { "PI-VIX" , "DSC019" , "307" , "9910" , "210" , "BR" , "40310" } )


//CAS - 31/08/2018 - Criação código de serviço no Microsiga - Food Network (Conforme e-mail enviado pela Camila) 
//Canal,Código Prod/Company Code/ Brand/ Platform/ Geographic/ G L Discovery
AADD( aStru , { "FN"  	 , "DSC028" , "307" , "7003" , "120" , "BR" , "40310" } )
AADD( aStru , { "PI-FN"  , "DSC029" , "307" , "7003" , "210" , "BR" , "40050" } )
AADD( aStru , { "EX-FN"  , "DSC030" , "307" , "7003" , "120" , "BR" , "40310" } ) 
AADD( aStru , { "BT-AB"	 , "DSC036" , "307" , "1000" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-BH"	 , "DSC037" , "307" , "3200" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-BL"  , "DSC031" , "307" , "1700" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-BT"	 , "DSC032" , "307" , "5300" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-IDB" , "DSC033" , "307" , "3400" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-KB"  , "DSC034" , "307" , "2400" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-TLC" , "DSC035" , "307" , "4800" , "120" , "BR" , "40310" } )
AADD( aStru , { "BT-FN"  , "DSC038" , "307" , "7003" , "120" , "BR" , "40310" } )


AADD(aStru,{"SERVICOS","SERVICOS","306","","120","BR","40310"})


nLin:=aScan(aStru,{|x|AllTrim(x[1])==alltrim(upper(cCodigo))})
if nLin<>0
	cRet:=aStru[nLin][nItem]
endif

Return(cRet)