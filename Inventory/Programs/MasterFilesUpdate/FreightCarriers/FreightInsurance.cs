using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using System.Globalization;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightInsurance : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private freight _freightData;
        private readonly AmerichickenContext _dbContext;

        public FreightInsurance(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
            _dbContext = new();

            this.Load += (s, e) => insTp1TextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE FREIGHT INSURANCE INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel");
        }

        private void LoadFreightCarriers()
        {
            FreightCarriers freightCarriers = new FreightCarriers(_mainWindow, _activeControlManager);
            freightCarriers.DisplayFreightCarrierData(_freightData);
            _mainWindow.DisposeControl(this);
            _activeControlManager.SetActiveControl(freightCarriers);
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
            var existingFreightData = _dbContext.freight.Find(freightData.PK_freight);
            if (existingFreightData != null)
            {
                SetFreightProperties(existingFreightData);
                _dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Freight Insurance Data not found, please try again or contact developer");
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
            existingFreightData.GEN_BEG = string.IsNullOrEmpty(genBeginDateMaskBox.Text) ? null : DateTime.TryParse(genBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genBeg) ? genBeg : null;
            existingFreightData.GEN_END = string.IsNullOrEmpty(genEndDateMaskBox.Text) ? null : DateTime.TryParse(genEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genEnd) ? genEnd : null;
            existingFreightData.GEN_LET = string.IsNullOrEmpty(genLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(genLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genLetter) ? genLetter : null;
            existingFreightData.GEN_COV4 = string.IsNullOrEmpty(genCov4TextBox.Text) ? null : int.Parse(genCov4TextBox.Text);
            existingFreightData.GEN_COV5 = string.IsNullOrEmpty(genCov5TextBox.Text) ? null : int.Parse(genCov5TextBox.Text);
            existingFreightData.GEN_COV6 = string.IsNullOrEmpty(genCov6TextBox.Text) ? null : int.Parse(genCov6TextBox.Text);
            existingFreightData.GEN_COV3 = string.IsNullOrEmpty(genCov3TextBox.Text) ? null : int.Parse(genCov3TextBox.Text);
            existingFreightData.GEN_COV2 = string.IsNullOrEmpty(genCov2TextBox.Text) ? null : int.Parse(genCov2TextBox.Text);
            existingFreightData.GEN_COV1 = string.IsNullOrEmpty(genCov1TextBox.Text) ? null : int.Parse(genCov1TextBox.Text);
            existingFreightData.AUTO_BEG = string.IsNullOrEmpty(autoBeginDateMaskBox.Text) ? null : DateTime.TryParse(autoBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoBeg) ? autoBeg : null;
            existingFreightData.AUTO_END = string.IsNullOrEmpty(autoEndDateMaskBox.Text) ? null : DateTime.TryParse(autoEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoEnd) ? autoEnd : null;
            existingFreightData.AUTO_LET = string.IsNullOrEmpty(autoLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(autoLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoLetter) ? autoLetter : null;
            existingFreightData.AUTO_COV1 = string.IsNullOrEmpty(autoCov1TextBox.Text) ? null : int.Parse(autoCov1TextBox.Text);
            existingFreightData.AUTO_COV2 = string.IsNullOrEmpty(autoCov2TextBox.Text) ? null : int.Parse(autoCov2TextBox.Text);
            existingFreightData.AUTO_COV3 = string.IsNullOrEmpty(autoCov3TextBox.Text) ? null : int.Parse(autoCov3TextBox.Text);
            existingFreightData.AUTO_COV4 = string.IsNullOrEmpty(autoCov4TextBox.Text) ? null : int.Parse(autoCov4TextBox.Text);
            existingFreightData.WORK_BEG = string.IsNullOrEmpty(compBeginDateMaskBox.Text) ? null : DateTime.TryParse(compBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compBeg) ? compBeg : null;
            existingFreightData.WORK_END = string.IsNullOrEmpty(compEndDateMaskBox.Text) ? null : DateTime.TryParse(compEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compEnd) ? compEnd : null;
            existingFreightData.WORK_LET = string.IsNullOrEmpty(compLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(compLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compLetter) ? compLetter : null;
            existingFreightData.WORK_COV1 = string.IsNullOrEmpty(compCov1TextBox.Text) ? null : int.Parse(compCov1TextBox.Text);
            existingFreightData.WORK_COV2 = string.IsNullOrEmpty(compCov2TextBox.Text) ? null : int.Parse(compCov2TextBox.Text);
            existingFreightData.WORK_COV3 = string.IsNullOrEmpty(compCov3TextBox.Text) ? null : int.Parse(compCov3TextBox.Text);
            existingFreightData.CARGO_BEG = string.IsNullOrEmpty(cargoBeginDateMaskBox.Text) ? null : DateTime.TryParse(cargoBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoBeg) ? cargoBeg : null;
            existingFreightData.CARGO_END = string.IsNullOrEmpty(cargoEndDateMaskBox.Text) ? null : DateTime.TryParse(cargoEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoEnd) ? cargoEnd : null;
            existingFreightData.CARGO_LET = string.IsNullOrEmpty(cargoLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(cargoLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoLetter) ? cargoLetter : null;
            existingFreightData.CARG_COV1 = string.IsNullOrEmpty(cargoCov1TextBox.Text) ? null : int.Parse(cargoCov1TextBox.Text);
            existingFreightData.CARG_COV2 = string.IsNullOrEmpty(cargoCov2TextBox.Text) ? null : int.Parse(cargoCov2TextBox.Text);
            existingFreightData.CARG_COV3 = string.IsNullOrEmpty(cargoCov3TextBox.Text) ? null : int.Parse(cargoCov3TextBox.Text);
            existingFreightData.CARG_COV4 = string.IsNullOrEmpty(cargoCov4TextBox.Text) ? null : int.Parse(cargoCov4TextBox.Text);
            existingFreightData.PHY_BEG = string.IsNullOrEmpty(damageBeginDateMaskBox.Text) ? null : DateTime.TryParse(damageBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var damageBeg) ? damageBeg : null;
            existingFreightData.PHY_END = string.IsNullOrEmpty(damageEndDateMaskBox.Text) ? null : DateTime.TryParse(damageEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var damageEnd) ? damageEnd : null;
            existingFreightData.PHY_COV1 = string.IsNullOrEmpty(damageCov1TextBox.Text) ? null : int.Parse(damageCov1TextBox.Text);
            existingFreightData.PHY_COV2 = string.IsNullOrEmpty(damageCov2TextBox.Text) ? null : int.Parse(damageCov2TextBox.Text);
            existingFreightData.CANCEL = string.IsNullOrEmpty(cancellationTextBox.Text) ? null : int.Parse(cancellationTextBox.Text);

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
                freightData.GEN_BEG != (string.IsNullOrEmpty(genBeginDateMaskBox.Text) ? null : DateTime.TryParse(genBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genBeg) ? genBeg : null) ||
                freightData.GEN_END != (string.IsNullOrEmpty(genEndDateMaskBox.Text) ? null : DateTime.TryParse(genEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genEnd) ? genEnd : null) ||
                freightData.GEN_LET != (string.IsNullOrEmpty(genLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(genLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genLetter) ? genLetter : null) ||
                freightData.GEN_COV4 != (string.IsNullOrEmpty(genCov4TextBox.Text) ? null : int.Parse(genCov4TextBox.Text)) ||
                freightData.GEN_COV5 != (string.IsNullOrEmpty(genCov5TextBox.Text) ? null : int.Parse(genCov5TextBox.Text)) ||
                freightData.GEN_COV6 != (string.IsNullOrEmpty(genCov6TextBox.Text) ? null : int.Parse(genCov6TextBox.Text)) ||
                freightData.GEN_COV3 != (string.IsNullOrEmpty(genCov3TextBox.Text) ? null : int.Parse(genCov3TextBox.Text)) ||
                freightData.GEN_COV2 != (string.IsNullOrEmpty(genCov2TextBox.Text) ? null : int.Parse(genCov2TextBox.Text)) ||
                freightData.GEN_COV1 != (string.IsNullOrEmpty(genCov1TextBox.Text) ? null : int.Parse(genCov1TextBox.Text)) ||
                freightData.AUTO_BEG != (string.IsNullOrEmpty(autoBeginDateMaskBox.Text) ? null : DateTime.TryParse(autoBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoBeg) ? autoBeg : null) ||
                freightData.AUTO_END != (string.IsNullOrEmpty(autoEndDateMaskBox.Text) ? null : DateTime.TryParse(autoEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoEnd) ? autoEnd : null) ||
                freightData.AUTO_LET != (string.IsNullOrEmpty(autoLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(autoLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoLetter) ? autoLetter : null) ||
                freightData.AUTO_COV1 != (string.IsNullOrEmpty(autoCov1TextBox.Text) ? null : int.Parse(autoCov1TextBox.Text)) ||
                freightData.AUTO_COV2 != (string.IsNullOrEmpty(autoCov2TextBox.Text) ? null : int.Parse(autoCov2TextBox.Text)) ||
                freightData.AUTO_COV3 != (string.IsNullOrEmpty(autoCov3TextBox.Text) ? null : int.Parse(autoCov3TextBox.Text)) ||
                freightData.AUTO_COV4 != (string.IsNullOrEmpty(autoCov4TextBox.Text) ? null : int.Parse(autoCov4TextBox.Text)) ||
                freightData.WORK_BEG != (string.IsNullOrEmpty(compBeginDateMaskBox.Text) ? null : DateTime.TryParse(compBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compBeg) ? compBeg : null) ||
                freightData.WORK_END != (string.IsNullOrEmpty(compEndDateMaskBox.Text) ? null : DateTime.TryParse(compEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compEnd) ? compEnd : null) ||
                freightData.WORK_LET != (string.IsNullOrEmpty(compLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(compLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var compLetter) ? compLetter : null) ||
                freightData.WORK_COV1 != (string.IsNullOrEmpty(compCov1TextBox.Text) ? null : int.Parse(compCov1TextBox.Text)) ||
                freightData.WORK_COV2 != (string.IsNullOrEmpty(compCov2TextBox.Text) ? null : int.Parse(compCov2TextBox.Text)) ||
                freightData.WORK_COV3 != (string.IsNullOrEmpty(compCov3TextBox.Text) ? null : int.Parse(compCov3TextBox.Text)) ||
                freightData.CARGO_BEG != (string.IsNullOrEmpty(cargoBeginDateMaskBox.Text) ? null : DateTime.TryParse(cargoBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoBeg) ? cargoBeg : null) ||
                freightData.CARGO_END != (string.IsNullOrEmpty(cargoEndDateMaskBox.Text) ? null : DateTime.TryParse(cargoEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoEnd) ? cargoEnd : null) ||
                freightData.CARGO_LET != (string.IsNullOrEmpty(cargoLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(cargoLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var cargoLetter) ? cargoLetter : null) ||
                freightData.CARG_COV1 != (string.IsNullOrEmpty(cargoCov1TextBox.Text) ? null : int.Parse(cargoCov1TextBox.Text)) ||
                freightData.CARG_COV2 != (string.IsNullOrEmpty(cargoCov2TextBox.Text) ? null : int.Parse(cargoCov2TextBox.Text)) ||
                freightData.CARG_COV3 != (string.IsNullOrEmpty(cargoCov3TextBox.Text) ? null : int.Parse(cargoCov3TextBox.Text)) ||
                freightData.CARG_COV4 != (string.IsNullOrEmpty(cargoCov4TextBox.Text) ? null : int.Parse(cargoCov4TextBox.Text)) ||
                freightData.PHY_BEG != (string.IsNullOrEmpty(damageBeginDateMaskBox.Text) ? null : DateTime.TryParse(damageBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var damageBeg) ? damageBeg : null) ||
                freightData.PHY_END != (string.IsNullOrEmpty(damageEndDateMaskBox.Text) ? null : DateTime.TryParse(damageEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var damageEnd) ? damageEnd : null) ||
                freightData.PHY_COV1 != (string.IsNullOrEmpty(damageCov1TextBox.Text) ? null : int.Parse(damageCov1TextBox.Text)) ||
                freightData.PHY_COV2 != (string.IsNullOrEmpty(damageCov2TextBox.Text) ? null : int.Parse(damageCov2TextBox.Text)) ||
                freightData.CANCEL != (string.IsNullOrEmpty(cancellationTextBox.Text) ? null : int.Parse(cancellationTextBox.Text));
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

    }
}