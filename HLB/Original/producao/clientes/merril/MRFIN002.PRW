#Include "rwmake.ch" 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Programa  � MRFIN002 .PRW � Autor � Jo�o dos Silva � Data � 16/09/2013 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao �Fonte criado para facilitar o get das informa��es do sistema���
���           �e para realizar o subtra��o dos impos do valor total do titu���
���           �lo antes de enviar o cnab para o banco.                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � FINANCEIRO    este                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/    

/*
Funcao      : MRFIN002()
Parametros  : _nOpc
Retorno     : _cRet
Objetivos   : Fonte criado para facilitar o get das informa��es do sistemae para realizar o subtra��o dos impos do valor total do titulo antes de enviar o cnab para o banco.  
Autor       : 
TDN         : 
Revis�o     : Jo�o Silva 
Data/Hora   : 24/03/2014
M�dulo      : Financeiro.
*/ 

User Function MRFIN002(nOpc)      

Local cRet      := ""
Local _nVlrAbat := 0
Local _nValor   := 0

//����������������������������������������������������Ŀ
//�Retorna o Endereco do cliente    				   �
//������������������������������������������������������
If nOpc == 1 
    cRet:= Substr(SA1->A1_END,1,40)
Endif

//����������������������������������������������������Ŀ
//�Retorna o Bairro do Cliente  �
//������������������������������������������������������
IF nOpc == 2
    cRet:= substr(SA1->A1_BAIRRO,1,12)
Endif

//����������������������������������������������������Ŀ
//�Retorna o Municipio						   �
//������������������������������������������������������
IF nOpc == 3          
    cRet:=Substr(SA1->A1_MUN,1,15)
Endif

//����������������������������������������������������Ŀ
//�Retorna o Valor do titulo a ser pago                �
//������������������������������������������������������

IF nOpc == 4
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := SE1->E1_SALDO - _nVlrAbat
    cRet      := STRZERO((_nValor*100),13,0)                           
Endif

//����������������������������������������������������Ŀ
//�Retorna do Valor de Mora                            �
//������������������������������������������������������

IF nOpc == 5
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := ((SE1->E1_SALDO - _nVlrAbat)*0.05)/30
    cRet      := Strzero(_nValor,13,0)
Endif

Return(cRet)      
