{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }

{ Direitos Autorais Reservados (c) 2004 Daniel Simoes de Almeida               }

{ Colaboradores nesse arquivo:                                                 }

{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }

{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }

{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }

{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/gpl-license.php                           }

{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }

{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 20/04/2013:  Daniel Sim�es de Almeida
|*   Inicio do desenvolvimento
******************************************************************************}

{$I ACBr.inc}

unit ACBrEscPosEpson;

interface

uses
  Classes, SysUtils, ACBrPosPrinter;

type

  { TACBrEscPosEpson }

  TACBrEscPosEpson = class(TACBrPosPrinterClass)
  private
  protected
    function ComandoCodBarras(const ATag: String; ACodigo: AnsiString): AnsiString;
      override;
    function ComandoQrCode(ACodigo: AnsiString): AnsiString; override;
    function ComandoEspacoEntreLinhas(Espacos: Byte): AnsiString; override;
    function ComandoPaginaCodigo(APagCodigo: TACBrPosPaginaCodigo): AnsiString;
      override;

  public
    constructor Create(AOwner: TACBrPosPrinter);
  end;


implementation

uses
  strutils, math,
  ACBrConsts, ACBrUtil;

{ TACBrEscPosEpson }

constructor TACBrEscPosEpson.Create(AOwner: TACBrPosPrinter);
begin
  inherited Create(AOwner);

  fpModeloStr := 'EscPosEpson';

{(*}
  with Cmd  do
  begin
    Zera                    := ESC + '@';
    EspacoEntreLinhasPadrao := ESC + '2';
    EspacoEntreLinhas       := ESC + '3';
    FonteNormal             := ESC + '!' + #0;
    FonteA                  := ESC + 'M' + #0;
    FonteB                  := ESC + 'M' + #1;
    LigaNegrito             := ESC + 'E' + #1;
    DesligaNegrito          := ESC + 'E' + #0;
    LigaExpandido           := GS  + '!' + #16;
    DesligaExpandido        := GS  + '!' + #0;
    LigaSublinhado          := ESC + '-' + #1;
    DesligaSublinhado       := ESC + '-' + #0;
    LigaInvertido           := GS  + 'B' + #1;
    DesligaInvertido        := GS  + 'B' + #0;
    LigaItalico             := '';        // N�o existe ?
    DesligaItalico          := '';        // N�o existe ?
    LigaCondensado          := FonteB;
    DesligaCondensado       := FonteA;
    AlinhadoEsquerda        := ESC + 'a' + #0;
    AlinhadoCentro          := ESC + 'a' + #1;
    AlinhadoDireita         := ESC + 'a' + #2;
    CorteTotal              := GS  + 'V' + #0;
    CorteParcial            := GS  + 'V' + #1;
    AbreGaveta              := ESC + 'p' + #0 + #10 + #100;
    ImprimeLogo             := GS  + '(L'#6#0'0E  '#1#1;  //TODO: Testar
    Beep                    := ESC + '(A' + #4 + #0 + #48 + #55 + #3 + #10;  // TODO: Testar

    TransmiteID             := '';  //TODO:
    TransmiteStatus         := '';  //TODO:
  end;
  {*)}
end;

function TACBrEscPosEpson.ComandoCodBarras(const ATag: String;
  ACodigo: AnsiString): AnsiString;
var
  L, A, M : Integer ;
  CmdBarCode: Char;
  ACodBar, Cmd128: AnsiString;
begin
  if ATag = cTagBarraUPCA then
    CmdBarCode := 'A'
  else if ATag = cTagBarraEAN13 then
    CmdBarCode := 'C'
  else if ATag = cTagBarraEAN8 then
    CmdBarCode := 'D'
  else if ATag = cTagBarraCode39 then
    CmdBarCode := 'E'
  else if ATag = cTagBarraInter then
    CmdBarCode := 'F'
  else if ATag = cTagBarraCodaBar then
    CmdBarCode := 'G'
  else if ATag = cTagBarraCode93 then
    CmdBarCode := 'H'
  else if (ATag = cTagBarraCode128) or (ATag = cTagBarraCode128b) then
  begin
    CmdBarCode := 'I';
    Cmd128 := '{B';
  end
  else if ATag = cTagBarraCode128a then
  begin
    CmdBarCode := 'I';
    Cmd128 := '{A';
  end
  else if ATag = cTagBarraCode128c then
  begin
    CmdBarCode := 'I';
    Cmd128 := '{C';
  end
  else if ATag = cTagBarraMSI then     // Apenas Bematech suporta
    CmdBarCode := 'R'
  else
  begin
    Result := ACodigo;
    Exit;
  end;

  ACodBar := ACodigo;

  if CmdBarCode = 'I' then // Cod128
  begin
    if LeftStr(ACodBar,1) <> '{' then
      ACodBar := Cmd128 + ACodBar;
  end;

  with fpPosPrinter.ConfigBarras do
  begin
    L := IfThen( LarguraLinha = 0, 3, max(min(LarguraLinha,4),2) );
    A := IfThen( Altura = 0, 50, max(min(Altura,255),1) );
    M := IfThen( MostrarCodigo, 2, 0 );
  end ;

  Result := GS + 'w' + chr( L ) + // Largura
            GS + 'h' + chr( A ) + // Altura
            GS + 'H' + chr( M ) + // HRI (numero impresso abaixo do cod.barras)
            GS + 'k' + CmdBarCode + chr( Length(ACodBar) ) + ACodBar;
end;

function TACBrEscPosEpson.ComandoQrCode(ACodigo: AnsiString): AnsiString;
begin
  with fpPosPrinter.ConfigQRCode do
  begin
     Result := GS + '(k' + #4 + #0 + '1A' + IntToStr(Tipo) + #0 +  // Tipo
               GS + '(k' + #3 + #0 + '1C' + chr(LarguraModulo) +   // Largura Modulo
               GS + '(k' + #3 + #0 + '1E' + IntToStr(ErrorLevel) + // Error Level
               GS + '(k' + IntToLEStr(length(ACodigo)+3)+'1P0' + ACodigo +  // Codifica
               GS + '(k' + #3 + #0 +'1Q0';  // Imprime
  end;
end;

function TACBrEscPosEpson.ComandoEspacoEntreLinhas(Espacos: Byte): AnsiString;
begin
  if Espacos = 0 then
    Result := Cmd.EspacoEntreLinhasPadrao
  else
    Result := Cmd.EspacoEntreLinhas + chr(Espacos);
end;

function TACBrEscPosEpson.ComandoPaginaCodigo(APagCodigo: TACBrPosPaginaCodigo
  ): AnsiString;
var
  CmdPag: Integer;
begin
  case APagCodigo of
    pc437: CmdPag := 0;
    pc850: CmdPag := 2;
    pc852: CmdPag := 18;
    pc860: CmdPag := 3;
    pc1252: CmdPag := 16;
  else
    begin
      Result := '';
      Exit;
    end;
  end;

  Result := ESC + 't' + chr( CmdPag );
end;

end.

