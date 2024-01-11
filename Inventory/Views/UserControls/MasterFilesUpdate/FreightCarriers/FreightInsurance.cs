/*using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;*/
using System.Globalization;
/*using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;*/
using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;

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
            _mainWindow.SetProgramLabel("Freight Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel    4. Main Menu");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //Save
                    UpdateFreightInsuranceData(_freightData);
                    break;
                case "2":
                    //Edit
                    insTp1TextBox.Focus();
                    break;
                case "3":
                    //Cancel
                    _mainWindow.DisposeControl(this);
                    FreightCarriers freightCarriers = new FreightCarriers(_mainWindow, _activeControlManager);
                    freightCarriers.GetFreightCarrierData(_freightData);
                    _activeControlManager.SetActiveControl(freightCarriers);
                    break;
                case "4":
                    //Main Menu
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please try again or contact developer");
                    break;
            }
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
                insTp1TextBox.Text = _freightData.INS_TP1?.Trim();
                insTp2TextBox.Text = _freightData.INS_TP2?.Trim();
                insTp3TextBox.Text = _freightData.INS_TP3?.Trim();
                insTp4TextBox.Text = _freightData.INS_TP4?.Trim();
                insTp5TextBox.Text = _freightData.INS_TP5?.Trim();
                policy1TextBox.Text = _freightData.POLICY1?.Trim();
                policy2TextBox.Text = _freightData.POLICY2?.Trim();
                policy3TextBox.Text = _freightData.POLICY3?.Trim();
                policy4TextBox.Text = _freightData.POLICY4?.Trim();
                policy5TextBox.Text = _freightData.POLICY5?.Trim();
                genBeginDateMaskBox.Text = _freightData.GEN_BEG?.ToString("MM/dd/yyyy").Trim();
                genEndDateMaskBox.Text = _freightData.GEN_END?.ToString("MM/dd/yyyy").Trim();
                genLetterSentDateMaskBox.Text = _freightData.GEN_LET?.ToString("MM/dd/yyyy").Trim();
                genCov4TextBox.Text = _freightData.GEN_COV4?.ToString();
                genCov5TextBox.Text = _freightData.GEN_COV5?.ToString();
                genCov6TextBox.Text = _freightData.GEN_COV6?.ToString();
                genCov3TextBox.Text = _freightData.GEN_COV3?.ToString();
                genCov2TextBox.Text = _freightData.GEN_COV2?.ToString();
                genCov1TextBox.Text = _freightData.GEN_COV1?.ToString();
                autoBeginDateMaskBox.Text = _freightData.AUTO_BEG?.ToString("MM/dd/yyyy").Trim();
                autoEndDateMaskBox.Text = _freightData.AUTO_END?.ToString("MM/dd/yyyy").Trim();
                autoLetterSentDateMaskBox.Text = _freightData.AUTO_LET?.ToString("MM/dd/yyyy").Trim();
                autoCov1TextBox.Text = _freightData.AUTO_COV1?.ToString();
                autoCov2TextBox.Text = _freightData.AUTO_COV2?.ToString();
                autoCov3TextBox.Text = _freightData.AUTO_COV3?.ToString();
                autoCov4TextBox.Text = _freightData.AUTO_COV4?.ToString();
                compBeginDateMaskBox.Text = _freightData.WORK_BEG?.ToString("MM/dd/yyyy").Trim();
                compEndDateMaskBox.Text = _freightData.WORK_END?.ToString("MM/dd/yyyy").Trim();
                compLetterSentDateMaskBox.Text = _freightData.WORK_LET?.ToString("MM/dd/yyyy").Trim();
                compCov1TextBox.Text = _freightData.WORK_COV1?.ToString();
                compCov2TextBox.Text = _freightData.WORK_COV2?.ToString();
                compCov3TextBox.Text = _freightData.WORK_COV3?.ToString();
                cargoBeginDateMaskBox.Text = _freightData.CARGO_BEG?.ToString("MM/dd/yyyy").Trim();
                cargoEndDateMaskBox.Text = _freightData.CARGO_END?.ToString("MM/dd/yyyy").Trim();
                cargoLetterSentDateMaskBox.Text = _freightData.CARGO_LET?.ToString("MM/dd/yyyy").Trim();
                cargoCov1TextBox.Text = _freightData.CARG_COV1?.ToString();
                cargoCov2TextBox.Text = _freightData.CARG_COV2?.ToString();
                cargoCov3TextBox.Text = _freightData.CARG_COV3?.ToString();
                cargoCov4TextBox.Text = _freightData.CARG_COV4?.ToString();
                damageBeginDateMaskBox.Text = _freightData.PHY_BEG?.ToString("MM/dd/yyyy").Trim();
                damageEndDateMaskBox.Text = _freightData.PHY_END?.ToString("MM/dd/yyyy").Trim();
                damageCov1TextBox.Text = _freightData.PHY_COV1?.ToString();
                damageCov2TextBox.Text = _freightData.PHY_COV2?.ToString();
                cancellationTextBox.Text = _freightData.CANCEL?.ToString();
            }
        }
        private void UpdateFreightInsuranceData(freight freightData)
        {
            if (freightData != null)
            {
                if (IsDataModified(freightData))
                {
                    var existingFreightData = _dbContext.freight.Find(freightData.PK_freight);
                    if (existingFreightData != null)
                    {
                        //Update Freight Insurance Data
                        existingFreightData.INS_TP1 = insTp1TextBox.Text.Trim();
                        existingFreightData.INS_TP2 = insTp2TextBox.Text.Trim();
                        existingFreightData.INS_TP3 = insTp3TextBox.Text.Trim();
                        existingFreightData.INS_TP4 = insTp4TextBox.Text.Trim();
                        existingFreightData.INS_TP5 = insTp5TextBox.Text.Trim();
                        existingFreightData.POLICY1 = policy1TextBox.Text.Trim();
                        existingFreightData.POLICY2 = policy2TextBox.Text.Trim();
                        existingFreightData.POLICY3 = policy3TextBox.Text.Trim();
                        existingFreightData.POLICY4 = policy4TextBox.Text.Trim();
                        existingFreightData.POLICY5 = policy5TextBox.Text.Trim();
                        existingFreightData.GEN_BEG = string.IsNullOrEmpty(genBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genBeg) ? genBeg : null;
                        existingFreightData.GEN_END = string.IsNullOrEmpty(genEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genEnd) ? genEnd : null;
                        existingFreightData.GEN_LET = string.IsNullOrEmpty(genLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genLetter) ? genLetter : null;
                        existingFreightData.GEN_COV4 = string.IsNullOrEmpty(genCov4TextBox.Text.Trim()) ? null : int.Parse(genCov4TextBox.Text.Trim());
                        existingFreightData.GEN_COV5 = string.IsNullOrEmpty(genCov5TextBox.Text.Trim()) ? null : int.Parse(genCov5TextBox.Text.Trim());
                        existingFreightData.GEN_COV6 = string.IsNullOrEmpty(genCov6TextBox.Text.Trim()) ? null : int.Parse(genCov6TextBox.Text.Trim());
                        existingFreightData.GEN_COV3 = string.IsNullOrEmpty(genCov3TextBox.Text.Trim()) ? null : int.Parse(genCov3TextBox.Text.Trim());
                        existingFreightData.GEN_COV2 = string.IsNullOrEmpty(genCov2TextBox.Text.Trim()) ? null : int.Parse(genCov2TextBox.Text.Trim());
                        existingFreightData.GEN_COV1 = string.IsNullOrEmpty(genCov1TextBox.Text.Trim()) ? null : int.Parse(genCov1TextBox.Text.Trim());
                        existingFreightData.AUTO_BEG = string.IsNullOrEmpty(autoBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoBeg) ? autoBeg : null;
                        existingFreightData.AUTO_END = string.IsNullOrEmpty(autoEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoEnd) ? autoEnd : null;
                        existingFreightData.AUTO_LET = string.IsNullOrEmpty(autoLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoLetter) ? autoLetter : null;
                        existingFreightData.AUTO_COV1 = string.IsNullOrEmpty(autoCov1TextBox.Text.Trim()) ? null : int.Parse(autoCov1TextBox.Text.Trim());
                        existingFreightData.AUTO_COV2 = string.IsNullOrEmpty(autoCov2TextBox.Text.Trim()) ? null : int.Parse(autoCov2TextBox.Text.Trim());
                        existingFreightData.AUTO_COV3 = string.IsNullOrEmpty(autoCov3TextBox.Text.Trim()) ? null : int.Parse(autoCov3TextBox.Text.Trim());
                        existingFreightData.AUTO_COV4 = string.IsNullOrEmpty(autoCov4TextBox.Text.Trim()) ? null : int.Parse(autoCov4TextBox.Text.Trim());
                        existingFreightData.WORK_BEG = string.IsNullOrEmpty(compBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compBeg) ? compBeg : null;
                        existingFreightData.WORK_END = string.IsNullOrEmpty(compEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compEnd) ? compEnd : null;
                        existingFreightData.WORK_LET = string.IsNullOrEmpty(compLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compLetter) ? compLetter : null;
                        existingFreightData.WORK_COV1 = string.IsNullOrEmpty(compCov1TextBox.Text.Trim()) ? null : int.Parse(compCov1TextBox.Text.Trim());
                        existingFreightData.WORK_COV2 = string.IsNullOrEmpty(compCov2TextBox.Text.Trim()) ? null : int.Parse(compCov2TextBox.Text.Trim());
                        existingFreightData.WORK_COV3 = string.IsNullOrEmpty(compCov3TextBox.Text.Trim()) ? null : int.Parse(compCov3TextBox.Text.Trim());
                        existingFreightData.CARGO_BEG = string.IsNullOrEmpty(cargoBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoBeg) ? cargoBeg : null;
                        existingFreightData.CARGO_END = string.IsNullOrEmpty(cargoEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoEnd) ? cargoEnd : null;
                        existingFreightData.CARGO_LET = string.IsNullOrEmpty(cargoLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoLetter) ? cargoLetter : null;
                        existingFreightData.CARG_COV1 = string.IsNullOrEmpty(cargoCov1TextBox.Text.Trim()) ? null : int.Parse(cargoCov1TextBox.Text.Trim());
                        existingFreightData.CARG_COV2 = string.IsNullOrEmpty(cargoCov2TextBox.Text.Trim()) ? null : int.Parse(cargoCov2TextBox.Text.Trim());
                        existingFreightData.CARG_COV3 = string.IsNullOrEmpty(cargoCov3TextBox.Text.Trim()) ? null : int.Parse(cargoCov3TextBox.Text.Trim());
                        existingFreightData.CARG_COV4 = string.IsNullOrEmpty(cargoCov4TextBox.Text.Trim()) ? null : int.Parse(cargoCov4TextBox.Text.Trim());
                        existingFreightData.PHY_BEG = string.IsNullOrEmpty(damageBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(damageBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var damageBeg) ? damageBeg : null;
                        existingFreightData.PHY_END = string.IsNullOrEmpty(damageEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(damageEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var damageEnd) ? damageEnd : null;
                        existingFreightData.PHY_COV1 = string.IsNullOrEmpty(damageCov1TextBox.Text.Trim()) ? null : int.Parse(damageCov1TextBox.Text.Trim());
                        existingFreightData.PHY_COV2 = string.IsNullOrEmpty(damageCov2TextBox.Text.Trim()) ? null : int.Parse(damageCov2TextBox.Text.Trim());
                        existingFreightData.CANCEL = string.IsNullOrEmpty(cancellationTextBox.Text.Trim()) ? null : int.Parse(cancellationTextBox.Text.Trim());

                        _freightData = existingFreightData;
                        //Save Freight Insurance Data
                        _dbContext.SaveChanges();
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Freight Insurance Data not found, please try again or contact developer");
                    }
                }
            }
            else
            {
                MessageBox.Show("ERROR: Freight Insurance Data is null, please try again or contact developer");
            }
            
        }
        private bool IsDataModified(freight freightData)
        {
            return freightData == null || freightData.INS_TP1 != insTp1TextBox.Text.Trim() ||
                freightData.INS_TP2 != insTp2TextBox.Text.Trim() ||
                freightData.INS_TP3 != insTp3TextBox.Text.Trim() ||
                freightData.INS_TP4 != insTp4TextBox.Text.Trim() ||
                freightData.INS_TP5 != insTp5TextBox.Text.Trim() ||
                freightData.POLICY1 != policy1TextBox.Text.Trim() ||
                freightData.POLICY2 != policy2TextBox.Text.Trim() ||
                freightData.POLICY3 != policy3TextBox.Text.Trim() ||
                freightData.POLICY4 != policy4TextBox.Text.Trim() ||
                freightData.POLICY5 != policy5TextBox.Text.Trim() ||
                freightData.GEN_BEG != (string.IsNullOrEmpty(genBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genBeg) ? genBeg : null) ||
                freightData.GEN_END != (string.IsNullOrEmpty(genEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genEnd) ? genEnd : null) ||
                freightData.GEN_LET != (string.IsNullOrEmpty(genLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(genLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var genLetter) ? genLetter : null) ||
                freightData.GEN_COV4 != (string.IsNullOrEmpty(genCov4TextBox.Text.Trim()) ? null : int.Parse(genCov4TextBox.Text.Trim())) ||
                freightData.GEN_COV5 != (string.IsNullOrEmpty(genCov5TextBox.Text.Trim()) ? null : int.Parse(genCov5TextBox.Text.Trim())) ||
                freightData.GEN_COV6 != (string.IsNullOrEmpty(genCov6TextBox.Text.Trim()) ? null : int.Parse(genCov6TextBox.Text.Trim())) ||
                freightData.GEN_COV3 != (string.IsNullOrEmpty(genCov3TextBox.Text.Trim()) ? null : int.Parse(genCov3TextBox.Text.Trim())) ||
                freightData.GEN_COV2 != (string.IsNullOrEmpty(genCov2TextBox.Text.Trim()) ? null : int.Parse(genCov2TextBox.Text.Trim())) ||
                freightData.GEN_COV1 != (string.IsNullOrEmpty(genCov1TextBox.Text.Trim()) ? null : int.Parse(genCov1TextBox.Text.Trim())) ||
                freightData.AUTO_BEG != (string.IsNullOrEmpty(autoBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoBeg) ? autoBeg : null) ||
                freightData.AUTO_END != (string.IsNullOrEmpty(autoEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoEnd) ? autoEnd : null) ||
                freightData.AUTO_LET != (string.IsNullOrEmpty(autoLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(autoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var autoLetter) ? autoLetter : null) ||
                freightData.AUTO_COV1 != (string.IsNullOrEmpty(autoCov1TextBox.Text.Trim()) ? null : int.Parse(autoCov1TextBox.Text.Trim())) ||
                freightData.AUTO_COV2 != (string.IsNullOrEmpty(autoCov2TextBox.Text.Trim()) ? null : int.Parse(autoCov2TextBox.Text.Trim())) ||
                freightData.AUTO_COV3 != (string.IsNullOrEmpty(autoCov3TextBox.Text.Trim()) ? null : int.Parse(autoCov3TextBox.Text.Trim())) ||
                freightData.AUTO_COV4 != (string.IsNullOrEmpty(autoCov4TextBox.Text.Trim()) ? null : int.Parse(autoCov4TextBox.Text.Trim())) ||
                freightData.WORK_BEG != (string.IsNullOrEmpty(compBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compBeg) ? compBeg : null) ||
                freightData.WORK_END != (string.IsNullOrEmpty(compEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compEnd) ? compEnd : null) ||
                freightData.WORK_LET != (string.IsNullOrEmpty(compLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(compLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var compLetter) ? compLetter : null) ||
                freightData.WORK_COV1 != (string.IsNullOrEmpty(compCov1TextBox.Text.Trim()) ? null : int.Parse(compCov1TextBox.Text.Trim())) ||
                freightData.WORK_COV2 != (string.IsNullOrEmpty(compCov2TextBox.Text.Trim()) ? null : int.Parse(compCov2TextBox.Text.Trim())) ||
                freightData.WORK_COV3 != (string.IsNullOrEmpty(compCov3TextBox.Text.Trim()) ? null : int.Parse(compCov3TextBox.Text.Trim())) ||
                freightData.CARGO_BEG != (string.IsNullOrEmpty(cargoBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoBeg) ? cargoBeg : null) ||
                freightData.CARGO_END != (string.IsNullOrEmpty(cargoEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoEnd) ? cargoEnd : null) ||
                freightData.CARGO_LET != (string.IsNullOrEmpty(cargoLetterSentDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(cargoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var cargoLetter) ? cargoLetter : null) ||
                freightData.CARG_COV1 != (string.IsNullOrEmpty(cargoCov1TextBox.Text.Trim()) ? null : int.Parse(cargoCov1TextBox.Text.Trim())) ||
                freightData.CARG_COV2 != (string.IsNullOrEmpty(cargoCov2TextBox.Text.Trim()) ? null : int.Parse(cargoCov2TextBox.Text.Trim())) ||
                freightData.CARG_COV3 != (string.IsNullOrEmpty(cargoCov3TextBox.Text.Trim()) ? null : int.Parse(cargoCov3TextBox.Text.Trim())) ||
                freightData.CARG_COV4 != (string.IsNullOrEmpty(cargoCov4TextBox.Text.Trim()) ? null : int.Parse(cargoCov4TextBox.Text.Trim())) ||
                freightData.PHY_BEG != (string.IsNullOrEmpty(damageBeginDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(damageBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var damageBeg) ? damageBeg : null) ||
                freightData.PHY_END != (string.IsNullOrEmpty(damageEndDateMaskBox.Text.Trim()) ? null : DateTime.TryParse(damageEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var damageEnd) ? damageEnd : null) ||
                freightData.PHY_COV1 != (string.IsNullOrEmpty(damageCov1TextBox.Text.Trim()) ? null : int.Parse(damageCov1TextBox.Text.Trim())) ||
                freightData.PHY_COV2 != (string.IsNullOrEmpty(damageCov2TextBox.Text.Trim()) ? null : int.Parse(damageCov2TextBox.Text.Trim())) ||
                freightData.CANCEL != (string.IsNullOrEmpty(cancellationTextBox.Text.Trim()) ? null : int.Parse(cancellationTextBox.Text.Trim()));
        }

    }
}