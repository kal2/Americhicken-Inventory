using Inventory.Interfaces;
using Inventory.Models;
using System.Globalization;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitInsuranceSupplier : UserControl, IActiveControlManager
    {
        // --- class variables --- //
        private readonly ActiveControlManager _activeControlHelper;
        private readonly MainWindow _mainWindow;
        private readonly AmerichickenContext _dbContext;
        private rem_sup _remitData;
        public RemitInsuranceSupplier(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _activeControlHelper = activeControlManager;
            _mainWindow = mainWindow;
            _dbContext = new AmerichickenContext();
            this.Load += (s, e) => insTp1TextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("ADD REMIT TO SUPPLIER INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel");
        }

        public void DisplayRemitInsuranceData(rem_sup remitToObject)
        {
            _remitData = remitToObject;
        }

        public void UpdateRemitInsuranceData(rem_sup remitToData)
        {
            if (remitToData != null)
            {
                if (IsDataModified(remitToData))
                {
                    UpdateExistingRemitInsurance(remitToData);

                    var existingRemData = _dbContext.rem_sup.Find(remitToData.PK_rem_sup);

                    _dbContext.SaveChanges();
                    _remitData = existingRemData;
                }
            }
            else
            {
                MessageBox.Show("ERROR: Remit Data not found in database. Please try again or contact developer.");
            }
        }

        public bool IsDataModified(rem_sup remitToData)
        {
            return remitToData == null || 
                   remitToData.ins_tp1 != insTp1TextBox.Text ||
                   remitToData.ins_tp2 != insTp2TextBox.Text ||
                   remitToData.ins_tp3 != insTp3TextBox.Text ||
                   remitToData.ins_tp4 != insTp4TextBox.Text ||
                   remitToData.ins_tp5 != insTp5TextBox.Text ||
                   remitToData.policy1 != policy1TextBox.Text ||
                   remitToData.gen_beg != DateTime.Parse(genBeginDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.gen_end != DateTime.Parse(genEndDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.gen_let != DateTime.Parse(genLetterSentDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.gen_cov1 != decimal.Parse(genCov1TextBox.Text) ||
                   remitToData.gen_cov2 != decimal.Parse(genCov2TextBox.Text) ||
                   remitToData.gen_cov3 != decimal.Parse(genCov3TextBox.Text) ||
                   remitToData.gen_cov4 != decimal.Parse(genCov4TextBox.Text) ||
                   remitToData.gen_cov5 != decimal.Parse(genCov5TextBox.Text) ||
                   remitToData.gen_cov6 != decimal.Parse(genCov6TextBox.Text) ||
                   remitToData.policy2 != policy2TextBox.Text ||
                   remitToData.auto_beg != DateTime.Parse(autoBeginDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.auto_end != DateTime.Parse(autoEndDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.auto_let != DateTime.Parse(autoLetterSentDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.auto_cov1 != decimal.Parse(autoCov1TextBox.Text) ||
                   remitToData.auto_cov2 != decimal.Parse(autoCov2TextBox.Text) ||
                   remitToData.auto_cov3 != decimal.Parse(autoCov3TextBox.Text) ||
                   remitToData.auto_cov4 != decimal.Parse(autoCov4TextBox.Text) ||
                   remitToData.policy3 != policy3TextBox.Text ||
                   remitToData.exces_beg != DateTime.Parse(excessBeginDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.exces_end != DateTime.Parse(excessEndDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.exces_let != DateTime.Parse(excessLetterSentDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.exce_cov1 != decimal.Parse(excessCov1TextBox.Text) ||
                   remitToData.exce_cov2 != decimal.Parse(excessCov2TextBox.Text) ||
                   remitToData.policy4 != policy4TextBox.Text ||
                   remitToData.work_beg != DateTime.Parse(workBeginDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.work_end != DateTime.Parse(workEndDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.work_let != DateTime.Parse(workLetterSentDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.work_cov1 != decimal.Parse(workCov1TextBox.Text) ||
                   remitToData.work_cov2 != decimal.Parse(workCov2TextBox.Text) ||
                   remitToData.work_cov3 != decimal.Parse(workCov3TextBox.Text) ||
                   remitToData.policy5 != policy5TextBox.Text ||
                   remitToData.recal_beg != DateTime.Parse(recallBeginDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.recal_end != DateTime.Parse(recallEndDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.recal_let != DateTime.Parse(recallLetterSentDateMaskBox.Text, new CultureInfo("en-US")) ||
                   remitToData.reca_cov1 != decimal.Parse(recallCov1TextBox.Text) ||
                   remitToData.cancel != decimal.Parse(cancellationTextBox.Text);
        }

        private void UpdateExistingRemitInsurance(rem_sup remitToData)
        {
            var existingRemData = _dbContext.rem_sup.Find(remitToData.PK_rem_sup);
            if (existingRemData != null)
            {
                SetRemitToInsuranceProperties(existingRemData);
                _dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Remit Data not found. Please try again or contact developer.");
            }
        }

        private void SetRemitToInsuranceProperties(rem_sup existingRemSup)
        {
            existingRemSup.ins_tp1 = insTp1TextBox.Text;
            existingRemSup.ins_tp2 = insTp2TextBox.Text;
            existingRemSup.ins_tp3 = insTp3TextBox.Text;
            existingRemSup.ins_tp4 = insTp4TextBox.Text;
            existingRemSup.ins_tp5 = insTp5TextBox.Text;
            existingRemSup.policy1 = policy1TextBox.Text;
            existingRemSup.gen_beg = string.IsNullOrEmpty(genBeginDateMaskBox.Text) ? null : DateTime.TryParse(genBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genBeg) ? genBeg : null;
            existingRemSup.gen_end = string.IsNullOrEmpty(genEndDateMaskBox.Text) ? null : DateTime.TryParse(genEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genEnd) ? genEnd : null;
            existingRemSup.gen_let = string.IsNullOrEmpty(genLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(genLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var genLet) ? genLet : null;
            existingRemSup.gen_cov1 = decimal.Parse(genCov1TextBox.Text);
            existingRemSup.gen_cov2 = decimal.Parse(genCov2TextBox.Text);
            existingRemSup.gen_cov3 = decimal.Parse(genCov3TextBox.Text);
            existingRemSup.gen_cov4 = decimal.Parse(genCov4TextBox.Text);
            existingRemSup.gen_cov5 = decimal.Parse(genCov5TextBox.Text);
            existingRemSup.gen_cov6 = decimal.Parse(genCov6TextBox.Text);
            existingRemSup.policy2 = policy2TextBox.Text;
            existingRemSup.auto_beg = string.IsNullOrEmpty(autoBeginDateMaskBox.Text) ? null : DateTime.TryParse(autoBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoBeg) ? autoBeg : null;
            existingRemSup.auto_end = string.IsNullOrEmpty(autoEndDateMaskBox.Text) ? null : DateTime.TryParse(autoEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoEnd) ? autoEnd : null;
            existingRemSup.auto_let = string.IsNullOrEmpty(autoLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(autoLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var autoLet) ? autoLet : null;
            existingRemSup.auto_cov1 = decimal.Parse(autoCov1TextBox.Text);
            existingRemSup.auto_cov2 = decimal.Parse(autoCov2TextBox.Text);
            existingRemSup.auto_cov3 = decimal.Parse(autoCov3TextBox.Text);
            existingRemSup.auto_cov4 = decimal.Parse(autoCov4TextBox.Text);
            existingRemSup.policy3 = policy3TextBox.Text;
            existingRemSup.exces_beg = string.IsNullOrEmpty(excessBeginDateMaskBox.Text) ? null : DateTime.TryParse(excessBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var excessBeg) ? excessBeg : null;
            existingRemSup.exces_end = string.IsNullOrEmpty(excessEndDateMaskBox.Text) ? null : DateTime.TryParse(excessEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var excessEnd) ? excessEnd : null;
            existingRemSup.exces_let = string.IsNullOrEmpty(excessLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(excessLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var excessLet) ? excessLet : null;
            existingRemSup.exce_cov1 = decimal.Parse(excessCov1TextBox.Text);
            existingRemSup.exce_cov2 = decimal.Parse(excessCov2TextBox.Text);
            existingRemSup.policy4 = policy4TextBox.Text;
            existingRemSup.work_beg = string.IsNullOrEmpty(workBeginDateMaskBox.Text) ? null : DateTime.TryParse(workBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var workBeg) ? workBeg : null;
            existingRemSup.work_end = string.IsNullOrEmpty(workEndDateMaskBox.Text) ? null : DateTime.TryParse(workEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var workEnd) ? workEnd : null;
            existingRemSup.work_let = string.IsNullOrEmpty(workLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(workLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var workLet) ? workLet : null;
            existingRemSup.work_cov1 = decimal.Parse(workCov1TextBox.Text);
            existingRemSup.work_cov2 = decimal.Parse(workCov2TextBox.Text);
            existingRemSup.work_cov3 = decimal.Parse(workCov3TextBox.Text);
            existingRemSup.policy5 = policy5TextBox.Text;
            existingRemSup.recal_beg = string.IsNullOrEmpty(recallBeginDateMaskBox.Text) ? null: DateTime.TryParse(recallBeginDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var recallBeg) ? recallBeg : null;
            existingRemSup.recal_end = string.IsNullOrEmpty(recallEndDateMaskBox.Text) ? null : DateTime.TryParse(recallEndDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var recallEnd) ? recallEnd : null;
            existingRemSup.recal_let = string.IsNullOrEmpty(recallLetterSentDateMaskBox.Text) ? null : DateTime.TryParse(recallLetterSentDateMaskBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var recallLet) ? recallLet : null;
            existingRemSup.reca_cov1 = decimal.Parse(recallCov1TextBox.Text);
            existingRemSup.cancel = decimal.Parse(cancellationTextBox.Text);
        }

        private void LoadSupplierProgram()
        {
            RemitSupplier remitInstance = new(_mainWindow, _activeControlHelper);
            remitInstance.DisplayRemitToData(_remitData);
            _mainWindow.DisposeControl(this);
            _activeControlHelper.SetActiveControl(remitInstance);
        }

        public Dictionary<string, Action> AvailableActions
        {
            get
            {
                return new Dictionary<string, Action>
                {
                    {"1", () => UpdateRemitInsuranceData(_remitData)},
                    {"2", () => insTp1TextBox.Focus()},
                    {"3", () => LoadSupplierProgram()}
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
    }
}