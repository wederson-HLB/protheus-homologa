
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTGPE027 ºAutor  ³Francisco Neto Data ³  01/03/17           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada no calculo de Folha de Pagamento para     º±±
±±º          ³ geracao automática do valor de Previdencia Privada         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Clientes GT (Previdencia Privada)               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function GTGPE027()

	private nmeses := 0
	private _Percent := SRA->RA_P_PERPP
	private datahum := SRA->RA_ADMISSA   
	private _FIL := SRA->RA_FILIAL
	private _MAT := SRA->RA_MAT

	private datadois := DDATABASE     
	private mes := val(right(cFolmes,2))
	private cValor := 0

	Private cPeriodo    := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
	
	If subs(cPeriodo,1,2) $ "04/06/09/11"
		datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
	Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
		datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
	Elseif subs(cPeriodo,1,2) $ "02"
		If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
			datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
		Else
			datadois := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
		Endif
	Endif

	datatres := subs(datadois,7,2)+"/"+subs(datadois,5,2)+"/"+subs(datadois,1,4)
	nmeses := DateDiffMonth( datahum , datatres ) 

	nOrdem := RetOrder( "SMU" , "MU_FILIAL+MU_MAT+MU_CODFOR+MU_PERINI" , .T. )
	SMU->( dbSetOrder( nOrdem )	)
	SMU->( dbSeek ( xFilial("SMU")+_MAT+""+ "" ) )
	
	While SMU->(! Eof() ) .AND. xFilial("SMU") = _FIL .AND. SMU->MU_MAT == _MAT 
		IF SUBSTR(cPeriodo,1,2)+SUBSTR(cPeriodo,4,4) >= SMU->MU_PERINI .AND. SUBSTR(cPeriodo,1,2)+SUBSTR(cPeriodo,4,4) <= SMU->MU_PERFIM
			nLINHA := FPOSTAB("S073",SMU->MU_CODFOR,"==",4)
			IF nLINHA > 0
				nVerba := FTABELA("S073",NLINHA,9)
				if _Percent > 0
					IF ((_Percent*salario)/100) >= M_MINPREVP    // valor minimo para desconto Prev Priv
						fGeraVerba(nVerba,((_Percent*salario)/100), , , , , , , , ,.T.) 
                    ENDIF
				endif	
		    ENDIF
	    ENDIF 
	   	dbSelectArea("SMU")
		SMU->( dbSkip())
	Enddo

return

