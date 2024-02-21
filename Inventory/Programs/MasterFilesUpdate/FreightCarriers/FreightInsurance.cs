using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using System.Globalization;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightInsurance : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private freight _freightData;

        public FreightInsurance(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            this.Load += (s, e) => insTp1TextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE FREIGHT INSURANCE INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel");
        }

        public Dictionary<string, Action> AvailableActions 
        {
            get
            {
                return new Dictionary<string, Action>
                {
                    { "1", () => UpdateFreightInsuranceData(_freightData)},
                    { "2", () => insTp1TextBox.Focus() },
                    { "3", () => LoadFreightCarriers() }
                };
            }
        }

        public void PerformAction(string userInput)
        {
            if (AvailableActions.TryGetValue(userInput, out var action))
            {
                action();
            }
            else
            {
                MessageBox.Show("ERROR: Invalid input, please try again or contact developer");
            }
        }
        private void UpdateFreightInsuranceData(freight freightData)
        {
            if (freightData != null)
            {
                if (IsDataModified(freightData))
                {
                    UpdateExistingFreight(freightData);
                }
                LoadFreightCarriers();
            }
            else
            {
                MessageBox.Show("ERROR: Freight Insurance Data is null, please try again or contact developer");
            }
            
        }

        private void UpdateExistingFreight(freight freightData)
        {
            using (AmerichickenContext dbContext = new())
            {
                var existingFreightData = dbContext.freight.Find(freightData.PK_freight);
                if (existingFreightData != null)
                {
                    SetFreightProperties(existingFreightData);
                    dbContext.SaveChanges();
                }
                else
                {
                    MessageBox.Show("ERROR: Freight Insurance Data not found, please try again or contact developer");
                }
            }
        }

        private void SetFreightProperties(freight existingFreightData)
        {
            //Update Freight Insurance Data
            existingFreightData.INS_TP1 = insTp1TextBox.Text;
            existingFreightData.INS_TP2 = insTp2TextBox.Text;
            existingFreightData.INS_TP3 = insTp3TextBox.Text;
            existingFreightData.INS_TP4 = insTp4TextBox.Text;
            existingFreightData.INS_TP5 = insTp5TextBox.Text;
            existingFreightData.POLICY1 = policy1TextBox.Text;
            existingFreightData.POLICY2 = policy2TextBox.Text;
            existingFreightData.POLICY3 = policy3TextBox.Text;
            existingFreightData.POLICY4 = policy4TextBox.Text;
            existingFreightData.POLICY5 = policy5TextBox.Text;
            existingFreightData.GEN_BEG = Converter.ParseDateTime(genBeginDateMaskBox.Text);
            existingFreightData.GEN_END = Converter.ParseDateTime(genEndDateMaskBox.Text);
            existingFreightData.GEN_LET = Converter.ParseDateTime(genLetterSentDateMaskBox.Text);
            existingFreightData.GEN_COV4 = Converter.ParseInt(genCov4TextBox.Text);
            existingFreightData.GEN_COV5 = Converter.ParseInt(genCov5TextBox.Text);
            existingFreightData.GEN_COV6 = Converter.ParseInt(genCov6TextBox.Text);
            existingFreightData.GEN_COV3 = Converter.ParseInt(genCov3TextBox.Text);
            existingFreightData.GEN_COV2 = Converter.ParseInt(genCov2TextBox.Text);
            existingFreightData.GEN_COV1 = Converter.ParseInt(genCov1TextBox.Text);
            existingFreightData.AUTO_BEG = Converter.ParseDateTime(autoBeginDateMaskBox.Text);
            existingFreightData.AUTO_END = Converter.ParseDateTime(autoEndDateMaskBox.Text);
            existingFreightData.AUTO_LET = Converter.ParseDateTime(autoLetterSentDateMaskBox.Text);
            existingFreightData.AUTO_COV1 = Converter.ParseInt(autoCov1TextBox.Text);
            existingFreightData.AUTO_COV2 = Converter.ParseInt(autoCov2TextBox.Text);
            existingFreightData.AUTO_COV3 = Converter.ParseInt(autoCov3TextBox.Text);
            existingFreightData.AUTO_COV4 = Converter.ParseInt(autoCov4TextBox.Text);
            existingFreightData.WORK_BEG = Converter.ParseDateTime(compBeginDateMaskBox.Text);
            existingFreightData.WORK_END = Converter.ParseDateTime(compEndDateMaskBox.Text);
            existingFreightData.WORK_LET = Converter.ParseDateTime(compLetterSentDateMaskBox.Text);
            existingFreightData.WORK_COV1 = Converter.ParseInt(compCov1TextBox.Text);
            existingFreightData.WORK_COV2 = Converter.ParseInt(compCov2TextBox.Text);
            existingFreightData.WORK_COV3 = Converter.ParseInt(compCov3TextBox.Text);
            existingFreightData.CARGO_BEG = Converter.ParseDateTime(cargoBeginDateMaskBox.Text);
            existingFreightData.CARGO_END = Converter.ParseDateTime(cargoEndDateMaskBox.Text);
            existingFreightData.CARGO_LET = Converter.ParseDateTime(cargoLetterSentDateMaskBox.Text);
            existingFreightData.CARG_COV1 = Converter.ParseInt(cargoCov1TextBox.Text);
            existingFreightData.CARG_COV2 = Converter.ParseInt(cargoCov2TextBox.Text);
            existingFreightData.CARG_COV3 = Converter.ParseInt(cargoCov3TextBox.Text);
            existingFreightData.CARG_COV4 = Converter.ParseInt(cargoCov4TextBox.Text);
            existingFreightData.PHY_BEG = Converter.ParseDateTime(damageBeginDateMaskBox.Text);
            existingFreightData.PHY_END = Converter.ParseDateTime(damageEndDateMaskBox.Text);
            existingFreightData.PHY_COV1 = Converter.ParseInt(damageCov1TextBox.Text);
            existingFreightData.PHY_COV2 = Converter.ParseInt(damageCov2TextBox.Text);
            existingFreightData.CANCEL = Converter.ParseInt(cancellationTextBox.Text);

            _freightData = existingFreightData;
        }
        private bool IsDataModified(freight freightData)
        {
            return freightData == null || freightData.INS_TP1 != insTp1TextBox.Text ||
                freightData.INS_TP2 != insTp2TextBox.Text ||
                freightData.INS_TP3 != insTp3TextBox.Text ||
                freightData.INS_TP4 != insTp4TextBox.Text ||
                freightData.INS_TP5 != insTp5TextBox.Text ||
                freightData.POLICY1 != policy1TextBox.Text ||
                freightData.POLICY2 != policy2TextBox.Text ||
                freightData.POLICY3 != policy3TextBox.Text ||
                freightData.POLICY4 != policy4TextBox.Text ||
                freightData.POLICY5 != policy5TextBox.Text ||
                freightData.GEN_BEG != Converter.ParseDateTime(genBeginDateMaskBox.Text) ||
                freightData.GEN_END != Converter.ParseDateTime(genEndDateMaskBox.Text) ||
                freightData.GEN_LET != Converter.ParseDateTime(genLetterSentDateMaskBox.Text) ||
                freightData.GEN_COV4 != Converter.ParseInt(genCov4TextBox.Text) ||
                freightData.GEN_COV5 != Converter.ParseInt(genCov5TextBox.Text) ||
                freightData.GEN_COV6 != Converter.ParseInt(genCov6TextBox.Text) ||
                freightData.GEN_COV3 != Converter.ParseInt(genCov3TextBox.Text) ||
                freightData.GEN_COV2 != Converter.ParseInt(genCov2TextBox.Text) ||
                freightData.GEN_COV1 != Converter.ParseInt(genCov1TextBox.Text) ||
                freightData.AUTO_BEG != Converter.ParseDateTime(autoBeginDateMaskBox.Text) ||
                freightData.AUTO_END != Converter.ParseDateTime(autoEndDateMaskBox.Text) ||
                freightData.AUTO_LET != Converter.ParseDateTime(autoLetterSentDateMaskBox.Text) ||
                freightData.AUTO_COV1 != Converter.ParseInt(autoCov1TextBox.Text) ||
                freightData.AUTO_COV2 != Converter.ParseInt(autoCov2TextBox.Text) ||
                freightData.AUTO_COV3 != Converter.ParseInt(autoCov3TextBox.Text) ||
                freightData.AUTO_COV4 != Converter.ParseInt(autoCov4TextBox.Text) ||
                freightData.WORK_BEG != Converter.ParseDateTime(compBeginDateMaskBox.Text) ||
                freightData.WORK_END != Converter.ParseDateTime(compEndDateMaskBox.Text) ||
                freightData.WORK_LET != Converter.ParseDateTime(compLetterSentDateMaskBox.Text) ||
                freightData.WORK_COV1 != Converter.ParseInt(compCov1TextBox.Text) ||
                freightData.WORK_COV2 != Converter.ParseInt(compCov2TextBox.Text) ||
                freightData.WORK_COV3 != Converter.ParseInt(compCov3TextBox.Text) ||
                freightData.CARGO_BEG != Converter.ParseDateTime(cargoBeginDateMaskBox.Text) ||
                freightData.CARGO_END != Converter.ParseDateTime(cargoEndDateMaskBox.Text) ||
                freightData.CARGO_LET != Converter.ParseDateTime(cargoLetterSentDateMaskBox.Text) ||
                freightData.CARG_COV1 != Converter.ParseInt(cargoCov1TextBox.Text) ||
                freightData.CARG_COV2 != Converter.ParseInt(cargoCov2TextBox.Text) ||
                freightData.CARG_COV3 != Converter.ParseInt(cargoCov3TextBox.Text) ||
                freightData.CARG_COV4 != Converter.ParseInt(cargoCov4TextBox.Text) ||
                freightData.PHY_BEG != Converter.ParseDateTime(damageBeginDateMaskBox.Text) ||
                freightData.PHY_END != Converter.ParseDateTime(damageEndDateMaskBox.Text) ||
                freightData.PHY_COV1 != Converter.ParseInt(damageCov1TextBox.Text) ||
                freightData.PHY_COV2 != Converter.ParseInt(damageCov2TextBox.Text) ||
                freightData.CANCEL != Converter.ParseInt(cancellationTextBox.Text);
        }
        public void GetFreightInsuranceData(freight freightData)
        {
            if (freightData == null)
            {
                throw new ArgumentNullException(nameof(freightData));
            }
            else
            {
                //Display Freight Insurance Data
                _freightData = freightData;
                insTp1TextBox.Text = _freightData.INS_TP1;
                insTp2TextBox.Text = _freightData.INS_TP2;
                insTp3TextBox.Text = _freightData.INS_TP3;
                insTp4TextBox.Text = _freightData.INS_TP4;
                insTp5TextBox.Text = _freightData.INS_TP5;
                policy1TextBox.Text = _freightData.POLICY1;
                policy2TextBox.Text = _freightData.POLICY2;
                policy3TextBox.Text = _freightData.POLICY3;
                policy4TextBox.Text = _freightData.POLICY4;
                policy5TextBox.Text = _freightData.POLICY5;
                genBeginDateMaskBox.Text = _freightData.GEN_BEG?.ToString("MM/dd/yyyy");
                genEndDateMaskBox.Text = _freightData.GEN_END?.ToString("MM/dd/yyyy");
                genLetterSentDateMaskBox.Text = _freightData.GEN_LET?.ToString("MM/dd/yyyy");
                genCov4TextBox.Text = _freightData.GEN_COV4?.ToString();
                genCov5TextBox.Text = _freightData.GEN_COV5?.ToString();
                genCov6TextBox.Text = _freightData.GEN_COV6?.ToString();
                genCov3TextBox.Text = _freightData.GEN_COV3?.ToString();
                genCov2TextBox.Text = _freightData.GEN_COV2?.ToString();
                genCov1TextBox.Text = _freightData.GEN_COV1?.ToString();
                autoBeginDateMaskBox.Text = _freightData.AUTO_BEG?.ToString("MM/dd/yyyy");
                autoEndDateMaskBox.Text = _freightData.AUTO_END?.ToString("MM/dd/yyyy");
                autoLetterSentDateMaskBox.Text = _freightData.AUTO_LET?.ToString("MM/dd/yyyy");
                autoCov1TextBox.Text = _freightData.AUTO_COV1?.ToString();
                autoCov2TextBox.Text = _freightData.AUTO_COV2?.ToString();
                autoCov3TextBox.Text = _freightData.AUTO_COV3?.ToString();
                autoCov4TextBox.Text = _freightData.AUTO_COV4?.ToString();
                compBeginDateMaskBox.Text = _freightData.WORK_BEG?.ToString("MM/dd/yyyy");
                compEndDateMaskBox.Text = _freightData.WORK_END?.ToString("MM/dd/yyyy");
                compLetterSentDateMaskBox.Text = _freightData.WORK_LET?.ToString("MM/dd/yyyy");
                compCov1TextBox.Text = _freightData.WORK_COV1?.ToString();
                compCov2TextBox.Text = _freightData.WORK_COV2?.ToString();
                compCov3TextBox.Text = _freightData.WORK_COV3?.ToString();
                cargoBeginDateMaskBox.Text = _freightData.CARGO_BEG?.ToString("MM/dd/yyyy");
                cargoEndDateMaskBox.Text = _freightData.CARGO_END?.ToString("MM/dd/yyyy");
                cargoLetterSentDateMaskBox.Text = _freightData.CARGO_LET?.ToString("MM/dd/yyyy");
                cargoCov1TextBox.Text = _freightData.CARG_COV1?.ToString();
                cargoCov2TextBox.Text = _freightData.CARG_COV2?.ToString();
                cargoCov3TextBox.Text = _freightData.CARG_COV3?.ToString();
                cargoCov4TextBox.Text = _freightData.CARG_COV4?.ToString();
                damageBeginDateMaskBox.Text = _freightData.PHY_BEG?.ToString("MM/dd/yyyy");
                damageEndDateMaskBox.Text = _freightData.PHY_END?.ToString("MM/dd/yyyy");
                damageCov1TextBox.Text = _freightData.PHY_COV1?.ToString();
                damageCov2TextBox.Text = _freightData.PHY_COV2?.ToString();
                cancellationTextBox.Text = _freightData.CANCEL?.ToString();
            }
        }

        private void LoadFreightCarriers()
        {
            FreightCarriers freightCarriers = new FreightCarriers(_mainWindow, _activeControlManager);
            freightCarriers.DisplayFreightCarrierData(_freightData);
            _mainWindow.DisposeControl(this);
            _activeControlManager.SetActiveControl(freightCarriers);
        }

    }
}