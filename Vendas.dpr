program Vendas;

uses
  Vcl.Forms,
  VendaFc in 'VendaFc.pas' {FormVenda},
  Pesquisa in 'Pesquisa.pas' {FormPesquisa},
  Home in 'Home.pas' {frmHome},
  Consulta in 'Consulta.pas' {FormConsultas};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmHome, frmHome);
  Application.CreateForm(TFormPesquisa, FormPesquisa);
  Application.CreateForm(TFormVenda, FormVenda);
  Application.CreateForm(TFormConsultas, FormConsultas);
  Application.Run;
end.
