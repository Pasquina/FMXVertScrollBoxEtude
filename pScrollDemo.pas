unit pScrollDemo;

{
   Copyright © 2016 Milan Vydareny

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

	For more information contact:
	Milan Vydareny
	Milan@VyDevSoft.com

}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TfScrollDemo = class(TForm)
    Panel1: TPanel;
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
    edBB: TEdit;
    Panel2: TPanel;
    Splitter1: TSplitter;
    VKAutoShowEnabled: TCheckBox;
    Layout1: TLayout;
    Edit2: TEdit;
    CheckBox2: TCheckBox;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    edWD: TEdit;
    ScrollBox1: TScrollBox;
    edBR: TEdit;
    btShowBounds: TButton;
    btAddLabel: TButton;
    edBBShow: TEdit;
    edBRShow: TEdit;
    edLX: TEdit;
    edLY: TEdit;
    Label1: TLabel;
    cbForceCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btAVClick(Sender: TObject);
    procedure ScrollBox1CalcContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
    procedure btSHClick(Sender: TObject);
    procedure VKAutoShowEnabledChange(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure btShowBoundsClick(Sender: TObject);
    procedure btAddLabelClick(Sender: TObject);
    procedure cbForceCBChange(Sender: TObject);
  private
    FEditA: TEdit;
    FButtonA: TButton;
    FVPX: integer;
    FVPY: integer;
    FBB: integer;
    FBR: integer;
    procedure SetButtonA(const Value: TButton);
    procedure SetEditA(const Value: TEdit);
    procedure SetVPX(const Value: integer);
    procedure SetVPY(const Value: integer);
    procedure SetBB(const Value: integer);
    procedure SetBR(const Value: integer);
    { Private declarations }
    property ButtonA: TButton read FButtonA write SetButtonA;
    property EditA: TEdit read FEditA write SetEditA;
    property VPX: integer read FVPX write SetVPX;
    property VPY: integer read FVPY write SetVPY;
    property BB: integer read FBB write SetBB;
    property BR: integer read FBR write SetBR;
  public
    { Public declarations }
  end;

var
  fScrollDemo: TfScrollDemo;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

{ TfScrollDemo }

{ Add a label at the point specified by the user. }

procedure TfScrollDemo.btAddLabelClick(Sender: TObject);
var
  LPoint: TPoint;
  LLabel: TLabel;
begin
  if TryStrToInt(edLX.Text, LPoint.X) and       // validate the label coordinates
    TryStrToInt(edLY.Text, LPoint.Y) then
    if (LPoint.X >= 0) and (LPoint.Y >= 0) then // ensure values are non-negative
    begin

      { Add a label }

      LLabel := TLabel.Create(Self);            // create the label
      LLabel.Visible := True;                   // make sure we can see it
      LLabel.Position.Point := LPoint;          // position the label
      LLabel.Parent := ScrollBox1;              // parent the label to the scroll box
      LLabel.AutoSize := True;                  // autosize the label text
      llabel.TextSettings.WordWrap := False;    // disable word wrap
      LLabel.Text := Format(                    // set the label text
        'Label at point %u, %u', [LPoint.X, LPoint.Y]);
      ScrollBox1.RealignContent;                // realign the content to include everything
      Exit;
    end;
  ShowMessage(                                  // tell user about error
    'Label coordinates must be non-negative integers.');
end;

{ Apply the Viewport specified by the user's input. }

procedure TfScrollDemo.btAVClick(Sender: TObject);
var
  LVPX, LVPY: integer;                       // local viewport coordinates work area
begin
  if TryStrToInt(edVPX.Text, LVPX) and       // validate the viewport coordinates
    TryStrToInt(edVPY.Text, LVPY) then
    if (LVPX >= 0) and (LVPY >= 0) then      // ensure values are non-negative
    begin
      VPX := LVPX;                           // save the new value
      VPY := LVPY;                           // save the new value
      ScrollBox1.ViewportPosition := PointF( // apply only valid input
        VPX,
        VPY);
      Exit;
    end;
  ShowMessage(                               // tell user about error
    'Viewport coordinates must be non-negative integers.');
end;

{ Display the value of the Scroll Box Height and Width properties. }

procedure TfScrollDemo.btSHClick(Sender: TObject);
begin
  edHT.Text := ScrollBox1.Height.ToString; // display the height property in the edit box
  edWD.Text := ScrollBox1.Width.ToString;  // display the width property in the edit box
end;

{ Display the current values of the Bounds Bottom and Right. }

procedure TfScrollDemo.btShowBoundsClick(Sender: TObject);
begin
  edBBShow.Text := ScrollBox1.ContentBounds.Bottom.ToString; // display the content bottom
  edBRShow.Text := ScrollBox1.ContentBounds.Right.ToString;  // display the content right
end;

{ If checked, the ContentBounds Bottom and Right values as specified by the user's input
  are validated and saved for use by the CalcContentBounds event. The event also
  checks the ForceCBChange check box and applies the specified changes only if the
  check box is checked.

  Important to note that the RealignContent method is what actually causes
  the Bounds to be applied. You cannot change the value of ContentBounds
  directly. This can only be handled by the onCalcContentBounds event. }

procedure TfScrollDemo.cbForceCBChange(Sender: TObject);
var
  LBB: integer;                        // local bottom bound
  LBR: integer;                        // local right bound
begin
  if cbForceCB.IsChecked then
  begin
    if TryStrToInt(edBB.Text, LBB) and // validate the Bounds values
      TryStrToInt(edBR.Text, LBR) then
      if (LBB > 0) and                 // insure positive values
        (LBR > 0) then
      begin
        BB := LBB;                     // save the new Bottom Bound value
        BR := LBR;                     // save the new Right Bound value
        ScrollBox1.RealignContent;     // this also causes OnCalcContentBounds to fire
        Exit;
      end;
    ShowMessage('ContentBounds values must be positive integers.');
  end
  else
  begin
    ScrollBox1.RealignContent;        // recalc bounds without forced values
  end;
end;


{ Form Create adds a number of random objects to the Vertical Scroll Box. These
  objects are for demonstration purposes only and have no other value. Their
  positions are well outside the current Scroll Box Height and width. This will
  cause the Vertical Scroll box to recalculate the Content Bounds to accomodate
  the added objects.

  Note that the initial value of the Content Bounds is calculated AFTER this event
  completes, so it cannot be obtained here. Obtaining the intial Content Bounds
  values is handled by the OnCalcContentBounds event.  }

procedure TfScrollDemo.FormCreate(Sender: TObject);
begin
//
//  { Add an edit box }
//
//  FEditA := TEdit.Create(Self);
//  FEditA.Visible := True;
//  FEditA.Position.Point := Point(100, 625);
//  FEditA.Parent := ScrollBox1;
//
//  { Add a button  }
//
//  FEditA.Padding.Bottom := 25;
//  FButtonA := TButton.Create(Self);
//  FButtonA.Position.Point := Point(150, 700);
//  FButtonA.Parent := ScrollBox1;
end;

{ Permits the examination of various TRectF values during test execution.  }

procedure TfScrollDemo.FormFocusChanged(Sender: TObject);
var
  LFocused: TControl;
  LFocusAbsoluteRect: TRectF;
  LFocusLocalRect: TRectF;
  LFocusParentRect: TRectF;
  LFocusName: string;
begin
  if Assigned(Focused) then
  begin
    LFocused := TControl(Focused.GetObject);
    LFocusAbsoluteRect := LFocused.AbsoluteRect;
    LFocusLocalRect := LFocused.LocalRect;
    LFocusParentRect := LFocused.ParentedRect;
    LFocusName := LFocused.Name;
end;

end;

procedure TfScrollDemo.SetBB(const Value: integer);
begin
  FBB := Value;
end;

procedure TfScrollDemo.SetBR(const Value: integer);
begin
  FBR := Value;
end;

procedure TfScrollDemo.SetButtonA(const Value: TButton);
begin
  FButtonA := Value;
end;

procedure TfScrollDemo.SetEditA(const Value: TEdit);
begin
  FEditA := Value;
end;

procedure TfScrollDemo.SetVPX(const Value: integer);
begin
  FVPX := Value;
end;

procedure TfScrollDemo.SetVPY(const Value: integer);
begin
  FVPY := Value;
end;

{ This event checks the Bounds Override check box. If checked, it applies the bottom
  and right bounds (saved by the check box OnChange event) to the ScrollBox, otherwise
  it leaves the calculated ScrollBox bounds unchanged. }

procedure TfScrollDemo.ScrollBox1CalcContentBounds(
  Sender: TObject;
  var ContentBounds: TRectF);
begin
  Beep;                                                      // to let the user know this routine was entered
  if cbForceCB.IsChecked then                                // change bounds only if force change is checked
  begin
    ContentBounds.Bottom := BB;                              // cause Bound Bottom value to change
    ContentBounds.Right := BR;                               // cause Bound Right value to change
  end;
end;

{ Set the VK (Virtual Keyboard) Auto Show Mode. }

procedure TfScrollDemo.VKAutoShowEnabledChange(Sender: TObject);
begin
  if VKAutoShowEnabled.IsChecked then                  // if auto show checked
    VKAutoShowMode := TVKAutoShowMode.Always           // always display the VK
  else
    VKAutoShowMode := TVKAutoShowMode.DefinedBySystem; // no display if not checked
end;

end.
