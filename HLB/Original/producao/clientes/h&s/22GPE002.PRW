#include "PROTHEUS.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GP410DES  �Autor  �ROBERTO R.MEZZALIRA � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  PONTO DE ENTRADA PARA DEFINIR OS REGISTROS VALIDOS POR    ���
���          �  LAYOUT                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function GP410DES()
LOCAL   nVlr := 0
LOCAL   nOP  := 0
PRIVATE lCod
//DEFINE A OPERACAO PELO NOME DO LAYOUT TED/DOC
DO CASE
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONTED.2RE'
		nOP  := 1
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONDOC.2RE'
		nOP  := 2
    CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETTED.2RE'
		nOP  := 3
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETDOC.2RE'  
		nOP  := 4 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCON.2RE'
	    nOP  := 5 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNET.2RE'  
		nOP  := 6		
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'SANTDOC.PAG'
	    nOP  := 7 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'SANTTED.PAG'  
		nOP  := 8		

    OTHERWISE
        nOP  := 0
ENDCASE

if nOp==0
   lCod:=.t.
else
   lCod:=.f.

	
	//SELECIONA OS REGISTROS VALIDOS
	DO CASE 

		CASE nOP == 1 .AND. NVALOR >= 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 
		CASE nOP == 2 .AND. NVALOR < 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T. 
		CASE nOP == 3 .AND. NVALOR >= 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 	
		CASE nOP == 4 .AND. NVALOR < 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
		CASE nOP == 5 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.   
		CASE nOP == 6 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
   		CASE nOP == 7 .AND. NVALOR >= 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 	
		CASE nOP == 8 .AND. NVALOR < 3000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
	
		
		ENDCASE

endif
   
Return(lCod)      
