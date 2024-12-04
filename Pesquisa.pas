unit Pesquisa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Data.Win.ADODB, Vcl.Buttons;

type
  TFormPesquisa = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    EditPesquisar: TEdit;
    ADOPesquisa: TADOQuery;
    DSPesquisa: TDataSource;
    Label1: TLabel;
    ADOPesquisaCodigoBarras: TWideStringField;
    ADOPesquisaNome: TWideStringField;
    ADOPesquisaDescricao: TWideStringField;
    BitBtnPesquisar: TBitBtn;
    BitBtnCancelar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure BitBtnPesquisarClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPesquisa: TFormPesquisa;

implementation

{$R *.dfm}

uses VendaFc;

procedure TFormPesquisa.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
end;

procedure TFormPesquisa.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Atalho para pesquisar (F2)
  if Key = VK_F2 then
  begin
    BitBtnPesquisar.Click;
  end;

  // Atalho para cancelar (ESC)
  if Key = VK_ESCAPE then
  begin
    BitBtnCancelar.Click;
  end;
end;

procedure TFormPesquisa.BitBtnCancelarClick(Sender: TObject);
begin
  Close;
end;

// Realiza a ação de Consultar Produtos
procedure TFormPesquisa.BitBtnPesquisarClick(Sender: TObject);
begin
   ADOPesquisa.Close;
   ADOPesquisa.SQL.Clear;
   ADOPesquisa.SQL.Add('SELECT CodigoBarras, Nome, Descricao FROM Produto WHERE Nome like :pNomeProduto');
   ADOPesquisa.Parameters.ParamByName('pNomeProduto').Value:= '%'+ EditPesquisar.text + '%';
   ADOPesquisa.open;

    IF ADOPesquisa.RecordCount>0 then
      begin
         DBGrid1.Enabled:=True;
         DBGrid1.SetFocus;
      end
        Else
          begin
            DBGrid1.Enabled:=False;
            Application.MessageBox('Produto não encontrado', 'HM Ferreira Costa', MB_ICONINFORMATION+MB_OK);
          end;
end;

// Procedimento ao dar duplo clique em um item no grid
procedure TFormPesquisa.DBGrid1DblClick(Sender: TObject);
begin
  FormVenda.EditCodBarras.Text:= DBGrid1.Columns.Items[0].Field.Value;
  FormVenda.EditCodBarras.SetFocus;
  FormVenda.EditCodBarras.SelStart:=Length(FormVenda.EditCodBarras.Text);
  close;
end;
end.

