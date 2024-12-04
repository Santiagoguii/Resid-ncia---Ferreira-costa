unit VendaFc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient, Data.Win.ADODB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.DBXMySQL, Data.SqlExpr,
  Vcl.Mask, Vcl.DBCtrls, Vcl.Menus, Vcl.Buttons;

type
  TFormVenda = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    Image2: TImage;
    EditCodBarras: TEdit;
    EditQtde: TEdit;
    LabelProdutocod: TLabel;
    LabelQtde: TLabel;
    Label10: TLabel;
    DSProduto: TDataSource;
    DSClient: TDataSource;
    ClientDataSet1: TClientDataSet;
    ClientDataSet1CodigoBarras: TStringField;
    ClientDataSet1NomeProduto: TStringField;
    ClientDataSet1PrecoProduto: TCurrencyField;
    ClientDataSet1Quantidade: TIntegerField;
    ClientDataSet1Subtotal: TCurrencyField;
    ClientDataSet1Totalgeral: TAggregateField;
    Conexao: TADOConnection;
    ADOProduto: TADOQuery;
    ADOProdutoCodigo: TIntegerField;
    ADOProdutoNome: TWideStringField;
    ADOProdutoPrecoUnitario: TBCDField;
    ADOProdutoCodigoBarras: TWideStringField;
    DBGrid1: TDBGrid;
    DBEdit1: TDBEdit;
    Panel3: TPanel;
    Label6: TLabel;
    DBEdit2: TDBEdit;
    ClientDataSet1ICMS: TCurrencyField;
    ClientDataSet1IPI: TCurrencyField;
    ClientDataSet1Total: TCurrencyField;
    EditRemover: TEdit;
    LabelRemover: TLabel;
    ADOQueryPedido: TADOQuery;
    ADOQueryItens: TADOQuery;
    ADOQueryPedidoConsulta: TADOQuery;
    ClientDataSet1Descricao: TStringField;
    LabelTProdutos: TLabel;
    LabelTLoja_Cliente: TLabel;
    EditLoja: TEdit;
    LabelLoja: TLabel;
    EditCliente: TEdit;
    LabelCliente: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BitBtnRemover: TBitBtn;
    BitBtnPesquisa: TBitBtn;
    BitBtnCancelar: TBitBtn;
    BitBtnFinalzar: TBitBtn;
    procedure EditCodBarrasKeyPress(Sender: TObject; var Key: Char);
    procedure EditCodBarrasKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditCodBarrasExit(Sender: TObject);
    procedure EditQtdeExit(Sender: TObject);
    procedure EditQtdeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditClienteKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtnRemoverClick(Sender: TObject);
    procedure BitBtnPesquisaClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure BitBtnFinalzarClick(Sender: TObject);
  private
    { Private declarations }
     NumeroNota: Integer; // Variável para armazenar o número da nota
  public
    { Public declarations }
  end;

var
  FormVenda: TFormVenda;

implementation

{$R *.dfm}

uses Pesquisa;

// Atalhos do teclado

procedure TFormVenda.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
end;

procedure TFormVenda.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Atalho para pesquisar (F2)
  if Key = VK_F2 then
  begin
    BitBtnPesquisa.Click;
  end;

  // Atalho para remover (F3)
  if Key = VK_F3 then
  begin
    BitBtnRemover.Click;
  end;

  // Atalho para cancelar (ESC)
  if Key = VK_ESCAPE then
  begin
    BitBtnCancelar.Click;
  end;

  // Atalho para finalizar (F10)
  if Key = VK_F10 then
  begin
    BitBtnFinalzar.Click;
  end;
end;

procedure TFormVenda.BitBtnPesquisaClick(Sender: TObject);
begin
  FormPesquisa.ShowModal;
end;

procedure TFormVenda.BitBtnRemoverClick(Sender: TObject);
var
  QuantidadeAtual, QuantidadeRemover: Integer;
begin
  // Verifica se o ClientDataSet está ativo e se há uma linha selecionada
  if (ClientDataSet1.Active) and (not ClientDataSet1.IsEmpty) then
  begin
    // Obtém a quantidade atual do produto selecionado
    QuantidadeAtual := ClientDataSet1.FieldByName('Quantidade').AsInteger;

    // Verifica se o Edit do Remover tem um valor válido
    if (EditRemover.Text = '') or (StrToIntDef(EditRemover.Text, 0) <= 0) then
    begin
      ShowMessage('Digite uma quantidade válida para remover.');
      Exit;
    end;

    // Converte a quantidade a ser removida
    QuantidadeRemover := StrToInt(EditRemover.Text);

    // Verifica se a quantidade a ser removida é válida
    if QuantidadeRemover >= QuantidadeAtual then
    begin
      // Remove o produto da lista
      ClientDataSet1.Delete;

      // Exibe a mensagem de sucesso
      ShowMessage('Produto removido com Sucesso!');

      // Limpa o campo de entrada de quantidade
      EditRemover.Clear;
      Exit;
    end;

    // Subtrai a quantidade e atualiza o ClientDataSet
    ClientDataSet1.Edit;
    ClientDataSet1.FieldByName('Quantidade').AsInteger := QuantidadeAtual - QuantidadeRemover;
    ClientDataSet1.FieldByName('SubTotal').AsFloat :=
      ClientDataSet1.FieldByName('PrecoProduto').AsFloat *
      ClientDataSet1.FieldByName('Quantidade').AsInteger;

    // Atualiza o ICMS, IPI e Total
    ClientDataSet1.FieldByName('ICMS').AsFloat :=
      ClientDataSet1.FieldByName('SubTotal').AsFloat * 0.17;
    ClientDataSet1.FieldByName('IPI').AsFloat :=
      ClientDataSet1.FieldByName('SubTotal').AsFloat * 0.10;
    ClientDataSet1.FieldByName('Total').AsFloat :=
      ClientDataSet1.FieldByName('SubTotal').AsFloat +
      ClientDataSet1.FieldByName('ICMS').AsFloat +
      ClientDataSet1.FieldByName('IPI').AsFloat;

    // Salva as alterações
    ClientDataSet1.Post;

    // Se a quantidade atual for 0, remove a linha
    if ClientDataSet1.FieldByName('Quantidade').AsInteger = 0 then
      ClientDataSet1.Delete;

    // Limpa o campo de entrada de quantidade
    EditRemover.Clear;
    ShowMessage('Quantidade Removida com Sucesso!');
  end
  else
  begin
    ShowMessage('Nenhum produto selecionado.');
  end;
end;

procedure TFormVenda.BitBtnCancelarClick(Sender: TObject);
begin
  ShowMessage('Operação cancelada. Retornando à tela principal.');
  Close;
end;

procedure TFormVenda.BitBtnFinalzarClick(Sender: TObject);
var
  NotaGerada: string;
  NumeroLoja: Integer;
  Cliente: string;
begin
  try
    // Verificar se os campos obrigatórios estão preenchidos
    if Trim(EditLoja.Text) = '' then
    begin
      ShowMessage('Por favor, insira o número da loja.');
      Exit;
    end;

    if Trim(EditCliente.Text) = '' then
    begin
      ShowMessage('Por favor, insira o nome do cliente.');
      Exit;
    end;

    NumeroLoja := StrToInt(EditLoja.Text);
    Cliente := EditCliente.Text;

    // Verifica se a conexão está ativa
    if not Conexao.Connected then
      Conexao.Open;

    Conexao.BeginTrans;

    // Inserir a nova venda (Data Atual)
    ADOQueryPedido.SQL.Text := 'INSERT INTO SfcPedidoVenda (DataMovim, Loja, Cliente) VALUES (GETDATE(), :Loja, :Cliente)';
    ADOQueryPedido.Parameters.ParamByName('Loja').Value := NumeroLoja;
    ADOQueryPedido.Parameters.ParamByName('Cliente').Value := Cliente;
    ADOQueryPedido.ExecSQL;

    // Recuperar a Nota gerada automaticamente
    ADOQueryPedido.SQL.Text := 'SELECT TOP 1 Nota FROM SfcPedidoVenda ORDER BY Nota DESC';
    ADOQueryPedido.Open;
    NotaGerada := ADOQueryPedido.FieldByName('Nota').AsString;

    // Inserir itens do pedido na tabela SfcPedidoVendaIt
    ClientDataSet1.First;
    while not ClientDataSet1.Eof do
    begin
      ADOQueryItens.SQL.Text :=
        'INSERT INTO SfcPedidoVendaIt (PedidoId, Produto, PrecoUnit, Qtde, ICMS, IPI) ' +
        'VALUES (:PedidoId, :Produto, :PrecoUnit, :Qtde, :ICMS, :IPI)';
      ADOQueryItens.Parameters.ParamByName('PedidoId').Value := NotaGerada;
      ADOQueryItens.Parameters.ParamByName('Produto').Value := ClientDataSet1.FieldByName('NomeProduto').AsString;
      ADOQueryItens.Parameters.ParamByName('PrecoUnit').Value := ClientDataSet1.FieldByName('PrecoProduto').AsFloat;
      ADOQueryItens.Parameters.ParamByName('Qtde').Value := ClientDataSet1.FieldByName('Quantidade').AsInteger;
      ADOQueryItens.Parameters.ParamByName('ICMS').Value := ClientDataSet1.FieldByName('ICMS').AsFloat;
      ADOQueryItens.Parameters.ParamByName('IPI').Value := ClientDataSet1.FieldByName('IPI').AsFloat;
      ADOQueryItens.ExecSQL;

      ClientDataSet1.Next;
    end;


    Conexao.CommitTrans;
    ShowMessage('Venda finalizada com sucesso! Código da Nota: ' + '**' + NotaGerada + '**');
    close;

    ClientDataSet1.EmptyDataSet;

  except
    on E: Exception do
    begin
      Conexao.RollbackTrans;
      ShowMessage('Erro ao finalizar a venda: ' + E.Message);
    end;
  end;
end;

procedure TFormVenda.EditClienteKeyPress(Sender: TObject; var Key: Char);
begin
  // Permite todos os caracteres alfabéticos e espaços
  if not (Key in [#32, 'A'..'Z', 'a'..'z', '0'..'9', #8, #13]) then
    Key := #0;
end;

procedure TFormVenda.EditCodBarrasExit(Sender: TObject);
var Soma, ICMSValue, IPIValue, TotalValue: Double;
Qtde : integer;
begin
  if length(EditCodBarras.text)=13 then
    begin
      if ClientDataSet1.Active = False then
        ClientDataSet1.Active := True;

      ADOProduto.Close;
      ADOProduto.SQL.Clear;
      ADOProduto.SQL.Add('SELECT Codigo,Nome,PrecoUnitario,CodigoBarras');
      ADOProduto.SQL.Add('FROM Produto WHERE CodigoBarras = :PCodigo ');
      ADOProduto.Parameters.ParamByName('PCodigo').Value := EditCodBarras.Text;
      ADOProduto.Open;

        if ADOProduto.RecordCount > 0 then
        begin
          if not ClientDataSet1.Active then
            ClientDataSet1.Active := True;

          if not ClientDataSet1.Locate('CodigoBarras', ADOProdutoCodigoBarras.value,[]) then
          begin
            Soma:=0;
            ICMSValue:=0;
            IPIValue:=0;
            TotalValue:=0;

            ClientDataSet1.Append;
            ClientDataSet1.FieldByName('CodigoBarras').Value := ADOProdutoCodigoBarras.Value;
            ClientDataSet1.FieldByName('NomeProduto').Value := ADOProdutoNome.Value;
            ClientDataSet1.FieldByName('PrecoProduto').Value := ADOProdutoPrecoUnitario.Value;
            ClientDataSet1.FieldByName('Quantidade').Value := StrToInt(EditQtde.Text);
            // SOMA
            Soma:= ClientDataSet1.FieldByName('PrecoProduto').Value * StrToInt(EditQtde.Text);
            ClientDataSet1.FieldByName('SubTotal').Value := Soma;
            // ICMS
            ICMSValue := Soma * 0.17;
            ClientDataSet1.FieldByName('ICMS').Value := ICMSValue;
            // IPI
            IPIValue := soma * 0.10;
            ClientDataSet1.FieldByName('IPI').Value := IPIValue;

            // Total
            TotalValue := Soma + ICMSValue + IPIValue;
            ClientDataSet1.FieldByName('Total').Value := TotalValue;

            ClientDataSet1.Post;
        end
          else
            begin
              Soma:=0;
              Qtde:=0;
              ClientDataSet1.Edit;
              Qtde:= StrToInt(DBGrid1.Columns.Items[3].Field.value) + StrToInt(EditQtde.Text);
              DBGrid1.Columns.Items[3].Field.value := IntToStr(Qtde);
              Soma:=FloatToCurr (DBGrid1.Columns.Items[2].Field.value) *StrToInt(DBGrid1.Columns.Items[3].Field.value);
              DBGrid1.Columns.Items[4].Field.value:=FloatToStr(Soma);
              //ICMS
              ICMSValue := Soma * 0.17;
              DBGrid1.Columns.Items[5].Field.Value := FloatToStr(ICMSValue);
              //IPI
              IPIValue := Soma * 0.10;
              DBGrid1.Columns.Items[6].Field.Value := FloatToStr(IPIValue);

              //Total
              TotalValue := Soma + ICMSValue + IPIValue;
              DBGrid1.Columns.Items[7].Field.Value := FloatToStr(TotalValue);

              ClientDataSet1.Post;
            end;


            EditCodBarras.Clear;
            EditQtde.text:='1';
            EditCodBarras.SetFocus;
      end;

    end;

end;

procedure TFormVenda.EditCodBarrasKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    Perform(WM_NEXTDLGCTL,0,0);
end;

procedure TFormVenda.EditCodBarrasKeyPress(Sender: TObject; var Key: Char);
begin
  if not(key in['0'..'9', char (VK_BACK)]) then
    begin
      key:=#0;
    end;

end;

procedure TFormVenda.EditQtdeExit(Sender: TObject);
begin
  if (EditQtde.text='') or (EditQtde.text='0') then
    begin
      Editqtde.Text:='1';
    end;
end;

procedure TFormVenda.EditQtdeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not ((Key in [Ord('0')..Ord('9')]) or (Key = VK_BACK)) then
    begin
      key:=0;
    end;
end;

end.
