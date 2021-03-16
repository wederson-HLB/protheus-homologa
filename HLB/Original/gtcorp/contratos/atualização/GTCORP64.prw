#include "Protheus.ch"

/*
Funcao      : GTCORP64
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para liberar acessos ao contratos.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 27/03/2012    15:54
Módulo      : Gestão de Contratos
*/

*--------------------*
User Function GTCORP64
*--------------------*
// Variaveis Locais da Funcao
Local aComboBx1	:= {""}
Local aComboBx2	:= {""}
Local cComboBx1	:= ""
Local cComboBx2	:= ""
Local cGet1	 := Space(25)
Local cGet2	 := Space(25)
Local cGet3	 := Space(2)
Local cGet4	 := Space(2)
Local oGet1
Local oGet2
Local oGet3
Local oGet4

Local aComboAux	:= {}
Local aCombo2Aux:= {}
Local cGrupo	:= ""
Local cUsuario	:= ""

//Carregando todos os grupos
aComboAux	:= AllGroups()
//Ajustando array para um aceitável a apresentação no combobox
for i:=1 to len(aComboAux)
	cGrupo:=""
	for l:=1 to len(aComboAux[i])
		for c:=1 to len(aComboAux[i][l])
			if c<>1
				cGrupo+=" - "
			endif
			cGrupo+=alltrim(aComboAux[i][l][c])
		next		
	next
	AADD(aComboBx1,cGrupo)
next
    


//Carregando todos os usuários
aCombo2Aux	:= AllUsers()
//Ajustando array para um aceitável a apresentação no combobox
for i:=1 to len(aCombo2Aux)
	cUsuario:=""
		for c:=1 to 2//len(aCombo2Aux[i][l])
			if c<>1
				cUsuario+=" - "
			endif
			cUsuario+=alltrim(aCombo2Aux[i][1][c])
		next		
	AADD(aComboBx2,cUsuario)
next

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

DEFINE MSDIALOG oDlg TITLE "Liberar permissoes" FROM C(206),C(231) TO C(576),C(571) PIXEL

		// Cria as Groups do Sistema
	@ C(006),C(010) TO C(070),C(160) LABEL "Contrato" PIXEL OF oDlg
	@ C(073),C(010) TO C(111),C(160) LABEL "Liberar acesso para" PIXEL OF oDlg
	@ C(116),C(010) TO C(157),C(159) LABEL "Liberar acesso para" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(015),C(043) MsGet oGet3 Var cGet3 Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	@ C(017),C(016) Say "Filial de:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(027),C(043) MsGet oGet4 Var cGet4 Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	@ C(028),C(016) Say "Filial ate:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(041),C(043) MsGet oGet1 Var cGet1 Size C(077),C(009) COLOR CLR_BLACK Picture "@!" F3 "CN9" PIXEL OF oDlg
	@ C(042),C(016) Say "De:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(055),C(043) MsGet oGet2 Var cGet2 Size C(077),C(009) COLOR CLR_BLACK Picture "@!" F3 "CN9" PIXEL OF oDlg
	@ C(056),C(016) Say "Ate:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(090),C(036) ComboBox cComboBx1 Items aComboBx1 Size C(114),C(010) PIXEL OF oDlg
	@ C(091),C(016) Say "Grupo" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(132),C(049) ComboBox cComboBx2 Items aComboBx2 Size C(072),C(010) PIXEL OF oDlg
	@ C(133),C(016) Say "Usuario" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(164),C(062) Button "Executar" Size C(037),C(012) action(iif(MsgYesNo("Deseja processar os contratos filtrados?"), Barra(cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2),"")) PIXEL OF oDlg
	

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)


/*
Funcao      : Barra()  
Parametros  : cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2
Retorno     : 
Objetivos   : Função para apresentação da barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 26/03/2013
*/
*----------------------------------------------------------------*
Static Function Barra(cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2)
*----------------------------------------------------------------*
Local cQry		:= ""
Local nQtde		:= 0
Private oDlgBar

	cQry:=" SELECT count(*) AS QTDE FROM "+RETSQLNAME("CN9")
	cQry+="	WHERE CN9_NUMERO BETWEEN '"+cGet1+"' AND '"+cGet2+"' AND D_E_L_E_T_='' AND CN9_FILIAL BETWEEN '"+cGet3+"' AND '"+cGet4+"'" 


		if select("TRBQRY")>0
			TRBQRY->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "TRBQRY", .F., .F. )
		
		DbSelectArea("TRBQRY")

	    
		Count to nRecCount

		if nRecCount> 0
			TRBQRY->(DbGoTop())
			nQtde:=TRBQRY->QTDE
		endif

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlgBar TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nQtde,oDlgBar,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlgBar CENTERED ON INIT(Libera(cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2,oMeter,oDlgBar))
	  
	//*************************************


Return

/*
Funcao      : C()  
Parametros  : nTam
Retorno     : nTam
Objetivos   : Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario. 
Autor       : Matheus Massarotto
Data/Hora   : 26/03/2013
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
Funcao      : Libera()  
Parametros  : cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2,oMeter,oDlgBar
Retorno     : 
Objetivos   : Funcao para liberar os acessos aos contratos selecionados 
Autor       : Matheus Massarotto
Data/Hora   : 27/03/2013
*/

*--------------------------------------------------------------------------------*
Static function Libera(cGet1,cGet2,cGet3,cGet4,cComboBx1,cComboBx2,oMeter,oDlgBar)
*--------------------------------------------------------------------------------*
Local cQry		:= ""
Local cGrupo	:= Substr(cComboBx1,1,6)
Local cUsuario	:= Substr(cComboBx2,1,6)

	//Inicia a régua
	oMeter:Set(0)

	cQry:=" SELECT CN9_FILIAL,CN9_NUMERO FROM "+RETSQLNAME("CN9")
	cQry+="	WHERE CN9_NUMERO BETWEEN '"+cGet1+"' AND '"+cGet2+"' AND D_E_L_E_T_='' AND CN9_FILIAL BETWEEN '"+cGet3+"' AND '"+cGet4+"'" 
	cQry+="	GROUP BY CN9_FILIAL,CN9_NUMERO

		if select("TRBQRY")>0
			TRBQRY->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "TRBQRY", .F., .F. )
		
		DbSelectArea("TRBQRY")

	    
		Count to nRecCount

		if nRecCount> 0
			TRBQRY->(DbGoTop())		

			While TRBQRY->(!EOF())
            
           	    //Processamento da régua
				nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
				nCurrent+=1 // atualiza régua
				oMeter:Set(nCurrent) //seta o valor na régua
                
                //PERMISSÃO PARA O GRUPO
				if !empty(cGrupo)
					DbSelectArea("CNN")
					CNN->(DbSetOrder(2))
					if !CNN->(DbSeek(TRBQRY->CN9_FILIAL+cGrupo+TRBQRY->CN9_NUMERO))
					    RecLock("CNN",.T.)
					    	CNN->CNN_FILIAL:=TRBQRY->CN9_FILIAL
					    	CNN->CNN_CONTRA:=TRBQRY->CN9_NUMERO
					    	CNN->CNN_GRPCOD:=cGrupo
					    	CNN->CNN_TRACOD:="001"
					    CNN->(MsUnlock())
					endif
			    endif
                //PERMISSÃO PARA O USUÁRIO
			    if !empty(cUsuario)
					DbSelectArea("CNN")
					CNN->(DbSetOrder(1))
					if !CNN->(DbSeek(TRBQRY->CN9_FILIAL+cUsuario+TRBQRY->CN9_NUMERO))
					    RecLock("CNN",.T.)
					    	CNN->CNN_FILIAL:=TRBQRY->CN9_FILIAL
					    	CNN->CNN_CONTRA:=TRBQRY->CN9_NUMERO
					    	CNN->CNN_GRPCOD:=cUsuario
					    	CNN->CNN_TRACOD:="001"
					    CNN->(MsUnlock())
					endif			    
			    endif
				TRBQRY->(DbSkip())
			Enddo
		endif

MsgInfo("Acessos liberados!")
oDlgBar:End()

Return