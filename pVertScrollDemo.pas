unit pVertScrollDemo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TfVertScrollDemo = class(TForm)
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    Button1: TButton;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit1: TEdit;
    btAV: TButton;
    edVPX: TEdit;
    edVPY: TEdit;
    btSH: TButton;
    edHT: TEdit;
    btSBB: TButton;
    edBB: TEdit;
    Panel2: TPanel;
    Splitter1: TSplitter;
    VKAutoShowEnabled: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btAVClick(Sender: TObject);
    procedure VertScrollBox1CalcContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
    procedure btSHClick(Sender: TObject);
    procedure btSBBClick(Sender: TObject);
    procedure VKAutoShowEnabledChange(Sender: TObject);
  private
    FEditA: TEdit;
    FButtonA: TButton;
    FVPX: integer;
    FVPY: integer;
    FBB: integer;
    procedure SetButtonA(const Value: TButton);
    procedure SetEditA(const Value: TEdit);
    procedure SetVPX(const Value: integer);
    procedure SetVPY(const Value: integer);
    procedure SetBB(const Value: integer);
    { Private declarations }
    property ButtonA: TButton read FButtonA write SetButtonA;
    property EditA: TEdit read FEditA write SetEditA;
    property VPX: integer read FVPX write SetVPX;
    property VPY: integer read FVPY write SetVPY;
    property BB: integer read FBB write SetBB;
  public
    { Public declarations }
  end;

var
  fVertScrollDemo: TfVertScrollDemo;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

{ TfVertScrollDemo }

{ Apply the Viewport specified by the user's input. }

procedure TfVertScrollDemo.btAVClick(Sender: TObject);
var
  LVPX, LVPY: integer;                                                // local viewport coordinates work area
begin
  if TryStrToInt(edVPX.Text, LVPX) and                                // validate the viewport coordinates
    TryStrToInt(edVPY.Text, LVPY) then
    if (LVPX >= 0) and (LVPY >= 0) then                               // ensure values are non-negative
    begin
      VPX := LVPX;                                                    // save the new value
      VPY := LVPY;                                                    // save the new value
      VertScrollBox1.ViewportPosition := PointF(                      // apply only valid input
        VPX,
        VPY);
      Exit;
    end;
  ShowMessage('Viewport coordinates must be non-negative integers.'); // tell user about error
end;

{ Display the value of the Vertical Scroll Box Height property. }

procedure TfVertScrollDemo.btSHClick(Sender: TObject);
begin
  edHT.Text := VertScrollBox1.Height.ToString;                        // display the height property in the edit box
end;

{ Set the ContentBounds Bottom value as specified by the user's input.
  Important to note that the RealignContent method is what actually causes
  the Bounds Bottom to be applied. You cannot change the value of ContentBounds
  directly. This can only be handled by the onCalcContentBounds event. }

procedure TfVertScrollDemo.btSBBClick(Sender: TObject);
var
  LBB: integer;
begin
  if TryStrToInt(edBB.Text, LBB) then // validate the Bounds Bottom value
    if LBB > 0 then                   // insure a positive value
    begin
      BB := LBB;                      // save the new Bottom Bound value
      VertScrollBox1.RealignContent;  // this also causes OnCalcContentBounds to fire
      Exit;
    end;
  ShowMessage('ContentBounds Bottom value must be a positive integer.');
end;

{ Form Create adds a number of random objects to the Vertical Scroll Box. These
  objects are for demonstration purposes only and have no other value. Their
  positions are well below the current Vertical Scroll Box Height. This will
  cause the Vertical Scroll box to recalculate the Bottom Bound to accomodate
  the added objects.

  Note that the initial value of the Bottom Bound is calculated AFTER this event
  completes, so it cannot be obtained here. Obtaining the intial Bottom Bound
  value is handled by the OnCalcContentBounds event.  }

procedure TfVertScrollDemo.FormCreate(Sender: TObject);
begin

  { Add an edit box }

  FEditA := TEdit.Create(Self);
  FEditA.Visible := True;
  FEditA.Position.Point := Point(100, 625);
  FEditA.Parent := VertScrollBox1;

  { Add a button  }

  FEditA.Padding.Bottom := 25;
  FButtonA := TButton.Create(Self);
  FButtonA.Position.Point := Point(150, 700);
  FButtonA.Parent := VertScrollBox1;
end;

procedure TfVertScrollDemo.SetBB(const Value: integer);
begin
  FBB := Value;
end;

procedure TfVertScrollDemo.SetButtonA(const Value: TButton);
begin
  FButtonA := Value;
end;

procedure TfVertScrollDemo.SetEditA(const Value: TEdit);
begin
  FEditA := Value;
end;

procedure TfVertScrollDemo.SetVPX(const Value: integer);
begin
  FVPX := Value;
end;

procedure TfVertScrollDemo.SetVPY(const Value: integer);
begin
  FVPY := Value;
end;

{ This event does 2 things: 1) it obtains the initial value of the Bottom Bound
  by checking for a current saved value of zero, and 2) it sets the Bottom Bound
  value if the current saved value is non-zero. The current saved value has been
  set to zero when the form was created, or to some integer value when the user
  has clicked the SBB button. }

procedure TfVertScrollDemo.VertScrollBox1CalcContentBounds(
  Sender: TObject;
  var ContentBounds: TRectF);
begin
  Beep;                                              // to let the user know this routine was entered
  if not(BB > 0) then
    BB := Trunc(VertScrollBox1.ContentBounds.Bottom) // save current value
  else
    ContentBounds.Bottom := BB;                      // cause Bound Bottom value to change

  edHT.Text := VertScrollBox1.Height.ToString;       // display the vertical scroll box height property
end;

{ Set the VK (Virtual Keyboard) Auto Show Mode. }

procedure TfVertScrollDemo.VKAutoShowEnabledChange(Sender: TObject);
begin
  if VKAutoShowEnabled.IsChecked then                  // if auto show checked
    VKAutoShowMode := TVKAutoShowMode.Always           // always display the VK
  else
    VKAutoShowMode := TVKAutoShowMode.DefinedBySystem; // no display if not checked
end;

end.
