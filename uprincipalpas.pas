unit uPrincipalpas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Regexpr, FileUtil, Process;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    btnHabilitar: TButton;
    btnDesabilitar: TButton;
    Image1: TImage;
    Label1: TLabel;
    listAPP: TListBox;
    procedure btnHabilitarClick(Sender: TObject);
    procedure btnDesabilitarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    class function buscaaplicativosMAC: TStringList;
    class function nomerealapp(nomeAPP :string):string;
    class procedure execTrocaDarkMode(APP :string; habilitado :boolean);

  end;

var
  frmPrincipal: TfrmPrincipal;

resourcestring
  MSGNENHUMAAPPSELECIONADA = 'É necessário selecionar um Aplicativo';
  MSGDARKMODETROCADO = 'Comando Executado com sucesso';

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.btnHabilitarClick(Sender: TObject);
begin
  if listAPP.GetSelectedText = '' then
  begin
    ShowMessage(MSGNENHUMAAPPSELECIONADA); Exit;
  end;
  execTrocaDarkMode(listAPP.GetSelectedText, true);
end;

procedure TfrmPrincipal.btnDesabilitarClick(Sender: TObject);
begin
  if listAPP.GetSelectedText = '' then
  begin
    ShowMessage(MSGNENHUMAAPPSELECIONADA); Exit;
  end;
  execTrocaDarkMode(listAPP.GetSelectedText, false);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  listAPP.Clear;
  listAPP.Items := buscaaplicativosMAC;
end;

class function TfrmPrincipal.buscaaplicativosMAC: TStringList;
var
  expressaoregex :string;
  Aplicativos :TStringList;
  contador :integer;
  validaregex :TRegExpr;

begin
  expressaoregex:= '(\/Applications\/)(.*)(\.app)';

  try
    Aplicativos := TStringList.Create;
    validaregex := TRegExpr.Create(expressaoregex);

    FindAllDirectories(Aplicativos, '/Applications', false);

    for contador := 0 to Aplicativos.Count -1 do
    begin

      if validaregex.Exec(Aplicativos[contador]) then
      begin
        Aplicativos[contador] :=
        ReplaceRegExpr(expressaoregex, Aplicativos[contador], '$2', true);
      end
      else
        Aplicativos[contador] := '';
    end;

    contador := 0;

    while contador < Aplicativos.Count do
      begin
        if Length(Aplicativos[contador]) = 0 then
          Aplicativos.Delete(contador)
        else
          Inc(contador);
      end;

      Result := Aplicativos;

  finally
    //FreeAndNil(Aplicativos);
  end;

end;

class function TfrmPrincipal.nomerealapp(nomeAPP: string): string;
var
  saida :string;
begin
  RunCommand('/bin/bash',['-c', 'osascript -e' +
             QuotedStr('id of app '+ '"' +
             nomeAPP + '"')],saida);
  Result := saida;
end;

class procedure TfrmPrincipal.execTrocaDarkMode(APP: string; habilitado: boolean
  );
var
  ativa :string;
  saida :string;
begin


  if habilitado then ativa:= 'no' else ativa:= 'yes';

  try
    RunCommand('/bin/bash',['-c', 'defaults write ' +
    Trim(nomerealapp(APP)) +
               ' NSRequiresAquaSystemAppearance -bool ' + ativa],saida);

  finally
    ShowMessage(MSGDARKMODETROCADO);
  end;

end;

end.

