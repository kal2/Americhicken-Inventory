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

            insTp1TextBox.Text = remitToObject.ins_tp1;
            insTp2TextBox.Text = remitToObject.ins_tp2;
            insTp3TextBox.Text = remitToObject.ins_tp3;
            insTp4TextBox.Text = remitToObject.ins_tp4;
            insTp5TextBox.Text = remitToObject.ins_tp5;
            policy1TextBox.Text = remitToObject.policy1;
            genBeginDateMaskBox.Text = remitToObject.gen_beg?.ToString("MM/dd/yyyy");
            genEndDateMaskBox.Text = remitToObject.gen_end?.ToString("MM/dd/yyyy");
            genLetterSentDateMaskBox.Text = remitToObject.gen_let?.ToString("MM/dd/yyyy");
            genCov1TextBox.Text = remitToObject.gen_cov1?.ToString();
            genCov2TextBox.Text = remitToObject.gen_cov2?.ToString();
            genCov3TextBox.Text = remitToObject.gen_cov3?.ToString();
            genCov4TextBox.Text = remitToObject.gen_cov4?.ToString();
            genCov5TextBox.Text = remitToObject.gen_cov5?.ToString();
            genCov6TextBox.Text = remitToObject.gen_cov6?.ToString();
            policy2TextBox.Text = remitToObject.policy2;
            autoBeginDateMaskBox.Text = remitToObject.auto_beg?.ToString("MM/dd/yyyy");
            autoEndDateMaskBox.Text = remitToObject.auto_end?.ToString("MM/dd/yyyy");
            autoLetterSentDateMaskBox.Text = remitToObject.auto_let?.ToString("MM/dd/yyyy");
            autoCov1TextBox.Text = remitToObject.auto_cov1?.ToString();
            autoCov2TextBox.Text = remitToObject.auto_cov2?.ToString();
            autoCov3TextBox.Text = remitToObject.auto_cov3?.ToString();
            autoCov4TextBox.Text = remitToObject.auto_cov4?.ToString();
            policy3TextBox.Text = remitToObject.policy3;
            excessBeginDateMaskBox.Text = remitToObject.exces_beg?.ToString("MM/dd/yyyy");
            excessEndDateMaskBox.Text = remitToObject.exces_end?.ToString("MM/dd/yyyy");
            excessLetterSentDateMaskBox.Text = remitToObject.exces_let?.ToString("MM/dd/yyyy");
            excessCov1TextBox.Text = remitToObject.exce_cov1?.ToString();
            excessCov2TextBox.Text = remitToObject.exce_cov2?.ToString();
            policy4TextBox.Text = remitToObject.policy4;
            workBeginDateMaskBox.Text = remitToObject.work_beg?.ToString("MM/dd/yyyy");
            workEndDateMaskBox.Text = remitToObject.work_end?.ToString("MM/dd/yyyy");
            workLetterSentDateMaskBox.Text = remitToObject.work_let?.ToString("MM/dd");
            workCov1TextBox.Text = remitToObject.work_cov1?.ToString();
            workCov2TextBox.Text = remitToObject.work_cov2?.ToString();
            workCov3TextBox.Text = remitToObject.work_cov3?.ToString();
            policy5TextBox.Text = remitToObject.policy5;
            recallBeginDateMaskBox.Text = remitToObject.recal_beg?.ToString("MM/dd/yyyy");
            recallEndDateMaskBox.Text = remitToObject.recal_end?.ToString("MM/dd/yyyy");
            recallLetterSentDateMaskBox.Text = remitToObject.recal_let?.ToString("MM/dd/yyyy");
            recallCov1TextBox.Text = remitToObject.reca_cov1?.ToString();
            cancellationTextBox.Text = remitToObject.cancel?.ToString();
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
                LoadSupplierProgram();
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
                   remitToData.gen_beg != Converter.ParseDateTime(genBeginDateMaskBox.Text) ||
                   remitToData.gen_end != Converter.ParseDateTime(genEndDateMaskBox.Text) ||
                   remitToData.gen_let != Converter.ParseDateTime(genLetterSentDateMaskBox.Text) ||
                   remitToData.gen_cov1 != Converter.ParseDecimal(genCov1TextBox.Text) ||
                   remitToData.gen_cov2 != Converter.ParseDecimal(genCov2TextBox.Text) ||
                   remitToData.gen_cov3 != Converter.ParseDecimal(genCov3TextBox.Text) ||
                   remitToData.gen_cov4 != Converter.ParseDecimal(genCov4TextBox.Text) ||
                   remitToData.gen_cov5 != Converter.ParseDecimal(genCov5TextBox.Text) ||
                   remitToData.gen_cov6 != Converter.ParseDecimal(genCov6TextBox.Text) ||
                   remitToData.policy2 != policy2TextBox.Text ||
                   remitToData.auto_beg != Converter.ParseDateTime(autoBeginDateMaskBox.Text) ||
                   remitToData.auto_end != Converter.ParseDateTime(autoEndDateMaskBox.Text) ||
                   remitToData.auto_let != Converter.ParseDateTime(autoLetterSentDateMaskBox.Text) ||
                   remitToData.auto_cov1 != Converter.ParseDecimal(autoCov1TextBox.Text) ||
                   remitToData.auto_cov2 != Converter.ParseDecimal(autoCov2TextBox.Text) ||
                   remitToData.auto_cov3 != Converter.ParseDecimal(autoCov3TextBox.Text) ||
                   remitToData.auto_cov4 != Converter.ParseDecimal(autoCov4TextBox.Text) ||
                   remitToData.policy3 != policy3TextBox.Text ||
                   remitToData.exces_beg != Converter.ParseDateTime(excessBeginDateMaskBox.Text) ||
                   remitToData.exces_end != Converter.ParseDateTime(excessEndDateMaskBox.Text) ||
                   remitToData.exces_let != Converter.ParseDateTime(excessLetterSentDateMaskBox.Text) ||
                   remitToData.exce_cov1 != Converter.ParseDecimal(excessCov1TextBox.Text) ||
                   remitToData.exce_cov2 != Converter.ParseDecimal(excessCov2TextBox.Text) ||
                   remitToData.policy4 != policy4TextBox.Text ||
                   remitToData.work_beg != Converter.ParseDateTime(workBeginDateMaskBox.Text) ||
                   remitToData.work_end != Converter.ParseDateTime(workEndDateMaskBox.Text) ||
                   remitToData.work_let != Converter.ParseDateTime(workLetterSentDateMaskBox.Text) ||
                   remitToData.work_cov1 != Converter.ParseDecimal(workCov1TextBox.Text) ||
                   remitToData.work_cov2 != Converter.ParseDecimal(workCov2TextBox.Text) ||
                   remitToData.work_cov3 != Converter.ParseDecimal(workCov3TextBox.Text) ||
                   remitToData.policy5 != policy5TextBox.Text ||
                   remitToData.recal_beg != Converter.ParseDateTime(recallBeginDateMaskBox.Text) ||
                   remitToData.recal_end != Converter.ParseDateTime(recallEndDateMaskBox.Text) ||
                   remitToData.recal_let != Converter.ParseDateTime(recallLetterSentDateMaskBox.Text) ||
                   remitToData.reca_cov1 != Converter.ParseDecimal(recallCov1TextBox.Text) ||
                   remitToData.cancel != Converter.ParseDecimal(cancellationTextBox.Text);
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
            existingRemSup.gen_beg = Converter.ParseDateTime(genBeginDateMaskBox.Text);
            existingRemSup.gen_end = Converter.ParseDateTime(genEndDateMaskBox.Text);
            existingRemSup.gen_let = Converter.ParseDateTime(genLetterSentDateMaskBox.Text);
            existingRemSup.gen_cov1 = Converter.ParseDecimal(genCov1TextBox.Text);
            existingRemSup.gen_cov2 = Converter.ParseDecimal(genCov2TextBox.Text);
            existingRemSup.gen_cov3 = Converter.ParseDecimal(genCov3TextBox.Text);
            existingRemSup.gen_cov4 = Converter.ParseDecimal(genCov4TextBox.Text);
            existingRemSup.gen_cov5 = Converter.ParseDecimal(genCov5TextBox.Text);
            existingRemSup.gen_cov6 = Converter.ParseDecimal(genCov6TextBox.Text);
            existingRemSup.policy2 = policy2TextBox.Text;
            existingRemSup.auto_beg = Converter.ParseDateTime(autoBeginDateMaskBox.Text);
            existingRemSup.auto_end = Converter.ParseDateTime(autoEndDateMaskBox.Text);
            existingRemSup.auto_let = Converter.ParseDateTime(autoLetterSentDateMaskBox.Text);
            existingRemSup.auto_cov1 = Converter.ParseDecimal(autoCov1TextBox.Text);
            existingRemSup.auto_cov2 = Converter.ParseDecimal(autoCov2TextBox.Text);
            existingRemSup.auto_cov3 = Converter.ParseDecimal(autoCov3TextBox.Text);
            existingRemSup.auto_cov4 = Converter.ParseDecimal(autoCov4TextBox.Text);
            existingRemSup.policy3 = policy3TextBox.Text;
            existingRemSup.exces_beg = Converter.ParseDateTime(excessBeginDateMaskBox.Text);
            existingRemSup.exces_end = Converter.ParseDateTime(excessEndDateMaskBox.Text);
            existingRemSup.exces_let = Converter.ParseDateTime(excessLetterSentDateMaskBox.Text);
            existingRemSup.exce_cov1 = Converter.ParseDecimal(excessCov1TextBox.Text);
            existingRemSup.exce_cov2 = Converter.ParseDecimal(excessCov2TextBox.Text);
            existingRemSup.policy4 = policy4TextBox.Text;
            existingRemSup.work_beg = Converter.ParseDateTime(workBeginDateMaskBox.Text);
            existingRemSup.work_end = Converter.ParseDateTime(workEndDateMaskBox.Text);
            existingRemSup.work_let = Converter.ParseDateTime(workLetterSentDateMaskBox.Text);
            existingRemSup.work_cov1 = Converter.ParseDecimal(workCov1TextBox.Text);
            existingRemSup.work_cov2 = Converter.ParseDecimal(workCov2TextBox.Text);
            existingRemSup.work_cov3 = Converter.ParseDecimal(workCov3TextBox.Text);
            existingRemSup.policy5 = policy5TextBox.Text;
            existingRemSup.recal_beg = Converter.ParseDateTime(recallBeginDateMaskBox.Text);
            existingRemSup.recal_end = Converter.ParseDateTime(recallEndDateMaskBox.Text);
            existingRemSup.recal_let = Converter.ParseDateTime(recallLetterSentDateMaskBox.Text);
            existingRemSup.reca_cov1 = Converter.ParseDecimal(recallCov1TextBox.Text);
            existingRemSup.cancel = Converter.ParseDecimal(cancellationTextBox.Text);

            _remitData = existingRemSup;
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